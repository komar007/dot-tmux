{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
        };
        tmux = pkgs.tmux;
        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      rec {
        # My tmux configuration: this enables tmux + populates ~/.tmux.conf and ~/.tmux/
        homeManagerModules.tmux =
          args:
          import ./hm-module.nix (
            args
            // {
              inherit pkgs tmux;
            }
          );
        homeManagerModules.default = homeManagerModules.tmux;

        # Alacritty unicode PUA key bindings required by some tmux binds
        homeManagerModules.alacrittyKeyBinds = import ./alacritty-bindings.nix;

        formatter = treefmtEval.config.build.wrapper;
        checks =
          let
            hmConfigBaseModule = {
              home = {
                username = "nix";
                homeDirectory = "/home/nix";
                stateVersion = "26.05";
              };
            };
            checkHmModule =
              mod:
              (inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  hmConfigBaseModule
                  mod
                ];
              }).activationPackage;
          in
          {
            formatting = treefmtEval.config.build.check self;
            typos = pkgs.runCommand "typos-check" {
              nativeBuildInputs = [ pkgs.typos ];
            } "cd ${self} && typos . && touch $out";
            home-manager-module = checkHmModule homeManagerModules.tmux;
          };
      }
    );
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # FIXME: we need relatively new nixfmt.
    # Consolidate with nixpkgs when we are ready to switch to tmux-3.6a
    nixpkgs-nixfmt.url = "github:nixos/nixpkgs/nixos-25.11";
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
        pkgs-nixfmt = import inputs.nixpkgs-nixfmt {
          inherit system;
        };
        tmux = pkgs.tmux;
        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs-nixfmt ./treefmt.nix;
      in
      rec {
        # My tmux configuration: this enables tmux + populates ~/.tmux.conf and ~/.tmux/
        homeManagerModules.tmux =
          args:
          import ./hm-module.nix (
            args
            // {
              inherit pkgs;
              inherit tmux;
            }
          );
        homeManagerModules.default = homeManagerModules.tmux;

        # Alacritty unicode PUA key bindings required by some tmux binds
        homeManagerModules.alacrittyKeyBinds = import ./alacritty-bindings.nix;

        formatter = treefmtEval.config.build.wrapper;
        checks = {
          formatting = treefmtEval.config.build.check self;
          typos = pkgs.runCommand "typos-check" {
            nativeBuildInputs = [ pkgs.typos ];
          } ''cd ${self} && typos . && touch $out'';
        };
      }
    );
}

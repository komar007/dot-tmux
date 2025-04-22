{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        tmux = pkgs.tmux;
      in rec {
        # My tmux configuration: this enables tmux + populates ~/.tmux.conf and ~/.tmux/
        homeManagerModules.tmux = args: import ./hm-module.nix (args // {
          inherit pkgs;
          inherit tmux;
        });
        homeManagerModules.default = homeManagerModules.tmux;

        # Alacritty unicode PUA key bindings required by some tmux binds
        homeManagerModules.alacrittyKeyBinds = import ./alacritty-bindings.nix;
      }
    );
}

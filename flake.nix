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
        packages.tmux = tmux;
        packages.default = packages.tmux;
        homeManagerModules.default = args: import ./hm-module.nix (args // {
          inherit pkgs;
          tmux = packages.tmux;
        });
      }
    );
}

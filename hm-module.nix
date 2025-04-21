{ config, lib, pkgs, tmux, ... }:
let
  pidtree_mon = pkgs.rustPlatform.buildRustPackage rec {
    pname = "pidtree_mon";
    version = "0.2.2";
    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-METVcuLDXXRjoYSuPGHj0Kv1QzpwIdnIBoCeQi5a38w=";
    };
    cargoHash = "sha256-6Z5dBwidZBz5Urt/n33l1MZRO4txDcG1Qk8RQmg6UoI=";
  };
  # set .tmux.conf's DEP_PREFIX to a directory we'll populate below with all dependencies...
  tmux-conf-input = builtins.readFile ./tmux.conf;
  tmux-conf = builtins.replaceStrings
    [ ''%hidden DEP_PREFIX=""'']
    [ ''%hidden DEP_PREFIX="~/.tmux/deps/"'' ]
    tmux-conf-input;
in
{
  config.home.packages = [
    tmux
  ];

  config.home.file.".tmux.conf".text = tmux-conf;

  config.home.file.".tmux/bin".source = ./tmux/bin;

  # ... dependencies of the tmux config:
  config.home.file = {
    ".tmux/deps/fzf".source = "${pkgs.fzf}/bin/fzf";
    ".tmux/deps/bat".source = "${pkgs.bat}/bin/bat";
    ".tmux/deps/xsel".source = "${pkgs.xsel}/bin/xsel";
    ".tmux/deps/pidtree_mon".source = "${pidtree_mon}/bin/pidtree_mon";
    ".tmux/deps/tput".source = "${pkgs.ncurses}/bin/tput";
  };
}

# Home-manager module with tmux & my personal configuration & the configuration's dependencies
{ config, lib, pkgs, tmux, ... }:
let
  pidtree_mon = pkgs.rustPlatform.buildRustPackage rec {
    pname = "pidtree_mon";
    version = "0.2.3";
    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-3UNs6Lvp5JwCzoqJUmOKxvI6VAbU5mbyJz75fYEzNEI=";
    };
    cargoHash = "sha256-6acEx49cTqAQ32AOdduKFbtC3K3jet9a8zBvIEnO1/g=";
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
  config.home.file.".tmux/conf.d".source = ./tmux/conf.d;

  # ... dependencies of the tmux config:
  config.home.file = {
    ".tmux/deps/fzf".source = "${pkgs.fzf}/bin/fzf";
    ".tmux/deps/bat".source = "${pkgs.bat}/bin/bat";
    ".tmux/deps/xsel".source = "${pkgs.xsel}/bin/xsel";
    ".tmux/deps/pidtree_mon".source = "${pidtree_mon}/bin/pidtree_mon";
    ".tmux/deps/tput".source = "${pkgs.ncurses}/bin/tput";
  };
}

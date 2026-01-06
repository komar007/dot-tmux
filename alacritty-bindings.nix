# This module adds alacritty keyboard bindings generated from tmux config using alacritty-binder
{ lib, ... }:
let
  tmux-conf = builtins.readFile ./tmux.conf;
  binder = import ./alacritty-binder.nix { inherit lib; };
in
{
  config.programs.alacritty.settings = {
    keyboard.bindings = binder.getAlacrittyBindings tmux-conf;
  };
}

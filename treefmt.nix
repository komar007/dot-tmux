{ ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  # FIXME: fix alacritty-binder formatting
  settings.formatter.nixfmt.excludes = [ "alacritty-binder.nix" ];
}

# Personal tmux configuration

## Features

Among the most notable features there are:

- a nice status bar,
- per-window CPU usage measurement,
- per-session shell (configure your shells in `~/shell.sh`),
- lots of key bindings for session, window and pane management,
- fuzzy session selector with session's active window preview,
- buffer/clipboard manager with fuzzy search,
- scrollback scraper (fuzzy-find and paste or open URLs and words from scrollback),
- multi-window scratch session in a popup,
- battery status with a nice icon, remaining percentage and charging status,
- neovim windows integration.

## Screenshots

![dot-tmux screenshot](/../main/screenshot1.png?raw=true "dot-tmux screenshot")

## Installation

If you want to try this configuration, you can install it either manually or through Home Manager.

### Home Manager

Modules for Home Manager are provided as a flake:

| module                                           | default            | description                                             |
|--------------------------------------------------|--------------------|---------------------------------------------------------|
| `homeManagerModules.${system}.tmux`              | :heavy_check_mark: | enables tmux and populates `~/.tmux.conf` and `~/.tmux` |
| `homeManagerModules.${system}.alacrittyKeyBinds` |                    | enables alacritty keybinds required by the config       |


<details>
<summary>
  New to home-manager? Expand installation instructions
</summary>

... or better, read the [guide](https://nix-community.github.io/home-manager/) first.

#### Installation

1. add the flake input:

   ```nix
   {
     inputs = {
       home-manager = {
         url = "github:nix-community/home-manager/release-24.11";
         inputs.nixpkgs.follows = "nixpkgs";
       };
       # ...
       komar007-dot-tmux = {
         url = "github:komar007/dot-tmux";
         inputs.flake-utils.follows = "flake-utils";
       };
       # ...
     };
   }
   ```

1. import the Home Manager modules:

   ```nix
   {
     inputs = # ...
     outputs = { self, home-manager, ... } @ inputs:
     let
       system = "x86_64-linux";
     in
     {
       home-manager.lib.homeManagerConfiguration {
         pkgs = # ...
         modules = [
           # ...
           (inputs.komar007-dot-tmux.homeManagerModules.${system}.default)
           (inputs.komar007-dot-tmux.homeManagerModules.${system}.alacrittyKeyBinds) # optional
         ];
       }
     }
   }
   ```

1. switch configuration:

   ```sh
   $ home-manager switch --flake .
   ```

</details>

### Manual installation

Clone the repository and from the cloned directory, run (after backing up your `~/.tmux.conf`):

``` sh
ln -s "$(pwd)/tmux.conf" ~/.tmux.conf
ln -s "$(pwd)/tmux" ~/.tmux
```

This configuration has some dependencies, which need to be installed and either available in `$PATH`
or in a directory which can be configured using the `DEP_PREFIX` variable at the top of `tmux.conf`
(see description in the file for details).

The list of dependencies is maintained in `hm-module.nix` under `config.home.file`. Most are either
already available in your distribution or can be installed via `cargo install`.

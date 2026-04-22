{ config, pkgs, ... }:

{
  imports = [
    ./system.nix
    ./hyprland.nix
    ./network.nix
    ./bluetooth.nix
    ./audio.nix
    ./localsend.nix
    ./performance.nix
    ./security.nix
    ./fonts.nix
  ];
}

{ config, pkgs, ... }:

{
  imports = [
    ./modules/nixos/default.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System state version
  system.stateVersion = "24.11";
}

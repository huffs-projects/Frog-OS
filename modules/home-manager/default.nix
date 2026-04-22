{ config, pkgs, inputs, ... }:

{
  imports = [
    ./themes.nix
    ./hyprland/configuration.nix
    ./kitty.nix
    ./yazi.nix
    ./zsh.nix
    ./starship.nix
    ./mako.nix
    ./wofi.nix
    ./neovim.nix
    ./waybar.nix
    ./mpd.nix
    ./ncmpcpp.nix
    ./hyprpaper.nix
    ./wallpaper-service.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./wlogout.nix
    ./webapps.nix
    ./fastfetch.nix
    ./cursor.nix
    ./git.nix
    ./gtk.nix
    ./btop.nix
    ./shell-tools.nix
  ];

  # Home Manager settings
  home.username = "frog";
  home.homeDirectory = "/home/frog";
  home.stateVersion = "24.11";

  # Packages managed by Home Manager
  home.packages = with pkgs; [
    # Window manager and desktop
    hyprpaper
    hypridle
    hyprlock
    
    # Terminal and shell
    kitty
    
    # File manager
    yazi
    
    # Applications
    firefox
    neovim
    spotify
    
    # Music
    mpd
    ncmpcpp
  ];

  # Enable programs with declarative configs
  programs.home-manager.enable = true;
  
  # Direnv configuration (package installed system-wide)
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}

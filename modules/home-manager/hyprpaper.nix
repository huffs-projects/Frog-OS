{ config, pkgs, ... }:

let
  # Wallpaper directory in user's home
  wallpaperDir = "${config.home.homeDirectory}/.local/share/wallpapers";
  
  # Default wallpaper (first one from Wallpapers directory)
  defaultWallpaper = "${wallpaperDir}/alena-aenami-away-1k.jpg";
  # Keep preloaded set intentionally small to reduce resident memory.
  preloadedWallpapers = [
    defaultWallpaper
    "${wallpaperDir}/alena-aenami-budapest.jpg"
    "${wallpaperDir}/OverTheCity.jpg"
  ];
in
{
  # Copy wallpapers from repo to user's wallpaper directory
  home.file.".local/share/wallpapers" = {
    source = ../../../Wallpapers;
    recursive = true;
  };

  # Hyprpaper configuration
  # Note: hyprpaper is started via exec-once in autostart.nix
  # Configuration file will be at ~/.config/hypr/hyprpaper.conf
  
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # Hyprpaper configuration
    # Wallpapers are stored in ~/.local/share/wallpapers
    
    # Preload only a small "hot set" for faster switching with lower memory use.
    # For larger sets, use wallpaper-manager.sh preload <count> on demand.
    ${builtins.concatStringsSep "\n    " (map (path: "preload = ${path}") preloadedWallpapers)}
    
    # Default wallpaper (applied to all monitors if specific ones aren't set)
    wallpaper = ,${defaultWallpaper}
    
    # Set wallpaper for specific monitors (uncomment and configure as needed)
    # wallpaper = DP-1,${wallpaperDir}/alena-aenami-budapest.jpg
    # wallpaper = HDMI-A-1,${wallpaperDir}/alena-aenami-ice1920.jpg
    
    # Enable splash screen
    splash = false
    
    # IPC socket for controlling hyprpaper
    ipc = true
  '';
}

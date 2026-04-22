{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Environment variables
    env = [
      "XCURSOR_SIZE,24"
      "XCURSOR_THEME,Catppuccin-Mocha-Blue-Cursors"
      "QT_QPA_PLATFORMTHEME,qt5ct"
    ];
    
    # XWayland
    xwayland = {
      use_nearest_neighbor = false;
      force_zero_scaling = false;
    };
  };
}

{ config, pkgs, theme, ... }:

let
  reducedMotion = config.frogos.ui.reducedMotion;
  # Helper function to convert hex to rgba (for hyprland)
  # Hyprland uses format: rgba(rrggbbaa) where rrggbbaa is hex without #
  hexToRgba = hex: alpha: 
    let
      # Remove # if present
      hexClean = builtins.replaceStrings ["#"] [""] hex;
      r = builtins.substring 0 2 hexClean;
      g = builtins.substring 2 2 hexClean;
      b = builtins.substring 4 2 hexClean;
    in "rgba(${r}${g}${b}${alpha})";
  
  # Convert theme colors to hyprland rgba format
  activeBorder = hexToRgba theme.accent "ee";
  inactiveBorder = hexToRgba theme.bg "aa";
  shadowColor = hexToRgba theme.bg "ee";
in
{
  imports = [
    ./bindings.nix
    ./windows.nix
    ./autostart.nix
    ./looknfeel.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration (will be auto-detected)
      monitor = ",preferred,auto,1";
      
      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
        };
        sensitivity = 0;
      };

      # General settings - using theme colors
      # Performance optimizations applied
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "${activeBorder}";
        "col.inactive_border" = "${inactiveBorder}";
        
        # Performance: Reduce cursor timeout
        cursor_inactive_timeout = 10;
        
        # Performance: Optimize layout switching
        layout = "dwindle";
        allow_tearing = false;
      };

      # Decoration - using theme colors
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "${shadowColor}";
      };

      # Animations
      animations = {
        enabled = if reducedMotion then "no" else "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Dwindle layout
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      # Master layout
      master = {
        new_is_master = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = "off";
      };

      # Workspace management
      workspace = [
        # Workspace 1 - General (default)
        "1, gapsout:10, gapsin:5"
        # Workspace 2 - Web browser
        "2, gapsout:10, gapsin:5"
        # Workspace 3 - Development
        "3, gapsout:10, gapsin:5"
        # Workspace 4 - Media
        "4, gapsout:10, gapsin:5"
        # Workspace 5 - Games
        "5, gapsout:0, gapsin:0"
      ];

      # Window swallowing configuration
      # When enabled, launching a GUI app from a terminal will temporarily
      # replace the terminal window. When the app closes, the terminal returns.
      misc = {
        enable_swallow = true;
        swallow_regex = "^.*$";
        # Disable Hyprland logo on startup
        disable_hyprland_logo = true;
        # Disable splash rendering
        disable_splash_rendering = true;
        # Force default workspace layout
        force_default_wallpaper = 0;
      };

      # Per-device config
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };
    };
  };
}

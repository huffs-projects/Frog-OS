{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Window rules - basic rules for floating windows
    windowrule = [
      # System utilities - float and center
      "float, ^(pavucontrol)$"
      "float, ^(blueman-manager)$"
      "float, ^(nm-connection-editor)$"
      "float, ^(wlogout)$"
      "float, ^(wofi)$"
      "float, ^(imv)$"
      "float, ^(mpv)$"
      
      # Size and position for system dialogs
      "size 800 600, ^(pavucontrol)$"
      "size 800 600, ^(blueman-manager)$"
      "size 800 600, ^(nm-connection-editor)$"
      "center, ^(pavucontrol)$"
      "center, ^(blueman-manager)$"
      "center, ^(nm-connection-editor)$"
      "center, ^(wlogout)$"
      
      # Calculator and similar utilities
      "float, ^(qalculate-gtk)$"
      "float, ^(gnome-calculator)$"
      "size 400 600, ^(qalculate-gtk)$"
      "size 400 600, ^(gnome-calculator)$"
      "center, ^(qalculate-gtk)$"
      "center, ^(gnome-calculator)$"
      
      # File pickers and dialogs
      "float, ^(thunar)$"
      "float, ^(file_progress)$"
      "float, ^(confirm)$"
      "float, ^(dialog)$"
      "float, ^(download)$"
      "float, ^(notification)$"
      "float, ^(error)$"
      "float, ^(splash)$"
      "float, ^(confirmreset)$"
      
      # Picture-in-picture windows
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"
      "size 25% 25%, title:^(Picture-in-Picture)$"
    ];
    
    # Windowrulev2 for more specific and conditional rules
    windowrulev2 = [
      # Transparency for terminals and file managers
      "opacity 0.9, class:^(kitty)$"
      "opacity 0.9, class:^(yazi)$"
      "opacity 0.95, class:^(foot)$"
      
      # Suppress maximize for all windows (prevents accidental fullscreen)
      "suppress Maximize, class:.*"
      
      # Focus rules - keep certain windows focused
      "stayfocused, title:^()$, class:^(wofi)$"
      "stayfocused, class:^(wlogout)$"
      
      # Workspace assignment rules
      "workspace 2, class:^(firefox)$"
      "workspace 3, class:^(code)$"
      "workspace 3, class:^(Code)$"
      "workspace 4, class:^(spotify)$"
      
      # Fullscreen rules for media players
      "fullscreen, class:^(mpv)$"
      "fullscreen, class:^(vlc)$"
      
      # XWayland fixes
      "nofocus, class:^(), title:^()$, xwayland:1, floating:1, fullscreen:0, pinned:0"
      
      # Fix for Steam
      "workspace 5, class:^(steam)$"
      "float, class:^(steam)$, title:^(Steam)$"
      
      # Fix for games
      "fullscreen, class:^(steam_app_)$"
      "fullscreen, class:^(steam_proton)$"
      
      # Fix for Electron apps that don't respect Wayland
      "windowdance, class:^(discord)$"
      "windowdance, class:^(Slack)$"
    ];
  };
}

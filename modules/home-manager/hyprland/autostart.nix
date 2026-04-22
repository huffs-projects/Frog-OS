{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Autostart applications
    # Optimized: Only essential services start immediately
    # Other services can be started on-demand or via systemd
    exec-once = [
      # Essential system services (start first)
      "waybar"                    # Status bar (required for system info)
      "mako"                      # Notification daemon (required for notifications)
      "hyprpaper"                 # Wallpaper daemon (required for wallpapers)
      
      # Security and system services
      "hypridle"                  # Idle daemon (required for auto-lock)
      
      # Clipboard management (lightweight, can run in background)
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      
      # Note: MPD is started as a user service (systemd), not via exec-once
      # This is more efficient and allows better service management
    ];
    
    # Performance: Delay non-critical startup
    # These can be started on-demand or via systemd user services
    # exec-once-delayed = [
    #   # Add non-critical services here if hyprland supports it
    # ];
  };
}

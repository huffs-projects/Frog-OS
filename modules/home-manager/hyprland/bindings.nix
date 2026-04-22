{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Keybindings
    "$mod" = "SUPER";
    
    bind = [
      # Application launcher
      "$mod, D, exec, wofi --show drun"
      "$mod, Return, exec, kitty"
      "$mod, Q, killactive"
      "$mod, M, exit"
      "$mod, E, exec, yazi"
      "$mod, V, togglefloating"
      "$mod, R, exec, wofi --show run"
      "$mod, P, pseudo"
      "$mod, J, togglesplit"
      
      # Move focus
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"
      
      # Switch workspaces
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
      
      # Move to workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"
      
      # Scroll through workspaces
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
      
      # Media controls
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
      
      # Brightness
      ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      
      # Screenshots
      ", Print, exec, hyprshot -m region"
      "$mod, Print, exec, hyprshot -m output"
      "$mod SHIFT, Print, exec, hyprshot -m window"
      
      # Lock screen
      "$mod, L, exec, hyprlock"
      
      # Clipboard history
      # Note: Pipes require shell execution, so we wrap with sh -c
      "$mod, C, exec, sh -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'"
      
      # Wallpaper management
      "$mod, W, exec, ${config.home.homeDirectory}/Frog-OS/scripts/wallpaper-manager.sh random"
      # Note: Pipes require shell execution, so we wrap with sh -c
      "$mod SHIFT, W, exec, sh -c '${config.home.homeDirectory}/Frog-OS/scripts/wallpaper-manager.sh list | wofi --dmenu | xargs -I {} ${config.home.homeDirectory}/Frog-OS/scripts/wallpaper-manager.sh set {}'"
      
      # Power menu
      "$mod SHIFT, M, exec, wlogout"
    ];
    
    bindm = [
      # Move/resize windows
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}

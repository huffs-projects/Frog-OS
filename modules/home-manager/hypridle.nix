{ config, pkgs, ... }:

{
  # Hypridle configuration
  # Configuration file will be at ~/.config/hypr/hypridle.conf
  
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
        ignore_dbus_inhibit = false
    }
    
    listener {
        timeout = 300  # 5 minutes
        on-timeout = brightnessctl -s set 10
        on-resume = brightnessctl -r
    }
    
    listener {
        timeout = 600  # 10 minutes
        on-timeout = hyprlock
    }
    
    listener {
        timeout = 900  # 15 minutes
        on-timeout = systemctl suspend
    }
  '';
}

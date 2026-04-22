{ config, pkgs, theme, ... }:

{
  xdg.configFile."wlogout/style.css".text = ''
    * {
      font-family: "Noto Sans", sans-serif;
      font-size: 14px;
    }

    window {
      background-color: ${theme.bg};
      border: 2px solid ${theme.fg};
      border-radius: 10px;
    }

    button {
      background-color: ${theme.bg};
      color: ${theme.fg};
      border: 1px solid ${theme.fg};
      border-radius: 5px;
      padding: 8px 12px;
      margin: 5px;
      min-width: 44px;
      min-height: 44px;
      transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
    }

    button:hover {
      background-color: ${theme.fg};
      color: ${theme.bg};
    }

    button:focus-visible {
      outline: 2px solid ${theme.accent};
      outline-offset: 2px;
    }

    @media (max-width: 1366px) {
      * {
        font-size: 13px;
      }

      window {
        border-width: 1px;
      }

      button {
        margin: 4px;
        padding: 8px 10px;
      }
    }
  '';

  xdg.configFile."wlogout/config".text = ''
    [logout]
    label = Logout
    action = loginctl terminate-user $USER

    [shutdown]
    label = Shutdown
    action = systemctl poweroff

    [reboot]
    label = Reboot
    action = systemctl reboot

    [suspend]
    label = Suspend
    action = systemctl suspend

    [lock]
    label = Lock
    action = hyprlock

    [cancel]
    label = Cancel
    action = exit
  '';
}

{ config, pkgs, theme, ... }:

let
  uiFont = "Noto Sans 11";
  gtkThemeName = "adw-gtk3-dark";
  reducedMotion = config.frogos.ui.reducedMotion;
  gtkAnimationsEnabled = !reducedMotion;

  gtkSharedCss = ''
    window {
      background-color: ${theme.bg};
      color: ${theme.fg};
    }

    entry {
      background-color: ${theme.bg};
      color: ${theme.fg};
      border-color: ${theme.accent};
    }

    button {
      background-color: ${theme.bg};
      color: ${theme.fg};
      border-color: ${theme.accent};
    }

    button:hover {
      background-color: ${theme.accent};
      color: ${theme.bg};
    }

    button:active {
      background-color: ${theme.accent};
      color: ${theme.bg};
    }

    label {
      color: ${theme.fg};
    }

    textview text {
      background-color: ${theme.bg};
      color: ${theme.fg};
    }

    treeview {
      background-color: ${theme.bg};
      color: ${theme.fg};
    }

    treeview:selected {
      background-color: ${theme.accent};
      color: ${theme.bg};
    }
  '';

  gtk4ButtonExtras = ''
    button {
      border-radius: 8px;
      padding: 8px 16px;
      min-height: 36px;
      transition: background-color 150ms ease-in-out, color 150ms ease-in-out, border-color 150ms ease-in-out;
    }
  '';
in
{
  gtk = {
    enable = true;

    # Use a consistent base theme so our token CSS overlays predictably.
    theme = {
      name = gtkThemeName;
      package = pkgs.adw-gtk3;
    };

    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-theme-name = gtkThemeName;
        gtk-icon-theme-name = "Adwaita";
        gtk-cursor-theme-name = "Catppuccin-Mocha-Blue";
        gtk-cursor-theme-size = 24;
        gtk-font-name = uiFont;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-enable-animations = gtkAnimationsEnabled;
        gtk-cursor-blink = true;
        gtk-cursor-blink-time = 1200;
        gtk-overlay-scrolling = true;
        gtk-kinetic-scrolling = true;
      };

      extraCss = gtkSharedCss;
    };

    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-theme-name = gtkThemeName;
        gtk-icon-theme-name = "Adwaita";
        gtk-cursor-theme-name = "Catppuccin-Mocha-Blue";
        gtk-cursor-theme-size = 24;
        gtk-font-name = uiFont;
        gtk-hint-font-metrics = false;
        gtk-enable-animations = gtkAnimationsEnabled;
        gtk-overlay-scrolling = true;
        gtk-kinetic-scrolling = true;
        gtk-enable-primary-paste = true;
        gtk-entry-select-on-focus = true;
        gtk-label-select-on-focus = true;
      };

      extraCss = gtkSharedCss + gtk4ButtonExtras;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };

    cursorTheme = {
      name = "Catppuccin-Mocha-Blue";
      package = pkgs.catppuccin-cursors.mochaBlue;
      size = 24;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = gtkThemeName;
      icon-theme = "Adwaita";
      cursor-theme = "Catppuccin-Mocha-Blue";
      font-name = uiFont;
      color-scheme = "prefer-dark";
      gtk-enable-animations = gtkAnimationsEnabled;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
  };
}

{ config, pkgs, theme, lib, ... }:

let
  inherit (import ./color-utils.nix { inherit lib; }) hexToHyprRgb;
  reducedMotion = config.frogos.ui.reducedMotion;

  frogosArtScript = pkgs.writeShellScript "frogos-art" ''
    cat << 'EOF'
███████╗██████╗  ██████╗  ██████╗  ██████╗ ███████╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝ ██╔═══██╗██╔════╝
█████╗  ██████╔╝██║   ██║██║  ███╗██║   ██║███████╗
██╔══╝  ██╔══██╗██║   ██║██║   ██║██║   ██║╚════██║
██║     ██║  ██║╚██████╔╝╚██████╔╝╚██████╔╝███████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
EOF
  '';

  bg = hexToHyprRgb theme.bg;
  fg = hexToHyprRgb theme.fg;
  accent = hexToHyprRgb theme.accent;
  red = hexToHyprRgb theme.red;
  green = hexToHyprRgb theme.green;
  inner = hexToHyprRgb theme.bg;
in
{
  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        disable_loading_bar = true
        hide_cursor = true
        grace = 0
        no_fade_in = ${if reducedMotion then "true" else "false"}
        no_fade_out = ${if reducedMotion then "true" else "false"}
        ignore_empty_input = true
        lock_on_empty = true
        input_delay = 0
        fail_on_empty = true
    }

    background {
        color = ${bg}
    }

    label {
        text = cmd[update:0] ${frogosArtScript}
        text_align = left
        color = ${accent}
        font_size = 12
        font_family = JetBrains Mono Nerd Font
        position = 0, -200
        halign = center
        valign = center
    }

    input-field {
        size = 250, 60
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        dots_rounding = -1
        outer_color = ${accent}
        inner_color = ${inner}
        font_color = ${fg}
        fade_on_empty = ${if reducedMotion then "false" else "true"}
        fade_timeout = 1000
        placeholder_text = <i>Password...</i>
        hide_input = true
        rounding = -1
        check_color = ${green}
        fail_color = ${red}
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        fail_transition = ${if reducedMotion then "0" else "300"}
        capslock_color = -1
        numlock_color = -1
        bothlock_color = -1
        invert_numlock = false
        swap_font_color = false
        position = 0, 50
        halign = center
        valign = center
    }

    label {
        text = cmd[update:1000] echo "<b>$(date +'%H:%M:%S')</b>"
        text_align = center
        color = ${fg}
        font_size = 60
        font_family = Noto Sans
        position = 0, 150
        halign = center
        valign = center
    }

    label {
        text = cmd[update:18000000] echo "$(date +'%A, %-d %B %Y')"
        text_align = center
        color = ${fg}
        font_size = 20
        font_family = Noto Sans
        position = 0, 220
        halign = center
        valign = center
    }
  '';
}

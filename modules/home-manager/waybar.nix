{ config, pkgs, theme, lib, ... }:

let
  inherit (import ./color-utils.nix { inherit lib; }) hexToCssRgba;
  reducedMotion = config.frogos.ui.reducedMotion;
  musicRefreshOnAc = config.frogos.ui.musicRefreshOnAc;
  musicRefreshOnBattery = config.frogos.ui.musicRefreshOnBattery;
  barHeight = if reducedMotion then 40 else 36;
  interactiveMinHeight = 44;

  # Music detection script that supports both playerctl (Spotify) and MPD
  musicScript = lib.writeShellScript "waybar-music" ''
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Escape JSON string values; collapse newlines so metadata never breaks the JSON line Waybar parses.
    json_escape() {
      printf '%s' "$1" | tr '\n\r' '  ' | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'
    }

    # Keep output cached to reduce expensive polling on battery.
    cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
    cache_file="$cache_dir/waybar-music.json"
    ts_file="$cache_dir/waybar-music.ts"
    mkdir -p "$cache_dir"

    power_mode="battery"
    if [ -r /sys/class/power_supply/AC/online ] && [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 0)" = "1" ]; then
      power_mode="ac"
    elif [ -r /sys/class/power_supply/ACAD/online ] && [ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo 0)" = "1" ]; then
      power_mode="ac"
    fi

    refresh_s=${toString musicRefreshOnBattery}
    if [ "$power_mode" = "ac" ]; then
      refresh_s=${toString musicRefreshOnAc}
    fi

    now_s="$(date +%s)"
    if [ -f "$cache_file" ] && [ -f "$ts_file" ]; then
      last_s="$(cat "$ts_file" 2>/dev/null || echo 0)"
      if [ "$last_s" -gt 0 ] && [ $((now_s - last_s)) -lt "$refresh_s" ]; then
        cat "$cache_file"
        exit 0
      fi
    fi
    
    # Try playerctl first (Spotify, Firefox, etc.)
    if command -v playerctl >/dev/null 2>&1; then
      player_status=$(playerctl status 2>/dev/null)
      if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
        metadata=$(playerctl metadata --format '{{artist}}|{{title}}|{{mpris:length}}' 2>/dev/null || echo "||0")
        artist=$(printf '%s' "$metadata" | awk -F'|' '{print $1}')
        title=$(printf '%s' "$metadata" | awk -F'|' '{print $2}')
        length=$(printf '%s' "$metadata" | awk -F'|' '{print $3}')
        position=$(playerctl position 2>/dev/null | cut -d. -f1 2>/dev/null || echo "0")
        
        # Convert nanoseconds to seconds for length
        if [ -n "$length" ] && [ "$length" != "0" ]; then
          length_sec=$((length / 1000000))
        else
          length_sec=0
        fi
        
        # Format time
        if [ -n "$position" ] && [ "$position" != "0" ]; then
          pos_min=$((position / 60))
          pos_sec=$((position % 60))
        else
          pos_min=0
          pos_sec=0
        fi
        
        if [ "$length_sec" -gt 0 ]; then
          len_min=$((length_sec / 60))
          len_sec=$((length_sec % 60))
          time_str=$(printf "%d:%02d/%d:%02d" $pos_min $pos_sec $len_min $len_sec)
        else
          time_str=$(printf "%d:%02d" $pos_min $pos_sec)
        fi
        
        if [ "$player_status" = "Playing" ]; then
          icon="󰎆"
          class="playing"
        else
          icon="󰏤"
          class="paused"
        fi
        
        if [ -n "$artist" ] && [ -n "$title" ]; then
          text_escaped=$(json_escape "$icon $artist - $title")
          tooltip_escaped=$(json_escape "$artist - $title ($time_str)")
        elif [ -n "$title" ]; then
          text_escaped=$(json_escape "$icon $title")
          tooltip_escaped=$(json_escape "$title ($time_str)")
        else
          text_escaped=$(json_escape "$icon No metadata")
          tooltip_escaped=$(json_escape "Playing ($time_str)")
        fi
        
        printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text_escaped" "$tooltip_escaped" "$class" | tee "$cache_file"
        printf '%s\n' "$now_s" > "$ts_file"
        exit 0
      fi
    fi
    
    # Fall back to MPD
    if command -v mpc >/dev/null 2>&1; then
      mpc_output=$(mpc status -f "%artist% - %title%" 2>/dev/null || true)
      if [ -n "$mpc_output" ]; then
        info=$(printf '%s\n' "$mpc_output" | awk 'NR==1 {print; exit}' || echo "")
        status_line=$(printf '%s\n' "$mpc_output" | awk 'NR==2 {print; exit}' || echo "")
        state=$(printf '%s' "$status_line" | awk '{print $1}' | tr -d '[]' || echo "stopped")
        elapsed=$(printf '%s' "$status_line" | grep -oE '[0-9]+:[0-9]+/[0-9]+:[0-9]+' | head -n 1 || echo "")

        if [ "$state" = "playing" ]; then
          icon="󰎆"
          class="playing"
          [ -n "$info" ] || info="Unknown"
          if [ -n "$elapsed" ]; then
            text_escaped=$(json_escape "$icon $info")
            tooltip_escaped=$(json_escape "$info ($elapsed)")
          else
            text_escaped=$(json_escape "$icon $info")
            tooltip_escaped=$(json_escape "$info")
          fi
        elif [ "$state" = "paused" ]; then
          icon="󰏤"
          class="paused"
          [ -n "$info" ] || info="Unknown"
          if [ -n "$elapsed" ]; then
            text_escaped=$(json_escape "$icon $info")
            tooltip_escaped=$(json_escape "$info ($elapsed)")
          else
            text_escaped=$(json_escape "$icon $info")
            tooltip_escaped=$(json_escape "$info")
          fi
        else
          icon="󰓛"
          class="stopped"
          text_escaped=$(json_escape "$icon Stopped")
          tooltip_escaped=$(json_escape "MPD Stopped")
        fi
        
        printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text_escaped" "$tooltip_escaped" "$class" | tee "$cache_file"
        printf '%s\n' "$now_s" > "$ts_file"
        exit 0
      fi
    fi
    
    # No player active - hide module by returning empty text
    printf '{"text":"","tooltip":"","class":"disconnected"}\n' | tee "$cache_file"
    printf '%s\n' "$now_s" > "$ts_file"
  '';
in
{
  options.frogos.ui.reducedMotion = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Reduce non-essential desktop motion and animation effects.";
  };

  options.frogos.ui.musicRefreshOnAc = lib.mkOption {
    type = lib.types.ints.positive;
    default = 4;
    description = "Music metadata refresh interval in seconds while on AC power.";
  };

  options.frogos.ui.musicRefreshOnBattery = lib.mkOption {
    type = lib.types.ints.positive;
    default = 10;
    description = "Music metadata refresh interval in seconds while on battery power.";
  };

  options.frogos.ui.makoWidth = lib.mkOption {
    type = lib.types.ints.positive;
    default = 420;
    description = "Mako notification width in pixels. Use ~300–360 on narrow displays; increase on ultrawide if needed.";
  };

  # Install music script
  home.file.".config/waybar/scripts/music.sh" = {
    source = musicScript;
    executable = true;
  };
  
  programs.waybar = {
    enable = true;
    package = null;  # Use system package
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = barHeight;
        spacing = 0;
        margin-top = 8;
        margin-bottom = 8;
        margin-left = 8;
        margin-right = 8;
        
        modules-left = [ "hyprland/workspaces" "custom/music" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "battery" ];
        
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          # Keep the icon-driven aesthetic, but expose window presence to reduce ambiguity.
          # `{windows}` renders window representations when configured by Waybar/Hyprland.
          format = "{icon}{windows}";
          format-window-separator = "";
          format-icons = {
            "1" = "󰨞";
            "2" = "󰈹";
            "3" = "󰊴";
            "4" = "󰈲";
            "5" = "󰊯";
            "6" = "󰊰";
            "7" = "󰊱";
            "8" = "󰊲";
            "9" = "󰊳";
            "10" = "󰊴";
            "urgent" = "󰗹";
            "focused" = "󰮯";
            "default" = "󰊽";
          };
        };
        
        "custom/music" = {
          format = "{}";
          exec = "${config.home.homeDirectory}/.config/waybar/scripts/music.sh";
          return-type = "json";
          interval = 5;
          max-length = 48;
          on-click = "playerctl play-pause 2>/dev/null || mpc toggle";
          on-click-right = "playerctl next 2>/dev/null || mpc next";
          on-click-middle = "playerctl previous 2>/dev/null || mpc prev";
        };
        
        clock = {
          format = "{:%H:%M}";
          tooltip-format = "<big>{:%A, %B %d, %Y}</big>\n<tt><small>{calendar}</small></tt>";
        };
        
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            headphone = "󰋋";
            hands-free = "󰋋";
            headset = "󰋋";
            phone = "󰄜";
            portable = "󰦧";
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
        };
        
        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀";
          tooltip-format = "{ifname} via {gwaddr} 󰈀";
          format-linked = "󰈀";
          format-disconnected = "󰤭";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };
        
        tray = {
          spacing = 8;
        };
      };
    };
    
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrains Mono Nerd Font", "Noto Sans", "Font Awesome 6 Free", sans-serif;
        font-size: 13px;
      }
      
      window#waybar {
        background-color: ${theme.bg};
        color: ${theme.fg};
        border: 1px solid ${hexToCssRgba theme.accent 0.9};
        border-radius: 8px;
        /* Slightly less “generic card shadow”: deeper + tighter, tinted to the active theme. */
        box-shadow:
          0 10px 26px ${hexToCssRgba theme.bg 0.65},
          0 1px 0 ${hexToCssRgba theme.fg 0.06} inset;
      }
      
      window#waybar.hidden {
        opacity: 0.3;
      }
      
      /* Workspaces - Mechabar style */
      #workspaces {
        padding: 0;
        margin: 0;
        background-color: transparent;
      }
      
      #workspaces button {
        padding: 0 8px;
        margin: 0 3px;
        background-color: transparent;
        color: ${theme.fg};
        border-radius: 4px;
        transition: background-color 0.2s ease, color 0.2s ease, opacity 0.2s ease;
        min-height: ${toString interactiveMinHeight}px;
      }
      
      #workspaces button:hover {
        background-color: ${hexToCssRgba theme.accent 0.2};
        color: ${theme.accent};
      }
      
      #workspaces button.focused {
        background-color: ${theme.accent};
        color: ${theme.bg};
        font-weight: bold;
      }
      
      #workspaces button.urgent {
        background-color: ${theme.red};
        color: ${theme.bg};
        animation: ${if reducedMotion then "none" else "urgent-flash 1s ease-in-out infinite"};
      }
      
      @keyframes urgent-flash {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.6; }
      }
      
      /* Music player - Supports both playerctl (Spotify) and MPD */
      #custom-music {
        padding: 0 12px;
        margin: 0 4px;
        background-color: transparent;
        color: ${theme.fg};
        font-weight: 500;
        min-width: 0;
        max-width: 46ch;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        min-height: ${toString interactiveMinHeight}px;
      }
      
      #custom-music.disconnected {
        color: ${theme.red};
        opacity: 0.7;
      }
      
      #custom-music.stopped {
        color: ${theme.yellow};
        opacity: 0.7;
      }
      
      #custom-music.playing {
        color: ${theme.green};
      }
      
      #custom-music.paused {
        color: ${theme.cyan};
      }
      
      #custom-music:hover {
        background-color: ${hexToCssRgba theme.accent 0.15};
      }
      
      /* Clock - Center module */
      #clock {
        padding: 0 14px;
        margin: 0 8px;
        background-color: ${theme.accent};
        color: ${theme.bg};
        font-weight: bold;
        border-radius: 4px;
        min-height: ${toString interactiveMinHeight}px;
      }
      
      /* Modules - Right side */
      #tray {
        padding: 0 8px;
        margin: 0 4px;
        background-color: transparent;
      }
      
      #pulseaudio,
      #network,
      #battery {
        padding: 0 10px;
        margin: 0 3px;
        margin-left: 6px;
        background-color: transparent;
        color: ${theme.fg};
        border-radius: 4px;
        transition: background-color 0.2s ease, color 0.2s ease;
        border-left: 1px solid ${hexToCssRgba theme.accent 0.2};
        padding-left: 10px;
        min-height: ${toString interactiveMinHeight}px;
      }
      
      /* Pulseaudio states */
      #pulseaudio {
        color: ${theme.blue};
      }
      
      #pulseaudio.muted {
        color: ${theme.red};
      }
      
      #pulseaudio:hover {
        background-color: ${hexToCssRgba theme.blue 0.15};
      }
      
      /* Network states */
      #network {
        color: ${theme.cyan};
      }
      
      #network.disconnected {
        color: ${theme.red};
      }
      
      #network:hover {
        background-color: ${hexToCssRgba theme.cyan 0.15};
      }
      
      /* Battery states */
      #battery {
        color: ${theme.green};
      }
      
      #battery.charging, #battery.plugged {
        color: ${theme.green};
      }
      
      #battery.warning:not(.charging) {
        color: ${theme.yellow};
      }
      
      @keyframes blink {
        to {
          background-color: ${theme.red};
          color: ${theme.bg};
        }
      }
      
      #battery.critical:not(.charging) {
        background-color: ${theme.red};
        color: ${theme.bg};
        animation-name: ${if reducedMotion then "none" else "blink"};
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: ${if reducedMotion then "1" else "infinite"};
        animation-direction: alternate;
        border-radius: 4px;
      }
      
      #battery:hover {
        background-color: ${hexToCssRgba theme.green 0.15};
      }
      
      /* Tray icons */
      #tray > .passive {
        -gtk-icon-effect: dim;
      }
      
      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: ${theme.red};
        color: ${theme.bg};
        border-radius: 4px;
      }
      
      /* Tooltip styling */
      tooltip {
        background-color: ${theme.bg};
        color: ${theme.fg};
        border: 1px solid ${theme.accent};
        border-radius: 6px;
        padding: 8px 12px;
        font-size: 12px;
      }
      
      /* Button interactions */
      button:hover {
        background-color: ${hexToCssRgba theme.accent 0.1};
      }
      
      label:focus {
        background-color: ${hexToCssRgba theme.accent 0.2};
      }

      #workspaces button:focus-visible,
      #custom-music:focus-visible,
      #pulseaudio:focus-visible,
      #network:focus-visible,
      #battery:focus-visible {
        outline: 2px solid ${theme.accent};
        outline-offset: 2px;
      }

      @media (prefers-reduced-motion: reduce) {
        #workspaces button,
        #pulseaudio,
        #network,
        #battery,
        #custom-music {
          transition: none;
        }

        #workspaces button.urgent,
        #battery.critical:not(.charging) {
          animation: none;
        }
      }

      /* Older laptop widths (ThinkPad-class 1366x768): tighten spacing but keep controls usable. */
      @media (max-width: 1366px) {
        * {
          font-size: 12px;
        }

        window#waybar {
          border-radius: 7px;
        }

        #workspaces button {
          padding: 0 7px;
          margin: 0 2px;
        }

        #clock {
          padding: 0 12px;
          margin: 0 6px;
        }

        #custom-music,
        #pulseaudio,
        #network,
        #battery {
          padding: 0 9px;
          margin-left: 4px;
        }
      }

      /* Very narrow desktop widths: preserve core status info and avoid wrap/crowding. */
      @media (max-width: 1180px) {
        #custom-music {
          display: none;
        }

        #network {
          padding: 0 7px;
        }

        #battery,
        #pulseaudio {
          padding: 0 8px;
        }
      }
    '';
  };
}

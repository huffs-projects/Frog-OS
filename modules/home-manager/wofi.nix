{ config, pkgs, theme, ... }:

{
  programs.wofi = {
    enable = true;
    
    settings = {
      # Use percentages for better behavior across resolutions/scales.
      width = "54%";
      height = "52%";
      # Keep sizing usable on both compact and large displays.
      normal_window = true;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = false;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 32;
      gtk_dark = true;
    };
    
    style = ''
      * {
        font-family: "Noto Sans", sans-serif;
        font-size: 13px;
      }
      
      window {
        background-color: ${theme.bg};
        border: 2px solid ${theme.accent};
        border-radius: 10px;
        min-width: 360px;
        min-height: 260px;
        max-width: 1100px;
        max-height: 780px;
      }
      
      #input {
        margin: 5px;
        border: none;
        color: ${theme.fg};
        background-color: ${theme.bg};
        border-radius: 5px;
        padding: 5px;
      }
      
      #inner-box {
        margin: 5px;
        border: none;
        background-color: ${theme.bg};
      }
      
      #outer-box {
        margin: 5px;
        border: none;
        background-color: ${theme.bg};
      }
      
      #scroll {
        margin: 0px;
        border: none;
      }
      
      #text {
        margin: 5px;
        border: none;
        color: ${theme.fg};
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      
      #entry:selected {
        background-color: ${theme.accent};
        color: ${theme.bg};
      }

      #entry {
        min-height: 44px;
        padding: 4px 8px;
      }

      #input:focus-visible,
      #entry:focus-visible {
        outline: 2px solid ${theme.accent};
        outline-offset: 2px;
      }
      
      #text:selected {
        color: ${theme.bg};
      }

      @media (max-width: 1366px) {
        * {
          font-size: 12px;
        }

        #entry {
          min-height: 44px;
          padding: 3px 7px;
        }
      }
    '';
  };
}

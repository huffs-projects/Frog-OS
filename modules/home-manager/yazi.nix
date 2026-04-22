{ config, pkgs, theme, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      manager = {
        ratio = [ 1 3 4 ];
        sort_by = "alphabetical";
        sort_dir_first = true;
        sort_reverse = false;
        linemode = "none";
        show_hidden = false;
        show_symlink = true;
      };
      
      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
        image_quality = 75;
        ueberzug_scale = 1;
        ueberzug_offset = [ 0 0 0 0 ];
      };
      
      # Configure openers - zathura, mpv, mpd as defaults
      opener = {
        # Zathura for PDFs
        zathura = [
          {
            run = ''${pkgs.zathura}/bin/zathura "$@"'';
            block = true;
            desc = "Open in Zathura";
            for = "unix";
          }
        ];
        
        # MPV for videos
        mpv = [
          {
            run = ''${pkgs.mpv}/bin/mpv "$@"'';
            orphan = true;
            desc = "Play in MPV";
            for = "unix";
          }
        ];
        
        # MPD/MPC for audio files
        mpc_add_play = [
          {
            run = ''${pkgs.mpc}/bin/mpc add "$@" && ${pkgs.mpc}/bin/mpc play'';
            orphan = true;
            desc = "Add to MPD and play";
            for = "unix";
          }
        ];
        
        # Default editor (neovim)
        edit = [
          {
            run = ''${pkgs.neovim}/bin/nvim "$@"'';
            block = true;
            desc = "Edit in Neovim";
            for = "unix";
          }
        ];
      };
      
      # File type associations
      open = {
        rules = [
          # PDF files - use zathura
          { mime = "application/pdf"; use = "zathura"; }
          
          # Video files - use mpv
          { mime = "video/*"; use = "mpv"; }
          
          # Audio files - use mpd/mpc
          { mime = "audio/*"; use = "mpc_add_play"; }
          
          # Text files - use default editor
          { mime = "text/*"; use = "edit"; }
        ];
      };
    };
    
    # Keybindings
    keymap = {
      manager = {
        # Navigation
        "<Esc>" = [ "escape" ];
        "<C-q>" = [ "quit" ];
        "<Enter>" = [ "enter" ];
        "<Backspace>" = [ "leave" ];
        "<Tab>" = [ "tab_switch" ];
        
        # File operations
        "y" = [ "yank" ];
        "p" = [ "paste" ];
        "d" = [ "remove" ];
        "r" = [ "rename" ];
        "c" = [ "copy" ];
        "x" = [ "cut" ];
        
        # Selection
        "<Space>" = [ "select" ];
        "v" = [ "visual_mode" ];
        "V" = [ "visual_mode" ];
        "<C-a>" = [ "select_all" ];
        
        # Search and filter
        "/" = [ "search" ];
        "f" = [ "find" ];
        "F" = [ "find_arrow" ];
        
        # Tabs
        "t" = [ "tab_create" ];
        "T" = [ "tab_create" "--current" ];
        "<C-w>" = [ "tab_close" ];
        
        # Other
        "h" = [ "leave" ];
        "l" = [ "enter" ];
        "j" = [ "arrow" "1" ];
        "k" = [ "arrow" "-1" ];
        "H" = [ "back" ];
        "L" = [ "forward" ];
        "J" = [ "arrow" "5" ];
        "K" = [ "arrow" "-5" ];
        "<C-r>" = [ "refresh" ];
        "." = [ "hidden" "toggle" ];
      };
    };
  };
}

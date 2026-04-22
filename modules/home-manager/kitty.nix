{ config, pkgs, theme, ... }:

{
  programs.kitty = {
    enable = true;
    
    # Font configuration - Code New Roman Nerd Font
    settings = {
      # Font family - Code New Roman Nerd Font
      font_family = "Code New Roman Nerd Font";
      font_size = 12.0;
      
      # Theme colors
      background = theme.bg;
      foreground = theme.fg;
      
      # Color palette using theme colors
      color0 = theme.bg;      # Black
      color1 = theme.red;     # Red
      color2 = theme.green;   # Green
      color3 = theme.yellow;  # Yellow
      color4 = theme.blue;    # Blue
      color5 = theme.magenta; # Magenta
      color6 = theme.cyan;    # Cyan
      color7 = theme.fg;      # White
      
      # Bright colors
      color8 = theme.bg;      # Bright black
      color9 = theme.red;     # Bright red
      color10 = theme.green;  # Bright green
      color11 = theme.yellow; # Bright yellow
      color12 = theme.blue;   # Bright blue
      color13 = theme.magenta;# Bright magenta
      color14 = theme.cyan;   # Bright cyan
      color15 = theme.fg;     # Bright white
      
      # Cursor and selection
      cursor = theme.accent;
      cursor_text_color = theme.bg;
      selection_background = theme.accent;
      selection_foreground = theme.bg;
      
      # Window settings
      window_padding_width = 8;
      window_margin_width = 0;
      window_border_width = 2;
      active_border_color = theme.accent;
      inactive_border_color = theme.bg;
      
      # Tab bar
      tab_bar_background = theme.bg;
      tab_bar_margin_color = theme.bg;
      active_tab_background = theme.accent;
      active_tab_foreground = theme.bg;
      inactive_tab_background = theme.bg;
      inactive_tab_foreground = theme.fg;
      
      # Bell
      bell_border_color = theme.yellow;
      
      # URL styling
      url_color = theme.cyan;
      url_style = "curly";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      
      # Scrollback
      scrollback_lines = 10000;
      scrollback_pager = "less";
      
      # Mouse
      mouse_hide_wait = 3.0;
      url_prefixes = "http https file ftp";
      open_url_with = "default";
      copy_on_select = "clipboard";
      
      # Terminal bell
      enable_audio_bell = false;
      visual_bell_duration = 0.0;
      
      # Window layout
      remember_window_size = true;
      initial_window_width = 640;
      initial_window_height = 400;
      
      # Font rendering
      disable_ligatures = false;
      font_features = "none";
      adjust_line_height = 0;
      adjust_column_width = 0;
    };
    
    # Keybindings
    keybindings = {
      # Window management
      "ctrl+shift+n" = "new_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+f" = "move_window_forward";
      "ctrl+shift+b" = "move_window_backward";
      "ctrl+shift+`" = "move_window_to_top";
      "ctrl+shift+r" = "start_resizing_window";
      "ctrl+shift+1" = "first_window";
      "ctrl+shift+2" = "second_window";
      "ctrl+shift+3" = "third_window";
      "ctrl+shift+4" = "fourth_window";
      "ctrl+shift+5" = "fifth_window";
      "ctrl+shift+6" = "sixth_window";
      "ctrl+shift+7" = "seventh_window";
      "ctrl+shift+8" = "eighth_window";
      "ctrl+shift+9" = "ninth_window";
      "ctrl+shift+0" = "tenth_window";
      
      # Tab management
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+." = "move_tab_forward";
      "ctrl+shift+," = "move_tab_backward";
      "ctrl+shift+alt+t" = "set_tab_title";
      
      # Font size
      "ctrl+plus" = "increase_font_size";
      "ctrl+minus" = "decrease_font_size";
      "ctrl+0" = "restore_font_size";
      
      # Scrollback
      "ctrl+shift+up" = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+page_up" = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end" = "scroll_end";
      "ctrl+shift+h" = "show_scrollback";
      
      # Selection
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      
      # Miscellaneous
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+u" = "kitten unicode_input";
      "ctrl+shift+f2" = "edit_config_file";
      "ctrl+shift+f5" = "load_config_file";
      "ctrl+shift+delete" = "clear_terminal reset active";
    };
  };
}

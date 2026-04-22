{ config, pkgs, theme, ... }:

{
  services.mako = {
    enable = true;
    
    backgroundColor = theme.bg;
    borderColor = theme.accent;
    borderRadius = 5;
    borderSize = 2;
    textColor = theme.fg;
    
    defaultTimeout = 10000;
    maxVisible = 5;
    sort = "-time";
    
    font = "Noto Sans 12";
    
    actions = true;
    icons = true;
    markup = 1;
    
    groupBy = "app-name";
    
    # Positioning
    anchor = "top-right";
    layer = "overlay";
    margin = "10";
    padding = "15";
    width = config.frogos.ui.makoWidth;
    # This is a max height; mako shrinks notifications to fit content.
    # Give longer localized bodies/actions room without forcing every notification tall.
    height = 240;
    
    # Urgency levels - using theme colors
    extraConfig = ''
      [urgency=low]
      border-color=${theme.cyan}
      default-timeout=5000
      
      [urgency=normal]
      border-color=${theme.accent}
      default-timeout=10000
      
      [urgency=critical]
      border-color=${theme.red}
      default-timeout=0
      background-color=${theme.red}
      text-color=${theme.bg}
    '';
  };
}

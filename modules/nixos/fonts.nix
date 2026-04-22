{ config, pkgs, ... }:

{
  # Font Configuration
  # Centralized font management for the system
  
  fonts = {
    # Enable font configuration
    enableDefaultFonts = false;
    
    # Font packages to install
    packages = with pkgs; [
      # Nerd Fonts - Programming fonts with icons
      # Includes: FiraCode, JetBrainsMono, CodeNewRoman
      # Used by: Terminal (kitty), Neovim, Waybar, GTK applications
      (nerdfonts.override { 
        fonts = [ 
          "FiraCode"      # Popular programming font with ligatures
          "JetBrainsMono" # Modern monospace font, default for GTK
          "CodeNewRoman"  # Code New Roman Nerd Font
        ]; 
      })
      
      # Noto Fonts - Comprehensive font family
      # Provides: Latin, CJK (Chinese, Japanese, Korean), Emoji support
      noto-fonts           # Base Noto fonts for Latin scripts
      noto-fonts-cjk       # Chinese, Japanese, Korean character support
      noto-fonts-emoji     # Emoji support for applications
    ];
    
    # Font configuration options
    fontconfig = {
      enable = true;
      
      # Default font settings
      defaultFonts = {
        # Serif fonts (for documents, reading)
        serif = [ "Noto Serif" ];
        
        # Sans-serif fonts (for UI, general text)
        sansSerif = [ "Noto Sans" ];
        
        # Monospace fonts (for code, terminal)
        monospace = [ 
          "Code New Roman Nerd Font"
          "JetBrains Mono Nerd Font" 
          "Fira Code Nerd Font"
        ];
        
        # Emoji font
        emoji = [ "Noto Color Emoji" ];
      };
      
      # Antialiasing settings
      antialias = true;
      
      # Subpixel rendering (better for LCD displays)
      subpixel = {
        rgba = "rgb";  # RGB subpixel layout (most common)
        lcdfilter = "default";
      };
      
      # Hinting (improves font rendering at small sizes)
      hinting = {
        enable = true;
        style = "slight";  # Options: none, slight, medium, full
      };
      
      # Cache settings
      cache32Bit = true;
    };
  };
}

{ config, pkgs, ... }:

let
  # Logo directory in user's home
  logoDir = "${config.home.homeDirectory}/.local/share/fastfetch";
  logoPath = "${logoDir}/FrogOS.png";
  
  # Fastfetch configuration following Option 5: Hybrid Balanced
  fastfetchConfig = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";
    logo = {
      type = "kitty";
      source = logoPath;
    };
    modules = [
      # System Info section
      "os"
      "host"
      "kernel"
      "uptime"
      "bootmgr"
      "separator"
      # Hardware section
      "cpu"
      "cpuusage"
      "gpu"
      "memory"
      "disk"
      "battery"
      "separator"
      # Network section
      "localip"
      "wifi"
      "bluetooth"
      "separator"
      # Software section
      "shell"
      "terminal"
      "editor"
      "packages"
      "de"
      "wm"
      "separator"
      # Theme section
      "wmtheme"
      "icons"
      "font"
      "cursor"
    ];
  };
in
{
  # Copy FrogOS logo to user's home directory
  home.file.".local/share/fastfetch/FrogOS.png" = {
    source = ../../../FrogOS.png;
  };
  
  # Write fastfetch configuration file
  xdg.configFile."fastfetch/config.jsonc" = {
    text = builtins.toJSON fastfetchConfig;
  };
}

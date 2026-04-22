{ config, pkgs, ... }:

{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
    fileWidgetCommand = "fd --type f";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    fd
    ripgrep
  ];

  home.shellAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    tree = "eza --tree";
    cat = "bat";
    grep = "rg";
    find = "fd";
  };
}

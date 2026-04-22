{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    
    shellAliases = {

      
      # Git
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gs = "git status";
      gd = "git diff";
      gb = "git branch";
      gco = "git checkout";
      glg = "lazygit";
      
      # System
      rebuild = "sudo nixos-rebuild switch --flake ~/Frog-OS";
      update = "nix flake update ~/Frog-OS";
      cleanup = "sudo nix-collect-garbage -d";
      
      # Navigation
      cd = "z";
      cdi = "zi";
    };
    
    initExtra = ''
      # Fastfetch on shell startup
      fastfetch
      

    '';
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
      ];
      theme = "robbyrussell";
    };
  };
}

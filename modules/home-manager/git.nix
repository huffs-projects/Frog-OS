{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = null;  # Use system package
    
    # User configuration - set these manually or uncomment and update:
    # userName = "Your Name";
    # userEmail = "your.email@example.com";
    
    # Global git config
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
      core.autocrlf = "input";
      
      # Aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        amend = "commit --amend --no-edit";
        wipe = "!git add -A && git commit -qm 'WIP' && git reset HEAD~1 --hard";
        bclean = ''!f() { git branch --merged ''${1:-main} | grep -v " ''${1:-main}$" | xargs git branch -d; }; f'';
        bdone = ''!f() { git checkout ''${1:-main} && git up && git bclean ''${1:-main}; }; f'';
      };
      
      # Color
      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };
      
      # Diff
      diff = {
        tool = "nvim";
        colorMoved = "default";
      };
      
      # Merge
      merge = {
        tool = "nvim";
        conflictstyle = "diff3";
      };
      
      # Push
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      
      # Pull
      pull = {
        ff = "only";
      };
      
      # Rebase
      rebase = {
        autoStash = true;
        autoSquash = true;
      };
      
      # Credential helper
      credential.helper = "store";
      
      # Safe directory (for system git operations)
      safe.directory = "*";
    };
    
    # LFS support
    lfs.enable = true;
    
    # Delta (better diff viewer) - optional, can be enabled if desired
    # delta.enable = true;
  };
}

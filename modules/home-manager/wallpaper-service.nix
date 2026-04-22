{ config, pkgs, ... }:
let
  rotateOnce = pkgs.writeShellApplication {
    name = "frog-wallpaper-rotate-once";
    runtimeInputs = with pkgs; [
      hyprland
      coreutils
      gnugrep
      procps
      gawk
      util-linux
    ];
    text = ''
      export FROG_WALLPAPER_ROTATE_SERVICE=1
      exec "${config.home.homeDirectory}/.local/bin/wallpaper-rotate.sh"
    '';
  };
in
{
  home.file.".local/bin/wallpaper-rotate.sh" = {
    source = ../../scripts/wallpaper-rotate.sh;
    executable = true;
  };

  systemd.user.services.frog-wallpaper-rotate = {
    Unit = {
      Description = "Rotate hyprpaper wallpaper (single step)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${rotateOnce}/bin/frog-wallpaper-rotate-once";
      # 77 = skipped (hyprpaper not ready, lock held, empty catalog, hyprctl failure) — avoid timer failure spam
      SuccessExitStatus = [ 0 77 ];
      Nice = 10;
    };
  };

  systemd.user.timers.frog-wallpaper-rotate = {
    Unit.Description = "Periodic wallpaper rotation for hyprpaper";
    Timer = {
      OnBootSec = "3min";
      OnUnitActiveSec = "15min";
      Unit = "frog-wallpaper-rotate.service";
      # Run soon after wake if a scheduled tick was missed (e.g. suspend/sleep)
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}

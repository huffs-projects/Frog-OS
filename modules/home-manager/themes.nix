# Theme colors are provided via home-manager.extraSpecialArgs.theme (see theme-data.nix + flake.nix).
{ theme, ... }:
{
  assertions = [
    {
      assertion =
        (theme ? bg)
        && (theme ? fg)
        && (theme ? accent)
        && (theme ? red)
        && (theme ? green)
        && (theme ? yellow)
        && (theme ? blue)
        && (theme ? magenta)
        && (theme ? cyan);
      message = "Frog-OS: theme must define bg, fg, accent, red, green, yellow, blue, magenta, and cyan (check themes/themes.toml)";
    }
  ];
}

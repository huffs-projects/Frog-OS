# Theme System

This directory contains theme definitions and configuration for Frog-OS.

> **Note**: A Rust-based theme manager utility is planned (see `THEME-MANAGER-PLANNING.md` and `theme-manager/` directory) but not yet integrated. For now, themes are managed manually via Nix files.

## Available Themes

All themes are defined in `modules/home-manager/themes.nix`. To switch themes, edit the `defaultTheme` variable.

### Standard Themes
- **tokyo-night** - Clean, dark theme with vibrant colors
- **everforest** - Comfortable & pleasant color scheme
- **gruvbox** - Retro groove color scheme (default)
- **kanagawa** - NeoVim dark colorscheme
- **nord** - Arctic, north-bluish color palette
- **matte-black** - Pure black minimalist theme

### Additional Themes
Additional themes may be available depending on your configuration. Check `modules/home-manager/themes.nix` to see which themes are currently defined in your setup.

## Switching Themes

1. Edit `modules/home-manager/themes.nix`
2. Change the `defaultTheme` variable to your desired theme name
3. Rebuild: `sudo nixos-rebuild switch --flake ~/Frog-OS#frogos`

## Theme Structure

Each theme contains:
- `name` - Display name
- `bg` - Background color
- `fg` - Foreground/text color
- `accent` - Accent color
- `red`, `green`, `yellow`, `blue`, `magenta`, `cyan` - Color palette

## Using Themes in Modules

Other modules can access the current theme via `_module.args.theme`:

```nix
{ config, pkgs, theme, ... }:

{
  # Use theme colors
  programs.kitty.settings.background = theme.bg;
  programs.kitty.settings.foreground = theme.fg;
}
```

## Adding New Themes

To add a new theme, add it to the `themes` attribute set in `modules/home-manager/themes.nix`:

```nix
my-theme = {
  name = "My Theme";
  bg = "#000000";
  fg = "#ffffff";
  accent = "#00ff00";
  # ... other colors
};
```

Then set `defaultTheme = "my-theme";` to use it.

# Pure helper: load active theme from themes/themes.toml (single source of truth).
{ ... }:
let
  data = builtins.fromTOML (builtins.readFile ../../themes/themes.toml);
  defaultName = data.metadata.default_theme or (throw "Frog-OS: themes/themes.toml missing metadata.default_theme");
  themes = data.themes or (throw "Frog-OS: themes/themes.toml missing [themes.*] tables");
  theme =
    themes.${defaultName} or (throw "Frog-OS: theme '${defaultName}' not found under [themes.*] in themes/themes.toml");
in
{
  inherit theme themes defaultName;
}

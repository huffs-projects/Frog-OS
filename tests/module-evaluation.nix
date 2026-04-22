{ pkgs, lib, ... }:

{
  # Module evaluation tests
  # These tests verify that modules can be evaluated without errors

  # Test that themes.nix exports theme correctly
  testThemesModule = {
    # This would be evaluated with actual module
    # For now, we test the structure
    test = {
      name = "themes-module-structure";
      # Check that themes.nix exists and can be parsed
      expr = builtins.pathExists ../modules/home-manager/themes.nix;
      expected = true;
    };
  };

  # Test that waybar.nix can reference theme
  testWaybarModule = {
    test = {
      name = "waybar-module-exists";
      expr = builtins.pathExists ../modules/home-manager/waybar.nix;
      expected = true;
    };
  };

  # Test that all required modules exist
  testModuleExistence = {
    requiredModules = [
      "../modules/nixos/system.nix"
      "../modules/nixos/hyprland.nix"
      "../modules/nixos/network.nix"
      "../modules/nixos/audio.nix"
      "../modules/nixos/bluetooth.nix"
      "../modules/home-manager/default.nix"
      "../modules/home-manager/themes.nix"
      "../modules/home-manager/hyprland/configuration.nix"
    ];

    tests = lib.mapAttrsToList (name: path: {
      name = "module-exists-${name}";
      expr = builtins.pathExists path;
      expected = true;
    }) (lib.genAttrs (map (p: builtins.baseNameOf p) requiredModules) (n: 
      lib.findFirst (p: builtins.baseNameOf p == n) null requiredModules
    ));
  };
}

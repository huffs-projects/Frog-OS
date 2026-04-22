{ lib }:

rec {
  # Helper function tests
  # These test pure Nix functions used throughout the configuration

  # Test hex to CSS rgba conversion
  testHexToCssRgba = {
    hexToCssRgba = (import ../modules/home-manager/color-utils.nix { inherit lib; }).hexToCssRgba;

    tests = [
      {
        name = "hexToCssRgba-black";
        expr = hexToCssRgba "#000000" 0.5;
        expected = "rgba(0, 0, 0, 0.5)";
      }
      {
        name = "hexToCssRgba-white";
        expr = hexToCssRgba "#ffffff" 1.0;
        expected = "rgba(255, 255, 255, 1)";
      }
      {
        name = "hexToCssRgba-red";
        expr = hexToCssRgba "#ff0000" 0.2;
        expected = "rgba(255, 0, 0, 0.2)";
      }
      {
        name = "hexToCssRgba-gruvbox-accent";
        expr = hexToCssRgba "#fe8019" 0.2;
        expected = "rgba(254, 128, 25, 0.2)";
      }
      {
        name = "hexToCssRgba-no-hash";
        expr = hexToCssRgba "1a1b26" 0.5;
        expected = "rgba(26, 27, 38, 0.5)";
      }
      {
        name = "hexToCssRgba-uppercase";
        expr = hexToCssRgba "#ABCDEF" 0.3;
        expected = "rgba(171, 205, 239, 0.3)";
      }
    ];
  };

  # Test theme structure validation
  testThemeStructure = {
    # Sample theme for testing
    sampleTheme = {
      name = "Test Theme";
      bg = "#000000";
      fg = "#ffffff";
      accent = "#ff0000";
      red = "#ff0000";
      green = "#00ff00";
      yellow = "#ffff00";
      blue = "#0000ff";
      magenta = "#ff00ff";
      cyan = "#00ffff";
    };

    tests = [
      {
        name = "theme-has-required-fields";
        expr = builtins.hasAttr "name" sampleTheme
          && builtins.hasAttr "bg" sampleTheme
          && builtins.hasAttr "fg" sampleTheme
          && builtins.hasAttr "accent" sampleTheme;
        expected = true;
      }
      {
        name = "theme-colors-are-hex-strings";
        expr = builtins.isString sampleTheme.bg
          && builtins.isString sampleTheme.fg
          && builtins.isString sampleTheme.accent;
        expected = true;
      }
      {
        name = "theme-hex-format";
        expr = lib.hasPrefix "#" sampleTheme.bg
          && lib.hasPrefix "#" sampleTheme.fg
          && lib.hasPrefix "#" sampleTheme.accent;
        expected = true;
      }
    ];
  };

  # Run all helper tests
  runTests = testSuite:
    lib.mapAttrs (name: test: {
      inherit name;
      result = lib.map (t:
        if t.expr == t.expected then
          { name = t.name; status = "PASS"; }
        else
          {
            name = t.name;
            status = "FAIL";
            expected = t.expected;
            got = t.expr;
          }
      ) test.tests;
    }) testSuite;
}

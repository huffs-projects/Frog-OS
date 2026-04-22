{ pkgs, lib, ... }:

let
  helpers = import ./helpers.nix { inherit lib; };
  moduleEval = import ./module-evaluation.nix { inherit pkgs lib; };
  vmTests = import ./nixos-vm-tests.nix { inherit pkgs; };
in
{
  # Main test suite entry point

  # Helper function tests
  helpers = helpers.runTests {
    hexToCssRgba = helpers.testHexToCssRgba;
    themeStructure = helpers.testThemeStructure;
  };

  # Module evaluation tests
  moduleEvaluation = moduleEval;

  # NixOS VM tests (only run on Linux systems with VM support)
  vmTests = vmTests;
}

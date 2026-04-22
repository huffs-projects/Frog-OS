{ pkgs, lib }:

# Example of how to write unit tests for Nix functions

let
  # The function we want to test
  hexToCssRgba = hex: alpha:
    let
      hexClean = builtins.replaceStrings ["#"] [""] hex;
      rHex = builtins.substring 0 2 hexClean;
      gHex = builtins.substring 2 2 hexClean;
      bHex = builtins.substring 4 2 hexClean;
      hexCharToDec = c:
        if c == "0" then 0
        else if c == "1" then 1
        else if c == "2" then 2
        else if c == "3" then 3
        else if c == "4" then 4
        else if c == "5" then 5
        else if c == "6" then 6
        else if c == "7" then 7
        else if c == "8" then 8
        else if c == "9" then 9
        else if c == "a" || c == "A" then 10
        else if c == "b" || c == "B" then 11
        else if c == "c" || c == "C" then 12
        else if c == "d" || c == "D" then 13
        else if c == "e" || c == "E" then 14
        else if c == "f" || c == "F" then 15
        else 0;
      hexToDec = s:
        let
          first = builtins.substring 0 1 s;
          second = builtins.substring 1 1 s;
        in (hexCharToDec first) * 16 + (hexCharToDec second);
      r = hexToDec rHex;
      g = hexToDec gHex;
      b = hexToDec bHex;
    in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";

  # Test cases
  testCases = [
    {
      name = "black-with-alpha";
      input = { hex = "#000000"; alpha = 0.5; };
      expected = "rgba(0, 0, 0, 0.5)";
    }
    {
      name = "white-full-opacity";
      input = { hex = "#ffffff"; alpha = 1.0; };
      expected = "rgba(255, 255, 255, 1)";
    }
    {
      name = "gruvbox-accent";
      input = { hex = "#fe8019"; alpha = 0.2; };
      expected = "rgba(254, 128, 25, 0.2)";
    }
  ];

  # Run tests
  runTest = testCase:
    let
      result = hexToCssRgba testCase.input.hex testCase.input.alpha;
      passed = result == testCase.expected;
    in
      {
        name = testCase.name;
        passed = passed;
        expected = testCase.expected;
        got = result;
      };

  results = map runTest testCases;
  allPassed = lib.all (r: r.passed) results;
in
{
  inherit hexToCssRgba;
  inherit testCases;
  inherit results;
  allPassed = allPassed;
}

# Shared hex color helpers for Waybar (CSS rgba) and Hyprland tools (rgb()).
{ lib }:
let
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

  hexToRgbComponents = hex:
    let
      hexClean = builtins.replaceStrings [ "#" ] [ "" ] hex;
      rHex = builtins.substring 0 2 hexClean;
      gHex = builtins.substring 2 2 hexClean;
      bHex = builtins.substring 4 2 hexClean;
    in {
      r = hexToDec rHex;
      g = hexToDec gHex;
      b = hexToDec bHex;
    };

  hexToHyprRgb = hex:
    let
      c = hexToRgbComponents hex;
    in "rgb(${toString c.r}, ${toString c.g}, ${toString c.b})";

  formatAlpha = a:
    let
      alphaStr = toString a;
      hasDecimal = lib.hasInfix "." alphaStr;
      removeTrailingZeros = str:
        if hasDecimal && lib.hasSuffix "0" str then
          removeTrailingZeros (lib.removeSuffix "0" str)
        else
          str;
      removeTrailingDot = str:
        if lib.hasSuffix "." str then lib.removeSuffix "." str else str;
    in removeTrailingDot (removeTrailingZeros alphaStr);

  hexToCssRgba = hex: alpha:
    let
      c = hexToRgbComponents hex;
    in "rgba(${toString c.r}, ${toString c.g}, ${toString c.b}, ${formatAlpha alpha})";
in
{
  inherit hexToRgbComponents hexToHyprRgb hexToCssRgba;
}

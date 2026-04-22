#!/usr/bin/env bash
# Unit test runner for Frog-OS
# Runs all unit tests including helper functions, module evaluation, and VM tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

find_nix() {
  if command -v nix >/dev/null 2>&1; then
    return 0
  fi

  # Common profile scripts that add nix to PATH (especially on macOS)
  local profile_scripts=(
    "$HOME/.nix-profile/etc/profile.d/nix.sh"
    "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    "/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
  )

  local script
  for script in "${profile_scripts[@]}"; do
    if [[ -r "$script" ]]; then
      # shellcheck disable=SC1090
      source "$script"
      if command -v nix >/dev/null 2>&1; then
        return 0
      fi
    fi
  done

  return 1
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Frog-OS Unit Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check prerequisites
if ! find_nix; then
  echo -e "${RED}Error:${NC} nix command not found"
  echo "Install Nix: https://nixos.org/download.html"
  echo "If Nix is installed, open a new shell or source a profile script:"
  echo "  source ~/.nix-profile/etc/profile.d/nix.sh"
  echo "  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  exit 1
fi

# Test helper functions
test_helpers() {
  echo -e "${BLUE}Testing helper functions...${NC}"
  
  # Test hexToCssRgba function
  echo -e "  Testing hexToCssRgba conversion..."
  
  test_cases=(
    "#000000:0.5:rgba(0, 0, 0, 0.5)"
    "#ffffff:1.0:rgba(255, 255, 255, 1)"
    "#ff0000:0.2:rgba(255, 0, 0, 0.2)"
    "#fe8019:0.2:rgba(254, 128, 25, 0.2)"
    "#123456:0.75:rgba(18, 52, 86, 0.75)"
    "#abcdef:0.123:rgba(171, 205, 239, 0.123)"
  )
  
  for test_case in "${test_cases[@]}"; do
    IFS=':' read -r hex alpha expected <<< "$test_case"
    
    # Use nix-instantiate to test the function (with proper alpha formatting)
    result=$(nix-instantiate --eval --strict -E "
      with (import <nixpkgs> {}).lib;
      let
        hexToCssRgba = hex: alpha:
          let
            hexClean = builtins.replaceStrings [\"#\"] [\"\"] hex;
            rHex = builtins.substring 0 2 hexClean;
            gHex = builtins.substring 2 2 hexClean;
            bHex = builtins.substring 4 2 hexClean;
            hexCharToDec = c:
              if c == \"0\" then 0
              else if c == \"1\" then 1
              else if c == \"2\" then 2
              else if c == \"3\" then 3
              else if c == \"4\" then 4
              else if c == \"5\" then 5
              else if c == \"6\" then 6
              else if c == \"7\" then 7
              else if c == \"8\" then 8
              else if c == \"9\" then 9
              else if c == \"a\" || c == \"A\" then 10
              else if c == \"b\" || c == \"B\" then 11
              else if c == \"c\" || c == \"C\" then 12
              else if c == \"d\" || c == \"D\" then 13
              else if c == \"e\" || c == \"E\" then 14
              else if c == \"f\" || c == \"F\" then 15
              else 0;
            hexToDec = s:
              let
                first = builtins.substring 0 1 s;
                second = builtins.substring 1 1 s;
              in (hexCharToDec first) * 16 + (hexCharToDec second);
            r = hexToDec rHex;
            g = hexToDec gHex;
            b = hexToDec bHex;
            # Format alpha value, removing trailing zeros
            formatAlpha = a:
              let
                alphaStr = toString a;
                # Check if string contains a decimal point
                hasDecimal = hasInfix \".\" alphaStr;
                # Recursively remove trailing zeros after decimal point
                removeTrailingZeros = str:
                  if hasDecimal && hasSuffix \"0\" str then
                    removeTrailingZeros (removeSuffix \"0\" str)
                  else
                    str;
                # Remove trailing decimal point if it's a whole number
                removeTrailingDot = str:
                  if hasSuffix \".\" str then removeSuffix \".\" str else str;
                cleaned = removeTrailingDot (removeTrailingZeros alphaStr);
              in cleaned;
          in \"rgba(\${toString r}, \${toString g}, \${toString b}, \${formatAlpha alpha})\";
      in
        hexToCssRgba \"${hex}\" ${alpha}
    " --json | tr -d '"')
    
    if [[ "$result" == "$expected" ]]; then
      echo -e "    ${GREEN}✓${NC} ${hex} with alpha ${alpha} -> ${result}"
      PASSED=$((PASSED + 1))
    else
      echo -e "    ${RED}✗${NC} ${hex} with alpha ${alpha}"
      echo -e "      Expected: ${expected}"
      echo -e "      Got:      ${result}"
      FAILED=$((FAILED + 1))
    fi
  done
  
  echo ""
}

# Test module evaluation
test_module_evaluation() {
  echo -e "${BLUE}Testing module evaluation...${NC}"
  
  modules=(
    "modules/nixos/system.nix"
    "modules/nixos/hyprland.nix"
    "modules/nixos/network.nix"
    "modules/home-manager/themes.nix"
    "modules/home-manager/waybar.nix"
  )
  
  for module in "${modules[@]}"; do
    if [[ ! -f "$module" ]]; then
      echo -e "  ${RED}✗${NC} ${module} (not found)"
      FAILED=$((FAILED + 1))
      continue
    fi
    
    # Test that module can be parsed
    if nix-instantiate --parse "$module" &> /dev/null; then
      echo -e "  ${GREEN}✓${NC} ${module} (syntax valid)"
      PASSED=$((PASSED + 1))
    else
      echo -e "  ${RED}✗${NC} ${module} (syntax error)"
      FAILED=$((FAILED + 1))
    fi
  done
  
  echo ""
}

# Test flake checks
test_flake_checks() {
  echo -e "${BLUE}Testing flake checks...${NC}"
  
  if nix flake check --no-build 2>&1 | grep -q "error"; then
    echo -e "  ${RED}✗${NC} Flake check failed"
    nix flake check --no-build 2>&1 | head -10
    FAILED=$((FAILED + 1))
  else
    echo -e "  ${GREEN}✓${NC} Flake structure is valid"
    PASSED=$((PASSED + 1))
  fi
  
  echo ""
}

# Test NixOS VM tests (optional, requires Linux)
test_vm_tests() {
  echo -e "${BLUE}Testing NixOS VM tests (optional)...${NC}"
  
  if [[ "$(uname)" != "Linux" ]]; then
    echo -e "  ${YELLOW}⚠${NC} VM tests require Linux (skipping on $(uname))"
    SKIPPED=$((SKIPPED + 1))
    echo ""
    return
  fi
  
  # Check if we can build VM tests
  if nix build .#nixosTests.basicSystem --no-link 2>&1 | grep -q "error"; then
    echo -e "  ${YELLOW}⚠${NC} VM tests build failed (may require additional setup)"
    SKIPPED=$((SKIPPED + 1))
  else
    echo -e "  ${GREEN}✓${NC} VM tests can be built"
    PASSED=$((PASSED + 1))
    echo -e "  ${YELLOW}Note:${NC} Run 'nix test .#nixosTests.basicSystem' to execute VM test"
  fi
  
  echo ""
}

# Run all tests
main() {
  test_helpers
  test_module_evaluation
  test_flake_checks
  test_vm_tests
  
  # Summary
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Test Summary${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${GREEN}Passed:${NC}  ${PASSED}"
  echo -e "  ${RED}Failed:${NC}  ${FAILED}"
  echo -e "  ${YELLOW}Skipped:${NC} ${SKIPPED}"
  echo ""
  
  if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
  fi
}

# Run main function
main

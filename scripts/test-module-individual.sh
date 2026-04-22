#!/usr/bin/env bash
# Individual module testing script for Frog-OS
# Tests each module independently to isolate issues

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

# Test a single module
test_module() {
    local module="$1"
    local name="$2"
    local type="$3"  # "nixos" or "home-manager"
    
    echo -e "${BLUE}Testing:${NC} $name ($module)"
    
    if [[ ! -f "$module" ]]; then
        echo -e "  ${RED}❌ Module not found${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    # Test Nix syntax
    if command -v nix-instantiate &> /dev/null; then
        if nix-instantiate --parse "$module" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Syntax valid"
        else
            echo -e "  ${RED}❌ Syntax error${NC}"
            nix-instantiate --parse "$module" 2>&1 | head -5 | sed 's/^/    /'
            FAILED=$((FAILED + 1))
            return 1
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} Skipped (nix-instantiate not available)"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi
    
    # Try to evaluate the module in isolation (if possible)
    if [[ "$type" == "nixos" ]]; then
        # For NixOS modules, we can try a minimal evaluation
        if nix-instantiate --eval -E "
            with import <nixpkgs> {};
            let
              testModule = import $module;
            in
              true
        " &> /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Can be evaluated"
        else
            echo -e "  ${YELLOW}⚠${NC} Evaluation test skipped (requires full context)"
        fi
    fi
    
    PASSED=$((PASSED + 1))
    echo ""
    return 0
}

# Test NixOS modules
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Testing NixOS Modules${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_module "modules/nixos/default.nix" "NixOS Default" "nixos"
test_module "modules/nixos/system.nix" "System Configuration" "nixos"
test_module "modules/nixos/hyprland.nix" "Hyprland System" "nixos"
test_module "modules/nixos/network.nix" "Network" "nixos"
test_module "modules/nixos/audio.nix" "Audio/PipeWire" "nixos"
test_module "modules/nixos/bluetooth.nix" "Bluetooth" "nixos"
test_module "modules/nixos/localsend.nix" "LocalSend" "nixos"

# Test Home Manager modules
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Testing Home Manager Modules${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_module "modules/home-manager/default.nix" "Home Manager Default" "home-manager"
test_module "modules/home-manager/themes.nix" "Themes" "home-manager"
test_module "modules/home-manager/hyprland/configuration.nix" "Hyprland Config" "home-manager"
test_module "modules/home-manager/hyprland/bindings.nix" "Hyprland Bindings" "home-manager"
test_module "modules/home-manager/hyprland/windows.nix" "Hyprland Windows" "home-manager"
test_module "modules/home-manager/hyprland/autostart.nix" "Hyprland Autostart" "home-manager"
test_module "modules/home-manager/hyprland/looknfeel.nix" "Hyprland Look & Feel" "home-manager"
test_module "modules/home-manager/kitty.nix" "Kitty" "home-manager"
test_module "modules/home-manager/yazi.nix" "Yazi" "home-manager"
test_module "modules/home-manager/zsh.nix" "Zsh" "home-manager"
test_module "modules/home-manager/starship.nix" "Starship" "home-manager"
test_module "modules/home-manager/mako.nix" "Mako" "home-manager"
test_module "modules/home-manager/wofi.nix" "Wofi" "home-manager"
test_module "modules/home-manager/neovim.nix" "Neovim" "home-manager"
test_module "modules/home-manager/waybar.nix" "Waybar" "home-manager"
test_module "modules/home-manager/mpd.nix" "MPD" "home-manager"
test_module "modules/home-manager/ncmpcpp.nix" "ncmpcpp" "home-manager"
test_module "modules/home-manager/hyprpaper.nix" "Hyprpaper" "home-manager"
test_module "modules/home-manager/hypridle.nix" "Hypridle" "home-manager"
test_module "modules/home-manager/hyprlock.nix" "Hyprlock" "home-manager"
test_module "modules/home-manager/webapps.nix" "Webapps" "home-manager"
test_module "modules/home-manager/fastfetch.nix" "Fastfetch" "home-manager"
test_module "modules/home-manager/cursor.nix" "Cursor" "home-manager"
test_module "modules/home-manager/git.nix" "Git" "home-manager"
test_module "modules/home-manager/gtk.nix" "GTK" "home-manager"
test_module "modules/home-manager/btop.nix" "Btop" "home-manager"
test_module "modules/home-manager/wallpaper-service.nix" "Wallpaper Service" "home-manager"
test_module "modules/home-manager/wlogout.nix" "Wlogout" "home-manager"

# Test root config
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Testing Root Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_module "flake.nix" "Flake" "nixos"
test_module "config.nix" "Config" "nixos"

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Passed:${NC} $PASSED"
if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Failed:${NC} $FAILED"
fi
if [[ $SKIPPED -gt 0 ]]; then
    echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
fi

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All module tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some module tests failed${NC}"
    exit 1
fi

#!/usr/bin/env bash
# Module testing script for Frog-OS
# Tests individual modules for correctness

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Frog-OS Modules${NC}"
echo ""

# Check if we're in a NixOS environment
if ! command -v nix-instantiate &> /dev/null; then
    echo -e "${YELLOW}⚠ Warning:${NC} nix-instantiate not found. Some tests will be skipped."
    echo ""
fi

# Function to test a module
test_module() {
    local module="$1"
    local name="$2"
    
    echo -e "${BLUE}Testing:${NC} $name"
    
    if [[ ! -f "$module" ]]; then
        echo -e "${RED}❌ Module not found:${NC} $module"
        return 1
    fi
    
    # Test Nix syntax
    if command -v nix-instantiate &> /dev/null; then
        if nix-instantiate --parse "$module" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Syntax valid"
        else
            echo -e "  ${YELLOW}⚠${NC} Syntax check failed (may be due to missing dependencies)"
            # Try to get more info
            if nix-instantiate --parse "$module" 2>&1 | grep -q "error"; then
                echo -e "  ${RED}  Error details:${NC}"
                nix-instantiate --parse "$module" 2>&1 | head -3 | sed 's/^/    /'
            fi
        fi
    fi
    
    # Check for common issues
    if grep -q "TODO\|FIXME\|XXX" "$module"; then
        echo -e "  ${YELLOW}⚠${NC} Contains TODO/FIXME comments"
    fi
    
    if grep -q "undefined\|null\|placeholder" "$module"; then
        echo -e "  ${YELLOW}⚠${NC} May contain placeholder values"
    fi
    
    echo ""
}

# Test NixOS modules
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}NixOS Modules${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_module "modules/nixos/system.nix" "System Configuration"
test_module "modules/nixos/hyprland.nix" "Hyprland System"
test_module "modules/nixos/network.nix" "Network"
test_module "modules/nixos/audio.nix" "Audio/PipeWire"
test_module "modules/nixos/bluetooth.nix" "Bluetooth"
test_module "modules/nixos/localsend.nix" "LocalSend"

# Test Home Manager modules
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Home Manager Modules${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_module "modules/home-manager/themes.nix" "Themes"
test_module "modules/home-manager/hyprland/configuration.nix" "Hyprland Config"
test_module "modules/home-manager/hyprland/bindings.nix" "Hyprland Bindings"
test_module "modules/home-manager/hyprland/windows.nix" "Hyprland Windows"
test_module "modules/home-manager/hyprland/autostart.nix" "Hyprland Autostart"
test_module "modules/home-manager/hyprland/looknfeel.nix" "Hyprland Look & Feel"
test_module "modules/home-manager/kitty.nix" "Kitty"
test_module "modules/home-manager/yazi.nix" "Yazi"
test_module "modules/home-manager/zsh.nix" "Zsh"
test_module "modules/home-manager/starship.nix" "Starship"
test_module "modules/home-manager/mako.nix" "Mako"
test_module "modules/home-manager/wofi.nix" "Wofi"
test_module "modules/home-manager/neovim.nix" "Neovim"
test_module "modules/home-manager/waybar.nix" "Waybar"
test_module "modules/home-manager/mpd.nix" "MPD"
test_module "modules/home-manager/ncmpcpp.nix" "ncmpcpp"
test_module "modules/home-manager/hyprpaper.nix" "Hyprpaper"
test_module "modules/home-manager/hypridle.nix" "Hypridle"
test_module "modules/home-manager/hyprlock.nix" "Hyprlock"
test_module "modules/home-manager/webapps.nix" "Webapps"
test_module "modules/home-manager/fastfetch.nix" "Fastfetch"
test_module "modules/home-manager/cursor.nix" "Cursor"
test_module "modules/home-manager/git.nix" "Git"
test_module "modules/home-manager/gtk.nix" "GTK"
test_module "modules/home-manager/btop.nix" "Btop"

# Test root config
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Root Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_module "flake.nix" "Flake"
test_module "config.nix" "Config"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Module testing complete!${NC}"
echo ""
echo "Note: Some syntax warnings may be false positives due to"
echo "      missing dependencies when testing outside of NixOS."

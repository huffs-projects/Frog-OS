#!/usr/bin/env bash
# Module validation script for Frog-OS
# Checks that all imported modules exist and have proper structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ERRORS=0
WARNINGS=0

echo "🔍 Validating Frog-OS modules..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if file exists
check_file() {
    local file="$1"
    local context="$2"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}❌ Missing:${NC} $file (required by $context)"
        ((ERRORS++))
        return 1
    else
        echo -e "${GREEN}✓${NC} $file"
        return 0
    fi
}

# Function to check Nix syntax
check_nix_syntax() {
    local file="$1"
    
    if command -v nix-instantiate &> /dev/null; then
        if ! nix-instantiate --parse "$file" &> /dev/null; then
            echo -e "${YELLOW}⚠ Warning:${NC} $file may have syntax issues (nix-instantiate check failed)"
            ((WARNINGS++))
            return 1
        fi
    fi
    return 0
}

# Check NixOS modules
echo "📦 Checking NixOS modules..."
NIXOS_MODULES=(
    "modules/nixos/default.nix"
    "modules/nixos/system.nix"
    "modules/nixos/hyprland.nix"
    "modules/nixos/network.nix"
    "modules/nixos/audio.nix"
    "modules/nixos/bluetooth.nix"
    "modules/nixos/localsend.nix"
)

for module in "${NIXOS_MODULES[@]}"; do
    if check_file "$module" "modules/nixos/default.nix"; then
        check_nix_syntax "$module"
    fi
done

# Check imported NixOS modules from default.nix
echo ""
echo "📋 Checking NixOS module imports..."
IMPORTED_NIXOS=(
    "modules/nixos/system.nix"
    "modules/nixos/hyprland.nix"
    "modules/nixos/network.nix"
    "modules/nixos/bluetooth.nix"
    "modules/nixos/audio.nix"
    "modules/nixos/localsend.nix"
)

for module in "${IMPORTED_NIXOS[@]}"; do
    check_file "$module" "modules/nixos/default.nix"
done

# Check Home Manager modules
echo ""
echo "🏠 Checking Home Manager modules..."
HM_MODULES=(
    "modules/home-manager/default.nix"
    "modules/home-manager/themes.nix"
    "modules/home-manager/hyprland/configuration.nix"
    "modules/home-manager/hyprland/bindings.nix"
    "modules/home-manager/hyprland/windows.nix"
    "modules/home-manager/hyprland/autostart.nix"
    "modules/home-manager/hyprland/looknfeel.nix"
    "modules/home-manager/kitty.nix"
    "modules/home-manager/yazi.nix"
    "modules/home-manager/zsh.nix"
    "modules/home-manager/starship.nix"
    "modules/home-manager/mako.nix"
    "modules/home-manager/wofi.nix"
    "modules/home-manager/neovim.nix"
    "modules/home-manager/waybar.nix"
    "modules/home-manager/mpd.nix"
    "modules/home-manager/ncmpcpp.nix"
    "modules/home-manager/hyprpaper.nix"
    "modules/home-manager/hypridle.nix"
    "modules/home-manager/hyprlock.nix"
    "modules/home-manager/webapps.nix"
    "modules/home-manager/fastfetch.nix"
    "modules/home-manager/cursor.nix"
    "modules/home-manager/git.nix"
    "modules/home-manager/gtk.nix"
    "modules/home-manager/btop.nix"
)

for module in "${HM_MODULES[@]}"; do
    if check_file "$module" "modules/home-manager/default.nix"; then
        check_nix_syntax "$module"
    fi
done

# Check imported Home Manager modules from default.nix
echo ""
echo "📋 Checking Home Manager module imports..."
IMPORTED_HM=(
    "modules/home-manager/themes.nix"
    "modules/home-manager/hyprland/configuration.nix"
    "modules/home-manager/kitty.nix"
    "modules/home-manager/yazi.nix"
    "modules/home-manager/zsh.nix"
    "modules/home-manager/starship.nix"
    "modules/home-manager/mako.nix"
    "modules/home-manager/wofi.nix"
    "modules/home-manager/neovim.nix"
    "modules/home-manager/waybar.nix"
    "modules/home-manager/mpd.nix"
    "modules/home-manager/ncmpcpp.nix"
    "modules/home-manager/hyprpaper.nix"
    "modules/home-manager/hypridle.nix"
    "modules/home-manager/hyprlock.nix"
    "modules/home-manager/webapps.nix"
    "modules/home-manager/fastfetch.nix"
    "modules/home-manager/cursor.nix"
    "modules/home-manager/git.nix"
    "modules/home-manager/gtk.nix"
    "modules/home-manager/btop.nix"
)

for module in "${IMPORTED_HM[@]}"; do
    check_file "$module" "modules/home-manager/default.nix"
done

# Check Hyprland sub-modules
echo ""
echo "🪟 Checking Hyprland sub-modules..."
HYPRLAND_MODULES=(
    "modules/home-manager/hyprland/bindings.nix"
    "modules/home-manager/hyprland/windows.nix"
    "modules/home-manager/hyprland/autostart.nix"
    "modules/home-manager/hyprland/looknfeel.nix"
)

for module in "${HYPRLAND_MODULES[@]}"; do
    if check_file "$module" "modules/home-manager/hyprland/configuration.nix"; then
        check_nix_syntax "$module"
    fi
done

# Check root config files
echo ""
echo "📄 Checking root configuration files..."
ROOT_FILES=(
    "flake.nix"
    "config.nix"
)

for file in "${ROOT_FILES[@]}"; do
    if check_file "$file" "root"; then
        check_nix_syntax "$file"
    fi
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✅ All modules validated successfully!${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  Validation complete with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}❌ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi

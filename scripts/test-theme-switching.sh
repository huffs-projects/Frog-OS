#!/usr/bin/env bash
# Theme switching test script for Frog-OS
# Tests that theme switching works correctly

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

THEMES_FILE="themes/themes.toml"
SWITCH_SCRIPT="scripts/switch-theme.sh"

echo -e "${BLUE}🎨 Testing Theme Switching${NC}"
echo ""

# Check if files exist
if [[ ! -f "$THEMES_FILE" ]]; then
    echo -e "${RED}❌ Error:${NC} $THEMES_FILE not found"
    exit 1
fi

if [[ ! -f "$SWITCH_SCRIPT" ]]; then
    echo -e "${RED}❌ Error:${NC} $SWITCH_SCRIPT not found"
    exit 1
fi

# Extract available themes
echo -e "${BLUE}Extracting available themes...${NC}"

# Get theme names from themes.toml
THEMES=$(grep -oP '^\[themes\.\K[^]]+' "$THEMES_FILE")

if [[ -z "$THEMES" ]]; then
    echo -e "${RED}❌ No themes found in $THEMES_FILE${NC}"
    exit 1
fi

THEME_COUNT=$(echo "$THEMES" | wc -l)
echo -e "  Found ${GREEN}$THEME_COUNT${NC} themes"

# Test switch-theme.sh script
echo ""
echo -e "${BLUE}Testing switch-theme.sh script...${NC}"

# Test --list option
if bash "$SWITCH_SCRIPT" --list &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} --list option works"
else
    echo -e "  ${RED}❌ --list option failed${NC}"
    exit 1
fi

# Check that script is executable
if [[ -x "$SWITCH_SCRIPT" ]]; then
    echo -e "  ${GREEN}✓${NC} Script is executable"
else
    echo -e "  ${YELLOW}⚠${NC} Script is not executable (run: chmod +x $SWITCH_SCRIPT)"
fi

# Validate theme structure
echo ""
echo -e "${BLUE}Validating theme structure...${NC}"

REQUIRED_FIELDS=("bg" "fg" "accent" "red" "green" "yellow" "blue" "magenta" "cyan")
MISSING_FIELDS=0

while IFS= read -r theme; do
    if [[ -z "$theme" ]]; then
        continue
    fi
    
    # Check if theme has required fields in its TOML block
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! awk "/^\\[themes\\.${theme}\\]/{in_section=1;next}/^\\[/{in_section=0}in_section" "$THEMES_FILE" | grep -q "^[[:space:]]*${field}[[:space:]]*="; then
            echo -e "  ${YELLOW}⚠ Theme '$theme' missing field:${NC} $field"
            MISSING_FIELDS=$((MISSING_FIELDS + 1))
        fi
    done
done <<< "$THEMES"

if [[ $MISSING_FIELDS -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} All themes have required fields"
fi

# Test default theme
echo ""
echo -e "${BLUE}Checking default theme...${NC}"

DEFAULT_THEME=$(grep -oP '^\s*default_theme\s*=\s*"\K[^"]+' "$THEMES_FILE" | head -1)

if [[ -n "$DEFAULT_THEME" ]]; then
    echo -e "  ${GREEN}✓${NC} Default theme: $DEFAULT_THEME"
    
    # Verify default theme exists
    if echo "$THEMES" | grep -q "^${DEFAULT_THEME}$"; then
        echo -e "  ${GREEN}✓${NC} Default theme exists in themes list"
    else
        echo -e "  ${RED}❌ Default theme '$DEFAULT_THEME' not found in themes${NC}"
        exit 1
    fi
else
    echo -e "  ${YELLOW}⚠${NC} No default theme found"
fi

# Check theme integration
echo ""
echo -e "${BLUE}Checking theme integration...${NC}"

INTEGRATED_MODULES=(
    "modules/home-manager/kitty.nix"
    "modules/home-manager/mako.nix"
    "modules/home-manager/wofi.nix"
    "modules/home-manager/waybar.nix"
    "modules/home-manager/hyprland/configuration.nix"
)

INTEGRATED_COUNT=0
for module in "${INTEGRATED_MODULES[@]}"; do
    if [[ -f "$module" ]] && grep -q "theme\." "$module"; then
        INTEGRATED_COUNT=$((INTEGRATED_COUNT + 1))
    fi
done

echo -e "  ${GREEN}✓${NC} $INTEGRATED_COUNT modules use theme variables"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Theme switching test complete!${NC}"
echo ""
echo "To switch themes, run:"
echo "  ./scripts/switch-theme.sh <theme-name>"
echo ""
echo "Available themes:"
echo "$THEMES" | sed 's/^/  - /' | head -10

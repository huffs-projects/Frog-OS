#!/usr/bin/env bash
# Keybinding validation script for Frog-OS
# Verifies that all keybindings are properly configured

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

ERRORS=0
WARNINGS=0

echo -e "${BLUE}⌨️  Validating Keybindings${NC}"
echo ""

BINDINGS_FILE="modules/home-manager/hyprland/bindings.nix"

if [[ ! -f "$BINDINGS_FILE" ]]; then
    echo -e "${RED}❌ Error:${NC} $BINDINGS_FILE not found"
    exit 1
fi

# Extract all keybindings
echo -e "${BLUE}Extracting keybindings from $BINDINGS_FILE...${NC}"

# Count bind statements
BIND_COUNT=$(grep -c "bind\s*=" "$BINDINGS_FILE" || echo "0")
echo -e "  Found ${GREEN}$BIND_COUNT${NC} keybinding definitions"

# Check for common issues
echo ""
echo -e "${BLUE}Checking for common issues...${NC}"

# Check for duplicate keybindings
echo "  Checking for duplicate keybindings..."
# Extract bind lines and check for duplicates
DUPLICATES=$(grep -E 'bind\s*=' "$BINDINGS_FILE" | sed -E 's/.*bind\s*=\s*"([^"]+)".*/\1/' | sort | uniq -d)
if [[ -n "$DUPLICATES" ]]; then
    echo -e "  ${RED}❌ Found duplicate keybindings:${NC}"
    echo "$DUPLICATES" | sed 's/^/    /'
    ERRORS=$((ERRORS + 1))
else
    echo -e "  ${GREEN}✓${NC} No duplicate keybindings found"
fi

# Check for missing commands
echo "  Checking for empty or missing commands..."
EMPTY_COMMANDS=$(grep -E 'bind\s*=\s*"[^"]+,\s*"' "$BINDINGS_FILE" | grep -E ',\s*"[[:space:]]*"' || true)
if [[ -n "$EMPTY_COMMANDS" ]]; then
    echo -e "  ${YELLOW}⚠ Found potentially empty commands:${NC}"
    echo "$EMPTY_COMMANDS" | head -5 | sed 's/^/    /'
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓${NC} All keybindings have commands"
fi

# Check for invalid key combinations (simplified check)
echo "  Checking for invalid key combinations..."
# This is a basic check - full validation would require more context
INVALID_LINES=$(grep -E 'bind\s*=\s*"[^"]+,\s*"' "$BINDINGS_FILE" | grep -vE ',\s*"[^"]+",' || true)
if [[ -n "$INVALID_LINES" ]]; then
    INVALID_COUNT=$(echo "$INVALID_LINES" | wc -l | tr -d '[:space:]')
    if [[ "${INVALID_COUNT}" -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠ Found $INVALID_COUNT potentially malformed keybindings${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${GREEN}✓${NC} Keybinding format looks valid"
    fi
else
    echo -e "  ${GREEN}✓${NC} Keybinding format looks valid"
fi

# Check for script references
echo "  Checking script references..."
SCRIPT_REFS=$(grep -E 'bind\s*=\s*"[^"]+,\s*"[^"]*\.sh' "$BINDINGS_FILE" || true)
if [[ -n "$SCRIPT_REFS" ]]; then
    SCRIPT_COUNT=$(echo "$SCRIPT_REFS" | wc -l)
    echo -e "  ${GREEN}✓${NC} Found $SCRIPT_COUNT script references"
    
    # Verify scripts exist
    while IFS= read -r ref; do
        if echo "$ref" | grep -q "\.sh"; then
            # Extract script path (simple extraction)
            SCRIPT_PATH=$(echo "$ref" | sed -E 's/.*,\s*"([^"]*\.sh).*/\1/' | head -1)
            if [[ "$SCRIPT_PATH" =~ ^/ ]] || [[ "$SCRIPT_PATH" =~ \$\{ ]]; then
                # Absolute path or variable - skip check
                continue
            elif [[ ! -f "$SCRIPT_PATH" ]] && [[ ! -f "$REPO_DIR/$SCRIPT_PATH" ]]; then
                echo -e "  ${YELLOW}⚠ Script not found:${NC} $SCRIPT_PATH"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    done <<< "$SCRIPT_REFS"
fi

# Check for essential keybindings
echo ""
echo -e "${BLUE}Checking for essential keybindings...${NC}"

# Check for common essential bindings (using patterns that match $mod variable)
ESSENTIAL_CHECKS=(
    "Q.*killactive|killactive.*Q"  # Close window
    "Return.*kitty|kitty.*Return"  # Terminal
    "M.*exit|exit.*M"  # Exit
    "D.*wofi|wofi.*D"  # Launcher
    "F.*fullscreen|fullscreen.*F"  # Fullscreen
)

FOUND_ESSENTIAL=0
for pattern in "${ESSENTIAL_CHECKS[@]}"; do
    if grep -qE "$pattern" "$BINDINGS_FILE"; then
        FOUND_ESSENTIAL=$((FOUND_ESSENTIAL + 1))
    fi
done

if [[ $FOUND_ESSENTIAL -ge 3 ]]; then
    echo -e "  ${GREEN}✓${NC} Found $FOUND_ESSENTIAL essential keybindings"
else
    echo -e "  ${YELLOW}⚠ Only found $FOUND_ESSENTIAL essential keybindings (expected 3+)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✅ Keybinding validation passed!${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  Validation complete with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}❌ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi

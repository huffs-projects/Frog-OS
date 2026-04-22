#!/usr/bin/env bash
# Configuration validation script for Frog-OS
# Tests the complete NixOS configuration build

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

echo -e "${BLUE} Validating Frog-OS Configuration${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    if ! command -v nix &> /dev/null; then
        echo -e "${RED}❌ Error:${NC} nix command not found"
        echo "   Please install Nix first: https://nixos.org/download.html"
        exit 1
    fi
    
    if ! command -v nixos-rebuild &> /dev/null && [[ ! -f /etc/nixos/configuration.nix ]]; then
        echo -e "${YELLOW}⚠ Warning:${NC} nixos-rebuild not found (not on NixOS system)"
        echo "   Some tests will be skipped"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if [[ ! -f "flake.nix" ]]; then
        echo -e "${RED}❌ Error:${NC} flake.nix not found"
        exit 1
    fi
    
    if [[ ! -f "config.nix" ]]; then
        echo -e "${RED}❌ Error:${NC} config.nix not found"
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} Prerequisites check passed"
    echo ""
}

# Validate flake structure
validate_flake() {
    echo -e "${BLUE}Validating flake structure...${NC}"
    
    if nix flake check "$REPO_DIR" 2>&1 | tee /tmp/flake-check.log; then
        echo -e "${GREEN}✓${NC} Flake structure is valid"
    else
        echo -e "${RED}❌ Flake structure validation failed${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    
    echo ""
}

# Validate imports
validate_imports() {
    echo -e "${BLUE}Validating module imports...${NC}"
    
    # Check NixOS module imports
    if ! grep -q "modules/nixos/default.nix" config.nix; then
        echo -e "${RED}❌ Missing import:${NC} modules/nixos/default.nix in config.nix"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} config.nix imports modules/nixos/default.nix"
    fi
    
    # Check that all imported modules exist
    while IFS= read -r import_line; do
        if [[ "$import_line" =~ \.\/([^\"\']+) ]]; then
            module_path="${BASH_REMATCH[1]}"
            if [[ ! -f "$module_path" ]]; then
                echo -e "${RED}❌ Missing module:${NC} $module_path"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done < <(grep -E "^[[:space:]]*imports[[:space:]]*=" modules/nixos/default.nix -A 10 | grep -E "\.\/")
    
    echo ""
}

# Test configuration build
test_build() {
    echo -e "${BLUE}Testing configuration build...${NC}"
    
    if command -v nixos-rebuild &> /dev/null; then
        echo "  Running: nixos-rebuild build --flake .#frogos"
        if sudo nixos-rebuild build --flake "$REPO_DIR#frogos" 2>&1 | tee /tmp/build.log; then
            echo -e "${GREEN}✓${NC} Configuration builds successfully"
        else
            echo -e "${RED}❌ Configuration build failed${NC}"
            echo "  Check /tmp/build.log for details"
            ERRORS=$((ERRORS + 1))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Skipping build test (not on NixOS system)${NC}"
        echo "  To test manually: sudo nixos-rebuild build --flake .#frogos"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    echo ""
}

# Test flake evaluation
test_flake_eval() {
    echo -e "${BLUE}Testing flake evaluation...${NC}"
    
    if nix eval --raw "$REPO_DIR#nixosConfigurations.frogos.config.system.name" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Flake evaluates successfully"
    else
        echo -e "${YELLOW}⚠ Warning:${NC} Could not evaluate flake (may require full build context)"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    echo ""
}

# Check for common issues
check_common_issues() {
    echo -e "${BLUE}Checking for common issues...${NC}"
    
    # Check for TODO/FIXME in critical files
    if grep -r "TODO\|FIXME" flake.nix config.nix modules/nixos/default.nix 2>/dev/null | grep -v "^Binary"; then
        echo -e "${YELLOW}⚠ Found TODO/FIXME comments in critical files${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check for hardcoded paths
    if grep -r "/home/[^/]*/Frog-OS" modules/ 2>/dev/null | grep -v "homeDirectory"; then
        echo -e "${YELLOW}⚠ Found hardcoded paths (should use config.home.homeDirectory)${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check flake.lock exists
    if [[ ! -f "flake.lock" ]]; then
        echo -e "${YELLOW}⚠ Warning:${NC} flake.lock not found. Run 'nix flake update' to generate it."
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓${NC} flake.lock exists"
    fi
    
    echo ""
}

# Main execution
main() {
    check_prerequisites
    validate_flake
    validate_imports
    test_flake_eval
    test_build
    check_common_issues
    
    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN} Configuration validation passed!${NC}"
        exit 0
    elif [[ $ERRORS -eq 0 ]]; then
        echo -e "${YELLOW}  Validation complete with $WARNINGS warning(s)${NC}"
        exit 0
    else
        echo -e "${RED}❌ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
        exit 1
    fi
}

main

#!/usr/bin/env bash
# Flake update script for Frog-OS
# Updates flake inputs and regenerates flake.lock

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

echo -e "${BLUE}🔄 Updating Frog-OS Flake${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
  echo -e "${RED}Error:${NC} flake.nix not found. Are you in the Frog-OS directory?"
  exit 1
fi

# Check if nix is available
if ! command -v nix &> /dev/null; then
  echo -e "${RED}Error:${NC} nix command not found"
  exit 1
fi

# Show current flake inputs
echo -e "${BLUE}Current flake inputs:${NC}"
nix flake metadata --json 2>/dev/null | nix eval --expr 'builtins.fromJSON (builtins.readFile "/dev/stdin")' --json 2>/dev/null | \
  jq -r '.locks.nodes.root.inputs | to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || \
  echo "  (Run 'nix flake show' to see inputs)"

echo ""

# Ask for confirmation
read -p "Update all flake inputs? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Update cancelled."
  exit 0
fi

# Update flake inputs
echo -e "${BLUE}Updating flake inputs...${NC}"
if nix flake update "$REPO_DIR"; then
  echo -e "${GREEN}✓${NC} Flake inputs updated successfully"
  echo ""
  echo -e "${BLUE}Updated inputs:${NC}"
  nix flake metadata --json 2>/dev/null | nix eval --expr 'builtins.fromJSON (builtins.readFile "/dev/stdin")' --json 2>/dev/null | \
    jq -r '.locks.nodes.root.inputs | to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || \
    echo "  (Run 'nix flake show' to see updated inputs)"
else
  echo -e "${RED}✗${NC} Failed to update flake inputs"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Flake update complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff flake.lock"
echo "  2. Test build: sudo nixos-rebuild build --flake .#frogos"
echo "  3. If successful, switch: sudo nixos-rebuild switch --flake .#frogos"

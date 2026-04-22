#!/usr/bin/env bash
# Script to add untracked Nix module files to Git
# This is required for nix flake check to work properly

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

echo -e "${BLUE}Adding untracked Nix module files to Git...${NC}"
echo ""

# List of untracked NixOS modules that need to be added
NIXOS_MODULES=(
  "modules/nixos/audio.nix"
  "modules/nixos/bluetooth.nix"
  "modules/nixos/localsend.nix"
  "modules/nixos/network.nix"
  "modules/nixos/performance.nix"
  "modules/nixos/security.nix"
)

# List of untracked Home Manager modules that need to be added
HM_MODULES=(
  "modules/home-manager/cursor.nix"
  "modules/home-manager/fastfetch.nix"
  "modules/home-manager/gtk.nix"
  "modules/home-manager/kitty.nix"
  "modules/home-manager/mpd.nix"
  "modules/home-manager/ncmpcpp.nix"
  "modules/home-manager/neovim.nix"
  "modules/home-manager/themes.nix"
  "modules/home-manager/wallpaper-service.nix"
  "modules/home-manager/webapps.nix"
  "modules/home-manager/wlogout.nix"
  "modules/home-manager/yazi.nix"
)

ADDED=0
MISSING=0

# Add NixOS modules
echo -e "${BLUE}Checking NixOS modules...${NC}"
for module in "${NIXOS_MODULES[@]}"; do
  if [[ -f "$module" ]]; then
    if ! git ls-files --error-unmatch "$module" &>/dev/null; then
      echo -e "${GREEN}Adding:${NC} $module"
      git add "$module"
      ADDED=$((ADDED + 1))
    else
      echo -e "${YELLOW}Already tracked:${NC} $module"
    fi
  else
    echo -e "${RED}Missing:${NC} $module"
    MISSING=$((MISSING + 1))
  fi
done

echo ""

# Add Home Manager modules
echo -e "${BLUE}Checking Home Manager modules...${NC}"
for module in "${HM_MODULES[@]}"; do
  if [[ -f "$module" ]]; then
    if ! git ls-files --error-unmatch "$module" &>/dev/null; then
      echo -e "${GREEN}Adding:${NC} $module"
      git add "$module"
      ADDED=$((ADDED + 1))
    else
      echo -e "${YELLOW}Already tracked:${NC} $module"
    fi
  else
    echo -e "${RED}Missing:${NC} $module"
    MISSING=$((MISSING + 1))
  fi
done

echo ""
echo -e "${BLUE}Summary:${NC}"
echo -e "  Added to Git: ${GREEN}${ADDED}${NC} files"
if [[ $MISSING -gt 0 ]]; then
  echo -e "  Missing files: ${RED}${MISSING}${NC}"
fi

if [[ $ADDED -gt 0 ]]; then
  echo ""
  echo -e "${GREEN}✓ Files added successfully${NC}"
  echo -e "${YELLOW}Note:${NC} You may want to commit these changes:"
  echo "  git commit -m 'Add untracked Nix module files for flake compatibility'"
else
  echo ""
  echo -e "${YELLOW}No new files to add${NC}"
fi

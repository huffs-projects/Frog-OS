#!/usr/bin/env bash
# Theme switcher for Frog-OS (edits themes/themes.toml metadata.default_theme)
# Usage: ./switch-theme.sh <theme-name>
# Example: ./switch-theme.sh nord

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
THEMES_FILE="${REPO_ROOT}/themes/themes.toml"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

load_available_themes() {
  if [ ! -f "$THEMES_FILE" ]; then
    echo -e "${RED}Error:${NC} Themes file not found: $THEMES_FILE"
    exit 1
  fi
  AVAILABLE_THEMES=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^\[themes\.([^]]+)\] ]]; then
      AVAILABLE_THEMES+=("${BASH_REMATCH[1]}")
    fi
  done < "$THEMES_FILE"
}

# Function to list available themes
list_themes() {
  load_available_themes
  echo "Available themes:"
  for theme in "${AVAILABLE_THEMES[@]}"; do
    echo "  - $theme"
  done
}

# Function to validate theme name
validate_theme() {
  local theme="$1"
  load_available_themes
  for available in "${AVAILABLE_THEMES[@]}"; do
    if [ "$theme" = "$available" ]; then
      return 0
    fi
  done
  return 1
}

# Function to switch theme
switch_theme() {
  local new_theme="$1"

  if [ ! -f "$THEMES_FILE" ]; then
    echo -e "${RED}Error:${NC} Themes file not found: $THEMES_FILE"
    exit 1
  fi

  if ! validate_theme "$new_theme"; then
    echo -e "${RED}Error:${NC} Invalid theme name: $new_theme"
    echo ""
    list_themes
    exit 1
  fi

  local current_theme
  current_theme=$(
    grep -E '^\s*default_theme\s*=' "$THEMES_FILE" | head -1 | sed -E 's/.*"([^"]+)".*/\1/'
  )

  if [ "$current_theme" = "$new_theme" ]; then
    echo -e "${YELLOW}Theme is already set to:${NC} $new_theme"
    exit 0
  fi

  echo -e "${GREEN}Switching theme from${NC} $current_theme ${GREEN}to${NC} $new_theme"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' -E 's/^default_theme = ".*"/default_theme = "'"$new_theme"'"/' "$THEMES_FILE"
  else
    sed -i -E 's/^default_theme = ".*"/default_theme = "'"$new_theme"'"/' "$THEMES_FILE"
  fi

  echo -e "${GREEN}OK${NC} Theme updated in $THEMES_FILE"
  echo ""
  echo "To apply the new theme, rebuild your NixOS configuration:"
  echo "  sudo nixos-rebuild switch --flake ~/Frog-OS#frogos"
  echo ""
  echo "Or for Home Manager only:"
  echo "  home-manager switch --flake ~/Frog-OS#frogos"
}

# Main script logic
if [ $# -eq 0 ]; then
  echo "Theme Switcher for Frog-OS"
  echo ""
  echo "Usage: $0 <theme-name>"
  echo "   or: $0 --list"
  echo ""
  list_themes
  exit 0
fi

if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
  list_themes
  exit 0
fi

switch_theme "$1"

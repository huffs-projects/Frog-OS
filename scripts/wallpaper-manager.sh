#!/usr/bin/env bash
# Wallpaper management script for hyprpaper
# Usage: ./wallpaper-manager.sh <command> [options]

set -euo pipefail

WALLPAPER_DIR="${HOME}/.local/share/wallpapers"
HYPRPAPER_SOCKET="${XDG_RUNTIME_DIR}/hyprpaper.sock"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if hyprpaper is running
check_hyprpaper() {
  if ! pgrep -x hyprpaper > /dev/null; then
    echo -e "${RED}Error:${NC} hyprpaper is not running"
    echo "Start it with: hyprpaper &"
    exit 1
  fi
}

collect_wallpapers() {
  local -n _result="$1"
  _result=()

  shopt -s nullglob
  local files=(
    "$WALLPAPER_DIR"/*.jpg
    "$WALLPAPER_DIR"/*.jpeg
    "$WALLPAPER_DIR"/*.png
    "$WALLPAPER_DIR"/*.JPG
    "$WALLPAPER_DIR"/*.JPEG
    "$WALLPAPER_DIR"/*.PNG
  )
  shopt -u nullglob

  local wallpaper
  for wallpaper in "${files[@]}"; do
    [ -f "$wallpaper" ] && _result+=("$wallpaper")
  done
}

# Function to list available wallpapers
list_wallpapers() {
  if [ ! -d "$WALLPAPER_DIR" ]; then
    echo -e "${RED}Error:${NC} Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
  fi
  
  echo -e "${BLUE}Available wallpapers:${NC}"
  local count=1
  local wallpapers=()
  collect_wallpapers wallpapers
  local wallpaper
  for wallpaper in "${wallpapers[@]}"; do
    local name
    name=$(basename "$wallpaper")
    echo "  $count. $name"
    ((count++))
  done
}

# Function to set wallpaper
set_wallpaper() {
  local wallpaper="$1"
  local monitor="${2:-}"
  
  if [ ! -f "$wallpaper" ]; then
    # Try to find it in wallpaper directory
    if [ -f "$WALLPAPER_DIR/$wallpaper" ]; then
      wallpaper="$WALLPAPER_DIR/$wallpaper"
    else
      echo -e "${RED}Error:${NC} Wallpaper not found: $wallpaper"
      exit 1
    fi
  fi
  
  check_hyprpaper
  
  # Convert to absolute path
  wallpaper=$(realpath "$wallpaper")
  
  if [ -n "$monitor" ]; then
    # Set for specific monitor
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
    echo -e "${GREEN}✓${NC} Set wallpaper for $monitor: $(basename "$wallpaper")"
  else
    # Set for all monitors
    hyprctl hyprpaper wallpaper ",$wallpaper"
    echo -e "${GREEN}✓${NC} Set wallpaper: $(basename "$wallpaper")"
  fi
}

# Function to get current wallpaper
get_current() {
  check_hyprpaper
  hyprctl hyprpaper listpreload | grep -E "^preload" | head -1 | awk '{print $2}' || echo "No wallpaper set"
}

# Function to set random wallpaper
set_random() {
  local wallpapers=()
  
  if [ ! -d "$WALLPAPER_DIR" ]; then
    echo -e "${RED}Error:${NC} Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
  fi
  
  # Collect all wallpapers
  collect_wallpapers wallpapers
  
  if [ ${#wallpapers[@]} -eq 0 ]; then
    echo -e "${RED}Error:${NC} No wallpapers found in $WALLPAPER_DIR"
    exit 1
  fi
  
  # Select random wallpaper
  local random_index=$((RANDOM % ${#wallpapers[@]}))
  local random_wallpaper="${wallpapers[$random_index]}"
  
  set_wallpaper "$random_wallpaper"
}

# Function to preload wallpapers
preload_wallpapers() {
  local max_count="${1:-6}"

  if ! [[ "$max_count" =~ ^[0-9]+$ ]] || [ "$max_count" -lt 1 ]; then
    echo -e "${RED}Error:${NC} preload count must be a positive integer"
    exit 1
  fi

  if [ ! -d "$WALLPAPER_DIR" ]; then
    echo -e "${RED}Error:${NC} Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
  fi
  
  check_hyprpaper
  
  echo -e "${BLUE}Preloading wallpapers...${NC}"
  local count=0
  local wallpapers=()
  collect_wallpapers wallpapers
  local wallpaper
  for wallpaper in "${wallpapers[@]}"; do
    wallpaper=$(realpath "$wallpaper")
    hyprctl hyprpaper preload "$wallpaper" > /dev/null 2>&1
    ((count++))
    if [ "$count" -ge "$max_count" ]; then
      break
    fi
  done
  echo -e "${GREEN}✓${NC} Preloaded $count wallpaper(s) (limit: $max_count)"
}

# Function to show help
show_help() {
  cat << EOF
Wallpaper Manager for hyprpaper

Usage: $0 <command> [options]

Commands:
  list                    List all available wallpapers
  set <wallpaper>         Set a wallpaper (filename or full path)
                          Optional: [monitor] - set for specific monitor
  random                  Set a random wallpaper
  current                 Show current wallpaper
  preload [count]         Preload up to count wallpapers (default: 6)
  help                    Show this help message

Examples:
  $0 list
  $0 set alena-aenami-away-1k.jpg
  $0 set alena-aenami-budapest.jpg DP-1
  $0 random
  $0 current
  $0 preload
  $0 preload 12

Wallpaper directory: $WALLPAPER_DIR
EOF
}

# Main script logic
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

case "$1" in
  list)
    list_wallpapers
    ;;
  set)
    if [ $# -lt 2 ]; then
      echo -e "${RED}Error:${NC} Please specify a wallpaper"
      echo "Usage: $0 set <wallpaper> [monitor]"
      exit 1
    fi
    set_wallpaper "$2" "${3:-}"
    ;;
  random)
    set_random
    ;;
  current)
    get_current
    ;;
  preload)
    preload_wallpapers "${2:-6}"
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    echo -e "${RED}Error:${NC} Unknown command: $1"
    echo "Run '$0 help' for usage information"
    exit 1
    ;;
esac

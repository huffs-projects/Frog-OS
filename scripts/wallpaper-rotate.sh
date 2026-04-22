#!/usr/bin/env bash
# Wallpaper rotation script for hyprpaper
# Rotates through wallpapers at specified intervals
# Usage: ./wallpaper-rotate.sh [interval] [--daemon]

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-${HOME}/.local/share/wallpapers}"
INTERVAL="${1:-300}"  # Default: 5 minutes (300 seconds)

# Exit codes: 77 = skipped (transient / not actionable) — systemd counts as success when configured
EXIT_SKIP=77
EXIT_ERROR=1

# Set by systemd unit so timers do not spam failures when the session is not ready
SERVICE_MODE="${FROG_WALLPAPER_ROTATE_SERVICE:-}"

# PID file for daemon mode
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-rotate.pid"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-rotate.lock"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

is_service_mode() {
  [ -n "$SERVICE_MODE" ]
}

# Skip (service) vs fail (interactive) for conditions the user cannot fix from this script alone
bail_skip_or_error() {
  local msg=$1
  if is_service_mode; then
    echo "$msg" >&2
    exit "$EXIT_SKIP"
  fi
  echo -e "${RED}Error:${NC} $msg" >&2
  exit "$EXIT_ERROR"
}

# Function to check if hyprpaper is running (strict — interactive)
check_hyprpaper() {
  if ! pgrep -x hyprpaper > /dev/null; then
    echo -e "${RED}Error:${NC} hyprpaper is not running" >&2
    echo "Start it with: hyprpaper &" >&2
    exit "$EXIT_ERROR"
  fi
}

# Wait for hyprpaper after login / timer (service)
wait_for_hyprpaper() {
  local max_seconds=${1:-90}
  local waited=0
  while [ "$waited" -lt "$max_seconds" ]; do
    if pgrep -x hyprpaper > /dev/null; then
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 1
}

ensure_hyprpaper() {
  if pgrep -x hyprpaper > /dev/null; then
    return 0
  fi
  if is_service_mode; then
    if wait_for_hyprpaper 90; then
      return 0
    fi
    bail_skip_or_error "hyprpaper did not start within 90s; skipping rotation"
  fi
  check_hyprpaper
}

# Fills named array with sorted unique absolute paths (runs in caller shell — required for correct exit handling)
fill_wallpaper_array() {
  local -n _wallpapers=$1
  _wallpapers=()

  if [ ! -d "$WALLPAPER_DIR" ]; then
    bail_skip_or_error "Wallpaper directory not found: $WALLPAPER_DIR"
  fi

  shopt -s nullglob
  local files=(
    "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png
    "$WALLPAPER_DIR"/*.JPG "$WALLPAPER_DIR"/*.JPEG "$WALLPAPER_DIR"/*.PNG
    "$WALLPAPER_DIR"/*.webp "$WALLPAPER_DIR"/*.WEBP
  )
  shopt -u nullglob

  if [ "${#files[@]}" -eq 0 ]; then
    bail_skip_or_error "No wallpapers found in $WALLPAPER_DIR"
  fi

  local f
  for f in "${files[@]}"; do
    [ -f "$f" ] || continue
    _wallpapers+=("$(realpath "$f")")
  done

  if [ "${#_wallpapers[@]}" -eq 0 ]; then
    bail_skip_or_error "No wallpapers found in $WALLPAPER_DIR"
  fi

  local sorted
  mapfile -t sorted < <(printf '%s\n' "${_wallpapers[@]}" | LC_ALL=C sort -u)
  _wallpapers=("${sorted[@]}")
}

# Apply next wallpaper: preload (best-effort) then set
apply_wallpaper() {
  local path=$1
  hyprctl hyprpaper preload "$path" > /dev/null 2>&1 || true
  if ! hyprctl hyprpaper wallpaper ",$path" > /dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Function to rotate wallpaper
rotate_wallpaper() {
  local wallpapers=()
  fill_wallpaper_array wallpapers

  local current_index=0

  # Try to find current wallpaper (first preload line is a reasonable anchor)
  local current
  current=$(hyprctl hyprpaper listpreload 2>/dev/null | grep -E "^preload" | head -1 | awk '{print $2}' || echo "")

  if [ -n "$current" ]; then
    local i
    for i in "${!wallpapers[@]}"; do
      if [ "${wallpapers[$i]}" = "$current" ]; then
        current_index=$i
        break
      fi
    done
  fi

  local next_index=$(((current_index + 1) % ${#wallpapers[@]}))
  local next_wallpaper="${wallpapers[$next_index]}"

  if ! apply_wallpaper "$next_wallpaper"; then
    if is_service_mode; then
      echo "hyprctl hyprpaper failed for: $next_wallpaper" >&2
      exit "$EXIT_SKIP"
    fi
    echo -e "${RED}Error:${NC} hyprctl hyprpaper failed for: $next_wallpaper" >&2
    exit "$EXIT_ERROR"
  fi
  echo -e "${GREEN}OK${NC} Rotated to: $(basename "$next_wallpaper")"
}

with_rotation_lock() {
  # Subshell keeps fd 200 scoped so flock is released when rotation finishes (avoids stuck lock across timer/daemon runs)
  if is_service_mode; then
    (
      flock -n 200 || {
        echo "Another rotation in progress; skipping." >&2
        exit "$EXIT_SKIP"
      }
      "$@"
    ) 200>"$LOCK_FILE"
  else
    (
      flock 200
      "$@"
    ) 200>"$LOCK_FILE"
  fi
}

# Function to run as daemon
run_daemon() {
  if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [ "$INTERVAL" -lt 1 ]; then
    echo -e "${RED}Error:${NC} interval must be a positive integer (seconds)" >&2
    exit "$EXIT_ERROR"
  fi

  echo -e "${BLUE}Starting wallpaper rotation daemon (interval: ${INTERVAL}s)${NC}"
  echo "$$" > "$PID_FILE"
  echo "Press Ctrl+C to stop"

  trap 'rm -f "$PID_FILE"; exit' INT TERM

  while true; do
    ensure_hyprpaper
    with_rotation_lock rotate_wallpaper
    sleep "$INTERVAL"
  done
}

# Function to stop daemon
stop_daemon() {
  if [ -f "$PID_FILE" ]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      rm -f "$PID_FILE"
      echo -e "${GREEN}OK${NC} Stopped wallpaper rotation daemon"
    else
      rm -f "$PID_FILE"
      echo -e "${YELLOW}Daemon not running${NC}"
    fi
  else
    echo -e "${YELLOW}Daemon not running${NC}"
  fi
}

# Function to show status
show_status() {
  if [ -f "$PID_FILE" ]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo -e "${GREEN}Daemon is running${NC} (PID: $pid)"
      echo "Interval: ${INTERVAL}s"
    else
      echo -e "${YELLOW}Daemon is not running${NC}"
      rm -f "$PID_FILE"
    fi
  else
    echo -e "${YELLOW}Daemon is not running${NC}"
  fi
}

# Function to show help
show_help() {
  cat << EOF
Wallpaper Rotation Script for hyprpaper

Usage: $0 [interval] [--daemon|--stop|--status]
       $0 [--help]

Options:
  interval                Rotation interval in seconds (default: 300 = 5 minutes)
  --daemon                Run as background daemon
  --stop                  Stop running daemon
  --status                Show daemon status
  --help                  Show this help message

Environment:
  WALLPAPER_DIR           Override wallpaper directory (default: ~/.local/share/wallpapers)
  FROG_WALLPAPER_ROTATE_SERVICE  Set by systemd; uses exit 77 skips and retries for hyprpaper

Examples:
  $0                      Rotate once (default 5 min interval)
  $0 600                  Rotate every 10 minutes
  $0 300 --daemon         Run as daemon, rotate every 5 minutes
  $0 --stop               Stop daemon
  $0 --status             Check daemon status

Wallpaper directory: $WALLPAPER_DIR
EOF
}

run_once() {
  ensure_hyprpaper
  with_rotation_lock rotate_wallpaper
}

# Main script logic
if [ $# -gt 0 ]; then
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    --stop)
      stop_daemon
      exit 0
      ;;
    --status)
      show_status
      exit 0
      ;;
    --daemon)
      ensure_hyprpaper
      run_daemon
      exit 0
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        INTERVAL="$1"
        if [ "${2:-}" = "--daemon" ]; then
          ensure_hyprpaper
          run_daemon
        else
          run_once
        fi
      else
        echo -e "${RED}Error:${NC} Invalid argument: $1" >&2
        show_help
        exit "$EXIT_ERROR"
      fi
      ;;
  esac
else
  run_once
fi

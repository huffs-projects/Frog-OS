#!/usr/bin/env bash
# Package update checker for Frog-OS
# Checks for package updates and shows what's available

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

echo -e "${BLUE}📦 Checking Package Versions${NC}"
echo ""

# Check if nix is available
if ! command -v nix &> /dev/null; then
  echo -e "${RED}Error:${NC} nix command not found"
  exit 1
fi

# Function to get package version
get_package_version() {
  local package="$1"
  nix eval --expr "with import <nixpkgs> {}; ${package}.version" 2>/dev/null || echo "unknown"
}

# Function to check if package exists
package_exists() {
  local package="$1"
  nix eval --expr "with import <nixpkgs> {}; lib.hasAttr \"${package}\" pkgs" 2>/dev/null | grep -q "true" || return 1
}

echo -e "${BLUE}System Packages:${NC}"
echo ""

# List of packages to check
packages=(
  "fastfetch"
  "btop"
  "brightnessctl"
  "playerctl"
  "wl-clipboard"
  "wlogout"
  "pavucontrol"
  "ncpamixer"
  "hyprshot"
  "cliphist"
  "ripgrep"
  "fd"
  "fzf"
  "eza"
  "zoxide"
  "bat"
  "unzip"
  "zip"
  "p7zip"
  "unrar"
  "curl"
  "wget"
  "nmap"
  "tcpdump"
  "nano"
  "zathura"
  "mpv"
  "imv"
  "ffmpeg"
  "yt-dlp"
  "cmatrix"
  "chafa"
  "ueberzugpp"
  "lazygit"
  "gcc"
  "gnumake"
  "rustc"
  "cargo"
  "signal-desktop"
  "localsend"
)

for pkg in "${packages[@]}"; do
  if package_exists "$pkg"; then
    version=$(get_package_version "$pkg")
    echo -e "  ${GREEN}✓${NC} $pkg: $version"
  else
    echo -e "  ${RED}✗${NC} $pkg: not found in nixpkgs"
  fi
done

echo ""
echo -e "${BLUE}Custom Packages:${NC}"
echo "  sky: 0.1.0 (pinned commit: df42059811754fd87ed6615cf7c3d47d60bb87c1)"
echo "  pipes-sh: 1.3.0 (pinned version)"
echo "  tuios: 0.4.3 (from flake input)"
echo "  tuios-web: 0.4.3 (from flake input)"

echo ""
echo -e "${BLUE}Flake Inputs:${NC}"
if [ -f "flake.lock" ]; then
  echo "  Run 'nix flake metadata' to see current input versions"
  echo "  Run './scripts/update-flake.sh' to update inputs"
else
  echo -e "  ${YELLOW}⚠${NC} flake.lock not found. Run 'nix flake update' to generate it."
fi

echo ""
echo -e "${BLUE}Note:${NC}"
echo "  - System packages come from nixpkgs (nixos-unstable channel)"
echo "  - Custom packages (sky, pipes-sh) have pinned versions"
echo "  - Flake inputs can be updated with: ./scripts/update-flake.sh"
echo "  - To update nixpkgs channel: nix flake update nixpkgs"

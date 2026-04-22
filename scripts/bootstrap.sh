#!/usr/bin/env bash
# Frog-OS bootstrap: install Nix (if needed), clone this repo, then apply the flake.
#
# From GitHub (replace OWNER/BRANCH):
#   curl -fsSL https://raw.githubusercontent.com/OWNER/Frog-OS/main/scripts/bootstrap.sh | bash
#
# With a custom clone URL:
#   FROG_OS_REPO=https://github.com/you/Frog-OS.git curl -fsSL ... | bash
#
# Environment:
#   FROG_OS_REPO   - Git clone URL (default: https://github.com/huffmakesthings/Frog-OS.git)
#   FROG_OS_DIR    - Install directory (default: ~/Frog-OS)
#   NIX_INSTALLER  - determinate | official | skip  (default: determinate)
#   SKIP_REBUILD   - if set, do not run nixos-rebuild (clone + flake update only)
#   DRY_RUN        - print actions only

set -euo pipefail

FROG_OS_REPO="${FROG_OS_REPO:-https://github.com/huffmakesthings/Frog-OS.git}"
FROG_OS_DIR="${FROG_OS_DIR:-$HOME/Frog-OS}"
NIX_INSTALLER="${NIX_INSTALLER:-determinate}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[bootstrap]${NC} $*"; }
warn() { echo -e "${YELLOW}[bootstrap]${NC} $*"; }
err() { echo -e "${RED}[bootstrap]${NC} $*" >&2; }

is_nixos() { [ -f /etc/NIXOS ]; }

have_nix() { command -v nix >/dev/null 2>&1; }

nix_profile_sh() {
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
}

install_nix() {
  if have_nix; then
    log "Nix is already installed: $(command -v nix)"
    nix_profile_sh
    return 0
  fi

  if is_nixos; then
    err "NixOS already includes Nix, but 'nix' is not on PATH. Log in again or open a new shell."
    exit 1
  fi

  case "$NIX_INSTALLER" in
    skip)
      warn "NIX_INSTALLER=skip but nix not found; cannot continue."
      exit 1
      ;;
    determinate)
      log "Installing Nix via Determinate installer..."
      if [ -n "${DRY_RUN:-}" ]; then
        echo "Would run: curl ... install.determinate.systems | sh -s -- install --no-confirm"
        return 0
      fi
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
      ;;
    official)
      log "Installing Nix via nixos.org installer..."
      if [ -n "${DRY_RUN:-}" ]; then
        echo "Would run: nixos.org/nix/install"
        return 0
      fi
      # Often interactive; prefer NIX_INSTALLER=determinate for unattended installs.
      curl -L https://nixos.org/nix/install | sh
      ;;
    *)
      err "Unknown NIX_INSTALLER=$NIX_INSTALLER (use determinate, official, or skip)"
      exit 1
      ;;
  esac

  nix_profile_sh
  if ! have_nix; then
    err "Nix install finished but 'nix' is still not on PATH."
    err "Open a new terminal and re-run this script, or run: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    exit 1
  fi
  log "Nix installed: $(command -v nix)"
}

clone_or_update_repo() {
  if [ -n "${DRY_RUN:-}" ]; then
    echo "Would clone/update: $FROG_OS_REPO -> $FROG_OS_DIR"
    return 0
  fi

  if [ -d "$FROG_OS_DIR/.git" ]; then
    log "Updating existing repo: $FROG_OS_DIR"
    git -C "$FROG_OS_DIR" fetch origin || true
    git -C "$FROG_OS_DIR" pull --ff-only || warn "git pull failed; fix conflicts or pull manually."
  else
    if [ -e "$FROG_OS_DIR" ]; then
      err "Path exists but is not a git repo: $FROG_OS_DIR"
      err "Remove it or set FROG_OS_DIR to another directory."
      exit 1
    fi
    log "Cloning $FROG_OS_REPO -> $FROG_OS_DIR"
    git clone "$FROG_OS_REPO" "$FROG_OS_DIR"
  fi
}

apply_flake() {
  if [ -n "${DRY_RUN:-}" ]; then
    echo "Would run flake steps in $FROG_OS_DIR"
    return 0
  fi

  cd "$FROG_OS_DIR"
  if [ ! -f flake.nix ]; then
    err "flake.nix not found in $FROG_OS_DIR"
    exit 1
  fi

  log "Refreshing flake lock..."
  nix flake lock

  if is_nixos; then
    if [ -n "${SKIP_REBUILD:-}" ]; then
      warn "SKIP_REBUILD is set; skipping nixos-rebuild."
      return 0
    fi
    log "Applying NixOS configuration (requires sudo)..."
    sudo nixos-rebuild switch --flake "$FROG_OS_DIR#frogos"
  else
    warn "Not NixOS: skipping nixos-rebuild. You can edit the flake here: $FROG_OS_DIR"
    log "Verifying flake evaluates (best-effort)..."
    nix flake check 2>/dev/null || warn "nix flake check failed or is unsupported on this host (expected for Linux-only outputs)."
  fi
}

main() {
  log "Frog-OS bootstrap"
  log "  FROG_OS_REPO=$FROG_OS_REPO"
  log "  FROG_OS_DIR=$FROG_OS_DIR"
  log "  NIX_INSTALLER=$NIX_INSTALLER"

  install_nix
  clone_or_update_repo
  apply_flake

  echo ""
  echo -e "${GREEN}Done.${NC} Repository: $FROG_OS_DIR"
}

main "$@"

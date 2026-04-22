# Frog-OS

A NixOS configuration with Hyprland window manager, featuring a modular structure and comprehensive theming system.

## Overview

Frog-OS is a personal NixOS configuration that provides a complete desktop environment built on:
- **Hyprland** - Modern Wayland compositor
- **Home Manager** - Declarative user environment management
- **Modular Architecture** - Organized, maintainable configuration structure

## Quick Start

### Prerequisites

- NixOS system with flakes enabled
- Root access for system configuration

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/huffmakesthings/Frog-OS.git ~/Frog-OS
   cd ~/Frog-OS
   ```

2. Build and switch to the configuration:
   ```bash
   sudo nixos-rebuild switch --flake ~/Frog-OS#frogos
   ```

3. Update flake inputs (to regenerate `flake.lock`):
   ```bash
   # Using the update script (recommended)
   ./scripts/update-flake.sh
   
   # Or manually
   nix flake update
   ```

## Project Structure

```
Frog-OS/
├── flake.nix              # Flake definition and inputs
├── config.nix             # Main NixOS configuration entry point
├── modules/
│   ├── nixos/             # System-level NixOS modules
│   │   ├── default.nix   # NixOS module imports
│   │   ├── system.nix    # System configuration (users, packages, etc.)
│   │   ├── hyprland.nix  # Hyprland system configuration
│   │   ├── network.nix   # Network configuration
│   │   ├── audio.nix     # Audio/PipeWire configuration
│   │   ├── bluetooth.nix # Bluetooth configuration
│   │   └── localsend.nix # LocalSend service configuration
│   │
│   ├── home-manager/      # User-level Home Manager modules
│   │   ├── default.nix   # Home Manager module imports
│   │   ├── themes.nix    # Theme system definitions
│   │   ├── hyprland/     # Hyprland window manager config
│   │   │   ├── configuration.nix  # Main Hyprland config
│   │   │   ├── bindings.nix       # Keybindings
│   │   │   ├── windows.nix        # Window rules
│   │   │   ├── looknfeel.nix     # Visual settings
│   │   │   └── autostart.nix     # Startup applications
│   │   ├── waybar.nix    # Waybar status bar
│   │   ├── wofi.nix      # Wofi launcher
│   │   ├── mako.nix      # Mako notifications
│   │   ├── kitty.nix     # Kitty terminal
│   │   ├── neovim.nix    # Neovim editor
│   │   ├── starship.nix  # Starship prompt
│   │   ├── zsh.nix       # Zsh shell configuration
│   │   ├── yazi.nix      # Yazi file manager
│   │   ├── git.nix       # Git configuration
│   │   ├── gtk.nix       # GTK theme configuration
│   │   ├── cursor.nix    # Cursor theme
│   │   ├── fastfetch.nix # Fastfetch system info
│   │   ├── hyprpaper.nix # Hyprpaper wallpaper daemon
│   │   ├── hypridle.nix  # Hypridle idle daemon
│   │   ├── hyprlock.nix  # Hyprlock lock screen
│   │   ├── mpd.nix       # MPD music daemon
│   │   ├── ncmpcpp.nix   # ncmpcpp music client
│   │   ├── webapps.nix   # Web app configurations
│   │   └── webapps/      # Web app definitions
│   │
│   └── themes/           # Theme documentation
│       └── README.md     # Theme system documentation
│
├── scripts/                  # Utility scripts
│   ├── wallpaper-manager.sh  # Wallpaper management
│   ├── wallpaper-rotate.sh   # Wallpaper rotation
│   ├── switch-theme.sh       # Theme switcher
│   ├── validate-modules.sh   # Module validation
│   ├── test-modules.sh       # Module testing
│   ├── validate-config.sh    # Configuration validation
│   ├── test-module-individual.sh  # Individual module tests
│   ├── validate-keybindings.sh   # Keybinding validation
│   ├── test-theme-switching.sh   # Theme testing
│   ├── update-flake.sh       # Flake update helper
│   ├── update-packages.sh    # Package version checker
│   └── README.md             # Script documentation
│
├── tests/                    # Unit tests and VM tests
│   └── README.md             # Test documentation
│
├── Wallpapers/               # Wallpaper collection (optional)
│
├── FASTFETCH-PLANNING.md     # Fastfetch planning notes
└── todo.md                   # Project TODO list
```

## Module Overview

### NixOS Modules (`modules/nixos/`)

System-level configuration modules that require root access:

- **system.nix** - Core system settings (hostname, timezone, users, system packages)
- **hyprland.nix** - Hyprland system integration (XWayland, etc.)
- **network.nix** - NetworkManager configuration
- **audio.nix** - PipeWire audio system
- **bluetooth.nix** - Bluetooth support
- **localsend.nix** - LocalSend service configuration

### Home Manager Modules (`modules/home-manager/`)

User-level configuration modules:

- **themes.nix** - Central theme system with multiple theme presets
- **hyprland/** - Complete Hyprland window manager configuration
- **waybar.nix** - Status bar with system information
- **wofi.nix** - Application launcher
- **mako.nix** - Notification daemon
- **kitty.nix** - Terminal emulator
- **neovim.nix** - Text editor
- **starship.nix** - Shell prompt
- **zsh.nix** - Shell configuration with aliases and plugins
- **yazi.nix** - Terminal file manager
- **git.nix** - Git configuration
- **gtk.nix** - GTK theme and icon settings
- **cursor.nix** - Cursor theme
- **fastfetch.nix** - System information display
- **hyprpaper.nix** - Wallpaper management
- **hypridle.nix** - Idle daemon
- **hyprlock.nix** - Lock screen
- **mpd.nix** - Music player daemon
- **ncmpcpp.nix** - MPD client
- **webapps.nix** - Web application configurations

## Theming

Frog-OS includes a comprehensive theming system. See `modules/themes/README.md` for details.

Available themes include:
- Standard themes: tokyo-night, everforest, gruvbox, kanagawa, nord, matte-black
- Additional themes: See `modules/themes/README.md` for the full list

To switch themes, edit `defaultTheme` in `modules/home-manager/themes.nix`.

## Flake Inputs

- **nixpkgs** (nixos-unstable) - Latest NixOS packages and modules
- **home-manager** - Declarative user environment management
- **tuios** - Terminal UI Operating System framework

See `flake.nix` for detailed documentation of each input.

## Common Tasks

### Rebuild Configuration
```bash
sudo nixos-rebuild switch --flake ~/Frog-OS#frogos
```

### Update Flake Inputs
```bash
nix flake update ~/Frog-OS
```

### Clean Build Artifacts
```bash
sudo nix-collect-garbage -d
```

### Test Configuration (Dry Run)
```bash
sudo nixos-rebuild build --flake ~/Frog-OS#frogos
```

## System Requirements

- NixOS (x86_64-linux)
- Flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`)
- Wayland-compatible graphics drivers

## Contributing

This is a personal configuration, but suggestions and improvements are welcome. See `todo.md` for planned improvements.

## License

This configuration is provided as-is for personal use.


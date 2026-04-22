# Scripts Directory

This directory contains utility scripts for managing and maintaining Frog-OS.

## Available Scripts

### Wallpaper Management

- **`wallpaper-manager.sh`** - Manage wallpapers with hyprpaper
  - List, set, random selection, preload wallpapers
  - See `../WALLPAPER-README.md` for detailed usage

- **`wallpaper-rotate.sh`** - Automatic wallpaper rotation
  - Rotate wallpapers at intervals
  - Supports daemon mode for background rotation
  - See `../WALLPAPER-README.md` for detailed usage

### Theme Management

- **`switch-theme.sh`** - Switch between themes
  - Usage: `./switch-theme.sh <theme-name>`
  - Lists available themes: `./switch-theme.sh --list`
  - Updates `modules/home-manager/themes.nix` with new theme

### Module Validation

- **`validate-modules.sh`** - Validate all NixOS modules
  - Checks that all imported modules exist
  - Validates Nix syntax
  - Reports missing files and syntax errors

- **`test-modules.sh`** - Test individual modules
  - Tests each module for syntax correctness
  - Checks for common issues (TODOs, placeholders)
  - Provides detailed testing output

### Flake & Package Management

- **`update-flake.sh`** - Update flake inputs
  - Updates all flake inputs safely
  - Shows current and updated versions
  - Provides testing recommendations

- **`update-packages.sh`** - Check package versions
  - Lists all installed package versions
  - Shows custom package pinning status
  - Helps identify update opportunities

### Testing & Validation

- **`validate-config.sh`** - Validate complete NixOS configuration
  - Tests flake structure
  - Validates module imports
  - Tests configuration build
  - Checks for common issues

- **`validate-modules.sh`** - Validate module files
  - Checks file existence
  - Validates Nix syntax
  - Verifies import chains

- **`test-modules.sh`** - Test all modules
  - Syntax validation
  - Common issue detection
  - TODO/FIXME detection

- **`test-module-individual.sh`** - Test modules independently
  - Isolates module issues
  - Individual syntax checks
  - Faster debugging

- **`validate-keybindings.sh`** - Validate Hyprland keybindings
  - Checks for duplicates
  - Validates key combinations
  - Verifies script references
  - Checks essential bindings

- **`test-theme-switching.sh`** - Test theme system
  - Validates theme structure
  - Tests theme switching script
  - Checks theme integration

## Usage

All scripts are executable and can be run directly:

```bash
# From repository root
./scripts/wallpaper-manager.sh list
./scripts/switch-theme.sh nord
./scripts/validate-modules.sh
./scripts/test-modules.sh
```

## Adding New Scripts

When adding new scripts:
1. Place them in this `scripts/` directory
2. Make them executable: `chmod +x scripts/your-script.sh`
3. Update this README with documentation
4. Update main `README.md` if the script is user-facing

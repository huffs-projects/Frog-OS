{ config, pkgs, ... }:

let
  # Custom sky package
  # Version: 0.1.0 (pinned)
  # Commit: df42059811754fd87ed6615cf7c3d47d60bb87c1
  # Reason: Personal branch with specific functionality
  # Update: See PACKAGE-VERSIONS.md for update procedure
  sky = pkgs.rustPlatform.buildRustPackage rec {
    pname = "sky";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "huffs-projects";
      repo = "sky";
      rev = "df42059811754fd87ed6615cf7c3d47d60bb87c1";  # personal branch commit
      sha256 = "sha256-2u/2o/4mVPBXWM23d2Oq5wj8mHDOpFWi/gftKmKtJVo=";
    };

    # Cargo lock file - Nix will automatically compute the cargo hash from this
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    nativeBuildInputs = with pkgs; [
      pkg-config
      rustc
      cargo
    ];

    buildInputs = with pkgs; [
      openssl
    ];

    # Install man page
    postInstall = ''
      mkdir -p $out/share/man/man1
      cp ${src}/man/man1/sky.1 $out/share/man/man1/ 2>/dev/null || true
    '';

    meta = with pkgs.lib; {
      description = "A personal package management framework";
      homepage = "https://github.com/huffs-projects/sky";
      license = licenses.gpl3Only;
      maintainers = [ ];
      platforms = platforms.unix;
    };
  };

  # pipes.sh - Terminal pipes screensaver
  # Version: 1.3.0 (pinned)
  # Reason: Stable version, tested and working
  # Update: See PACKAGE-VERSIONS.md for update procedure
  pipes-sh = pkgs.stdenv.mkDerivation rec {
    pname = "pipes-sh";
    version = "1.3.0";

    src = pkgs.fetchFromGitHub {
      owner = "pipeseroni";
      repo = "pipes.sh";
      rev = "v${version}";
      sha256 = "sha256-856OWlnNiGB20571TJg7Ayzcz4r6NqdW5DMDiim09mc=";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp pipes.sh $out/bin/pipes.sh
      chmod +x $out/bin/pipes.sh
    '';

    meta = with pkgs.lib; {
      description = "Animated pipes terminal screensaver";
      homepage = "https://github.com/pipeseroni/pipes.sh";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.unix;
    };
  };

  # TUIOS - Terminal UI Operating System
  # Version: 0.4.3 (pinned)
  # Note: Also available via flake input, but built here for consistency
  # Update: Update version here or use flake input (see FLAKE-MANAGEMENT.md)
  tuios = pkgs.buildGoModule rec {
    pname = "tuios";
    version = "0.4.3";

    src = pkgs.fetchFromGitHub {
      owner = "Gaurav-Gosain";
      repo = "tuios";
      rev = "v${version}";
      sha256 = "sha256-4x5Vqd81/ZFXDpPUnJeOzI2DprAD49saL+aZZMAxI3w=";
    };

    vendorHash = "sha256-uhqa850dHRHNZLXUMGg9Hb8skEY/5CrGmxSmnBytW/s=";

    subPackages = [ "cmd/tuios" ];

    meta = with pkgs.lib; {
      description = "Terminal UI Operating System - A terminal-based window manager with vim-like modal interface";
      homepage = "https://github.com/Gaurav-Gosain/tuios";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.unix;
    };
  };

  # TUIOS Web - Web terminal server
  # Version: 0.4.3 (pinned)
  # Note: Also available via flake input, but built here for consistency
  # Update: Update version here or use flake input (see FLAKE-MANAGEMENT.md)
  tuios-web = pkgs.buildGoModule rec {
    pname = "tuios-web";
    version = "0.4.3";

    src = pkgs.fetchFromGitHub {
      owner = "Gaurav-Gosain";
      repo = "tuios";
      rev = "v${version}";
      sha256 = "sha256-4x5Vqd81/ZFXDpPUnJeOzI2DprAD49saL+aZZMAxI3w=";
    };

    vendorHash = "sha256-uhqa850dHRHNZLXUMGg9Hb8skEY/5CrGmxSmnBytW/s=";

    subPackages = [ "cmd/tuios-web" ];

    meta = with pkgs.lib; {
      description = "TUIOS Web Terminal Server - Browser-based terminal access for TUIOS";
      homepage = "https://github.com/Gaurav-Gosain/tuios";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.unix;
    };
  };
in
{
  # Hostname
  networking.hostName = "frogos";

  # Timezone
  time.timeZone = "America/New_York";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console keymap
  console.keyMap = "us";

  # User account
  users.users.frog = {
    isNormalUser = true;
    description = "Frog-OS User";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" ];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # System utilities
    fastfetch
    btop
    brightnessctl
    playerctl
    wl-clipboard
    wlogout
    pavucontrol
    networkmanagerapplet
    
    # Desktop environment
    waybar
    zsh
    
    # Audio TUI
    ncpamixer
    
    # Screenshot tools
    hyprshot
    
    # Clipboard history
    cliphist
    

    
    # Archive utilities
    unzip
    zip
    p7zip
    unrar
    
    # Network tools
    curl
    wget
    nmap
    tcpdump
    
    # Text editors
    nano
    wordgrinder
    
    # Media
    zathura
    mpv
    imv
    ffmpeg
    yt-dlp
    
    # Terminal screensavers
    cmatrix
    pipes-sh
    
    # Image preview for Yazi
    chafa
    ueberzugpp
    
    # Version control
    lazygit
    
    # Development tools
    git
    direnv
    nix-direnv
    gcc
    gnumake
    python3
    rustc
    cargo
    
    # Desktop integration
    xdg-desktop-portal-hyprland
    lxqt.policykit
    
    # Power management
    power-profiles-daemon
    
    # Disk management
    udisks2
    ntfs3g
    exfatprogs
    
    # Keyring
    gnome.gnome-keyring
    
    # Backup tools
    restic
    
    # Log tools
    lnav
    
    # Custom packages
    sky
    tuios
    tuios-web
    
    # Additional apps
    signal-desktop
    # LazyDocker (may need overlay or flake input)
    
    # Cursor theme
    catppuccin-cursors.mochaBlue
  ];

  # Power management
  services.power-profiles-daemon.enable = true;

  # Disk management
  services.udisks2.enable = true;

  # GNOME Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}

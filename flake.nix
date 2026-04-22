{
  description = "Frog-OS NixOS Configuration";

  inputs = {
    # NixOS unstable channel - provides the latest packages and NixOS modules
    # Used for: System packages, kernel, base system configuration
    # Update Strategy: Rolling updates (nixos-unstable branch)
    # To pin: Change to "github:NixOS/nixpkgs/<commit-hash>" or "github:NixOS/nixpkgs/nixos-24.11"
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager - declarative user environment management
    # Used for: User-specific configurations (dotfiles, user packages, etc.)
    # Follows nixpkgs to ensure compatibility
    # Update Strategy: Track latest release (updates with nixpkgs)
    # To pin: Change to "github:nix-community/home-manager/<commit-hash>" or specific release
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # TUIOS - Terminal UI Operating System framework
    # Used for: Terminal-based system management and custom terminal applications
    # Follows nixpkgs for dependency compatibility
    # Update Strategy: Track latest version
    # To pin: Change to "github:Gaurav-Gosain/tuios/<commit-hash>" or specific tag
    tuios = {
      url = "github:Gaurav-Gosain/tuios";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # System for tests (default to x86_64-linux)
      testSystem = "x86_64-linux";
      pkgs = import nixpkgs { system = testSystem; };
      theme = (import ./modules/home-manager/theme-data.nix { lib = nixpkgs.lib; }).theme;
    in
    {
      nixosConfigurations = {
        frogos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./config.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs theme; };
              home-manager.users.frog = import ./modules/home-manager/default.nix;
            }
          ];
        };
      };

      # Unit tests for helper functions and module evaluation
      checks.${testSystem} = let
        lib = pkgs.lib;
        helpers = import ./tests/helpers.nix { inherit lib; };
        moduleEval = import ./tests/module-evaluation.nix { inherit pkgs lib; };
      in {
        # Helper function tests - test hexToCssRgba
        helpers = pkgs.runCommand "test-helpers" { } ''
          echo "Testing helper functions..."
          
          # Test hexToCssRgba function
          test_result=$(${pkgs.nix}/bin/nix-instantiate --eval --strict --json -E "
            let
              helpers = import ${./tests/helpers.nix} { lib = (import ${nixpkgs} { system = \"${testSystem}\"; }).lib; };
              hexToCssRgba = helpers.testHexToCssRgba.hexToCssRgba;
            in
              {
                test1 = hexToCssRgba \"#000000\" 0.5;
                test2 = hexToCssRgba \"#ffffff\" 1.0;
                test3 = hexToCssRgba \"#fe8019\" 0.2;
              }
          " 2>&1)
          
          if echo "$test_result" | grep -q "error"; then
            echo "Helper function tests failed:"
            echo "$test_result"
            exit 1
          fi
          
          echo "Helper tests passed" > $out
          echo "$test_result" >> $out
        '';

        # Module existence tests
        # Note: Use flake-relative paths (./) which Nix resolves correctly
        moduleExistence = pkgs.runCommand "test-module-existence" {
          systemNix = ./modules/nixos/system.nix;
          hyprlandNix = ./modules/nixos/hyprland.nix;
          networkNix = ./modules/nixos/network.nix;
          themesNix = ./modules/home-manager/themes.nix;
          waybarNix = ./modules/home-manager/waybar.nix;
        } ''
          echo "Testing module existence..."
          
          # Check that required modules exist
          # Modules are passed as individual variables that Nix resolves to store paths
          modules=(
            "$systemNix"
            "$hyprlandNix"
            "$networkNix"
            "$themesNix"
            "$waybarNix"
          )
          
          for module in "''${modules[@]}"; do
            if [[ ! -f "$module" ]]; then
              echo "Module not found: $module"
              exit 1
            fi
          done
          
          echo "All required modules exist" > $out
        '';
      };

      # NixOS VM tests (integration tests)
      nixosTests = {
        basicSystem = (import ./tests/nixos-vm-tests.nix { inherit pkgs; }).basicSystemTest;
        network = (import ./tests/nixos-vm-tests.nix { inherit pkgs; }).networkTest;
        homeManager = (import ./tests/nixos-vm-tests.nix {
          inherit pkgs theme inputs;
        }).homeManagerTest;
      };
    };
}

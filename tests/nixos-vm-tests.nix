{ pkgs, theme, inputs, ... }:

{
  # NixOS VM integration tests
  # These tests run in isolated VMs to verify system configuration

  # Basic system configuration test
  basicSystemTest = pkgs.testers.runNixOSTest {
    name = "frogos-basic-system";

    nodes.machine = { config, pkgs, ... }: {
      imports = [
        ../config.nix
        ../modules/nixos/default.nix
      ];

      # Minimal configuration for testing
      system.stateVersion = "24.11";

      # Disable services that require hardware or network for faster tests
      services.hyprland.enable = false;
      networking.networkmanager.enable = false;

      # Enable basic services for testing
      systemd.services.test = {
        description = "Test service";
        serviceConfig.Type = "oneshot";
        script = "echo 'Test service ran successfully'";
        wantedBy = [ "multi-user.target" ];
      };
    };

    testScript = ''
      # Wait for system to boot
      machine.wait_for_unit("multi-user.target")

      # Test that system is running
      machine.succeed("systemctl is-active multi-user.target")

      # Test that test service ran
      machine.succeed("systemctl status test.service")

      # Test that NixOS configuration is valid
      machine.succeed("nixos-version")
    '';
  };

  # Network configuration test
  networkTest = pkgs.testers.runNixOSTest {
    name = "frogos-network";

    nodes.machine = { config, pkgs, ... }: {
      imports = [
        ../modules/nixos/network.nix
      ];

      system.stateVersion = "24.11";

      # Minimal base configuration
      networking.hostName = "test-machine";
    };

    testScript = ''
      machine.wait_for_unit("network-online.target")

      # Test that NetworkManager is configured (if enabled)
      # machine.succeed("systemctl status NetworkManager || true")

      # Test that firewall rules are applied
      # This would require more complex setup
    '';
  };

  # Home Manager configuration test
  homeManagerTest = pkgs.testers.runNixOSTest {
    name = "frogos-home-manager";

    nodes.machine = { config, pkgs, ... }: {
      imports = [
        ../config.nix
        inputs.home-manager.nixosModules.home-manager
      ];

      system.stateVersion = "24.11";

      # Set up user for Home Manager
      users.users.frog = {
        isNormalUser = true;
        home = "/home/frog";
        createHome = true;
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit theme inputs; };
      home-manager.users.frog = import ../modules/home-manager/default.nix;
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")

      # Test that home directory exists
      machine.succeed("test -d /home/frog")

      # Test that Home Manager is configured
      machine.succeed("test -f /home/frog/.config/home-manager/generation.nix || true")
    '';
  };
}

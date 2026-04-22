# Frog-OS Unit Testing

This directory contains the unit testing infrastructure for Frog-OS.

## Test Structure

### 1. Helper Function Tests (`helpers.nix`)

Tests pure Nix functions used throughout the configuration:

- **hexToCssRgba**: Tests hex color to CSS rgba conversion
- **themeStructure**: Tests theme data structure validation

### 2. Module Evaluation Tests (`module-evaluation.nix`)

Tests that modules can be evaluated without errors:

- Module existence checks
- Module structure validation
- Import chain verification

### 3. NixOS VM Tests (`nixos-vm-tests.nix`)

Integration tests that run in isolated VMs:

- **basicSystemTest**: Tests basic system configuration
- **networkTest**: Tests network configuration
- **homeManagerTest**: Tests Home Manager integration

## Running Tests

### Run All Unit Tests

```bash
./scripts/run-unit-tests.sh
```

### Run Specific Test Categories

#### Helper Function Tests

```bash
nix-instantiate --eval --strict -E "with import ./tests/helpers.nix { lib = (import <nixpkgs> {}).lib; }; runTests { hexToCssRgba = testHexToCssRgba; }"
```

#### Module Evaluation Tests

```bash
nix-instantiate --eval --strict -E "import ./tests/module-evaluation.nix { pkgs = import <nixpkgs> {}; lib = (import <nixpkgs> {}).lib; }"
```

#### NixOS VM Tests (Linux only)

```bash
# Build and run a VM test
nix test .#nixosTests.basicSystem

# Or run all VM tests
nix test .#nixosTests.network
nix test .#nixosTests.homeManager
```

### Using Flake Checks

```bash
# Run all checks
nix flake check

# Run specific checks
nix build .#checks.x86_64-linux.helpers
nix build .#checks.x86_64-linux.moduleExistence
```

## Writing New Tests

### Adding a Helper Function Test

1. Add your test function to `tests/helpers.nix`:

```nix
testMyFunction = {
  myFunction = hex: /* your function */;
  
  tests = [
    {
      name = "test-case-1";
      expr = myFunction "#ff0000";
      expected = "expected-result";
    }
  ];
};
```

2. Add it to the test suite in `tests/default.nix`:

```nix
helpers = helpers.runTests {
  hexToCssRgba = helpers.testHexToCssRgba;
  myFunction = helpers.testMyFunction;  # Add here
};
```

### Adding a Module Evaluation Test

Add to `tests/module-evaluation.nix`:

```nix
testMyModule = {
  test = {
    name = "my-module-exists";
    expr = builtins.pathExists ../modules/my-module.nix;
    expected = true;
  };
};
```

### Adding a NixOS VM Test

Add to `tests/nixos-vm-tests.nix`:

```nix
myServiceTest = pkgs.testers.runNixOSTest {
  name = "my-service-test";
  
  nodes.machine = { config, pkgs, ... }: {
    # Your test configuration
  };
  
  testScript = ''
    # Your test script
    machine.wait_for_unit("my-service")
    machine.succeed("systemctl status my-service")
  '';
};
```

Then add it to `flake.nix`:

```nix
nixosTests = {
  basicSystem = ...;
  myService = (import ./tests/nixos-vm-tests.nix { inherit pkgs; }).myServiceTest;
};
```

## Test Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Determinism**: Tests should produce the same results every time
3. **Clarity**: Test names should clearly describe what they're testing
4. **Coverage**: Test both success and failure cases
5. **Performance**: Keep VM tests minimal to reduce execution time

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run unit tests
  run: ./scripts/run-unit-tests.sh

- name: Run flake checks
  run: nix flake check

- name: Run VM tests (Linux only)
  if: runner.os == 'Linux'
  run: nix test .#nixosTests.basicSystem
```

## Troubleshooting

### Tests fail with "path does not exist"

Ensure all module files are tracked by Git:
```bash
./scripts/add-untracked-modules.sh
```

### VM tests fail to build

VM tests require:
- Linux system (or Linux VM)
- Sufficient disk space
- Network access for downloading dependencies

### Helper function tests fail

Check that your function implementation matches the test expectations. Use `nix-instantiate --eval` to debug:

```bash
nix-instantiate --eval --strict -E 'your-function-expression'
```

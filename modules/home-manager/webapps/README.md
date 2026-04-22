# Web Apps Framework

This module provides a framework for easily adding web applications as desktop entries.

## Current Web Apps

- **ChatGPT** - AI Assistant (https://chat.openai.com)
- **Gmail** - Email (https://mail.google.com)

## Adding New Web Apps

To add a new web app, edit `modules/home-manager/webapps.nix` and add a new entry to the `webApps` list:

```nix
myapp = createWebApp {
  name = "My App";
  url = "https://example.com";
  comment = "My App Description";
  categories = [ "Network" "Category" ];
};
```

### Parameters

- `name` (required): Display name of the application
- `url` (required): URL to open in Firefox
- `icon` (optional): Icon name (defaults to "firefox")
- `comment` (optional): Description/tooltip text
- `categories` (optional): Desktop entry categories (defaults to ["Network" "WebBrowser"])

### Example Categories

- `Network` - General network applications
- `Chat` - Chat/messaging apps
- `Email` - Email clients
- `Video` - Video streaming
- `AudioVideo` - Media applications
- `Development` - Development tools
- `AI` - AI/ML applications
- `InstantMessaging` - Instant messaging
- `WebBrowser` - Web browsers

## Usage

After adding web apps and rebuilding your configuration:

```bash
sudo nixos-rebuild switch --flake ~/Frog-OS#frogos
```

The web apps will appear in:
- Wofi launcher (`$mod + D`)
- Any other application launcher
- Desktop environment menus

## Customization

### Using Different Browser

To use a different browser (e.g., Chromium), modify the `createWebApp` function:

```nix
exec = "${pkgs.chromium}/bin/chromium --app=${url}";
```

### Using App Mode

For a more app-like experience, you can use Firefox's app mode:

```nix
exec = "${pkgs.firefox}/bin/firefox --kiosk ${url}";
```

Or create a Firefox profile specifically for web apps.

### Custom Icons

To use custom icons, either:
1. Place icon files in `~/.local/share/icons/` and reference them by name
2. Use system icons by name (e.g., "gmail", "chatgpt")
3. Use full paths to icon files

## Notes

- Web apps open in Firefox by default
- Each web app opens in a new window
- Apps appear in application launchers automatically
- Desktop entries are created in `~/.local/share/applications/`

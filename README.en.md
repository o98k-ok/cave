# cave

A macOS menu bar app for managing SSH tunnels.

**Languages:** [中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

## Features

- Menu bar resident: Quick management of SSH tunnels (forward `-L` / reverse `-R`)
- Tunnel list: One-click start/stop, edit, delete, and status visualization
- Node chain: Local / Proxy / Target at a glance, with click-to-copy support
- Internationalization: Supports `ZH / EN / JA`, default Chinese
- Themes: `Dark / Light / CLI / Christmas`
- Settings center: Boot startup, language, theme, graceful exit (close tunnels first)

## Screenshots

### Main Interface
![Main Interface](docs/screenshots/main-interface.png)

### Add Tunnel
![Add Tunnel](docs/screenshots/add-tunnel.png)

### Settings Center
![Settings Center](docs/screenshots/settings.png)

## Requirements

- macOS 13+
- Xcode Command Line Tools (includes `swift`)

## Local Build and Run

### Debug Build

```bash
swift build
```

### Package `.app`

```bash
./build.sh
open build/cave.app
```

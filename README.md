# MindfulAccess

A macOS utility that helps users maintain mindful app usage by implementing time-based access controls with verification.

## Features

- 🕒 Time-based access control for applications
- 🔒 Verification required to access protected apps
- ⏱️ Configurable access duration with auto-shutdown
- 🔔 Warning notifications before app shutdown
- ⚙️ Easy-to-use configuration interface
- 💾 Persistent state tracking across sessions
- 🔄 Menu bar integration for easy access

## Prerequisites

- macOS 10.14 or later
- Accessibility permissions (will be requested during installation)

## Installation

### Option 1: Direct Installation (Recommended)

1. Download the latest release from the [Releases](https://github.com/yourusername/MindfulAccess/releases) page
2. Open the DMG file
3. Drag `MindfulAccess.app` to your Applications folder
4. Double-click `MindfulAccess.app` to start

The app will:
- Request necessary permissions
- Create a menu bar icon
- Start monitoring protected apps
- Run automatically at login

### Option 2: Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/MindfulAccess.git
   cd MindfulAccess
   ```

2. Build the app:
   ```bash
   bash scripts/build_app.sh
   ```

3. Install the built app:
   - Option A: Drag `dist/MindfulAccess.app` to your Applications folder
   - Option B: Run the installer: `dist/MindfulAccess.app/Contents/Resources/install.sh`

## Usage

### First Run

1. Click the menu bar icon (⏱️)
2. Select "Configure..." to open settings
3. Add applications you want to protect
4. Set your preferred time window and access duration
5. The app will now monitor your protected applications

### Protected App Access

When you try to open a protected application:
1. The app will be temporarily closed
2. A verification dialog will appear
3. Enter the displayed verification string exactly
4. Upon successful verification:
   - The app will reopen
   - You'll have access for the configured duration
   - A warning will appear before access expires
   - The app will automatically close when access expires

### Menu Bar Options

- 🔧 Configure...: Open settings
- ❌ Quit: Exit the application

## Configuration

Settings are stored in `~/.config/mindfulaccess/config` with these defaults:
- Start hour: 9 (9:00 AM)
- End hour: 17 (5:00 PM)
- String length: 32 characters
- Access duration: 30 minutes
- Protected apps: None (configure through settings)

## Uninstallation

1. Option A: Use the bundled uninstaller
   ```bash
   /Applications/MindfulAccess.app/Contents/Resources/uninstall.sh
   ```

2. Option B: Manual removal
   - Quit MindfulAccess from the menu bar
   - Move MindfulAccess.app to the Trash
   - Remove configuration (optional):
     ```bash
     rm -rf ~/.config/mindfulaccess
     rm -rf ~/.local/share/mindfulaccess
     ```

## Project Structure

```
MindfulAccess/
├── src/              # Source code
│   ├── core/         # Core application logic
│   ├── ui/           # User interface components
│   └── utils/        # Utility functions
├── scripts/          # Build scripts
│   └── templates/    # App bundle templates
├── docs/             # Documentation
└── tests/            # Test suites
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with AppleScript for macOS integration
- Uses native macOS notifications and menu bar
- Follows macOS app bundle conventions 
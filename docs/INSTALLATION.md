# MindfulAccess Installation Guide

## System Requirements

### Hardware Requirements
- Mac computer with Intel or Apple Silicon processor
- 50MB free disk space (minimum)
- 128MB RAM (minimum)

### Software Requirements
- macOS 10.14 (Mojave) or later
- Terminal application
- Bash shell (3.2 or later)
- AppleScript support enabled
- Git (for installation from source)

## Installation Methods

### Method 1: Direct Installation (Recommended)

1. **Download the Repository**
   ```bash
   git clone https://github.com/yourusername/MindfulAccess.git
   cd MindfulAccess
   ```

2. **Set Up Environment**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   echo 'export MINDFULACCESS_ROOT="$HOME/path/to/MindfulAccess"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Set Permissions**
   ```bash
   # Make scripts executable
   chmod +x src/core/*.sh
   chmod +x src/ui/*.sh
   chmod +x src/utils/*.sh
   chmod +x scripts/*.sh
   
   # Set directory permissions
   chmod 755 src config scripts tests
   chmod 644 config/default_config.sh
   ```

4. **Create Required Directories**
   ```bash
   # Create config directory
   mkdir -p ~/.config/mindfulaccess
   
   # Create log directory
   mkdir -p ~/.local/share/mindfulaccess/logs
   ```

5. **Initial Configuration**
   ```bash
   # Run configuration interface
   bash src/core/app_protector.sh --config
   ```

### Method 2: Installation Script

1. **Download and Run Installer**
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/MindfulAccess/main/scripts/install.sh
   chmod +x install.sh
   ./install.sh
   ```

2. **Follow Prompts**
   - Choose installation directory
   - Set up environment variables
   - Configure initial settings

## Post-Installation Setup

### 1. System Permissions

1. **Enable Accessibility Access**
   - Open System Preferences
   - Go to Security & Privacy → Privacy → Accessibility
   - Click the lock to make changes
   - Add Terminal.app (or your preferred terminal)
   - Check the box to enable access

2. **Enable Notifications**
   - Open System Preferences
   - Go to Notifications
   - Find Terminal.app (or your preferred terminal)
   - Enable notifications and customize style

### 2. Shell Integration

1. **Verify Environment**
   ```bash
   # Check environment variable
   echo $MINDFULACCESS_ROOT
   
   # Should output your installation path
   ```

2. **Test Installation**
   ```bash
   # Run with debug mode
   DEBUG=true bash src/core/app_protector.sh --run
   
   # Should start without errors
   ```

### 3. Initial Configuration

1. **Basic Setup**
   ```bash
   # Run configuration interface
   bash src/core/app_protector.sh --config
   
   # Configure:
   # - Protected applications
   # - Time window
   # - String length
   # - Access duration
   ```

2. **Verify Configuration**
   ```bash
   # Check config file
   cat ~/.config/mindfulaccess/config
   
   # Test configuration
   bash src/core/app_protector.sh --run
   ```

## Automatic Startup

### Method 1: Launch Agent (Recommended)

1. **Create Launch Agent**
   ```bash
   # Create directory if needed
   mkdir -p ~/Library/LaunchAgents
   
   # Copy launch agent plist
   cp config/launchd/com.mindfulaccess.plist ~/Library/LaunchAgents/
   
   # Load launch agent
   launchctl load ~/Library/LaunchAgents/com.mindfulaccess.plist
   ```

2. **Verify Launch Agent**
   ```bash
   # Check if running
   launchctl list | grep mindfulaccess
   ```

### Method 2: Login Items

1. **Create Launcher Script**
   ```bash
   # Create launcher
   echo '#!/bin/bash
   export MINDFULACCESS_ROOT="$HOME/path/to/MindfulAccess"
   bash "$MINDFULACCESS_ROOT/src/core/app_protector.sh" --run' > ~/Library/Scripts/mindfulaccess_launcher.sh
   
   chmod +x ~/Library/Scripts/mindfulaccess_launcher.sh
   ```

2. **Add to Login Items**
   - Open System Preferences
   - Go to Users & Groups
   - Click Login Items
   - Add the launcher script

## Troubleshooting Installation

### Common Issues

1. **Permission Denied**
   ```bash
   # Fix script permissions
   chmod +x src/core/*.sh src/ui/*.sh src/utils/*.sh
   ```

2. **Environment Variable Not Set**
   ```bash
   # Add to shell profile
   echo 'export MINDFULACCESS_ROOT="$PWD"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Configuration Directory Issues**
   ```bash
   # Fix permissions
   chmod 700 ~/.config/mindfulaccess
   chmod 600 ~/.config/mindfulaccess/config
   ```

### Verification Steps

1. **Check Installation**
   ```bash
   # Verify files
   ls -l $MINDFULACCESS_ROOT/src/core/app_protector.sh
   
   # Check permissions
   ls -l ~/.config/mindfulaccess/config
   ```

2. **Test Functionality**
   ```bash
   # Run with debug
   DEBUG=true bash src/core/app_protector.sh --run
   
   # Check logs
   tail -f ~/.local/share/mindfulaccess/logs/mindfulaccess.log
   ```

## Uninstallation

1. **Stop Services**
   ```bash
   # Unload launch agent
   launchctl unload ~/Library/LaunchAgents/com.mindfulaccess.plist
   
   # Kill running instances
   pkill -f "mindfulaccess.*"
   ```

2. **Remove Files**
   ```bash
   # Remove configuration
   rm -rf ~/.config/mindfulaccess
   
   # Remove logs
   rm -rf ~/.local/share/mindfulaccess
   
   # Remove launch agent
   rm ~/Library/LaunchAgents/com.mindfulaccess.plist
   
   # Remove installation
   rm -rf $MINDFULACCESS_ROOT
   ```

3. **Clean Environment**
   ```bash
   # Remove from shell profile
   # Edit ~/.bashrc or ~/.zshrc and remove the MINDFULACCESS_ROOT export line
   ```

## Support

For additional help:
1. Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review the [Technical Documentation](TECHNICAL.md)
3. Open an issue on GitHub
4. Contact the maintainers 
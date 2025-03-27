#!/bin/bash

# Installation script for MindfulAccess

# Get the absolute path of the installation directory
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create necessary directories
CONFIG_DIR="$HOME/.config/mindfulaccess"
LOG_DIR="$HOME/.local/share/mindfulaccess/logs"
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"

# Set proper permissions
chmod 755 "$CONFIG_DIR"
chmod 755 "$LOG_DIR"

# Create environment file
ENV_FILE="$CONFIG_DIR/env"
cat > "$ENV_FILE" << EOF
export MINDFULACCESS_ROOT="$INSTALL_DIR"
export PATH="\$MINDFULACCESS_ROOT/bin:\$PATH"
EOF

# Create default configuration if it doesn't exist
CONFIG_FILE="$CONFIG_DIR/config"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << EOF
START_HOUR=9
END_HOUR=17
STRING_LENGTH=32
ACCESS_DURATION=30
APPS=(Safari)
EOF
fi

# Create bin directory and symlink executables
mkdir -p "$INSTALL_DIR/bin"
ln -sf "$INSTALL_DIR/src/ui/config_interface.sh" "$INSTALL_DIR/bin/mindfulaccess-config"
ln -sf "$INSTALL_DIR/src/ui/dialogs.sh" "$INSTALL_DIR/bin/mindfulaccess-dialog"

# Make executables executable
chmod +x "$INSTALL_DIR/src/ui/config_interface.sh"
chmod +x "$INSTALL_DIR/src/ui/dialogs.sh"

# Add environment setup to shell rc file
RC_FILE="$HOME/.zshrc"
if [[ ! -f "$RC_FILE" ]]; then
    RC_FILE="$HOME/.bashrc"
fi

if ! grep -q "source.*mindfulaccess/env" "$RC_FILE"; then
    echo "# MindfulAccess environment setup" >> "$RC_FILE"
    echo "source \"$ENV_FILE\"" >> "$RC_FILE"
fi

echo "MindfulAccess installed successfully!"
echo "Please restart your terminal or run: source \"$ENV_FILE\"" 
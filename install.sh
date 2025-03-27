#!/bin/bash

# Installation script for MindfulAccess

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Log start of installation
log_info "Starting installation of MindfulAccess v1.0.0..."

# Check system requirements
log_info "Checking system requirements..."
check_system_requirements || exit 1

# Stop any running instances
log_info "Stopping process matching: app_protector.sh --run"
pkill -f "app_protector.sh --run" || true

# Create backup of existing installation
if [[ -d "$INSTALL_DIR" ]]; then
    BACKUP_DIR="$HOME/Library/Application Support/MindfulAccess/backup"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/MindfulAccess-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" "$INSTALL_DIR" 2>/dev/null || true
    log_info "Backup created: $BACKUP_FILE"
fi

# Start installation
log_info "Installing MindfulAccess..."

# Remove existing installation
log_info "Removing existing installation..."
sudo rm -rf "$INSTALL_DIR"

# Install launch agent
log_info "Installing launch agent..."
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENT_DIR"
cp "$RESOURCES_DIR/LaunchAgents/$APP_IDENTIFIER.plist" "$LAUNCH_AGENT_DIR/"

# Set up directories and files
log_info "Setting up directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"
touch "$LOG_FILE" || true  # Don't fail if file exists

# Copy files
cp -r "$RESOURCES_DIR/src" "$INSTALL_DIR/"
cp -r "$RESOURCES_DIR/config" "$INSTALL_DIR/"
cp -r "$RESOURCES_DIR/bin" "$INSTALL_DIR/"

# Set permissions
chmod -R 755 "$INSTALL_DIR"
chmod -R 644 "$CONFIG_DIR"/*
chmod -R 644 "$LOG_DIR"/*

# Create default configuration if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << EOF
START_HOUR=9
END_HOUR=17
STRING_LENGTH=32
ACCESS_DURATION=30
APPS=(Safari)
EOF
fi

# Load launch agent
launchctl unload "$LAUNCH_AGENT_DIR/$APP_IDENTIFIER.plist" 2>/dev/null || true
launchctl load -w "$LAUNCH_AGENT_DIR/$APP_IDENTIFIER.plist"

log_info "Installation complete!"
log_info "MindfulAccess will start automatically at login"
log_info "To start now, run: open -a MindfulAccess" 
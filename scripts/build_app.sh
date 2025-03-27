#!/bin/bash

# Build script for MindfulAccess.app

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
APP_NAME="MindfulAccess"
APP_VERSION="1.0.0"
APP_IDENTIFIER="com.mindfulaccess.app"
APP_PATH="$PROJECT_ROOT/dist/$APP_NAME.app"
ICON_PATH="$PROJECT_ROOT/assets/AppIcon.icns"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Logging
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

# Replace template variables
replace_vars() {
    local file="$1"
    sed -i '' \
        -e "s/{{APP_NAME}}/$APP_NAME/g" \
        -e "s/{{APP_VERSION}}/$APP_VERSION/g" \
        -e "s/{{APP_IDENTIFIER}}/$APP_IDENTIFIER/g" \
        "$file"
}

# Create app bundle structure
create_bundle_structure() {
    log_info "Creating app bundle structure..."
    mkdir -p "$APP_PATH/Contents/"{MacOS,Resources,Frameworks}
    mkdir -p "$APP_PATH/Contents/Resources/"{src,config,bin,LaunchAgents}
}

# Create Info.plist
create_info_plist() {
    log_info "Creating Info.plist..."
    cp "$TEMPLATES_DIR/info.plist.template" "$APP_PATH/Contents/Info.plist"
    replace_vars "$APP_PATH/Contents/Info.plist"
}

# Create main executable
create_main_executable() {
    log_info "Creating main executable..."
    cp "$TEMPLATES_DIR/main_executable.sh.template" "$APP_PATH/Contents/MacOS/$APP_NAME"
    replace_vars "$APP_PATH/Contents/MacOS/$APP_NAME"
    chmod +x "$APP_PATH/Contents/MacOS/$APP_NAME"
}

# Create launch agent
create_launch_agent() {
    log_info "Creating launch agent..."
    cp "$TEMPLATES_DIR/launchagent.plist.template" "$APP_PATH/Contents/Resources/LaunchAgents/$APP_IDENTIFIER.plist"
    replace_vars "$APP_PATH/Contents/Resources/LaunchAgents/$APP_IDENTIFIER.plist"
}

# Create installer and uninstaller
create_installer() {
    log_info "Creating installer and uninstaller..."
    local resources_dir="$APP_PATH/Contents/Resources"
    
    # Copy utilities first
    cp "$TEMPLATES_DIR/utils.sh.template" "$resources_dir/utils.sh"
    replace_vars "$resources_dir/utils.sh"
    chmod +x "$resources_dir/utils.sh"
    
    # Install script
    cp "$TEMPLATES_DIR/install.sh.template" "$resources_dir/install.sh"
    replace_vars "$resources_dir/install.sh"
    chmod +x "$resources_dir/install.sh"
    
    # Uninstall script
    cp "$TEMPLATES_DIR/uninstall.sh.template" "$resources_dir/uninstall.sh"
    replace_vars "$resources_dir/uninstall.sh"
    chmod +x "$resources_dir/uninstall.sh"
}

# Copy project files
copy_project_files() {
    log_info "Copying project files..."
    cp -r "$PROJECT_ROOT/src" "$APP_PATH/Contents/Resources/"
    cp -r "$PROJECT_ROOT/config" "$APP_PATH/Contents/Resources/"
    
    if [[ -f "$ICON_PATH" ]]; then
        cp "$ICON_PATH" "$APP_PATH/Contents/Resources/AppIcon.icns"
    else
        log_error "Warning: App icon not found at $ICON_PATH"
    fi
}

# Compile menu helper
compile_menu_helper() {
    log_info "Compiling menu helper..."
    local menu_helper_src="$PROJECT_ROOT/src/ui/menu_helper.swift"
    local menu_helper_bin="$APP_PATH/Contents/Resources/bin/MindfulAccessMenu"
    
    # Create bin directory if it doesn't exist
    mkdir -p "$(dirname "$menu_helper_bin")"
    
    # Compile the Swift code
    if ! swiftc -o "$menu_helper_bin" "$menu_helper_src"; then
        log_error "Failed to compile menu helper"
        return 1
    fi
    
    # Make it executable
    chmod +x "$menu_helper_bin"
    
    log_info "Menu helper compiled successfully"
    return 0
}

# Create DMG
create_dmg() {
    log_info "Creating DMG..."
    DMG_PATH="$PROJECT_ROOT/dist/$APP_NAME-$APP_VERSION.dmg"
    hdiutil create -volname "$APP_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_PATH"
    
    log_info "Build complete!"
    log_info "App bundle: $APP_PATH"
    log_info "DMG installer: $DMG_PATH"
    log_info ""
    log_info "To install, either:"
    log_info "1. Drag $APP_NAME.app to /Applications"
    log_info "2. Or run the install.sh script inside the app bundle"
    log_info ""
    log_info "To uninstall, run uninstall.sh script inside the app bundle"
}

# Main build process
main() {
    # Check for templates
    if [ ! -d "$TEMPLATES_DIR" ]; then
        log_error "Templates directory not found at $TEMPLATES_DIR"
        exit 1
    fi
    
    # Create bundle
    create_bundle_structure
    
    # Create components
    create_info_plist
    create_main_executable
    create_launch_agent
    create_installer
    
    # Copy files
    copy_project_files
    
    # Compile menu helper
    compile_menu_helper || exit 1
    
    # Create DMG
    create_dmg
}

# Run main function
main 
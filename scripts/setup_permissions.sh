#!/bin/bash

# Script to set up proper app bundle and permissions for MindfulAccess

# Get the absolute path of the project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create app bundle directory structure
APP_DIR="$PROJECT_DIR/dist/MindfulAccess.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MindfulAccess</string>
    <key>CFBundleIdentifier</key>
    <string>com.mindfulaccess.app</string>
    <key>CFBundleName</key>
    <string>MindfulAccess</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create main executable
cat > "$APP_DIR/Contents/MacOS/MindfulAccess" << EOF
#!/bin/bash
# Main executable for MindfulAccess

# Request accessibility permissions if needed
osascript -e 'tell application "System Events" to set UI elements enabled to true'

# Run the actual test suite
"$PROJECT_DIR/tests/menu_bar/run_tests.sh"
EOF

# Make the executable executable
chmod +x "$APP_DIR/Contents/MacOS/MindfulAccess"

echo "App bundle created at $APP_DIR"
echo "To run with proper permissions:"
echo "1. Open System Settings > Privacy & Security > Accessibility"
echo "2. Click the + button"
echo "3. Navigate to: $APP_DIR"
echo "4. Select MindfulAccess.app and click Open"
echo "5. Enable the permission for MindfulAccess"
echo ""
echo "After granting permissions, run:"
echo "open \"$APP_DIR\"" 
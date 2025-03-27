#!/bin/bash

# Format time in 24-hour format with minutes
format_time() {
    local hour=$1
    printf "%02d:00" "$hour"
}

# Format time window
format_time_window() {
    local start_hour=$1
    local end_hour=$2
    printf "%02d:00 - %02d:00" "$start_hour" "$end_hour"
}

# Format app list for display
format_app_list() {
    local apps=$1
    echo "$apps" | sed 's/,/, /g'
}

# Show success message with green color
show_success() {
    local message=$1
    echo -e "\033[0;32m✓ $message\033[0m"
}

# Show simple warning dialog
show_simple_warning() {
    local title="$1"
    local message="$2"
    
    osascript <<EOF
        tell application "System Events"
            display dialog "$message" ¬
                buttons {"OK"} ¬
                default button "OK" ¬
                with title "$title"
        end tell
EOF
} 
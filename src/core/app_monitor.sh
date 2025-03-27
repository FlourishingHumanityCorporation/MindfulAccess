#!/bin/bash

# Application monitor utility for MindfulAccess
# Handles application state monitoring and control

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Source dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"

# Get process name variations for an app
# Arguments:
#   $1: Application name
# Returns:
#   Array of possible process names
get_process_names() {
    local app_name=$1
    local base_name=${app_name%.app}
    echo "$base_name" "$base_name.app"
}

# Check if an application is running
# Arguments:
#   $1: Application name
# Returns:
#   0 if running, 1 if not running
is_app_running() {
    local app_name=$1
    local running=1
    
    # Try both with and without .app extension
    for process_name in $(get_process_names "$app_name"); do
        if pgrep -i "^${process_name}$" >/dev/null 2>&1; then
            log_debug "Application '$process_name' is running"
            running=0
            break
        fi
    done
    
    if [[ $running -eq 1 ]]; then
        log_debug "Application '$app_name' is not running"
    fi
    return $running
}

# Get the frontmost application name
# Returns:
#   Name of the frontmost application
get_frontmost_app() {
    local frontmost
    frontmost=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')
    log_debug "Frontmost application: $frontmost"
    echo "$frontmost"
}

# Force quit an application
# Arguments:
#   $1: Application name
force_quit_app() {
    local app_name=$1
    local pid
    
    # Try both with and without .app extension
    for process_name in $(get_process_names "$app_name"); do
        pid=$(pgrep -i "^${process_name}$")
        if [[ -n "$pid" ]]; then
            log_info "Force quitting application '$process_name' (PID: $pid)"
            # First try SIGTERM
            kill -15 "$pid" 2>/dev/null
            sleep 2
            
            # If still running, try SIGINT
            if kill -0 "$pid" 2>/dev/null; then
                kill -2 "$pid" 2>/dev/null
                sleep 1
            fi
            
            # Only use SIGKILL as absolute last resort
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
            return 0
        fi
    done
    
    return 1
}

# Quit an application
# Arguments:
#   $1: Application name
# Returns:
#   0 on success, 1 on failure
quit_app() {
    local app_name=$1
    
    if ! is_app_running "$app_name"; then
        log_debug "Application '$app_name' is not running, no need to quit"
        return 0
    fi
    
    log_info "Attempting to quit application '$app_name'"
    
    # First try AppleScript quit
    osascript -e "
        tell application \"$app_name\"
            if it is running then
                try
                    quit
                on error errMsg
                    log \"Error quitting $app_name: \" & errMsg
                end try
            end if
        end tell" 2>/dev/null
    
    # Wait a moment for the app to quit
    sleep 2
    
    # If app is still running, try force quit
    if is_app_running "$app_name"; then
        log_info "Application didn't quit gracefully, trying force quit"
        force_quit_app "$app_name"
        sleep 1
    fi
    
    # Verify app has quit
    if is_app_running "$app_name"; then
        log_error "Failed to quit application '$app_name'"
        return 1
    else
        log_info "Successfully quit application '$app_name'"
        return 0
    fi
}

# Schedule application shutdown after specified duration
# Arguments:
#   $1: Application name
#   $2: Duration in minutes
schedule_app_shutdown() {
    local app_name=$1
    local duration_minutes=$2
    
    # Validate duration
    if ! [[ "$duration_minutes" =~ ^[0-9]+$ ]] || (( duration_minutes < 1 )); then
        log_error "Invalid duration: $duration_minutes minutes"
        return 1
    fi
    
    log_info "Scheduling shutdown of '$app_name' in $duration_minutes minutes"
    
    # Launch background process to handle the delayed shutdown
    (
        sleep $((duration_minutes * 60))
        if is_app_running "$app_name"; then
            log_info "Executing scheduled shutdown of '$app_name'"
            quit_app "$app_name"
        else
            log_info "Application '$app_name' is not running at scheduled shutdown time"
        fi
    ) &
    
    # Store the background process ID for potential future reference
    echo $! > "/tmp/mindfulaccess_${app_name// /_}_shutdown.pid"
    log_debug "Shutdown scheduler started with PID $!"
    return 0
}

# Open an application
# Arguments:
#   $1: Application name
# Returns:
#   0 on success, 1 on failure
open_app() {
    local app_name=$1
    
    log_info "Opening application '$app_name'"
    
    # Try to open the app using AppleScript
    osascript -e "
        tell application \"$app_name\"
            try
                activate
            on error errMsg
                # If that fails, try opening it from /Applications
                tell application \"Finder\"
                    try
                        open application file \"$app_name.app\" of folder \"Applications\" of startup disk
                    on error
                        # If that fails too, try using the 'open' command
                        do shell script \"open -a '$app_name'\"
                    end try
                end tell
            end try
        end tell" 2>/dev/null
    
    # Wait a moment for the app to open
    sleep 1
    
    # Verify app is running
    if is_app_running "$app_name"; then
        log_info "Successfully opened application '$app_name'"
        return 0
    else
        log_error "Failed to open application '$app_name'"
        return 1
    fi
}

# Test the app monitor (if script is run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Enable debug output for testing
    DEBUG=true
    
    test_app="Safari"
    log_info "Testing app monitor with application: $test_app"
    
    if is_app_running "$test_app"; then
        log_info "$test_app is running"
        frontmost=$(get_frontmost_app)
        log_info "Frontmost app is: $frontmost"
        
        log_info "Testing quit function..."
        quit_app "$test_app"
    else
        log_info "$test_app is not running"
    fi
fi 
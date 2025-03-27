#!/bin/bash

# MindfulAccess - Main Application Script
# Controls access to specified applications based on time windows and verification

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Source dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/core/string_generator.sh"
source "$MINDFULACCESS_ROOT/src/core/time_checker.sh"
source "$MINDFULACCESS_ROOT/src/core/app_monitor.sh"
source "$MINDFULACCESS_ROOT/src/ui/dialogs.sh"
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"
source "$MINDFULACCESS_ROOT/src/ui/config_interface.sh"

# Use a simple array and delimiter for state tracking (Bash 3 compatible)
ACTIVE_APPS=""
ACTIVE_APPS_DELIMITER="|"
ACTIVE_APPS_FILE="/tmp/mindfulaccess_active_apps"

# Configuration section
NOTIFICATION_STYLE="notification"  # Options: "notification", "dialog"
NOTIFICATION_INTERVAL=60          # How often to update the countdown (in seconds)
NOTIFICATION_FORMAT="MM:SS"       # Options: "MM:SS", "Minutes only"
WARNING_TIME=120                  # Time before shutdown to show warning (in seconds)
TEMP_DIR="/tmp/mindfulaccess"    # Directory for temporary files

# Initialize directories and files
init_directories() {
    mkdir -p "$TEMP_DIR"
    END_TIMES_DIR="$TEMP_DIR/end_times"
    ACTIVE_APPS_FILE="$TEMP_DIR/active_apps"
    mkdir -p "$END_TIMES_DIR"
}

# Format time remaining according to configuration
format_time_remaining() {
    local minutes=$1
    local seconds=$2
    
    case "$NOTIFICATION_FORMAT" in
        "MM:SS")
            echo "$minutes:$(printf "%02d" "$seconds")"
            ;;
        "Minutes only")
            echo "$minutes minutes"
            ;;
        *)
            echo "$minutes:$(printf "%02d" "$seconds")"
            ;;
    esac
}

# Show notification using configured style
show_time_notification() {
    local app_name="$1"
    local time_text="$2"
    
    case "$NOTIFICATION_STYLE" in
        "notification")
            osascript -e "
                tell application \"System Events\"
                    display notification \"$time_text remaining\" ¬
                        with title \"MindfulAccess\" ¬
                        subtitle \"$app_name Access Time\"
                end tell" 2>/dev/null
            ;;
        "dialog")
            osascript -e "
                tell application \"System Events\"
                    display dialog \"Time remaining for $app_name: $time_text\" ¬
                        buttons {\"Close\"} ¬
                        default button \"Close\" ¬
                        with title \"MindfulAccess\" ¬
                        giving up after 1
                end tell" 2>/dev/null
            ;;
    esac
}

# Show countdown for an app
show_countdown() {
    local app_name="$1"
    local end_time="$2"
    local pid_file="/tmp/mindfulaccess_${app_name// /_}_countdown.pid"
    
    log_debug "Starting countdown for $app_name (end time: $end_time)"
    
    # Validate end time
    if ! [[ "$end_time" =~ ^[0-9]+$ ]]; then
        log_error "Invalid end time format: $end_time"
        return 1
    fi
    
    # Check if countdown is already running
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_debug "Countdown already running for $app_name (PID: $pid)"
            return 0
        else
            log_debug "Removing stale PID file for $app_name"
            rm -f "$pid_file"
        fi
    fi
    
    # Show countdown notifications
    (
        # Save our PID for cleanup
        echo $$ > "$pid_file"
        log_debug "Started countdown process for $app_name (PID: $$)"
        
        # Key intervals for important notifications (in minutes)
        declare -a key_intervals=(15 10 5 2 1)
        
        # Track last notification time to prevent duplicates
        last_notification=0
        
        while true; do
            # Calculate remaining time
            current_time=$(date +%s)
            remaining_seconds=$((end_time - current_time))
            
            # Exit if time is up
            if ((remaining_seconds <= 0)); then
                log_info "Time's up for $app_name"
                osascript -e "
                    display notification \"Time's up!\" ¬
                        with title \"MindfulAccess\" ¬
                        subtitle \"$app_name Access Ended\" ¬
                        sound name \"Glass\""
                break
            fi
            
            # Calculate minutes and seconds
            minutes=$((remaining_seconds / 60))
            seconds=$((remaining_seconds % 60))
            
            # Format time string
            time_str="$(printf "%d:%02d" "$minutes" "$seconds")"
            log_debug "Time remaining for $app_name: $time_str"
            
            # Show dialog at key intervals
            if [[ " ${key_intervals[@]} " =~ " $minutes " ]] && ((seconds == 0)); then
                log_debug "Showing key interval dialog for $app_name ($minutes minutes)"
                osascript -e "
                    tell application \"System Events\"
                        display dialog \"Time remaining for $app_name: $time_str\" ¬
                            buttons {\"OK\"} ¬
                            default button \"OK\" ¬
                            with title \"MindfulAccess Warning\" ¬
                            with icon caution
                    end tell"
            fi
            
            # Show notification every minute when seconds is 0
            if ((seconds == 0)); then
                log_debug "Showing minute notification for $app_name"
                osascript -e "
                    display notification \"$time_str remaining\" ¬
                        with title \"MindfulAccess\" ¬
                        subtitle \"$app_name Access Time\"
                "
            # More frequent notifications in last 5 minutes
            elif ((minutes < 5)) && ((seconds % 30 == 0)); then
                log_debug "Showing frequent notification for $app_name"
                osascript -e "
                    display notification \"$time_str remaining\" ¬
                        with title \"MindfulAccess\" ¬
                        subtitle \"$app_name Access Time\"
                "
            fi
            
            sleep 1
        done
        
        # Cleanup
        log_debug "Cleaning up countdown for $app_name"
        rm -f "$pid_file"
    ) &
    
    # Wait briefly to ensure process started
    sleep 0.5
    if [[ -f "$pid_file" ]]; then
        log_debug "Countdown started successfully for $app_name"
        return 0
    else
        log_error "Failed to start countdown for $app_name"
        return 1
    fi
}

# Handle app access grant
grant_app_access() {
    local app_name="$1"
    local duration="$2"
    
    # Grant access
    add_active_app "$app_name"
    show_access_granted "$app_name" "$duration"
    
    # Reopen the app
    open_app "$app_name"
    
    # Calculate and store end time
    local end_time=$(($(date +%s) + duration * 60))
    echo "$end_time" > "$END_TIMES_DIR/${app_name// /_}"
    
    # Show countdown
    show_countdown "$app_name" "$end_time"
    
    # Schedule app shutdown and removal from active apps
    schedule_app_shutdown "$app_name" "$duration" "$end_time"
    
    # Schedule warning notification
    schedule_warning "$app_name" "$duration"
}

# Schedule app shutdown
schedule_app_shutdown() {
    local app_name="$1"
    local duration="$2"
    local end_time="$3"
    
    (
        sleep $((duration * 60))
        log_info "Access duration expired for '$app_name'"
        remove_active_app "$app_name"
        rm -f "$END_TIMES_DIR/${app_name// /_}"
        quit_app "$app_name"
    ) &
}

# Schedule warning notification
schedule_warning() {
    local app_name="$1"
    local duration="$2"
    
    if (( duration * 60 > WARNING_TIME )); then
        (
            sleep $(( duration * 60 - WARNING_TIME ))
            show_shutdown_warning "$app_name" $((WARNING_TIME / 60))
        ) &
    fi
}

# Handle protected app
handle_protected_app() {
    local app_name="$1"
    
    # Check if already granted access
    if is_app_active "$app_name"; then
        log_debug "App '$app_name' already has access"
        
        # Show countdown if app becomes active again
        local end_time_file="$END_TIMES_DIR/${app_name// /_}"
        if [[ -f "$end_time_file" ]]; then
            local end_time=$(cat "$end_time_file")
            show_countdown "$app_name" "$end_time"
        fi
        
        return 0
    fi
    
    log_info "Protected application detected: $app_name"
    
    # Check if we're in block time
    # check_time_window returns 0 during block time (9:00-18:00)
    # and 1 during free time (18:00-9:00)
    if check_time_window; then
        # Inside block time - require verification
        log_info "Inside block time ($CONFIG_START_HOUR:00-$CONFIG_END_HOUR:00) - verification required"
        
        # Quit the app first
        quit_app "$app_name"
        sleep 1  # Give the app time to close
        
        # Generate verification string
        local verify_string
        verify_string=$(generate_random_string "$CONFIG_STRING_LENGTH")
        if [[ -z "$verify_string" ]]; then
            log_error "Failed to generate verification string"
            show_access_denied "$app_name" "Internal error"
            quit_app "$app_name"
            return 1
        fi
        
        log_info "Showing verification dialog for '$app_name'"
        # Show verification dialog
        if show_verification_dialog "$app_name" "$verify_string"; then
            grant_app_access "$app_name" "$CONFIG_ACCESS_DURATION"
            return 0
        else
            log_info "Verification failed for '$app_name'"
            quit_app "$app_name"
            return 1
        fi
    else
        # Outside block time - allow free access
        log_debug "Outside block time ($CONFIG_START_HOUR:00-$CONFIG_END_HOUR:00) - allowing free access"
        return 0
    fi
}

# Main application loop
main_loop() {
    # Enable debug logging
    DEBUG=true
    
    log_info "Starting MindfulAccess main loop"
    log_info "Protected apps: $CONFIG_APPS"
    log_info "Time window: $(format_time_window "$CONFIG_START_HOUR" "$CONFIG_END_HOUR")"
    
    # Initialize directories
    init_directories
    
    # Load active apps from file if it exists
    if [[ -f "$ACTIVE_APPS_FILE" ]]; then
        ACTIVE_APPS=$(cat "$ACTIVE_APPS_FILE")
        log_info "Loaded active apps from file: $ACTIVE_APPS"
    fi
    
    while true; do
        # Load current configuration
        get_config
        log_debug "Current configuration loaded: Protected apps = $CONFIG_APPS"
        
        # Get frontmost application
        current_app=$(get_frontmost_app)
        log_debug "Checking frontmost app: $current_app"
        
        # Skip if no app is frontmost
        if [[ -z "$current_app" ]]; then
            log_debug "No frontmost app detected"
            sleep 1
            continue
        fi
        
        # Check if it's a protected app
        if is_protected_app "$current_app" "$CONFIG_APPS"; then
            log_debug "Protected app detected: $current_app"
            handle_protected_app "$current_app"
        else
            log_debug "App '$current_app' is not protected"
        fi
        
        sleep 1
    done
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    # Kill any remaining countdown processes
    for pid_file in /tmp/mindfulaccess_*_countdown.pid; do
        if [[ -f "$pid_file" ]]; then
            kill $(cat "$pid_file") 2>/dev/null
            rm -f "$pid_file"
        fi
    done
    # Kill any remaining shutdown schedulers
    pkill -f "mindfulaccess.*shutdown.pid"
    # Clean up temporary files
    rm -rf "$TEMP_DIR"
    exit 0
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

# Main entry point
main() {
    # Process command line arguments
    process_args "$@"
    
    # Initialize configuration
    init_config
    
    # Start main loop
    main_loop
}

# Add app to active apps
add_active_app() {
    local app="$1"
    if [[ -z "$ACTIVE_APPS" ]]; then
        ACTIVE_APPS="$app"
    else
        ACTIVE_APPS="$ACTIVE_APPS$ACTIVE_APPS_DELIMITER$app"
    fi
    echo "$ACTIVE_APPS" > "$ACTIVE_APPS_FILE"
    log_info "Added '$app' to active apps: $ACTIVE_APPS"
}

# Check if app is active
is_app_active() {
    local app="$1"
    log_debug "Checking if '$app' is active (current active apps: $ACTIVE_APPS)"
    
    # First check memory
    if [[ -n "$ACTIVE_APPS" ]]; then
        if [[ "$ACTIVE_APPS" == "$app" ]] || [[ "$ACTIVE_APPS" == *"$ACTIVE_APPS_DELIMITER$app"* ]] || [[ "$ACTIVE_APPS" == "$app$ACTIVE_APPS_DELIMITER"* ]]; then
            log_debug "'$app' is active in memory"
            return 0
        fi
    fi
    
    # Then check file
    if [[ -f "$ACTIVE_APPS_FILE" ]]; then
        local file_apps
        file_apps=$(cat "$ACTIVE_APPS_FILE")
        log_debug "Active apps from file: $file_apps"
        if [[ -n "$file_apps" ]]; then
            if [[ "$file_apps" == "$app" ]] || [[ "$file_apps" == *"$ACTIVE_APPS_DELIMITER$app"* ]] || [[ "$file_apps" == "$app$ACTIVE_APPS_DELIMITER"* ]]; then
                ACTIVE_APPS="$file_apps"
                log_debug "'$app' is active in file"
                return 0
            fi
        fi
    fi
    
    log_debug "'$app' is not active"
    return 1
}

# Remove app from active apps
remove_active_app() {
    local app="$1"
    ACTIVE_APPS=$(echo "$ACTIVE_APPS" | sed "s/$ACTIVE_APPS_DELIMITER$app$ACTIVE_APPS_DELIMITER/$ACTIVE_APPS_DELIMITER/g" | sed "s/^$app$ACTIVE_APPS_DELIMITER//g" | sed "s/$ACTIVE_APPS_DELIMITER$app$//g" | sed "s/^$app$//g")
    echo "$ACTIVE_APPS" > "$ACTIVE_APPS_FILE"
    log_info "Removed '$app' from active apps: $ACTIVE_APPS"
}

# Process command line arguments
process_args() {
    case "$1" in
        --config)
            configure_app
            exit $?
            ;;
        --run)
            # Normal operation mode
            return 0
            ;;
        --help)
            echo "Usage: $0 [--config|--run|--help]"
            echo "  --config  Configure application settings"
            echo "  --run     Run the application (default)"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Check if app is in protected list
is_protected_app() {
    local app_name=$1
    local apps=$2
    
    log_debug "Checking if '$app_name' is in protected apps list: '$apps'"
    # Convert comma-separated list to space-separated for matching
    local app_list=${apps//,/ }
    if [[ " $app_list " =~ " $app_name " ]]; then
        log_debug "'$app_name' is protected"
        return 0
    else
        log_debug "'$app_name' is not protected"
        return 1
    fi
}

# Run main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 
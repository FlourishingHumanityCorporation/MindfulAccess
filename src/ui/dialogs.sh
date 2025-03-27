#!/bin/bash

# Dialog utility for MindfulAccess
# Handles user interaction through AppleScript dialogs

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Source dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/ui/constants.sh"

# Create the verification dialog AppleScript
create_verification_dialog() {
    local app_name="$1"
    local verification_string="$2"
    local last_attempt="$3"
    
    cat <<EOF
        set verificationResult to display dialog "To access $app_name, please type: $verification_string" ¬
            default answer "$last_attempt" ¬
            buttons {"Cancel", "Verify"} ¬
            default button 2 ¬
            with title "MindfulAccess Verification"
        
        {button returned of verificationResult, text returned of verificationResult}
EOF
}

# Perform shake animation
perform_shake_animation() {
    cat <<EOF
        tell process "System Events"
            set theWindow to front window
            set {x, y} to position of theWindow
            
            repeat 3 times
                set position of theWindow to {x - 20, y}
                delay 0.03
                set position of theWindow to {x + 20, y}
                delay 0.03
                set position of theWindow to {x, y}
                delay 0.03
            end repeat
        end tell
EOF
}

# Handle verification attempt
handle_verification_attempt() {
    local app_name="$1"
    local verification_string="$2"
    local last_attempt="$3"
    local timeout="${4:-30}"
    
    # Show the verification dialog
    local result
    result=$(osascript <<EOF
        tell application "System Events"
            activate
            try
                display dialog "Please enter this code to access $app_name:\n\n$verification_string" ¬
                    default answer "" ¬
                    buttons {"Cancel", "Verify"} ¬
                    default button "Verify" ¬
                    with title "MindfulAccess Verification"
                
                set dialogResult to result
                set buttonPressed to button returned of dialogResult
                set textEntered to text returned of dialogResult
                
                return buttonPressed & ":" & textEntered
            on error errMsg
                return "Cancel:"
            end try
        end tell
EOF
    )
    
    # Check if osascript failed
    if [[ $? -ne 0 ]]; then
        log_error "Failed to show verification dialog"
        return 1
    fi
    
    # Parse the result
    local button text
    IFS=':' read -r button text <<< "$result"
    
    if [[ "$button" == "Verify" && "$text" == "$verification_string" ]]; then
        log_debug "Verification successful"
        # Activate the app after successful verification
        osascript -e "
            tell application \"System Events\"
                try
                    tell application \"$app_name\" to activate
                end try
            end tell"
        return 0
    else
        log_debug "Verification failed"
        return 1
    fi
}

# Parse dialog result
parse_dialog_result() {
    local result="$1"
    local button text
    IFS=':' read -r button text <<< "$result"
    echo "$button:$text"
}

# Check if verification was successful
is_verification_successful() {
    local button="$1"
    local text="$2"
    local verification_string="$3"
    
    [[ "$button" == "Verify" || "$button" == "OK" ]] && [[ "$text" == "$verification_string" ]]
}

# Extract incorrect attempt from error message
get_incorrect_attempt() {
    local error_msg="$1"
    echo "$error_msg" | sed 's/.*incorrect:\(.*\)/\1/'
}

# Show verification dialog
show_verification_dialog() {
    local app_name="$1"
    local verification_string="$2"
    
    # Validate input
    if [[ -z "$app_name" ]]; then
        log_error "App name cannot be empty"
        return 1
    fi
    if [[ -z "$verification_string" ]]; then
        log_error "Verification string cannot be empty"
        return 1
    fi
    
    # First, quit the app
    log_debug "Quitting $app_name before showing verification dialog"
    osascript -e "
        tell application \"System Events\"
            try
                tell application \"$app_name\" to quit
            end try
        end tell"
    sleep 1
    
    # Show dialog and handle result
    local result
    result=$(handle_verification_attempt "$app_name" "$verification_string")
    local status=$?
    
    if [[ $status -eq 0 ]]; then
        log_debug "Verification successful for $app_name"
        return 0
    else
        log_debug "Verification failed or cancelled for $app_name"
        return 1
    fi
}

# Show warning dialog with a simple message
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

# Show warning dialog
show_warning_dialog() {
    local app_name="$1"
    local remaining_time="$2"
    
    # Validate input
    if [[ -z "$app_name" ]] || [[ -z "$remaining_time" ]]; then
        log_error "App name and remaining time are required"
        return 1
    fi
    
    show_simple_warning "MindfulAccess Warning" "Your access to $app_name will expire in $remaining_time."
}

# Show access notification
show_access_notification() {
    local app_name="$1"
    local duration="$2"
    
    # Validate input
    if [[ -z "$app_name" ]] || [[ -z "$duration" ]]; then
        log_error "App name and duration are required"
        return 1
    fi
    
    # Show notification
    osascript -e "display notification \"Access granted for $duration\" ¬
        with title \"MindfulAccess\" ¬
        subtitle \"$app_name\""
}

# Show access granted dialog
show_access_granted() {
    local app_name="$1"
    local duration="$2"
    
    # Validate input
    if [[ -z "$app_name" ]] || [[ -z "$duration" ]]; then
        log_error "App name and duration are required"
        return 1
    fi
    
    # Show dialog
    osascript -e "tell application \"System Events\"
        display dialog \"Access granted to $app_name for $duration.\" ¬
            buttons {\"OK\"} ¬
            default button \"OK\" ¬
            with title \"MindfulAccess\"
    end tell"
}

# Show access denied notification
# Arguments:
#   $1: Application name
#   $2: Reason
show_access_denied() {
    local app_name=$1
    local reason=$2
    
    log_debug "Showing access denied notification for $app_name: $reason"
    
    osascript -e "
        tell application \"System Events\"
            display notification \"$reason\" with title \"MindfulAccess\" subtitle \"$app_name Access Denied\"
        end tell" 2>/dev/null
}

# Show shutdown warning
# Arguments:
#   $1: Application name
#   $2: Minutes remaining
show_shutdown_warning() {
    local app_name=$1
    local minutes=$2
    
    log_debug "Showing shutdown warning for $app_name ($minutes minutes remaining)"
    
    osascript -e "
        tell application \"System Events\"
            display notification \"$app_name will close in $minutes minutes\" with title \"MindfulAccess Warning\"
        end tell" 2>/dev/null
}

# Show configuration dialog
show_config_dialog() {
    local current_config
    current_config="Current Configuration:\n\n"
    current_config+="Protected Apps: $(format_app_list "$CONFIG_APPS")\n"
    current_config+="Time Window: $(format_time_window "$CONFIG_START_HOUR" "$CONFIG_END_HOUR")\n"
    current_config+="Access Duration: $CONFIG_ACCESS_DURATION minutes\n"
    current_config+="String Length: $CONFIG_STRING_LENGTH characters\n\n"
    current_config+="Choose an option to modify:"

    osascript -e "
        tell application \"System Events\"
            activate
            set configOptions to {\"Edit Protected Apps\", \"Edit Time Window\", \"Edit Access Duration\", \"Edit String Settings\", \"Done\"}
            choose from list configOptions with prompt \"$current_config\" with title \"MindfulAccess Configuration\"
        end tell" 2>/dev/null
}

# Handle access duration dialog
handle_duration_dialog() {
    local result
    result=$(osascript -e "
        tell application \"System Events\"
            display dialog \"Enter access duration in minutes (1-480):\" ¬
                default answer \"$CONFIG_ACCESS_DURATION\" ¬
                buttons {\"Cancel\", \"OK\"} ¬
                default button \"OK\" ¬
                with title \"Edit Access Duration\"
        end tell" 2>/dev/null)
    
    if [[ "$result" == *"button returned:OK"* ]]; then
        local duration
        duration=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$duration" =~ ^[0-9]+$ ]] && (( duration >= 1 && duration <= 480 )); then
            if save_config "$CONFIG_START_HOUR" "$CONFIG_END_HOUR" "$CONFIG_STRING_LENGTH" "$duration" "$CONFIG_APPS"; then
                get_config
                show_success "Access duration updated to $duration minutes"
                return 0
            else
                log_error "Failed to save configuration"
                return 1
            fi
        else
            show_simple_warning "Invalid Duration" "Please enter a number between 1 and 480 minutes."
            return 1
        fi
    fi
    return 0
}

# Configure app
configure_app() {
    local result
    local dialog_state="$STATE_MAIN"
    
    # Initialize configuration first
    init_config
    get_config
    
    while true; do
        case "$dialog_state" in
            "$STATE_MAIN")
                result=$(show_config_dialog)
                if [[ "$result" == "false" ]]; then
                    return 0
                fi
                
                case "$result" in
                    "Edit Protected Apps")
                        dialog_state="$STATE_APPS"
                        ;;
                    "Edit Time Window")
                        dialog_state="$STATE_TIME"
                        ;;
                    "Edit Access Duration")
                        dialog_state="$STATE_DURATION"
                        ;;
                    "Edit String Settings")
                        dialog_state="$STATE_SETTINGS"
                        ;;
                    "Done")
                        show_success "Configuration complete"
                        return 0
                        ;;
                    *)
                        log_error "Invalid menu option"
                        return 1
                        ;;
                esac
                ;;
                
            "$STATE_APPS")
                handle_apps_dialog
                dialog_state="$STATE_MAIN"
                ;;
                
            "$STATE_TIME")
                handle_time_dialog
                dialog_state="$STATE_MAIN"
                ;;

            "$STATE_DURATION")
                handle_duration_dialog
                dialog_state="$STATE_MAIN"
                ;;
                
            "$STATE_SETTINGS")
                handle_settings_dialog
                dialog_state="$STATE_MAIN"
                ;;
                
            *)
                log_error "Invalid dialog state"
                return 1
                ;;
        esac
    done
}

# Test the dialogs (if script is run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Enable debug output for testing
    DEBUG=true
    
    test_app="Safari"
    test_string="ABC123"
    
    log_info "Testing verification dialog"
    if show_verification_dialog "$test_app" "$test_string"; then
        show_access_granted "$test_app" 30
    else
        show_access_denied "$test_app" "Verification failed"
    fi
    
    log_info "Testing shutdown warning"
    show_shutdown_warning "$test_app" 2
fi 
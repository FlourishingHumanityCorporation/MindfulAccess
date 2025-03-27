#!/bin/bash

# Configuration interface for MindfulAccess
# Provides AppleScript-based UI for managing settings

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Source dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"
source "$MINDFULACCESS_ROOT/src/ui/constants.sh"
source "$MINDFULACCESS_ROOT/src/ui/format_utils.sh"
source "$MINDFULACCESS_ROOT/src/ui/dialog_handlers.sh"

# Show current configuration
show_current_config() {
    get_config
    
    echo "Current MindfulAccess Configuration:"
    echo "-----------------------------------"
    echo "Protected Applications: $(format_app_list "$CONFIG_APPS")"
    echo "Time Window: $(format_time_window "$CONFIG_START_HOUR" "$CONFIG_END_HOUR")"
    echo "Verification String Length: $CONFIG_STRING_LENGTH characters"
    echo "Access Duration: $CONFIG_ACCESS_DURATION minutes"
}

# Show main configuration menu
show_main_menu() {
    local current_config
    current_config="Current Configuration:\n\n"
    current_config+="Protected Apps: $(format_app_list "$CONFIG_APPS")\n"
    current_config+="Time Window: $(format_time_window "$CONFIG_START_HOUR" "$CONFIG_END_HOUR")\n"
    current_config+="String Length: $CONFIG_STRING_LENGTH characters\n"
    current_config+="Access Duration: $CONFIG_ACCESS_DURATION minutes\n\n"
    current_config+="Choose an option to modify:"

    osascript -e "
        tell application \"System Events\"
            activate
            set configOptions to {\"$MENU_APPS\", \"$MENU_TIME\", \"$MENU_DURATION\", \"$MENU_SETTINGS\", \"$MENU_TEST\", \"$MENU_DONE\"}
            choose from list configOptions with prompt \"$current_config\" with title \"$TITLE_CONFIG\"
        end tell" 2>/dev/null
}

# Handle protected apps dialog
handle_apps_dialog() {
    local result
    result=$(osascript -e "
        tell application \"System Events\"
            display dialog \"Enter protected application names (comma-separated):\" default answer \"$(format_app_list "$CONFIG_APPS")\" with title \"Edit Protected Apps\"
        end tell" 2>/dev/null)
    
    if [[ "$result" == *"button returned:OK"* ]]; then
        local apps
        apps=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ -n "$apps" ]]; then
            if save_config "$CONFIG_START_HOUR" "$CONFIG_END_HOUR" "$CONFIG_STRING_LENGTH" "$CONFIG_ACCESS_DURATION" "$apps"; then
                get_config
                show_success "Protected applications updated successfully"
                return 0
            else
                log_error "Failed to save configuration"
                return 1
            fi
        else
            log_error "Invalid app list format"
            return 1
        fi
    fi
    return 0
}

# Handle time window dialog
handle_time_dialog() {
    local result start_hour end_hour

    # Get start hour
    result=$(osascript -e "
        tell application \"System Events\"
            display dialog \"Enter start hour (0-23):\" default answer \"$CONFIG_START_HOUR\" with title \"Edit Start Hour\"
        end tell" 2>/dev/null)
    
    if [[ "$result" == *"button returned:OK"* ]]; then
        start_hour=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$start_hour" =~ ^[0-9]+$ ]] && (( start_hour >= 0 && start_hour <= 23 )); then
            # Get end hour
            result=$(osascript -e "
                tell application \"System Events\"
                    display dialog \"Enter end hour (0-23):\" default answer \"$CONFIG_END_HOUR\" with title \"Edit End Hour\"
                end tell" 2>/dev/null)
            
            if [[ "$result" == *"button returned:OK"* ]]; then
                end_hour=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
                if [[ "$end_hour" =~ ^[0-9]+$ ]] && (( end_hour >= 0 && end_hour <= 23 )); then
                    if save_config "$start_hour" "$end_hour" "$CONFIG_STRING_LENGTH" "$CONFIG_ACCESS_DURATION" "$CONFIG_APPS"; then
                        get_config
                        show_success "Time window updated successfully"
                        return 0
                    else
                        log_error "Failed to save configuration"
                        return 1
                    fi
                fi
            fi
        fi
    fi
    return 0
}

# Handle string settings dialog
handle_settings_dialog() {
    local result string_length
    result=$(osascript -e "
        tell application \"System Events\"
            display dialog \"Enter verification string length (5-64):\" default answer \"$CONFIG_STRING_LENGTH\" with title \"Edit String Length\"
        end tell" 2>/dev/null)
    
    if [[ "$result" == *"button returned:OK"* ]]; then
        string_length=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$string_length" =~ ^[0-9]+$ ]] && (( string_length >= 5 && string_length <= 64 )); then
            if save_config "$CONFIG_START_HOUR" "$CONFIG_END_HOUR" "$string_length" "$CONFIG_ACCESS_DURATION" "$CONFIG_APPS"; then
                get_config
                show_success "String length updated successfully"
                return 0
            else
                log_error "Failed to save configuration"
                return 1
            fi
        else
            show_simple_warning "Invalid Length" "Please enter a number between 5 and 64 characters."
            return 1
        fi
    fi
    return 0
}

# Handle access duration dialog
handle_duration_dialog() {
    local result duration
    result=$(osascript -e "
        tell application \"System Events\"
            display dialog \"Enter access duration in minutes (1-480):\" default answer \"$CONFIG_ACCESS_DURATION\" with title \"Edit Access Duration\"
        end tell" 2>/dev/null)
    
    if [[ "$result" == *"button returned:OK"* ]]; then
        duration=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$duration" =~ ^[0-9]+$ ]] && (( duration >= 1 && duration <= 480 )); then
            if save_config "$CONFIG_START_HOUR" "$CONFIG_END_HOUR" "$CONFIG_STRING_LENGTH" "$duration" "$CONFIG_APPS"; then
                get_config
                show_success "Access duration updated successfully"
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

# Handle test configuration
handle_test_config() {
    # Generate a test verification string
    local test_string
    test_string=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$CONFIG_STRING_LENGTH")
    
    if [[ -z "$test_string" ]]; then
        # Fallback method if tr fails
        test_string="TEST$(date +%s)"
    fi
    
    # Show test dialog
    show_simple_warning "$TITLE_TEST" "We will now test the configuration with:\n\nVerification String: $test_string\nAccess Duration: $CONFIG_ACCESS_DURATION minutes\n\nClick OK to start the test."
    
    # Test with Safari as it's usually available on macOS
    local test_app="Safari"
    
    # Try to open Safari
    osascript -e "tell application \"$test_app\" to activate"
    sleep 1
    
    # Show verification dialog
    if show_verification_dialog "$test_app" "$test_string"; then
        show_access_granted "$test_app" "$CONFIG_ACCESS_DURATION"
        
        # Show countdown window
        (
            local end_time=$(($(date +%s) + CONFIG_ACCESS_DURATION * 60))
            while true; do
                local current_time=$(date +%s)
                local remaining_seconds=$((end_time - current_time))
                
                if (( remaining_seconds <= 0 )); then
                    break
                fi
                
                local minutes=$((remaining_seconds / 60))
                local seconds=$((remaining_seconds % 60))
                
                osascript -e "
                    tell application \"System Events\"
                        set timeLeft to \"$minutes:$(printf "%02d" "$seconds")\"
                        display dialog \"Time remaining for $test_app: \" & timeLeft ¬
                            buttons {\"Close\"} ¬
                            default button \"Close\" ¬
                            with title \"$TITLE_TEST\" ¬
                            giving up after 1
                    end tell" 2>/dev/null || break
                
                sleep 1
            done
        ) &
        
        show_simple_warning "$TITLE_TEST" "Test successful! The app will close in $CONFIG_ACCESS_DURATION minutes.\n\nA countdown window will show the remaining time."
    else
        show_access_denied "$test_app" "Test verification cancelled"
        show_simple_warning "$TITLE_TEST" "Test cancelled. You can try again by selecting Test Config from the menu."
    fi
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
                result=$(show_main_menu)
                if [[ "$result" == "false" ]]; then
                    return 0
                fi
                
                case "$result" in
                    "$MENU_APPS")
                        dialog_state="$STATE_APPS"
                        ;;
                    "$MENU_TIME")
                        dialog_state="$STATE_TIME"
                        ;;
                    "$MENU_DURATION")
                        dialog_state="$STATE_DURATION"
                        ;;
                    "$MENU_SETTINGS")
                        dialog_state="$STATE_SETTINGS"
                        ;;
                    "$MENU_TEST")
                        handle_test_config
                        dialog_state="$STATE_MAIN"
                        ;;
                    "$MENU_DONE")
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

# Main entry point
main() {
    show_current_config
    configure_app
}

# Run main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi 
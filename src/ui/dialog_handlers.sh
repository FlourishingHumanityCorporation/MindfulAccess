#!/bin/bash

# Source dependencies
source "$MINDFULACCESS_ROOT/src/ui/constants.sh"
source "$MINDFULACCESS_ROOT/src/ui/format_utils.sh"

# Handle protected apps dialog
handle_apps_dialog() {
    local result
    result=$(osascript -e "
        tell application \"System Events\"
            display dialog \"Enter protected application names (comma-separated):\" default answer \"$(format_app_list "$CONFIG_APPS")\" with title \"$TITLE_APPS\"
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
            display dialog \"Enter start hour (0-23):\" default answer \"$CONFIG_START_HOUR\" with title \"$TITLE_TIME\"
        end tell" 2>/dev/null)
    
    if [[ "$result" == *"button returned:OK"* ]]; then
        start_hour=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$start_hour" =~ ^[0-9]+$ ]] && (( start_hour >= 0 && start_hour <= 23 )); then
            # Get end hour
            result=$(osascript -e "
                tell application \"System Events\"
                    display dialog \"Enter end hour (0-23):\" default answer \"$CONFIG_END_HOUR\" with title \"$TITLE_TIME\"
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
            display dialog \"Enter verification string length (5-64):\" default answer \"$CONFIG_STRING_LENGTH\" with title \"$TITLE_SETTINGS\"
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
            display dialog \"Enter access duration in minutes (1-480):\" default answer \"$CONFIG_ACCESS_DURATION\" with title \"$TITLE_DURATION\"
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
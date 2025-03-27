#!/bin/bash

# Time checking utility for MindfulAccess
# Handles time window validation and formatting

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Source dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"

# Format time in 24-hour format
format_time() {
    local hour=$1
    printf "%02d:00" "$hour"
}

# Format time window for display
format_time_window() {
    if [[ -z "$CONFIG_START_HOUR" ]] || [[ -z "$CONFIG_END_HOUR" ]]; then
        log_error "Start or end hour not set"
        return 1
    fi
    
    if ! [[ "$CONFIG_START_HOUR" =~ ^[0-9]+$ ]] || ! [[ "$CONFIG_END_HOUR" =~ ^[0-9]+$ ]]; then
        log_error "Hour must be a number: $CONFIG_START_HOUR - $CONFIG_END_HOUR"
        return 1
    fi
    
    printf "%02d:00 - %02d:00" "$CONFIG_START_HOUR" "$CONFIG_END_HOUR"
}

# Check if current time is within allowed window
check_time_window() {
    if [[ -z "$CONFIG_START_HOUR" ]] || [[ -z "$CONFIG_END_HOUR" ]]; then
        log_error "Start or end hour not set"
        return 1
    fi
    
    if ! [[ "$CONFIG_START_HOUR" =~ ^[0-9]+$ ]] || ! [[ "$CONFIG_END_HOUR" =~ ^[0-9]+$ ]]; then
        log_error "Hour must be a number: $CONFIG_START_HOUR - $CONFIG_END_HOUR"
        return 1
    fi
    
    local current_hour
    current_hour=$(date +%H)
    current_hour=$((10#$current_hour)) # Force base 10
    
    log_debug "Checking time window: $current_hour is between $CONFIG_START_HOUR and $CONFIG_END_HOUR"
    
    # Return 0 (true) during BLOCK time (when access should be restricted)
    # Return 1 (false) during FREE time (when access should be unrestricted)
    if (( current_hour >= CONFIG_START_HOUR && current_hour < CONFIG_END_HOUR )); then
        log_debug "Time check passed - in block time (access restricted)"
        return 0
    else
        log_debug "Time check failed - outside block time (free access)"
        return 1
    fi
}

# Get remaining minutes in time window
get_time_remaining() {
    if ! check_time_window; then
        echo "0"
        return 1
    fi
    
    local current_hour current_minute
    current_hour=$(date +%H)
    current_minute=$(date +%M)
    current_hour=$((10#$current_hour))
    current_minute=$((10#$current_minute))
    
    local total_minutes_remaining
    total_minutes_remaining=$(( (CONFIG_END_HOUR - current_hour - 1) * 60 + (60 - current_minute) ))
    
    echo "$total_minutes_remaining"
}

# Test the time checker (if script is run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Enable debug output for testing
    DEBUG=true
    
    # Test time window formatting
    CONFIG_START_HOUR=9
    CONFIG_END_HOUR=17
    formatted=$(format_time_window)
    log_info "Formatted time window: $formatted"
    
    # Test time window checking
    if check_time_window; then
        log_info "Current time is within window"
        remaining=$(get_time_remaining)
        log_info "Minutes remaining: $remaining"
    else
        log_info "Current time is outside window"
    fi
fi 
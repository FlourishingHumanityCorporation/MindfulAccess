#!/bin/bash

# Configuration manager for MindfulAccess
# Handles loading, saving, and validating configuration

# Default configuration values
DEFAULT_START_HOUR=9
DEFAULT_END_HOUR=17
DEFAULT_STRING_LENGTH=32
DEFAULT_ACCESS_DURATION=30
DEFAULT_APPS="Safari"

# Configuration paths
if [[ "$TEST_MODE" == "true" ]]; then
    CONFIG_DIR="$TEST_CONFIG_DIR"
    CONFIG_FILE="$TEST_CONFIG_DIR/config"
else
    CONFIG_DIR="$HOME/.config/mindfulaccess"
    CONFIG_FILE="$CONFIG_DIR/config"
fi

# Initialize configuration
init_config() {
    # Create config directory if it doesn't exist
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    # Create default config if it doesn't exist
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << EOF
START_HOUR=$DEFAULT_START_HOUR
END_HOUR=$DEFAULT_END_HOUR
STRING_LENGTH=$DEFAULT_STRING_LENGTH
ACCESS_DURATION=$DEFAULT_ACCESS_DURATION
APPS=($DEFAULT_APPS)
EOF
    fi
}

# Load configuration
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Error: Configuration file not found" >&2
        return 1
    fi
    
    # Read config file line by line to handle array values
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" == \#* ]] && continue
        
        # Remove leading/trailing whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Handle array values
        if [[ "$value" == \(*\) ]]; then
            # Remove parentheses and set as array
            value=${value#\(}
            value=${value%\)}
            eval "$key=($value)"
        else
            # Set as regular variable
            eval "$key=$value"
        fi
    done < "$CONFIG_FILE"
    
    return 0
}

# Save configuration
save_config() {
    local start_hour=$1
    local end_hour=$2
    local string_length=$3
    local access_duration=$4
    local apps=$5
    
    # Validate configuration
    if ! validate_config "$start_hour" "$end_hour" "$string_length" "$access_duration" "$apps"; then
        echo "Error: Invalid configuration values" >&2
        return 1
    fi
    
    # Save to file
    cat > "$CONFIG_FILE" << EOF
START_HOUR=$start_hour
END_HOUR=$end_hour
STRING_LENGTH=$string_length
ACCESS_DURATION=$access_duration
APPS=($apps)
EOF
}

# Get configuration
get_config() {
    # Load current config
    load_config
    
    # Set global variables with defaults if not set
    CONFIG_START_HOUR=${START_HOUR:-$DEFAULT_START_HOUR}
    CONFIG_END_HOUR=${END_HOUR:-$DEFAULT_END_HOUR}
    CONFIG_STRING_LENGTH=${STRING_LENGTH:-$DEFAULT_STRING_LENGTH}
    CONFIG_ACCESS_DURATION=${ACCESS_DURATION:-$DEFAULT_ACCESS_DURATION}
    CONFIG_APPS="${APPS[*]:-$DEFAULT_APPS}"
    
    log_debug "Loaded configuration:"
    log_debug "  Start Hour: $CONFIG_START_HOUR"
    log_debug "  End Hour: $CONFIG_END_HOUR"
    log_debug "  String Length: $CONFIG_STRING_LENGTH"
    log_debug "  Access Duration: $CONFIG_ACCESS_DURATION"
    log_debug "  Apps: $CONFIG_APPS"
}

# Validate configuration
validate_config() {
    local start_hour=$1
    local end_hour=$2
    local string_length=$3
    local access_duration=$4
    local apps=$5
    
    # Validate hours
    if ! [[ "$start_hour" =~ ^[0-9]+$ ]] || (( start_hour < 0 || start_hour > 23 )); then
        return 1
    fi
    if ! [[ "$end_hour" =~ ^[0-9]+$ ]] || (( end_hour < 0 || end_hour > 23 )); then
        return 1
    fi
    if (( start_hour >= end_hour )); then
        return 1
    fi
    
    # Validate string length
    if ! [[ "$string_length" =~ ^[0-9]+$ ]] || (( string_length < 5 || string_length > 64 )); then
        return 1
    fi
    
    # Validate access duration
    if ! [[ "$access_duration" =~ ^[0-9]+$ ]] || (( access_duration < 1 )); then
        return 1
    fi
    
    # Validate apps
    if [[ -z "$apps" ]]; then
        return 1
    fi
    
    return 0
}

# Test the configuration manager (if script is run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_info "Testing configuration manager"
    
    # Test loading configuration
    get_config
    
    log_info "Current configuration:"
    log_info "  Start Hour: $CONFIG_START_HOUR"
    log_info "  End Hour: $CONFIG_END_HOUR"
    log_info "  String Length: $CONFIG_STRING_LENGTH"
    log_info "  Access Duration: $CONFIG_ACCESS_DURATION"
    log_info "  Apps: $CONFIG_APPS"
    
    # Test saving new configuration
    if save_config 9 18 12 15 "Firefox Chrome"; then
        log_info "Test configuration saved successfully"
    else
        log_error "Failed to save test configuration"
        exit 1
    fi
fi 
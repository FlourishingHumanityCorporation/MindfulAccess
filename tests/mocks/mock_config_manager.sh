#!/bin/bash

# Mock configuration manager for testing

# Mock state
declare -A MOCK_CONFIG=(
    ["start_hour"]="9"
    ["end_hour"]="17"
    ["string_length"]="32"
    ["access_duration"]="30"
    ["apps"]="Chrome Firefox"
)

# Mock save_config function
save_config() {
    local start_hour=$1
    local end_hour=$2
    local string_length=$3
    local access_duration=$4
    local apps=$5
    
    MOCK_CONFIG["start_hour"]=$start_hour
    MOCK_CONFIG["end_hour"]=$end_hour
    MOCK_CONFIG["string_length"]=$string_length
    MOCK_CONFIG["access_duration"]=$access_duration
    MOCK_CONFIG["apps"]=$apps
    
    return 0
}

# Mock get_config function
get_config() {
    CONFIG_START_HOUR=${MOCK_CONFIG["start_hour"]}
    CONFIG_END_HOUR=${MOCK_CONFIG["end_hour"]}
    CONFIG_STRING_LENGTH=${MOCK_CONFIG["string_length"]}
    CONFIG_ACCESS_DURATION=${MOCK_CONFIG["access_duration"]}
    CONFIG_APPS=${MOCK_CONFIG["apps"]}
    
    return 0
}

# Mock validate_config function
validate_config() {
    local start_hour=$1
    local end_hour=$2
    local string_length=$3
    local access_duration=$4
    local apps=$5
    
    # Basic validation
    [[ "$start_hour" =~ ^[0-9]+$ ]] || return 1
    [[ "$end_hour" =~ ^[0-9]+$ ]] || return 1
    [[ "$string_length" =~ ^[0-9]+$ ]] || return 1
    [[ "$access_duration" =~ ^[0-9]+$ ]] || return 1
    [[ -n "$apps" ]] || return 1
    
    return 0
}

# Reset mock state
reset_mock_config() {
    MOCK_CONFIG["start_hour"]="9"
    MOCK_CONFIG["end_hour"]="17"
    MOCK_CONFIG["string_length"]="32"
    MOCK_CONFIG["access_duration"]="30"
    MOCK_CONFIG["apps"]="Chrome Firefox"
}

# Initialize mock state
reset_mock_config 
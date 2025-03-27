#!/bin/bash

# Mock logger for testing

# Log storage
declare -a LOG_MESSAGES=()

# Mock logging functions
log_info() {
    LOG_MESSAGES+=("INFO: $*")
}

log_error() {
    LOG_MESSAGES+=("ERROR: $*")
}

log_debug() {
    LOG_MESSAGES+=("DEBUG: $*")
}

# Get all logged messages
get_log_messages() {
    printf '%s\n' "${LOG_MESSAGES[@]}"
}

# Get messages of specific type
get_log_messages_by_type() {
    local type="$1"
    local pattern="^$type: "
    printf '%s\n' "${LOG_MESSAGES[@]}" | grep "$pattern"
}

# Clear log messages
clear_log_messages() {
    LOG_MESSAGES=()
}

# Initialize mock state
clear_log_messages 
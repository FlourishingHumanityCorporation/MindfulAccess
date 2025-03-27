#!/bin/bash

# Logger utility for MindfulAccess
# Provides standardized logging functionality

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Set up log directory
if [[ "$TEST_MODE" == "true" ]]; then
    LOG_DIR="$TEST_LOG_DIR"
else
    LOG_DIR="$HOME/.local/share/mindfulaccess/logs"
fi

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log file path
LOG_FILE="$LOG_DIR/mindfulaccess.log"

# Maximum log file size in bytes (5MB)
MAX_LOG_SIZE=5242880

# Rotate log file if it exceeds maximum size
rotate_log() {
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE") -gt $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "$LOG_FILE.1"
        touch "$LOG_FILE"
        chmod 644 "$LOG_FILE"
    fi
}

# Format timestamp for log entries
format_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Write to log file with level and message
write_log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(format_timestamp)
    
    # Rotate log if needed
    rotate_log
    
    # Write log entry
    printf "[%s] %-5s %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE"
    
    # Also print to stderr for immediate visibility during development
    if [[ "$level" == "ERROR" ]] || [[ "$DEBUG" == "true" ]]; then
        printf "[%s] %-5s %s\n" "$timestamp" "$level" "$message" >&2
    fi
}

# Log info message
log_info() {
    write_log "INFO" "$1"
}

# Log error message
log_error() {
    write_log "ERROR" "$1"
}

# Log debug message
log_debug() {
    if [[ "$DEBUG" == "true" ]]; then
        write_log "DEBUG" "$1"
    fi
}

# Test the logger (if script is run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Enable debug output for testing
    DEBUG=true
    
    log_info "Testing logger"
    log_error "Test error message"
    log_debug "Test debug message"
    
    # Test log rotation
    for i in {1..100}; do
        log_info "Test message $i"
    done
    
    echo "Log file location: $LOG_FILE"
fi 
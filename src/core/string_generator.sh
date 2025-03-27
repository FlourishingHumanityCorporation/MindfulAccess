#!/bin/bash

# String generator utility for MindfulAccess
# Generates random strings for verification

# Get the installation directory from environment
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    echo "Error: MINDFULACCESS_ROOT environment variable not set"
    exit 1
fi

# Source dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"

# Get the directory of the current script
readonly SCRIPT_DIR="${BASH_SOURCE%/*}"

# Validation function for string length
validate_string_length() {
    local length=$1
    
    # Check if length is a number
    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        log_error "String length must be a number"
        return 1
    fi
    
    # Check if length is within reasonable bounds (5-64 characters)
    if (( length < 5 || length > 64 )); then
        log_error "String length must be between 5 and 64 characters"
        return 1
    fi
    
    return 0
}

# Generate a random string of specified length
# Arguments:
#   $1: Length of the string to generate
# Returns:
#   Random string on success, empty string on failure
generate_random_string() {
    local length=$1
    local result=""
    
    # Validate input
    if ! validate_string_length "$length"; then
        return 1
    fi
    
    # Generate random string using /dev/urandom
    # Using a mix of uppercase, lowercase, and numbers for better readability
    result=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length")
    
    if [[ ${#result} -eq "$length" ]]; then
        log_debug "Generated random string of length $length"
        echo "$result"
        return 0
    else
        log_error "Failed to generate random string"
        return 1
    fi
}

# Test the string generation (if script is run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_length=10
    log_info "Testing string generation with length $test_length"
    
    if result=$(generate_random_string "$test_length"); then
        log_info "Generated test string: $result"
    else
        log_error "String generation test failed"
        exit 1
    fi
fi 
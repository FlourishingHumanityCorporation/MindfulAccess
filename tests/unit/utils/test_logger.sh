#!/bin/bash

# Unit tests for logger.sh

# Source test setup
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Source the script under test
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"

# Override log file location for tests
LOG_FILE="$TEST_LOG_DIR/test.log"

# Test log file creation
test_log_file_creation() {
    echo "Testing log file creation..."
    
    # Test log directory creation
    assert_true "[[ -d '$TEST_LOG_DIR' ]]" "Log directory should be created"
    
    # Test log file creation
    log_info "Test message"
    assert_true "[[ -f '$LOG_FILE' ]]" "Log file should be created"
    validate_test_path "$LOG_FILE" || return 1
}

# Test log message format
test_log_message_format() {
    echo "Testing log message format..."
    
    # Validate test directory
    validate_test_path "$LOG_FILE" || return 1
    
    # Clear log file
    > "$LOG_FILE"
    
    # Test info message
    local message="Test info message"
    log_info "$message"
    local log_line=$(tail -n 1 "$LOG_FILE")
    assert_true "[[ '$log_line' =~ .*INFO.*$message ]]" "Info message should be properly formatted"
    
    # Test error message
    message="Test error message"
    log_error "$message"
    log_line=$(tail -n 1 "$LOG_FILE")
    assert_true "[[ '$log_line' =~ .*ERROR.*$message ]]" "Error message should be properly formatted"
    
    # Test debug message
    message="Test debug message"
    log_debug "$message"
    log_line=$(tail -n 1 "$LOG_FILE")
    assert_true "[[ '$log_line' =~ .*DEBUG.*$message ]]" "Debug message should be properly formatted"
}

# Test log rotation
test_log_rotation() {
    echo "Testing log rotation..."
    
    # Validate test directory
    validate_test_path "$LOG_FILE" || return 1
    validate_test_path "${LOG_FILE}.1" || return 1
    
    # Create a large log file
    for i in {1..1000}; do
        log_info "Test message $i"
    done
    
    # Check if log was rotated
    assert_true "[[ -f '${LOG_FILE}.1' ]]" "Log file should be rotated"
}

# Test multi-line messages
test_multiline_messages() {
    echo "Testing multi-line messages..."
    
    # Validate test directory
    validate_test_path "$LOG_FILE" || return 1
    
    # Clear log file
    > "$LOG_FILE"
    
    # Test multi-line message
    local message="Line 1\nLine 2\nLine 3"
    log_info "$message"
    
    # Count lines
    local line_count=$(grep -c "INFO" "$LOG_FILE")
    assert_equals "3" "$line_count" "Multi-line message should create multiple log entries"
}

# Test special characters
test_special_characters() {
    echo "Testing special characters..."
    
    # Validate test directory
    validate_test_path "$LOG_FILE" || return 1
    
    # Clear log file
    > "$LOG_FILE"
    
    # Test message with special characters
    local message="Special chars: !@#$%^&*()_+"
    log_info "$message"
    local log_line=$(tail -n 1 "$LOG_FILE")
    assert_true "[[ '$log_line' =~ .*$message ]]" "Special characters should be handled properly"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "${BASH_SOURCE[0]}"
fi 
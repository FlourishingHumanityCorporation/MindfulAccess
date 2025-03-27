#!/bin/bash

# Unit tests for time_checker.sh

# Source test setup
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Source required dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"

# Mock date command for testing
MOCK_HOUR=9
MOCK_MINUTE=30

date() {
    if [[ "$1" == "+%H" ]]; then
        printf "%02d" "$MOCK_HOUR"
    elif [[ "$1" == "+%M" ]]; then
        printf "%02d" "$MOCK_MINUTE"
    else
        command date "$@"
    fi
}

# Source the script under test
source "$MINDFULACCESS_ROOT/src/core/time_checker.sh"

# Initialize test environment
init_config

# Test time window checking
test_check_time_window() {
    echo "Testing check_time_window function..."
    
    # Test within time window
    CONFIG_START_HOUR=9
    CONFIG_END_HOUR=17
    MOCK_HOUR=10
    assert_true "check_time_window" "Should be within time window"
    
    # Test before time window
    MOCK_HOUR=8
    assert_false "check_time_window" "Should be before time window"
    
    # Test after time window
    MOCK_HOUR=18
    assert_false "check_time_window" "Should be after time window"
    
    # Test at start hour
    MOCK_HOUR=9
    assert_true "check_time_window" "Should be within time window at start hour"
    
    # Test at end hour
    MOCK_HOUR=17
    assert_false "check_time_window" "Should be outside time window at end hour"
}

# Test time window formatting
test_format_time_window() {
    echo "Testing format_time_window function..."
    
    # Test normal time window
    CONFIG_START_HOUR=9
    CONFIG_END_HOUR=17
    local result
    result=$(format_time_window)
    assert_equals "09:00 - 17:00" "$result" "Should format time window correctly"
    
    # Test single-digit hours
    CONFIG_START_HOUR=8
    CONFIG_END_HOUR=16
    result=$(format_time_window)
    assert_equals "08:00 - 16:00" "$result" "Should pad single-digit hours"
    
    # Test midnight to noon
    CONFIG_START_HOUR=0
    CONFIG_END_HOUR=12
    result=$(format_time_window)
    assert_equals "00:00 - 12:00" "$result" "Should handle midnight to noon"
}

# Test time remaining calculation
test_get_time_remaining() {
    echo "Testing get_time_remaining function..."
    
    # Test middle of window
    CONFIG_START_HOUR=9
    CONFIG_END_HOUR=17
    MOCK_HOUR=13
    MOCK_MINUTE=30
    
    local result
    result=$(get_time_remaining)
    assert_equals "210" "$result" "Should calculate remaining minutes correctly"
    
    # Test start of window
    MOCK_HOUR=9
    MOCK_MINUTE=0
    result=$(get_time_remaining)
    assert_equals "480" "$result" "Should calculate full window at start"
    
    # Test near end of window
    MOCK_HOUR=16
    MOCK_MINUTE=45
    result=$(get_time_remaining)
    assert_equals "15" "$result" "Should calculate remaining minutes near end"
    
    # Test outside window (before)
    MOCK_HOUR=8
    MOCK_MINUTE=30
    result=$(get_time_remaining)
    assert_equals "0" "$result" "Should return 0 minutes before window"
    
    # Test outside window (after)
    MOCK_HOUR=18
    MOCK_MINUTE=30
    result=$(get_time_remaining)
    assert_equals "0" "$result" "Should return 0 minutes after window"
}

# Test time window validation
test_validate_time_window() {
    echo "Testing validate_time_window function..."
    
    # Test valid time window
    assert_true "validate_time_window 9 17" "Should accept valid time window"
    
    # Test invalid start hour
    assert_false "validate_time_window 24 17" "Should reject invalid start hour"
    assert_false "validate_time_window -1 17" "Should reject negative start hour"
    
    # Test invalid end hour
    assert_false "validate_time_window 9 24" "Should reject invalid end hour"
    assert_false "validate_time_window 9 -1" "Should reject negative end hour"
    
    # Test start hour after end hour
    assert_false "validate_time_window 17 9" "Should reject start hour after end hour"
    
    # Test same start and end hour
    assert_false "validate_time_window 9 9" "Should reject same start and end hour"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "${BASH_SOURCE[0]}"
fi 
#!/bin/bash

# Integration tests for app_protector.sh

# Source test setup
source "${BASH_SOURCE%/*}/../common/test_setup.sh"

# Source required dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"
source "$MINDFULACCESS_ROOT/src/core/string_generator.sh"
source "$MINDFULACCESS_ROOT/src/core/time_checker.sh"
source "$MINDFULACCESS_ROOT/src/core/app_monitor.sh"
source "$MINDFULACCESS_ROOT/src/ui/dialogs.sh"

# Mock AppleScript responses
MOCK_FRONTMOST_APP="Chrome"
MOCK_RUNNING_APPS=("Chrome" "Firefox" "Safari")
MOCK_DIALOG_RESPONSE="button returned:OK, text returned:teststring123"

# Mock osascript for testing
osascript() {
    if [[ "$*" == *"get name of first process whose frontmost is true"* ]]; then
        echo "$MOCK_FRONTMOST_APP"
        return 0
    elif [[ "$*" == *"get name of every process"* ]]; then
        printf "%s\n" "${MOCK_RUNNING_APPS[@]}"
        return 0
    elif [[ "$*" == *"tell application"*"to quit"* ]]; then
        local app_name=$(echo "$*" | sed -n 's/.*tell application "\([^"]*\).*/\1/p')
        MOCK_RUNNING_APPS=("${MOCK_RUNNING_APPS[@]/$app_name}")
        return 0
    elif [[ "$*" == *"display dialog"* ]]; then
        echo "$MOCK_DIALOG_RESPONSE"
        return 0
    fi
    return 1
}

# Initialize test environment
init_config

# Source the script under test
source "$MINDFULACCESS_ROOT/src/core/app_protector.sh"

# Test complete app protection flow
test_app_protection_flow() {
    echo "Testing complete app protection flow..."
    
    # Set up test configuration
    CONFIG_START_HOUR=9
    CONFIG_END_HOUR=17
    CONFIG_STRING_LENGTH=12
    CONFIG_ACCESS_DURATION=30
    CONFIG_APPS="Chrome Firefox"
    
    # Test within time window
    MOCK_HOUR=10
    MOCK_MINUTE=30
    
    # Test protected app access
    MOCK_FRONTMOST_APP="Chrome"
    MOCK_DIALOG_RESPONSE="button returned:OK, text returned:teststring123"
    
    # Run protection check
    check_app_access
    assert_equals 0 $? "Should allow access with correct verification"
    
    # Test access duration
    sleep 1
    check_app_access
    assert_equals 0 $? "Should maintain access during duration"
    
    # Test outside time window
    MOCK_HOUR=8
    check_app_access
    assert_equals 1 $? "Should deny access outside time window"
    
    # Test unprotected app
    MOCK_FRONTMOST_APP="Safari"
    MOCK_HOUR=10
    check_app_access
    assert_equals 0 $? "Should allow unprotected app access"
}

# Test app shutdown scheduling
test_app_shutdown_scheduling() {
    echo "Testing app shutdown scheduling..."
    
    # Set up test configuration
    CONFIG_ACCESS_DURATION=1
    CONFIG_APPS="Chrome"
    
    # Schedule shutdown
    MOCK_FRONTMOST_APP="Chrome"
    schedule_app_shutdown "Chrome" "$CONFIG_ACCESS_DURATION"
    assert_equals 0 $? "Should schedule shutdown successfully"
    
    # Wait for shutdown
    sleep 2
    
    # Verify app was quit
    is_app_running "Chrome"
    assert_equals 1 $? "App should be quit after duration"
}

# Test configuration changes
test_configuration_changes() {
    echo "Testing configuration changes..."
    
    # Test changing protected apps
    CONFIG_APPS="Chrome"
    MOCK_FRONTMOST_APP="Firefox"
    check_app_access
    assert_equals 0 $? "Should allow access to newly unprotected app"
    
    CONFIG_APPS="Chrome Firefox"
    check_app_access
    assert_equals 1 $? "Should require verification for newly protected app"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "${BASH_SOURCE[0]}"
fi 
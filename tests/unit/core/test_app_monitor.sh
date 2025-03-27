#!/bin/bash

# Unit tests for app_monitor.sh

# Source test setup
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Source required dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"

# Mock AppleScript responses
MOCK_FRONTMOST_APP="Chrome"
MOCK_RUNNING_APPS=("Chrome" "Firefox" "Safari")

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
    fi
    return 1
}

# Source the script under test
source "$MINDFULACCESS_ROOT/src/core/app_monitor.sh"

# Initialize test environment
init_config

# Test getting frontmost app
test_get_frontmost_app() {
    echo "Testing get_frontmost_app function..."
    
    # Test normal case
    MOCK_FRONTMOST_APP="Chrome"
    local result
    result=$(get_frontmost_app)
    assert_equals "Chrome" "$result" "Should get correct frontmost app"
    
    # Test different app
    MOCK_FRONTMOST_APP="Firefox"
    result=$(get_frontmost_app)
    assert_equals "Firefox" "$result" "Should update when frontmost app changes"
}

# Test checking if app is protected
test_is_app_protected() {
    echo "Testing is_app_protected function..."
    
    # Set up protected apps
    PROTECTED_APPS=("Chrome" "Firefox")
    
    # Test protected app
    assert_true "is_app_protected 'Chrome'" "Should identify protected app"
    assert_true "is_app_protected 'Firefox'" "Should identify protected app"
    
    # Test unprotected app
    assert_false "is_app_protected 'Safari'" "Should identify unprotected app"
    assert_false "is_app_protected 'Terminal'" "Should identify unprotected app"
}

# Test getting running apps
test_get_running_apps() {
    echo "Testing get_running_apps function..."
    
    # Set up mock running apps
    MOCK_RUNNING_APPS=("Chrome" "Firefox" "Safari")
    
    # Test getting running apps
    local result
    result=$(get_running_apps)
    assert_equals "Chrome Firefox Safari" "$result" "Should get all running apps"
    
    # Test with different apps
    MOCK_RUNNING_APPS=("Terminal" "Finder")
    result=$(get_running_apps)
    assert_equals "Terminal Finder" "$result" "Should update when running apps change"
}

# Test quitting an app
test_quit_app() {
    echo "Testing quit_app function..."
    
    # Set up mock running apps
    MOCK_RUNNING_APPS=("Chrome" "Firefox" "Safari")
    
    # Test quitting an app
    quit_app "Chrome"
    local result
    result=$(get_running_apps)
    assert_equals "Firefox Safari" "$result" "Should remove quit app from running apps"
    
    # Test quitting another app
    quit_app "Firefox"
    result=$(get_running_apps)
    assert_equals "Safari" "$result" "Should remove second quit app from running apps"
}

# Test quitting all protected apps
test_quit_all_protected_apps() {
    echo "Testing quit_all_protected_apps function..."
    
    # Set up mock running apps and protected apps
    MOCK_RUNNING_APPS=("Chrome" "Firefox" "Safari")
    PROTECTED_APPS=("Chrome" "Firefox")
    
    # Test quitting all protected apps
    quit_all_protected_apps
    local result
    result=$(get_running_apps)
    assert_equals "Safari" "$result" "Should only leave unprotected apps running"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "${BASH_SOURCE[0]}"
fi 
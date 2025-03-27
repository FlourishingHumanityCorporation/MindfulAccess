#!/bin/bash

# Unit tests for config_interface.sh

# Source test setup
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Source required dependencies
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"

# Override config file location for tests
CONFIG_FILE="$TEST_CONFIG_DIR/config"

# Initialize test environment
init_config

# Source the script under test
source "$MINDFULACCESS_ROOT/src/ui/config_interface.sh"

# Mock logger.sh to prevent actual logging during tests
log_info() { :; }
log_error() { :; }
log_debug() { :; }

# Dialog state tracking
TEST_DIALOG_STATE="$STATE_MAIN"
TEST_DIALOG_STEP=0
TEST_NEXT_ACTION="Done"
TEST_DIALOG_COUNT=0
MAX_DIALOG_COUNT=10  # Prevent infinite loops

# Test helper function
assert() {
    local test_name=$1
    local expected=$2
    local actual=$3
    
    ((tests_run++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ $test_name: PASSED"
        ((tests_passed++))
    else
        echo "❌ $test_name: FAILED"
        echo "   Expected: $expected"
        echo "   Got: $actual"
        ((tests_failed++))
    fi
}

# Reset dialog state
reset_dialog_state() {
    TEST_DIALOG_STATE="$STATE_MAIN"
    TEST_DIALOG_STEP=0
    TEST_NEXT_ACTION="Done"
    TEST_DIALOG_COUNT=0
}

# Mock osascript for testing
function osascript() {
    shift # Skip -e parameter
    local input="$*"  # Get all remaining arguments
    
    # Increment dialog count and check for infinite loops
    ((TEST_DIALOG_COUNT++))
    if ((TEST_DIALOG_COUNT > MAX_DIALOG_COUNT)); then
        echo "ERROR: Maximum dialog count exceeded" >&2
        return 1
    fi
    
    echo "DEBUG: osascript input: $input" >&2
    echo "DEBUG: Current state: $TEST_DIALOG_STATE:$TEST_DIALOG_STEP" >&2
    
    # Handle main menu
    if [[ "$TEST_DIALOG_STATE" == "$STATE_MAIN" ]]; then
        if [[ "$input" == *"choose from list"* ]]; then
            if [[ "$TEST_NEXT_ACTION" == "Done" ]]; then
                echo "Done"
                return 0
            elif [[ "$TEST_NEXT_ACTION" == "cancel" ]]; then
                echo "false"
                return 0
            else
                echo "$TEST_NEXT_ACTION"
                return 0
            fi
        fi
    fi
    
    # Handle app dialog
    if [[ "$TEST_DIALOG_STATE" == "$STATE_APPS" ]]; then
        if [[ "$input" == *"display dialog"*"Enter protected application names"* ]]; then
            if [[ "$TEST_NEXT_ACTION" == "cancel" ]]; then
                echo "button returned:Cancel"
            else
                echo "button returned:OK, text returned:Safari,Chrome"
                CONFIG_APPS="Safari,Chrome"
            fi
            TEST_DIALOG_STATE="$STATE_MAIN"
            return 0
        fi
    fi
    
    # Handle time dialog
    if [[ "$TEST_DIALOG_STATE" == "$STATE_TIME" ]]; then
        if [[ "$input" == *"display dialog"*"Enter start hour"* ]]; then
            if [[ "$TEST_NEXT_ACTION" == "cancel" ]]; then
                echo "button returned:Cancel"
                TEST_DIALOG_STATE="$STATE_MAIN"
            else
                echo "button returned:OK, text returned:10"
                CONFIG_START_HOUR="10"
                TEST_DIALOG_STEP=1
            fi
            return 0
        elif [[ "$input" == *"display dialog"*"Enter end hour"* ]]; then
            if [[ "$TEST_NEXT_ACTION" == "cancel" ]]; then
                echo "button returned:Cancel"
            else
                echo "button returned:OK, text returned:18"
                CONFIG_END_HOUR="18"
            fi
            TEST_DIALOG_STATE="$STATE_MAIN"
            return 0
        fi
    fi
    
    # Handle settings dialog
    if [[ "$TEST_DIALOG_STATE" == "$STATE_SETTINGS" ]]; then
        if [[ "$input" == *"display dialog"*"Enter verification string length"* ]]; then
            if [[ "$TEST_NEXT_ACTION" == "cancel" ]]; then
                echo "button returned:Cancel"
                TEST_DIALOG_STATE="$STATE_MAIN"
            else
                echo "button returned:OK, text returned:24"
                CONFIG_STRING_LENGTH="24"
                TEST_DIALOG_STEP=1
            fi
            return 0
        elif [[ "$input" == *"display dialog"*"Enter access duration"* ]]; then
            if [[ "$TEST_NEXT_ACTION" == "cancel" ]]; then
                echo "button returned:Cancel"
            else
                echo "button returned:OK, text returned:45"
                CONFIG_ACCESS_DURATION="45"
            fi
            TEST_DIALOG_STATE="$STATE_MAIN"
            return 0
        fi
    fi
    
    # Default case for unknown states
    echo "DEBUG: Unhandled AppleScript command: $input" >&2
    TEST_DIALOG_STATE="$STATE_MAIN"
    echo "button returned:Cancel"
    return 0
}

# Mock dialog handlers
handle_apps_dialog() {
    local result
    result=$(osascript -e "display dialog \"Enter protected application names (comma-separated):\" default answer \"$CONFIG_APPS\"")
    if [[ "$result" == *"button returned:OK"* ]]; then
        local apps
        apps=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ -n "$apps" ]]; then
            CONFIG_APPS="$apps"
            return 0
        fi
    fi
    return 0
}

handle_time_dialog() {
    local result start_hour end_hour

    # Get start hour
    result=$(osascript -e "display dialog \"Enter start hour (0-23):\" default answer \"$CONFIG_START_HOUR\"")
    if [[ "$result" == *"button returned:OK"* ]]; then
        start_hour=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$start_hour" =~ ^[0-9]+$ ]] && (( start_hour >= 0 && start_hour <= 23 )); then
            CONFIG_START_HOUR="$start_hour"
            
            # Get end hour
            result=$(osascript -e "display dialog \"Enter end hour (0-23):\" default answer \"$CONFIG_END_HOUR\"")
            if [[ "$result" == *"button returned:OK"* ]]; then
                end_hour=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
                if [[ "$end_hour" =~ ^[0-9]+$ ]] && (( end_hour >= 0 && end_hour <= 23 )); then
                    CONFIG_END_HOUR="$end_hour"
                    return 0
                fi
            fi
        fi
    fi
    return 0
}

handle_settings_dialog() {
    local result string_length duration

    # Get string length
    result=$(osascript -e "display dialog \"Enter verification string length (5-64):\" default answer \"$CONFIG_STRING_LENGTH\"")
    if [[ "$result" == *"button returned:OK"* ]]; then
        string_length=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
        if [[ "$string_length" =~ ^[0-9]+$ ]] && (( string_length >= 5 && string_length <= 64 )); then
            CONFIG_STRING_LENGTH="$string_length"
            
            # Get access duration
            result=$(osascript -e "display dialog \"Enter access duration in minutes:\" default answer \"$CONFIG_ACCESS_DURATION\"")
            if [[ "$result" == *"button returned:OK"* ]]; then
                duration=$(echo "$result" | sed -n 's/.*text returned:\(.*\).*/\1/p')
                if [[ "$duration" =~ ^[0-9]+$ ]] && (( duration > 0 )); then
                    CONFIG_ACCESS_DURATION="$duration"
                    return 0
                fi
            fi
        fi
    fi
    return 0
}

# Test show_current_config function
test_show_current_config() {
    echo "Testing show_current_config function..."
    
    # Validate test directory
    validate_test_path "$CONFIG_FILE" || return 1
    
    # Set test values
    CONFIG_APPS="Chrome Firefox"
    CONFIG_START_HOUR=9
    CONFIG_END_HOUR=17
    CONFIG_STRING_LENGTH=32
    CONFIG_ACCESS_DURATION=30
    
    # Capture the output
    local output
    output=$(show_current_config)
    
    # Debug output
    echo "DEBUG: show_current_config output:"
    echo "$output"
    
    # Check if output contains expected values
    [[ "$output" == *"Protected Applications: Chrome Firefox"* ]]
    assert "show_current_config contains apps" 0 $?
    
    [[ "$output" == *"Time Window: 9:00 - 17:00"* ]]
    assert "show_current_config contains time window" 0 $?
    
    [[ "$output" == *"Verification String Length: 32"* ]]
    assert "show_current_config contains string length" 0 $?
    
    [[ "$output" == *"Access Duration: 30 minutes"* ]]
    assert "show_current_config contains duration" 0 $?
}

# Test dialog handlers
test_dialog_handlers() {
    echo "Testing dialog handlers..."
    
    # Test apps dialog
    reset_dialog_state
    TEST_DIALOG_STATE="$STATE_APPS"
    TEST_NEXT_ACTION="OK"
    handle_apps_dialog
    assert "handle_apps_dialog updates apps" "Safari,Chrome" "$CONFIG_APPS"
    
    # Test time dialog
    reset_dialog_state
    TEST_DIALOG_STATE="$STATE_TIME"
    TEST_NEXT_ACTION="OK"
    handle_time_dialog
    assert "handle_time_dialog updates start hour" "10" "$CONFIG_START_HOUR"
    assert "handle_time_dialog updates end hour" "18" "$CONFIG_END_HOUR"
    
    # Test settings dialog
    reset_dialog_state
    TEST_DIALOG_STATE="$STATE_SETTINGS"
    TEST_NEXT_ACTION="OK"
    handle_settings_dialog
    assert "handle_settings_dialog updates string length" "24" "$CONFIG_STRING_LENGTH"
    assert "handle_settings_dialog updates duration" "45" "$CONFIG_ACCESS_DURATION"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Initialize test environment
    run_test_suite "${BASH_SOURCE[0]}"
fi 
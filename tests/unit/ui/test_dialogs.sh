#!/bin/bash
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Debug helper functions
debug_print() {
    local prefix="$1"
    shift
    echo "[DEBUG:$prefix] $*" >&2
}

debug_print_osascript_input() {
    local input="$*"
    debug_print "OSASCRIPT" "Input command: $input"
    echo "$input" | sed 's/^/[DEBUG:OSASCRIPT_CMD] /' >&2
}

debug_print_mock_state() {
    debug_print "MOCK_STATE" "MOCK_VERIFICATION_STRING=$MOCK_VERIFICATION_STRING"
    debug_print "MOCK_STATE" "DIALOG_TIMEOUT=$DIALOG_TIMEOUT"
    debug_print "MOCK_STATE" "MOCK_SHOULD_FAIL=$MOCK_SHOULD_FAIL"
}

# Enhanced mock osascript with debugging
mock_osascript() {
    debug_print_osascript_input "$*"
    debug_print_mock_state
    
    case "$*" in
        *"display dialog"*"verification"*)
            debug_print "MOCK" "Handling verification dialog"
            
            # Extract the default answer if present
            local default_answer=""
            if [[ "$*" =~ default\ answer\ \"([^\"]*)\" ]]; then
                default_answer="${BASH_REMATCH[1]}"
                debug_print "MOCK" "Found default answer: $default_answer"
            fi
            
            if [[ "$MOCK_SHOULD_FAIL" == "true" ]]; then
                debug_print "MOCK" "Mock set to fail verification"
                if [[ "$*" =~ repeat\ 3\ times ]]; then
                    # This is the shake animation part
                    debug_print "MOCK" "Executing shake animation"
                    return 0
                fi
                echo "error:incorrect_code"
                return 1
            fi
            
            # If there's a default answer and it's wrong, trigger shake
            if [[ -n "$default_answer" && "$default_answer" != "$MOCK_VERIFICATION_STRING" ]]; then
                debug_print "MOCK" "Incorrect verification attempt: $default_answer"
                if [[ "$*" =~ repeat\ 3\ times ]]; then
                    # This is the shake animation part
                    debug_print "MOCK" "Executing shake animation"
                    return 0
                fi
                echo "error:incorrect_code"
                return 1
            fi
            
            local response="button returned:Verify, text returned:$MOCK_VERIFICATION_STRING"
            debug_print "MOCK" "Returning verification response: $response"
            echo "$response"
            ;;
        *"display dialog"*"warning"*)
            debug_print "MOCK" "Handling warning dialog"
            echo "button returned:OK"
            ;;
        *"display notification"*)
            debug_print "MOCK" "Handling notification"
            return 0
            ;;
        *"tell application"*"quit"*)
            debug_print "MOCK" "Handling quit command for: $*"
            return 0
            ;;
        *"tell application"*"activate"*)
            debug_print "MOCK" "Handling activate command for: $*"
            return 0
            ;;
        *)
            debug_print "MOCK" "Unhandled command: $*"
            return 1
            ;;
    esac
}

# Enhanced cleanup with debugging
cleanup_test() {
    debug_print "CLEANUP" "Starting cleanup process"
    
    # Kill osascript processes
    local osascript_pids=$(pgrep -f "osascript")
    if [[ -n "$osascript_pids" ]]; then
        debug_print "CLEANUP" "Killing osascript processes: $osascript_pids"
        pkill -f "osascript"
    else
        debug_print "CLEANUP" "No osascript processes found"
    fi
    
    # Close windows
    debug_print "CLEANUP" "Attempting to close windows"
    osascript -e 'tell application "System Events" to keystroke "w" using command down' 2>/dev/null
    
    # Remove aliases
    debug_print "CLEANUP" "Removing aliases"
    unalias osascript 2>/dev/null || true
    
    # Kill background processes
    local bg_jobs=$(jobs -p)
    if [[ -n "$bg_jobs" ]]; then
        debug_print "CLEANUP" "Killing background jobs: $bg_jobs"
        jobs -p | xargs kill -9 2>/dev/null || true
    else
        debug_print "CLEANUP" "No background jobs found"
    fi
    
    debug_print "CLEANUP" "Cleanup complete"
}

# Register cleanup
trap cleanup_test EXIT INT TERM

# Test setup helper
setup_test() {
    local test_name="$1"
    debug_print "SETUP" "Setting up test: $test_name"
    MOCK_SHOULD_FAIL="false"
    export -f mock_osascript
    export -f debug_print
    export -f debug_print_osascript_input
    export -f debug_print_mock_state
    alias osascript=mock_osascript
    debug_print "SETUP" "Test setup complete"
}

# Test teardown helper
teardown_test() {
    local test_name="$1"
    debug_print "TEARDOWN" "Cleaning up test: $test_name"
    unalias osascript 2>/dev/null || true
    unset MOCK_VERIFICATION_STRING
    unset MOCK_SHOULD_FAIL
    debug_print "TEARDOWN" "Test teardown complete"
}

test_verification_dialog() {
    setup_test "verification_dialog"
    debug_print "TEST" "Starting verification dialog test"
    
    # Test successful verification
    debug_print "TEST" "Testing successful verification"
    MOCK_VERIFICATION_STRING="TEST123"
    local result
    result=$(show_verification_dialog "TestApp" "TEST123")
    local status=$?
    debug_print "TEST" "Verification result: $result (status=$status)"
    assert_equals "0" "$status" "Verification dialog should succeed"
    assert_contains "$result" "button returned:Verify" "Dialog should be confirmed"
    assert_contains "$result" "TEST123" "Verification string should match"
    
    # Test incorrect verification with shake
    debug_print "TEST" "Testing incorrect verification with shake"
    MOCK_SHOULD_FAIL="true"
    result=$(show_verification_dialog "TestApp" "TEST123")
    status=$?
    debug_print "TEST" "Failed verification result: $result (status=$status)"
    assert_not_equals "0" "$status" "Verification dialog should fail"
    
    # Test that incorrect attempt is preserved
    debug_print "TEST" "Testing incorrect attempt preservation"
    MOCK_VERIFICATION_STRING="WRONG123"
    result=$(show_verification_dialog "TestApp" "TEST123")
    status=$?
    debug_print "TEST" "Preserved attempt result: $result (status=$status)"
    assert_contains "$result" "WRONG123" "Previous attempt should be preserved"
    
    teardown_test "verification_dialog"
}

test_warning_dialog() {
    setup_test "warning_dialog"
    debug_print "TEST" "Starting warning dialog test"
    
    local result
    result=$(show_warning_dialog "TestApp" "5 minutes")
    local status=$?
    debug_print "TEST" "Warning dialog result: $result (status=$status)"
    assert_equals "0" "$status" "Warning dialog should succeed"
    assert_contains "$result" "button returned:OK" "Warning should be acknowledged"
    
    teardown_test "warning_dialog"
}

test_access_notification() {
    setup_test "access_notification"
    debug_print "TEST" "Starting access notification test"
    
    local result
    result=$(show_access_notification "TestApp" "30 minutes")
    local status=$?
    debug_print "TEST" "Notification result: $result (status=$status)"
    assert_equals "0" "$status" "Notification should succeed"
    
    teardown_test "access_notification"
}

test_dialog_timeouts() {
    setup_test "dialog_timeouts"
    debug_print "TEST" "Starting dialog timeouts test"
    
    DIALOG_TIMEOUT=1
    local start_time=$(date +%s)
    debug_print "TEST" "Starting timeout test at: $start_time"
    
    show_verification_dialog "TestApp" "TEST123"
    local end_time=$(date +%s)
    debug_print "TEST" "Ending timeout test at: $end_time"
    
    local duration=$((end_time - start_time))
    debug_print "TEST" "Test duration: $duration seconds"
    assert_less_than "$duration" "2" "Dialog should timeout within specified time"
    
    teardown_test "dialog_timeouts"
}

test_input_validation() {
    setup_test "input_validation"
    debug_print "TEST" "Starting input validation test"
    
    # Test empty app name
    debug_print "TEST" "Testing empty app name"
    local result
    result=$(show_verification_dialog "" "TEST123" 2>&1)
    local status=$?
    debug_print "TEST" "Empty app name result: $result (status=$status)"
    assert_not_equals "0" "$status" "Empty app name should fail"
    assert_contains "$result" "App name cannot be empty" "Should show error for empty app name"
    
    # Test empty verification string
    debug_print "TEST" "Testing empty verification string"
    result=$(show_verification_dialog "TestApp" "" 2>&1)
    status=$?
    debug_print "TEST" "Empty verification string result: $result (status=$status)"
    assert_not_equals "0" "$status" "Empty verification string should fail"
    assert_contains "$result" "Verification string cannot be empty" "Should show error for empty verification string"
    
    teardown_test "input_validation"
}

test_error_handling() {
    setup_test "error_handling"
    debug_print "TEST" "Starting error handling test"
    
    # Setup failure mode
    MOCK_SHOULD_FAIL="true"
    debug_print "TEST" "Setting mock to fail"
    
    local result
    result=$(show_verification_dialog "TestApp" "TEST123" 2>&1)
    local status=$?
    debug_print "TEST" "Error handling result: $result (status=$status)"
    assert_not_equals "0" "$status" "Should handle dialog failure"
    assert_contains "$result" "Verification failed for TestApp" "Should show error message"
    
    teardown_test "error_handling"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    debug_print "MAIN" "Starting test suite"
    run_test_suite "${BASH_SOURCE[0]}"
    debug_print "MAIN" "Test suite complete"
fi 
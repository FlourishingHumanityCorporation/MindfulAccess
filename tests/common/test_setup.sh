#!/bin/bash

# Common test setup for MindfulAccess tests

# Ensure we're in the project root
if [[ -z "$MINDFULACCESS_ROOT" ]]; then
    export MINDFULACCESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Add test directories to PATH
export PATH="$MINDFULACCESS_ROOT/tests/mocks:$PATH"

# Test environment variables
export TEST_MODE=true
export TEST_TMP_DIR="$MINDFULACCESS_ROOT/tests/tmp"
export TEST_CONFIG_DIR="$TEST_TMP_DIR/config"
export TEST_LOG_DIR="$TEST_TMP_DIR/logs"
export DEBUG=true

# Safety check function
validate_test_path() {
    local path="$1"
    if [[ ! "$path" =~ ^"$TEST_TMP_DIR" ]]; then
        echo "Error: Attempted to access path outside test directory: $path" >&2
        return 1
    fi
    return 0
}

# Safe remove function
safe_remove() {
    local path="$1"
    if validate_test_path "$path"; then
        rm -rf "$path"
    fi
}

# Create test directories
mkdir -p "$TEST_TMP_DIR"
mkdir -p "$TEST_CONFIG_DIR"
mkdir -p "$TEST_LOG_DIR"

# Source common test utilities
source "$MINDFULACCESS_ROOT/tests/common/test_utils.sh"

# Source main scripts
source "$MINDFULACCESS_ROOT/src/core/app_protector.sh"
source "$MINDFULACCESS_ROOT/src/utils/logger.sh"
source "$MINDFULACCESS_ROOT/src/ui/dialogs.sh"

# Test utilities
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output (if not already defined)
if [[ -z "$RED" ]]; then
    RED='\033[0;31m'
fi
if [[ -z "$GREEN" ]]; then
    GREEN='\033[0;32m'
fi
if [[ -z "$YELLOW" ]]; then
    YELLOW='\033[1;33m'
fi
if [[ -z "$NC" ]]; then
    NC='\033[0m'
fi

# Assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected' but got '$actual'}"
    
    ((TEST_COUNT++))
    if [[ "$expected" == "$actual" ]]; then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Expected value to not equal '$unexpected'}"
    
    ((TEST_COUNT++))
    if [[ "$unexpected" != "$actual" ]]; then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  Unexpected: '$unexpected'"
        echo "  Actual:     '$actual'"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' to contain '$needle'}"
    
    ((TEST_COUNT++))
    if [[ "$haystack" == *"$needle"* ]]; then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  String:   '$haystack'"
        echo "  Expected: '$needle'"
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' to not contain '$needle'}"
    
    ((TEST_COUNT++))
    if [[ "$haystack" != *"$needle"* ]]; then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  String:      '$haystack'"
        echo "  Unexpected:  '$needle'"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-Expected file '$file' to exist}"
    
    ((TEST_COUNT++))
    if [[ -f "$file" ]]; then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  File: '$file' does not exist"
        return 1
    fi
}

assert_directory_exists() {
    local directory="$1"
    local message="${2:-Expected directory '$directory' to exist}"
    
    ((TEST_COUNT++))
    if [[ -d "$directory" ]]; then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  Directory: '$directory' does not exist"
        return 1
    fi
}

assert_less_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Expected '$value' to be less than '$threshold'}"
    
    ((TEST_COUNT++))
    if (( value < threshold )); then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  Value:     $value"
        echo "  Threshold: $threshold"
        return 1
    fi
}

assert_greater_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Expected '$value' to be greater than '$threshold'}"
    
    ((TEST_COUNT++))
    if (( value > threshold )); then
        ((PASS_COUNT++))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        ((FAIL_COUNT++))
        echo -e "${RED}✗${NC} $message"
        echo "  Value:     $value"
        echo "  Threshold: $threshold"
        return 1
    fi
}

# Test runner
run_test_suite() {
    local test_file="$1"
    local test_name
    
    echo -e "\n${YELLOW}Running tests from ${test_file##*/}${NC}"
    
    # Find and run all test functions
    for test_function in $(declare -F | cut -d' ' -f3 | grep '^test_'); do
        test_name=${test_function#test_}
        test_name=${test_name//_/ }
        echo -e "\n${YELLOW}Test: $test_name${NC}"
        
        # Run setup if it exists
        if declare -F setup >/dev/null; then
            setup
        fi
        
        # Run the test
        $test_function
        
        # Run teardown if it exists
        if declare -F teardown >/dev/null; then
            teardown
        fi
    done
    
    # Print summary
    echo -e "\n${YELLOW}Test Summary:${NC}"
    echo "Total:  $TEST_COUNT"
    echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
    echo -e "${RED}Failed: $FAIL_COUNT${NC}"
    
    # Return non-zero if any tests failed
    return $((FAIL_COUNT > 0))
}

# Setup test environment
setup_test_environment() {
    # Reset test counters
    reset_test_counters
    
    # Clean up test directories safely
    if [[ -d "$TEST_CONFIG_DIR" ]]; then
        safe_remove "$TEST_CONFIG_DIR"
    fi
    if [[ -d "$TEST_LOG_DIR" ]]; then
        safe_remove "$TEST_LOG_DIR"
    fi
    
    # Create fresh test directories
    mkdir -p "$TEST_CONFIG_DIR"
    mkdir -p "$TEST_LOG_DIR"
    
    # Set up mock environment
    export MOCK_ENABLED=true
}

# Cleanup test environment
cleanup_test_environment() {
    # Clean up test directories safely
    if [[ -d "$TEST_TMP_DIR" ]]; then
        safe_remove "$TEST_TMP_DIR"
    fi
    
    # Reset environment variables
    unset TEST_MODE
    unset TEST_CONFIG_DIR
    unset TEST_LOG_DIR
    unset TEST_TMP_DIR
    unset MOCK_ENABLED
}

# Register cleanup
trap cleanup_test_environment EXIT 
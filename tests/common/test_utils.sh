#!/bin/bash

# Common test utilities for MindfulAccess tests

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Assert equals with message
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✅ $message: PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ $message: FAILED${NC}"
        echo -e "${RED}   Expected: $expected${NC}"
        echo -e "${RED}   Got: $actual${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert true with message
assert_true() {
    local condition="$1"
    local message="$2"
    
    ((TESTS_RUN++))
    
    if eval "$condition"; then
        echo -e "${GREEN}✅ $message: PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ $message: FAILED${NC}"
        echo -e "${RED}   Expected true but got false${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert false with message
assert_false() {
    local condition="$1"
    local message="$2"
    
    ((TESTS_RUN++))
    
    if ! eval "$condition"; then
        echo -e "${GREEN}✅ $message: PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ $message: FAILED${NC}"
        echo -e "${RED}   Expected false but got true${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Print test summary
print_test_summary() {
    local test_file="$1"
    echo "----------------------------------------"
    echo "Test Summary for $test_file:"
    echo "Tests Run: $TESTS_RUN"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo "----------------------------------------"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed! 🎉${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed! 😢${NC}"
        return 1
    fi
}

# Reset test counters
reset_test_counters() {
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
}

# Run a test suite
run_test_suite() {
    local test_file="$1"
    echo "Running tests in $test_file..."
    echo "----------------------------------------"
    
    # Find and run all test functions
    for test_func in $(declare -F | cut -d' ' -f3 | grep '^test_'); do
        echo "Running $test_func..."
        $test_func
    done
    
    print_test_summary "$test_file"
} 
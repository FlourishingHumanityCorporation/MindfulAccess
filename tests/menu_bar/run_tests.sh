#!/bin/bash

# Create test directory
TEST_DIR="/tmp/mindfulaccess_tests"
mkdir -p "$TEST_DIR"

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Run a single test
run_test() {
    local test_name="$1"
    local test_script="$2"
    echo -n "Running test: $test_name... "
    
    # Run the test and capture output
    result=$(osascript "$test_script" 2>&1)
    status=$?
    
    # Save output to log
    echo "$result" > "$TEST_DIR/${test_name}.log"
    
    # Display result
    if [[ "$result" == *"✅"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        echo "$result"
    else
        echo -e "${RED}FAIL${NC}"
        echo "$result"
    fi
    echo "----------------------------------------"
}

# Clear previous test results
rm -f "$TEST_DIR"/*.log

# Run all tests
for test_script in "$SCRIPT_DIR"/test_*.scpt; do
    if [[ -f "$test_script" ]]; then
        run_test "$(basename "$test_script" .scpt)" "$test_script"
    fi
done

# Summary
echo "Test logs saved in $TEST_DIR" 
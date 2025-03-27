#!/bin/bash

# Unit tests for string_generator.sh

# Source test setup
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Source the script under test
source "$MINDFULACCESS_ROOT/src/core/string_generator.sh"

# Test string generation
test_generate_random_string() {
    echo "Testing random string generation..."
    
    # Test default length
    local result
    result=$(generate_random_string)
    assert_equals "32" "${#result}" "Default string length should be 32"
    
    # Test custom length
    local custom_length=16
    result=$(generate_random_string "$custom_length")
    assert_equals "$custom_length" "${#result}" "Custom string length should be $custom_length"
    
    # Test string content format
    [[ "$result" =~ ^[A-Za-z0-9]+$ ]]
    assert_equals "0" "$?" "String should only contain alphanumeric characters"
    
    # Test uniqueness
    local str1 str2
    str1=$(generate_random_string)
    str2=$(generate_random_string)
    assert_false "[[ '$str1' == '$str2' ]]" "Generated strings should be unique"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "${BASH_SOURCE[0]}"
fi 
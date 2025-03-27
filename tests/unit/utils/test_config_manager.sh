#!/bin/bash

# Unit tests for config_manager.sh

# Source test setup
source "${BASH_SOURCE%/*}/../../common/test_setup.sh"

# Source the script under test
source "$MINDFULACCESS_ROOT/src/utils/config_manager.sh"

# Override config file location for tests
CONFIG_FILE="$TEST_CONFIG_DIR/config"

# Test configuration initialization
test_init_config() {
    echo "Testing config initialization..."
    
    # Test default config creation
    init_config
    assert_true "[[ -f '$CONFIG_FILE' ]]" "Config file should be created"
    validate_test_path "$CONFIG_FILE" || return 1
    
    # Test default values
    source "$CONFIG_FILE"
    assert_equals "$DEFAULT_START_HOUR" "$START_HOUR" "Default start hour should be set"
    assert_equals "$DEFAULT_END_HOUR" "$END_HOUR" "Default end hour should be set"
    assert_equals "$DEFAULT_STRING_LENGTH" "$STRING_LENGTH" "Default string length should be set"
    assert_equals "$DEFAULT_ACCESS_DURATION" "$ACCESS_DURATION" "Default access duration should be set"
}

# Test configuration loading
test_load_config() {
    echo "Testing config loading..."
    
    # Validate test directory
    validate_test_path "$CONFIG_FILE" || return 1
    
    # Create test config
    cat > "$CONFIG_FILE" << EOF
START_HOUR=10
END_HOUR=18
STRING_LENGTH=24
ACCESS_DURATION=45
APPS=(Chrome Firefox)
EOF
    
    # Test loading
    load_config
    assert_equals "10" "$START_HOUR" "Start hour should be loaded"
    assert_equals "18" "$END_HOUR" "End hour should be loaded"
    assert_equals "24" "$STRING_LENGTH" "String length should be loaded"
    assert_equals "45" "$ACCESS_DURATION" "Access duration should be loaded"
    assert_equals "Chrome Firefox" "${APPS[*]}" "Apps should be loaded"
}

# Test configuration saving
test_save_config() {
    echo "Testing config saving..."
    
    # Validate test directory
    validate_test_path "$CONFIG_FILE" || return 1
    
    # Test saving new values
    save_config "9" "17" "32" "30" "Safari Chrome"
    
    # Verify saved values
    source "$CONFIG_FILE"
    assert_equals "9" "$START_HOUR" "Start hour should be saved"
    assert_equals "17" "$END_HOUR" "End hour should be saved"
    assert_equals "32" "$STRING_LENGTH" "String length should be saved"
    assert_equals "30" "$ACCESS_DURATION" "Access duration should be saved"
    assert_equals "Safari Chrome" "${APPS[*]}" "Apps should be saved"
}

# Test configuration validation
test_validate_config() {
    echo "Testing config validation..."
    
    # Test valid configuration
    assert_true "validate_config 9 17 32 30 'Chrome Firefox'" "Valid config should pass validation"
    
    # Test invalid hours
    assert_false "validate_config 24 17 32 30 'Chrome Firefox'" "Invalid start hour should fail"
    assert_false "validate_config 9 24 32 30 'Chrome Firefox'" "Invalid end hour should fail"
    
    # Test invalid string length
    assert_false "validate_config 9 17 4 30 'Chrome Firefox'" "String length too short should fail"
    assert_false "validate_config 9 17 65 30 'Chrome Firefox'" "String length too long should fail"
    
    # Test invalid duration
    assert_false "validate_config 9 17 32 0 'Chrome Firefox'" "Zero duration should fail"
    assert_false "validate_config 9 17 32 -1 'Chrome Firefox'" "Negative duration should fail"
    
    # Test invalid apps
    assert_false "validate_config 9 17 32 30 ''" "Empty apps should fail"
}

# Test get_config function
test_get_config() {
    echo "Testing get_config function..."
    
    # Validate test directory
    validate_test_path "$CONFIG_FILE" || return 1
    
    # Set up test values
    cat > "$CONFIG_FILE" << EOF
START_HOUR=10
END_HOUR=18
STRING_LENGTH=24
ACCESS_DURATION=45
APPS=(Chrome Firefox)
EOF
    
    # Test getting config
    get_config
    assert_equals "10" "$CONFIG_START_HOUR" "CONFIG_START_HOUR should be set"
    assert_equals "18" "$CONFIG_END_HOUR" "CONFIG_END_HOUR should be set"
    assert_equals "24" "$CONFIG_STRING_LENGTH" "CONFIG_STRING_LENGTH should be set"
    assert_equals "45" "$CONFIG_ACCESS_DURATION" "CONFIG_ACCESS_DURATION should be set"
    assert_equals "Chrome Firefox" "$CONFIG_APPS" "CONFIG_APPS should be set"
}

# Run tests if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "${BASH_SOURCE[0]}"
fi 
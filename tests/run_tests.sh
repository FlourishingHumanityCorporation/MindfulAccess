#!/bin/bash

# Set up environment
export MINDFULACCESS_ROOT="${BASH_SOURCE%/*}/.."
source "$MINDFULACCESS_ROOT/tests/common/test_setup.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test categories
UNIT_TESTS=(
    "tests/unit/core/test_app_monitor.sh"
    "tests/unit/core/test_time_checker.sh"
    "tests/unit/core/test_string_generator.sh"
    "tests/unit/ui/test_dialogs.sh"
    "tests/unit/ui/test_config_interface.sh"
    "tests/unit/utils/test_config_manager.sh"
    "tests/unit/utils/test_logger.sh"
)

INTEGRATION_TESTS=(
    "tests/integration/test_app_protector.sh"
)

PERFORMANCE_TESTS=(
    "tests/performance/test_response_times.sh"
    "tests/performance/test_resource_usage.sh"
    "tests/performance/test_scalability.sh"
)

SECURITY_TESTS=(
    "tests/security/test_input_validation.sh"
    "tests/security/test_file_security.sh"
    "tests/security/test_state_protection.sh"
)

# Function to run a test file
run_test_file() {
    local test_file="$1"
    if [[ -f "$test_file" ]]; then
        echo -e "\n${YELLOW}Running $test_file${NC}"
        if bash "$test_file"; then
            echo -e "${GREEN}✓ $test_file passed${NC}"
            return 0
        else
            echo -e "${RED}✗ $test_file failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}Test file not found: $test_file${NC}"
        return 1
    fi
}

# Function to run a category of tests
run_test_category() {
    local category=("$@")
    local failed=0
    
    for test_file in "${category[@]}"; do
        if ! run_test_file "$test_file"; then
            ((failed++))
        fi
    done
    
    return $failed
}

# Parse command line arguments
UNIT=false
INTEGRATION=false
PERFORMANCE=false
SECURITY=false
CHANGED=false
SPECIFIC_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --unit)
            UNIT=true
            shift
            ;;
        --integration)
            INTEGRATION=true
            shift
            ;;
        --performance)
            PERFORMANCE=true
            shift
            ;;
        --security)
            SECURITY=true
            shift
            ;;
        --changed)
            CHANGED=true
            shift
            ;;
        --file)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run tests based on arguments
FAILED=0

if [[ -n "$SPECIFIC_FILE" ]]; then
    # Run specific file
    if ! run_test_file "$SPECIFIC_FILE"; then
        ((FAILED++))
    fi
elif [[ "$CHANGED" = true ]]; then
    # Run tests for changed files
    CHANGED_FILES=$(git diff --name-only HEAD)
    for file in $CHANGED_FILES; do
        if [[ "$file" == tests/* ]] && [[ "$file" == *.sh ]]; then
            if ! run_test_file "$file"; then
                ((FAILED++))
            fi
        elif [[ "$file" == src/* ]]; then
            # Find corresponding test file
            test_file="tests/unit/${file#src/}"
            test_file="${test_file%.sh}_test.sh"
            if [[ -f "$test_file" ]]; then
                if ! run_test_file "$test_file"; then
                    ((FAILED++))
                fi
            fi
        fi
    done
else
    # Run categories based on flags or all if no flags
    if [[ "$UNIT" = true ]] || [[ "$INTEGRATION" = false && "$PERFORMANCE" = false && "$SECURITY" = false ]]; then
        echo -e "\n${YELLOW}Running Unit Tests${NC}"
        if ! run_test_category "${UNIT_TESTS[@]}"; then
            ((FAILED++))
        fi
    fi
    
    if [[ "$INTEGRATION" = true ]] || [[ "$UNIT" = false && "$PERFORMANCE" = false && "$SECURITY" = false ]]; then
        echo -e "\n${YELLOW}Running Integration Tests${NC}"
        if ! run_test_category "${INTEGRATION_TESTS[@]}"; then
            ((FAILED++))
        fi
    fi
    
    if [[ "$PERFORMANCE" = true ]]; then
        echo -e "\n${YELLOW}Running Performance Tests${NC}"
        if ! run_test_category "${PERFORMANCE_TESTS[@]}"; then
            ((FAILED++))
        fi
    fi
    
    if [[ "$SECURITY" = true ]]; then
        echo -e "\n${YELLOW}Running Security Tests${NC}"
        if ! run_test_category "${SECURITY_TESTS[@]}"; then
            ((FAILED++))
        fi
    fi
fi

# Print summary
echo -e "\n${YELLOW}Test Summary${NC}"
if [[ "$FAILED" -eq 0 ]]; then
    echo -e "${GREEN}All tests passed${NC}"
else
    echo -e "${RED}$FAILED test suites failed${NC}"
fi

exit $FAILED 
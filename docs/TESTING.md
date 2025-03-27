# MindfulAccess Testing Guide

## Testing Infrastructure

### Directory Structure
```
tests/
├── unit/                 # Unit tests
│   ├── core/            # Core component tests
│   ├── ui/              # UI component tests
│   └── utils/           # Utility tests
├── integration/         # Integration tests
├── e2e/                 # End-to-end tests
├── performance/         # Performance tests
├── security/           # Security tests
├── common/             # Common test utilities
├── mocks/              # Mock implementations
└── fixtures/           # Test fixtures
```

### Test Categories

1. **Unit Tests**
   - Individual function testing
   - Isolated component behavior
   - Mock external dependencies

2. **Integration Tests**
   - Component interaction
   - Subsystem functionality
   - Real dependency usage

3. **End-to-End Tests**
   - Complete workflows
   - User scenarios
   - System integration

4. **Performance Tests**
   - Response time
   - Resource usage
   - Scalability

5. **Security Tests**
   - Input validation
   - File permissions
   - State protection

## Test Coverage Plan

### Core Components

1. **App Protector (`test_app_protector.sh`)**
   - [x] Basic app protection flow
   - [x] App shutdown scheduling
   - [x] Configuration changes
   - [ ] Multiple app protection
   - [ ] Concurrent access handling
   - [ ] State recovery
   - [ ] Error handling

2. **App Monitor (`test_app_monitor.sh`)**
   - [x] Frontmost app detection
   - [x] Protected app checking
   - [x] App quitting
   - [ ] Process name variations
   - [ ] App relaunch prevention
   - [ ] Background app handling

3. **Time Checker (`test_time_checker.sh`)**
   - [x] Time window validation
   - [x] Time formatting
   - [x] Remaining time calculation
   - [ ] Timezone handling
   - [ ] Date rollover
   - [ ] DST transitions

4. **String Generator (`test_string_generator.sh`)**
   - [x] Random string generation
   - [x] Length validation
   - [x] Character set validation
   - [ ] Distribution testing
   - [ ] Performance benchmarks
   - [ ] Memory usage

### UI Components

1. **Dialogs (`test_dialogs.sh`)**
   - [ ] Verification dialog
   - [ ] Access notifications
   - [ ] Warning messages
   - [ ] Dialog timeouts
   - [ ] Input validation
   - [ ] Error handling

2. **Config Interface (`test_config_interface.sh`)**
   - [x] Configuration display
   - [x] Settings validation
   - [x] Dialog handling
   - [ ] Input sanitization
   - [ ] Cancel operations
   - [ ] Error messages

### Utilities

1. **Config Manager (`test_config_manager.sh`)**
   - [x] Configuration loading
   - [x] Configuration saving
   - [x] Validation
   - [ ] File permissions
   - [ ] Corrupt config handling
   - [ ] Default fallbacks

2. **Logger (`test_logger.sh`)**
   - [x] Log file creation
   - [x] Message formatting
   - [x] Log rotation
   - [ ] Concurrent writing
   - [ ] Error recovery
   - [ ] Performance impact

## Test Scenarios

### End-to-End Workflows

1. **First-Time Setup**
   ```bash
   test_first_time_setup() {
       # Test initial configuration
       # Verify directory creation
       # Check default settings
   }
   ```

2. **Normal Usage Flow**
   ```bash
   test_normal_usage() {
       # Configure protected apps
       # Open protected app
       # Verify and grant access
       # Check duration enforcement
   }
   ```

3. **Configuration Changes**
   ```bash
   test_config_changes() {
       # Modify settings
       # Verify immediate effect
       # Test persistence
   }
   ```

### Error Scenarios

1. **Invalid Configuration**
   ```bash
   test_invalid_config() {
       # Test invalid time windows
       # Test invalid app names
       # Test corrupt config file
   }
   ```

2. **System Issues**
   ```bash
   test_system_issues() {
       # Test permission problems
       # Test disk space issues
       # Test process failures
   }
   ```

3. **User Errors**
   ```bash
   test_user_errors() {
       # Test invalid verification
       # Test dialog cancellation
       # Test rapid app switching
   }
   ```

## Performance Testing

### Response Time Tests
```bash
test_response_times() {
    # Measure app detection time
    # Measure verification dialog display
    # Measure configuration loading
}
```

### Resource Usage Tests
```bash
test_resource_usage() {
    # Monitor CPU usage
    # Track memory consumption
    # Check disk I/O
}
```

### Scalability Tests
```bash
test_scalability() {
    # Test with many protected apps
    # Test with frequent access attempts
    # Test with large config files
}
```

## Security Testing

### Input Validation
```bash
test_input_validation() {
    # Test command injection
    # Test special characters
    # Test buffer limits
}
```

### File Security
```bash
test_file_security() {
    # Check file permissions
    # Test secure state storage
    # Verify cleanup
}
```

### State Protection
```bash
test_state_protection() {
    # Test state file tampering
    # Test concurrent modifications
    # Test crash recovery
}
```

## Running Tests

### All Tests
```bash
# Run complete test suite
bash tests/run_tests.sh
```

### Specific Categories
```bash
# Run unit tests only
bash tests/run_tests.sh --unit

# Run integration tests
bash tests/run_tests.sh --integration

# Run performance tests
bash tests/run_tests.sh --performance
```

### Development Testing
```bash
# Run tests for modified files
bash tests/run_tests.sh --changed

# Run specific test file
bash tests/run_tests.sh --file test_app_monitor.sh
```

## Test Development

### Adding New Tests

1. Create test file:
   ```bash
   # Unit test
   touch tests/unit/core/test_new_feature.sh
   chmod +x tests/unit/core/test_new_feature.sh
   ```

2. Test structure:
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../../common/test_setup.sh"
   
   test_new_feature() {
       # Test implementation
   }
   
   if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
       run_test_suite "${BASH_SOURCE[0]}"
   fi
   ```

### Best Practices

1. **Test Organization**
   - One feature per test file
   - Clear test names
   - Comprehensive assertions

2. **Mock Usage**
   - Mock external commands
   - Mock file operations
   - Mock system state

3. **Error Handling**
   - Test failure cases
   - Verify error messages
   - Check return codes

4. **Clean State**
   - Reset before each test
   - Clean up after tests
   - Isolate test environments

## Continuous Integration

### GitHub Actions
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: bash tests/run_tests.sh
```

### Local Pre-commit
```bash
#!/bin/bash
# .git/hooks/pre-commit
bash tests/run_tests.sh --changed
```

## Test Maintenance

### Regular Tasks
1. Update test fixtures
2. Review test coverage
3. Clean up test logs
4. Update mock data

### Troubleshooting
1. Enable debug logging
2. Check test environment
3. Verify mock behavior
4. Review test output 
# MindfulAccess Technical Documentation

## Architecture Overview

MindfulAccess follows a modular architecture with clear separation of concerns:

### Core Components

1. **App Protector (`src/core/app_protector.sh`)**
   - Main application loop
   - State management
   - Event coordination
   - Command-line interface

2. **App Monitor (`src/core/app_monitor.sh`)**
   - Application state detection
   - Process control (quit/launch)
   - Frontmost app detection
   - AppleScript integration

3. **Time Checker (`src/core/time_checker.sh`)**
   - Time window validation
   - Time formatting
   - Remaining time calculation

4. **String Generator (`src/core/string_generator.sh`)**
   - Random string generation
   - Configurable length
   - Alphanumeric characters

### UI Components

1. **Dialogs (`src/ui/dialogs.sh`)**
   - Verification dialog
   - Access granted/denied notifications
   - Shutdown warnings
   - AppleScript dialog management

2. **Config Interface (`src/ui/config_interface.sh`)**
   - Interactive configuration
   - Settings validation
   - User input handling
   - Current config display

### Utilities

1. **Config Manager (`src/utils/config_manager.sh`)**
   - Configuration file handling
   - Default settings
   - Config validation
   - Settings persistence

2. **Logger (`src/utils/logger.sh`)**
   - Structured logging
   - Log rotation
   - Debug mode support
   - Timestamp formatting

## State Management

### Active Apps Tracking

```bash
# Memory state
ACTIVE_APPS=""
ACTIVE_APPS_DELIMITER="|"

# Persistent state
ACTIVE_APPS_FILE="/tmp/mindfulaccess_active_apps"
```

State is maintained both in memory and on disk to ensure:
- Persistence across script restarts
- Quick access for frequent checks
- Recovery from crashes

### State Operations

1. **Adding Apps**
   ```bash
   add_active_app "AppName"
   # Updates both memory and file state
   ```

2. **Checking Status**
   ```bash
   is_app_active "AppName"
   # Checks memory first, then file
   ```

3. **Removing Apps**
   ```bash
   remove_active_app "AppName"
   # Updates both memory and file state
   ```

## Process Flow

### Main Loop

1. Load configuration
2. Monitor frontmost application
3. Check if app is protected
4. Verify time window
5. Handle verification if needed
6. Manage access duration
7. Schedule cleanup

### Verification Process

1. Generate random string
2. Close protected app
3. Show verification dialog
4. Compare user input
5. Grant/deny access
6. Schedule shutdown

### Access Duration

1. Grant initial access
2. Schedule warning notification
3. Schedule app shutdown
4. Remove from active apps
5. Clean up state

## Configuration

### File Structure

```bash
# ~/.config/mindfulaccess/config
START_HOUR=9
END_HOUR=17
STRING_LENGTH=32
ACCESS_DURATION=30
APPS=(Safari)
```

### Validation Rules

- Hours: 0-23
- String length: 5-64
- Access duration: > 0
- Apps: Non-empty list

## Error Handling

1. **Configuration Errors**
   - Invalid settings detection
   - Default value fallbacks
   - User notification

2. **Runtime Errors**
   - AppleScript failures
   - Process control issues
   - State management recovery

3. **Time Window Violations**
   - Access denial
   - User notification
   - App shutdown

## Testing

### Test Categories

1. **Unit Tests**
   - String generation
   - Time checking
   - Configuration validation
   - State management

2. **Integration Tests**
   - App protection flow
   - Configuration interface
   - Notification system
   - State persistence

### Test Utilities

- Mock AppleScript responses
- Temporary configuration
- State verification
- Log analysis

## Security Considerations

1. **File Permissions**
   - Configuration file: 600
   - Log directory: 700
   - Script files: 755

2. **State Protection**
   - Temporary file usage
   - Process isolation
   - Clean state removal

3. **Input Validation**
   - Configuration sanitization
   - String verification
   - Path validation

## Performance

1. **Optimization Techniques**
   - Memory-first state checks
   - Efficient string operations
   - Minimal disk I/O

2. **Resource Usage**
   - Low CPU utilization
   - Minimal memory footprint
   - Controlled disk writes

## Debugging

Enable debug mode:
```bash
DEBUG=true bash src/core/app_protector.sh --run
```

Debug output includes:
- State changes
- App detection
- Time checks
- Verification process
- Configuration loading

## Future Improvements

1. **Features**
   - Multiple time windows
   - Per-app settings
   - Usage statistics
   - GUI configuration

2. **Technical**
   - Database storage
   - IPC mechanisms
   - Plugin system
   - Network sync 
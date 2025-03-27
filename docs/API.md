# MindfulAccess API Documentation

## Core Functions

### App Protector (`src/core/app_protector.sh`)

#### State Management
```bash
add_active_app "app_name"
# Adds an app to the active apps list in both memory and file storage
# Returns: None

is_app_active "app_name"
# Checks if an app is in the active apps list
# Returns: 0 if active, 1 if not

remove_active_app "app_name"
# Removes an app from the active apps list
# Returns: None
```

#### Process Control
```bash
process_args "$@"
# Processes command line arguments
# Arguments: Command line arguments array
# Returns: 0 for success, 1 for failure

is_protected_app "app_name" "apps_list"
# Checks if an app is in the protected apps list
# Returns: 0 if protected, 1 if not

main_loop
# Main application loop that monitors and controls app access
# Returns: Never returns unless interrupted

cleanup
# Cleans up resources and state before exit
# Returns: None
```

### App Monitor (`src/core/app_monitor.sh`)

#### Process Management
```bash
get_process_names "app_name"
# Gets possible process names for an app
# Returns: Array of process names

is_app_running "app_name"
# Checks if an application is currently running
# Returns: 0 if running, 1 if not

get_frontmost_app
# Gets the name of the frontmost application
# Returns: String name of frontmost app

force_quit_app "app_name"
# Forces an application to quit immediately
# Returns: 0 on success, 1 on failure

quit_app "app_name"
# Attempts to quit an application gracefully, falls back to force quit
# Returns: 0 on success, 1 on failure

schedule_app_shutdown "app_name" "duration_minutes"
# Schedules an application to be shut down after specified duration
# Returns: 0 on success, 1 on failure
```

### Time Checker (`src/core/time_checker.sh`)

#### Time Management
```bash
format_time "hour"
# Formats hour in 24-hour format
# Returns: Formatted time string (HH:00)

format_time_window
# Formats the configured time window
# Returns: Formatted time window string (HH:00 - HH:00)

check_time_window
# Checks if current time is within allowed window
# Returns: 0 if within window, 1 if outside

get_time_remaining
# Gets remaining minutes in current time window
# Returns: Number of minutes remaining, 0 if outside window
```

### String Generator (`src/core/string_generator.sh`)

```bash
generate_random_string [length]
# Generates a random alphanumeric string
# Arguments: Optional length (defaults to CONFIG_STRING_LENGTH)
# Returns: Random string
```

## UI Functions

### Dialogs (`src/ui/dialogs.sh`)

```bash
show_verification_dialog "app_name" "verification_string"
# Shows verification dialog and handles app quit/reopen
# Returns: 0 if verified, 1 if not

show_access_granted "app_name" "duration"
# Shows access granted notification
# Returns: None

show_access_denied "app_name" "reason"
# Shows access denied notification with reason
# Returns: None

show_shutdown_warning "app_name" "minutes"
# Shows warning before app shutdown
# Returns: None
```

### Config Interface (`src/ui/config_interface.sh`)

```bash
format_time "hour"
# Formats time in 24-hour format
# Returns: Formatted time string

format_time_window "start_hour" "end_hour"
# Formats time window for display
# Returns: Formatted time window string

format_app_list "apps"
# Formats app list for display
# Returns: Formatted app list string

show_current_config
# Shows current configuration
# Returns: None

show_main_menu
# Shows main configuration menu
# Returns: Selected menu option

handle_apps_dialog
# Handles protected apps configuration
# Returns: 0 on success, 1 on failure

handle_time_dialog
# Handles time window configuration
# Returns: 0 on success, 1 on failure

handle_settings_dialog
# Handles string settings configuration
# Returns: 0 on success, 1 on failure

configure_app
# Main configuration interface
# Returns: 0 on success, 1 on failure
```

## Utility Functions

### Config Manager (`src/utils/config_manager.sh`)

```bash
init_config
# Initializes configuration with defaults if needed
# Returns: None

load_config
# Loads configuration from file
# Returns: 0 on success, 1 on failure

save_config "start_hour" "end_hour" "string_length" "access_duration" "apps"
# Saves configuration to file
# Returns: 0 on success, 1 on failure

get_config
# Gets current configuration into global variables
# Returns: None

validate_config "start_hour" "end_hour" "string_length" "access_duration" "apps"
# Validates configuration values
# Returns: 0 if valid, 1 if invalid
```

### Logger (`src/utils/logger.sh`)

```bash
rotate_log
# Rotates log file if it exceeds size limit
# Returns: None

format_timestamp
# Formats current timestamp for logging
# Returns: Formatted timestamp string

write_log "level" "message"
# Writes a log entry with level and message
# Returns: None

log_info "message"
# Logs an info message
# Returns: None

log_error "message"
# Logs an error message
# Returns: None

log_debug "message"
# Logs a debug message (only if DEBUG=true)
# Returns: None
```

## Environment Variables

```bash
MINDFULACCESS_ROOT
# Root directory of MindfulAccess installation
# Required for all scripts

DEBUG
# Enable debug logging when set to "true"
# Optional, defaults to "false"

TEST_MODE
# Enable test mode when set to "true"
# Optional, defaults to "false"
```

## Configuration Files

### Default Configuration (`config/default_config.sh`)
```bash
DEFAULT_START_HOUR=9
DEFAULT_END_HOUR=17
DEFAULT_STRING_LENGTH=32
DEFAULT_ACCESS_DURATION=30
DEFAULT_APPS="Safari"
```

### User Configuration (`~/.config/mindfulaccess/config`)
```bash
START_HOUR=9
END_HOUR=17
STRING_LENGTH=32
ACCESS_DURATION=30
APPS=(Safari)
```

## Return Codes

```bash
0  # Success
1  # General failure
2  # Configuration error
3  # Environment error
4  # Permission error
5  # Runtime error
```

## Usage Examples

### Basic Usage
```bash
# Run with default settings
bash src/core/app_protector.sh --run

# Run with debug logging
DEBUG=true bash src/core/app_protector.sh --run

# Configure settings
bash src/core/app_protector.sh --config
```

### API Usage
```bash
# Check if an app is protected
if is_protected_app "Safari" "$CONFIG_APPS"; then
    echo "Safari is protected"
fi

# Get remaining time in window
remaining=$(get_time_remaining)
echo "Minutes remaining: $remaining"

# Schedule app shutdown
schedule_app_shutdown "Safari" 30

# Show verification dialog
if show_verification_dialog "Safari" "ABC123"; then
    show_access_granted "Safari" 30
else
    show_access_denied "Safari" "Verification failed"
fi
``` 
# MindfulAccess - App Access Control for macOS

## Overview

A macOS utility that helps users maintain mindful app usage by implementing time-based access controls with verification.

### Core Features

- Restricts access to user-specified applications during designated time windows
- Requires entering a randomly generated alphanumeric string to access protected apps
- Provides timed access: apps remain accessible for a configurable duration after verification
- Automatically shuts down protected apps when access duration expires
- Simple AppleScript-based configuration interface

### Technologies Used

- **Bash**: Core scripting for random string generation, time checking, and process control
- **AppleScript**: User dialogs (for access control and configuration)
- **launchd**: macOS native service manager for background execution
- **Plist Files**: Launch agent configuration

### Prerequisites

- macOS (10.14 or later recommended)
- Terminal and a text editor
- Basic knowledge of shell scripting and AppleScript syntax

## Detailed Architecture & Components

### File Structure

1. **app_protector.sh**
   - Core logic implementation
   - Random string generation
   - Time window checking
   - Frontmost app detection
   - Access code validation
   - Scheduled app shutdown
   - Configuration management

2. **configure_app_protector.sh**
   - Lightweight launcher script
   - Provides easy access to configuration dialog

3. **com.example.appprotector.plist**
   - Launch agent configuration
   - Ensures script runs at login
   - Configures program arguments and execution settings

### Global Configuration

```bash
# Global Configuration Variables
APPS=("Microsoft Outlook" "Slack")      # Protected applications
START_HOUR=8                            # Access window start (24h format)
END_HOUR=11                            # Access window end (24h format)
STRING_LENGTH=10                        # Random string length
ACCESS_DURATION=10                      # Access duration in minutes
CONFIG_FILE="$HOME/.app_protector_config"  # Configuration storage
```

## Implementation Phases

### Phase 1: Core Functionality (1-2 Days)

#### 1.1 Random String Generation
```bash
generate_random_string() {
    random_string=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$STRING_LENGTH")
    echo "$random_string"
}
```

#### 1.2 Time Window Check
```bash
check_time_window() {
    current_hour=$(date +%H)
    current_hour=$((10#$current_hour))
    if (( current_hour < START_HOUR || current_hour >= END_HOUR )); then
        return 1
    else
        return 0
    fi
}
```

#### 1.3 Frontmost App Detection
```bash
get_frontmost_app() {
    osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'
}
```

#### 1.4 Access Control Dialog & Timed Shutdown
```bash
prompt_user_for_input() {
    local app_name="$1"
    local rand_str="$2"
    
    # AppleScript dialog implementation
    # Schedule shutdown after successful validation
    ( sleep $(( ACCESS_DURATION * 60 ))
      for app in "${APPS[@]}"; do
          osascript -e "tell application \"$app\" to quit"
      done
    ) &
}
```

### Phase 2: Launch Agent & Persistence (1 Day)

#### 2.1 Launch Agent Configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.example.appprotector</string>
    <key>ProgramArguments</key>
    <array>
      <string>/full/path/to/app_protector.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
```

### Phase 3: Configuration Interface (0.5-1 Day)

- AppleScript-based configuration dialog
- Settings management and persistence
- Protection status control (enable/disable)

### Phase 4: Testing & Refinement (1-2 Days)

#### Testing Areas
- Unit testing of core functions
- Integration testing
- Edge case handling
- Security validation

#### Logging & Debugging
- Comprehensive error logging
- State change tracking
- Diagnostic information

### Phase 5: Documentation & Deployment (0.5 Day)

- README creation
- Installation instructions
- Configuration guide
- Troubleshooting documentation
- Deployment script

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Misconfiguration | Medium | High | Input validation, defaults |
| Timezone Issues | Medium | High | System time documentation |
| Launch Agent Issues | Medium | High | Plist validation |
| Race Conditions | Medium | Medium | Debounce logic |
| Security Vulnerabilities | Low | High | Input sanitization |

## Success Criteria

### Functionality
- Accurate time window enforcement
- Reliable access code validation
- Automatic app shutdown after duration
- Persistent configuration

### Security
- Minimal privilege requirements
- Protected configuration
- Input validation

### Usability
- Clear user interface
- Reliable operation
- Helpful error messages
- Easy configuration

## Timeline

Total Estimated Duration: 4-6 Days

1. Core Functionality: 1-2 days
2. Launch Agent Setup: 1 day
3. Configuration Interface: 0.5-1 day
4. Testing & Refinement: 1-2 days
5. Documentation & Deployment: 0.5 day 
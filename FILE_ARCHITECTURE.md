# MindfulAccess File Architecture

## Directory Structure

```
MindfulAccess/
├── src/
│   ├── core/
│   │   ├── app_protector.sh          # Main application logic
│   │   ├── string_generator.sh       # Random string generation utilities
│   │   ├── time_checker.sh           # Time window validation functions
│   │   └── app_monitor.sh            # Application monitoring and control
│   │
│   ├── ui/
│   │   ├── dialogs.sh               # AppleScript dialog implementations
│   │   └── config_interface.sh       # Configuration interface functions
│   │
│   └── utils/
│       ├── logger.sh                 # Logging utilities
│       └── config_manager.sh         # Configuration file management
│
├── config/
│   ├── default_config.sh            # Default configuration values
│   └── launchd/
│       └── com.mindfulaccess.plist  # Launch agent configuration
│
├── scripts/
│   ├── install.sh                   # Installation script
│   ├── uninstall.sh                 # Uninstallation script
│   └── configure.sh                 # Configuration launcher script
│
├── tests/
│   ├── unit/
│   │   ├── test_string_generator.sh
│   │   ├── test_time_checker.sh
│   │   └── test_app_monitor.sh
│   │
│   └── integration/
│       └── test_app_protector.sh
│
├── logs/
│   └── .gitkeep                     # Placeholder for log directory
│
├── docs/
│   ├── INSTALLATION.md
│   ├── CONFIGURATION.md
│   ├── TROUBLESHOOTING.md
│   └── API.md
│
├── .gitignore
├── LICENSE
├── README.md
└── PROJECT_PLAN.md
```

## Component Details

### Core Components (`src/core/`)

1. **app_protector.sh**
   - Main application entry point
   - Orchestrates all core functionality
   - Dependencies: string_generator.sh, time_checker.sh, app_monitor.sh
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/string_generator.sh"
   source "${BASH_SOURCE%/*}/time_checker.sh"
   source "${BASH_SOURCE%/*}/app_monitor.sh"
   ```

2. **string_generator.sh**
   - Random string generation functionality
   - Configurable string length and complexity
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../utils/logger.sh"
   ```

3. **time_checker.sh**
   - Time window validation
   - Timezone handling
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../utils/logger.sh"
   ```

4. **app_monitor.sh**
   - Application state monitoring
   - Process control (quit/launch)
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../utils/logger.sh"
   ```

### User Interface (`src/ui/`)

1. **dialogs.sh**
   - AppleScript dialog implementations
   - User interaction handling
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../utils/logger.sh"
   ```

2. **config_interface.sh**
   - Configuration dialog implementation
   - Settings validation
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../utils/config_manager.sh"
   source "${BASH_SOURCE%/*}/../utils/logger.sh"
   ```

### Utilities (`src/utils/`)

1. **logger.sh**
   - Logging functionality
   - Debug information
   - Error tracking
   ```bash
   #!/bin/bash
   readonly LOG_DIR="${BASH_SOURCE%/*}/../../logs"
   ```

2. **config_manager.sh**
   - Configuration file handling
   - Settings persistence
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/logger.sh"
   ```

### Configuration (`config/`)

1. **default_config.sh**
   - Default application settings
   ```bash
   #!/bin/bash
   # Default configuration values
   DEFAULT_START_HOUR=8
   DEFAULT_END_HOUR=17
   DEFAULT_STRING_LENGTH=10
   DEFAULT_ACCESS_DURATION=10
   ```

2. **launchd/com.mindfulaccess.plist**
   - Launch agent configuration
   - System integration settings

### Scripts (`scripts/`)

1. **install.sh**
   - Installation process
   - Dependency checks
   - Launch agent setup
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../src/utils/logger.sh"
   ```

2. **uninstall.sh**
   - Clean uninstallation
   - Configuration cleanup
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../src/utils/logger.sh"
   ```

3. **configure.sh**
   - Configuration interface launcher
   ```bash
   #!/bin/bash
   source "${BASH_SOURCE%/*}/../src/ui/config_interface.sh"
   ```

## File Permissions

```bash
# Core executables
chmod 755 src/core/*.sh

# UI scripts
chmod 755 src/ui/*.sh

# Utility scripts
chmod 755 src/utils/*.sh

# Installation scripts
chmod 755 scripts/*.sh

# Configuration files
chmod 644 config/default_config.sh
chmod 644 config/launchd/com.mindfulaccess.plist
```

## Dependencies

Each script follows a consistent pattern for importing dependencies:

```bash
#!/bin/bash

# Get the directory of the current script
readonly SCRIPT_DIR="${BASH_SOURCE%/*}"

# Source required dependencies
source "$SCRIPT_DIR/relative/path/to/dependency.sh"
```

## Configuration Storage

User configuration is stored in:
```
$HOME/.config/mindfulaccess/config
```

## Logging

Logs are stored in:
```
$HOME/.local/share/mindfulaccess/logs/
```

## Best Practices

1. **Modularity**
   - Each script has a single responsibility
   - Clear separation of concerns
   - Minimal dependencies between components

2. **Error Handling**
   - All functions include error checking
   - Proper exit codes
   - Comprehensive logging

3. **Configuration**
   - Centralized configuration management
   - Default values for all settings
   - User-specific configuration override

4. **Security**
   - Proper file permissions
   - Input validation
   - Secure storage of settings

5. **Testing**
   - Unit tests for core functionality
   - Integration tests for complete workflows
   - Test coverage tracking 
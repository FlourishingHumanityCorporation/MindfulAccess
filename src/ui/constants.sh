#!/bin/bash

# Guard against multiple sourcing
if [[ -n "$MINDFULACCESS_CONSTANTS_LOADED" ]]; then
    return 0
fi
MINDFULACCESS_CONSTANTS_LOADED=1

# Dialog state constants
STATE_MAIN="main"
STATE_APPS="apps"
STATE_TIME="time"
STATE_DURATION="duration"
STATE_SETTINGS="settings"

# Menu options
MENU_APPS="Restricted Apps"
MENU_TIME="Block Time"
MENU_DURATION="Access Duration"
MENU_SETTINGS="String Lengths"
MENU_TEST="Test Config"
MENU_DONE="Done"

# Menu titles
TITLE_APPS="Edit Restricted Apps"
TITLE_TIME="Edit Block Time"
TITLE_DURATION="Edit Access Duration"
TITLE_SETTINGS="Edit String Length"
TITLE_TEST="Test Configuration"
TITLE_CONFIG="MindfulAccess Configuration" 
# MindfulAccess Troubleshooting Guide

## Common Issues and Solutions

### 1. Application Not Being Protected

#### Symptoms
- Protected app opens without verification
- No dialog appears when opening the app
- App doesn't close when it should

#### Solutions
1. **Check Configuration**
   ```bash
   bash src/core/app_protector.sh --config
   ```
   - Verify the app is in the protected apps list
   - Ensure exact app name matches (case-sensitive)

2. **Check Environment**
   ```bash
   echo $MINDFULACCESS_ROOT
   ```
   - Should point to the MindfulAccess installation directory
   - Add to `~/.bashrc` or `~/.zshrc` if missing

3. **Check Permissions**
   ```bash
   ls -l src/core/app_protector.sh
   ```
   - Should be executable (`chmod +x src/core/*.sh`)

4. **Enable Debug Mode**
   ```bash
   DEBUG=true bash src/core/app_protector.sh --run
   ```
   - Watch the output for errors
   - Check app detection messages

### 2. Verification Dialog Issues

#### Symptoms
- Dialog doesn't appear
- Dialog appears but doesn't accept input
- Dialog keeps reappearing

#### Solutions
1. **Check AppleScript Permissions**
   - System Preferences → Security & Privacy → Privacy
   - Enable accessibility access for Terminal/iTerm

2. **Clear Active Apps State**
   ```bash
   rm -f /tmp/mindfulaccess_active_apps
   ```
   - Removes potentially corrupted state
   - Restart the app protector

3. **Check Dialog Process**
   ```bash
   ps aux | grep "[a]pplescript"
   ```
   - Look for stuck dialog processes
   - Kill if necessary: `killall osascript`

### 3. Time Window Problems

#### Symptoms
- Access denied at wrong times
- Incorrect time window display
- Time-based features not working

#### Solutions
1. **Verify System Time**
   ```bash
   date
   ```
   - Ensure system time is correct
   - Check timezone settings

2. **Check Configuration**
   ```bash
   cat ~/.config/mindfulaccess/config
   ```
   - Verify START_HOUR and END_HOUR
   - Hours should be in 24-hour format (0-23)

3. **Test Time Window**
   ```bash
   DEBUG=true bash src/core/app_protector.sh --run
   ```
   - Look for "Time check passed/failed" messages
   - Verify current hour is being detected correctly

### 4. Configuration Issues

#### Symptoms
- Settings not saving
- Invalid configuration errors
- Default values not loading

#### Solutions
1. **Check Config Directory**
   ```bash
   ls -la ~/.config/mindfulaccess/
   ```
   - Should exist and be writable
   - Create if missing: `mkdir -p ~/.config/mindfulaccess`

2. **Verify Config File**
   ```bash
   cat ~/.config/mindfulaccess/config
   ```
   - Check syntax
   - Verify values are within valid ranges

3. **Reset to Defaults**
   ```bash
   rm ~/.config/mindfulaccess/config
   bash src/core/app_protector.sh --config
   ```
   - Removes corrupted config
   - Reinitializes with defaults

### 5. Performance Issues

#### Symptoms
- High CPU usage
- Slow response time
- System lag

#### Solutions
1. **Check Process Usage**
   ```bash
   ps aux | grep "[a]pp_protector"
   ```
   - Look for multiple instances
   - Check CPU/memory usage

2. **Monitor Log Growth**
   ```bash
   ls -lh ~/.local/share/mindfulaccess/logs/
   ```
   - Check log file size
   - Verify log rotation is working

3. **Clean Up Resources**
   ```bash
   pkill -f "mindfulaccess.*shutdown.pid"
   rm -f /tmp/mindfulaccess_*
   ```
   - Removes stale processes
   - Cleans up temporary files

### 6. Notification Problems

#### Symptoms
- Missing shutdown warnings
- No access granted/denied notifications
- Duplicate notifications

#### Solutions
1. **Check Notification Settings**
   - System Preferences → Notifications
   - Enable notifications for Terminal/iTerm

2. **Test Notifications**
   ```bash
   osascript -e 'display notification "Test" with title "MindfulAccess"'
   ```
   - Verifies AppleScript notifications work
   - Checks system notification settings

3. **Clear Notification Cache**
   ```bash
   killall NotificationCenter
   ```
   - Resets notification system
   - May require logout/login

## Debug Information Collection

If you need to report an issue, please provide:

1. **System Information**
   ```bash
   system_profiler SPSoftwareDataType
   echo $SHELL
   echo $MINDFULACCESS_ROOT
   ```

2. **Configuration**
   ```bash
   cat ~/.config/mindfulaccess/config
   ```

3. **Debug Logs**
   ```bash
   DEBUG=true bash src/core/app_protector.sh --run
   ```
   - Run for a few minutes
   - Copy the output

4. **Process State**
   ```bash
   ps aux | grep "[m]indfulaccess"
   ls -la /tmp/mindfulaccess_*
   ```

## Still Need Help?

1. Check the [Technical Documentation](TECHNICAL.md)
2. Review the [README.md](../README.md)
3. Open an issue on GitHub with:
   - Detailed problem description
   - Steps to reproduce
   - Collected debug information
   - System information 
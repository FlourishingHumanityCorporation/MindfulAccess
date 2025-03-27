try
    tell application "System Events"
        -- Test 1: Check if our app has permissions
        log "Testing app permissions..."
        set appPath to "/Applications/MindfulAccess.app"
        
        -- Try to get trusted status
        set isTrusted to get UI element "MindfulAccess" enabled
        if not isTrusted then
            log "❌ App is not trusted for accessibility"
            
            -- Try to open security preferences
            tell application "System Preferences"
                activate
                set current pane to pane id "com.apple.preference.security"
                reveal anchor "Privacy_Accessibility"
            end tell
            
            return false
        end if
        
        log "✅ App has required permissions"
        return true
    end tell
on error errMsg
    log "❌ Permission check failed: " & errMsg
    return false
end try 
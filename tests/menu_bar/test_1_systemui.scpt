try
    tell application "System Events"
        set sysUI to first process whose name is "SystemUIServer"
        log "✅ Can access SystemUIServer"
        return true
    end tell
on error errMsg
    log "❌ Cannot access SystemUIServer: " & errMsg
    return false
end try 
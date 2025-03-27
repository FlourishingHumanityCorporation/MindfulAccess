try
    tell application "System Events"
        tell process "SystemUIServer"
            set menuItems to name of every menu bar item of menu bar 1
            log "✅ Current menu items: " & menuItems
            return menuItems
        end tell
    end tell
on error errMsg
    log "❌ Cannot list menu items: " & errMsg
    return false
end try 
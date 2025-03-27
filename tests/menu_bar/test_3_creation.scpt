try
    tell application "System Events"
        tell process "SystemUIServer"
            -- Try to create a test item
            set testItem to make new menu bar item at end of menu bar 1 with properties {title:"test"}
            delay 0.5
            -- Try to delete it
            delete testItem
            log "✅ Can create and delete menu items"
            return true
        end tell
    end tell
on error errMsg
    log "❌ Cannot create/delete menu items: " & errMsg
    return false
end try 
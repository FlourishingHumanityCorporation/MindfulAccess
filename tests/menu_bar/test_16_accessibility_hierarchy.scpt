try
    tell application "System Events"
        log "Step 1: Exploring SystemUIServer hierarchy..."
        tell process "SystemUIServer"
            -- Try to get all UI elements
            try
                set allElements to every UI element
                log "Total UI elements found: " & (count of allElements)
                
                -- Examine each element
                repeat with elem in allElements
                    try
                        log "Element info:"
                        log "- Name: " & name of elem
                        log "- Description: " & description of elem
                        log "- Role: " & role of elem
                    end try
                end repeat
            on error errMsg
                log "Error getting UI elements: " & errMsg
            end try
            
            -- Try to get windows
            try
                set wins to every window
                log "Windows found: " & (count of wins)
            on error errMsg
                log "Error getting windows: " & errMsg
            end try
            
            -- Try to get menus
            try
                set menus to every menu
                log "Menus found: " & (count of menus)
            on error errMsg
                log "Error getting menus: " & errMsg
            end try
        end tell
        
        log "✅ Basic hierarchy exploration completed"
        return true
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
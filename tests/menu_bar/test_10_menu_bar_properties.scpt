try
    tell application "System Events"
        log "Testing menu bar properties..."
        
        -- Step 1: Get SystemUIServer process
        set sysUI to first process whose name is "SystemUIServer"
        log "Process name: " & name of sysUI
        log "Process ID: " & id of sysUI
        
        -- Step 2: Examine process properties
        log "Process properties:"
        log "- Frontmost: " & frontmost of sysUI
        log "- Visible: " & visible of sysUI
        log "- Has UI elements: " & (UI elements enabled of sysUI)
        
        -- Step 3: List all menu bars
        tell sysUI
            log "Examining menu bars..."
            set menuBars to every menu bar
            log "Found " & (count of menuBars) & " menu bars"
            
            repeat with mb in menuBars
                try
                    log "Menu bar properties:"
                    log "- Role: " & role of mb
                    log "- Description: " & description of mb
                    log "- Position: " & position of mb
                    log "- Size: " & size of mb
                    
                    -- Step 4: List existing menu items
                    set menuItems to every menu bar item of mb
                    log "Found " & (count of menuItems) & " menu items"
                    repeat with mi in menuItems
                        log "  Item: " & title of mi
                    end repeat
                on error errMsg
                    log "Error examining menu bar: " & errMsg
                end try
            end repeat
        end tell
        
        log "✅ Menu bar properties test completed"
        return true
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
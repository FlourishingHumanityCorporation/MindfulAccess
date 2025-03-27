try
    tell application "System Events"
        -- Test 1: List menu extras
        log "Testing menu extras access..."
        tell process "SystemUIServer"
            -- Try to access menu extras through a different path
            set menuExtras to menu bars
            repeat with menuBar in menuExtras
                log "Menu bar items: " & (name of every menu bar item of menuBar)
            end repeat
        end tell
        
        -- Test 2: Try to access through UI elements
        log "Testing UI elements access..."
        tell process "SystemUIServer"
            set allElements to entire contents
            log "UI elements found: " & (count of allElements)
        end tell
        
        log "✅ Menu extras tests passed"
        return true
    end tell
on error errMsg
    log "❌ Menu extras test failed: " & errMsg
    return false
end try 
try
    tell application "System Events"
        -- Test 1: Try to access through UI hierarchy
        log "Testing UI hierarchy access..."
        tell process "SystemUIServer"
            set topLevel to UI elements
            repeat with elem in topLevel
                log "Found element: " & (name of elem)
                if exists menu bar of elem then
                    log "Found menu bar in element"
                end if
            end repeat
        end tell
        
        -- Test 2: Try to access through application menu bar
        log "Testing application menu bar access..."
        tell application process "SystemUIServer"
            set menuBars to menu bars
            if (count of menuBars) > 0 then
                log "Found " & (count of menuBars) & " menu bars"
                log "First menu bar properties: " & (properties of item 1 of menuBars)
            end if
        end tell
        
        log "✅ Alternative menu bar tests completed"
        return true
    end tell
on error errMsg
    log "❌ Alternative menu bar test failed: " & errMsg
    return false
end try 
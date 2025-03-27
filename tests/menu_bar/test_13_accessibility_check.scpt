try
    tell application "System Events"
        -- Test 1: Basic accessibility permissions
        log "Step 1: Testing basic accessibility permissions..."
        set procList to name of every process
        log "✓ Can list processes (" & (count of procList) & " processes found)"
        
        -- Test 2: UI element access
        log "Step 2: Testing UI element access..."
        set sysUI to first process whose name is "SystemUIServer"
        tell sysUI
            -- Try to get attributes
            log "Process attributes:"
            log "- Has UI elements allowed: " & UI elements enabled
            log "- Has focus: " & focused
            log "- Bundle ID: " & bundle identifier
            
            -- Try to get UI element attributes
            set uiElems to UI elements
            log "UI elements found: " & (count of uiElems)
            
            -- Try to get accessibility description
            log "Accessibility description:"
            log description
            
            -- Try to get role description
            log "Role description:"
            log role description
        end tell
        
        -- Test 3: Menu bar specific permissions
        log "Step 3: Testing menu bar specific permissions..."
        tell application process "SystemUIServer"
            -- Try to get menu bars directly
            try
                set menuBars to menu bars
                log "Direct menu bars found: " & (count of menuBars)
            on error errMsg
                log "Direct menu bar access failed: " & errMsg
            end try
            
            -- Try to get through UI elements
            try
                set menuElements to UI elements whose role description contains "menu"
                log "Menu-related elements found: " & (count of menuElements)
            on error errMsg
                log "Menu element search failed: " & errMsg
            end try
        end tell
        
        log "✅ Accessibility tests completed"
        return true
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
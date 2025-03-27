try
    tell application "System Events"
        -- Test 1: Basic UI element access
        log "Testing UI element access..."
        set uiEnabled to UI elements enabled
        if not uiEnabled then
            log "❌ UI elements are not enabled"
            return false
        end if
        
        -- Test 2: Process list access
        log "Testing process list access..."
        set procs to name of every process
        log "Found " & (count of procs) & " processes"
        
        -- Test 3: Menu bar access
        log "Testing menu bar access..."
        tell process "SystemUIServer"
            -- Try to get properties of menu bar
            set menuBarProps to properties of menu bar 1
            log "Menu bar properties: " & menuBarProps
        end tell
        
        log "✅ All permission tests passed"
        return true
        
    end tell
on error errMsg
    log "❌ Permission test failed: " & errMsg
    return false
end try 
try
    tell application "System Events"
        -- Test 1: Check if we have accessibility access at all
        log "Step 1: Checking basic accessibility access..."
        try
            set accessEnabled to UI elements enabled
            log "✓ UI Elements enabled: " & accessEnabled
        on error errMsg
            log "❌ Cannot check UI Elements enabled: " & errMsg
        end try
        
        -- Test 2: Check what we can access in SystemUIServer
        log "Step 2: Checking SystemUIServer access levels..."
        tell process "SystemUIServer"
            -- Try to get basic properties that don't require deep access
            log "Basic properties:"
            try
                log "- Application name: " & name
                log "- Visible: " & visible
                log "- Frontmost: " & frontmost
                log "✓ Can access basic properties"
            on error errMsg
                log "❌ Cannot access basic properties: " & errMsg
            end try
            
            -- Try to get process-level UI elements
            log "Process UI elements:"
            try
                set procElements to every UI element
                log "✓ Can access process elements: " & (count of procElements)
            on error errMsg
                log "❌ Cannot access process elements: " & errMsg
            end try
            
            -- Try to get window-level access
            log "Window access:"
            try
                set windowCount to count of windows
                log "✓ Can access windows: " & windowCount
            on error errMsg
                log "❌ Cannot access windows: " & errMsg
            end try
            
            -- Try to get menu bar-level access
            log "Menu bar access:"
            try
                set menuBarCount to count of menu bars
                log "✓ Can access menu bars: " & menuBarCount
            on error errMsg
                log "❌ Cannot access menu bars: " & errMsg
            end try
        end tell
        
        -- Test 3: Check if we can access menu bar through different paths
        log "Step 3: Testing alternative menu bar access paths..."
        try
            tell application process "SystemUIServer"
                -- Try direct menu bar access
                try
                    set mb to menu bar 1
                    log "✓ Can access menu bar 1 directly"
                on error errMsg
                    log "❌ Cannot access menu bar 1: " & errMsg
                end try
                
                -- Try through UI elements
                try
                    set menuElements to UI elements whose role is "menu bar"
                    log "✓ Found " & (count of menuElements) & " menu bar elements"
                on error errMsg
                    log "❌ Cannot search for menu bar elements: " & errMsg
                end try
            end tell
        on error errMsg
            log "❌ Cannot access SystemUIServer as application process: " & errMsg
        end try
        
        log "✅ Permission check completed"
        return true
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
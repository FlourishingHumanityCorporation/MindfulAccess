try
    tell application "System Events"
        log "Step 1: Accessing SystemUIServer..."
        set sysUI to first process whose name is "SystemUIServer"
        log "✓ Found SystemUIServer process"
        
        -- Log process properties
        log "Process properties:"
        log "- Name: " & name of sysUI
        log "- ID: " & id of sysUI
        log "- Frontmost: " & frontmost of sysUI
        
        -- Check UI elements
        log "Step 2: Checking UI elements..."
        tell sysUI
            set allElements to every UI element
            log "Found " & (count of allElements) & " UI elements"
            
            repeat with elem in allElements
                try
                    log "Element: " & name of elem & " (Role: " & role of elem & ")"
                    if exists menu bar of elem then
                        log "✓ Found menu bar in element: " & name of elem
                        
                        -- Try to access menu bar
                        tell menu bar of elem
                            log "Menu bar properties:"
                            log properties
                            
                            -- Try to create menu item
                            log "Step 3: Attempting to create menu bar item..."
                            make new menu bar item at end with properties {title:"TestMenu"}
                            log "✓ Successfully created menu bar item"
                            
                            -- Verify and cleanup
                            if exists menu bar item "TestMenu" then
                                delete menu bar item "TestMenu"
                                log "✓ Successfully cleaned up"
                            end if
                        end tell
                        return true
                    end if
                on error errMsg
                    log "Note: Skipping element due to: " & errMsg
                end try
            end repeat
        end tell
        
        -- Alternative approach using application process
        log "Step 4: Trying alternative approach..."
        tell application process "SystemUIServer"
            set menuBars to menu bars
            log "Found " & (count of menuBars) & " menu bars via alternative approach"
            
            if (count of menuBars) > 0 then
                tell menu bar 1
                    log "Menu bar 1 properties:"
                    log properties
                end tell
            end if
        end tell
        
        error "No suitable menu bar found for manipulation"
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
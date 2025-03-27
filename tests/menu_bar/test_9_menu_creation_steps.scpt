try
    -- Step 1: Basic SystemUIServer access
    log "Step 1: Testing SystemUIServer access..."
    tell application "System Events"
        set sysUI to first process whose name is "SystemUIServer"
        log "✓ Found SystemUIServer process"
        
        -- Step 2: List all UI elements
        log "Step 2: Listing UI elements..."
        tell sysUI
            set allElements to every UI element
            log "Found " & (count of allElements) & " UI elements"
            
            -- Step 3: Find menu bars
            log "Step 3: Looking for menu bars..."
            repeat with elem in allElements
                try
                    if exists menu bar of elem then
                        log "✓ Found menu bar in element: " & (name of elem)
                        
                        -- Step 4: Try to create menu item
                        log "Step 4: Attempting to create menu item..."
                        tell menu bar of elem
                            make new menu bar item at end with properties {title:"test"}
                            log "✓ Successfully created menu item"
                            
                            -- Step 5: Add menu
                            log "Step 5: Adding menu to item..."
                            tell last menu bar item
                                make new menu
                                tell menu 1
                                    make new menu item with properties {title:"Test Option"}
                                end tell
                                log "✓ Successfully added menu"
                                
                                -- Step 6: Test menu interaction
                                log "Step 6: Testing menu interaction..."
                                tell menu 1
                                    if exists menu item "Test Option" then
                                        log "✓ Menu item exists and is accessible"
                                    end if
                                end tell
                                
                                -- Step 7: Cleanup
                                log "Step 7: Cleaning up..."
                                delete last menu bar item
                                log "✓ Successfully cleaned up"
                            end tell
                        end tell
                        return true
                    end if
                on error errMsg
                    log "✗ Error in element " & (name of elem) & ": " & errMsg
                end try
            end repeat
        end tell
    end tell
    error "No suitable menu bar found"
on error errMsg
    log "✗ Test failed: " & errMsg
    return false
end try 
try
    tell application "System Events"
        log "Testing menu persistence..."
        
        -- Step 1: Initial creation
        log "Step 1: Creating initial menu item..."
        tell process "SystemUIServer"
            set menuCreated to false
            repeat with elem in UI elements
                try
                    if exists menu bar of elem then
                        tell menu bar of elem
                            make new menu bar item at end with properties {title:"test-persist"}
                            log "✓ Created initial menu item"
                            set menuCreated to true
                            exit repeat
                        end tell
                    end if
                end try
            end repeat
            
            if not menuCreated then
                error "Failed to create initial menu item"
            end if
        end tell
        
        -- Step 2: Wait and verify
        log "Step 2: Waiting to verify persistence..."
        delay 3
        
        tell process "SystemUIServer"
            set menuFound to false
            repeat with elem in UI elements
                try
                    if exists menu bar of elem then
                        tell menu bar of elem
                            if exists menu bar item "test-persist" then
                                log "✓ Menu item persisted after delay"
                                set menuFound to true
                                
                                -- Step 3: Try to modify
                                log "Step 3: Testing menu modification..."
                                tell menu bar item "test-persist"
                                    make new menu
                                    tell menu 1
                                        make new menu item with properties {title:"Test Option"}
                                    end tell
                                end tell
                                log "✓ Successfully modified menu"
                                
                                -- Step 4: Wait and verify modification
                                delay 2
                                if exists menu bar item "test-persist" then
                                    tell menu bar item "test-persist"
                                        if exists menu 1 then
                                            if exists menu item "Test Option" of menu 1 then
                                                log "✓ Menu modifications persisted"
                                            end if
                                        end if
                                    end tell
                                end if
                                
                                -- Step 5: Cleanup
                                log "Step 5: Cleaning up..."
                                delete menu bar item "test-persist"
                                log "✓ Cleanup successful"
                                exit repeat
                            end if
                        end tell
                    end if
                end try
            end repeat
            
            if not menuFound then
                error "Menu item did not persist"
            end if
        end tell
        
        log "✅ Menu persistence test completed"
        return true
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
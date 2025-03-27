try
    tell application "System Events"
        -- First check if we already have permissions
        log "Step 1: Checking current permissions..."
        try
            set accessEnabled to UI elements enabled
            log "Current UI Elements enabled: " & accessEnabled
            
            if not accessEnabled then
                -- Request permissions via dialog
                log "Requesting accessibility permissions..."
                display dialog "MindfulAccess needs additional permissions to create menu bar items. Please grant access in System Settings > Privacy & Security > Accessibility." buttons {"Open Settings", "Cancel"} default button 1 with icon caution
                
                if button returned of result is "Open Settings" then
                    -- Open Security & Privacy preferences directly to Accessibility
                    do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'"
                    
                    -- Wait for user to grant permissions
                    display dialog "After granting permissions in Settings, click OK to continue." buttons {"OK"} default button 1
                    
                    -- Verify permissions again
                    set accessEnabled to UI elements enabled
                    if accessEnabled then
                        log "✓ Successfully gained accessibility permissions"
                    else
                        error "Permissions not granted"
                    end if
                else
                    error "Permission request cancelled"
                end if
            else
                log "✓ Already have basic accessibility permissions"
            end if
            
            -- Test deeper access
            log "Step 2: Testing SystemUIServer access..."
            tell process "SystemUIServer"
                -- Try to access menu bar elements
                try
                    set menuElements to UI elements whose role is "menu bar"
                    log "Menu elements found: " & (count of menuElements)
                    
                    if (count of menuElements) is 0 then
                        -- Additional permissions might be needed
                        display dialog "Additional permissions might be needed. Please ensure MindfulAccess is allowed in System Settings > Privacy & Security > Accessibility and try running the script again." buttons {"Open Settings", "OK"} default button 1 with icon caution
                        
                        if button returned of result is "Open Settings" then
                            do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'"
                        end if
                    end if
                on error errMsg
                    log "❌ Menu element access failed: " & errMsg
                    -- Suggest additional permissions
                    display dialog "Unable to access menu elements. Please verify all permissions in System Settings > Privacy & Security > Accessibility." buttons {"Open Settings", "OK"} default button 1 with icon caution
                    
                    if button returned of result is "Open Settings" then
                        do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'"
                    end if
                end try
            end tell
        on error errMsg
            log "❌ Permission check failed: " & errMsg
            return false
        end try
        
        log "✅ Permission check and request completed"
        return true
    end tell
on error errMsg
    log "❌ Test failed: " & errMsg
    return false
end try 
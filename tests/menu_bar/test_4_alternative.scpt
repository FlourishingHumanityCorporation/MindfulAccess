try
    tell application "System Events"
        -- Try to create a status item directly
        set statusItem to make new menu bar item with properties {title:"test"} at end of menu bar 1
        
        -- Add a menu
        tell statusItem
            make new menu
            tell menu 1
                make new menu item with properties {title:"Test Item"}
            end tell
        end tell
        
        delay 1
        
        -- Clean up
        delete statusItem
        
        log "✅ Alternative menu creation successful"
        return true
    end tell
on error errMsg
    log "❌ Alternative menu creation failed: " & errMsg
    return false
end try 
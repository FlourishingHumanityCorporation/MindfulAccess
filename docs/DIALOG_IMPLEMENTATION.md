# Dialog Implementation Documentation

## Overview
The dialog system in MindfulAccess handles user interactions through AppleScript dialogs, providing verification prompts, notifications, and warnings.

## Core Components

### 1. Verification Dialog
- **Function**: `show_verification_dialog`
- **Purpose**: Prompts user to verify access to protected applications
- **Implementation Details**:
  - Quits the target application before showing dialog
  - Shows dialog with timeout (default 30 seconds)
  - Validates user input against verification string
  - Reopens application on successful verification
  - Returns 0 for success, 1 for failure

### 2. Warning Dialog
- **Function**: `show_warning_dialog`
- **Purpose**: Displays warnings about impending app closure
- **Implementation Details**:
  - Shows dialog with OK button
  - Includes app name and remaining time
  - Non-blocking implementation

### 3. Access Notifications
- **Function**: `show_access_notification`
- **Purpose**: Notifies user about granted access
- **Implementation Details**:
  - Uses macOS notification system
  - Shows duration of granted access
  - Includes app name in subtitle

### 4. Access Control Dialogs
- **Functions**: 
  - `show_access_granted`
  - `show_access_denied`
- **Purpose**: Inform user about access decisions
- **Implementation Details**:
  - Displays reason for denial
  - Shows granted duration
  - Uses system notifications

## Verification Dialog Behavior

### Core Features
- Single persistent dialog instance
- Input preservation on incorrect attempts
- Visual shake feedback
- Error message display
- Enter key support for verification

### User Flow
1. Dialog appears when accessing protected app
2. User enters verification code
3. On incorrect code:
   - Dialog shakes
   - Shows "Incorrect code" message
   - Preserves incorrect input
   - Returns to same dialog
   - Allows immediate retry
4. On correct code:
   - Dialog closes
   - App reopens
5. On cancel:
   - Dialog closes
   - App remains closed

### Implementation Details

#### Dialog Creation
```applescript
set verificationDialog to display dialog "To access $app_name, please type: $verification_string" ¬
    default answer "$last_attempt" ¬
    buttons {"Cancel", "Verify"} ¬
    default button 2 ¬
    with title "MindfulAccess Verification"
```

#### Incorrect Code Handling
```applescript
# Shake animation
tell process "System Events"
    set theWindow to first window whose title contains "MindfulAccess"
    set {x, y} to position of theWindow
    
    repeat 4 times
        set position of theWindow to {x - 25, y}
        delay 0.02
        set position of theWindow to {x + 25, y}
        delay 0.02
    end repeat
    
    set position of theWindow to {x, y}
end tell

# Show error and preserve input
display dialog "Incorrect code. Please try again." ¬
    buttons {"OK"} default button 1 ¬
    with title "MindfulAccess Verification"

# Continue with same dialog
set verificationDialog to display dialog "..." ¬
    default answer textEntered ¬  # Preserve incorrect input
    ...
```

### Key Features

1. **Dialog Persistence**
   - Single dialog instance
   - No reopening on incorrect attempts
   - Maintains window position

2. **User Feedback**
   - Visual shake animation
   - Error message display
   - Input preservation
   - Clear success/failure indication

3. **Error Handling**
   - Graceful window management
   - Try/catch for animations
   - Timeout handling
   - Cancel handling

4. **User Experience**
   - Enter key support
   - Immediate retry capability
   - Clear error messages
   - Smooth animations

### Best Practices

1. **Dialog Management**
   - Create once, reuse
   - Maintain state
   - Handle window references carefully

2. **Error Handling**
   - Wrap window operations in try/catch
   - Graceful fallbacks
   - Clear user feedback

3. **User Input**
   - Preserve incorrect attempts
   - Clear error messages
   - Quick feedback
   - Easy retry

4. **Performance**
   - Minimal delays
   - Efficient animations
   - No unnecessary redraws

### Testing Considerations

1. **Functionality Tests**
   - Correct code acceptance
   - Incorrect code handling
   - Cancel operation
   - Timeout behavior

2. **UI Tests**
   - Dialog appearance
   - Animation smoothness
   - Input preservation
   - Error message clarity

3. **Edge Cases**
   - Rapid input attempts
   - Window management
   - System load handling
   - Multiple displays

### Future Improvements

1. **Enhanced Feedback**
   - Color-based input validation
   - Progress indicators
   - Attempt counters
   - Custom animations

2. **Security Features**
   - Input masking option
   - Rate limiting
   - Pattern detection
   - Logging enhancements

3. **Accessibility**
   - Screen reader support
   - Keyboard navigation
   - High contrast mode
   - Font size options

4. **Performance**
   - Animation optimization
   - Window handling improvements
   - State management refinements
   - Memory usage optimization

## Testing Infrastructure

### 1. Mock System
```
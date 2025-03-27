#!/bin/bash

# Source the dialog script
source "${BASH_SOURCE%/*}/../../src/ui/dialogs.sh"

# Test verification string
VERIFICATION_STRING="TEST123"

# Use Safari as our test app
TEST_APP="Safari"

# Make sure Safari is running
osascript -e "tell application \"$TEST_APP\" to activate"
sleep 1

echo "Please try the following:"
echo "1. Enter an incorrect code and click Verify (dialog should shake)"
echo "2. Notice your incorrect input remains"
echo "3. Try again with the correct code: $VERIFICATION_STRING"
echo "4. Or click Cancel to exit"
echo
echo "Starting verification dialog..."
show_verification_dialog "$TEST_APP" "$VERIFICATION_STRING"

# Print result
status=$?
if [[ $status -eq 0 ]]; then
    echo "✅ Verification successful! Safari should be active again."
else
    echo "❌ Verification failed or cancelled."
fi 
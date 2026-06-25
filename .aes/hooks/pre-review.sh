#!/bin/bash
# Pre-review hook for AES
# Requires verification to be completed with pass verdict and diffstory

echo "Running pre-review checks..."

# Check if we're in an AES project
if [ ! -f "aes/kanban.md" ]; then
    echo "Error: Not in an AES project (missing aes/kanban.md)"
    exit 1
fi

# Check if verification exists for current ticket
CURRENT_TICKET=$(grep "current_ticket:" aes/kanban.md | awk '{print $2}' | head -1)
if [ -z "$CURRENT_TICKET" ]; then
    echo "Error: No current_ticket found in aes/kanban.md"
    echo "Add 'current_ticket: TXXX' to the kanban frontmatter."
    exit 1
fi

# Check for verify file
VERIFY_FILE="aes/tickets/${CURRENT_TICKET}-verify.md"
if [ ! -f "$VERIFY_FILE" ]; then
    echo "Error: Verify file not found: $VERIFY_FILE"
    echo "Please run '/aes-verify' before requesting review."
    exit 1
fi

# Check if verify has verdict: pass
if ! grep -q "verdict: pass" "$VERIFY_FILE"; then
    echo "Error: Verification does not have verdict: pass in $VERIFY_FILE"
    echo "Please fix issues and re-run verification."
    exit 1
fi

# Check if diffstory is written in build file
BUILD_FILE="aes/tickets/${CURRENT_TICKET}-build.md"
if [ ! -f "$BUILD_FILE" ]; then
    echo "Error: Build file not found: $BUILD_FILE"
    echo "Please run '/aes-build' before requesting review."
    exit 1
fi
if ! grep -q "^## Diffstory" "$BUILD_FILE"; then
    echo "Error: Diffstory section not found in $BUILD_FILE"
    echo "The build output must include a '## Diffstory' section."
    exit 1
fi

echo "Pre-review checks passed."
exit 0
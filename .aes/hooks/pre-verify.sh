#!/bin/bash
# Pre-verify hook for AES
# Confirms build phase is complete before verification starts

echo "Running pre-verify checks..."

# Check if we're in an AES project
if [ ! -f "aes/kanban.md" ]; then
    echo "Error: Not in an AES project (missing aes/kanban.md)"
    exit 1
fi

# Get current ticket from kanban
CURRENT_TICKET=$(grep "current_ticket:" aes/kanban.md | awk '{print $2}' | head -1)
if [ -z "$CURRENT_TICKET" ]; then
    echo "Error: No current_ticket found in aes/kanban.md"
    exit 1
fi

# Check for build file
BUILD_FILE="aes/tickets/${CURRENT_TICKET}-build.md"
if [ ! -f "$BUILD_FILE" ]; then
    echo "Error: Build file not found: $BUILD_FILE"
    echo "Please run '/aes-build' before verifying."
    exit 1
fi

# Check if build is done
if ! grep -q "status: done" "$BUILD_FILE"; then
    echo "Error: Build phase not complete (status != done) in $BUILD_FILE"
    exit 1
fi

echo "Pre-verify checks passed."
exit 0
#!/bin/bash
# Pre-build hook for AES
# Checks if plan is done and validates critical files

echo "Running pre-build checks..."

# Check if we're in an AES project
if [ ! -f "aes/kanban.md" ]; then
    echo "Error: Not in an AES project (missing aes/kanban.md)"
    exit 1
fi

# Check if plan exists for current ticket
CURRENT_TICKET=$(grep "current_ticket:" aes/kanban.md | awk '{print $2}' | head -1)
if [ -z "$CURRENT_TICKET" ]; then
    echo "Error: No current_ticket found in aes/kanban.md"
    echo "Add 'current_ticket: TXXX' to the kanban frontmatter."
    exit 1
fi

# Check for plan file
PLAN_FILE="aes/tickets/${CURRENT_TICKET}-plan.md"
if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found: $PLAN_FILE"
    echo "Please run '/aes-plan' before building."
    exit 1
fi

# Check if plan is done
if ! grep -q "status: done" "$PLAN_FILE"; then
    echo "Error: Plan is not marked as done in $PLAN_FILE"
    echo "Please complete the plan phase before building."
    exit 1
fi

# Check for critical files
CRITICAL_FILES=("docs/VISION.md" "docs/REQUIREMENTS.md" "docs/ROADMAP.md")
for file in "${CRITICAL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Missing critical file: $file"
        exit 1
    fi
    
    # Check if file is not just a placeholder
    if grep -q "\[.*\]" "$file" && ! grep -qv "\[.*\]" "$file" | grep -qv "^[[:space:]]*$"; then
        echo "Warning: File $file appears to contain mostly placeholders"
    fi
done

echo "Pre-build checks passed."
exit 0
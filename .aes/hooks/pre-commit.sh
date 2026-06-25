#!/bin/sh
# Pre-commit hook for AES
# Blocks commits if current ticket's verification gate fails
# This is ENFORCEMENT: the commit cannot proceed without passing verification

set -e

echo ""
echo "══════════════════════════════════════════════════"
echo "  Pre-Commit Verification Gate"
echo "══════════════════════════════════════════════════"

if [ ! -f "aes/kanban.md" ]; then
  log "Not in an AES project — skipping"
  exit 0
fi

CURRENT_TICKET=$(grep "^current_ticket:" aes/kanban.md | awk '{print $2}')
if [ -z "$CURRENT_TICKET" ] || [ "$CURRENT_TICKET" = "none" ]; then
  log "No current_ticket — skipping verification gate"
  exit 0
fi

VERIFY_SCRIPT="scripts/verify-implementation.sh"
if [ ! -x "$VERIFY_SCRIPT" ]; then
  echo "  ⚠  verify-implementation.sh not found — verification gate SKIPPED"
  echo "  Install: make setup or create scripts/verify-implementation.sh"
  exit 0
fi

if ! "$VERIFY_SCRIPT" "$CURRENT_TICKET"; then
  echo ""
  echo "  ❌ VERIFICATION GATE BLOCKED"
  echo "  Ticket $CURRENT_TICKET has failing acceptance criteria."
  echo "  Fix the issues above before committing, or run:"
  echo "    SKIP_VERIFY=1 git commit"
  echo ""
  exit 1
fi

echo "  ✅ Verification gate passed for $CURRENT_TICKET"
echo ""
exit 0

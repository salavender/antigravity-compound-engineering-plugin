#!/bin/bash
# Atomically mark a plan as implemented with validation
# Usage: ./scripts/complete-plan.sh <plan-file>

set -euo pipefail

# Parse flags
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
  shift
fi

PLAN_FILE="${1:?Usage: complete-plan.sh [--force] <plan-file>}"

# Validation
if [[ ! -f "$PLAN_FILE" ]]; then
  echo "❌ File not found: $PLAN_FILE" >&2
  exit 1
fi

# Check for unchecked acceptance criteria (strict validation)
if grep -q "^- \[ \]" "$PLAN_FILE"; then
  if [[ "$FORCE" == "false" ]]; then
    unchecked_count=$(grep -c "^- \[ \]" "$PLAN_FILE")
    echo "❌ Error: $unchecked_count unchecked acceptance criteria found." >&2
    echo "All acceptance criteria must be checked before marking a plan as implemented." >&2
    echo "" >&2
    echo "Unchecked items:" >&2
    grep "^- \[ \]" "$PLAN_FILE" | head -5 | sed 's/^/  /' >&2
    echo "" >&2
    echo "Use --force to bypass this check (not recommended)." >&2
    exit 1
  else
    echo "⚠️  Warning: Bypassing acceptance criteria validation (--force used)."
  fi
fi

# Check current status
current_status=$(grep "^> Status:" "$PLAN_FILE" | head -1 || echo "")

if [[ -z "$current_status" ]]; then
  echo "❌ Error: No status line found in plan file." >&2
  echo "Expected format: > Status: Draft|Approved ✓" >&2
  exit 1
fi

# Update status atomically (portable sed for macOS)
# Support multiple status formats: Draft, Approved ✓, Approved
sed -i.bak 's/^> Status: Draft$/> Status: Implemented/' "$PLAN_FILE" && rm -f "${PLAN_FILE}.bak"
sed -i.bak 's/^> Status: Approved ✓$/> Status: Implemented/' "$PLAN_FILE" && rm -f "${PLAN_FILE}.bak"
sed -i.bak 's/^> Status: Approved$/> Status: Implemented/' "$PLAN_FILE" && rm -f "${PLAN_FILE}.bak"

# Verify the update worked
new_status=$(grep "^> Status:" "$PLAN_FILE" | head -1)

if [[ "$new_status" == "> Status: Implemented" ]]; then
  echo "✅ Plan marked as Implemented: $(basename "$PLAN_FILE")"
else
  echo "⚠️  Status updated but may need manual review: $new_status" >&2
fi

#!/bin/bash

CHANGELOG_PATH="CHANGELOG.md"

# Check if CHANGELOG exists
if [ ! -f "$CHANGELOG_PATH" ]; then
    echo "⚠️  CHANGELOG.md not found"
    exit 0
fi

# Count [Unreleased] sections
UNRELEASED_COUNT=$(grep -c "^## \[Unreleased\]" "$CHANGELOG_PATH")

# Check for merge conflict markers (use || true to handle zero matches)
CONFLICT_COUNT=$(grep -cE "^(<<<<<<< |>>>>>>> |=======)" "$CHANGELOG_PATH" 2>/dev/null || echo "0")

# Report issues
ERRORS=0

if [ "$UNRELEASED_COUNT" -gt 1 ]; then
    echo "❌ ERROR: Multiple [Unreleased] sections found: $UNRELEASED_COUNT"
    echo "   Run 'npm run changelog:gen' to consolidate"
    ERRORS=$((ERRORS + 1))
fi

if [ "$CONFLICT_COUNT" -gt 0 ]; then
    echo "❌ ERROR: Merge conflict markers found in CHANGELOG.md"
    echo "   Manually resolve conflicts before committing"
    ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
    echo "✅ CHANGELOG.md validation passed"
    exit 0
else
    exit 1
fi

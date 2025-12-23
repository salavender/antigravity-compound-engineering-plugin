#!/bin/bash
#
# validators/freshness.sh
# Part of: Unified Documentation Validation Framework
#
# Checks if documentation has been updated to reflect recent code changes.
# Warns if code was modified without corresponding documentation updates.
#
# Exit codes:
#   0 = Documentation is fresh (or no code changes)
#   2 = Code changed without doc updates (warning)
#   1 = Error
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "Checking documentation freshness..."

# If not in a git repo, skip
if ! git -C "$ROOT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
  echo "✓ Not a git repository; skipping freshness check."
  exit 0
fi

# Detect staged vs committed changes
if git -C "$ROOT_DIR" diff --cached --quiet; then
  # No staged changes; compare HEAD~1 to HEAD
  ref="HEAD~1..HEAD"
else
  # Staged changes exist; compare staged to HEAD
  ref=""
fi

# Find code changes
code_changed=$(git -C "$ROOT_DIR" diff $ref --name-only 2>/dev/null | grep -E '\.(ts|tsx|py|sh|js|jsx)$' || true)

if [ -z "$code_changed" ]; then
  echo "✓ No code changes detected."
  exit 0
fi

# Check if docs were updated
docs_changed=$(git -C "$ROOT_DIR" diff $ref --name-only 2>/dev/null | grep -E 'docs/' || true)

if [ -z "$docs_changed" ]; then
  echo "⚠ Code modified but no documentation updates found:"
  echo "$code_changed" | while read -r file; do
    echo "  - $file"
  done
  echo ""
  echo "Reminder: Update documentation to match code changes (README, ADRs, solutions, etc.)"
  exit 2  # Non-critical warning
fi

echo "✓ Documentation appears to be in sync with code changes."
exit 0

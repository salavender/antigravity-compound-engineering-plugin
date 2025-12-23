#!/bin/bash
# check-docs-freshness.sh - Warn if important changes lack documentation

set -e

# Check for skip flag
if [[ "$*" == *"--skip-docs"* ]]; then
    echo "⏭️  Skipping documentation freshness check (--skip-docs)"
    exit 0
fi

# Detect files changed in the pending commit (staged) or last commit if clean
if git diff --staged --name-only | grep -q .; then
    CHANGED_FILES=$(git diff --staged --name-only)
    COMMIT_MSG="staged changes"
else
    CHANGED_FILES=$(git diff HEAD~1 --name-only)
    COMMIT_MSG=$(git log -1 --pretty=%s)
fi

echo "🔍 Checking documentation freshness for: $COMMIT_MSG"

WARNINGS=0

# Helper to warn
warn() {
    echo "⚠️  $1"
    WARNINGS=$((WARNINGS + 1))
}

# 1. Check for new scripts
NEW_SCRIPTS=$(echo "$CHANGED_FILES" | grep "^scripts/" | grep -v "README")
if [ ! -z "$NEW_SCRIPTS" ]; then
    if ! echo "$CHANGED_FILES" | grep -q "scripts/README.md"; then
        warn "Scripts modified but scripts/README.md not updated."
    fi
fi

# 2. Check for new workflows
NEW_WORKFLOWS=$(echo "$CHANGED_FILES" | grep "^\.agent/workflows/" | grep -v "README")
if [ ! -z "$NEW_WORKFLOWS" ]; then
    if ! echo "$CHANGED_FILES" | grep -q ".agent/workflows/README.md"; then
        warn "Workflows modified but .agent/workflows/README.md not updated."
    fi
fi

# 3. Check for documentation updates for feature code
# (Simple heuristic: if src/ or components/ changed, check for ANY docs/ update)
CODE_CHANGED=$(echo "$CHANGED_FILES" | grep -E "^(src|components|lib|app)/")
DOCS_CHANGED=$(echo "$CHANGED_FILES" | grep "^docs/")

if [ ! -z "$CODE_CHANGED" ] && [ -z "$DOCS_CHANGED" ]; then
    warn "Code modified but no files in docs/ updated."
    echo "    (If this is internal/refactor, ignore. If feature work, update docs!)"
    echo "    (To bypass: run with --skip-docs)"
fi

if [ $WARNINGS -gt 0 ]; then
    echo ""
    echo "💡 Run '/work' to follow the documentation phase."
    # Exit 0 for soft warning, Exit 1 for hard blocker
    exit 0 
else
    echo "✅ Documentation checks passed."
    exit 0
fi

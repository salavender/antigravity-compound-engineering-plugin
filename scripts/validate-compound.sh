#!/bin/bash
# Validate compound system health
# Usage: ./scripts/validate-compound.sh

set -e

echo "🔍 Validating Compound System..."

exit_code=0

# Check 1: Unchecked deferred work in implementation_plan.md
if [ -f "implementation_plan.md" ]; then
    deferred_plan=$(grep -c '^- \[ \]' implementation_plan.md 2>/dev/null || echo 0)
    if [ "$deferred_plan" -gt 0 ]; then
        echo "⚠️  Found $deferred_plan unchecked items in implementation_plan.md"
        echo "   Check if they need todo files in todos/"
        exit_code=1
    fi
fi

# Check 2: Unchecked deferred work in plans/
if [ -d "plans" ]; then
    deferred_plans=$(grep -r '^- \[ \]' plans/ 2>/dev/null | wc -l)
    if [ "$deferred_plans" -gt 0 ]; then
        echo "⚠️  Found $deferred_plans unchecked items in plans/"
        exit_code=1
    fi
fi

# Check 3: Unchecked deferred work in explorations/
if [ -d "docs/explorations" ]; then
    deferred_explorations=$(grep -r '^- \[ \]' docs/explorations/ 2>/dev/null | grep -v "templates/" | wc -l)
    if [ "$deferred_explorations" -gt 0 ]; then
        echo "⚠️  Found $deferred_explorations unchecked items in docs/explorations/"
        exit_code=1
    fi
fi

# Check 3: Pattern Registry Validation
if [ -f "scripts/validate-patterns.sh" ]; then
    ./scripts/validate-patterns.sh
    if [ $? -ne 0 ]; then
        exit_code=1
    fi
fi

# Check 4: Check for empty todos directory (excluding template)
todo_count=$(ls todos/*.md 2>/dev/null | grep -v template | wc -l)
if [ "$todo_count" -eq 0 ]; then
    echo "ℹ️  No active todos found."
fi

if [ "$exit_code" -eq 0 ]; then
    echo "✅ Validation complete. System healthy."
else
    echo "❌ Validation failed. Please address items above."
fi

exit $exit_code

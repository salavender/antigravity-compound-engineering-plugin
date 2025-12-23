#!/bin/bash
# scripts/validate-architecture.sh
# Validates that docs/architecture/compound-system.md is up-to-date
# Usage: ./scripts/validate-architecture.sh

DOC_FILE="docs/architecture/compound-system.md"

if [ ! -f "$DOC_FILE" ]; then
    echo "❌ Error: Architecture document not found at $DOC_FILE"
    exit 1
fi

# 1. Extract Expected Counts from Frontmatter
EXPECTED_SKILLS=$(grep "skills:" "$DOC_FILE" | head -1 | awk '{print $2}')
EXPECTED_WORKFLOWS=$(grep "workflows:" "$DOC_FILE" | head -1 | awk '{print $2}')
EXPECTED_SCRIPTS=$(grep "scripts:" "$DOC_FILE" | head -1 | awk '{print $2}')
EXPECTED_PATTERNS=$(grep "patterns:" "$DOC_FILE" | head -1 | awk '{print $2}')

# 2. Count Actual Components
ACTUAL_SKILLS=$(ls -d skills/*/ 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_WORKFLOWS=$(ls .agent/workflows/*.md 2>/dev/null | grep -v README | wc -l | tr -d ' ')
ACTUAL_SCRIPTS=$(find scripts -maxdepth 1 -type f -not -name "README.md" -not -name ".*" | wc -l | tr -d ' ')
ACTUAL_PATTERNS=$(grep -c "^### Pattern" docs/solutions/patterns/critical-patterns.md)

# 3. Compare and Report
FAIL=0

if [ "$ACTUAL_SKILLS" -ne "$EXPECTED_SKILLS" ]; then
    echo "❌ Skills mismatch: Doc says $EXPECTED_SKILLS, Found $ACTUAL_SKILLS"
    FAIL=1
fi

if [ "$ACTUAL_WORKFLOWS" -ne "$EXPECTED_WORKFLOWS" ]; then
    echo "❌ Workflows mismatch: Doc says $EXPECTED_WORKFLOWS, Found $ACTUAL_WORKFLOWS"
    FAIL=1
fi

if [ "$ACTUAL_SCRIPTS" -ne "$EXPECTED_SCRIPTS" ]; then
    echo "❌ Scripts mismatch: Doc says $EXPECTED_SCRIPTS, Found $ACTUAL_SCRIPTS"
    FAIL=1
fi

if [ "$ACTUAL_PATTERNS" -ne "$EXPECTED_PATTERNS" ]; then
    echo "❌ Patterns mismatch: Doc says $EXPECTED_PATTERNS, Found $ACTUAL_PATTERNS"
    FAIL=1
fi

if [ "$FAIL" -eq 1 ]; then
    echo ""
    echo "⚠️  Architecture Document is stale!"
    echo "   Please update counts in $DOC_FILE"
    exit 1
fi

echo "✅ Architecture Document is up-to-date."
exit 0

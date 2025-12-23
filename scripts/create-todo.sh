#!/bin/bash
# scripts/create-todo.sh
# Creates a high-quality todo file following the project standard.
# Usage: ./scripts/create-todo.sh <priority> <title> <problem_statement> [criteria...]

set -euo pipefail

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <priority> <title> <problem_statement> <criteria1> [criteria2...]"
  echo "Example: $0 p2 \"Fix Bug\" \"The bug is...\" \"Criteria 1\" \"Criteria 2\""
  exit 1
fi

PRIORITY="$1"
TITLE="$2"
PROBLEM="$3"
shift 3
CRITERIA_ARGS=("$@")

# 1. Generate ID
NEXT_ID=$(./scripts/next-todo-id.sh)

# 2. Sanitize title for filename
# Lowercase, replace spaces with hyphens, remove non-alphanumeric, max 50 chars
SANITIZED_DESC=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)
FILENAME="todos/${NEXT_ID}-pending-${PRIORITY}-${SANITIZED_DESC}.md"

# 3. Create file content
cat > "$FILENAME" <<EOF
---
status: pending
priority: ${PRIORITY}
issue_id: "${NEXT_ID}"
tags: [generated, cleanup]
dependencies: []
---

# ${TITLE}

## Problem Statement

**What's broken/missing:**
${PROBLEM}

**Impact:**
This issue currently affects the system quality or functionality and needs to be addressed.

## Findings
- **Status:** Identified during workflow execution.
- **Priority:** ${PRIORITY}
- **System Impact:** This item is tracked to ensure continuous improvement of the codebase. Addressing it will contribute to overall system stability and feature completeness. The findings section provides context on origin and importance.

## Recommended Action
Implement the solution according to the acceptance criteria below.

## Acceptance Criteria
EOF

# Add criteria
for criteria in "${CRITERIA_ARGS[@]}"; do
  echo "- [ ] $criteria" >> "$FILENAME"
done

# Add standard closing
cat >> "$FILENAME" <<EOF

## Work Log

### $(date +%Y-%m-%d) - Created

**By:** Agent
**Actions:**
- Auto-generated via create-todo.sh

## Notes
Source: Workflow automation
EOF

echo "✅ Created todo: $FILENAME"
echo "   ID: $NEXT_ID"
echo "   Priority: $PRIORITY"
echo "   Title: $TITLE"

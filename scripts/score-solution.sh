#!/bin/bash
# Usage: ./scripts/score-solution.sh [solution_file]
# Returns: Quality score 0-10
# Example output: 9/10 (YAML: 2/2, Code: 3/3, Table: 2/2, Prevention: 1/2, Refs: 1/1)
# Verifies solution quality based on completeness
set -e

SOL_FILE="$1"

if [ -z "$SOL_FILE" ] || [ ! -f "$SOL_FILE" ]; then
    echo "Usage: $0 <solution_file>"
    exit 1
fi

SCORE=0

# --- 1. YAML Frontmatter (0-2) ---
# Check for required fields
YAML_SCORE=0
REQ_FIELDS=("date" "problem_type" "severity" "symptoms" "root_cause" "tags")
MISSING=0
for field in "${REQ_FIELDS[@]}"; do
    if ! grep -q "^$field:" "$SOL_FILE"; then
        MISSING=$((MISSING + 1))
    fi
done

if [ "$MISSING" -eq 0 ]; then YAML_SCORE=2
elif [ "$MISSING" -le 2 ]; then YAML_SCORE=1
fi
SCORE=$((SCORE + YAML_SCORE))

# --- 2. Code Examples (0-3) ---
# Count code blocks ```language
# We look for ``` followed by a letter (start of language)
CODE_BLOCK_COUNT=$(grep -c '```[a-zA-Z]' "$SOL_FILE")

CODE_SCORE=0
if [ "$CODE_BLOCK_COUNT" -ge 2 ]; then CODE_SCORE=3
elif [ "$CODE_BLOCK_COUNT" -ge 1 ]; then CODE_SCORE=2
fi
SCORE=$((SCORE + CODE_SCORE))

# --- 3. Investigation Table (0-2) ---
# Look for markdown table headers | ... | ... |
TABLE_SCORE=0
if grep -q "|.*|.*|" "$SOL_FILE"; then
    TABLE_SCORE=2
fi
SCORE=$((SCORE + TABLE_SCORE))

# --- 4. Prevention Section (0-2) ---
PREV_SCORE=0
if grep -q "^## Prevention" "$SOL_FILE"; then
    # Check if empty content?
    PREV_CONTENT=$(awk '/^## Prevention/{flag=1; next} /^## /{flag=0} flag' "$SOL_FILE" | wc -c | tr -d ' ')
    if [ "$PREV_CONTENT" -gt 50 ]; then
        PREV_SCORE=2
    elif [ "$PREV_CONTENT" -gt 0 ]; then
        PREV_SCORE=1
    fi
fi
SCORE=$((SCORE + PREV_SCORE))

# --- 5. Cross-References (0-1) ---
REF_SCORE=0
if grep -q "^## Cross-References" "$SOL_FILE"; then
    REF_SCORE=1
fi
SCORE=$((SCORE + REF_SCORE))

echo "$SCORE/10 (YAML: $YAML_SCORE/2, Code: $CODE_SCORE/3, Table: $TABLE_SCORE/2, Prevention: $PREV_SCORE/2, Refs: $REF_SCORE/1)"

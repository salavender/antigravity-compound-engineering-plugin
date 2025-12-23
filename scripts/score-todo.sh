#!/bin/bash
# Usage: ./scripts/score-todo.sh [todo_file]
# Returns: Quality score 0-10 with breakdown
# Example output: 8/10 (Problem: 3/3, Criteria: 3/3, Refs: 1/2, Context: 1/2)

TODO_FILE="$1"

if [ -z "$TODO_FILE" ] || [ ! -f "$TODO_FILE" ]; then
    echo "Usage: $0 <todo_file>"
    exit 1
fi

SCORE=0

# --- 1. Problem Statement (0-3) ---
# Check length of content between "## Problem Statement" and next section
# We'll use awk to extract the section
PROBLEM_TEXT=$(awk '/^## Problem Statement/{flag=1; next} /^## /{flag=0} flag' "$TODO_FILE" | tr -d '\n\r ')
DESC_LEN=${#PROBLEM_TEXT}

PROB_SCORE=0
if [ "$DESC_LEN" -gt 200 ]; then PROB_SCORE=3
elif [ "$DESC_LEN" -gt 80 ]; then PROB_SCORE=2
elif [ "$DESC_LEN" -gt 0 ]; then PROB_SCORE=1
fi
SCORE=$((SCORE + PROB_SCORE))

# --- 2. Acceptance Criteria (0-3) ---
# Count lines starting to "- [ ]"
# Use fixed string matching for safety, -- to stop flag parsing
CRITERIA_COUNT=$(grep -F -c -- "- [ ]" "$TODO_FILE")

AC_SCORE=0
if [ "$CRITERIA_COUNT" -ge 3 ]; then AC_SCORE=3
elif [ "$CRITERIA_COUNT" -ge 2 ]; then AC_SCORE=2
elif [ "$CRITERIA_COUNT" -ge 1 ]; then AC_SCORE=1
fi
SCORE=$((SCORE + AC_SCORE))

# --- 3. References (0-2) ---
REF_SCORE=0
if grep -q '\[.*\](file://' "$TODO_FILE"; then REF_SCORE=2
elif grep -q '\[.*\](' "$TODO_FILE"; then REF_SCORE=1
fi
SCORE=$((SCORE + REF_SCORE))

# --- 4. Context Extracted (0-2) ---
# Check if "## Context" or "## Findings" exists and has content
CONTEXT_TEXT=$(awk '/^## (Context|Findings)/{flag=1; next} /^## /{flag=0} flag' "$TODO_FILE" | tr -d '\n\r ')
CONTEXT_LEN=${#CONTEXT_TEXT}

CTX_SCORE=0
# Plan logic: "if > 100 then +2". Implicitly 0 otherwise?
# Let's be slightly more generous: > 20 chars = 1, > 100 = 2
if [ "$CONTEXT_LEN" -gt 100 ]; then CTX_SCORE=2
elif [ "$CONTEXT_LEN" -gt 20 ]; then CTX_SCORE=1
fi

SCORE=$((SCORE + CTX_SCORE))

echo "$SCORE/10 (Problem: $PROB_SCORE/3, Criteria: $AC_SCORE/3, Refs: $REF_SCORE/2, Context: $CTX_SCORE/2)"

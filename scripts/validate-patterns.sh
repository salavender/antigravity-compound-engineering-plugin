#!/bin/bash
# Validate critical-patterns.md integrity
# Ensures numerical continuity (1..N) and validates relative source links.

PATTERNS_FILE="docs/solutions/patterns/critical-patterns.md"
DOCS_ROOT="docs/solutions/patterns"

echo "🔍 Validating Pattern Registry ($PATTERNS_FILE)..."

if [ ! -f "$PATTERNS_FILE" ]; then
    echo "❌ Critical Error: $PATTERNS_FILE not found!"
    exit 1
fi

EXIT_CODE=0

# ---------------------------------------------------------
# 1. Numerical Continuity Check
# ---------------------------------------------------------
echo "Checking numerical continuity..."

# Extract pattern numbers
# 1. grep headers "### Pattern #12"
# 2. sed to capture the number
# 3. sort numerically
pattern_numbers=$(grep -E "^### Pattern #[0-9]+" "$PATTERNS_FILE" | sed -E 's/### Pattern #([0-9]+).*/\1/' | sort -n)

expected=1
count=0
gap_found=0

for num in $pattern_numbers; do
    # Remove leading zeros if any (bash treats 08 as octal otherwise, though sort -n handles output well)
    num=$((10#$num))
    
    if [ "$num" -ne "$expected" ]; then
        echo "❌ Gap or Sequence Error: Expected Pattern #$expected but found #$num"
        gap_found=1
        EXIT_CODE=1
        # Sync expected to next number to allow finding more errors or just continue?
        # Let's just adjust expected to current + 1 to try and continue linear check
        expected=$(($num + 1))
    else
        expected=$(($expected + 1))
    fi
    count=$(($count + 1))
done

if [ "$gap_found" -eq 0 ]; then
    echo "✅ Pattern sequence is valid (Count: $count)"
else
    echo "❌ Pattern sequence check failed."
fi

# ---------------------------------------------------------
# ---------------------------------------------------------
# 2. Source Link Validation
# ---------------------------------------------------------
echo "Checking source links..."
# Use a temp file to track errors to avoid subshell variable scope issues
error_log=$(mktemp)
grep_output=$(mktemp)

# Debug: check if grep works
if ! command -v grep &> /dev/null; then
    echo "❌ Error: grep command not found"
    exit 1
fi

grep -n "Source:" "$PATTERNS_FILE" > "$grep_output"

# Read from temp file
while read -r line; do
    # Format: "line_number:Source: [Link Text](path)"
    
    line_num=$(echo "$line" | cut -d: -f1)
    content=$(echo "$line" | cut -d: -f2-)
    
    # Extract path between parenthesis - non-greedy match for content inside first parens after brackets
    link_path=$(echo "$content" | sed -E 's/.*\]\(([^)]*)\).*/\1/')
    
    if [ -z "$link_path" ] || [ "$link_path" = "$content" ]; then
        continue
    fi

    if [[ "$link_path" == http* ]]; then
        continue
    fi
    
    # Ignore absolute file paths (artifacts)
    if [[ "$link_path" == file://* ]]; then
        continue
    fi

    check_path="$DOCS_ROOT/$link_path"
    
    if [ ! -f "$check_path" ]; then
        echo "❌ Broken link on line $line_num: $link_path"
        echo "   (Checked path: $check_path)"
        echo "error" >> "$error_log"
    fi

done < "$grep_output"

rm "$grep_output"

if [ -s "$error_log" ]; then
    echo "❌ Source link validation failed."
    EXIT_CODE=1
else
    echo "✅ All source links are valid."
fi
rm "$error_log"

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "🎉 Validation Passed: Pattern Registry is healthy."
else
    echo "🚫 Validation Failed."
fi

exit $EXIT_CODE

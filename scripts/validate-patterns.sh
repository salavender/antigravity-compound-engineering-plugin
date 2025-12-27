#!/bin/bash
# scripts/validate-patterns.sh
# Validates numerical sequence and link integrity in critical-patterns.md
# and individual pattern files.

# Instrumentation
./scripts/log-skill.sh "pattern-validation" "automated" "$$"

PATTERNS_INDEX="docs/solutions/patterns/critical-patterns.md"
INDIVIDUAL_DIR="docs/solutions/patterns/individual"
EXIT_CODE=0

echo "🔍 Validating Pattern Registry..."

if [ ! -f "$PATTERNS_INDEX" ]; then
    echo "❌ Error: $PATTERNS_INDEX not found."
    exit 1
fi

# 1. Index Continuity and Link Check
echo "   Checking critical-patterns.md index..."
patterns=$(grep -oE "\[[^]]*\]\(\./individual/pattern-([0-9]+)-.*\.md\)" "$PATTERNS_INDEX" | sed -E 's/.*pattern-([0-9]+)-.*/\1/')

current=0
for p in $patterns; do
    expected=$((current + 1))
    # Remove leading zeros
    p_num=$((10#$p))
    if [ "$p_num" -ne "$expected" ]; then
        echo "   ❌ Gap detected in index: Found Pattern #$p_num but expected #$expected"
        EXIT_CODE=1
    fi
    current=$p_num
done

if [ "$current" -eq 0 ]; then
    echo "   ❌ No patterns found in index."
    EXIT_CODE=1
fi

# 2. Individual File Validation
echo "   Checking individual pattern files in $INDIVIDUAL_DIR..."
files=$(ls "$INDIVIDUAL_DIR"/pattern-*.md 2>/dev/null)

if [ -z "$files" ]; then
    echo "   ❌ No individual pattern files found!"
    EXIT_CODE=1
fi

for f in $files; do
    fname=$(basename "$f")
    # Extract number from filename
    f_num=$(echo "$fname" | sed -E 's/pattern-([0-9]+)-.*/\1/')
    f_num=$((10#$f_num))
    
    # Check frontmatter matches filename
    fm_num=$(grep "pattern_number:" "$f" | awk '{print $2}')
    if [ -z "$fm_num" ] || [ "$fm_num" -ne "$f_num" ]; then
        echo "   ❌ Frontmatter mismatch in $fname: pattern_number=$fm_num"
        EXIT_CODE=1
    fi
    
    # Check for domain-specific terms (Safety check for white-labeling)
    if grep -Ei "InvestOS|Portfolio|FundAdmin" "$f" > /dev/null; then
        echo "   ⚠️ Warning: Potential domain-specific term in $fname"
        # We don't fail for warnings unless they are certain InvestOS references
        if grep -i "InvestOS" "$f" > /dev/null; then
            echo "   ❌ Found 'InvestOS' in $fname - FAILED"
            EXIT_CODE=1
        fi
    fi

    # Check relative links in the individual file
    # We look for links like [Text](../../category/file.md)
    links=$(grep -oE "\[[^]]*\]\(\.{1,3}/[^)]*\)" "$f" | sed -E 's/\[[^]]*\]\(([^)]*)\)/\1/')
    for link in $links; do
        clean_link=$(echo "$link" | cut -d'#' -f1)
        # Resolved path relative to the file's dir (INDIVIDUAL_DIR)
        target=$(realpath -m "$INDIVIDUAL_DIR/$clean_link")
        # Check if it exists within the project root
        project_root=$(pwd)
        if [ ! -f "$target" ] && [ ! -d "$target" ]; then
             echo "   ❌ Broken link in $fname: $link (Target not found)"
             EXIT_CODE=1
        fi
    done
done

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "   ✅ Pattern registry and modular files are valid ($current patterns checked)."
else
    echo "   ❌ Pattern validation contains errors."
fi

exit $EXIT_CODE


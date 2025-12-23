#!/bin/bash

# validate-spec-consistency.sh
# Validates that spec phases marked complete have:
# 1. VERIFICATION/phase{N}-complete.md files
# 2. Plan files with no unchecked acceptance criteria (warning only)

set -e

SPECS_DIR="docs/specs"
ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Validating spec consistency..."
echo ""

# Find all spec directories (exclude templates)
for SPEC_DIR in "$SPECS_DIR"/*/; do
    SPEC_NAME=$(basename "$SPEC_DIR")
    
    # Skip templates
    [[ "$SPEC_NAME" == "templates" ]] && continue
    
    TASKS_FILE="$SPEC_DIR/03-tasks.md"
    [[ ! -f "$TASKS_FILE" ]] && continue
    
    # Extract completed phases from 03-tasks.md summary table
    # Look for lines like: | Phase 1: ... | ✅ ... |
    COMPLETED_PHASES=$(grep -E '^\| Phase [0-9]+:.*\| ✅' "$TASKS_FILE" 2>/dev/null | \
        sed -n 's/.*Phase \([0-9]\+\):.*/\1/p' || true)
    
    for PHASE_NUM in $COMPLETED_PHASES; do
        VERIFICATION_FILE="$SPEC_DIR/VERIFICATION/phase${PHASE_NUM}-complete.md"
        
        # Check 1: Verification file exists
        if [[ ! -f "$VERIFICATION_FILE" ]]; then
            echo -e "${RED}ERROR:${NC} Missing verification file for $SPEC_NAME Phase $PHASE_NUM"
            echo "       Expected: $VERIFICATION_FILE"
            echo "       Fix: Run ./scripts/update-spec-phase.sh $SPEC_NAME $PHASE_NUM complete"
            echo ""
            ((ERRORS++))
        fi
        
        # Check 2: Plan file has no unchecked items (warning only)
        PLAN_FILE=$(find "$SPEC_DIR/plans" -name "phase${PHASE_NUM}-*.md" -o -name "phase${PHASE_NUM}_*.md" 2>/dev/null | head -1)
        
        if [[ -n "$PLAN_FILE" && -f "$PLAN_FILE" ]]; then
            # Count unchecked items in Acceptance Criteria section
            # Look for lines starting with "- [ ]"
            UNCHECKED_COUNT=$(grep -c '^\s*- \[ \]' "$PLAN_FILE" 2>/dev/null || echo "0")
            
            if [[ "$UNCHECKED_COUNT" -gt 0 ]]; then
                echo -e "${YELLOW}WARNING:${NC} $SPEC_NAME Phase $PHASE_NUM has $UNCHECKED_COUNT unchecked items in plan"
                echo "         File: $PLAN_FILE"
                echo "         Fix: Update acceptance criteria to [x] or add notes for descoped items"
                echo ""
                ((WARNINGS++))
            fi
        fi
    done
done

# Summary
echo "---"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✓ All specs are consistent${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠ Spec consistency check passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}✗ Spec consistency check failed: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
fi

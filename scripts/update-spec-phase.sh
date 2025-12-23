#!/bin/bash

# update-spec-phase.sh
# Automates updating spec status across README.md, 03-tasks.md, and 00-START-HERE.md

SPEC_NAME=$1
PHASE_NUM=$2
STATUS=$3 # "complete" or "started" or "not_started"

if [[ -z "$SPEC_NAME" || -z "$PHASE_NUM" || -z "$STATUS" ]]; then
    echo "Usage: $0 <spec_name> <phase_number> <status>"
    echo "Example: $0 compound-measurement 2 complete"
    exit 1
fi

SPEC_DIR="docs/specs/$SPEC_NAME"
if [[ ! -d "$SPEC_DIR" ]]; then
    echo "Error: Spec directory not found: $SPEC_DIR"
    exit 1
fi

README_FILE="$SPEC_DIR/README.md"
TASKS_FILE="$SPEC_DIR/03-tasks.md"
START_FILE="$SPEC_DIR/00-START-HERE.md"
SPEC_YAML="$SPEC_DIR/spec.yaml"

# --- NEW: spec.yaml Logic ---
if [[ -f "$SPEC_YAML" ]]; then
    echo "Found $SPEC_YAML. Updating structured data..."
    
    # Update spec.yaml using python
    python3 -c "
import re, sys
content = sys.stdin.read()
phase = '$PHASE_NUM'
status = '$STATUS'
# Map status to progress
progress = '100' if status == 'complete' else ('50' if status == 'started' else '0')

# Update phase block
phase_pattern = fr'^  {phase}:(.*?)(?=(^  \d+:|\Z))'
def update_phase(match):
    block = match.group(1)
    block = re.sub(r'status: \".*?\"', f'status: \"{status}\"', block)
    block = re.sub(r'progress: \d+', f'progress: {progress}', block)
    return f'  {phase}:' + block

if re.search(phase_pattern, content, re.M | re.S):
    new_content = re.sub(phase_pattern, update_phase, content, flags=re.M | re.S)
else:
    # If phase doesn't exist, we might want to fail or just ignore
    new_content = content

# Also update current_phase if status is started
if status == 'started':
    new_content = re.sub(r'^current_phase:.*', f'current_phase: {phase}', new_content, flags=re.M)

sys.stdout.write(new_content)
" < "$SPEC_YAML" > "${SPEC_YAML}.tmp" && mv "${SPEC_YAML}.tmp" "$SPEC_YAML"

    # Synchronize to markdown
    ./scripts/sync-spec.sh "$SPEC_DIR"
    
    # Continue to Phase Completion Protocol below (don't exit early)
    USED_SPEC_YAML=true
else
    USED_SPEC_YAML=false
fi
# --- End spec.yaml Logic ---

# Only run legacy logic if we didn't use spec.yaml
if [[ "$USED_SPEC_YAML" != "true" ]]; then

# Determine Icons and Text
case $STATUS in
    complete)
        ICON="✅"
        TEXT="Complete"
        PERCENT="100%"
        BAR="▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"
        ;;
    started)
        ICON="\[\/\]"
        TEXT="In Progress"
        PERCENT="50%"
        BAR="▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░"
        ;;
    not_started)
        ICON="❌"
        TEXT="Not Started"
        PERCENT="0%"
        BAR="░░░░░░░░░░░░░░░░░░░░"
        ;;
    *)
        echo "Error: Status must be 'complete', 'started', or 'not_started'"
        exit 1
        ;;
esac

# 1. Update README.md Progress Bar
# Pattern: Phase <N>:     [BAR] <PERCENT> <STATUS>
if [[ -f "$README_FILE" ]]; then
    echo "Updating $README_FILE..."
    # macOS sed workaround (non-destructive)
    perl -pi -e "s/^Phase $PHASE_NUM:.*$/Phase $PHASE_NUM:     $BAR    $PERCENT $TEXT/" "$README_FILE"
fi

# 2. Update 03-tasks.md Summary Table
# Pattern: | Phase <N>: <Desc> | <STATUS> | <PERCENT> | ... |
if [[ -f "$TASKS_FILE" ]]; then
    echo "Updating $TASKS_FILE..."
    # Match the row for Phase N and update the status columns
    perl -pi -e "s/^\| Phase $PHASE_NUM:.*?\|.*?\|.*?\|/| Phase $PHASE_NUM: \@\@\@ | $ICON $TEXT | $PERCENT |/g" "$TASKS_FILE"
    # Note: Description @@@ is a placeholder to keep it simple, but let's try to preserve it
    # Better: match the second and third columns specifically
    perl -pi -e "s/^(\| Phase $PHASE_NUM:.*?\|).*?\|.*?\|/\$1 $ICON $TEXT | $PERCENT |/" "$TASKS_FILE"
    
    # Also update Phase N header status if it exists
    # Pattern: ## Phase <N>: ... \n\n ... \n**Status:** ...
    # This is multi-line, perl is better
    perl -0777 -pi -e "s/(## Phase $PHASE_NUM:.*?\n\n.*?\n\*\*Status:\*\* ).*?\n/\$1$ICON $TEXT\n/s" "$TASKS_FILE"
fi

# 3. Update 00-START-HERE.md
if [[ -f "$START_FILE" ]]; then
    echo "Updating $START_FILE..."
    # Update Current Phase line
    if [[ "$STATUS" == "started" ]]; then
        perl -pi -e "s/^\*\*Current Phase:\*\* .*$/\*\*Current Phase:\*\* Phase $PHASE_NUM/" "$START_FILE"
    fi
    
    # Log Accomplishment if complete
    if [[ "$STATUS" == "complete" ]]; then
        # Check if already logged
        if ! grep -q "Phase $PHASE_NUM Complete" "$START_FILE"; then
            # Insert after "### Recent Accomplishments" header
            perl -pi -e "s/### Recent Accomplishments/### Recent Accomplishments\n- $ICON **Phase $PHASE_NUM Complete**/" "$START_FILE"
        fi
    fi
fi

fi # End of legacy logic (USED_SPEC_YAML != true)

# --- Phase Completion Protocol ---
# When completing a phase, we need to:
# 1. Create VERIFICATION/phase{N}-complete.md
# 2. Warn if plan file has unchecked acceptance criteria

if [[ "$STATUS" == "complete" ]]; then
    VERIFICATION_DIR="$SPEC_DIR/VERIFICATION"
    VERIFICATION_FILE="$VERIFICATION_DIR/phase${PHASE_NUM}-complete.md"
    
    # Create verification file if it doesn't exist
    if [[ ! -f "$VERIFICATION_FILE" ]]; then
        mkdir -p "$VERIFICATION_DIR"
        
        # Generate verification document
        cat > "$VERIFICATION_FILE" << 'VERIFICATION_EOF'
# Phase PHASE_NUM Verification

> **Spec:** [Parent Spec](../README.md)
> **Phase:** PHASE_NUM
> **Completed:** COMPLETION_DATE

## Exit Criteria Verification

<!-- Check each exit criterion from 03-tasks.md -->

- [x] All tasks in phase marked complete
- [x] Exit criteria met
- [ ] Verification evidence documented below

## Evidence

### Build/Test Results
<!-- Paste relevant output or screenshots -->

```
# Add verification commands and their output here
```

### Manual Verification
<!-- Document any manual checks performed -->

- [ ] Verified in browser/app
- [ ] Tested edge cases

## Notes

<!-- Any additional context, blockers resolved, or lessons learned -->

---

**Verified by:** Agent
**Date:** COMPLETION_DATE
VERIFICATION_EOF

        # Replace placeholders
        sed -i '' "s/PHASE_NUM/$PHASE_NUM/g" "$VERIFICATION_FILE" 2>/dev/null || \
        sed -i "s/PHASE_NUM/$PHASE_NUM/g" "$VERIFICATION_FILE"
        
        TODAY=$(date +%Y-%m-%d)
        sed -i '' "s/COMPLETION_DATE/$TODAY/g" "$VERIFICATION_FILE" 2>/dev/null || \
        sed -i "s/COMPLETION_DATE/$TODAY/g" "$VERIFICATION_FILE"
        
        echo "✓ Created verification file: $VERIFICATION_FILE"
        echo "  → Please fill in the evidence section"
    else
        echo "ℹ Verification file already exists: $VERIFICATION_FILE"
    fi
    
    # Check for unchecked acceptance criteria in plan file
    PLAN_DIR="$SPEC_DIR/plans"
    if [[ -d "$PLAN_DIR" ]]; then
        # Find plan file for this phase
        PLAN_FILE=$(find "$PLAN_DIR" -name "phase${PHASE_NUM}-*.md" -o -name "phase${PHASE_NUM}_*.md" 2>/dev/null | head -1)
        
        if [[ -n "$PLAN_FILE" && -f "$PLAN_FILE" ]]; then
            # Count unchecked acceptance criteria in the file
            UNCHECKED_COUNT=$(grep -c '^\s*- \[ \]' "$PLAN_FILE" 2>/dev/null || echo "0")
            
            if [[ "$UNCHECKED_COUNT" -gt 0 ]]; then
                echo ""
                echo "⚠️  WARNING: Plan file has $UNCHECKED_COUNT unchecked items:"
                echo "   $PLAN_FILE"
                echo ""
                echo "   Options:"
                echo "   1. Update the plan file acceptance criteria to [x]"
                echo "   2. If items were descoped, add notes explaining why"
                echo ""
                grep -n '^\s*- \[ \]' "$PLAN_FILE" | head -5
                [[ "$UNCHECKED_COUNT" -gt 5 ]] && echo "   ... and $((UNCHECKED_COUNT - 5)) more"
            else
                echo "✓ Plan file acceptance criteria all checked"
            fi
        fi
    fi
fi

echo "✓ Spec status updated for $SPEC_NAME Phase $PHASE_NUM to $STATUS"

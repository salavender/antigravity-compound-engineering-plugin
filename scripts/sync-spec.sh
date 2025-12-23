#!/bin/bash

# sync-spec.sh
# Synchronizes markdown files (README.md, 03-tasks.md, 00-START-HERE.md)
# with the structured data in spec.yaml

SPEC_DIR=$1

if [[ -z "$SPEC_DIR" ]]; then
    echo "Usage: $0 <spec_directory>"
    exit 1
fi

SPEC_YAML="$SPEC_DIR/spec.yaml"
if [[ ! -f "$SPEC_YAML" ]]; then
    echo "Error: spec.yaml not found in $SPEC_DIR"
    exit 1
fi

README_FILE="$SPEC_DIR/README.md"
TASKS_FILE="$SPEC_DIR/03-tasks.md"
START_FILE="$SPEC_DIR/00-START-HERE.md"

# Helper to extract value from spec.yaml using python (no PyYAML needed)
get_val() {
    python3 -c "
import re, sys
content = sys.stdin.read()
key = '$1'
match = re.search(fr'^{key}:\s*([^#\n]*)', content, re.M)
if match:
    # Strip quotes and then strip again for extra safety
    val = match.group(1).strip().strip('\"').strip('\'').strip()
    print(val)
" < "$SPEC_YAML"
}

# Helper to extract phase data
get_phase_val() {
    local phase=$1
    local key=$2
    python3 -c "
import re, sys
content = sys.stdin.read()
phase = '$phase'
key = '$key'
# Find the phase block
phase_match = re.search(fr'^  {phase}:(.*?)(?=(^  \d+:|\Z))', content, re.M | re.S)
if phase_match:
    block = phase_match.group(1)
    val_match = re.search(fr'^\s+{key}:\s*([^#\n]*)', block, re.M)
    if val_match:
        val = val_match.group(1).strip().strip('\"').strip('\'').strip()
        print(val)
" < "$SPEC_YAML"
}

NAME=$(get_val "name")
CURRENT_PHASE=$(get_val "current_phase")
TODAY=$(date +%Y-%m-%d)

echo "Syncing spec: $NAME (Current Phase: $CURRENT_PHASE)"

# 1. Update README.md
if [[ -f "$README_FILE" ]]; then
    echo "Updating $README_FILE..."
    
    # Update Status line
    # **Status**: {X}% Complete | **Current Phase**: Phase {N} - {Name}
    PHASE_NAME=$(get_phase_val "$CURRENT_PHASE" "name")
    
    # Calculate total progress (average of phases)
    TOTAL_PROGRESS=$(python3 -c "
import re, sys
content = sys.stdin.read()
progresses = re.findall(r'^\s+progress:\s*(\d+)', content, re.M)
if progresses:
    print(round(sum(map(int, progresses))/len(progresses)))
else:
    print(0)
" < "$SPEC_YAML")

    perl -pi -e "s/^\*\*Status\*\*: .*$/\*\*Status\*\*: $TOTAL_PROGRESS% Complete | \*\*Current Phase\*\*: Phase $CURRENT_PHASE - $PHASE_NAME/" "$README_FILE"
    
    # Update Progress Bars in Status Block
    # Phase N:     [BAR] <PERCENT> <STATUS>
    
    # We need to iterate over all phases present in the YAML
    PHASES=$(python3 -c "import re, sys; print(' '.join(re.findall(r'^\s+(\d+):', sys.stdin.read(), re.M)))" < "$SPEC_YAML")
    
    for p in $PHASES; do
        P_STATUS=$(get_phase_val "$p" "status")
        P_PROGRESS=$(get_phase_val "$p" "progress")
        
        # Format Status Text
        case $P_STATUS in
            complete) TEXT="Complete" ;;
            started) TEXT="In Progress" ;;
            not_started) TEXT="Not Started" ;;
        esac
        
        # Format Bar (20 chars)
        BAR_COUNT=$((P_PROGRESS / 5))
        EMPTY_COUNT=$((20 - BAR_COUNT))
        BAR=""
        for ((i=0; i<BAR_COUNT; i++)); do BAR="${BAR}█"; done
        for ((i=0; i<EMPTY_COUNT; i++)); do BAR="${BAR}░"; done
        
        perl -pi -e "s/^Phase $p:.*$/Phase $p:     $BAR    $P_PROGRESS% $TEXT/" "$README_FILE"
    done
    
    perl -pi -e "s/^\*\*Last Updated\*\*: .*$/\*\*Last Updated\*\*: $TODAY/" "$README_FILE"
fi

# 2. Update 03-tasks.md Summary Table
if [[ -f "$TASKS_FILE" ]]; then
    echo "Updating $TASKS_FILE..."
    
    PHASES=$(python3 -c "import re, sys; print(' '.join(re.findall(r'^\s+(\d+):', sys.stdin.read(), re.M)))" < "$SPEC_YAML")
    
    for p in $PHASES; do
        P_NAME=$(get_phase_val "$p" "name")
        P_STATUS=$(get_phase_val "$p" "status")
        P_PROGRESS=$(get_phase_val "$p" "progress")
        
        case $P_STATUS in
            complete) ICON="✅"; TEXT="Complete" ;;
            started) ICON="🔄"; TEXT="In Progress" ;;
            not_started) ICON="❌"; TEXT="Not Started" ;;
        esac
        
        # Update table row
        # | Phase <N>: <Name> | <ICON> <TEXT> | <PROGRESS>% | ... |
        # Use a more flexible regex to match the row
        perl -pi -e "s/^\| Phase $p:.*?\|.*?\|.*?\|/| Phase $p: $P_NAME | $ICON $TEXT | $P_PROGRESS% |/g" "$TASKS_FILE"
        
        # Also update Phase Header Status if it exists
        perl -0777 -pi -e "s/(## Phase $p:.*?\n\n.*?\n\*\*Status:\*\* ).*?\n/\$1$ICON $TEXT\n/s" "$TASKS_FILE"
    done
    
    perl -pi -e "s/^\*\*Last Updated\*\*: .*$/\*\*Last Updated\*\*: $TODAY/" "$TASKS_FILE"
fi

# 3. Update 00-START-HERE.md
if [[ -f "$START_FILE" ]]; then
    echo "Updating $START_FILE..."
    perl -pi -e "s/^\*\*Current Phase:\*\* .*$/\*\*Current Phase:\*\* Phase $CURRENT_PHASE/" "$START_FILE"
fi

echo "✓ Spec synchronized from spec.yaml"

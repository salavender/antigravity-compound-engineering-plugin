#!/bin/bash
# Audit all lifecycle-managed documents for state drift
# Checks if status metadata matches completion checkboxes

set -euo pipefail

FIX=false
if [[ "${1:-}" == "--fix" ]]; then
  FIX=true
fi

echo "🔍 Auditing Lifecycle Document State Consistency..."
echo ""

DRIFT_COUNT=0
FIX_COUNT=0

# Function to check a single file
check_file() {
  local file="$1"
  local doc_type="$2"
  
  # Count total checkboxes and checked boxes
  local total=$(grep -c "^- \[.\]" "$file" 2>/dev/null | tr -d '\n' || echo 0)
  local checked=$(grep -c "^- \[x\]" "$file" 2>/dev/null | tr -d '\n' || echo 0)
  
  # Skip files with no checkboxes
  if [ "$total" -eq 0 ]; then
    return
  fi
  
  # Extract status and the matching line
  local status_line=""
  local status=""
  
  if grep -qi "^status:" "$file"; then
    status_line=$(grep -i "^status:" "$file" | head -1)
    status=$(echo "$status_line" | sed 's/status://I' | xargs)
  elif grep -i "^> Status:" "$file"; then
    status_line=$(grep -i "^> Status:" "$file" | head -1)
    status=$(echo "$status_line" | sed 's/.*Status://' | xargs)
  else
    status="UNKNOWN"
  fi
  
  # Determine if complete
  local is_complete=false
  if [ "$checked" -eq "$total" ] && [ "$total" -gt 0 ]; then
    is_complete=true
  fi
  
  # Check for drift
  local has_drift=false
  local new_status=""
  
  if [ "$doc_type" = "plan" ]; then
    if [ "$is_complete" = true ] && [[ ! "$status" =~ (Implemented|Complete) ]]; then
      has_drift=true
      new_status="Implemented"
    elif [ "$is_complete" = false ] && [[ "$status" =~ (Implemented|Complete) ]]; then
      has_drift=true
      new_status="Draft"
    fi
  elif [ "$doc_type" = "todo" ]; then
    if [ "$is_complete" = true ] && [[ ! "$status" =~ (done) ]]; then
      has_drift=true
      new_status="done"
    elif [ "$is_complete" = false ] && [[ "$status" =~ (done) ]]; then
      has_drift=true
      new_status="pending" # Or keep original if it was ready/pending
    fi
  fi
  
  if [ "$has_drift" = true ]; then
    if [ "$FIX" = true ] && [ -n "$new_status" ]; then
      if [[ "$status_line" =~ ^status: ]]; then
        sed -i.bak "s/^status:.*/status: $new_status/I" "$file" && rm -f "${file}.bak"
      elif [[ "$status_line" =~ ^\>\ Status: ]]; then
        sed -i.bak "s/^> Status:.*/> Status: $new_status/I" "$file" && rm -f "${file}.bak"
      fi

      echo "🔧 FIXED: $(basename "$file") ($status → $new_status)"
      FIX_COUNT=$((FIX_COUNT + 1))
    else
      echo "❌ DRIFT: $(basename "$file")"
      echo "   Status: $status | Checked: $checked/$total | Expected: $new_status"
      DRIFT_COUNT=$((DRIFT_COUNT + 1))
    fi
  fi
}

# Audit plans/
echo "📋 Checking plans/..."
for file in plans/*.md; do
  if [ -f "$file" ]; then
    check_file "$file" "plan"
  fi
done

# Audit todos/
echo "✅ Checking todos/..."
for file in todos/*.md; do # Only check active todos, archive is expected to be complete
  if [ -f "$file" ] && [[ ! "$file" =~ template ]]; then
    check_file "$file" "todo"
  fi
done

# Audit specs/ (basic check)
echo "📚 Checking docs/specs/..."
for file in docs/specs/**/*.md; do
  if [ -f "$file" ]; then
    check_file "$file" "spec"
  fi
done

echo ""
if [ "$DRIFT_COUNT" -eq 0 ] && [ "$FIX_COUNT" -eq 0 ]; then
  echo "✅ No state drift detected!"
elif [ "$FIX_COUNT" -gt 0 ]; then
  echo "✅ Fixed $FIX_COUNT documents!"
  [[ "$DRIFT_COUNT" -gt 0 ]] && echo "⚠️  Remaining drift in $DRIFT_COUNT documents."
else
  echo "⚠️  Found $DRIFT_COUNT documents with state drift."
  echo "Run with --fix flag to auto-correct."
fi

exit $((DRIFT_COUNT > 0 ? 1 : 0))


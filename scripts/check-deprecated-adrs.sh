#!/bin/bash
# Check for deprecated ADRs that haven't been reviewed in 6+ months
#
# Usage: ./scripts/check-deprecated-adrs.sh
#
# Exit codes:
#   0 = Always (non-blocking, informational only)

set -euo pipefail

ADR_DIR="docs/decisions"
SIX_MONTHS_AGO=$(date -v-6m +%Y-%m-%d 2>/dev/null || date -d "6 months ago" +%Y-%m-%d)
WARNINGS=0

# Check if ADR directory exists
if [[ ! -d "$ADR_DIR" ]]; then
  echo "ℹ No ADR directory found at $ADR_DIR"
  exit 0
fi

for file in "$ADR_DIR"/*.md; do
  [[ -f "$file" ]] || continue
  
  # Skip template and README
  basename=$(basename "$file")
  [[ "$basename" == "adr-template.md" ]] && continue
  [[ "$basename" == "README.md" ]] && continue
  
  # Check if status is deprecated
  status=$(grep -E "^status:" "$file" 2>/dev/null | head -1 | sed 's/status:[[:space:]]*//' | tr -d '"' | tr -d "'" || echo "")
  
  if [[ "$status" == "deprecated" ]]; then
    # Get last_referenced date
    last_ref=$(grep -E "^last_referenced:" "$file" 2>/dev/null | head -1 | sed 's/last_referenced:[[:space:]]*//' | tr -d '"' | tr -d "'" || echo "")
    
    if [[ -z "$last_ref" ]]; then
      echo "⚠ $basename: deprecated but missing last_referenced date"
      WARNINGS=$((WARNINGS + 1))
    elif [[ "$last_ref" < "$SIX_MONTHS_AGO" ]]; then
      echo "⚠ $basename: deprecated and not reviewed since $last_ref (>6 months)"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done

if [[ $WARNINGS -eq 0 ]]; then
  echo "✓ No deprecated ADRs need review"
fi

exit 0

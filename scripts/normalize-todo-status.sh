#!/bin/bash
# Normalize non-standard status values to standard equivalents
# Usage: ./scripts/normalize-todo-status.sh [--dry-run|--apply]

set -euo pipefail

DRY_RUN=true

# Parse arguments
if [[ "${1:-}" == "--apply" ]]; then
  DRY_RUN=false
elif [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $0 [--dry-run|--apply]"
  exit 1
fi

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${YELLOW}[DRY-RUN MODE]${NC} Showing what would be normalized"
else
  echo -e "${BLUE}[APPLY MODE]${NC} Normalizing status values"
fi
echo ""

NORMALIZED_COUNT=0

for file in todos/*.md todos/archive/*.md; do
  [[ -f "$file" ]] || continue
  [[ "$(basename "$file")" == "todo-template.md" ]] && continue
  
  # Check if file contains status values to normalize
  if grep -qE "^status: (complete|completed)$" "$file"; then
    if [[ "$DRY_RUN" == "true" ]]; then
      current_status=$(grep "^status:" "$file" | head -1 | awk '{print $2}')
      echo -e "${YELLOW}Would normalize:${NC} $(basename "$file") (status: $current_status → done)"
    else
      # Normalize "complete" and "completed" to "done"
      sed -i.bak 's/^status: complete$/status: done/g' "$file"
      sed -i.bak 's/^status: completed$/status: done/g' "$file"
      rm -f "${file}.bak"
      echo -e "${GREEN}✓${NC} Normalized: $(basename "$file")"
    fi
    NORMALIZED_COUNT=$((NORMALIZED_COUNT + 1))
  fi
done

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${YELLOW}Summary (DRY-RUN):${NC} Would normalize $NORMALIZED_COUNT file(s)"
  if [[ "$NORMALIZED_COUNT" -gt 0 ]]; then
    echo ""
    echo "To apply changes, run:"
    echo "  ./scripts/normalize-todo-status.sh --apply"
  fi
else
  echo -e "${GREEN}Summary:${NC} Normalized $NORMALIZED_COUNT file(s)"
fi
echo ""

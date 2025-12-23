#!/bin/bash
# Get the next available todo ID
# Usage: ./scripts/next-todo-id.sh

set -euo pipefail

# Collect all IDs from todos/ and archive/
ALL_IDS=$(ls todos/*.md todos/archive/*.md 2>/dev/null | \
  xargs -I{} basename {} | \
  grep -oE '^[0-9]+' | \
  sort -n | \
  tail -1)

if [[ -z "$ALL_IDS" ]]; then
  echo "001"
else
  printf "%03d\n" $((10#$ALL_IDS + 1))
fi

#!/bin/bash
# Get the next available ADR ID
# Usage: ./scripts/next-adr-id.sh

set -euo pipefail

# Collect all IDs from docs/decisions/
ALL_IDS=$(ls docs/decisions/*.md 2>/dev/null | \
  xargs -I{} basename {} | \
  grep -oE '^[0-9]+' | \
  sort -n | \
  tail -1)

if [[ -z "$ALL_IDS" ]]; then
  echo "001"
else
  printf "%03d\n" $((10#$ALL_IDS + 1))
fi

#!/bin/bash
#
# validators/folder-docs.sh
# Part of: Unified Documentation Validation Framework
# 
# Validates that key directories have README.md files with required sections:
# - Purpose
# - Components
# - Component Details (optional for small folders)
# - Changelog
#
# Also checks for documentation freshness by comparing git log dates.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Core folders to validate
CORE_FOLDERS=(
  "app"
  "backend"
  "lib"
  "docs"
  "scripts"
)

FAILED=0

echo "Validating folder documentation..."

for folder in "${CORE_FOLDERS[@]}"; do
  folder_path="${ROOT_DIR}/${folder}"
  
  if [ ! -d "$folder_path" ]; then
    echo "  ⚠ Skipping non-existent folder: $folder"
    continue
  fi
  
  readme="${folder_path}/README.md"
  
  if [ ! -f "$readme" ]; then
    echo "  ✗ Missing README.md in $folder/"
    FAILED=1
    continue
  fi
  
  # Check for required sections
  for section in "## Purpose" "## Components" "## Changelog"; do
    if ! grep -q "^${section}" "$readme"; then
      echo "  ✗ Missing section '$section' in $folder/README.md"
      FAILED=1
    fi
  done
  
  # Check freshness: warn if code changed more recently than changelog
  if git -C "$ROOT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    last_code_change=$(git -C "$ROOT_DIR" log -1 --format=%aI -- "$folder" 2>/dev/null | head -1 || echo "")
    last_doc_change=$(git -C "$ROOT_DIR" log -1 --format=%aI -- "$readme" 2>/dev/null | head -1 || echo "")
    
    if [ -n "$last_code_change" ] && [ -n "$last_doc_change" ]; then
      if [[ "$last_code_change" > "$last_doc_change" ]]; then
        echo "  ⚠ Documentation may be stale in $folder/ (code changed after docs)"
      fi
    fi
  fi
  
  echo "  ✓ $folder/README.md is valid"
done

if [ $FAILED -eq 0 ]; then
  echo "All folder documentation is valid."
  exit 0
else
  echo "Some folder documentation issues found."
  exit 1
fi

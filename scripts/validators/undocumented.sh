#!/bin/bash
#
# validators/undocumented.sh
# Part of: Unified Documentation Validation Framework
#
# Proactively discovers directories with source code but no README.md.
# Uses a heuristic: folder contains source files (*.ts, *.tsx, *.py, *.sh)
# but is missing README.md.
#
# Exit codes:
#   0 = No undocumented folders found
#   2 = Undocumented folders found (warning, non-blocking)
#   1 = Error (e.g., invalid arguments)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Roots to scan
ROOTS=("app" "lib" "backend" "scripts")

# Exclusions
EXCLUSIONS=("node_modules" "__pycache__" ".git" "__tests__" "archive" ".vercel" ".next" "dist")

# Build exclusion args
EXCLUDE_ARGS=()
for excl in "${EXCLUSIONS[@]}"; do
  EXCLUDE_ARGS+=("-not" "-path" "*/$excl/*" "-not" "-path" "*/$excl")
done

echo "Discovering undocumented directories..."

undocumented=()

for root in "${ROOTS[@]}"; do
  root_path="${ROOT_DIR}/${root}"
  
  if [ ! -d "$root_path" ]; then
    continue
  fi
  
  # Find directories with source files but no README.md
  while IFS= read -r -d '' folder; do
    # Check if folder has source files
    has_source=$(find "$folder" -maxdepth 1 -type f \( \
      -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.sh" \
    \) 2>/dev/null | head -1)
    
    # Check if README exists
    if [ -n "$has_source" ] && [ ! -f "$folder/README.md" ]; then
      undocumented+=("$folder")
    fi
  done < <(find "$root_path" -mindepth 1 -maxdepth 2 -type d "${EXCLUDE_ARGS[@]}" -print0 2>/dev/null)
done

if [ ${#undocumented[@]} -eq 0 ]; then
  echo "✓ No undocumented source directories found."
  exit 0
fi

echo "⚠ Found ${#undocumented[@]} undocumented directories:"
for dir in "${undocumented[@]}"; do
  echo "  - $dir"
done

echo ""
echo "To create documentation, run:"
echo "  cp docs/templates/folder-readme-template.md <directory>/README.md"
echo "  # Then edit and customize"

exit 2  # Non-critical warning

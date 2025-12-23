#!/bin/bash
# scripts/discover-undocumented-folders.sh
# Proactively discovers folders lacking README documentation
#
# Usage: ./scripts/discover-undocumented-folders.sh

# Configuration
ROOTS=("app" "lib" "backend" "scripts")
# Exclude system folders, tests, archives, and Next.js route groups/special folders
EXCLUSIONS=("node_modules" "__pycache__" ".git" "__tests__" "archive" ".vercel" ".next" "dist" "(*" "*)")
EXTENSIONS=("ts" "tsx" "py" "sh")

# Build find exclusion pattern
EXCLUDE_ARGS=()
for excl in "${EXCLUSIONS[@]}"; do
  EXCLUDE_ARGS+=("-not" "-path" "*/$excl/*")
  EXCLUDE_ARGS+=("-not" "-name" "$excl")
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

undocumented=()

# Process each root directory
for root in "${ROOTS[@]}"; do
  if [ -d "$root" ]; then
    # Find directories at depth 1 and 2
    # We want to catch lib/cache (depth 2) and app/api (depth 2)
    while IFS= read -r -d '' folder; do
      # Skip the root itself if it's already in the list or we want it
      [[ "$folder" == "." ]] && continue
      
      # Check if folder has source files (*.ts, *.tsx, *.py, *.sh)
      # head -1 for efficiency
      has_source=$(find "$folder" -maxdepth 1 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.sh" \) 2>/dev/null | grep -v "README.md" | head -1)
      
      if [ -n "$has_source" ] && [ ! -f "$folder/README.md" ]; then
        undocumented+=("$folder")
      fi
    done < <(find "$root" -mindepth 1 -maxdepth 2 -type d "${EXCLUDE_ARGS[@]}" -print0 2>/dev/null)
  fi
done

# Summary output
if [ ${#undocumented[@]} -gt 0 ]; then
  echo -e "${RED}❌ Found ${#undocumented[@]} undocumented folder(s):${NC}"
  for folder in "${undocumented[@]}"; do
    echo -e "   - ${YELLOW}$folder${NC} (run: ${BLUE}./scripts/bootstrap-folder-docs.sh $folder${NC})"
  done
  exit 1
fi

echo -e "${GREEN}✅ All key folders have README documentation.${NC}"
exit 0

#!/bin/bash
# Archive completed lifecycle documents (todos, plans, specs)
# Usage: ./scripts/archive-completed.sh [--apply]
#
# By default runs in dry-run mode, showing what would be archived.
# Use --apply to actually move files.

set -euo pipefail

# Configuration
DRY_RUN=true
VERBOSE=false
ARCHIVED_COUNT=0
SKIPPED_COUNT=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      DRY_RUN=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true  # Already default, but explicit is nice
      shift
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--apply] [--dry-run] [--verbose]"
      echo "  --apply   Actually move files (default: dry-run)"
      echo "  --dry-run Show what would happen (default)"
      echo "  --verbose Show detailed output"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_action() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would archive: $1"
  else
    echo -e "${GREEN}[ARCHIVED]${NC} $1"
  fi
}

# Function to archive a todo file
archive_todo() {
  local file="$1"
  local basename=$(basename "$file")
  local dest="todos/archive/$basename"
  
  if [[ "$DRY_RUN" == "false" ]]; then
    mv "$file" "$dest"
  fi
  log_action "$basename → todos/archive/"
  ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
}

# Function to archive a plan file
archive_plan() {
  local file="$1"
  local basename=$(basename "$file")
  local dest="plans/archive/$basename"
  
  if [[ "$DRY_RUN" == "false" ]]; then
    mv "$file" "$dest"
  fi
  log_action "$basename → plans/archive/"
  ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
}

# Function to archive an exploration file
archive_exploration() {
  local file="$1"
  local basename=$(basename "$file")
  local dest="docs/explorations/archive/$basename"
  
  if [[ "$DRY_RUN" == "false" ]]; then
    mv "$file" "$dest"
  fi
  log_action "$basename → docs/explorations/archive/"
  ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
}

# Function to archive an entire spec directory
archive_spec() {
  local spec_dir="$1"
  local spec_name=$(basename "$spec_dir")
  local dest="docs/specs/archive/$spec_name"
  
  if [[ "$DRY_RUN" == "false" ]]; then
    mv "$spec_dir" "$dest"
  fi
  log_action "$spec_name/ → docs/specs/archive/"
  ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
}

# Check if a todo is completed
is_todo_complete() {
  local file="$1"
  local basename=$(basename "$file")
  
  # Check filename contains "done"
  if [[ "$basename" =~ -done- ]]; then
    return 0
  fi
  
  # Check YAML status
  if grep -qi "^status:.*done" "$file" 2>/dev/null; then
    return 0
  fi
  
  return 1
}

# Check if a plan is completed
is_plan_complete() {
  local file="$1"
  
  # Check for "Status: Implemented" in markdown
  if grep -qiE "^>?\s*Status:.*Implemented" "$file" 2>/dev/null; then
    return 0
  fi
  
  # Check if all checkboxes are checked
  local total=$(grep -cE "^- \[.\]" "$file" 2>/dev/null || true)
  local checked=$(grep -cE "^- \[x\]" "$file" 2>/dev/null || true)
  
  if [[ "$total" -gt 0 && "$total" -eq "$checked" ]]; then
    # Has checkboxes and all are checked
    return 0
  fi
  
  return 1
}

# Check if an exploration is completed
is_exploration_complete() {
  local file="$1"
  
  # Check for "status: complete" or "status: done" or "outcome: proceed_to_plan" or all checkboxes checked
  if grep -qiE "^status:\s*(complete|done)" "$file" 2>/dev/null; then
    return 0
  fi
  
  # Check if all checkboxes are checked
  local total=$(grep -cE "^- \[.\]" "$file" 2>/dev/null || true)
  local checked=$(grep -cE "^- \[x\]" "$file" 2>/dev/null || true)
  
  if [[ "$total" -gt 0 && "$total" -eq "$checked" ]]; then
    return 0
  fi
  
  # If outcome is set and no unchecked items exist
  if grep -qi "^outcome:" "$file" 2>/dev/null; then
      local unchecked=$(grep -cE "^- \[ \]" "$file" || true)
      if [[ "$unchecked" -eq 0 ]]; then
          return 0
      fi
  fi
  
  return 1
}

# Check if a spec is completed
is_spec_complete() {
  local spec_dir="$1"
  local readme="$spec_dir/README.md"
  
  # Must have README
  if [[ ! -f "$readme" ]]; then
    return 1
  fi
  
  # Check for 100% in progress bars
  if grep -qE "(100%|████████████████████)" "$readme" 2>/dev/null; then
    # Additional check: ensure no incomplete tasks remain
    local tasks_file="$spec_dir/03-tasks.md"
    if [[ -f "$tasks_file" ]]; then
      local unchecked=$(grep -cE "^- \[ \]" "$tasks_file" || true)
      if [[ "$unchecked" -eq 0 ]]; then
        return 0
      fi
    else
      # No tasks file, trust the README
      return 0
    fi
  fi
  
  return 1
}

# Main execution
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  📦 Archive Completed Documents"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "  Mode: DRY-RUN (use --apply to execute)"
else
  echo "  Mode: APPLYING CHANGES"
fi
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Ensure archive directories exist
mkdir -p todos/archive plans/archive docs/specs/archive docs/explorations/archive

# Process todos
echo "📋 Checking todos..."
for file in todos/*.md; do
  [[ -f "$file" ]] || continue
  [[ "$(basename "$file")" == "todo-template.md" ]] && continue
  
  if is_todo_complete "$file"; then
    archive_todo "$file"
  elif [[ "$VERBOSE" == "true" ]]; then
    echo "   Skipping: $(basename "$file") (not complete)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi
done

# Process plans
echo ""
echo "📝 Checking plans..."
for file in plans/*.md; do
  [[ -f "$file" ]] || continue
  [[ "$(basename "$file")" == "README.md" ]] && continue
  
  if is_plan_complete "$file"; then
    archive_plan "$file"
  elif [[ "$VERBOSE" == "true" ]]; then
    echo "   Skipping: $(basename "$file") (not complete)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi
done

# Process specs
echo ""
echo "📚 Checking specs..."
for spec_dir in docs/specs/*/; do
  [[ -d "$spec_dir" ]] || continue
  spec_name=$(basename "$spec_dir")
  
  # Skip templates and archive
  [[ "$spec_name" == "templates" ]] && continue
  [[ "$spec_name" == "archive" ]] && continue
  
  if is_spec_complete "$spec_dir"; then
    archive_spec "$spec_dir"
  elif [[ "$VERBOSE" == "true" ]]; then
    echo "   Skipping: $spec_name/ (not complete)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi
done

# Process explorations
echo ""
echo "🔍 Checking explorations..."
if [ -d "docs/explorations" ]; then
  for file in docs/explorations/*.md; do
    [[ -f "$file" ]] || continue
    [[ "$(basename "$file")" == "template.md" ]] && continue
    
    if is_exploration_complete "$file"; then
      archive_exploration "$file"
    elif [[ "$VERBOSE" == "true" ]]; then
      echo "   Skipping: $(basename "$file") (not complete)"
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    fi
  done
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "  Summary (DRY-RUN)"
  echo "  Would archive: $ARCHIVED_COUNT items"
  if [[ "$ARCHIVED_COUNT" -gt 0 ]]; then
    echo ""
    echo "  To apply these changes, run:"
    echo "    ./scripts/archive-completed.sh --apply"
  fi
else
  echo "  Summary"
  echo "  Archived: $ARCHIVED_COUNT items"
fi
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Exit with count for scripting
exit 0

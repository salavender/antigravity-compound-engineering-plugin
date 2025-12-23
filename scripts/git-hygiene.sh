#!/bin/bash
# Git hygiene maintenance script
# Identifies and cleans up stale/merged branches and prunes remote references.
#
# Usage: ./scripts/git-hygiene.sh [--fix]
#
# Exit codes:
#   0 = Clean or successful cleanup
#   1 = Issues found (in report-only mode)

set -euo pipefail

# Validate we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  RED='\033[0;31m'
  NC='\033[0m' # No Color
  echo -e "${RED}✗${NC} Not in a git repository"
  echo "This script must be run from within a git repository."
  exit 1
fi

FIX_MODE=false
MAIN_BRANCH="main"
ISSUES_FOUND=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix|--apply)
      FIX_MODE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--fix]"
      echo "  --fix   Delete merged local branches and prune remote references"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Running Git Hygiene...${NC}"

# 0. Validate documentation freshness
echo -e "${BLUE}📚 Checking documentation freshness...${NC}"
if [[ -x "./scripts/validate-folder-docs.sh" ]]; then
  if ! ./scripts/validate-folder-docs.sh; then
    echo -e "   ${RED}❌ Documentation check failed.${NC}"
    ISSUES_FOUND=1
  else
    echo -e "   ${GREEN}✓${NC} Documentation is fresh"
  fi
else
  echo -e "   ${YELLOW}⚠${NC} Documentation validation script not found"
fi

# 1. Prune remote references
echo -e "${BLUE}📡 Pruning remote-tracking branches...${NC}"
if [[ "$FIX_MODE" == "true" ]]; then
  git fetch --prune
  echo -e "   ${GREEN}✓${NC} Remote references pruned"
else
  echo -e "   ${YELLOW}ℹ${NC} Dry run: git fetch --prune"
fi

# 2. Identify merged local branches
echo -e "\n${BLUE}📂 Checking for merged local branches...${NC}"
merged_branches=$(git branch --merged "$MAIN_BRANCH" | grep -v "^\*" | grep -v "^  $MAIN_BRANCH" || true)

if [[ -z "$merged_branches" ]]; then
  echo -e "   ${GREEN}✓${NC} No merged local branches to clean up"
else
  count=$(echo "$merged_branches" | wc -l | tr -d ' ')
  echo -e "   ${YELLOW}⚠${NC} Found $count merged local branch(es):"
  echo "$merged_branches" | sed 's/^/      - /'
  
  if [[ "$FIX_MODE" == "true" ]]; then
    echo -e "   ${BLUE}🔧 Deleting merged branches...${NC}"
    echo "$merged_branches" | xargs -n 1 git branch -d
    echo -e "   ${GREEN}✓${NC} Merged branches deleted"
  else
    echo -e "   ${YELLOW}ℹ${NC} Run with --fix to delete these branches"
  fi
fi

# 3. Identify stale branches (no commits in 3 days)
echo -e "\n${BLUE}🕰️  Checking for stale branches (no commits in 3+ days)...${NC}"
stale_found=0
current_time=$(date +%s)
three_days_ago=$((current_time - (3 * 24 * 60 * 60)))

# Get all local branches and their last commit date
while read -r branch; do
  [[ -z "$branch" ]] && continue
  last_commit_date=$(git log -1 --format=%at "$branch")
  if [[ "$last_commit_date" -lt "$three_days_ago" ]]; then
    last_commit_human=$(git log -1 --format=%cr "$branch")
    echo -e "   ${YELLOW}⚠${NC} Stale: ${branch} (last commit: $last_commit_human)"
    stale_found=$((stale_found + 1))
  fi
done < <(git branch --format="%(refname:short)" | grep -v "^$MAIN_BRANCH$")

if [[ $stale_found -eq 0 ]]; then
  echo -e "   ${GREEN}✓${NC} No stale branches detected"
fi

echo -e "\n${BLUE}✨ Git hygiene check complete${NC}"

if [[ "$FIX_MODE" == "false" ]] && [[ $ISSUES_FOUND -ne 0 ]]; then
  echo -e "\n${RED}✗ Git hygiene issues found. Please address them before pushing.${NC}"
  exit 1
fi

if [[ "$FIX_MODE" == "false" ]] && [[ -n "$merged_branches" ]]; then
  echo -e "\n${YELLOW}⚠ Merged branches found. Run with --fix to clean up.${NC}"
  exit 1
fi

exit 0

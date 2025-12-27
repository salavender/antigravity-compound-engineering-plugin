#!/bin/bash
# Create isolated worktree for PR review
# Usage: ./scripts/worktree-review.sh <pr-number>

set -euo pipefail

# Validate argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <pr-number>"
  echo "Example: $0 123"
  exit 1
fi

PR_NUMBER="$1"
WORKTREE_BASE="../.worktrees"
WORKTREE_DIR="$WORKTREE_BASE/pr-$PR_NUMBER"
BRANCH_NAME="pr-$PR_NUMBER-review"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  echo "❌ Error: GitHub CLI (gh) is not installed."
  echo "Install: https://cli.github.com/"
  exit 1
fi

# Create worktrees directory if it doesn't exist
mkdir -p "$WORKTREE_BASE"

# Check if worktree already exists
if [ -d "$WORKTREE_DIR" ]; then
  echo "⚠️  Worktree for PR #$PR_NUMBER already exists at $WORKTREE_DIR"
  echo "To recreate, first remove it:"
  echo "  git worktree remove $WORKTREE_DIR"
  exit 1
fi

echo "📥 Fetching PR #$PR_NUMBER..."
gh pr checkout "$PR_NUMBER" -b "$BRANCH_NAME"

echo "🌳 Creating worktree..."
git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"

echo ""
echo "✅ PR #$PR_NUMBER ready for review in isolated worktree"
echo "📂 Location: $WORKTREE_DIR"
echo ""
echo "Next steps:"
echo "  cd $WORKTREE_DIR"
echo "  # npm install  # Install dependencies if needed"
echo ""
echo "To remove when done:"
echo "  git worktree remove $WORKTREE_DIR"
echo "  git branch -d $BRANCH_NAME"

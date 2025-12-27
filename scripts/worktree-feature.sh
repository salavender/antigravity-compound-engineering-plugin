#!/bin/bash
# Create isolated worktree for feature development
# Usage: ./scripts/worktree-feature.sh <feature-name>

set -euo pipefail

# Validate argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <feature-name>"
  echo "Example: $0 user-authentication"
  exit 1
fi

FEATURE_NAME="$1"
WORKTREE_BASE="../.worktrees"
WORKTREE_DIR="$WORKTREE_BASE/feature-$FEATURE_NAME"
BRANCH_NAME="feature/$FEATURE_NAME"

# Create worktrees directory if it doesn't exist
mkdir -p "$WORKTREE_BASE"

# Check if worktree already exists
if [ -d "$WORKTREE_DIR" ]; then
  echo "⚠️  Worktree for feature '$FEATURE_NAME' already exists at $WORKTREE_DIR"
  echo "To recreate, first remove it:"
  echo "  git worktree remove $WORKTREE_DIR"
  exit 1
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "⚠️  Branch '$BRANCH_NAME' already exists"
  echo "Using existing branch. To create a new branch, delete the old one first:"
  echo "  git branch -d $BRANCH_NAME"
else
  echo "🌿 Creating branch $BRANCH_NAME..."
  git checkout -b "$BRANCH_NAME"
fi

echo "🌳 Creating worktree..."
git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"

echo ""
echo "✅ Feature '$FEATURE_NAME' workspace ready"
echo "📂 Location: $WORKTREE_DIR"
echo "🌿 Branch: $BRANCH_NAME"
echo ""
echo "Next steps:"
echo "  cd $WORKTREE_DIR"
echo "  # npm install  # Install dependencies if needed"
echo "  # Start working on your feature..."
echo ""
echo "To push to remote:"
echo "  git push -u origin $BRANCH_NAME"
echo ""
echo "To remove when done:"
echo "  git worktree remove $WORKTREE_DIR"
echo "  git branch -d $BRANCH_NAME  # After merging"

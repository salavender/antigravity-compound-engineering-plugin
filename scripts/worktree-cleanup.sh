#!/bin/bash
# Clean up removed worktrees and prune stale metadata
# Usage: ./scripts/worktree-cleanup.sh

set -euo pipefail

echo "🧹 Cleaning up worktrees..."

# Prune worktree metadata for removed worktrees
echo "📋 Pruning stale worktree metadata..."
git worktree prune

# List current worktrees
echo ""
echo "📂 Active worktrees:"
git worktree list

echo ""
echo "✅ Worktree cleanup complete"
echo ""
echo "To manually remove a worktree:"
echo "  git worktree remove <path>"

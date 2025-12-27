---
name: git-workflow
description: Standardized patterns for Git branching, worktrees, and lifecycle management.
file_triggers:
  - ".agent/workflows/work.md"
---

# Git Workflow Patterns

## Overview
Ensures consistent Git practices across all agent workflows, favoring isolated work environments (worktrees) and clean lifecycle closure.

## Branch Setup

### Option A: Standard Branching
Use for quick, single-task fixes where isolated environments are not required.
```bash
git checkout main && git pull origin main
git checkout -b feature/{feature-name}
```

### Option B: Isolated Worktree (RECOMMENDED)
Use for complex features or PR reviews to keep the main workspace clean.
```bash
# Use automated script for features
./scripts/worktree-feature.sh {feature-name}
cd ../.worktrees/feature-{feature-name}

# OR for PR reviews
./scripts/worktree-review.sh {pr-number}
cd ../.worktrees/pr-{pr-number}
```

**Why worktrees?**
- Parallel work without stashing.
- Isolated dependencies.
- No interruption of main branch state.

## Branch Lifecycle Closure (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Never proceed to task completion with an open, unmerged feature branch unless explicitly documented.

### Option A: Work Merged via PR (Recommended)
If the PR was merged via GitHub:
```bash
# Switch to main and clean up
git checkout main
git pull origin main
git branch -d feature/{name}      # Delete local
```

### Option B: Local-Only Work (Direct Merge)
If work was small and doesn't need a PR:
```bash
# Merge locally and clean up
git checkout main
git merge feature/{name} --no-ff -m "merge: {feature}"
git branch -d feature/{name}      # Delete local
git push origin main
```

### Option C: Abandon Work
```bash
git checkout main
git branch -D feature/{name}      # Force delete local
git push origin --delete feature/{name}  # Delete remote (if exists)
```

### Option D: Keep WIP (Escape Hatch)
If the branch must stay open (e.g., waiting for review):
```bash
export SKIP_BRANCH_CHECK=1
git push
```

### Option E: Worktree Cleanup
```bash
# From main workspace
git worktree remove ../.worktrees/{name}
./scripts/worktree-cleanup.sh  # Prune metadata
```

## Instrumentation
```bash
./scripts/log-skill.sh "git-workflow" "workflow" "{calling_workflow_name}"
```

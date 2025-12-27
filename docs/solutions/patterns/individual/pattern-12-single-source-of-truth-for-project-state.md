---
pattern_number: 12
title: "Single Source of Truth for Project State"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #12: Single Source of Truth for Project State


**Problem:** Project state becomes inconsistent when multiple files attempt to track the same status (e.g., `README.md` vs `tasks.md` vs `requirements.md`), leading to confusion and maintenance burden.

**❌ WRONG:**
```markdown
# 01-requirements.md
REQ-1: Auth [x] Complete

# 03-tasks.md
Task 1: Auth [ ] In Progress
```
*Duplicating status across definition and execution documents.*

**✅ CORRECT:**
```markdown
# 01-requirements.md
REQ-1: Auth (See 03-tasks.md for status)

# 03-tasks.md
Task 1: Auth [x] Complete
```
*Define once, track in one place. Link elsewhere.*

**Why:** De-normalization of status requires N manual updates for every 1 actual change. Humans and agents will inevitably miss one, leading to "split-brain" state.

**Source:** Process analysis of specification state drift.

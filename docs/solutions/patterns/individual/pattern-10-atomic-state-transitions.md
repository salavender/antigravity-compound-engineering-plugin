---
pattern_number: 10
title: "Atomic State Transitions"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #10: Atomic State Transitions


**Problem:** Lifecycle documents (todos, plans, specs) have status metadata that can drift from their completion checkboxes when state transitions require multiple manual steps. Additionally, standard "update X, then Y, then Z" instructions in documentation lead to drift when humans/agents miss a step. An interruption or error mid-process leaves the system in a corrupted state.

**❌ WRONG:**
```bash
# Manual multi-step process
vim todos/016-ready-p2-task.md  # Edit status field
mv todos/016-ready...md todos/016-complete...md  # Rename
# ⚠️ Interruption here = corrupted state (filename vs. YAML mismatch)
```

**✅ CORRECT:**
```bash
# Atomic script enforces consistency
./scripts/done-todo.sh todos/016-ready-p2-task.md
# ✅ Single operation validates, updates, and renames atomically
```

**When to Apply:**
- Any document with lifecycle states (draft → complete, ready → done, pending → approved)
- Operations that require 2+ steps to complete a state transition
- Metadata that must stay in sync with document content (YAML frontmatter, filenames, checkboxes)

**Implementation Checklist:**
- [ ] Create atomic completion script (validates + updates + renames)
- [ ] Update workflow to mandate script usage
- [ ] Add audit script to detect drift (`scripts/audit-state-drift.sh`)

**Why:** State drift causes automation failures, confusing debugging sessions, and trust erosion in the system of record. Wrapping multi-step transitions in scripts eliminates entire categories of consistency bugs.

**Source:** Analysis of inconsistent todo and plan states.

---
pattern_number: 21
title: "Strict Lifecycle Enums"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #21: Strict Lifecycle Enums


**Problem:** Lifecycle documents (todos, plans, specs) with YAML frontmatter status fields develop "enum drift" when non-standard values are used, causing automation failures, state inconsistencies, and trust erosion in the compound system.

**❌ WRONG:**
```yaml
# Inconsistent status values
status: "mostly done"
status: "waiting"
status: "in progress" # (Mixed case/spaces)
```

**✅ CORRECT:**
Use a strict, hyphenated, lower-case enum set:
- **Todos:** `pending`, `ready`, `in-progress`, `done`, `rejected`
- **Plans/Specs:** `draft`, `proposed`, `approved`, `executing`, `verifying`, `completed`, `archived`

**Why:** Machine-readable lifecycle metadata must be predictable. Standardizing on a fixed set of enums ensures that validation scripts (like `validate-todo-consistency.sh`) and dashboards can accurately report on system health without complex parsing logic.

**Source:** Analysis of lifecycle document metadata drift.

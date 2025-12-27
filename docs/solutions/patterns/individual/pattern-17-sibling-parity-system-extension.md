---
pattern_number: 17
title: "Sibling Parity (System Extension)"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #17: Sibling Parity (System Extension)


**Problem:** When adding a new system component (e.g., `docs/explorations`) that is a sibling to an existing component (e.g., `docs/solutions`), developers often fail to update shared tooling that references the existing component, leading to broken searches, missing validation, and silent failures.

**❌ WRONG:**
Adding `docs/explorations` but forcing the user (or agent) to remember to search it separately because `scripts/compound-search.sh` only looks at `docs/solutions`.

**✅ CORRECT:**
**"When you add a sibling, check the parent's references."**

Before committing a new component:
1. `grep -r "existing_sibling_name" .`
2. Update EVERY file found to also include the new sibling.

```bash
# Example: Adding docs/explorations
grep -r "docs/solutions" .
# Found: scripts/compound-search.sh, scripts/validate-compound.sh
# Action: Add docs/explorations to both scripts IMMEDIATELY.
```

**Why:** Tools are coupled to the file structure. Changing the structure without updating the tools creates technical debt and breaks the "Compound Engineering" promise of making work easier.

**Source:** Derived from architectural consistency analysis.

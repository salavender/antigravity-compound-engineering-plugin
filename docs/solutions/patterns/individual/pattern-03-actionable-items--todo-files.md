---
pattern_number: 3
title: "Actionable Items → Todo Files"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #3: Actionable Items → Todo Files


**Problem:** When deferred work is documented only in artifacts (implementation plans, walkthroughs, solution docs), it becomes invisible to `/triage` and `/resolve-todo` workflows. Work falls through the cracks.

**❌ WRONG:**
```markdown
# implementation_plan.md
## Future Work
- [ ] Port parallelization pattern to dashboard
- [ ] Investigate async driver

# Agent then closes the task without creating todo files
```

**✅ CORRECT:**
```markdown
# implementation_plan.md
## Future Work
- [ ] Port parallelization pattern to dashboard

# Agent creates corresponding todo file:
# todos/001-ready-p2-port-parallelization-dashboard.md
```

**Rule:** Every unchecked `- [ ]` in an artifact that represents actionable future work MUST have a corresponding todo file in `todos/`.

**Why:** Implementation plans and walkthroughs are for USER communication. Todo files are for SYSTEM tracking. Without todo files, deferred work is invisible to standard workflows like `/triage` and `/resolve-todo`.

**Validation:**
```bash
# Count unchecked items in artifacts
grep -c '^\- \[ \]' *.md

# Count todo files
ls todos/*.md | grep -v template | wc -l

# If mismatch → investigate
```

**Source:** Derived from Compound Engineering efficiency patterns.

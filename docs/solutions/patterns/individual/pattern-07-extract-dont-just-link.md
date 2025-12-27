---
pattern_number: 7
title: "Extract, Don't Just Link"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #7: Extract, Don't Just Link


**Problem:** Auto-generated artifacts (todos, docs, reports) often just link to source material, forcing the user/agent to manually traverse links to get context. This breaks flow and increases cognitive load.

**❌ WRONG:**
```markdown
# Create Skill X
See these solutions:
- [Solution A](link)
- [Solution B](link)
```

**✅ CORRECT:**
```markdown
# Create Skill X

## Context
Extracted from reference solutions:
- "Symptom 1 observed in Solution A"
- "Issue 2 observed in Solution B"

## References
- [Solution A](link)
- [Solution B](link)
```

**Why:**
- **Actionability:** The artifact becomes self-contained.
- **Resilient:** If links break or change, the core context is preserved.
- **Efficiency:** Decision making can happen immediately without context switching.

**Source:** Integration feedback on skill documentation.

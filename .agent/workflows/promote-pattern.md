---
description: Promote a recurring issue to a critical pattern.
---

# /promote-pattern - Pattern Promotion

Use this workflow when you have a **Pattern Promotion Todo** (ready-p2-promote-pattern).
Goal: Synthesize individual solutions into a reusable engineering pattern.

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/promote-pattern" "$$"
./scripts/compound-search.sh "design pattern"
```

### Step 1: Analyze Sources

Read the solutions referenced in the todo.
Identify:
1. What context do they share?
2. What was the common root cause?
3. What is the fundamental principle violated?

### Step 2: Synthesize Pattern

You must strictly follow this template.

**Pattern Template:**

1.  **Name**: (Concept Name, e.g., "Single Source of Truth")
2.  **Context**: (When does this apply? e.g., "When defining constants...")
3.  **Problem**: (What goes wrong? e.g., "Values drift across files...")
4.  **Forces**: (Why is this hard? e.g., "Convenience vs Maintenance...")
5.  **Solution**: (The Rule)
    *   ❌ **Anti-Pattern**: (Code example of what NOT to do)
    *   ✅ **Best Practice**: (Code example of what TO do)
6.  **Consequences**: (Trade-offs)

### Step 3: Update Knowledge Base

1.  Open `docs/solutions/patterns/critical-patterns.md` (or create domain specific file)
2.  Append the synthesized pattern.
3.  Add it to the Table of Contents.

### Step 4: Link Back

For each source solution:
1.  Open the solution file.
2.  Add a link to the new pattern under "Related Solutions" or "Long-term Prevention".

### Step 5: Close Todo

Move the promotion todo to `todos/archive/` or delete it.

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Pattern Promotion",
  TaskStatus: "Pattern synthesized and documented. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Promoted pattern: {Pattern Name}. Updated critical-patterns.md and linked back to source solutions."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Pattern promoted

Next steps:
1. /housekeeping - Archive used todos
2. /compound-health - Check pattern coverage
```

---

## References

- [Critical Patterns](../../docs/solutions/patterns/critical-patterns.md)

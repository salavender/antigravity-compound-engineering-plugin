---
description: Triage and prioritize findings from code reviews. Use after /review to decide which issues to tackle.
---

# /triage - Decision Workflow for Findings

Go through findings one by one and decide whether to create todo items for them.

> **Important:** Do NOT code during triage. This is for decision-making only.

## When To Use

- After `/review` generates findings
- When processing security audit results
- When reviewing performance analysis
- For any list of issues needing prioritization

---

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/triage" "$$"
./scripts/compound-search.sh "prioritization"
```

### Step 0.1: Search Related Solutions

Before approving a finding into a "ready" todo, check if this issue was already addressed in a different pattern or solution.

```bash
// turbo
./scripts/compound-search.sh "{finding keywords}"
```

---

### Step 1: Load Pending Items

```bash
# List pending todos
ls todos/*-pending-*.md 2>/dev/null || echo "No pending items"
```

### Step 2: Present Each Finding

For each item, present:

```
---
Issue #{N}: {Brief Title}

Severity: 🔴 P1 (CRITICAL) / 🟡 P2 (IMPORTANT) / 🔵 P3 (NICE-TO-HAVE)

Category: {Security/Performance/Architecture/Bug/Feature}

Description:
{What's wrong or could be improved}

Location: {file_path:line_number}

Proposed Solution:
{How to fix it}

Estimated Effort: {Small <2h / Medium 2-8h / Large >8h}

---
Decision?
1. yes - Approve and mark as ready
2. next - Skip this item (delete todo)
3. custom - Modify before approving
```

### Step 3: Handle Decisions

**When "yes":**
1. Rename file: `{id}-pending-{pri}-{desc}.md` → `{id}-ready-{pri}-{desc}.md`
2. Update YAML: `status: pending` → `status: ready`
3. Confirm: "✅ Approved: Issue #{id} - Ready to work on"

**When "next":**
1. Delete the todo file
2. Skip to next item
3. Track as skipped for summary

**When "custom":**
1. Ask what to modify
2. Update the information
3. Present revised version
4. Ask again

### Step 4: Track Progress

Show progress during triage:
```
Progress: 3/10 completed | ~2 minutes remaining
```

### Step 5: Final Summary

```markdown
## Triage Complete

**Total Items:** {X}
**Approved (ready):** {Y}
**Skipped:** {Z}

### Approved (Ready for Work):
- `042-ready-p1-transaction-fix.md`
- `043-ready-p2-cache-optimization.md`

### Skipped:
- Item #5: Low priority, defer to next sprint
- Item #12: Not reproducible

### Next Steps:
1. Work on approved items: `/work todos/042-ready-p1-*.md`
2. View ready todos: `ls todos/*-ready-*.md`
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Triage Findings",
  TaskStatus: "Findings prioritized. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Triaged {total} items. Approved: {ready}, Skipped: {skipped}."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Triage complete

Next steps:
1. /work - Start working on approved items
2. /resolve-todo - Batch process approved items
```

---

## References

- Todos created by: `/review`, `/plan`, `/compound`
- Work on todos: `/work`, `/resolve-todo`

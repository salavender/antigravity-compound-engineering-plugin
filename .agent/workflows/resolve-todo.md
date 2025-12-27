---
description: Resolve multiple todo items efficiently. Use to batch-process ready todos.
---

# /resolve-todo - Batch Todo Resolution

Work through ready todo items systematically.

## When To Use

- After `/triage` approves items
- When you have multiple ready todos
- For batch processing work items

---

## Workflow

### Step 0: Search Before Solving

Even if the todo contains a proposed solution, check for newer patterns or related fixes that might change the implementation approach.

```bash
// turbo
./scripts/log-workflow.sh "/resolve-todo" "$$"
./scripts/compound-search.sh "{relevant keywords}"
```

---

### Step 1: List Ready Todos

```bash
ls todos/*-ready-*.md
```

### Step 2: Prioritize by Severity

Order: P1 (critical) → P2 (important) → P3 (nice-to-have)

```bash
# P1 first
ls todos/*-ready-p1-*.md
# Then P2
ls todos/*-ready-p2-*.md
# Then P3
ls todos/*-ready-p3-*.md
```

### Step 3: Check Dependencies

Before starting, verify no blockers:
```bash
grep "dependencies:" todos/{current-todo}.md
```

### Step 4: Work Each Todo

For each todo:

1. **Read:** Understand the problem and proposed solution
2. **Implement:** Make the changes
3. **Test:** Verify the fix works
4. **Update:** Complete the todo atomically

```bash
./scripts/complete-todo.sh todos/{id}-ready-{pri}-{desc}.md
```

This script atomically updates YAML status AND renames the file.

> [!IMPORTANT]
> The agent must verify that all checklist items (`- [ ]`) are checked (`- [x]`) **before** running this script. The script does not auto-check boxes.

### Step 5: Commit Changes

```bash
git add -A
git commit -m "fix: resolve todo #{id} - {description}"
```

### Step 6: Summary

```markdown
## Todos Resolved

**Completed:** {X}
**Remaining:** {Y}

### Completed:
- ✅ #{001} - Fixed security issue
- ✅ #{002} - Performance optimization

### Next Steps:
1. Continue with remaining todos
2. Create PR with changes
3. Run /review on changes
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Resolve Todos",
  TaskStatus: "Todos resolved and committed. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Resolved {count} todos. Priority distribution: {P1/P2/P3}. Commits created."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Todos resolved

Next steps:
1. /review - Review the changes
2. /housekeeping - Cleanup completed todo files
```

---

## References

- Triage items: `/triage`
- Review changes: `/review`

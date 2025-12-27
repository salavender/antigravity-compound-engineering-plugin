---
description: Orchestrate the full "plan → review → work → review → compound" lifecycle for small tasks.
---

# /cycle - Unified Small-Task Lifecycle

Orchestrate the full "essential" development lifecycle for small, self-contained tasks. This workflow ensures rigorous quality without friction by chaining the standard workflows together.

> **Why /cycle?** "Quick" tasks often skip steps like planning or review, leading to bugs. /cycle makes it easy to do it right.

## When To Use

- For small, well-defined tasks (15-60 mins)
- When "just fixing one thing"
- To ensure you don't skip the "boring" but critical steps

---

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/cycle" "$$"
./scripts/compound-search.sh "unified workflow" "cycle"
```

### Step 1: Planning

Trigger the planning workflow.

```bash
/plan
```

*Guidance:* Use the **Minimal** or **Standard** template. Don't over-engineer, but DO capture:
- Goal
- Approach
- Verification plan

### Step 2: Self-Review

Review your own plan immediately.

```bash
/plan-review
```

*Guidance:*
- Did you run `compound-search`?
- Is the verification plan solid?
- If yes → **Approved**.

### Step 3: Execution

Execute the plan systematically.

```bash
/work
```

*Guidance:*
- Mark the todo as in-progress: `./scripts/start-todo.sh todos/{todo}.md`
- Create tests first if possible.
- Update todos as you go.

### Step 4: Rapid Review

Review the code changes.

```bash
/review
```

*Guidance:*
- Run the **Security** and **Simplicity** passes.
- Verify tests pass.
- If self-approving (for non-critical path), be extra critical.

### Step 4.5: Complete Source Todo (CONDITIONAL)

> [!CAUTION]
> **IF WORKING FROM A TODO:** You must atomically mark it complete.

**If this /cycle was triggered by a todo file:**

```bash
./scripts/done-todo.sh todos/{todo-filename}.md
```

**Why:** This script updates YAML status AND renames the file atomically, preventing state drift ([Pattern #10](../../docs/solutions/patterns/critical-patterns.md#pattern-10-atomic-state-transitions)).

**Skip this step if:**
- Working from a plan file
- No source todo exists
- Todo is exploratory work

### Step 5: Capture Knowledge

Don't skip this just because it was small.

```bash
/compound
```

*Guidance:*
- Did you learn a new grep pattern?
- Did you fix a tricky type error?
- Document it!

### Step 6: Cleanup

Archive and cleanup.

```bash
/housekeeping
```

---

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Cycle: {Task Name}",
  TaskStatus: "Cycle complete. All quality gates passed.",
  Mode: "VERIFICATION",
  TaskSummary: "Completed full development cycle for {task}. Passed plan, review, work, and compound stages."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Cycle complete

Next steps:
1. /housekeeping - Final check before push
2. /review - Request peer review if necessary
3. Continue working
```

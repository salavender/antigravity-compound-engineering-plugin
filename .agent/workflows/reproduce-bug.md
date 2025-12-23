---
description: Reproduce reported bugs systematically. Use when investigating bug reports.
---

# /reproduce-bug - Systematic Bug Reproduction

Attempt to reproduce a reported bug following the steps provided.

## Workflow

### Step 0: Establish Context (MANDATORY)

> [!IMPORTANT]
> If you are starting a new session to reproduce this bug, you MUST establish context first.

**Run the context resumer:**

```bash
// turbo
./scripts/log-workflow.sh "/reproduce-bug" "$$"
./scripts/compound-search.sh "bug reproduction"
```

**Action:** Follow `skills/session-resume/SKILL.md` to ensure all previous context and state are restored.

---

### Step 1: Setup Environment

Match the reported environment as closely as possible.

### Step 2: Follow Reproduction Steps

Execute each step exactly as documented.

### Step 3: Document Results

```markdown
## Reproduction Attempt

**Bug Report:** #{issue_number}
**Date:** {date}
**Environment:** {your environment}

### Steps Followed
1. ✅ Step 1 - {result}
2. ✅ Step 2 - {result}
3. ❌/✅ Step 3 - {result}

### Result
- [ ] **Reproduced:** Yes/No
- [ ] **Consistent:** Every time / Intermittent / Once

### Additional Observations
{Any patterns noticed}

### Next Steps
- [ ] Debug further
- [ ] Request more info
- [ ] Plan fix with /plan
```

---

### Step 4: Persist Next Steps (MANDATORY)

> [!IMPORTANT]
> **Do not skip.** Reproduction results are lost if not converted to todos.

**If reproduced:**
**If reproduced:**
```bash
# Create todo to fix the bug
./scripts/create-todo.sh "p1" "Fix: {Bug Title}" \
  "Reproduction successful for issue #{issue_number}.\n\nReproduction Details:\n(Link to reproduction steps and results)" \
  "Fix the bug" \
  "Verify fix with reproduction steps"
```

**If NOT reproduced / Need info:**
```bash
# Create todo to follow up
./scripts/create-todo.sh "p2" "Follow Up: Issue #{issue_number}" \
  "Could not reproduce or need more info for issue #{issue_number}." \
  "Request more information" \
  "Attempt reproduction on different environment"
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Reproduce Bug",
  TaskStatus: "Reproduction attempt recorded. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Reproduction attempt for #{issue}. Result: {Reproduced/Not Reproduced}. Next steps persisted in todo."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Reproduction attempt complete

Next steps:
1. /plan - Plan the fix (if reproduced)
2. /report-bug - If new bug discovered during attempts
3. /housekeeping - Cleanup context
```

---

## References

- Report bugs: `/report-bug`
- Plan fix: `/plan`

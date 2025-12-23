---
description: Report bugs with structured reproduction steps. Use when you find a bug that needs tracking.
---

# /report-bug - Structured Bug Reporting

Create detailed bug reports with reproduction steps.

## Workflow

### Step 0: Search Existing Bugs (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Before reporting a new bug, verify it hasn't already been solved or reported.

**Run the auto-searcher:**
```bash
// turbo
./scripts/log-workflow.sh "/report-bug" "$$"
./scripts/compound-search.sh "{keyword1}" "{keyword2}"
```

**See also:** `skills/compound-docs/SKILL.md` for advanced searching and checking if similar bugs are already reported.

**If relevant solutions or bug reports found:**
1. Do NOT file a duplicate report.
2. Add your new findings (logs, screenshots) to the existing issue if it's still open.
3. Use `/reproduce-bug` if you can provide a more consistent reproduction for an existing issue.
4. Execute the update command to track usage if it's a solved problem:
   ```bash
   // turbo
   ./scripts/update-solution-ref.sh {paths from search output}
   ```

---

### Step 1: Gather Information and Reproduce

> [!TIP]
> Use the **debug skill** for structured reproduction workflows.

```bash
cat skills/debug/SKILL.md
./scripts/log-skill.sh "debug" "workflow" "/report-bug"
```

- [ ] **What happened:** Observable behavior
- [ ] **What was expected:** Intended behavior
- [ ] **How to reproduce:** Step-by-step instructions
- [ ] **Environment:** OS, browser, versions

### Step 2: Create Bug Report

```markdown
# Bug: {Brief Description}

## Summary
{One-line description}

## Environment
- OS: {operating system}
- Browser/Runtime: {details}
- Version: {app version}

## Steps to Reproduce
1. {Step 1}
2. {Step 2}
3. {Step 3}

## Expected Behavior
{What should happen}

## Actual Behavior
{What actually happened}

## Screenshots/Logs
{Attach if applicable}

## Possible Cause
{Initial hypothesis if any}

## Workaround
{Temporary fix if known}
```

### Step 3: File the Report

```bash
# Create issue
gh issue create --title "Bug: {description}" --body "$(cat bug-report.md)"
```

### Step 4: Create Local Todo (MANDATORY)

> [!IMPORTANT]
> **Do not skip.** GitHub issues can be forgotten. Create a local tracking item.

```bash
# Create local todo
./scripts/create-todo.sh "p1" "Fix: {Bug Title}" \
  "External Tracking: GitHub Issue #{issue_number}.\n\nBug Description:\n(Brief description here)" \
  "Fix the bug reported in issue #{issue_number}" \
  "Add regression test"
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Report Bug",
  TaskStatus: "Bug reported and tracked. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Reported bug: {Bug Title}. Github Issue #{number}. Local Todo created."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Bug reported: #{issue_number}

Next steps:
1. /plan - Create plan to fix the bug
2. /reproduce-bug - If reproduction steps need refinement
3. /housekeeping - Cleanup
```

---

## References

- Reproduce bugs: `/reproduce-bug`
- Plan fix: `/plan`

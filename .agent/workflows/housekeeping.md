---
description: Pre-push cleanup to archive completed items and validate repo health. Use before git push.
---

# /housekeeping - Pre-Push Cleanup

Archive completed work, fix state drift, and validate repo health before pushing.

> **Why housekeeping?** A clean repository compounds knowledge faster. Regular archiving ensures active workspaces only contain work-in-progress.

## When To Use

- **MANDATORY:** Before every `git push` (the pre-push hook will block if skipped)
- After completing a major feature or phase
- When ending an agent session

---

## Workflow

### Step 0: Run Automated Check

Start by running the housekeeping orchestrator:

```bash
// turbo
./scripts/log-workflow.sh "/housekeeping" "$$"
./scripts/pre-push-housekeeping.sh
```

### Step 0.5: Collect Daily Metrics

```bash
// turbo
./scripts/compound-metrics.sh
```

### Step 0.6: Check for Skill Gaps

```bash
// turbo
./scripts/suggest-skills.sh
```

**If all checks pass (Green):** You are ready to push.
You have two options:

### Option A: Auto-Fix (Recommended)

Run all checks and automatically fix what can be fixed:

```bash
// turbo
./scripts/pre-push-housekeeping.sh --fix
```

This will:
- Auto-correct status metadata drift using `--fix`
- Auto-archive completed todos, plans, and specs
- Validate compound system integrity
- Run linting checks

### Option B: Manual Step-by-Step

If you prefer more control, follow these steps:

### Step 1: Fix State Drift

Synchronize YAML frontmatter status with checklist completion state:

```bash
// turbo
./scripts/audit-state-drift.sh --fix
```

### Step 2: Archive Completed Items

Move finished work to their respective `archive/` directories:

```bash
// turbo
./scripts/archive-completed.sh --apply
```

**What gets archived:**
- **Todos:** Status is `complete` or filename contains `-complete-`
- **Plans:** Status is `Implemented` or all checkboxes are checked
- **Specs:** README shows 100% AND tasks are all checked

**Tip:** Use `skills/file-todos/SKILL.md` to properly format and tag new todo files.

> [!IMPORTANT]
> **Reinforce Pattern #3 (Actionable Items → Todo Files):**
> Before archiving plans or specs, ensure all unchecked items (`- [ ]`) that represent actionable future work have been converted to todo files in `todos/`.
> 
> **Validation:**
> ```bash
> # Search for orphans
> grep -r "^\- \[ \]" plans/ docs/specs/
> ```
> 
> See [critical-patterns.md](file:///Users/macbookair/Documents/GitHub/[PROJECT_NAME]/docs/solutions/patterns/critical-patterns.md#L80-L121) for the full rule.

### Step 3: Update Index Files

Ensure directory READMEs reflect the new directory state:

- [ ] Update `todos/README.md` active count
- [ ] Update `plans/README.md` archive references
- [ ] Update `docs/specs/README.md` active specs list

### Step 3.5: Skill Discovery

Check if the knowledge base suggests new skill opportunities:

```bash
// turbo
./scripts/suggest-skills.sh
```

If new skills are discovered, you can run `/create-agent-skill` to formalize high-priority skills.


### Step 3.6: Check Deprecated ADRs

Check if any deprecated ADRs need review (haven't been reviewed in 6+ months):

```bash
// turbo
./scripts/check-deprecated-adrs.sh
```

- If warnings appear, review the deprecated ADR to see if it can be archived or needs an update.
- Update `last_referenced` date if you review it.

### Step 3.7: Rotate Logs

Prevent log files from growing indefinitely:

```bash
# Rotate logs older than 12 weeks
// turbo
./scripts/rotate-logs.sh
```

### Step 3.8: Documentation Freshness Check

Verify recent changes have corresponding documentation:

```bash
// turbo
./scripts/check-docs-freshness.sh
```

**The script checks:**
- [ ] Files changed in last commit have corresponding doc updates
- [ ] New scripts are mentioned in README files
- [ ] New workflows are indexed in `.agent/workflows/README.md`

**If warnings appear:** Update docs before pushing.

### Step 3.9: Search Knowledge Base (Optional)

> [!TIP]
> Before shipping, check for any related housekeeping patterns or recent cleanup solutions.

```bash
./scripts/compound-search.sh "housekeeping cleanup archive validation"
```

---

### Step 4: Verify and Ship

Re-run the health check to confirm all issues are resolved:

```bash
// turbo
./scripts/pre-push-housekeeping.sh
```

**If passed:**
```bash
git add -A
git commit -m "chore: housekeeping - archive completed work"
git push
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

> [!IMPORTANT]
> **Visual Completion Signal**
> Call `task_boundary` one last time to signal completion in the user's UI. This prevents the "task" from appearing active after you've finished.

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Housekeeping",
  TaskStatus: "Cleanup and archiving complete. Repository is healthy.",
  Mode: "VERIFICATION",
  TaskSummary: "Executed pre-push housekeeping. Validated state consistency, archived completed work, and rotated logs."
});
```

#### Step 2: Mandatory Handoff

> [!IMPORTANT]
> **Exit Transition**
> Do not stop here. Offer the user clear paths to the next logical workflow.

```bash
✓ Housekeeping complete

Next steps:
1. /work - Start a new task from a todo or plan
2. /resolve-todo - Batch process existing todos
3. /plan - Create a plan for a new feature or fix
4. Continue working - Perform manual follow-ups
```

## References

- **Archive script:** `scripts/archive-completed.sh`
- **State audit:** `scripts/audit-state-drift.sh`
- **Health check:** `scripts/pre-push-housekeeping.sh`
- **Todo management:** `/resolve-todo`
- **Plan creation:** `/plan`


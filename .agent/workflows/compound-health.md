---
description: Check the improved Compound System's health and usage metrics.
---

# /compound-health - System Health Check

Use this workflow weekly to ensure the Compound System is actually working.

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/compound-health" "$$"
./scripts/compound-search.sh "system health"
```

### Step 1: Run Health Dashboard

```bash
./scripts/compound-health.sh
```

### Step 2: Analyze Metrics

**Coverage:**
- **Target:** >50%
- **Action if Low:** Commit to running `/compound-search` before every `/plan`.

**Usage:**
- **Target:** >3 invocations/week
- **Action if Low:** Remind yourself to use the scripts!

**Staleness:**
- **Action:** Any solution not referenced in >6 months -> Review for deprecation.

### Step 3: Maintenance

1. **Fix Orphans**: Run `./scripts/update-solution-ref.sh` on solutions you know you've used recently.
2. **Promote Patterns**: If new pattern candidates are identified, run `/compound`.

### Step 4: Record Status

Add an entry to `docs/solutions/changelog.md` (or equivalent) noting the health stats.

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] System Health Check",
  TaskStatus: "Health checked and recorded. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Completed system health check. Grade: {grade}, Coverage: {coverage}%."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Health check complete

Next steps:
1. /housekeeping - Fix any issues found
2. /plan - Plan improvements to lower technical debt
```

---

## References

- [Health Script](../../scripts/compound-health.sh)

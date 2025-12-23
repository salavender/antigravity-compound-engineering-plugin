---
description: Batch process pending todos to unblock triage bottlenecks
---

# /triage-sprint - Batch Triage Workflow

Rapidly process pending work items with strict time-boxing to clear backlog bottlenecks.

> **Why sprint?** When pending todos accumulate (e.g., >20 pending), individual triage is too slow. Sprints prioritize volume processing over deep analysis to restore flow.

## When To Use

- When "Pending Todos" count > 20
- Weekly (Fridays) to clear the deck
- When `compound-dashboard.sh` shows "Bottleneck" warning

---

## Workflow

### Step 0: Search Before Solving

```bash
// turbo
./scripts/log-workflow.sh "/triage-sprint" "$$"
./scripts/compound-search.sh "triage" "prioritization"
```

---

### Step 1: Assess Backlog

Check the volume of work:

```bash
echo "Pending Todos: $(grep -l "Status: Pending" todos/*.md | wc -l)"
```

**Set Goal:**
- 5 items = 10 minutes
- 10 items = 20 minutes
- 20+ items = 45 minutes (Max)

---

### Step 2: Batch Processing (Sprint)

Execute this block for each batch of 5 items:

1. **List next 5 pending files:**
   ```bash
   ls todos/*-pending-*.md | head -5
   ```

2. **Rapid Review (2 min/item max):**
   For each item, decide immediately:
   - **Do Now:** Move to `/work` queue (Change status to `Ready`, set priority)
   - **Defer:** Move to backlog (Change status to `Deferred`, add reason)
   - **Reject:** Archive (Change status to `Archived`, add reason)
   - **Duplicate:** Merge with existing (Archive one, update other)

3. **Validation Command:**
   ```bash
   # Update status in file
   sed -i '' 's/Status: Pending/Status: Ready/' todos/{filename}
   # OR
   sed -i '' 's/Status: Pending/Status: Deferred/' todos/{filename}
   ```

---

### Step 3: Hard Stop

When time limit is reached:
1. Stop processing
2. Count remaining items
3. Schedule next sprint if > 10 remain

---

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Triage Sprint",
  TaskStatus: "Sprint complete. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Processed X items. Y remain pending. Z moved to Ready."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Sprint complete

Next steps:
1. /work - Start working on items marked Ready
2. /housekeeping - Archive rejected items
```

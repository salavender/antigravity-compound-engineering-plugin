---
pattern_number: 15
title: "Task Completion Visibility"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #15: Task Completion Visibility


**Problem:** When agents finish a task but don't update the `task_boundary` to a terminal state, the user's UI still shows the task as "active" (e.g., "Implementing..."), leading to confusion about the actual work status.

**❌ WRONG:**
```javascript
// Agent finishes work
await notify_user({ message: "Task complete!" });
// UI still shows: "Implementing Feature X"
```

**✅ CORRECT:**
```javascript
// 1. Update UI to completion state
await task_boundary({ 
  TaskName: "[COMPLETED] Feature X",
  TaskStatus: "Work verified. Offering next steps.",
  Mode: "VERIFICATION"
});

// 2. Then notify user
await notify_user({ message: "Task complete!" });
```

**Why:** The `task_boundary` tool is the steering wheel for the user's visual perception of progress. Explicitly marking a task as `[COMPLETED]` or `[SUCCESS]` in the `TaskName` provides immediate visual confirmation that matches the natural language response.

**Source:** Analysis of task UI completion gaps.

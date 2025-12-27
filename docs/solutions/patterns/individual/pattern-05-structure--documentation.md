---
pattern_number: 5
title: "Structure > Documentation"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #5: Structure > Documentation


**Problem:** Critical behaviors (like searching for prior solutions or establishing session state) are often ignored because they are only documented in passive "Read Me First" files. Passive documentation is easily bypassed during high-velocity work.

**❌ WRONG:**
Relying on a static setup guide (e.g., `SETUP.md`) to remind agents to run a specific script at the start of every task.

**✅ CORRECT:**
Embed the behavioral trigger directly into the **Execution Workflow** files (`.agent/workflows/*.md`) as a mandatory "Step 0".
- Every creation workflow MUST start with a search step.
- Every session START MUST be gated by a `session-resume` skill trigger in core instructions.

**Why:** Structuring workflows to include mandatory triggers ensures that best practices are followed every time, regardless of the developer's memory. Correct structure enforces correct behavior.

**Source:** Agent skill discoverability observations.

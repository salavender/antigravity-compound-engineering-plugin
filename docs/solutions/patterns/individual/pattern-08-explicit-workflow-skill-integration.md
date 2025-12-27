---
pattern_number: 8
title: "Explicit Workflow Skill Integration"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #8: Explicit Workflow Skill Integration


**Problem:** Agents fail to use available skills (like `compound-doc` search, `session-resume`, `file-todos`) because workflows rely on implicit "agent memory" or "best judgment" rather than explicit triggers. This leads to duplicate bugs, context loss, and lost deferred work.

**❌ WRONG:**
```markdown
# /report-bug.md
## Workflow
### Step 1: Gather Information
- [ ] What happened...
```
*(Agent dives into reporting without checking if it's already solved)*

**✅ CORRECT:**
```markdown
# /report-bug.md
## Workflow
### Step 0: Search Existing Bugs (MANDATORY)
> [!CAUTION]
> BLOCKING STEP. Run ./scripts/compound-search.sh...

### Step 1: Gather Information
```
*(Agent is forced to search first)*

**Rule:** Workflows must contain **Explicit Blocking Steps** (Step 0) that trigger relevant agent skills commands. Do not assume the agent will "just know" to use them.

**Why:** Implicit expectations fail because agent context is reset. Explicit triggers in the workflow markup act as unavoidable guardrails.

**Source:** Analysis of agent skill discoverability issues.

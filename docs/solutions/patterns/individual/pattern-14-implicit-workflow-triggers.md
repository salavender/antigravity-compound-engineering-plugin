---
pattern_number: 14
title: "Implicit Workflow Triggers"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #14: Implicit Workflow Triggers


**Problem:** When users approve a plan, complete work, or solve a problem, agents often default to ad-hoc actions instead of triggering the appropriate formal workflow. This bypasses critical system safeguards, state tracking, and telemetry.

**Trigger Protocol Table:**

| Phrase Category | Example Phrases | Triggered Workflow |
|-----------------|-----------------|--------------------|
| Investigation | "I need to understand...", "Why is X doing Y?", "Let me investigate...", "Debug: ..." | `/explore` |
| Plan Approval | "Proceed", "Go ahead", "LGTM" | `/work` |
| Work Completion | "Ship it", "Ready to merge", "Let's review" | `/review` |
| Problem Solved | "That worked", "It's fixed", "Working now" | `/compound` |

**❌ WRONG:**
```markdown
User: "Plan looks good. Proceed."
Agent: "Okay, I'll start editing files now..."
(Agent starts editing without /work protocol)
```

**✅ CORRECT:**
```markdown
User: "Plan looks good. Proceed."
Agent: "Understood. Starting /work workflow..."
(Agent executes Step 0 of work.md)
```

**Rule:** User Approval/Completion/Success Phrases = Implicit Workflow Trigger. The agent must immediately switch to the corresponding workflow protocol.

**Why:** Implicit triggers ensure that the "Compounding Engineering" loop is closed even when explicit commands are forgotten. Formalizing these triggers transforms casual conversation into structured engineering work. Ad-hoc execution causes state drift, missing telemetry, and "invisible work."

**Source:** Workflow protocol hardening.

---
pattern_number: 23
title: "Mandatory Instrumentation"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #23: Mandatory Instrumentation


**Problem:** When instrumentation (self-reporting of usage) is treated as an optional feature rather than a system requirement, the Compound System's dashboard becomes inaccurate. This makes it impossible to assess which skills or workflows are effective, violating the principle of compounding knowledge.

**❌ WRONG:**
```markdown
# My New Skill
[Plan and Implementation details]
# (No instrumentation provided)
```

**✅ CORRECT:**
Institutionalize instrumentation across three layers:
1. **Skill Layer**: Every skill MUST have an `## Instrumentation` section calling `./scripts/log-skill.sh`.
2. **Workflow Layer**: Workflows that consume skills MUST call `./scripts/log-workflow.sh`.
3. **Policy Layer**: Mandatory instrumentation rules in core AI configuration (`GEMINI.md`).

**Why:** You cannot improve what you cannot measure. Mandatory instrumentation ensures that every unit of engineering work contributes to the system's observability, allowing for evidence-based optimization of the agent's toolkit.

**Source:** Corrective action for opaque dashboard metrics.

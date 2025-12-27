---
description: Intelligent workflow router to suggest the right tool for the job.
triggers: [audit-security, compound, cycle, explore, plan, refactor, reproduce-bug, resolve-todo, review, specs, triage, work]
uses: [debug, standard-security-auth, mobile, testing]
---

# /route - Intelligent Workflow Suggestion

This workflow helps you find the right workflow effectively by mapping your intent to the correct compound system workflow.

> **Purpose:** Intelligent routing to reduce decision fatigue.

## When To Use

- **Unsure:** When you don't know which workflow to pick
- **Vague Intent:** "I need to fix a bug" or "I need to secure this"
- **Discovery:** To find specialized workflows you might have missed

## Routing Logic

### Intent → Workflow Mapping

| Intent | Keywords | Primary Workflow | Secondary Option |
|--------|----------|------------------|------------------|
| **Bug Fix** | bug, error, fail, crash, fix | `/reproduce-bug` | `/explore` (if deep analysis needed) |
| **New Feature** | feature, add, create, implement | `/plan` | `/specs` (if multi-session) |
| **Refactoring** | refactor, clean, structure, debt | `/refactor` | `/review` |
| **Security** | auth, login, token, vulnerability | `/audit-security` | `/explore` |
| **Quick Task** | small, quick, one-off | `/cycle` | `/work` |
| **Batch Work** | multiple, batch, triage | `/resolve-todo` | `/triage` |

---

## Workflow Steps

### Step 1: Identify Your Intent

Match your current goal to the table above.

### Step 2: Check for Specialized Skills

Before starting, check if a specialized skill applies to your domain:

- **Mobile/Responsive UI:** `skills/mobile/SKILL.md`
- **Authentication:** `skills/standard-security-auth/SKILL.md`
- **Testing:** `skills/testing/SKILL.md`
- **Debugging:** `skills/debug/SKILL.md`

### Step 3: Execute Workflow

Run the selected command.

```bash
# Example: Found a bug?
/reproduce-bug

# Example: Building a new feature?
/plan
```

### Step 4: Feedback (Mental Check)

Did the selected workflow fit?
- **Yes:** Proceed.
- **No:** Consider capturing this as a learning using `/compound`.

---

## References

- [Workflows README](file:///Users/macbookair/Documents/GitHub/antigravity-compound-engineering-plugin/.agent/workflows/README.md)
- [Skills README](file:///Users/macbookair/Documents/GitHub/antigravity-compound-engineering-plugin/skills/README.md)

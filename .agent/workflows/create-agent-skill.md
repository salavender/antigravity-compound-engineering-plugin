---
description: Create new skills for extending agent capabilities. Use to add new domain expertise.
---

# /create-agent-skill - Build New Skills

Create modular skills that extend agent capabilities.

## Skill Architecture

Skills are filesystem-based capabilities:

```
skills/{skill-name}/
├── SKILL.md        # Router + essential principles (always loaded)
├── workflows/      # Step-by-step procedures
├── references/     # Domain knowledge
├── templates/      # Output structures
└── scripts/        # Reusable code
```

## Workflow

### Step 0: Check for Existing Skills/Logic

Verify that a similar skill doesn't already exist or that existing scripts can't be reused to achieve the goal.

```bash
// turbo
./scripts/log-workflow.sh "/create-agent-skill" "$$"
./scripts/compound-search.sh "new skill creation"

ls skills/
grep -r "{skill keywords}" skills/
```

---

### Step 1: Define Skill Purpose

```
Skill name: {name}
Domain: {area of expertise}
Core capability: {what it enables}
```

### Step 2: Create Directory Structure

```bash
mkdir -p skills/{skill-name}/{workflows,references,templates,scripts}
```

### Step 3: Create SKILL.md (Router)

```markdown
---
name: {skill-name}
description: {what this skill provides}
---

# {Skill Name}

## Overview

{Brief description of capability}

- {Condition 2}

## Instrumentation

```bash
# Log usage when using this skill
./scripts/log-skill.sh "{skill-name}" "manual" "$$"
```

## What do you want to do?

1. **{Action 1}** → Read `workflows/action1.md`
2. **{Action 2}** → Read `workflows/action2.md`
3. **{Action 3}** → Read `references/knowledge.md`
```

### Step 4: Add Workflows

Create step-by-step procedures in `workflows/`:

```markdown
# {Workflow Name}

## Prerequisites
- {Required setup}

## Steps
1. {Step 1}
2. {Step 2}
3. {Step 3}

## Expected Output
{What success looks like}
```

### Step 5: Add References

Add domain knowledge in `references/`:
- Best practices
- Common patterns
- Examples

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] New Skill: {Skill Name}",
  TaskStatus: "Skill created and instrumented. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Created new skill {name} with structure: SKILL.md, workflows/, references/."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Skill created: skills/{name}/

Next steps:
1. /work - Implement workflows for the new skill
2. /compound - Document the new capability
```

---

## Principles

1. **Skills are prompts** - All prompting best practices apply
2. **SKILL.md is always loaded** - Keep essential principles inline
3. **Router pattern** - Ask what to do, then route
4. **Progressive disclosure** - Load only what's needed

---
description: Create new workflow commands dynamically. Use to extend the workflow system.
---

# /generate-command - Create New Commands

Generate new workflow commands with proper structure.

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/generate-command" "$$"
./scripts/compound-search.sh "workflow command"
```

### Step 1: Define Command

```
Command name: {name}
Description: {what it does}
When to use: {trigger conditions}
```

### Step 2: Create File

```bash
cat > .agent/workflows/{name}.md << 'EOF'
---
description: {description}
---

# /{name} - {Title}

{Purpose and overview}

## When To Use

- {Condition 1}
- {Condition 2}

---

## Workflow

### Step 1: {First Step}

{Instructions}

### Step 2: {Second Step}

{Instructions}

---

## References

- {Related command}: `/{command}`
EOF
```

### Step 3: Verify

```bash
# Check file exists
cat .agent/workflows/{name}.md

# Test invocation
/{name}
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Generate Command: /{name}",
  TaskStatus: "Command generated and verified. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Generated new workflow command /{name}: {description}. Verified file creation."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Command generated: /{name}

Next steps:
1. /{name} - Test the new command
2. /housekeeping - Verify integration
```

---

## Template Structure

All commands should have:
- YAML frontmatter with `description`
- Clear title and purpose
- "When To Use" section
- Numbered workflow steps
- References to related commands

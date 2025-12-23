---
description: Diagnose and fix broken skills. Use when a skill isn't working correctly.
---

# /heal-skill - Skill Maintenance

Diagnose and repair skills that aren't functioning correctly.

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/heal-skill" "$$"
./scripts/compound-search.sh "broken skill"
```

### Step 1: Identify the Issue

Common problems:
- [ ] SKILL.md not loading
- [ ] Workflow not found
- [ ] Missing references
- [ ] Broken file paths

### Step 2: Diagnose

```bash
# Check skill exists
ls skills/{skill-name}/

# Verify SKILL.md
cat skills/{skill-name}/SKILL.md
./scripts/log-skill.sh "{skill-name}" "workflow" "/heal-skill"

# Check for broken links
grep -r "Read \`" skills/{skill-name}/ | while read line; do
  path=$(echo "$line" | grep -o '`[^`]*`' | tr -d '`')
  [ -f "skills/{skill-name}/$path" ] || echo "Missing: $path"
done
```

### Step 3: Common Fixes

**SKILL.md not structured correctly:**
- Add proper YAML frontmatter
- Include clear router section

**Missing workflows:**
- Create the referenced workflow file
- Update router to match actual files

**Broken references:**
- Fix file paths
- Update relative paths

### Step 4: Verify Fix

```bash
# Test skill invocation
# Check all workflows accessible
# Verify references load
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Heal Skill: {Skill Name}",
  TaskStatus: "Skill diagnosed and repaired. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Diagnosed issues in skill {name}. Applied fixes: {fixes}. Verified functionality."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Skill healed

Next steps:
1. /create-agent-skill - Extend capabilities further
2. /work - Resume original task
```

---

## Skill Health Checklist

- [ ] YAML frontmatter present
- [ ] Description clear
- [ ] Router section works
- [ ] All workflows exist
- [ ] References accessible

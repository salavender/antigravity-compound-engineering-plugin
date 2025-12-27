---
description: Transform feature descriptions into well-structured project plans. Use before starting any significant work.
---

# /plan - Research and Plan Before Building

Transform feature descriptions, bug reports, or improvement ideas into well-structured plans that follow project conventions and best practices.

> **Why plan first?** Research before coding prevents building the wrong thing. A 30-minute plan saves hours of rework.

## When To Use

- Before any feature taking >2 hours
- For bugs requiring investigation
- When exploring unfamiliar codebase areas
- Before architectural changes

---

## Workflow

### Step 0: Search Existing Solutions (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** You MUST complete this before proceeding. Skipping wastes time re-solving known problems.

**Run the auto-searcher:**
```bash
// turbo
./scripts/log-workflow.sh "/plan" "$$"
./scripts/compound-search.sh "{keyword1}" "{keyword2}"
```

**See also:** `skills/compound-docs/SKILL.md` for advanced searching and pattern promotion.

**Output required:**
Copy the **table** AND the **update command** from the script output into your plan.

**If relevant solutions found:**
1. List them in the plan under "## Prior Solutions"
2. Execute the update command to track usage:
   ```bash
   // turbo
   ./scripts/update-solution-ref.sh {paths from search output}
   ```

---

#### ⛔ VALIDATION CHECKPOINT

Before proceeding to Step 0.5, confirm:

- [ ] Ran `compound-search.sh` with relevant keywords?
- [ ] Reviewed all matching solutions (or confirmed none found)?
- [ ] Ran `update-solution-ref.sh` if reusing any solution?

**If any box is unchecked:** Complete it now. Do NOT proceed.

---

### Step 0.5: Check Active Specs

Before creating a standalone plan, check if this work belongs to an active spec:

```bash
ls docs/specs/*/README.md 2>/dev/null | grep -v templates
```

**If active spec found:**
1. Read `docs/specs/{name}/00-START-HERE.md` for context
2. Determine if this plan belongs to the spec
3. If yes, create plan in `docs/specs/{name}/plans/{phase}-{description}.md`
4. Link to parent spec in plan header
5. Reference current phase from spec's `03-tasks.md`

**If no active spec (or work is unrelated):** Proceed with standalone plan in `plans/`.

> [!TIP]
> Use `/specs` first if this is multi-week work that should have its own specification.

### Step 0.6: Pattern Awareness (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Before creating your plan, review the critical patterns to avoid reinventing solutions to known problems.

```bash
# Quick review of critical patterns
cat docs/solutions/patterns/critical-patterns.md | grep "^### Pattern"
```

**Key patterns to consider during planning:**
- Pattern #9: Rigorous Planning (Multi-Order Thinking)
- Pattern #10: Atomic State Transitions
- Pattern #3: Actionable Items → Todo Files

**Why this matters:** These patterns exist because the same mistakes were made 3+ times. Consulting them now prevents wasted effort.

---

### Step 1: Clarify Requirements

If the request is vague, ask clarifying questions:

```
Before I create a plan, I have some questions:

1. What problem does this solve for users?
2. Are there any constraints (timeline, tech stack, etc.)?
3. Should this integrate with existing features?
```

**Do not proceed until requirements are clear.**

### Step 2: Research Phase

Gather context from multiple sources in parallel:

**Codebase Research:**
- [ ] Find similar implementations in the codebase
- [ ] Identify relevant files and patterns
- [ ] Check for existing utilities/helpers to reuse
- [ ] Review related tests for expected behavior

**Documentation Research:**
- [ ] Check project README, CLAUDE.md, or GEMINI.md
- [ ] Review any existing docs for the feature area
- [ ] Look for team conventions and standards

**External Research:**
- [ ] Find best practices for this type of feature
- [ ] Check framework documentation for recommended approaches
- [ ] Look for common pitfalls to avoid

**Reference Collection:**
Document all findings with specific references:
- File paths: `src/services/auth.ts:42`
- URLs: `https://docs.example.com/auth`
- Issues: `#123`, `#456`

### Step 3: Analyze and Identify Gaps

Review collected research for:

- [ ] Edge cases not covered
- [ ] Potential conflicts with existing code
- [ ] Missing dependencies
- [ ] Security considerations
- [ ] Performance implications

### Step 3.5: Deep Analysis (Think Hard)

> [!IMPORTANT]
> Don't rush to solutions. Invest time in rigorous analysis now to avoid costly surprises later.

**Multi-Order Thinking:**
- [ ] **1st order:** What does this change directly affect?
- [ ] **2nd order:** What depends on those affected things?
- [ ] **3rd order:** What cascading effects could occur?
- [ ] **4th order:** Could this affect unrelated systems through shared dependencies?

**Long-Term Implications:**
- [ ] How will this age in 6 months? 1 year?
- [ ] Does this create technical debt or reduce it?
- [ ] Is this approach reversible if we're wrong?
- [ ] Will future maintainers understand the "why"?

**Edge Cases (Leave No Stone Unturned):**
- [ ] Empty/null/undefined inputs
- [ ] Boundary conditions (min, max, exactly-at-limit)
- [ ] Concurrent/race conditions
- [ ] Failure modes (network, database, external services)
- [ ] User behavior extremes (fast clicking, back button, refresh)
- [ ] Data migration scenarios
- [ ] Rollback scenarios

**Stakeholder Impact Analysis:**
- [ ] **End Users:** Will this change behavior they rely on? UX disruption?
- [ ] **Other Developers:** Breaking API changes? Documentation needs?
- [ ] **Operations/Support:** New failure modes? Monitoring/alerting updates?
- [ ] **Downstream Systems:** Integrations affected? Consumer contracts broken?
- [ ] **Business Stakeholders:** Timeline/scope implications? Resource needs?
- [ ] **Security/Compliance:** Data handling changes? Audit requirements?

### Step 4: Choose Detail Level

**📄 MINIMAL** - Simple bugs, small improvements
```markdown
## Problem
[Brief description]

## Solution
[Approach]

## Acceptance Criteria
- [ ] Requirement 1
- [ ] Requirement 2
```

**📋 STANDARD** - Most features
```markdown
## Overview
[Comprehensive description]

## Problem Statement
[Why this matters]

## Proposed Solution
[Technical approach with code examples]

## Acceptance Criteria
- [ ] Detailed requirements

## Technical Considerations
- Dependencies
- Risks
- Alternatives considered

## References
- [Links to research]
```

**📚 DETAILED** - Complex features, architectural changes
All of STANDARD plus:
- Implementation phases
- Rollback strategy
- Migration plan
- Testing strategy
- Monitoring requirements

### Step 5.5: Register Architectural Decisions

> [!IMPORTANT]
> If your plan makes long-term architectural choices (library swaps, schema changes, 
> pattern adoptions), create ADRs to persist them.

**Triggers for ADR creation:**
- Choosing between competing technologies/libraries
- Defining new patterns or conventions
- Making breaking changes with long-term impact
- Decisions that future developers need to understand "why"

**If architectural decision made:**
```bash
# Get next ADR ID
next_id=$(printf "%03d" $(( $(ls -1 docs/decisions/*.md 2>/dev/null | xargs -n1 basename | grep -E '^[0-9]{3}-' | wc -l) + 1 )))
cp docs/decisions/adr-template.md docs/decisions/${next_id}-{decision-slug}.md
```

**Link in plan:**
Add `## Architectural Decisions: ADR-{NNN}` section referencing the new ADR.

### Step 5.9: Create Plan Document

Create plan file: `plans/{feature-name}.md`

**Structure:**
```markdown
# {Feature Title}

> Created: {DATE}
> Status: Draft

## Summary
[One-paragraph overview]

## Problem Statement
[What problem this solves]

## Research Findings

### Codebase Patterns
[Relevant existing code with file:line references]

### Best Practices
[External research findings]

## Proposed Solution

### Approach
[Technical approach]

### Code Examples
\`\`\`{language}
// Example implementation
\`\`\`

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Considerations

### Dependencies
- [Required packages/services]

### Risks
- [Potential issues]

### Alternatives Considered
- [Other approaches and why rejected]

## Implementation Steps

Tasks tracked in [03-tasks.md](../03-tasks.md#phase-{N}).

**Approach:**
- Task 1: [Technical details]
- Task 2: [Technical details]

## References
- [Research links]
- [Related issues]
```

### Step 6: Create Plans Directory (if needed)

```bash
mkdir -p plans
```

### Step 7: Offer Next Steps

```
✓ Plan created: plans/{feature-name}.md

What's next?
1. Start work - Execute this plan with /work
2. Review plan - Get feedback before starting
3. Refine plan - Add more detail
4. Nothing for now
```

### Step 8: Create Todos for Deferred Scope

> [!IMPORTANT]
> If the plan identifies "out of scope" or "future work" items, create todo files for them NOW.

**Check for deferred items:**
- [ ] Did you mark anything as "out of scope"?
- [ ] Are there "nice to have" features for later?
- [ ] Did research reveal related improvements?

**If YES:**
```bash
# Create todo for each deferred item
./scripts/create-todo.sh "p3" "{description}" \
  "Deferred item from plan {feature-name}. This feature was identified as valuable but out of scope for the initial implementation." \
  "Implement feature" "Verify functionality"
```

**Before adding plan references to the todo:**

> [!CAUTION]
> Verify referential integrity to prevent dead links.

**If referencing this plan in the todo:**
```bash
# Verify the plan file exists
if [ ! -f "plans/{feature-name}.md" ]; then
  echo "❌ ERROR: Plan file does not exist. Cannot create reference."
  exit 1
fi
```

**Alternative references** (if plan was not persisted):
- Specs: `../docs/specs/{name}/README.md`
- Solutions: `../docs/solutions/{category}/{solution-name}.md`
- ADRs: `../docs/decisions/{nnn}-{decision}.md`

**See also:** `skills/file-todos/SKILL.md` for full todo management workflows.

---

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

> [!IMPORTANT]
> **Visual Completion Signal**
> Call `task_boundary` one last time to signal completion in the user's UI. This prevents the "task" from appearing active after you've finished.

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Planning: {Feature Name}",
  TaskStatus: "Plan created and ready for review or execution.",
  Mode: "VERIFICATION",
  TaskSummary: "Completed planning for {feature}. Created comprehensive plan with acceptance criteria, research findings, and implementation steps."
});
```

#### Step 2: Mandatory Handoff

> [!IMPORTANT]
> **Exit Transition**
> Do not stop here. Offer the user clear paths to the next logical workflow.

```bash
✓ Plan created: plans/{feature-name}.md

Next steps:
1. /plan-review - Get feedback on plan quality before execution
2. /work - Start implementing (if plan is simple and you're confident)
3. Refine plan - Add more detail based on additional research
4. Create todos - For any deferred scope identified
```

---

## Quality Guidelines

**Good plans have:**
- ✅ Clear problem statement (not just "what" but "why")
- ✅ Research with specific file references
- ✅ Concrete acceptance criteria (testable)
- ✅ Code examples following existing patterns
- ✅ Considered alternatives

**Avoid:**
- ❌ Vague requirements ("make it better")
- ❌ No research ("just do X")
- ❌ Missing acceptance criteria
- ❌ Ignoring existing patterns

---

## References

- Plans directory: `plans/`
- Execute plans: `/work`
- Triage deferred items: `/triage`

---
description: Create and manage specifications for multi-session initiatives. Use before /plan for major work.
---

# /specs - Multi-Session Initiative Management

Create and manage structured specifications for large, multi-session initiatives like refactors, new features, and rebranding.

> **Why specs?** Large work spans multiple agent sessions. Specs preserve context, track phases, and capture decisions so each session can resume effectively.

## When To Use

**Use /specs when:**
- Work spans multiple weeks
- Multiple phases with distinct deliverables
- Need to preserve context across agent sessions
- Large refactors, new features, or rebranding

**Use /plan instead when:**
- Work completes in a single session
- Scope is well-defined and bounded
- No phased rollout needed

---

## Workflow

### Step 0: Search Existing Solutions (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Before defining a new specification, verify we're not reinventing a solution that already exists in the knowledge base.

```bash
// turbo
./scripts/log-workflow.sh "/specs" "$$"
./scripts/compound-search.sh "{initiative keywords}"
```

**Output required:**
Copy the search output table into your spec's "01-requirements.md" or "02-design.md".

---

### Step 0.5: Check Existing Specs

Before creating a new spec, check if one already exists:

```bash
ls docs/specs/*/README.md 2>/dev/null
```

**If joining an active spec:**
1. Read `docs/specs/{name}/00-START-HERE.md` for context
2. Review current phase in `03-tasks.md`
3. Resume work from where it left off

**Only proceed to Step 1 if creating a NEW spec.**

### Step 1: Create Spec Directory

```bash
mkdir -p docs/specs/{name}/{VERIFICATION,plans}
```

Use lowercase-hyphenated names: `multi-tenant`, `auth-refactor`, `brand-update`

### Step 2: Copy and Customize Templates

Copy from `docs/specs/templates/`:

```bash
cp docs/specs/templates/README-template.md docs/specs/{name}/README.md
cp docs/specs/templates/00-START-HERE-template.md docs/specs/{name}/00-START-HERE.md
cp docs/specs/templates/01-requirements-template.md docs/specs/{name}/01-requirements.md
cp docs/specs/templates/02-design-template.md docs/specs/{name}/02-design.md  # Optional for simple specs
cp docs/specs/templates/03-tasks-template.md docs/specs/{name}/03-tasks.md
cp docs/specs/templates/04-decisions-template.md docs/specs/{name}/04-decisions.md
```

### Step 3: Fill Core Documents

**Priority order:**

1. **README.md** - Fill status dashboard with current phase and progress
2. **01-requirements.md** - Define acceptance criteria for the initiative
3. **03-tasks.md** - Break work into phases with:
   - Clear scope boundaries
   - Exit criteria (how to know it's done)
   - Estimated duration
   - Dependencies on other phases
4. **00-START-HERE.md** - Summarize current state for future sessions
5. **04-decisions.md** - Initialize empty (populate as decisions are made)

### Step 3.5: Deep Analysis (Think Hard)

> [!IMPORTANT]
> Specs guide multi-week work. Invest heavily in upfront analysis to avoid costly mid-initiative pivots.

**Multi-Order Thinking:**
- [ ] **1st order:** What does this initiative directly change?
- [ ] **2nd order:** What systems/processes depend on those changes?
- [ ] **3rd order:** What cascading effects ripple outward?
- [ ] **4th order:** Could this affect unrelated areas through shared dependencies?

**Long-Term Implications:**
- [ ] How will this age in 6 months? 1 year?
- [ ] Does this reduce or create technical debt?
- [ ] Is this reversible if assumptions prove wrong?

**Edge Cases (Leave No Stone Unturned):**
- [ ] Boundary conditions and failure modes
- [ ] Concurrent access / race conditions
- [ ] Migration and rollback scenarios

**Stakeholder Impact Analysis:**
- [ ] **End Users:** Behavior changes? Learning curve?
- [ ] **Other Developers:** Breaking changes? Documentation?
- [ ] **Operations/Support:** New failure modes? Runbooks?
- [ ] **Downstream Systems:** Integration impacts?
- [ ] **Business Stakeholders:** Timeline/resource implications?

### Step 4: Create Decision Records

**For spec-scoped decisions:** Add to `04-decisions.md` (temporary during spec)

**For project-wide decisions:** Create in `docs/decisions/`
- Technology choices that outlive the spec
- Patterns that become project standards
- Decisions other specs should follow

**Migration:** When spec completes, promote relevant decisions from `04-decisions.md` 
to `docs/decisions/` if they have project-wide applicability.

### Step 5: Create Phase 1 Plan

Run `/plan` for the first phase:

- Create plan in `docs/specs/{name}/plans/phase1-{description}.md`
- Link back to parent spec in plan header
- Reference phase from `03-tasks.md`

### Step 6: Offer Next Steps

```
✓ Spec created: docs/specs/{name}/

What's next?
1. Start Phase 1 - Run /plan for first phase
2. Review spec - Ask for feedback on structure
3. Share spec - Let team know about the initiative
```

---

## Phase Transitions

When completing a phase:

1. **Update 03-tasks.md** - Mark phase tasks complete
2. **Automate Summary Updates** (MANDATORY):
   ```bash
   // turbo
   ./scripts/update-spec-phase.sh {spec_name} {phase_num} complete
   ```
   *This atomically updates README.md, START-HERE.md, and 03-tasks.md summary table.*
3. **Run /plan** for next phase
   ```bash
   // turbo
   ./scripts/update-spec-phase.sh {spec_name} {next_phase_num} started
   ```

---

## Decision Logging

When making architectural decisions during implementation:

1. **Add to 04-decisions.md** using ADR format
2. **Scope strictly:**
   - ✅ Technology choices (GraphQL vs REST)
   - ✅ Patterns (Strangler Fig for migration)
   - ✅ Trade-offs (speed vs completeness)
   - ❌ Bug fixes
   - ❌ Implementation details
   - ❌ Routine choices

3. **Consider pattern promotion:**
   ```bash
   # If similar decisions made 3+ times
   grep -l "{pattern}" docs/specs/*/04-decisions.md | wc -l
   ```
   If count ≥ 3, run `/compound` to promote to critical pattern.

---

## Context Restoration Protocol

Every new session should check for active specs:

```bash
# Check for active specs
active_spec=$(ls -d docs/specs/*/ 2>/dev/null | grep -v templates | head -1)
if [ -n "$active_spec" ]; then
  echo "Active spec: $active_spec"
  cat "${active_spec}00-START-HERE.md"
fi
```

This is built into `/plan` Step 0.5 and GEMINI.md agent behavior.

---

## Quality Guidelines

**Good specs have:**
- ✅ Clear phase boundaries with exit criteria
- ✅ Acceptance criteria for each requirement
- ✅ Decisions documented with alternatives
- ✅ START-HERE that restores context in 2 minutes

**Avoid:**
- ❌ Phases without exit criteria
- ❌ Vague requirements without acceptance criteria
- ❌ Decisions without alternatives considered
- ❌ Stale START-HERE that doesn't reflect current state

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Spec Management",
  TaskStatus: "Spec updated. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Managed spec {name}. Current phase: {phase}. Status: {status}."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Spec managed: docs/specs/{name}/

Next steps:
1. /plan - Create plan for next phase
2. /work - Execute current phase items
```

---

## References

- Templates: `docs/specs/templates/`
- Create phase plans: `/plan`
- Execute phase work: `/work`
- Record solutions: `/compound`

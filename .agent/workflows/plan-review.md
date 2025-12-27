---
description: Review implementation plans for quality and completeness. Use before starting work on a plan.
triggers: [housekeeping, plan, specs, work]
uses: [compound-docs]
---

# /plan-review - Plan Quality Review

Review an implementation plan for completeness and quality before execution.

> **Why review plans?** A flawed plan leads to wasted effort. 10 minutes of review can save hours of rework.

## When To Use

- Before starting `/work` on any plan
- When inheriting a plan from another session
- For self-review of your own plans
- Reviewing a specification from `/specs`

---

## Workflow

### Step 0: Search for Existing Solutions

> [!CAUTION]
> **BLOCKING STEP.** Before reviewing the plan's approach, verify we're not reinventing the wheel.

```bash
// turbo
./scripts/log-workflow.sh "/plan-review" "$$"
./scripts/compound-search.sh "{main problem keywords}"
./scripts/log-skill.sh "compound-docs" "workflow" "/plan-review"
```

**See also:** `skills/compound-docs/SKILL.md` for cross-referencing findings.

**If solutions found:**
1. Cross-reference with the plan's approach — are we reinventing?
2. Update references if the plan should use existing solutions:
   ```bash
   // turbo
   ./scripts/update-solution-ref.sh {paths}
   ```

#### ⛔ CHECKPOINT: Did the plan author run compound-search?

- [ ] Plan includes "## Prior Solutions" section (or explicitly states "none found")?
- [ ] If existing solutions apply, are they referenced in the approach?

**Flag missing compound search as a review concern.**

---

### Step 1: Load Plan

Read the plan file and understand the scope:

```bash
cat plans/{plan-name}.md
```

---

### Step 2: Check Completeness

**Requirements:**
- [ ] Problem statement clear and specific
- [ ] Success criteria defined and measurable
- [ ] Scope boundaries explicit (what's in/out)

**Research:**
- [ ] Codebase patterns referenced
- [ ] Best practices cited or linked
- [ ] Alternatives considered and rejected with reasons

**Implementation:**
- [ ] Steps actionable (not vague)
- [ ] Dependencies identified
- [ ] Risks acknowledged with mitigations

**Lifecycle:**
- [ ] Verification plan included
- [ ] Related specs/todos referenced (if any)

---

### Step 2.5: Spec-Specific Checks (If Reviewing a Spec)

**If verifying a `docs/specs/` document:**
- [ ] Phases have clear exit criteria in `03-tasks.md`
- [ ] `00-START-HERE.md` restores context in <2 minutes
- [ ] `04-decisions.md` initialized (even if empty)
- [ ] `README.md` dashboard accurately reflects current status

---

### Step 3: Deep Gap Analysis

> [!CAUTION]
> This step requires deliberate, slow thinking. Question everything.

**Did the plan think hard enough?**
- [ ] Are 2nd-4th order effects considered?
- [ ] Are long-term implications (6mo, 1yr) addressed?
- [ ] Is the approach reversible if assumptions are wrong?

**Edge Case Coverage (Leave No Stone Unturned):**
- [ ] Boundary conditions (min, max, at-limit)
- [ ] Failure modes (network, DB, external services)
- [ ] Concurrent access / race conditions
- [ ] Data extremes and migration scenarios
- [ ] User behavior edge cases

**Stakeholder Impact (Who else is affected?):**
- [ ] End users notified of behavior changes?
- [ ] Breaking changes communicated to other devs?
- [ ] Ops/support aware of new failure modes?
- [ ] Downstream integrations considered?

**Standard Gap Checks:**
- [ ] Missing dependencies
- [ ] Unclear requirements / unstated assumptions
- [ ] **Missing compound solutions** (did we search before planning?)

---

### Step 4: Provide Feedback

Save the feedback to `plans/reviews/{plan-name}-review.md`.

```markdown
## Plan Review: {Plan Name}
...
```

---

### Step 5: Update Plan Status

If approved, update the plan:

```markdown
> Status: Completed ✓
```

---

### Step 6: Proceed to Execution (If Approved)

Once the plan is approved and the status is updated:

> [!IMPORTANT]
> **Workflow Transition**
> Do not execute the plan ad-hoc. Transition immediately to the **/work** workflow.

```bash
# Start the work workflow
/work
```

---

### Step 7: Create Revision Todo (CONDITIONAL)

**If Verdict is "Needs major revisions":**

> [!CAUTION]
> **Action Required.** Don't just leave feedback in the chat. Create a todo for the revision work.

```bash
./scripts/create-todo.sh "p1" "Revise Plan: ${plan_name}" \
  "Plan review identified major issues in plans/${plan_name}.md that need to be addressed before execution can proceed.\n\nReview: plans/reviews/${plan_name}-review.md\n\nConcerns:\n(Paste summary of concerns here)" \
  "Revise plan to address concerns" \
  "Re-request review"
```

---

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

> [!IMPORTANT]
> **Visual Completion Signal**
> Call `task_boundary` one last time to signal completion in the user's UI. This prevents the "task" from appearing active after you've finished.

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Plan Review: {Plan Name}",
  TaskStatus: "Review complete. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Completed plan review for {plan name}. Verdict: {Ready/Needs Revisions}. {Key findings summary}."
});
```

#### Step 2: Mandatory Handoff

> [!IMPORTANT]
> **Exit Transition**
> Do not stop here. Offer the user clear paths to the next logical workflow.

```bash
✓ Review complete

Next steps:
1. /work - Execute the approved plan (if verdict: Ready)
2. Revise plan - Address review concerns (if verdict: Needs Revisions)
3. /specs - Elevate to specification if scope expanded during review
4. Create revision todo - For major revision tracking
```

---

## Quality Guidelines

**Good reviews:**
- ✅ Check compound solutions first
- ✅ Verify measurable success criteria
- ✅ Confirm scope boundaries
- ✅ Validate risks are acknowledged

**Avoid:**
- ❌ Rubber-stamping without reading
- ❌ Skipping compound search
- ❌ Ignoring missing success criteria

---

## References

- Create plans: `/plan`
- Execute plans: `/work`
- Search solutions: `./scripts/compound-search.sh`
- Archive when done: `/housekeeping`

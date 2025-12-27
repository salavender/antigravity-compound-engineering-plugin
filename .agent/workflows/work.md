---
description: Execute work plans systematically while maintaining quality. Use after /plan to implement features.
---

# /work - Systematic Plan Execution

Execute a work plan efficiently while maintaining quality and finishing features completely.

> **Why systematic execution?** Random implementation leads to incomplete features. Following a plan with continuous testing ships complete, working code.

## When To Use

- After creating a plan with `/plan`
- When working from a specification or todo file
- For any multi-step implementation

---

## Workflow

### Step -1: Resume Context (If New Session)

> [!CAUTION]
> **BLOCKING STEP.** If this is a NEW CONVERSATION, follow the session-resume skill first.

```bash
cat skills/session-resume/SKILL.md
./scripts/log-skill.sh "session-resume" "workflow" "/work"
```

### Step 0: Search Before Solving

Before diving in, check if similar problems were solved:

```bash
// turbo
./scripts/log-workflow.sh "/work" "$$"
./scripts/compound-search.sh "{relevant keywords}"
./scripts/log-skill.sh "compound-docs" "workflow" "/work"
```

This 30-second search can save hours of reinventing solutions.

**See also:** `skills/compound-docs/SKILL.md` for solution investigation.

> [!IMPORTANT]
> **Implicit Workflow Triggers (Pattern #13)**
> This workflow should be triggered automatically when users approve a plan with phrases like "Proceed", "Go ahead", or "LGTM". Do not execute plans ad-hoc—always use this workflow protocol.
> 
> See [Critical Patterns](file:///Users/macbookair/Documents/GitHub/[PROJECT_NAME]/docs/solutions/patterns/critical-patterns.md#pattern-13-implicit-workflow-triggers) for full trigger table.

---

### Step 0.5: Planning Rigor Check (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Before diving into execution, verify the plan is rigorous.

If working from a plan file, confirm it addresses:

- [ ] **Multi-Order Effects:** Are 2nd–4th order effects documented?
- [ ] **Stakeholder Impact:** Are End Users, Devs, and Ops impacts considered?

**If missing:** Add a brief analysis before proceeding, or flag for `/plan` revision.

**See also:** Pattern #9 in `docs/solutions/patterns/critical-patterns.md`

---

### Phase 1: Quick Start

#### Step 1: Read and Clarify

```
Before starting, I'll review the plan and ask any clarifying questions.

[Read the plan file]

Questions about this plan:
1. [Any unclear requirement]
2. [Any ambiguity]

Should I proceed, or do you want to clarify anything first?
```

**Do not skip this** - better to ask questions now than build the wrong thing.

#### Step 2: Setup Environment

**Option A: Live work on current branch**
```bash
git checkout main && git pull origin main
git checkout -b feature/{feature-name}
```

**Option B: Isolated worktree (recommended for parallel work)**
```bash
git worktree add ../feature-{name} -b feature/{name}
cd ../feature-{name}
```

**Use worktree if:**
- Working on multiple features simultaneously
- Want to keep main clean while experimenting
- Plan to switch between branches frequently

#### Step 3: Create Todo List

Break the plan into actionable tasks:

```
## Implementation Tasks

- [ ] Task 1: [Specific action]
- [ ] Task 2: [Specific action]
- [ ] Task 3: [Specific action]
- [ ] Run full test suite
- [ ] Final review
```

**Tip:** Use `skills/file-todos/SKILL.md` to manage these tasks if they evolve into standalone work items.

### Phase 2: Execute

#### Task Execution Loop

```
while (tasks remain):
  1. Mark current task as in_progress
  2. Read referenced files from plan
  3. Look for similar patterns in codebase
  4. Implement following existing conventions
  5. Write tests for new functionality
  6. Run tests after changes
  7. Mark task as completed
```

#### Follow Existing Patterns

- [ ] Read similar code referenced in plan first
- [ ] Match naming conventions exactly
- [ ] Reuse existing components where possible
- [ ] Follow project coding standards
- [ ] When in doubt, grep for similar implementations:
  ```bash
  grep -r "similar_pattern" --include="*.ts" src/
  ```

#### Test Continuously

- [ ] Run relevant tests after each significant change
- [ ] Don't wait until the end to test
- [ ] Fix failures immediately
- [ ] Add new tests for new functionality

```bash
# Run tests frequently
npm test -- --watch
# or
pytest -x  # stop on first failure
```

#### Track Progress

Update task list as you work:
```
- [x] Task 1: Completed
- [/] Task 2: In progress ← current
- [ ] Task 3: Not started
```

### Phase 3: Quality Check

#### Run Core Checks

```bash
# Run full test suite
npm test
# or
pytest

# Run linting
npm run lint
# or
ruff check .
```

#### Optional Reviewer Checks

For complex/risky changes, consider review passes:

| Check | When To Use |
|-------|-------------|
| Simplicity review | Large changes, refactors |
| Security review | Auth, data handling |
| Performance review | Database, loops, APIs |

#### Final Validation Checklist

- [ ] All tasks marked completed
- [ ] All tests pass
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] No console.log/print statements left
- [ ] No TODO comments left unaddressed

#### Convert Remaining Tasks to Todos

If any implementation tasks remain unchecked (scope reduced, deferred, etc.):

```bash
# Create todo for each uncompleted task
./scripts/create-todo.sh "p2" "{description}" \
  "Task from /work workflow that was not completed: {description}." \
  "Complete task" "Verify implementation"
```

**Note:** Reference `skills/file-todos/SKILL.md` for standard todo statuses and prioritization.

> [!NOTE]
> Don't close `/work` with unchecked tasks in your inline list. Either complete them or convert to todos.

### Phase 3.5: Documentation Update (MANDATORY)

> [!IMPORTANT]
> Code without documentation is incomplete work.

**Checklist:**
- [ ] Did this change add/modify user-facing functionality?
- [ ] If yes: Update relevant docs (README, API docs, etc.)
- [ ] If yes: Add entry to CHANGELOG

**Common docs to update:**
| Change Type | Update Target |
|-------------|---------------|
| New script | Add to relevant README (e.g., `scripts/README.md`) |
| New workflow | Add to `.agent/workflows/README.md` |
| New API endpoint | Update API documentation |
| New component | Update component docs |
| Config change | Update setup/installation docs |

> [!TIP]
> Ask: "If a new developer joins tomorrow, what would they need to know about this change?"

### Phase 4: Ship

#### Update Changelog

If this work includes user-facing changes:

```bash
# Generate changelog entry
npm run changelog:gen
```

#### Update Source Todo Status (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP:** You must run this BEFORE committing user-facing changes if working from a todo.

```bash
./scripts/complete-todo.sh todos/{todo-filename}.md
./scripts/log-skill.sh "file-todos" "workflow" "/work"
```

#### Commit Changes

Use conventional commits:
```bash
git add -A
git commit -m "feat: {feature description}

- Implemented X
- Added tests for Y
- Updated Z

Generated with /work"
```

#### Create Pull Request

```bash
git push -u origin feature/{name}
gh pr create --title "feat: {feature}" --body "
## Summary
{What this PR does}

## Changes
- {Change 1}
- {Change 2}

## Testing
- {How it was tested}

## Screenshots
{If UI changes}
"
```

#### Update Spec Status (if working from a spec specific plan)

If your plan is located in `docs/specs/{name}/plans/`:

> [!IMPORTANT]
> **Spec Phase Completion Protocol**

1. **Run Automation Script:**
   ```bash
   // turbo
   ./scripts/update-spec-phase.sh {spec_name} {phase_num} complete
   ```
   *This single command updates `03-tasks.md`, `README.md`, and `00-START-HERE.md` ensuring they are perfectly in sync.*

2. **Verify Consistency:**
   - Run `ls docs/specs/{name}/` to ensure structure is clean

#### Update Plan Status (if working from a plan)

If you executed a plan from `plans/`:

```bash
# Update plan status manually
# Change: Status: Draft → Status: Implemented
```

> [!NOTE]
> Plans don't have automated completion scripts (unlike todos). Update the status line manually when all acceptance criteria are checked.

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

> [!IMPORTANT]
> **Visual Completion Signal**
> Call `task_boundary` one last time to signal completion in the user's UI. This prevents the "task" from appearing active after you've finished.

```javascript
await task_boundary({
  TaskName: "[COMPLETED] {Feature/Task Name}",
  TaskStatus: "Work verified and documented. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Summary of accomplishments..."
});
```

#### Step 2: Mandatory Handoff

> [!IMPORTANT]
> **Exit Transition**
> Do not stop here. Offer the user clear paths to the next logical workflow.

```bash
✓ Work complete

Next steps:
1. /review - Get feedback on changes
2. /compound - Document interesting solutions/patterns discovered
3. /housekeeping - Cleanup and archive if no more work remains
4. Continue working - More tasks to complete
```

#### Offer Next Steps

```
✓ Work complete

What's next?
1. Create PR - Push and open pull request
2. Run review - Get /review feedback on changes
3. Document solution - Run /compound if you solved interesting problems
4. Continue working - More tasks to complete
```

---

## Quality Guidelines

**Good execution:**
- ✅ Follow the plan, don't improvise
- ✅ Test after every change
- ✅ Commit frequently with clear messages
- ✅ Ask before deviating from plan

**Avoid:**
- ❌ Skipping tests until the end
- ❌ Large uncommitted changes
- ❌ Ignoring existing patterns
- ❌ Scope creep without updating plan

---

## References

- Create plans: `/plan`
- Review plans: `/plan-review`
- Review changes: `/review`
- Document solutions: `/compound`
- Triage remaining work: `/triage`
- Archive when done: `/housekeeping`

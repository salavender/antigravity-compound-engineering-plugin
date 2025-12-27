---
description: Systematic structural improvement with zero regression risk. Refactoring-specific workflow.
triggers: [compound, explore, review, work]
uses: []
---

# /refactor - Structural Improvement (Zero-Risk Loop)

Execute focused refactoring with regression test coverage and zero-risk validation. Unlike `/work` (which is feature-oriented), this workflow emphasizes safety and pattern alignment.

> **Why refactor systematically?** Structural debt compounds into development friction. Safe, pattern-aligned refactoring compounds into velocity and architecture coherence.

## When To Use

- Extracting logic from large components or functions
- Consolidating duplicate logic
- Improving test coverage
- Aligning code with existing architectural patterns
- Standardizing patterns across the codebase

---

## Workflow

### Phase 1: Preparation (30-60 min)

#### Step 1: Define the Refactoring Scope

State clearly:
- **What** is being refactored
- **Why** (architectural goal, debt reduction)
- **Acceptance Criteria**

```markdown
## Refactoring Plan

**Target:** [File or Module Path]
**Why:** [Goal]

**Success Criteria:**
- [ ] All tests pass
- [ ] No behavioral changes
- [ ] Follows project patterns
```

#### Step 2: Search for Related Refactorings

Learn from similar improvements:

```bash
./scripts/compound-search.sh "refactor {domain}"
```

#### Step 3: Establish Test Baseline

Ensure you have regression coverage BEFORE making changes:

```bash
# Run relevant tests
# npm test / pytest / etc.
```

**Requirement:** Maintain or improve existing coverage.

#### Step 4: Check Pattern Alignment

Ensure your refactoring aligns with project standards:

```bash
cat docs/solutions/patterns/critical-patterns.md | grep -i "{domain}"
```

---

### Phase 2: Execution (1-4 hours)

#### Step 5: Refactor in Small Steps

Make atomic changes. After each step, run tests and verify behavior.

#### Step 6: Validate Behavior Preservation

Ensure zero behavioral change through automated tests and manual spot-checks.

---

### Phase 3: Documentation & Merge

#### Step 7: Document the Refactoring

Create a solution document or update existence patterns.

#### Step 8: Commit with Clear Message

```bash
git commit -m "refactor: {target} to improve {goal}

- [Detail 1]
- [Detail 2]

Tests: All baseline tests passing."
```

---

## Safety Checkpoints

- [ ] Baseline tests pass before starting
- [ ] Manual verification confirms identical behavior
- [ ] Test coverage is maintained or increased
- [ ] Architectural goal matches project patterns

---

## Related Workflows

- **Before refactoring:** Use `/explore` if unsure about the approach
- **After refactoring:** Use `/review` to ensure code quality
- **If you discover new patterns:** Use `/compound` to document for the team

---

## Instrumentation

```bash
./scripts/log-skill.sh "refactor" "workflow" "$$"
```

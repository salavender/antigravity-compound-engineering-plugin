---
description: Deep investigation before planning. Use for best practices, implications, and systematic analysis.
---

# /explore - Research and Deep Thinking

Conduct a deep, systematic pre-planning investigation to gather industry best practices, analyze multi-order effects, and understand complex problems before committing to a formal plan.

> **Why explore?** A plan built on assumptions is a liability. 30 minutes of deep exploration compounds into architectural excellence and prevents costly rework.

## When To Use

- Before any `/plan` for complex features
- When investigating unfamiliar technologies or patterns
- For bugs requiring deep root-cause analysis
- Anytime you think: "I need to understand this better before I decide."

---

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/explore" "$$"
./scripts/compound-search.sh "exploration"
```

### Step 1: Search Existing Knowledge (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Search both solutions AND prior explorations.

```bash
// turbo
./scripts/compound-search.sh "{keywords}"
ls docs/explorations/*.md | grep "{keyword}"
```

### Step 1.5: Define the Question

State exactly what we are trying to understand.
*Example: "What is the most robust way to handle multi-session task orchestration in a stateless agentic system?"*

### Step 2: Scope & Time-box

Set boundaries to avoid rabbit holes.
- **Time-box:** How long will we explore? (e.g., 30m, 1h, 1 day)
- **Success Criteria:** What specific answer or evidence do we need?

---

### Step 3: Internet Research (Recommended)

> [!TIP]
> **Best Practice.** Verification of industry standards is highly encouraged.

```bash
// turbo
search_web("{topic} best practices software engineering")
search_web("{topic} common pitfalls and anti-patterns")
search_web("{topic} design patterns comparison")
```

**Summarize industry standards in the exploration artifact.**

---

### Step 4: Deep Systematic Analysis

Apply multi-order thinking and holistic analysis.

**Multi-Order Consequences ("And Then What?"):**
- **1st order:** Immediate impact of the potential change.
- **2nd order:** What depends on those changes?
- **3rd order:** Cascading effects (drift, technical debt).
- **4th order:** Long-term cultural or architectural shifts.

**Stakeholder Impact Matrix:**
Assess impact on End Users, Developers, Ops/Support, and Downstream Systems.

---

### Step 5: Document Findings

Create the exploration file at `docs/explorations/{topic}-{YYYYMMDD}.md`.
Use the template at `docs/explorations/templates/exploration-template.md`.

### Step 6: Long-Term Implications Check

- **6 months/1 year:** How will this age?
- **Reversibility:** Can we undo this? (Type 1 vs Type 2 decisions)
- **Technical Debt:** Does this create or pay down debt?

---

### Step 7: Decision Gate

Decide on the next logical action:
1. **Proceed to /plan:** We have enough understanding to build.
2. **Proceed to /specs:** This is a major iniciativa.
3. **Create Todo:** Defer based on findings.
4. **No Action:** Learning captured, no change needed.
5. **Escalate:** Needs human stakeholder input.

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Exploration: {Topic}",
  TaskStatus: "Exploration complete. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Completed deep exploration of {topic}. Findings documented in docs/explorations/{filename}. Decision: {Gate Decision}."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Exploration complete

Next steps:
1. /plan - Create plan based on findings (if proceed)
2. /specs - Create specification (if major initiative)
3. /triage - File found issues as todos
```

---

## Quality Guidelines

- ✅ Internet search for industry standards is encouraged.
- ✅ Document "And Then What?" at least to 3rd order.
- ✅ Explicitly state when something is a "Type 1" (irreversible) decision.
- ✅ Link findings back to codebase patterns.

---

## References

- Explorations directory: `docs/explorations/`
- Solutions: `docs/solutions/`
- Pattern #11: Explore Before Plan

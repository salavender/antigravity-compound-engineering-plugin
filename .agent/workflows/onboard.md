---
description: Knowledge priming and context establishment for new sessions. Bootstrap agent/developer into current project state.
triggers: [explore, housekeeping, plan, review, specs, work]
uses: [session-resume]
---

# /onboard - Knowledge Priming and Context Establishment

Prime the agent with the foundational knowledge needed to work effectively on the project. This workflow bootstraps understanding of architecture decisions, specifications, critical patterns, and recent context.

> **Why onboard?** A well-primed agent avoids repeating mistakes, respects architectural patterns, and makes decisions aligned with project strategy. This compounds into quality and velocity.

## When To Use

- At the start of any new session (run proactively)
- Before working on unfamiliar components or systems
- When joining a sub-team or domain you haven't touched recently
- When the project structure or strategy has significantly changed

---

## Workflow

### Step 1: Load Session Context (IMMEDIATE)

Restore state from previous session:

```bash
./scripts/compound-dashboard.sh
cat skills/session-resume/SKILL.md
```

**Check:**
- Grade (target: B or higher)
- Any warnings or blockers
- Recommended next steps from previous session

### Step 2: Review Architecture Decisions (5-10 min)

Understand the project's strategic choices:

```bash
ls -lt docs/decisions/*.md | head -5
cat docs/decisions/critical-patterns.md
```

**Read:**
- The 3-5 most recent ADRs (Architecture Decision Records)
- `docs/decisions/patterns/critical-patterns.md` (Pattern reference)
- Any ADRs relevant to your planned work area

**Questions to answer:**
- What are the non-negotiable architectural principles?
- What technology choices are locked-in vs. open?
- What past mistakes should I avoid?

### Step 3: Review Active Specifications (5-10 min)

Understand ongoing initiatives:

```bash
ls docs/specs/*/README.md
cat docs/specs/*/README.md | head -50
```

**For each active spec:**
- What phase are we in?
- What dependencies exist?
- What are the blockers?

### Step 4: Search Recent Solutions (5-10 min)

Learn from recent problem-solving:

```bash
./scripts/compound-search.sh "{domain}"
ls -lt docs/solutions/**/*.md | head -10
```

**Focus on:**
- Solutions in your planned work domain
- Any patterns or decisions marked "Critical"
- Recent explorations that might inform your approach

### Step 5: Check Active Work (2-5 min)

Understand what's in motion:

```bash
ls todos/*-ready-*.md todos/*-in-progress-*.md 2>/dev/null
cat todos/*-in-progress-*.md
```

**Questions:**
- What is blocked and why?
- What depends on my work?
- What should I NOT touch right now?

### Step 6: Establish Personal Context (2-5 min)

State your session's goals:

**Write a brief session summary** to `docs/sessions/session-YYYYMMDD-N.md`:

(Use template at `docs/sessions/template/session-template.md` or follow format below)

```
📍 Session Context Established:

**Project State:** [Grade from dashboard]
**Active Initiatives:** [Key specs in motion]
**My Role This Session:** [What I'm doing]
**Constraints:** [Things I should NOT do]
**Dependencies:** [Who/what I depend on]

**Next Action:** [First concrete task]
```

---

## Success Criteria

- [ ] Dashboard health grade confirmed (B or higher)
- [ ] At least 3 recent ADRs reviewed
- [ ] Active specifications understood
- [ ] Personal session context documented
- [ ] Ready to start work with full context

---

## Common Issues

### "I don't see docs/specs/"

**Solution:** The project might not be using formal specs yet. Check `docs/decisions/` instead.

### "There are too many solutions!"

**Solution:** Use `./scripts/compound-search.sh "{domain}"` to filter by topic.

### "The last session left incomplete work"

**Solution:** Check `todos/*-in-progress-*.md` for details. Decide: resume or defer.

---

## Related Workflows

- **After onboarding:** Use `/plan` or `/work` based on your context
- **If you discover gaps:** Use `/explore` to research unfamiliar areas
- **At session end:** Use `/review` to document your work, then `/housekeeping` to archive it

---

## Instrumentation

```bash
./scripts/log-skill.sh "onboard" "workflow" "$$"
```

## Notes

This workflow is mandatory at session start. Skipping it may lead to:
- Architectural violations
- Duplicate work
- Missed context from ongoing initiatives
- Poor decision-making due to incomplete information

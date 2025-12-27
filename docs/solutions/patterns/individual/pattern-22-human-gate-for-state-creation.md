---
pattern_number: 22
title: "Human Gate for State Creation"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #22: Human Gate for State Creation


**Problem:** Fully automated systems that create actionable state (like todo files, bug reports, or skill suggestions) without a human-in-the-loop validation gate inevitably lead to backlog pollution, duplicate work, and quality erosion.

**❌ WRONG:**
```bash
# Automated script detects a potential gap and auto-creates a P2 todo
if [ "$gap_detected" == "true" ]; then
  ./scripts/create-todo.sh "p2" "Create skill for $tag" ...
fi
```
*Result: 14+ unvalidated P2 todos pollute the backlog in 48 hours.*

**✅ CORRECT:**
```bash
# Automated script suggests the gap but requires explicit action to create state
if [ "$gap_detected" == "true" ]; then
  echo "   - 💡 Suggestion: Potential skill gap detected for '$tag'"
  echo "     Run 'create-skill.sh $tag' to initialize."
fi
```
*Result: Backlog remains high-signal; human/agent validates necessity before committing state.*

**Rule:** Automated discovery systems should **suggest**, but only human-approved or explicitly triggered processes should **create** actionable state.

**Why:** Backlog quality is the foundation of agent efficiency. Low-signal noise in the `todos/` or `plans/` directories causes priority inflation and hides genuine architectural gaps.

**Source:** Observations on backlog pollution from automated skill discovery.

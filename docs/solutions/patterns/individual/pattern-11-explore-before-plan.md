---
pattern_number: 11
title: "Explore Before Plan"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #11: Explore Before Plan


**Problem:** Plans for complex features are often built on assumptions rather than deep understanding. This leads to missed 2nd-4th order effects, ignorance of industry best practices, and costly architectural rework.

**❌ WRONG:**
Diving straight into `/plan` for a complex architectural change without researching how other systems solve it or analyzing cascading ripple effects.

**✅ CORRECT:**
Use the `/explore` workflow before `/plan` to:
1. Conduct internet research for best practices (recommended).
2. Analyze multi-order consequences (1st-4th order).
3. Assess long-term implications (6mo/1yr) and reversibility.
4. Document findings in `docs/explorations/` to compound knowledge.

**Why:** Exploration produces **understanding**; planning produces **action**. Separating these concerns ensures that decisions are evidence-based and holistic, saving hours of rework during execution.

**Source:** Evolution of the research-first workflow protocol.

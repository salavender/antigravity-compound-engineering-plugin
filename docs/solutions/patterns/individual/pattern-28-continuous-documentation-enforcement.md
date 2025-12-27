---
pattern_number: 28
title: "Continuous Documentation Enforcement"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #28: Continuous Documentation Enforcement


**Problem:** Mandatory documentation steps (like `/doc`) are often ignored during high-velocity work. This breaks the link between code and its explanation, leading to stale READMEs and invalid changelogs that pass structural validation but lack semantic accuracy.

**❌ WRONG:**
```markdown
# /work workflow
Phase 3.5: Documentation Update (MANDATORY)
- [ ] Run /doc
- [ ] Update changelog
```
*(Agent completes Phase 3.5 without running `/doc` and proceeds to Phase 4. Documentation drift occurs immediately.)*

**✅ CORRECT:**
```markdown
# /work workflow
Phase 3.5: Documentation Update (MANDATORY)
- [ ] Run /doc
- [ ] Update changelog

**Automated Validation:**
```bash
./scripts/validate-folder-docs.sh
```
*(Workflow is gated by an automated check. The agent cannot proceed past Phase 3.5 until the script confirms that every modified folder has a fresh documentation entry for today.)*

**Why:** Passive checklists fail in high-pressure environments. By embedding gated automated validation directly into the execution and review workflows, we transform documentation from a "best effort" task into a foundational requirement.

**Canonical Implementation:** `scripts/validate-folder-docs.sh`

**Source:** Evolution of automated documentation enforcement.

---
pattern_number: 9
title: "Rigorous Planning (Multi-Order Thinking)"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #9: Rigorous Planning (Multi-Order Thinking)


**Problem:** Plans focus on structural completion (filling checklists) rather than deep architectural rigor and foresight, leading to unforeseen 2nd-order side effects and missed stakeholder impacts.

**❌ WRONG:**
```
"I will update the API endpoint to add a new field. No risks identified."
```

**✅ CORRECT:**
```
"1st Order: New field added to API.
2nd Order: Frontend components using this API need updating.
3rd Order: Downstream cache needs invalidation.
4th Order: External reporting tool (System X) might fail if it relies on strict schema.
Stakeholder: Ops needs to monitor cache hit rates during rollout."
```

**Multi-Order Thinking Checklist:**
- [ ] **1st order:** What does this change directly affect?
- [ ] **2nd order:** What depends on those affected things?
- [ ] **3rd order:** What cascading effects could occur?
- [ ] **4th order:** Could this affect unrelated systems through shared dependencies?

**Stakeholder Impact Checklist:**
- [ ] **End Users:** Will this change behavior they rely on? UX disruption?
- [ ] **Other Developers:** Breaking API changes? Documentation needs?
- [ ] **Operations/Support:** New failure modes? Monitoring/alerting updates?

**Why:** Each hour spent in deep analysis during planning saves 5-10 hours of rework during execution. Assuming no 2nd-order effects exist is a common failure mode.

**Source:** Implementation of rigorous planning and review workflows.

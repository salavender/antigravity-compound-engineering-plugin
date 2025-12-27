---
pattern_number: 13
title: "Observability by Default"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #13: Observability by Default


**Problem:** Scripts and skills that do not self-report usage create blind spots in the system dashboard, making it impossible to optimize agent capabilities.

**❌ WRONG:**
```bash
# custom-script.sh
# ... logic ...
echo "Done"
```
*Silent execution leaves no trace.*

**✅ CORRECT:**
```bash
# custom-script.sh
./scripts/log-skill.sh "my-skill" "automated" "$$"
# ... logic ...
```
*Explicit logging empowers the dashboard.*

**Why:** You cannot improve what you cannot measure. If tools don't report their usage, the system cannot learn which tools are valuable or broken.

**Source:** Dashboard observability improvements.

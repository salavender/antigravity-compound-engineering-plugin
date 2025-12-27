---
pattern_number: 4
title: "Housekeeping Before Push"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #4: Housekeeping Before Push


**Problem:** Accumulating completed todos, plans, and specifications in active directories creates noise, slows down context restoration for new agent sessions, and leads to state drift between documentation and actual implementation status.

**❌ WRONG:**
```bash
# Developer finishes work and pushes immediately
git push
# Active directories stay cluttered with -complete- files
```

**✅ CORRECT:**
```bash
# Always run housekeeping before push
/housekeeping 
# OR
./scripts/pre-push-housekeeping.sh --fix
git push
```

**Why:** A clean repository is a predictable repository. Regular archiving ensuring that active workspaces only contain work-in-progress, making it much easier for both human and AI agents to understand what needs attention.

**Source:** System workflow hardening observations.

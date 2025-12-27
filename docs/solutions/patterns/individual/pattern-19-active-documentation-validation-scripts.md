---
pattern_number: 19
title: "Active Documentation (Validation Scripts)"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #19: Active Documentation (Validation Scripts)


**Problem:** Documentation (READMEs, indexes, architecture maps) naturally drifts from the actual state of the codebase as features are added or modified. Passive documentation (text-only) is easily ignored and often becomes a "lie," eroding developer trust and leading to discovery failures.

**❌ WRONG:**
Relying solely on manual updates to a list of scripts in a `README.md`.
```markdown
## Available Scripts
- script_a.sh
- script_b.sh
```
*A developer adds `script_c.sh` but forgets to update the README. The system is now out of sync.*

**✅ CORRECT:**
Enforce documentation accuracy with **Active Validation Scripts** that fail the build/push if drift is detected.
```bash
# scripts/validate-architecture.sh
expected_count=$(grep "scripts:" docs/architecture.md | awk '{print $2}')
actual_count=$(ls scripts/*.sh | wc -l)

if [ "$expected_count" != "$actual_count" ]; then
  echo "ERROR: Documentation drift detected!"
  exit 1
fi
```

**Why:** Documentation that *cannot lie* is the only documentation that can be trusted. By coupling architectural maps with automated validation scripts, the system forces documentation to remain a Single Source of Truth.

**Canonical Implementation:** `scripts/validate-patterns.sh`

**Source:** Documentation hygiene and freshness system analysis.

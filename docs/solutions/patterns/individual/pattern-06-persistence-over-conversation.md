---
pattern_number: 6
title: "Persistence Over Conversation"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #6: Persistence Over Conversation


**Problem:** Workflows generate actionable outputs (bugs, findings, next steps) that are only printed in the conversation. When the session ends, the context is lost and work is forgotten. This creates "invisible work" that doesn't survive session boundaries.

**❌ WRONG:**
```markdown
# /reproduce-bug workflow
### Step 3: Document Results
- [x] Reproduced: Yes
- [x] Consistent: Every time

### Next Steps
- [ ] Debug further
- [ ] Plan fix with /plan

# Agent prints results but creates no todo file
# Session ends → Work lost
```

**✅ CORRECT:**
```markdown
# /reproduce-bug workflow
### Step 4: Persist Next Steps (MANDATORY)
next_id=$(./scripts/next-todo-id.sh)
cat > todos/${next_id}-pending-p1-fix-repro-bug.md << EOF
# Fix: {Bug Title}
Reproduction successful. See details in issue #{issue_number}.
EOF
```

**Rule:** Any workflow that generates actionable output (bug reports, findings, next steps, review feedback) MUST persist that output as a todo file, NOT just print it in conversation.

**Why:**
- **Session Boundaries:** Agent memory is cleared between sessions
- **Discoverability:** Printed outputs are buried in chat logs; todo files are indexed by `/triage` and `/resolve-todo`
- **Accountability:** Files can be tracked, prioritized, and verified for completion

**Affected Workflows:**
- `/report-bug` → Must create local todo after filing GH issue
- `/reproduce-bug` → Must convert "Next Steps" to todo
- `/plan-review` → Must create revision todo if "Needs major revisions"
- `/review` → Must create todos for all P1/P2 findings
- `/work` → Must convert uncompleted inline tasks to todos

**Source:** Derived from workflow todo integration analysis.

---
name: session-resume
description: Resume context from previous session
---

# Session Resume Skill

Helps agents quickly understand where work left off when starting a new session.

## When To Use

- At the **start of any new conversation**
- When context seems missing
- When user asks "what were we working on?"

## Instrumentation

```bash
# Log usage when using this skill
./scripts/log-skill.sh "session-resume" "manual" "$$"
```

---

## Quick Resume Checklist

### 1. Check Active Work

```bash
# Ready todos (highest priority)
ls todos/*-ready-*.md 2>/dev/null | head -5

# In-progress plans
ls plans/*.md 2>/dev/null

# Recent solutions (for context)
ls -t docs/solutions/**/*.md 2>/dev/null | head -3
```

### 2. Check Recent Git Activity

```bash
# Recent commits
git log --oneline -5

# Uncommitted changes
git status --short
```

### 3. Summarize Context

After gathering info, summarize:

### 4. Check System Health

```bash
./scripts/compound-dashboard.sh
```

Review health grade and recommendations before starting work.

### 5. Final Summary

```
📍 Session Context:

**Active Work:**
- {X} ready todos waiting
- Plan in progress: {plan name if any}

**Recent Activity:**
- Last commit: {subject}
- {Changed files if uncommitted}

**Suggested Next Steps:**
1. {Most logical next action}
2. {Alternative}
```

---

## Automatic Triggers

Consider running this skill when you see:
- User starts with "continue", "resume", "where were we"
- First message in a new session
- User seems to lack context

---

## References

- Todos: `todos/`
- Plans: `plans/`
- Solutions: `docs/solutions/`
- Workflows: `.agent/workflows/`

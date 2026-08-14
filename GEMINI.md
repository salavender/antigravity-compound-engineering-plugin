# Compound Project - Agent Configuration

## Project Overview

This project implements the Compound Learning System for {PROJECT_NAME} - a self-improving knowledge system based on the "Compounding Engineering" philosophy.

## Core Principle

> **Each unit of engineering work should make subsequent units of work easier—not harder.**

## Workflows Available

> **Full index:** See [.agent/workflows/README.md](.agent/workflows/README.md) for all commands and quick start guide.

Use these commands for systematic development:

| Command | When |
|---|---|
| `/explore` | Deep investigation before planning |
| `/specs` | Before multi-week initiatives |
| `/plan` | Before starting significant work |
| `/work` | Execute plans systematically |
| `/review` | Before merging, self-review |
| `/compound` | After solving problems ("that worked!") |
| `/housekeeping` | Before git push (cleanup & archive) |
| `/tracker-routing` | Before creating/moving work between Linear and GitHub |

## Knowledge Persistence

Solutions are documented in `docs/solutions/` and explorations in `docs/explorations/` with:
- YAML frontmatter for searchability
- Categorized by problem type
- Schema validated (`schema.yaml`)

**Before solving a problem:** Search `docs/solutions/` and `docs/explorations/` for prior knowledge.

**After solving a problem:** Run `/compound` to document it.

## Compounding Loop

```
/explore (optional) → /specs (large) → /plan (per phase) → /work → /review → /compound → /housekeeping → repeat
```

## Work-surface boundary

Do not turn the compound system into a second project-management database.

```text
Git docs/specs/ADRs  = durable truth
GitHub Issues/PRs    = engineering execution + evidence
Linear               = temporary attention, brainstorming, decisions, gates
```

Use `/tracker-routing` before creating or moving work objects.

### Linear

Use Linear for collaborative reasoning, product/strategy questions, architecture alternatives, risk acceptance, go/no-go decisions, and operator/human attention that genuinely needs a shared surface.

Keep Linear thin: title, canonical Git link, short acceptance/decision state. Do not paste plans, specs, research, code-review transcripts, or `NEXT.md` into Linear.

### GitHub

Engineering agents default to GitHub for implementation, bugs, refactors, tests, security remediation, performance, CI/CD, deployment verification, code review, and scanner findings.

If work originated in Linear, link `Linear: SAL-NNN` from the GitHub issue/PR and keep the implementation/evidence in GitHub. If engineering discovers a question requiring human/business/architecture/risk adjudication, promote it to a thin Linear decision object.

This is **promotion, not synchronization**. Do not mirror both boards.

## Important Directories

```
.agent/workflows/     # All workflow commands
docs/solutions/       # Persistent knowledge base
docs/explorations/    # Deep investigations & research
docs/decisions/       # Project-wide ADRs
docs/features/        # Feature documentation
skills/               # Modular capabilities
plans/                # Implementation plans from /plan
todos/                # Work items from /review

docs/specs/           # Multi-session specifications
```

## Agent Behavior

1. **Resume Context** - At the start of EVERY new session, read `skills/session-resume/SKILL.md` and follow the checklist to establish state.
2. **Check active specs** - Before starting significant work, inspect active multi-session initiatives under `docs/specs/`.
3. **Search before solving** - Check `docs/solutions/` and `docs/explorations/` for similar problems.
4. **Deep Explore** - Use `/explore` for complex problems to avoid assumption-based planning.
5. **Document after solving** - Trigger `/compound` on success phrases.
6. **Follow patterns** - Reference `patterns/critical-patterns.md`.
7. **Use workflows** - Prefer `/specs` (large) or `/plan` (small) → `/work` over ad-hoc coding.
8. **Todos for deferred work** - If work is deferred, use the repo's current deferred-work convention; do not create tracker duplicates merely to record the defer.
9. **Housekeeping before push** - Run `/housekeeping` or the pre-push hook will block until cleanup is done.
10. **Weekly health check** - Every Monday, run `./scripts/compound-health.sh` and address warnings.
11. **Record architectural decisions** - When making technology/pattern/schema choices, create ADRs in `docs/decisions/`.
12. **Check health daily** - Run `./scripts/compound-dashboard.sh` at session start.
13. **Instrument Skills** - Every new skill MUST include an `## Instrumentation` section in `SKILL.md` calling `./scripts/log-skill.sh`.
14. **Route trackers correctly** - Before creating a Linear or GitHub work object, use `/tracker-routing` and search for existing coverage.

# Compound Project - Agent Configuration

## Project Overview

This project implements the Compound Learning System for {PROJECT_NAME} - a self-improving knowledge system based on the "Compounding Engineering" philosophy.

## Core Principle

> **Each unit of engineering work should make subsequent units of work easier—not harder.**

## Workflows Available

> **Full index:** See [.agent/workflows/README.md](.agent/workflows/README.md) for all commands and quick start guide.

Use these commands for systematic development:

| Command | When |
|---------|------|
| `/explore` | Deep investigation before planning |
| `/specs` | Before multi-week initiatives |
| `/plan` | Before starting significant work |
| `/work` | Execute plans systematically |
| `/review` | Before merging, self-review |
| `/compound` | After solving problems ("that worked!") |
| `/housekeeping` | Before git push (cleanup & archive) |
| `/tracker-routing` | Before creating or moving work between Linear and GitHub |

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

The compound system is not a second project-management database.

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

If work originated in Linear, link `Linear: SAL-NNN` from the GitHub issue/PR and keep implementation/evidence in GitHub. If engineering discovers a question requiring human/business/architecture/risk adjudication, promote it to a thin Linear decision object.

This is **promotion, not synchronization**. Do not mirror both boards.

## Important Directories

```
.agent/workflows/     # All workflow commands
docs/solutions/       # Persistent knowledge base
docs/explorations/    # Deep investigations & research
docs/decisions/       # Project-wide ADRs
├── patterns/         # Critical patterns (READ FIRST)
├── schema.yaml       # Validation schema
└── {categories}/     # Categorized solutions
docs/features/        # Feature documentation (New features, READMEs)
skills/               # Modular capabilities
├── file-todos/       # Todo management
├── compound-docs/    # Solution documentation
└── session-resume/   # Context resume
plans/                # Implementation plans from /plan
├── archive/          # Completed plans
todos/                # Work items from /review
├── archive/          # Completed todos
docs/specs/           # Multi-session specifications
├── archive/          # Completed specs
```

## Agent Behavior

1. **Resume Context** - At the start of EVERY new session, read `skills/session-resume/SKILL.md` and follow the checklist to establish state.
0. **Check active specs** - Before starting significant work, run `ls docs/specs/*/README.md` to find active multi-session initiatives
1. **Search before solving** - Check `docs/solutions/` and `docs/explorations/` for similar problems (use `skills/compound-docs/SKILL.md`)
2. **Deep Explore** - Use `/explore` for complex problems to avoid assumption-based planning.
3. **Document after solving** - Trigger `/compound` on success phrases
4. **Follow patterns** - Reference `patterns/critical-patterns.md`
5. **Use workflows** - Prefer `/specs` (large) or `/plan` (small) → `/work` over ad-hoc coding (see `skills/` for specific domain help)
6. **Todos for deferred work** - If you close/reject/defer work, create a todo file in `todos/` (use `skills/file-todos/SKILL.md`). Implementation plans document decisions; todos track actionable follow-up.
7. **Housekeeping before push** - Run `/housekeeping` or the pre-push hook will block until cleanup is done.
8. **Weekly health check** - Every Monday, run `./scripts/compound-health.sh` and address any warnings. Target: >50% coverage.
9. **Record architectural decisions** - When making technology/pattern/schema choices, create ADRs in `docs/decisions/`. Check existing ADRs before re-debating.
10. **Check health daily** - Run `./scripts/compound-dashboard.sh` at session start. Target: Grade B or higher.
11. **Instrument Skills** - Every new skill MUST include an `## Instrumentation` section in `SKILL.md` calling `./scripts/log-skill.sh`.
12. **Tracker routing** - Before creating or moving a Linear/GitHub work object, run `/tracker-routing` and search existing coverage first.

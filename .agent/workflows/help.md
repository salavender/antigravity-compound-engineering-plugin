---
description: Unified help and discovery for workflows. Use when unsure which command to use.
triggers: [adr, changelog, compound, compound-health, create-agent-skill, cycle, deploy-docs, doc, explore, generate-command, heal-skill, housekeeping, onboard, plan, plan-review, promote-pattern, release-docs, report-bug, reproduce-bug, resolve-pr, resolve-todo, review, skill-review, specs, triage, triage-sprint, work, xcode-test]
uses: [session-resume]
---

# /help - Workflow Discovery & Help

Quick reference for all available workflows, categorized by their tier and purpose.

## 🔴 Tier 1: Core Loop (Recommended)

Essential workflows for the standard development cycle. Follow this order:

1.  **[/explore](./explore.md)**: Deep investigation before planning.
2.  **[/specs](./specs.md)**: Design multi-phase initiatives.
3.  **[/plan](./plan.md)**: Create implementation plan for a single task/phase.
4.  **[/work](./work.md)**: Execute an approved implementation plan.
5.  **[/review](./review.md)**: Quality gate for implemented changes.
6.  **[/compound](./compound.md)**: Capture reusable knowledge and solutions.
7.  **[/housekeeping](./housekeeping.md)**: Cleanup and archive before pushing.

---

## 🟡 Tier 2: Situational Tools

Workflows for specific tasks or problem types.

### Task & Todo Management
- **[/triage](./triage.md)**: Prioritize pending local todos.
- **[/resolve-todo](./resolve-todo.md)**: Batch-process "ready" todo items.

### Planning & Review
- **[/plan-review](./plan-review.md)**: Quality check on an implementation plan.
- **[/adr](./adr.md)**: Create Architectural Decision Records.

### Bug & Incident Response
- **[/report-bug](./report-bug.md)**: Standardized bug reporting.
- **[/reproduce-bug](./reproduce-bug.md)**: Reproduce and analyze reported bugs.

### Special Operations
- **[/onboard](./onboard.md)**: Context restoration for new sessions.
- **[/heal-skill](./heal-skill.md)**: Diagnose and fix broken modular skills.
- **[/cycle](./cycle.md)**: Accelerated plan-work-review cycle for small tasks.

---

## ⚪️ Tier 3: Advanced & Maintenance

Specialized tools for system maintenance and metadata.

- **[/compound-health](./compound-health.md)**: Monitor the health of the knowledge base.
- **[/generate-command](./generate-command.md)**: Create new workflow commands.
- **[/create-agent-skill](./create-agent-skill.md)**: Add new modular capabilities.
- **[/promote-pattern](./promote-pattern.md)**: Turn recurring solutions into patterns.
- **[/skill-review](./skill-review.md)**: Review potential new skills from usage.

---

## 💡 Pro-Tips

- **New Session?** Always run `/onboard` (or follow `skills/session-resume/SKILL.md`).
- **Done with work?** Don't forget `/housekeeping` to keep the repo clean.
- **Confused?** Check the [Workflows README](./README.md) for full details on all 28+ workflows.

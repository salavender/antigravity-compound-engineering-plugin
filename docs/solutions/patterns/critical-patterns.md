---
tags: [patterns, compound-learning, workflows, architecture]
last_referenced: "2025-12-27"
pattern_health:
  review_cadence: quarterly
  next_review: "2026-03-27"
  pattern_status: core_standard
  times_violated: 0
  effectiveness_notes: "Patterns split into modular files for better maintainability and discovery."
---

# Antigravity Critical Patterns

> **Required Reading for All Agents**
> 
> This document contains critical patterns learned from repeated mistakes.
> Every agent MUST consult this before generating code.

---

## How Patterns Are Added

A pattern is promoted to this document when:
1. The same mistake has occurred **3+ times**
2. The solution is **non-obvious** but must be followed every time
3. It represents a **foundational requirement**

---

## Patterns Index

| # | Pattern Name | Summary |
|---|--------------|---------|
| 1 | [Single Source of Truth (Business Logic)](./individual/pattern-01-single-source-of-truth-for-business-logic.md) | autoritative system of record for critical state |
| 2 | [Single Source of Truth (UI Components)](./individual/pattern-02-single-source-of-truth-for-ui-components.md) | use canonical components to prevent UI drift |
| 3 | [Actionable Items → Todo Files](./individual/pattern-03-actionable-items--todo-files.md) | persist future work to todos/ directory |
| 4 | [Housekeeping Before Push](./individual/pattern-04-housekeeping-before-push.md) | archive completed items to maintain repo hygiene |
| 5 | [Structure > Documentation](./individual/pattern-05-structure--documentation.md) | embed triggers in workflows rather than manuals |
| 6 | [Persistence Over Conversation](./individual/pattern-06-persistence-over-conversation.md) | work must survive session boundaries in files |
| 7 | [Extract, Don't Just Link](./individual/pattern-07-extract-dont-just-link.md) | artifacts must be self-contained |
| 8 | [Explicit Workflow Skill Integration](./individual/pattern-08-explicit-workflow-skill-integration.md) | mandatory Step 0 for skill usage |
| 9 | [Rigorous Planning (Multi-Order Thinking)](./individual/pattern-09-rigorous-planning-multi-order-thinking.md) | 1st-4th order effect analysis |
| 10 | [Atomic State Transitions](./individual/pattern-10-atomic-state-transitions.md) | single operation for state changes |
| 11 | [Explore Before Plan](./individual/pattern-11-explore-before-plan.md) | research before committing to an approach |
| 12 | [Single Source of Truth (Project State)](./individual/pattern-12-single-source-of-truth-for-project-state.md) | track project status in one place |
| 13 | [Observability by Default](./individual/pattern-13-observability-by-default.md) | scripts must self-report usage |
| 14 | [Implicit Workflow Triggers](./individual/pattern-14-implicit-workflow-triggers.md) | phrases that trigger formal protocols |
| 15 | [Task Completion Visibility](./individual/pattern-15-task-completion-visibility.md) | terminal state for task boundaries |
| 16 | [Centralized Fallbacks](./individual/pattern-16-centralized-fallbacks-over-magic-numbers.md) | avoid hardcoded defaults in components |
| 17 | [Sibling Parity](./individual/pattern-17-sibling-parity-system-extension.md) | update all sibling references when adding components |
| 18 | [Mobile Table Responsiveness](./individual/pattern-18-mobile-table-responsiveness.md) | transform tables for small screens |
| 19 | [Active Documentation](./individual/pattern-19-active-documentation-validation-scripts.md) | automated validation of doc accuracy |
| 20 | [Visual Redirect Cues](./individual/pattern-20-visual-redirect-cues.md) | provide context before redirecting users |
| 21 | [Strict Lifecycle Enums](./individual/pattern-21-strict-lifecycle-enums.md) | machine-readable status values |
| 22 | [Human Gate for State Creation](./individual/pattern-22-human-gate-for-state-creation.md) | suggest often, create only on approval |
| 23 | [Mandatory Instrumentation](./individual/pattern-23-mandatory-instrumentation.md) | three-layer reporting requirement |
| 24 | [Batch Resource Operations](./individual/pattern-24-batch-resource-operations.md) | avoid N+1 and non-atomic DB calls |
| 25 | [React State Initialization Guard](./individual/pattern-25-react-state-initialization-guard.md) | prevent double-execution in Strict Mode |
| 26 | [CSP Inline Strategy](./individual/pattern-26-csp-inline-strategy.md) | balance styles and script security |
| 27 | [Tiered Component Documentation](./individual/pattern-27-tiered-component-documentation.md) | classification for documentation depth |
| 28 | [Continuous Documentation Enforcement](./individual/pattern-28-continuous-documentation-enforcement.md) | gate workflows with doc validation |
| 29 | [Explicit Error Handling](./individual/pattern-29-explicit-error-handling-no-silent-swallowing.md) | no bare excepts or silent failures |
| 30 | [Avoid N+1 Queries](./individual/pattern-30-avoid-n1-queries.md) | fetch once, filter in memory |
| 31 | [Centralized Configuration](./individual/pattern-31-centralized-configuration-single-source-of-truth.md) | single source for system-wide constants |
| 32 | [Reusable Auth Guards](./individual/pattern-32-reusable-auth-guards.md) | prevent hook violations in auth logic |

---

*Last updated: 2025-12-27*

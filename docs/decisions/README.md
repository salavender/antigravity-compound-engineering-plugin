# Architecture Decision Records (ADRs)

This directory contains project-wide architectural decisions that persist beyond individual implementation plans.

## When to Write an ADR

Create an ADR when you make a significant technical decision that:
1.  **Has long-term impact** (difficult to reverse)
2.  **Affects multiple components** or the entire system
3.  **Establish a pattern** that others should follow
4.  **Involves a trade-off** between competing quality attributes (e.g., speed vs. maintainability)

Examples:
- "We are switching from REST to GraphQL for the External API"
- "We will use the 'Service Object' pattern for all complex business logic"
- "We are adopting a strict 'No Native HTML Tables' policy in favor of reusable DataGrid components"

## When NOT to Write an ADR

- **Bug fixes** (use `docs/solutions/` instead)
- **Implementation details** (document in code comments or PRs)
- **Routine choices** (e.g., "Using `map` instead of `forEach`")
- **Spec-specific decisions** (use `docs/specs/{name}/04-decisions.md` if the decision only applies to that spec)

## Workflow

1.  **Identify the need** during `/plan`, `/specs`, or implementation.
2.  **Check existing ADRs** to avoid re-litigating settled decisions.
3.  **Create a new ADR** using the workflow:
    ```bash
    /adr
    ```
    Or manually:
    ```bash
    cp docs/decisions/adr-template.md docs/decisions/NNN-decision-slug.md
    ```
4.  **Get review** from the team (or User).
5.  **Merge** and follow the decision.

## Lifecycle Status

- **Proposed:** Under discussion, not yet agreed upon.
- **Accepted:** Agreed and currently in force.
- **Deprecated:** Guidance to stop using, but legacy instances may exist.
- **Superseded:** No longer in force; replaced by a newer ADR (link to it).

## Tags

Use tags in the YAML frontmatter to categorize (flat structure):
- `database`, `api`, `frontend`, `infrastructure`, `security`
- `patterns`, `dependencies`, `testing`, `workflow`

## Naming Convention

`NNN-description-of-decision.md`
- `NNN`: Monotonically increasing integer (001, 002, ...)
- `description`: Short, kebab-case summary

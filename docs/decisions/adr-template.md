---
id: "ADR-{NNN}"
title: "{Decision Title}"
date: "YYYY-MM-DD"
status: "proposed | accepted | deprecated | superseded"
deprecated_date: "" # If status is deprecated, YYYY-MM-DD
superseded_by: ""  # If status is superseded, e.g., "ADR-005"
tags: []
last_referenced: "YYYY-MM-DD"
---

# ADR-{NNN}: {Decision Title}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-XXX}

## Context

{What is the issue, conflict, or opportunity that motivates this decision? What constraints are we working under?}

## Decision

{What is the change that we're proposing and/or doing? Be specific and authoritative.}

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| {Option 1} | {+} | {-} | {Reason} |
| {Option 2} | {+} | {-} | {Reason} |

## Consequences

**Positive:**
- {Benefit 1}
- {Benefit 2}

**Negative:**
- {Trade-off 1}
- {Trade-off 2}

## Related

- Spec: `docs/specs/{name}/` (if originated from spec)
- Plan: `plans/{name}.md` (if originated from plan)
- Supersedes: ADR-{NNN} (if replacing previous decision)
- Superseded By: ADR-{NNN} (if this decision is obsolete)

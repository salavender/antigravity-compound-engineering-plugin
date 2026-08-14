# Tracker Routing: Linear vs GitHub

## Purpose

Route work to the surface that owns its semantic state. Do not create a second project-management layer.

### Canonical boundaries

```text
Git docs/specs/ADRs  = durable truth
GitHub Issues/PRs    = engineering execution + evidence
Linear               = temporary attention, brainstorming, decisions, gates
```

## Before creating work

Ask:

1. Is this durable knowledge? Write it in the repository.
2. Is this executable engineering work? Use GitHub Issues/PRs.
3. Is this collaborative reasoning, a business/architecture decision, risk acceptance, or a human gate? Use Linear.
4. Does an existing object already cover it?
5. Will the object still have value after the canonical Git record exists?

Do not create a Linear issue for every backlog row, probe, log, CI result, or engineering subtask.
Do not create a GitHub issue for pure brainstorming.

## Linear

Use Linear for:

- product/strategy questions
- architecture alternatives
- hypothesis comparison
- business/risk decisions
- go/no-go gates
- operator attention that requires human action
- temporary multi-agent reasoning

Keep the issue thin. Link to Git documents. Never paste the plan/spec/research body.

When the decision is made:

1. write the durable conclusion to Git (`docs/decisions`, `docs/specs`, or the relevant canonical doc);
2. link any resulting GitHub execution work;
3. archive the Linear object when it is no longer an active decision/attention surface.

### Auto-synced GitHub projections

If Linear's GitHub **Issues Sync** creates a GitHub issue for a Linear decision, that GitHub issue is a **read-only projection**, not engineering work.

- Do not implement it.
- Do not assign engineering agents to it.
- Do not create a branch/PR from it.
- Do not close it independently of the Linear decision while Issues Sync is enabled.
- Prefer disabling GitHub Issues Sync for this repository; keep PR/commit linking enabled.

## GitHub

Engineering agents default to GitHub for:

- implementation
- bugs and refactors
- tests
- security remediation
- performance work
- CI/CD
- deployment verification
- code review
- scanner findings

Keep implementation details, PR discussion, review verdicts, and CI evidence in GitHub.

If work originated from Linear, put `Linear: SAL-NNN` in the GitHub issue/PR and link the canonical spec/ADR. Do not copy the Linear discussion.

## Escalation

GitHub → Linear only when engineering discovers a question requiring human/business/architecture/risk adjudication.

Linear → GitHub only when a decision creates executable engineering work.

This is promotion, not synchronization.

## Completion

```text
canonical Git truth updated
→ GitHub execution merged/verified
→ Linear gate updated if needed
→ Linear archived when no longer active
```

## Capacity

Linear Free has a 250-unarchived-issue ceiling. Protect capacity by keeping the Linear working set small. Archive completed decision/attention objects promptly; do not delete valuable history merely to make the counter smaller.

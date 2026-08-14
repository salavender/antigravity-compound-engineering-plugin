# /tracker-routing

## Purpose

Choose the correct system before creating or moving a work object.

## Decision tree

```text
Is this durable knowledge?
  └─ yes → repository docs/specs/ADRs

Is this executable engineering?
  └─ yes → GitHub Issue/PR

Is this collaborative reasoning, a decision, risk acceptance, or human gate?
  └─ yes → Linear
```

If the answer is unclear, do not create another ticket. Search the repository, existing GitHub work, and existing Linear objects first.

## Linear → GitHub

Use this when a Linear decision creates implementation work.

- Canonical decision goes into Git.
- Create/link a GitHub issue or PR for implementation.
- Add `Linear: SAL-NNN` to the GitHub object.
- Keep code, review, CI, and evidence in GitHub.
- Update Linear only with the resulting decision/evidence state.
- Archive Linear when it no longer requires attention.

## GitHub → Linear

Use this only when an engineering finding requires:

- product/business adjudication;
- architecture selection;
- risk acceptance;
- go/no-go decision;
- cross-agent/human reasoning outside the codebase.

Create a thin Linear decision object that links back to the GitHub evidence. Do not duplicate the GitHub issue/PR discussion.

## Anti-patterns

- Linear copy of `NEXT.md`.
- Linear child issue for every GitHub subtask.
- GitHub mirror of every Linear brainstorm.
- Long-form research in Linear.
- PR transcript pasted into Linear.
- Using Linear Projects/Cycles to reproduce the repository backlog.

## Session close

Always leave the canonical Git record correct. Close GitHub execution when shipped. Update and archive Linear only when its attention/decision state is complete.

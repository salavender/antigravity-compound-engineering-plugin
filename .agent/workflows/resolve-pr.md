---
description: Handle PR comments and review feedback efficiently. Use when addressing reviewer feedback.
---

# /resolve-pr - Address PR Feedback

Work through PR comments and review feedback systematically.

## When To Use

- When a PR has review comments
- After receiving change requests
- To batch-process reviewer feedback

---

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/resolve-pr" "$$"
./scripts/compound-search.sh "pull request review"
```

### Step 1: Fetch PR Comments

```bash
# Get PR details
gh pr view {PR_NUMBER} --json comments,reviews

# List requested changes
gh pr view {PR_NUMBER} --json reviewRequests
```

### Step 2: Categorize Feedback

Group comments by type:

| Type | Action |
|------|--------|
| **Must fix** | Required for approval |
| **Suggestion** | Consider implementing |
| **Question** | Respond with clarification |
| **Praise** | Acknowledge, no action needed |

### Step 3: Address Each Comment

For each must-fix comment:

1. **Understand:** Read the feedback carefully
2. **Fix:** Make the requested change
3. **Test:** Verify the change works
4. **Respond:** Reply to the comment

```bash
# After fixing
git add -A
git commit -m "fix: address review feedback - {description}"
git push
```

### Step 4: Reply to Comments

For each comment addressed:
```bash
gh pr comment {PR_NUMBER} --body "Fixed in {commit_sha}"
```

For questions:
```bash
gh pr comment {PR_NUMBER} --body "Good question - {explanation}"
```

### Step 5: Request Re-review

```bash
gh pr ready {PR_NUMBER}
gh pr review {PR_NUMBER} --request
```

### Step 6: Summary

```markdown
## PR Feedback Addressed

**Comments processed:** {X}
**Changes made:** {Y}
**Responses added:** {Z}

### Changes Made:
- Fixed: {description}
- Updated: {description}

### Awaiting Response:
- Question about {topic}

### Next Steps:
1. Push changes: `git push`
2. Request re-review
3. Monitor for additional feedback
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Resolve PR",
  TaskStatus: "PR feedback addressed. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Addressed {count} comments on PR #{number}. Fixes verified and pushed."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ PR feedback resolved

Next steps:
1. /housekeeping - Cleanup branches
2. /triage - Process any remaining feedback
```

---

## References

- Review PRs: `/review`
- Work on changes: `/work`

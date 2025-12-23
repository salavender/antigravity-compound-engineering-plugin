---
description: Create a new Architecture Decision Record. Use when making significant technical choices.
---

# /adr - Record Architectural Decision

Capture long-term architectural choices that should persist beyond individual plans or specs.

> **Why ADRs?** Implementation plans are transient. Decisions that shape the project should be permanent, searchable, and prevent re-litigation.

## When To Use

**Triggers:**
- Choosing between competing technologies/libraries
- Defining new patterns or conventions
- Making breaking changes with long-term impact
- Decisions that future developers need to understand "why"

**Examples:**
- "We will use GraphQL instead of REST for the External API"
- "We adopt the Tailwind framework as our single source of UI primitives"
- "All backend dates will be stored in UTC"

**Skip ADRs for:**
- Routine implementation choices
- Bug fixes
- Decisions scoped to a single spec (use `04-decisions.md` instead)

---

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/adr" "$$"
./scripts/compound-search.sh "architectural decision"
```

### Step 1: Check Existing ADRs (MANDATORY)

> [!CAUTION]
> **BLOCKING STEP.** Check if this decision has already been made.

```bash
// turbo
./scripts/compound-search.sh "{decision keywords}"
```

If an existing ADR covers this decision → Reference it; don't create a duplicate.

---

### Step 1: Get Next ID
```bash
// turbo
next_id=$(printf "%03d" $(( $(ls -1 docs/decisions/*.md 2>/dev/null | xargs -n1 basename | grep -E '^[0-9]{3}-' | wc -l) + 1 )))
echo "Next ADR ID: $next_id"
```

### Step 2: Create From Template
```bash
cp docs/decisions/adr-template.md docs/decisions/${next_id}-{decision-slug}.md
```

Use a descriptive slug, e.g., `002-adopt-graphql-for-external-api.md`

### Step 3: Fill Core Sections

Open the new file and complete:

| Section | Content |
|---------|---------|
| **Context** | What problem or situation led to this decision? What constraints exist? |
| **Decision** | The specific choice made (be authoritative). |
| **Alternatives** | What else was considered? Why rejected? |
| **Consequences** | Trade-offs: positive AND negative. |

### Step 4: Link to Source

Update the `## Related` section:
- Link to originating `/plan` or `/spec` if applicable
- Note if this supersedes a previous ADR

### Step 5: Update Frontmatter

Ensure YAML is valid:
```yaml
---
id: "ADR-{NNN}"
title: "{Decision Title}"
date: "YYYY-MM-DD"
status: "accepted"  # or proposed, deprecated, superseded
tags: [database, api, frontend, infrastructure, patterns, dependencies]
last_referenced: "YYYY-MM-DD"
---
```

### Step 6: Offer Next Steps

```
✓ ADR created: docs/decisions/{next_id}-{slug}.md

What's next?
1. Get review - Share with team for feedback
2. Link in plan - Reference ADR in your implementation plan
3. Continue working - Decision is now recorded
```

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Create ADR",
  TaskStatus: "ADR created and filed. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Created ADR-{NNN}: {Title}. Documented decision context and consequences."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ ADR created

Next steps:
1. /plan - Create implementation plan for this decision
2. /work - Start implementing
```

---

## Lifecycle Management

| Status | Meaning |
|--------|---------|
| `proposed` | Under discussion, not yet agreed |
| `accepted` | Agreed and currently in force |
| `deprecated` | Guidance to stop using; legacy may exist |
| `superseded` | Replaced by a newer ADR (link to it) |

**To supersede an ADR:**
1. Create new ADR with updated decision
2. Add `superseded_by: "ADR-{NNN}"` to old ADR's frontmatter
3. Change old ADR status to `superseded`

---

## Quality Guidelines

**Good ADRs have:**
- ✅ Clear context (the "why")
- ✅ Explicit decision statement
- ✅ Alternatives with rejection reasons
- ✅ Honest consequences (including negatives)

**Avoid:**
- ❌ Vague rationale ("seemed better")
- ❌ Missing alternatives
- ❌ Only positive consequences listed
- ❌ Implementation details (that's for plans)

---

## References

- Directory: `docs/decisions/`
- Template: `docs/decisions/adr-template.md`
- Search decisions: `./scripts/compound-search.sh`
- Integration: `/plan` Step 5.5 and `/specs` Step 4
- Standard: [Michael Nygard's ADR format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

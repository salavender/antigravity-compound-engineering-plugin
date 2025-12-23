---
description: Document reusable knowledge (solutions, features, decisions) to compound project capability.
---

# /compound - Compound Your Knowledge

Capture reusable knowledge while context is fresh—solutions to problems, feature implementations, architectural decisions—creating structured documentation for searchability and future reference.

> **Why "compound"?** Each documented piece of knowledge compounds your capability. The first time you solve a problem OR build a feature takes research. Document it, and the next occurrence takes minutes.

## When To Use

**Auto-trigger on phrases:**
- "that worked"
- "it's fixed"
- "working now"
- "problem solved"

**Also trigger when completing features:**
- "Feature complete"
- "Shipped the {feature}"
- "Implementation done"

**Manual invocation:**
- `/compound` after solving a non-trivial problem
- `/compound` after completing a feature

**Skip documentation for:**
- Simple typos
- Obvious syntax errors
- Trivial fixes (<5 minutes to solve)

---

## Workflow

### Step 0: Instrumentation

```bash
./scripts/log-workflow.sh "/compound" "$$"
```

### Step 0.5: Search for Similar Solutions (Recommended)

> [!TIP]
> Check if a similar solution already exists to avoid duplication. Search for keywords related to the problem or feature you are documenting.

```bash
./scripts/compound-search.sh "{primary symptom or feature keywords}"
```
```

### Step 1: Gather Context from Conversation

Extract the following from the current conversation:

**Required:**
- [ ] **Problem/Feature:** What was solved or built?
- [ ] **Details:** Root cause (for problems) or Implementation details (for features)
- [ ] **Solution:** What fixed it? (if problem)

**Optional but valuable:**
- [ ] **Investigation attempts:** What didn't work and why?
- [ ] **Prevention strategies:** How to avoid in future?
- [ ] **Related issues:** Similar problems encountered before?

### Step 2: Determine Documentation Type

| If you are documenting... | Output |
|---------------------------|--------|
| A solved problem | Create in `docs/solutions/{category}/` |
| A new feature | Create in `docs/features/` OR update README |
| An architectural decision | Create in `docs/decisions/` (ADR) |

### Step 3: Determine Details (if Problem)

If documenting a **Solved Problem**, map to one of these categories:

| If the problem involves... | Category |
|---------------------------|----------|
| Slow performance, N+1 queries, memory | `performance-issues` |
| Vulnerabilities, auth, data exposure | `security-issues` |
| Schema, migrations, data integrity | `database-issues` |
| Compilation, bundling, dependencies | `build-errors` |
| Failing tests, flaky tests | `test-failures` |
| Exceptions, crashes, runtime errors | `runtime-errors` |
| Visual glitches, responsive, accessibility | `ui-bugs` |
| API failures, third-party services | `integration-issues` |
| Business logic, calculations | `logic-errors` |

### Step 4: Generate Filename

Format: `{sanitized-symptom}-{YYYYMMDD}.md`

**Sanitization rules:**
- Lowercase
- Replace spaces with hyphens
- Remove special characters except hyphens
- Truncate to <60 characters

**Examples:**
- `n-plus-one-query-user-list-20251219.md`
- `auth-cookie-mismatch-20251219.md`
- `missing-env-variable-supabase-20251219.md`

### Step 5: Create Solution Document (if Problem)

Load the template from `docs/solutions/templates/solution-template.md` and fill in:

**YAML Frontmatter:**
```yaml
---
date: "{TODAY'S DATE: YYYY-MM-DD}"
problem_type: "{FROM SCHEMA: performance_issue, security_issue, etc.}"
component: "{FROM SCHEMA: api_endpoint, database_model, etc.}"
severity: "{critical | high | medium | low}"
symptoms:
  - "{EXACT ERROR MESSAGE OR BEHAVIOR}"
root_cause: "{FROM SCHEMA: missing_include, null_check_missing, etc.}"
tags:
  - "{relevant-tag-1}"
  - "{relevant-tag-2}"
related_issues: []
---
```

**Document Sections:**
1. Problem Statement with impact
2. Symptoms observed
3. Investigation steps with results table
4. Root cause analysis
5. Working solution with code examples
6. Prevention strategies
7. Cross-references

**For Feature Documentation:**
- Use `docs/features/templates/feature-template.md`
- Create in `docs/features/{feature-name}.md`

### Step 6: Validate YAML

Before creating the file, validate:

- [ ] `problem_type` is a valid enum from schema.yaml
- [ ] `severity` is one of: critical, high, medium, low
- [ ] `component` is a valid enum from schema.yaml
- [ ] `root_cause` is a valid enum from schema.yaml
- [ ] `symptoms` is a non-empty array
- [ ] `tags` is a non-empty array

If validation fails, fix the values before proceeding.

### Step 7: Write Solution File

Create the file at: `docs/solutions/{category}/{filename}.md`

### Step 8: Check for Pattern Promotion

After creating the solution, **dynamically count** similar solutions:

```bash
# Count similar solutions
grep -l "{key symptom terms}" docs/solutions/**/*.md | wc -l
```

**If count ≥ 3:**
1. Create a pattern promotion todo with a **DRAFT**:

```bash
# Create todo for pattern promotion
./scripts/create-todo.sh "p2" "Promote Pattern: {Pattern Name}" \
  "Pattern identified during solution documentation: {Pattern Name}.\n\nContext:\n(Description of the pattern and why it matters)" \
  "Draft the pattern in docs/solutions/patterns/critical-patterns.md" \
  "Add 'WRONG' vs 'CORRECT' examples" \
  "Link to original solution: ${filename}"
```

2. The todo should include:
   - Pattern name
   - List of 3+ related solutions
   - Proposed ❌ WRONG vs ✅ CORRECT format
   - Source cross-references

### Step 9: Capture Follow-up Opportunities (Conditional)

> [!TIP]
> **Safety Net.** If you already ran `/review` and captured deferred work there, **SKIP THIS STEP.**

**If running standalone (no prior review), check:**
- [ ] Did the solution defer any enhancements for later?
- [ ] Are there related optimizations not yet implemented?
- [ ] Did we close/reject alternatives that have value to port later?

**Also check for NEW opportunities (discovered during documentation):**
- [ ] Did writing this solution reveal a gap in another area?

**If YES, create todo files:**

```bash
# Get next ID
next_id=$(./scripts/next-todo-id.sh)

# Create todo from template
cp todos/todo-template.md todos/${next_id}-pending-p2-{description}.md
# Edit the file with specific details of deferred tasks
```

> [!TIP]
> Use the standardized naming convention: `{id}-{status}-{priority}-{description}.md`.
> See [todos/README.md](../../todos/README.md) for details.
```

### Step 10: Mandatory Validation

> [!CAUTION]
> **Do not skip.** Auto-validation protects the knowledge base.

Before closing the `/compound` workflow, run:

```bash
./scripts/validate-compound.sh
```

- [ ] Script passed?
- [ ] Pattern promotion todo created (if count ≥ 3)?
- [ ] Deferred work converted to todos?

**If any failure, FIX IT before closing.**

---

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

> [!IMPORTANT]
> **Visual Completion Signal**
> Call `task_boundary` one last time to signal completion in the user's UI. This prevents the "task" from appearing active after you've finished.

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Compound Knowledge: {filename}",
  TaskStatus: "Solution documented and validated. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Documented {type} at docs/solutions/{category}/{filename}.md. Validated YAML and pattern promotion."
});
```

#### Step 2: Mandatory Handoff

> [!IMPORTANT]
> **Exit Transition**
> Do not stop here. Offer the user clear paths to the next logical workflow.

```bash
✓ Solution documented

File created:
- docs/solutions/{category}/{filename}.md

Next steps:
1. /housekeeping - Archive and cleanup before push (Recommended)
2. /review - Get feedback on documentation or associated changes
3. /work - Return to previous task or start new implementation
4. Continue working - Perform manual follow-ups
```

---

## Quality Guidelines

**Good documentation has:**
- ✅ Exact error messages (copy-paste from output)
- ✅ Specific file:line references
- ✅ Observable symptoms (what you saw, not interpretations)
- ✅ Failed attempts documented (helps avoid wrong paths)
- ✅ Technical explanation (not just "what" but "why")
- ✅ Code examples (before/after if applicable)
- ✅ Prevention guidance (how to catch early)

**Avoid:**
- ❌ Vague descriptions ("something was wrong")
- ❌ Missing technical details ("fixed the code")
- ❌ No context (which file? which version?)
- ❌ Just code dumps (explain why it works)

---

## Example

**User:** "That worked! The N+1 query is fixed."

**Agent creates:**

```
docs/solutions/performance-issues/n-plus-one-user-list-20251219.md
```

With frontmatter:
```yaml
---
date: "2025-12-19"
problem_type: "performance_issue"
component: "database_model"
severity: "high"
symptoms:
  - "User list API taking >5 seconds"
  - "N+1 query detected in logs"
root_cause: "missing_include"
tags:
  - n-plus-one
  - eager-loading
  - performance
---
```

---

## References

- Schema: `docs/solutions/schema.yaml`
- Template: `docs/solutions/templates/solution-template.md`
- Patterns: `docs/solutions/patterns/critical-patterns.md`

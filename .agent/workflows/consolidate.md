---
description: Knowledge curation and deduplication. Merge redundant solutions into authoritative references.
triggers: [compound, explore, housekeeping, specs]
uses: []
---

# /consolidate - Knowledge Curation and Deduplication

Identify redundant, overlapping, or stale knowledge in the documentation system and consolidate it into authoritative references. This prevents knowledge rot and maintains a high-signal knowledge base.

> **Why consolidate?** Every duplicate solution wastes future developers' time. A curated knowledge base compounds into decision velocity and pattern consistency.

## When To Use

- Monthly or quarterly knowledge base maintenance
- When you notice multiple similar solutions
- After a large exploration or discovery phase
- When merging related patterns
- When deprecating old approaches

---

## Workflow

### Step 1: Identify Redundancy

Find related or overlapping solutions:

```bash
./scripts/compound-search.sh "{keyword}"
ls -lt docs/solutions/{category}/*.md | head -20
```

### Step 2: Analyze Coverage

For each cluster of related solutions:

```markdown
## Knowledge Audit: [Topic]

**Related Documents:**
1. {solution-a}
2. {solution-b}

**Plan:**
- Merge: [Which to combine]
- Deprecate: [Which to archive]
```

### Step 3: Consolidate into Master Reference

Create or update a master document that:
- Lists all approaches
- Recommends current best practice
- Links to implementations in codebase

### Step 4: Archive Superseded Documents

Move old documents to `docs/solutions/archive/` and update them with a redirection note.

---

## Knowledge Consolidation Checklist

- [ ] Identify related documents
- [ ] Analyze coverage and gaps
- [ ] Create/update master reference
- [ ] Archive superseded documents
- [ ] Update all internal references

---

## Related Workflows

- **Before consolidating:** Use `/explore` if unsure about merits
- **After consolidating:** Document new patterns in `/compound`
- **Maintenance:** Run quarterly as part of `/housekeeping`

---

## Instrumentation

```bash
./scripts/log-skill.sh "consolidate" "workflow" "$$"
```

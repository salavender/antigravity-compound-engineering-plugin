---
description: Update folder-level documentation and component changelogs. Use after modifying components or adding new ones.
---

# /doc - Update Folder Documentation

Maintain living, component-level documentation in folder README files.

> **Why /doc?** Component-level context evaporates quickly. Documenting the "why" and "when" of changes ensures the codebase remains understandable as it grows.

## When To Use

- After modifying a component's core logic
- When adding a new file to a directory
- As a handoff step in the `/review` workflow
- When referencing a new ADR in a component

---

## Workflow

### Step 1: Identify Target Folder

Identify which folder's `README.md` needs updating.

```bash
# If not provided, list modified folders
git diff main --name-only | xargs -n1 dirname | sort -u
```

### Step 2: Read Existing README

Check if a `README.md` exists. If not, bootstrap it using the template.

```bash
# Check for README
ls {folder_path}/README.md

# If missing, use bootstrap script
./scripts/bootstrap-folder-docs.sh {folder_path}
```

### Step 3: Update Components Table

If a new component was added, ensure it's in the table.

| Component | Purpose | Status |
|-----------|---------|--------|
| `NewComponent.tsx` | {Purpose} | `🏗️ Building` |

### Step 4: Add Tiered Component Details

Update the `## Component Details` section with depth based on the component's [Tier](../../docs/templates/component-tier-guide.md).

- **🔴 Critical**: Full detail (Purpose, Functionality, Tech, Error Handling, Usage).
- **🟡 Supporting**: Brief purpose and key exports.
- **🟢 Generated**: One-line description.

### Step 5: Add Changelog Entry

Document the change, including the "why" and relevant references.

```markdown
### {YYYY-MM-DD}
- {Change description} (Response to: {Link to TODO/Spec/ADR})
```

### Step 6: Verify Links

Ensure any newly added links to ADRs or other documentation are valid.

### Step 7: Integration Audit (Sibling Parity)

If you created a NEW folder, ensure it is covered by the validation system:
1. Run `./scripts/discover-undocumented-folders.sh` to verify discovery.
2. Run `./scripts/validate-folder-docs.sh` to verify structure.
3. If new patterns were established, update `docs/solutions/patterns/critical-patterns.md`.

---

## Quality Guidelines

- ✅ Focus on the **Why**, not just the **What**.
- ✅ Keep the components table updated and sorted.
- ✅ Link to relevant ADRs for architectural decisions.
- ✅ Ensure changelog entries are dated and specific.

---

## References

- Template: `docs/templates/folder-readme-template.md`
- Tier Guide: `docs/templates/component-tier-guide.md`
- Documentation Map: `docs/architecture/codebase-map.md`
- ADRs: `docs/decisions/`

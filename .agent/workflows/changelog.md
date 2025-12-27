---
description: Generate changelog entries from commits. Use before releases.
---

# /changelog - Generate Changelog

Create changelog entries from git history automatically using conventional commits and the project's internal generation tools.

## Workflow

### Step 1: Run Generation Script

```bash
npm run changelog:gen
```

This script will:
1. Find the latest git tag.
2. Parse all commits since that tag.
3. Group them by type (feat, fix, docs, etc.).
4. Prepend a new entry to `CHANGELOG.md`.

### Step 2: Review and Edit

Open `CHANGELOG.md` and review the generated entry:
- Check for accuracy and grouping.
- Improve descriptions where needed.
- Ensure breaking changes are clearly highlighted.

### Step 3: Commit Changes

```bash
git add CHANGELOG.md
git commit -m "docs: update changelog"
```

---

## References

- Implementation: `scripts/generate-changelog.js`
- Full Release Workflow: `/release`

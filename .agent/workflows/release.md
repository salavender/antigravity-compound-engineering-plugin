---
description: Unified release pipeline. Orchestrates changelog generation, versioning, documentation preparation, and deployment.
triggers: [compound, housekeeping]
uses: []
---

# /release - Unified Release Pipeline

Manage the end-to-end release process, from changelog generation to documentation deployment.

## When To Use

- Before publishing a new version of the software.
- When significant changes require documentation updates.
- To ensure a consistent release sequence.

---

## Workflow

### Step 1: Generate Changelog

Create changelog entries from git history using conventional commits.

```bash
npm run changelog:gen
```

### Step 2: Update Versioning

Update version numbers in `package.json` or equivalent files and badges in `README.md`.

### Step 3: Build & Preview

Verify documentation integrity before deployment.

```bash
npm run docs:build
npm run docs:serve
```

### Step 4: Tag & Deploy

Create a release tag and publish verified documentation.

```bash
git tag -a v{X.Y.Z} -m "Release {X.Y.Z}"
git push origin v{X.Y.Z}
```

---

## Related Workflows

- **Cleanup:** Run `/housekeeping` after release
- **Learning:** Use `/compound` to document reusable knowledge from the release cycle
- **Specific:** Use `/changelog` for standalone changelog updates

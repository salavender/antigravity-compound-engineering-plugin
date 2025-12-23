---
description: Prepare release documentation. Use before publishing new versions.
---

# /release-docs - Release Documentation

Prepare documentation for a new release.

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/release-docs" "$$"
./scripts/compound-search.sh "release notes"
```

### Step 1: Update Version

Update version numbers in:
- [ ] package.json / pyproject.toml
- [ ] README.md badges
- [ ] Documentation config

### Step 2: Generate Changelog

Run `npm run changelog:gen` to generate release notes.

### Step 3: Update Documentation

- [ ] Update getting started guide if APIs changed
- [ ] Add migration guide for breaking changes
- [ ] Update API reference
- [ ] Add examples for new features

### Step 4: Review Documentation

```bash
# Build and preview
npm run docs:build
npm run docs:serve
```

Check:
- [ ] All code examples work
- [ ] Links not broken
- [ ] Screenshots current

### Step 5: Tag Release

```bash
git tag -a v{X.Y.Z} -m "Release {X.Y.Z}"
git push origin v{X.Y.Z}
```

### Step 6: Deploy Docs

Run `/deploy-docs` to publish.

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Release Docs",
  TaskStatus: "Docs released and deployed. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Released documentation for v{X.Y.Z}. Generated changelog, updated versions, deployment triggered."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Docs released

Next steps:
1. /housekeeping - Cleanup artifacts
2. Notify Team - Announce the release
```

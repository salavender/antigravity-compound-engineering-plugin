---
description: Deploy documentation updates. Use when publishing docs changes.
---

# /deploy-docs - Documentation Deployment

Deploy documentation to hosting platform.

## Workflow

### Step 0: Search & Log

```bash
// turbo
./scripts/log-workflow.sh "/deploy-docs" "$$"
./scripts/compound-search.sh "deployment"
```

### Step 1: Build Documentation

```bash
# For most doc systems
npm run docs:build
# or
mkdocs build
# or
mdbook build
```

### Step 2: Preview Locally

```bash
npm run docs:serve
# or
mkdocs serve
# or
python -m http.server 8000 -d dist/
```

### Step 3: Deploy

```bash
# GitHub Pages
npm run docs:deploy

# Vercel
vercel --prod

# Netlify
netlify deploy --prod

# Manual
rsync -avz dist/ user@server:/var/www/docs/
```

### Step 4: Verify

- [ ] Docs accessible at URL
- [ ] All pages load
- [ ] Search works
- [ ] Links not broken

### Phase 5: Completion & Handoff

#### Step 1: Establish Terminal UI State

```javascript
await task_boundary({
  TaskName: "[COMPLETED] Deploy Documentation",
  TaskStatus: "Docs deployed and verified. Offering next steps.",
  Mode: "VERIFICATION",
  TaskSummary: "Deployed docs to {target}. Verified accessibility and links."
});
```

#### Step 2: Mandatory Handoff

```bash
✓ Docs deployed

Next steps:
1. /housekeeping - Cleanup artifacts
2. /work - Resume development
```

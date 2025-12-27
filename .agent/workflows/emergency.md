---
description: High-velocity hotfix path for critical issues. Bypass standard friction while maintaining post-mortem documentation.
triggers: [audit-security, compound, plan, work]
uses: []
---

# /emergency - Critical Incident Response

Rapidly respond to critical production issues with a streamlined hotfix workflow. This path reduces friction while maintaining accountability through mandatory post-mortems.

> **Why have an emergency workflow?** Critical issues demand speed. A dedicated fast-track prevents "just ship it" decisions while ensuring incidents get proper post-mortem analysis.

## When To Use

- Production outages (any service down)
- Security breaches or exploitation detected
- Data loss or corruption detected
- Critical functionality broken for all/majority of users
- Revenue-impacting issues
- Regulatory/compliance violations

---

## Emergency Response Hierarchy

| Level | Criteria | Response Time | Workflow |
|-------|----------|----------------|----------|
| **Critical** | All users affected, revenue loss | <30 min | This workflow |
| **High** | Majority of users affected | <2 hours | Use `/work` with priority |
| **Medium** | Some users affected | <1 day | Regular `/plan`/`/work` |
| **Low** | Minor impact | <1 week | Standard workflows |

---

## Workflow

### Phase 1: Incident Assessment (2-5 min)

#### Step 1: Declare Emergency Status

```bash
echo "CRITICAL INCIDENT: {issue-title}" | tee incident-{timestamp}.log
```

**Criteria for emergency status:**
- ✓ Production service down or severely degraded
- ✓ Security vulnerability actively exploited
- ✓ Data loss detected
- ✓ Majority of users affected
- ✗ Single user complaint
- ✗ Feature request or enhancement

#### Step 2: Assess Impact

Quickly determine scope:

```markdown
## Incident Declaration

**Issue:** [What's broken]
**Severity:** [P0 / P1]
**Affected Users:** [All / Majority / Specific subset]
**Data Impact:** [None / At-risk / Confirmed loss]

**Timeline:**
- Detected: [When discovered]
- Started: [When problem began]
- Duration: [How long affected]
```

#### Step 3: Establish Incident Channel

Create a shared space for quick coordination:

```bash
# Create incident file for tracking
cat > incidents/incident-{timestamp}-{title}.md << 'EOF'
# Incident: [Title]

**Status:** ONGOING
**Start Time:** [timestamp]
**Incident Commander:** [Your name]

## Timeline
- HH:MM - Incident detected
- HH:MM - Root cause identified
- HH:MM - Hotfix deployed

## Communications
- [Project Channel / Notification System]

## Mitigation Steps Taken
1. [Action taken]
2. [Action taken]
EOF
```

---

### Phase 2: Rapid Diagnosis (5-15 min)

#### Step 4: Identify Root Cause (Fast)

Do NOT spend >15 minutes diagnosing. Use existing knowledge:

```bash
# Check logs
tail -100 logs/production.log | grep -i "error\|exception"

# Check recent changes
git log --oneline -10

# Quick system checks
curl https://api.yourproject.com/health
```

**If unclear after 15 minutes:** Apply temporary mitigation (step 5) while continuing diagnosis.

#### Step 5: Apply Temporary Mitigation (If Needed)

Quick temporary fixes to restore service:

```bash
# Examples (adjust per incident):

# Scale up service
# Scale up command...

# Enable read-only mode
READONLY_MODE=true npm run start

# Switch to backup resource
BACKUP_MODE=true npm run start

# Disable problematic feature
FEATURE_X_ENABLED=false npm run start

# Roll back recent deployment
git revert {commit-hash}
# Trigger deploy...
```

---

### Phase 3: Hotfix Development (15-45 min)

#### Step 6: Implement Hotfix

Once root cause is identified, fix it:

```bash
# Create hotfix branch
git checkout -b hotfix/{issue-key}

# Make minimal changes
# [Fix only the bug, no refactoring, no features]

# Test locally
# run tests...

# Commit
git commit -m "hotfix: {issue-key} - {description}

Critical incident: {description of impact}

Mitigation: {what was done temporarily}
Root cause: {brief explanation}
Fix: {what this change does}

Incident: incidents/incident-{timestamp}-{title}.md"
```

#### Step 7: Deploy Hotfix

```bash
# Build
# run build...

# Deploy to production
git push origin hotfix/{issue-key}
# [Follow normal deployment process, but expedited]

# Verify fix
curl https://api.yourproject.com/health
# [Manual testing of affected area]
```

---

### Phase 4: Incident Closure & Post-Mortem

#### Step 8: Confirm Resolution

```bash
# Verify service is healthy
for i in {1..10}; do
  curl https://api.yourproject.com/health | jq .status
done
```

#### Step 9: Conduct Post-Mortem (Within 24 hours)

Create a formal post-mortem document:

```bash
touch docs/explorations/postmortem-incident-{timestamp}-{title}.md
```

**Post-mortem structure:**

```markdown
# Post-Mortem: [Incident Title]

**Date:** YYYY-MM-DD
**Duration:** [Start time] to [End time] (X minutes)
**Severity:** [Critical / High]
**Incident ID:** incidents/incident-{timestamp}-{title}.md

## Executive Summary
[1-2 sentence summary of what happened]

## Timeline

| Time | Event |
|------|-------|
| HH:MM | Incident detection |
| HH:MM | Root cause identified |
| HH:MM | Hotfix deployed |
| HH:MM | Service restored |

## Root Cause
[Detailed explanation of why this happened]

## Impact
- **Users Affected:** [Number / Percentage]
- **Data Loss:** [Yes (describe) / No]
- **Other Systems:** [Cascading failures if any]

## Resolution
### Immediate Hotfix
- Commit: [hash]
- What: [Brief description]

## Prevention
### Preventive Measures (What we'll do to prevent recurrence)
1. [Measure 1]
   - Todo: [Reference to prevention todo]
2. [Measure 2]
   - Todo: [Reference to prevention todo]

## Lessons Learned
- [Lesson 1]
- [Lesson 2]
```

#### Step 10: Create Prevention Todos

For each preventive measure, create a todo matching the project's todo patterns.

---

## Related Workflows

- **Before incident:** Use `/audit-security` to catch issues proactively
- **During incident:** This workflow (you are here)
- **Prevention:** `/plan` and `/work` to implement measures
- **Learning:** `/compound` to document incident patterns and prevention strategies

---

## Instrumentation

```bash
./scripts/log-skill.sh "emergency" "workflow" "$$"
```

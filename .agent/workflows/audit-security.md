---
description: Proactive security and threat modeling audit. Dedicated workflow for security-focused reviews.
triggers: [compound, review, work]
uses: [standard-security-auth]
---

# /audit-security - Proactive Security Assessment

Execute a dedicated security and threat modeling audit to identify vulnerabilities, validate defense mechanisms, and ensure secure-by-design principles are followed.

> **Why audit security systematically?** Security debt compounds invisibly until it becomes a critical breach. Proactive, methodical auditing catches issues early when they're cheap to fix.

## When To Use

- Before any production deployment
- When adding new API endpoints or sensitive features
- After major dependency updates
- Quarterly or after security-relevant code changes
- When a security incident or near-miss occurs

---

## Workflow

### Phase 1: Threat Modeling (1-2 hours)

#### Step 1: Define the Security Scope

State what you're auditing:

```markdown
## Security Audit Scope

**Target:** [Component, system, or feature to audit]
**Risk Level:** [Critical / High / Medium / Low]

**Key Assets:**
- [Data at risk]
- [Operations at risk]
```

#### Step 2: Threat Modeling Exercise

Identify attack vectors using (e.g., STRIDE):

- **Spoofing**: Can identity be forged?
- **Tampering**: Can data be modified?
- **Repudiation**: Can actions be denied?
- **Information Disclosure**: Can secrets be leaked?
- **Denial of Service**: Can availability be disrupted?
- **Elevation of Privilege**: Can access be escalated?

#### Step 3: Map to Industry Standards

Check against modern threats (e.g., OWASP Top 10):

```bash
grep -r "security\|auth\|validation" docs/decisions/
```

---

### Phase 2: Code Audit (2-4 hours)

#### Step 4: Review Authentication Flow

For any auth-related code:

```bash
grep -r "auth\|cookie\|token\|session" {target} | head -20
```

**Checklist:**
- [ ] Tokens are securely generated
- [ ] Tokens have appropriate expiration
- [ ] Tokens are validated on every request
- [ ] Session invalidation works correctly
- [ ] CSRF protection present (if applicable)

#### Step 5: Review Input Validation

Check all user inputs:

```bash
grep -r "req.body\|query\|params\|headers" {target}
```

**Checklist:**
- [ ] All inputs validated and sanitized
- [ ] Type checking and length constraints enforced
- [ ] Parameterized queries used for database access
- [ ] XSS prevention (escaping/encoding) active

#### Step 6: Review Data Protection

Check how sensitive data is handled:

```bash
grep -r "password\|secret\|token\|key\|pii" {target}
```

**Checklist:**
- [ ] Sensitive data not logged in plaintext
- [ ] Sensitive data encrypted in transit (HTTPS)
- [ ] No hardcoded secrets
- [ ] Environment variables used for configuration

#### Step 7: Review Access Control

Check authorization logic:

```bash
grep -r "role\|permission\|guard\|authorized" {target}
```

**Checklist:**
- [ ] Role checked before sensitive operations
- [ ] Resource isolation enforced (e.g., owner ID validation)
- [ ] Default-deny approach (whitelist roles)
- [ ] Rate limiting enforced where applicable

#### Step 8: Review Dependencies

Check for known vulnerabilities:

```bash
# npm audit / pip list / etc.
```

---

### Phase 3: Documentation & Remediation

#### Step 9: Create Security Audit Report

```bash
touch docs/explorations/security-audit-{target}-{date}.md
```

#### Step 10: Create Remediation Todos

For each issue found, create a todo matching project patterns.

---

## Security Audit Checklist Summary

| Area | Check | Status |
|------|-------|--------|
| Authentication | Secure token management | ☐ |
| Authorization | Role-based & Resource-level access | ☐ |
| Input Validation | Sanitization & Injection prevention | ☐ |
| Data Protection | Encryption & Secret management | ☐ |
| Logging | Audit trail & No sensitive leaked data | ☐ |

---

## Related Workflows

- **After audit:** Use `/work` to fix issues
- **To document results:** Use `/compound` to add patterns
- **Before production:** Run this as part of `/review`

---

## Instrumentation

```bash
./scripts/log-skill.sh "audit-security" "workflow" "$$"
```

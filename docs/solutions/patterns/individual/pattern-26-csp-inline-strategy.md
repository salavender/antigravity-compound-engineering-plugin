---
pattern_number: 26
title: "CSP Inline Strategy"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #26: CSP Inline Strategy


**Problem:** Modern UI libraries often rely on inline styles for dynamic values (like CSS variables). Blocking `'unsafe-inline'` completely breaks these features, but allowing it globally across all source types destroys security.

**❌ WRONG:**
```typescript
// middleware.ts
const cspHeader = `
  default-src 'self';
  style-src 'self' 'unsafe-inline'; // ⛔ Too permissive if script-src is also loose
  script-src 'self' 'unsafe-inline'; // ⛔ CATSTROPHIC: Allows XSS
`
```

**✅ CORRECT:**
```typescript
// middleware.ts
// Allow inline styles (required for dynamic styles) 
// BUT enforce strict script blocking
const cspHeader = `
  default-src 'self';
  style-src 'self' 'unsafe-inline'; // Accepted trade-off for dynamic styles
  script-src 'self' 'nonce-${nonce}' 'strict-dynamic'; // 🛡️ Offset the risk
`
```

**Rule:** If you must use `style-src 'unsafe-inline'`, you MUST strictly lock down `script-src` (no `'unsafe-inline'`). You cannot have both loose.

**Why:** The risk of `style-src 'unsafe-inline'` is primarily defacement, whereas `script-src 'unsafe-inline'` is RCE/XSS. We accept the lower risk to enable modern UI architecture but compensate with strict script security.

**Source:** Security hardening research for content security policy.

---
pattern_number: 20
title: "Visual Redirect Cues"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #20: Visual Redirect Cues


**Problem:** System-initiated redirects (e.g., automatic logout on session expiry, cross-portal role redirection) that happen without a visual cue disorient the user. The UI "jumps" to a new state without explaining why, leading to a fragmented user experience.

**❌ WRONG:**
```typescript
// Immediate redirect without explanation
if (user.role === 'wrong_portal') {
  router.push('/correct-portal');
}
```

**✅ CORRECT:**
```typescript
// Provide feedback, allow time to read, THEN redirect
if (user.role === 'wrong_portal') {
  toast.info('Account Detected', 'Redirecting to correct portal...');
  setTimeout(() => {
    router.push('/correct-portal');
  }, 1500);
}
```

**Why:** A short delay (1.5s - 2s) combined with a Toast notification provides necessary context for the transition. This respects the user's attention and ensures they understand why their session state changed.

**Source:** UI bug remediation patterns for redirects.

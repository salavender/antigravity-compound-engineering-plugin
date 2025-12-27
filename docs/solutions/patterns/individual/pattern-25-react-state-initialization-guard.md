---
pattern_number: 25
title: "React State Initialization Guard"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #25: React State Initialization Guard


**Problem:** In React Strict Mode (development), effects and component bodies run twice. Side effects placed directly in the body or in unguarded `useEffect` hooks will incur double execution, leading to race conditions, duplicate API calls, and logic errors (like double authentication attempts).

**❌ WRONG:**
```typescript
// Context.tsx
useEffect(() => {
  // ⛔ Runs twice in dev, causing multiple API calls
  initSession(); 
}, []);
```

**✅ CORRECT:**
```typescript
// Context.tsx
const initializing = useRef(false);

useEffect(() => {
  if (initializing.current) return; // 🛡️ Guard against double-invocation
  initializing.current = true;
  
  initSession();
}, []);
```

**Why:** Ensuring single execution is critical for logic that is not idempotent (like initialization or event logging). While Strict Mode helps find bugs, we must explicitly guard against its side effects for initialization logic to keep development logs clean and logic deterministic.

**Source:** Debugging observations on duplicate API calls in React development environments.

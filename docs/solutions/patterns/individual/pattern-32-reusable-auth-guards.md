---
pattern_number: 32
title: "Reusable Auth Guards"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #32: Reusable Auth Guards


**Problem:** Duplicating authentication checks (`if (!user) return null;`) and hook-conditional logic (`enabled: !!user`) in every component leads to `react-hooks/rules-of-hooks` violations (guard clauses before hooks) and inconsistent UI behavior.

**❌ WRONG:**
```tsx
export function MyComponent() {
    const { user } = useAuth();
    
    // ⛔ Violation: Hook called conditionally or after guard
    useKeyboardShortcut({ enabled: !!user });
    
    // ⛔ Manual guard duplicated everywhere
    if (!user) return null;
    
    return <div>Protected Content</div>;
}
```

**✅ CORRECT:**
```tsx
// 1. Use the HOC for structural guarding
export const MyComponent = withAuthGuard(MyComponentInternal);

// 2. Use the hook for clean auth state access
function MyComponentInternal() {
    const { isAuthenticated } = useAuthGuard();
    
    useKeyboardShortcut({ enabled: isAuthenticated });
    
    return <div>Protected Content</div>;
}
```

**Why:** Higher-Order Components (`withAuthGuard`) handle the structural decision at the top level, avoiding Rules of Hooks violations. Small, specialized hooks (`useAuthGuard`) provide a stable API for component-level logic without re-implementing checks everywhere.

**Source:** Logic error remediation for React hooks and authentication state.

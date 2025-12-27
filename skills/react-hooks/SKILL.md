---
name: react-hooks
description: Resolves React hook violations (rules of hooks, useEffect dependencies, hook ordering).
---

# React Hooks Skill

Handles common React hook patterns and violations across the codebase.

## Capabilities

- **Rules of Hooks violations**: Early returns before hook calls, conditional hooks
- **useEffect dependency issues**: Missing/stale dependencies, infinite loops
- **Hook ordering problems**: Hooks called in conditional order, inconsistent hook sequence
- **Context hook patterns**: Proper use of useContext, avoiding unnecessary context re-renders
- **Custom hook extraction**: Safe creation of custom hooks for reusable logic

## Key Patterns

### Pattern 1: Early Returns Before Hooks (⚠️ FATAL)
```typescript
// WRONG - return before hooks
if (!isAuthenticated) {
  return <Login />;  // ❌ Hook call below is unreachable sometimes
}
const user = useUser();  // VIOLATION

// RIGHT - hooks always execute
const user = useUser();
if (!isAuthenticated) {
  return <Login />;
}
```

### Pattern 2: useEffect Dependency Problems
```typescript
// WRONG - missing dependency
const context = useContext(MyContext);
useEffect(() => {
  doSomething(context);
}, []);  // ❌ Missing `context`

// RIGHT - include all dependencies
useEffect(() => {
  doSomething(context);
}, [context]);
```

### Pattern 3: Infinite Loop from Context Object
```typescript
// WRONG - context object changes on every render
const Provider = ({ children }) => {
  const value = { user: currentUser };  // New object every render
  return (
    <MyContext.Provider value={value}>  // ❌ Causes infinite loop
      {children}
    </MyContext.Provider>
  );
};

// RIGHT - memoize context value
const Provider = ({ children }) => {
  const value = useMemo(() => ({ user: currentUser }), [currentUser]);
  return (
    <MyContext.Provider value={value}>
      {children}
    </MyContext.Provider>
  );
};
```

---

## Debugging Workflow

1. **Identify the error**: Check browser console for hook violations.
2. **Find the violation**: search for early returns or dependency issues.
3. **Locate the component**: Grep for hook name or variable.
4. **Apply fix**: Use the patterns above as templates.
5. **Test**: Re-render and check console.

## Instrumentation

```bash
./scripts/log-skill.sh react-hooks
```

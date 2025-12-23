# Performance Review Pass

## Checklist

### 1. Rendering Performance
- [ ] **Unnecessary re-renders**: Are components memoized where needed (`React.memo`, `useMemo`, `useCallback`)?
- [ ] **Large lists**: Is virtualization used for lists >100 items?
- [ ] **Heavy computations**: Are expensive calculations deferred or cached?

### 2. Data Fetching
- [ ] **N+1 Queries**: Are queries batched? No fetching inside loops?
- [ ] **Caching**: Is React Query used with appropriate stale times?
- [ ] **Pagination**: Large datasets paginated?

### 3. Bundle Size
- [ ] **Dynamic imports**: Are heavy modules lazily loaded?
- [ ] **Tree shaking**: Are unused exports avoided?

## Verification Commands

```bash
# Look for async calls in loops
grep -rn "forEach.*await\|map.*await" --include="*.ts" --include="*.tsx" .

# Check bundle size (if build available)
npm run build && ls -la .next/static/chunks/ | head -20
```

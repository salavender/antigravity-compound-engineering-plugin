# Architecture Review Pass

## Checklist

### 1. Component Structure
- [ ] **Single Responsibility**: Does each component do ONE thing?
- [ ] **Prop Drilling**: Is context/global state used for deep props?
- [ ] **Component Size**: Are components <200 lines? Split if larger.

### 2. State Management
- [ ] **Correct Location**: Is state lifted only as high as needed?
- [ ] **Server vs Client State**: Is React Query used for server state?
- [ ] **Form State**: Are forms using controlled components correctly?

### 3. Dependencies
- [ ] **Circular Imports**: No circular dependencies between modules?
- [ ] **Layering**: Does data flow UI → Hooks → API → Database?
- [ ] **External Deps**: Are new packages justified and vetted?

### 4. Patterns
- [ ] **Project Conventions**: Following existing patterns?
- [ ] **Canonical Components**: Using project's standard UI components?

## References

- [Critical Patterns](../../../docs/solutions/patterns/critical-patterns.md)

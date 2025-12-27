---
pattern_number: 2
title: "Single Source of Truth for UI Components"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #2: Single Source of Truth for UI Components


**Problem:** When multiple implementations of the same UI primitive exist (e.g., 3 different Button components), developers waste time choosing, code diverges, and maintenance burden grows. Dead code accumulates.

**❌ WRONG:**
```typescript
// Creating a new button component
// app/components/ui/button.tsx
export const Button = ({ children }) => <button>{children}</button>;

// Meanwhile, a StandardButton already exists with full features
```

**✅ CORRECT:**
```typescript
// Always use the project's canonical component
import { StandardButton } from '@/app/components/ui/core';

<StandardButton isLoading={loading} variant="primary">Submit</StandardButton>
```

**Canonical Components (Example):**
| Primitive | Canonical Component | Location |
|-----------|---------------------|----------|
| Button | `StandardButton` | `ui/core/StandardButton.tsx` |
| Input | `StandardInput` | `ui/core/StandardInput.tsx` |
| Card | `StandardCard` | `ui/core/StandardCard.tsx` |
| Table | `StandardTable` | `ui/core/StandardTable.tsx` |
| Spinner | `Loader2` | `lucide-react` |

**Why:** A single, well-maintained component is always better than multiple half-implemented alternatives. This reduces cognitive load, ensures consistency, and prevents dead code accumulation.

**Source:** UI component consolidation best practices.

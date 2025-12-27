---
pattern_number: 16
title: "Centralized Fallbacks over Magic Numbers"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #16: Centralized Fallbacks over Magic Numbers


**Problem:** When default/fallback values are hardcoded directly in components (magic numbers), they inevitably drift as different developers use different defaults for the same concept. This creates inconsistent UI behavior and makes system-wide changes require hunting through dozens of files.

**❌ WRONG:**
```typescript
// DetailModal.tsx
const score = data.metrics?.active_score || 12.5;

// ItemBrowser.tsx  
const score = metrics?.active_score || 0;

// AdminView.tsx
const score = item.performance?.active_score || 10;
```
*Three different components, three different magic number defaults.*

**✅ CORRECT:**
```typescript
// lib/constants/defaults.ts
export const FALLBACK_SCORE = 0;

// All components
import { FALLBACK_SCORE } from '@/lib/constants/defaults';
const score = data?.active_score || FALLBACK_SCORE;
```
*Single source of truth. One change updates everywhere.*

**Rule:** Before implementing a fallback with a literal value (`|| 0`, `|| ""`, `|| 12.5`), check if a centralized constant exists in `lib/constants/defaults.ts`. If not, create one there instead of using a magic number.

**Why:** Centralizing fallback values ensures consistency, simplifies maintenance, and improves discoverability of existing defaults.

**Source:** Derived from logic error remediation patterns.

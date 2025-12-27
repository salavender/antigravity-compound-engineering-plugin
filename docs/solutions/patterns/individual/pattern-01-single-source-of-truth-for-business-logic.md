---
pattern_number: 1
title: "Single Source of Truth for Business Logic"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
pattern_health:
  review_cadence: semi-annual
  next_review: "2026-06-27"
  pattern_status: core_standard
  times_violated: 0
  effectiveness_notes: "Core principle preventing frontend/backend logic drift. Critical for multi-platform consistency."
---

### Pattern #1: Single Source of Truth for Business Logic


**Problem:** When business logic (e.g., "Is this item active?", "Can this user perform action X?") is duplicated in frontend components, it inevitably drifts from the backend definition, causing UI bugs and data integrity confusion.

**❌ WRONG:**
```typescript
// Frontend Component
const isActive = lastUpdateDate && diffDays(now, lastUpdateDate) < 5;
```

**✅ CORRECT:**
```typescript
// Frontend Component
const isActive = resource.status === 'active';
```

**Why:** The Backend (Database/Service) is the authoritative system of record. The Frontend should be a "dumb" view layer that displays decisions made by the backend, rather than re-calculating them. This ensures consistency across Web, Mobile, API, and Email.

**Source:** Based on industry best practices for distributed systems.

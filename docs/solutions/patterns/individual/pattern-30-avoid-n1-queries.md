---
pattern_number: 30
title: "Avoid N+1 Queries"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #30: Avoid N+1 Queries


**Problem:** Executing a database query inside a loop (e.g., fetching comments for each post) causes performance to degrade linearly with dataset size. A dashboard with 50 items triggers 51 network requests, causing massive latency.

**❌ WRONG:**
```python
items = fetch_items()
for item in items:
    # ❌ NETWORK CALL INSIDE LOOP
    details = fetch_details_for_item(item.id)
    process(item, details)
```

**✅ CORRECT:**
```python
items = fetch_items()
# ✅ FETCH ALL ONCE
all_details = fetch_all_details_for_batch(item_ids)

for item in items:
    # ✅ FILTER IN MEMORY
    relevant_details = [d for d in all_details if d.item_id == item.id]
    process(item, relevant_details)
```

**Rule:** NEVER execute a database query (or API call) inside a `for` loop over entities. Fetch all data upfront in 1-2 queries, then join/filter in memory.

**Why:** Network latency is orders of magnitude slower than in-memory processing. Batching requests reduces load on the database and drastically improves response times.

**Source:** Performance optimization patterns for large datasets.

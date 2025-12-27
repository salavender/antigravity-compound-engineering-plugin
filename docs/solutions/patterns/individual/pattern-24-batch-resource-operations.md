---
pattern_number: 24
title: "Batch Resource Operations"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #24: Batch Resource Operations


**Problem:** Iterative database calls (N+1) within resource processing loops cause significant performance degradation as the system scales. Operations spanning multiple tables lack atomicity when performed as separate client-side calls.

**❌ WRONG:**
```python
# Looping through resources and making individual DB calls
for item in items:
    # 1st order: N SELECTs
    data = db.table("metadata").select("*").eq("id", item.id).execute()
    # 2nd order: N UPDATEs
    db.table("items").update({"data": data}).eq("id", item.id).execute()

# Non-atomic persistence
db.table("history").insert(log_data).execute()
# If this fails, the sync audit is never created
db.table("sync_audit").insert(audit_data).execute()
```

**✅ CORRECT:**
```python
# 1. Batch Fetching
item_ids = [i.id for i in items]
metadata = db.table("metadata").select("*").in_("id", item_ids).execute()
meta_map = {m['id']: m for m in metadata.data}

# 2. Process in Memory
updates = []
for item in items:
    current_meta = meta_map.get(item.id)
    updates.append({"id": item.id, "data": current_meta})

# 3. Atomic Commit (e.g., via RPC or Transaction)
db.rpc("commit_resource_sync", {"p_updates": updates, "p_audit": audit_data}).execute()
```

**Why:** Batching converts $O(N)$ database roundtrips into $O(1)$, which is critical for system responsiveness. Using atomic transactions or database functions ensures integrity across multiple tables, preventing orphaned records during partial failures.

**Source:** Performance optimization patterns for scaled resources.

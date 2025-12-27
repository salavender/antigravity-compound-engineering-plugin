---
pattern_number: 29
title: "Explicit Error Handling (No Silent Swallowing)"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #29: Explicit Error Handling (No Silent Swallowing)


**Problem:** Broad exception catching (`except Exception` or bare `except:`) followed by `pass` or generic logging without a stack trace swallows the root cause of failures. This makes debugging nearly impossible, hides data corruption, and prevents reliable incident response.

**❌ WRONG:**
```python
try:
    process_transaction()
except: # ⛔ Bare except
    pass # ⛔ Silent swallowing

try:
    calculate_totals()
except Exception as e:
    logger.error(f"Error: {e}") # ⛔ Loses stack trace
```

**✅ CORRECT:**
```python
try:
    process_transaction()
except TransactionError as e:
    logger.error(f"Transaction failed: {e}")
    raise # 🛡️ Re-raise or handle specifically

try:
    calculate_totals()
except Exception:
    logger.exception("Unexpected calculation failure") # 🛡️ Captured stack trace
    raise # 🛡️ Allow failure to be visible
```

**Why:** Being "crash-proof" by hiding errors is a false security that actually increases system fragility. Explicit error handling ensures that failures are visible, traceable, and actionable. Using `logger.exception()` automatically captures the full stack trace.

**Source:** Logic error remediation research for silent error swallowing.

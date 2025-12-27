---
pattern_number: 31
title: "Centralized Configuration (Single Source of Truth)"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #31: Centralized Configuration (Single Source of Truth)


**Problem:** Defining configuration values (e.g., API URLs, trusted origins, feature toggles) in multiple files or hardcoding them locally leads to "configuration drift." Changes in one place fail to propagate elsewhere, causing bugs and security vulnerabilities.

**❌ WRONG:**
```python
# File: middleware_security.py
TRUSTED_ORIGINS = ["https://app.com", "http://localhost:3000"] # ❌ LOCALLY DEFINED

# File: main.py
origins = ["https://app.com"] # ❌ DUPLICATED AND INCONSISTENT
```

**✅ CORRECT:**
```python
# File: config.py
import os
TRUSTED_ORIGINS = os.getenv("TRUSTED_ORIGINS", "https://app.com,http://localhost:3000").split(",")

# File: middleware_security.py
from config import TRUSTED_ORIGINS # ✅ IMPORT FROM SSOT
```

**Rule:** Never re-define a configuration constant or hardcode an environment-dependent value (like a domain) locally. Always define it in a central config file and import it.

**Why:** Centralization ensures consistency across the entire system. It simplifies updates and allows for easier environment-specific overrides via environment variables.

**Source:** Security hardening analysis for CSRF and configuration drift.

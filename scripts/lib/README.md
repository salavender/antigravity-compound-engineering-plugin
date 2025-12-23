---
description: Shared utility libraries and helper functions for build and maintenance scripts
---

# scripts/lib

## Overview

Shared bash utility libraries used across the build, maintenance, and validation scripts. These modules provide common functionality for error handling, integration wiring, and prerequisite validation.

> [!TIP]
> This folder contains reusable bash functions that reduce duplication across the script ecosystem. Check here before writing new utility functions.

## Key Components

| Component | Description | Responsibility |
|-----------|-------------|--------------------|
| `error_handling.sh` | Error reporting and graceful failure handling | Exit code management, user messaging |
| `integration_wiring.sh` | Script initialization and environment setup | Loading utilities, config, logging |
| `prerequisite_validation.sh` | Pre-flight checks for script dependencies | Validating tools, permissions, paths |

## Architecture

**Inbound**: All scripts in `./scripts/` that need shared utilities
**Outbound**: None (purely internal library)

## Usage Pattern

```bash
# In any script that needs utilities
source ./scripts/lib/error_handling.sh
source ./scripts/lib/integration_wiring.sh
```

---

## Component Details

### 🔴 error_handling.sh

**Purpose:** Standardized error handling and reporting across all build scripts

**Primary Functionality:**
- Exit with meaningful error messages
- Log error context
- Graceful failure without crashing the shell

**Key Functions:**
- `handle_error()` - Report and exit on failure
- `assert_command()` - Verify command succeeded

---

### 🔴 integration_wiring.sh

**Purpose:** Initialize scripts with required utilities, logging, and configuration

**Primary Functionality:**
- Load environment configuration
- Initialize logging framework
- Wire up dependencies from `scripts/lib/`
- Set up exit handlers

**Usage:**
```bash
source ./scripts/lib/integration_wiring.sh
# Logging and config now available
```

---

### 🔴 prerequisite_validation.sh

**Purpose:** Validate that required tools and permissions exist before script execution

**Primary Functionality:**
- Check for required commands (`node`, `npm`, `python`, etc.)
- Verify file/directory accessibility
- Validate script dependencies

**Key Functions:**
- `require_command()` - Exit if command not available
- `require_file()` - Exit if file doesn't exist

---

## Related

- Pattern #21: Script Architecture
- `./scripts/compound-dashboard.sh` (uses these utilities)
- `./scripts/bootstrap-folder-docs.sh` (uses these utilities)

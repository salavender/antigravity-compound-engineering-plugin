---
description: Validation and health-check scripts for compound learning system compliance
---

# scripts/validators

## Overview

Collection of bash scripts that validate the health and compliance of the codebase against the Compound Learning System standards. These validators ensure documentation quality, todo consistency, spec tracking, and architectural patterns are maintained.

> [!TIP]
> Run individual validators to audit specific areas of codebase health, or use `compound-dashboard.sh` for a comprehensive health check.

## Architecture

**Inbound**: `./scripts/compound-dashboard.sh` (orchestrates validators), manual execution
**Outbound**: None (read-only validation)

## Key Components

| Component | Description | Validates |
|-----------|-------------|--------------------|
| `compound.sh` | Solution documentation compliance | docs/solutions/ structure and YAML |
| `folder-docs.sh` | README documentation for all folders | Tiered documentation standards |
| `freshness.sh` | Documentation freshness and staleness | Last-modified dates, outdated content |
| `patterns.sh` | Critical patterns adherence | Pattern #1-27 compliance |
| `todos.sh` | Todo file consistency and state | Status, priorities, file naming |
| `specs.sh` | Specification tracking | docs/specs/ structure |
| `codebase-map.sh` | Codebase map accuracy | docs/codebase-map.md coverage |
| `undocumented.sh` | Discovers folders without README.md | Folder documentation gaps |
| `changelog.sh` | CHANGELOG.md format validation | Semver, entry structure |

---

## Component Details

### 🔴 folder-docs.sh

**Purpose:** Validate that all folders have README.md files following tiered documentation standards

**Validates:**
- Every folder contains a README.md
- README follows Tier 1/2/3 templates
- YAML frontmatter is valid
- No stale or placeholder content

---

### 🔴 compound.sh

**Purpose:** Validate that solutions are properly documented with correct structure and metadata

**Validates:**
- docs/solutions/ YAML frontmatter
- Categories match schema
- Required fields present
- Markdown formatting

---

### 🔴 todos.sh

**Purpose:** Ensure todo files maintain state consistency and proper naming conventions

**Validates:**
- Status field matches filename (e.g., `pending-*.md` has `status: pending`)
- All required YAML fields
- No orphaned or misnamed files

---

### 🟡 freshness.sh

**Purpose:** Identify stale or outdated documentation

**Detects:**
- Documentation not modified in 60+ days
- Placeholder content
- Outdated references

---

### 🟡 patterns.sh

**Purpose:** Audit codebase against critical patterns (Pattern #1-27)

**Checks:**
- Pattern usage in code
- Architecture compliance
- Style guide adherence

---

### 🟢 specs.sh

**Purpose:** Validate specification tracking in docs/specs/

---

### 🟢 codebase-map.sh

**Purpose:** Verify codebase-map.md covers all major folders

---

### 🟢 undocumented.sh

**Purpose:** Discover folders that lack README.md files

---

### 🟢 changelog.sh

**Purpose:** Validate CHANGELOG.md format and entries

---

## Usage

Run individual validators:

```bash
./scripts/validators/folder-docs.sh     # Check all folder documentation
./scripts/validators/todos.sh            # Check todo file consistency
./scripts/validators/compound.sh         # Check solution documentation
```

Run comprehensive health check:

```bash
./scripts/compound-dashboard.sh
```

## Related

- `./scripts/compound-dashboard.sh` (orchestrator)
- Pattern #27: Tiered Component Documentation
- docs/solutions/patterns/critical-patterns.md

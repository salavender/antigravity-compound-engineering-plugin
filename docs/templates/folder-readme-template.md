---
description: [Brief description of what this folder contains]
---

# [Folder Name]

## Overview
What is this folder responsible for? How does it fit into the broader application?
> [!TIP]
> Use this section to explain the "why" of this folder.

## Architecture
(Optional) Diagram or description of how components in this folder interact with the rest of the system.
- **Inbound**: What uses this?
- **Outbound**: What does this use?

## Key Components
Index of critical files.

| Component | Description | key Responsibility |
|-----------|-------------|--------------------|
| `[File].ts` | ... | ... |

## Dependencies
- Internal: `@/lib/...`
- External: `third-party-lib`

## Decision Records
Links to relevant ADRs or decisions affecting this module.
- [ ] [ADR-000: Example](docs/decisions/000-example.md)

---

## Component Details

Index of all components in this folder with detailed descriptions based on their [Tier](docs/templates/component-tier-guide.md).

### 🔴 {Critical Component Name}

**Purpose:** {Why this component exists and what problem it solves}

**Primary Functionality:**
- {Behavior 1}
- {Behavior 2}

**Technologies:**
- Framework: {Next.js, React, etc.}
- Libraries: {Specific deps used}
- Patterns: {BFF, Repository, etc.}

**Error Handling:**
{How failures are managed}

**Usage:**
```typescript
// Example usage
```

---

### 🟡 {Supporting Component Name}

**Purpose:** {Brief explanation}

**Key Exports:** `{functionA}`, `{functionB}`

---

### 🟢 {Generated Component Name}

{One-line description}

---

## Usage
Examples of how to use components in this folder.

```typescript
import { Something } from './';
```

## Troubleshooting
Common pitfalls or gotchas.

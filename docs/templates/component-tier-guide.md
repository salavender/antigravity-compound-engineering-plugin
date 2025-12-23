# Component Tier Classification Guide

This guide defines the classification criteria for components in the {PROJECT_NAME} codebase. Tiers determine the required depth of documentation in folder-level `README.md` files.

## Summary Table

| Tier | Icon | Criteria | Documentation Depth |
|------|------|----------|---------------------|
| **🔴 Critical** | 🔴 | Core logic, security-sensitive, complex APIs | Implementation details, technologies, error handling |
| **🟡 Supporting** | 🟡 | Utilities, formatters, reusable helpers | Purpose and key exports |
| **🟢 Generated** | 🟢 | Auto-generated code, schemas, static config | One-line description |

---

## 🔴 Critical Components

**Criteria:**
- Implements core business logic (e.g., `UserService`, `CoreEngine`)
- Handles authentication or authorization (e.g., `auth_middleware.ts`, `permissions.py`)
- Acts as a high-complexity API surface (20KB+ or 10+ exports)
- State management or global providers

**Required Content:**
1. **Purpose**: Deep "Why" and architectural role.
2. **Primary Functionality**: Bullet points of key complex behaviors.
3. **Technologies**: Specific libraries, frameworks, and design patterns.
4. **Error Handling**: How the component fails and recovers.
5. **Usage Example**: Non-obvious code snippet.

---

## 🟡 Supporting Components

**Criteria:**
- Domain-specific utilities (e.g., `formatters.ts`, `validators.ts`)
- Stateless helper functions
- Feature flags or simple constants
- Thin wrappers around external libraries

**Required Content:**
1. **Purpose**: Brief summary of responsibility.
2. **Key Exports**: List of main functions/classes (if many, just the primary ones).

---

## 🟢 Generated Components

**Criteria:**
- Code generated from database schemas (e.g., `schema.d.ts`)
- Third-party library types
- Static configuration files (e.g., `.json` configs)

**Required Content:**
1. **Description**: One sentence on what it targets.

---

## Decision Tree

1. **Is it auto-generated?** → 🟢 **Generated**
2. **Does it touch security or money?** → 🔴 **Critical**
3. **Is it >500 lines or highly complex?** → 🔴 **Critical**
4. **Is it a pure utility/helper?** → 🟡 **Supporting**
5. **When in doubt?** → Default to 🟡 **Supporting**

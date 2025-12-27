---
pattern_number: 27
title: "Tiered Component Documentation"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #27: Tiered Component Documentation


**Problem:** "Sparse documentation syndrome" occurs when folder-level READMEs exist but contain only placeholder text or lists of files without context. This forces engineers to read source code to understand a component's purpose, increasing cognitive load and slowing onboarding.

**❌ WRONG:**
```markdown
# App Components
This folder contains UI components.

## Files
- StandardButton.tsx
- StandardInput.tsx
- {Brief 1-sentence description}
```
*Placeholder text and simple lists provide no architectural context or usage guidance.*

**✅ CORRECT:**
```markdown
# App Components

## Component Details

### 🔴 StandardButton.tsx
**Purpose:** Canonical button component with shared styling and states.
**Usage:** Use for all primary and secondary actions. Supports `isLoading`, `variant`, and `size`.

### 🟡 IconWrapper.tsx
**Purpose:** Simple utility to normalize icon sizes and colors.
**Key Exports:** `IconWrapper`
```

**Classification:**
- 🔴 **Critical:** Foundation components requiring deep usage guidance.
- 🟡 **Supporting:** Business-specific components or complex utilities.
- 🟢 **Utility:** Simple wrappers or generated boilerplate.

**Why:** Tiered documentation ensures high-value items are documented deeply while minimizing maintenance for trivial utilities.

**Source:** Documentation hygiene and clarity improvements.

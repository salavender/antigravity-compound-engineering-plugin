---
date: "{DATE}"
problem_type: "{PROBLEM_TYPE}"
component: "{COMPONENT}"
severity: "{SEVERITY}"
symptoms:
  - "{SYMPTOM_1}"
  - "{SYMPTOM_2}"
root_cause: "{ROOT_CAUSE}"
tags:
  - "{TAG_1}"
  - "{TAG_2}"
related_issues: []
related_solutions: []
last_referenced: "2025-12-23"
---

# {TITLE}

## Problem Statement

**What happened:**
{Brief description of the observable problem}

**Impact:**
{Who was affected and how severely}

## Symptoms

The following symptoms were observed:

1. **{Symptom 1}**
   - Exact error message or behavior
   - When it occurred

2. **{Symptom 2}**
   - Additional symptoms if applicable

## Investigation Steps

### What Was Tried

> [!TIP]
> Document ALL significant attempts, not just the successful one. Failed approaches help future readers avoid the same dead ends.

| Attempt | Hypothesis | Result |
|---------|------------|--------|
| 1. {First attempt} | {Why it might work} | ❌ {Why it failed} |
| 2. {Second attempt} | {Why it might work} | ❌ {Why it failed} |
| 3. {Final attempt} | {Why it might work} | ✅ {Why it worked} |

**Include for each failed attempt:**
- What assumption led to this approach?
- Why didn't it work?
- What did you learn from the failure?

### Key Discoveries

- Discovery 1: {Important finding during investigation}
- Discovery 2: {Another important finding}

## Root Cause Analysis

**The actual problem:**
{Technical explanation of what was really wrong}

**Why it happened:**
{Underlying reason - missing knowledge, incorrect assumption, etc.}

## Lessons Learned

> [!IMPORTANT]
> Capture the journey and insights gained. This section helps avoid repeating mistakes.

### Mistakes Made

- **Assumption:** {What we incorrectly assumed}
  - **Why it was wrong:** {Explanation}
  - **Correction:** {What the reality was}

### Key Breakthroughs

- **Insight:** {Critical realization that changed approach}
  - **Impact:** {How this changed the investigation}

### What We'd Do Differently

- {Specific improvement for next time}
- {Another learning/improvement}
- {Process or approach change}

## Working Solution

### The Fix

```{language}
# File: {filepath}
# Lines: {line_numbers}

{CODE_EXAMPLE}
```

### Explanation

{Why this solution works and what it changes}

### Verification

```bash
# How to verify the fix worked
{VERIFICATION_COMMAND}
```

## Prevention Strategies

### Immediate Prevention

- [ ] {Specific check or test to add}
- [ ] {Code pattern to avoid}

### Long-term Prevention

- **Pattern to follow:** {Best practice to adopt}
- **Early detection:** {How to catch this earlier next time}
- **Documentation:** {What to document for team}

## Cross-References

### Related Solutions


### External Resources

- [{Resource name}]({URL})

---

*Documented: {DATE}*
*Time to resolve: {DURATION}*

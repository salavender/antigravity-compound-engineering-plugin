# Session Documentation

> Directory for session retrospectives, work cycle summaries, and agent handoff documentation.

## Purpose

Session summaries provide a historical record of:
- What work was completed in a specific session
- Decisions made and why
- Problems encountered and how they were solved (or deferred)
- Context for the next agent/developer to resume work

## Key Components

| Component | Status | Description |
|-----------|--------|-------------|
| `template/` | 🟢 Active | Contains the standard `session-template.md` |
| `session-*.md` | 🟢 Active | Session summary files (YYYYMMDD-N) |

## Component Details

### `template/`
Contains `session-template.md`, the standardized format for all session summaries. Agents should copy this template at the end of their session.

### `session-*.md`
Individual session records.
- **Naming:** `session-YYYYMMDD-N.md` (e.g., `session-20251226-1.md`)
- **Frontmatter:** Requires `date`, `session_type`, `agent_role`, and `status`.

## Workflow

1. **Start of Session:** Run `/onboard` to establish context.
2. **During Session:** Track work in `todos/`.
3. **End of Session:**
   - Create a session summary using the template.
   - Run `/review` to verify work.
   - Run `/housekeeping` to clean up.

## Changelog

### 2025-12-27
- Created `docs/sessions/` directory in the white-label template.
- Added `template/session-template.md`.
- Integrated directory into the `/onboard` and `/work` cycle.

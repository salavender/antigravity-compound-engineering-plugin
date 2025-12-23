# Agent Skills & Capabilities

## Purpose
The "brain" of the AI Agent. This directory contains the definitions, memories, and tools that enable the Agent to work effectively on the codebase.

## Components

| Component | Description |
|-----------|-------------|
| `compound-docs/` | Templates and logic for the Compounding Knowledge system. |
| `file-todos/` | Logic for the file-based task management system. |
| `session-resume/` | Context restoration protocols for new sessions. |
| `code-review/` | Checklists and workflows for automated code review. |
| `testing/` | Custom testing infrastructure and patterns. |
| `debug/` | Root-cause analysis and debugging protocols. |
| `react-hooks/` | Best practices and patterns for React development. |
| `examples/` | Project-specific or optional skill examples (e.g. Supabase). |

## Component Details

### `compound-docs/`
Contains the `SKILL.md` instruction set and template files used by the `/compound` workflow to generate persistent documentation.

### `file-todos/`
Contains the logic for managing the `todos/` directory, including status transitions and priority handling.

## Changelog

### 2025-12-23
- Initialized README documentation.

# Project Scripts

## Purpose

This directory contains automation scripts that power the agent workflows. They enable self-improvement, validation, and maintenance of the compound engineering system.

## Components


## Workflow Core

- **`log-workflow.sh`**: Logs workflow initiations to simple text logs.
- **`check-docs-freshness.sh`**: ✨ Checks if recent code changes have accompanying documentation updates.
- **`pre-push-housekeeping.sh`**: Master script run before pushes to ensure repo health.

## Knowledge & Compound System

- **`compound-search.sh`**: Context-aware search for existing solutions.
- **`compound-metrics.sh`**: Collects usage metrics for the compound system.
- **`compound-dashboard.sh`**: Displays daily health metrics of the agent system.
- **`validate-compound.sh`**: Validates YAML frontmatter of solution documents.
- **`validate-patterns.sh`**: 🔍 Validates integrity of the critical patterns registry (numerical continuity & links).

## Todo Management

- **`create-todo.sh`**: Standardized creation of todo files.
- **`complete-todo.sh`**: Marks todos as completed and updates archives.
- **`audit-state-drift.sh`**: Syncs file metadata with content state.

## Maintenance

- **`archive-completed.sh`**: Moves finished work to archive directories.
- **`rotate-logs.sh`**: Manages log file sizes.
- **`check-deprecated-adrs.sh`**: Alerts on stale architectural decisions.
- **`push-env.sh`**: Environment deployment utility.

## Metrics & Instrumentation

- **`log-skill.sh`**: Logs skill usage for telemetry.
- **`score-solution.sh`**: Heuristic scoring for solution documents.
- **`score-todo.sh`**: Heuristic scoring for todo verification.
- **`debug-scores.sh`**: Debug utility for scoring logic.
- **`compound-health.sh`**: Weekly deep health validation.
- **`backfill-solution-metrics.sh`**: Historical data processing.
- **`suggest-skills.sh`**: Analyzes usage to suggest new skills.

## Utilities

- **`validate-architecture.sh`**: Enforces architecture documentation integrity.
- **`update-solution-ref.sh`**: Updates solution reference counts.
- **`update-spec-phase.sh`**: Manages specification lifecycles.
- **`next-todo-id.sh`**: Generates unique IDs for todos.

## Usage

Most scripts are designed to be run via the agent workflows (e.g. `/work`, `/housekeeping`), but can be run manually for debugging.

```bash
./scripts/check-docs-freshness.sh
```

## Changelog

- **2025-12-27**: Added git worktree automation scripts.
- **2025-12-23**: Initial transfer from InvestOS compound system.
```

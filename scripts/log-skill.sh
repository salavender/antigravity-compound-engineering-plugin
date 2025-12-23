#!/bin/bash
# Log skill usage
# Usage: ./scripts/log-skill.sh [skill_name] [trigger_type] [context]

set -e

SKILL="${1:-unknown}"
TRIGGER="${2:-manual}"
CONTEXT="${3:-}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p .agent/logs
echo "${TIMESTAMP}|${SKILL}|${TRIGGER}|${CONTEXT}" >> .agent/logs/skill_usage.log

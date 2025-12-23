#!/bin/bash
# Log workflow invocation
# Usage: ./scripts/log-workflow.sh [workflow_name] [session_id]

set -e

WORKFLOW="${1:-unknown}"
SESSION="${2:-$(date +%s)}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p .agent/logs
echo "${TIMESTAMP}|${WORKFLOW}|${SESSION}" >> .agent/logs/workflow_usage.log

#!/bin/bash
# validators/todos.sh - Validate todo filename/status alignment
# Delegates to: scripts/validate-todo-consistency.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
bash "${ROOT_DIR}/scripts/validate-todo-consistency.sh"

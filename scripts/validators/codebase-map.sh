#!/bin/bash
# validators/codebase-map.sh - Verify codebase map reflects structure
# Delegates to: scripts/validate-codebase-map.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
bash "${ROOT_DIR}/scripts/validate-codebase-map.sh"

#!/bin/bash
# validators/patterns.sh - Validate critical patterns numbering
# Delegates to: scripts/validate-patterns.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
bash "${ROOT_DIR}/scripts/validate-patterns.sh"

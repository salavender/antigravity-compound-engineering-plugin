#!/bin/bash
# validators/compound.sh - Validate compound/solution YAML schema
# Delegates to: scripts/validate-compound.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
bash "${ROOT_DIR}/scripts/validate-compound.sh"

#!/bin/bash
# validators/specs.sh - Validate spec consistency
# Delegates to: scripts/validate-spec-consistency.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
bash "${ROOT_DIR}/scripts/validate-spec-consistency.sh"

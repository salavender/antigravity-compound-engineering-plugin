#!/bin/bash
# validators/changelog.sh - Validate CHANGELOG existence
# Delegates to: scripts/validate-changelog.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
bash "${ROOT_DIR}/scripts/validate-changelog.sh"

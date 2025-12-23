#!/bin/bash
#
# scripts/validate-docs.sh
# Unified Documentation Validation Framework
#
# This script consolidates all documentation validation checks into a single,
# testable, maintainable framework with consistent exit codes and clear ownership.
#
# Exit Codes:
#   0 = All validations passed
#   1 = Critical validation failed (blocks push)
#   2 = Non-critical warning (informational, non-blocking)
#  99 = Script error or missing dependency
#
# Usage:
#   ./scripts/validate-docs.sh [MODE] [OPTIONS]
#
# Modes:
#   all                - Run all validators (default)
#   folder-docs        - Check README presence and structure
#   undocumented       - Discover folders with code but no README
#   freshness          - Check documentation staleness
#   compound           - Validate compound/solution YAML schema
#   patterns           - Validate critical patterns numbering
#   specs              - Check spec consistency
#   todos              - Check todo filename/status alignment
#   changelog          - Check CHANGELOG existence
#   codebase-map       - Verify map reflects structure
#
# Options:
#   --help             Show this help message
#   --quiet            Suppress warnings; only show critical failures
#   --json             Output results as JSON (future)
#   --fix              Auto-fix issues where possible (future)
#

set -euo pipefail

# Color output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATORS_DIR="${SCRIPT_DIR}/validators"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
QUIET_MODE=false
JSON_MODE=false
FIX_MODE=false

# Results tracking
declare -a ERRORS=()
declare -a WARNINGS=()
declare -a PASSES=()

# Helper functions
log_pass() {
  PASSES+=("$1")
  echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
  WARNINGS+=("$1")
  [ "$QUIET_MODE" = false ] && echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  ERRORS+=("$1")
  echo -e "${RED}✗${NC} $1"
}

log_info() {
  [ "$QUIET_MODE" = false ] && echo -e "${BLUE}ℹ${NC} $1"
}

show_help() {
  sed -n '2,/^$/p' "$0" | tail -n +2
}

# Validator wrapper: Calls individual validator and aggregates results
run_validator() {
  local validator_name="$1"
  local validator_file="${VALIDATORS_DIR}/${validator_name}.sh"
  
  if [ ! -f "$validator_file" ]; then
    log_error "Validator not found: $validator_name"
    return 99
  fi
  
  log_info "Running: $validator_name"
  
  if bash "$validator_file"; then
    log_pass "$validator_name"
    return 0
  else
    local exit_code=$?
    if [ $exit_code -eq 2 ]; then
      log_warn "$validator_name returned non-critical warning"
      return 2
    else
      log_error "$validator_name failed (exit: $exit_code)"
      return 1
    fi
  fi
}

# Aggregate results and determine final exit code
determine_exit_code() {
  if [ ${#ERRORS[@]} -gt 0 ]; then
    return 1  # Critical failure
  elif [ ${#WARNINGS[@]} -gt 0 ]; then
    return 2  # Non-critical warning
  else
    return 0  # All pass
  fi
}

# Main validation orchestration
main() {
  local mode="${1:-all}"
  
  case "$mode" in
    --help|-h)
      show_help
      exit 0
      ;;
    --quiet)
      QUIET_MODE=true
      mode="${2:-all}"
      ;;
    --json)
      JSON_MODE=true
      mode="${2:-all}"
      ;;
  esac
  
  echo "Documentation Validation Framework ($(date '+%Y-%m-%d %H:%M:%S'))"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  # Run validators based on mode
  case "$mode" in
    all)
      run_validator "folder-docs" || true
      run_validator "undocumented" || true
      run_validator "freshness" || true
      run_validator "compound" || true
      run_validator "patterns" || true
      run_validator "specs" || true
      run_validator "todos" || true
      run_validator "changelog" || true
      run_validator "codebase-map" || true
      ;;
    folder-docs)
      run_validator "folder-docs" || true
      ;;
    undocumented)
      run_validator "undocumented" || true
      ;;
    freshness)
      run_validator "freshness" || true
      ;;
    compound)
      run_validator "compound" || true
      ;;
    patterns)
      run_validator "patterns" || true
      ;;
    specs)
      run_validator "specs" || true
      ;;
    todos)
      run_validator "todos" || true
      ;;
    changelog)
      run_validator "changelog" || true
      ;;
    codebase-map)
      run_validator "codebase-map" || true
      ;;
    *)
      log_error "Unknown mode: $mode"
      show_help
      exit 99
      ;;
  esac
  
  echo ""
  echo "Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "Passed:  ${#PASSES[@]} checks"
  echo -e "Warnings: ${#WARNINGS[@]} non-critical"
  echo -e "Errors:  ${#ERRORS[@]} critical"
  echo ""
  
  # Show errors
  if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "${RED}Critical Issues:${NC}"
    for error in "${ERRORS[@]}"; do
      echo "  - $error"
    done
    echo ""
  fi
  
  # Show warnings
  if [ ${#WARNINGS[@]} -gt 0 ] && [ "$QUIET_MODE" = false ]; then
    echo -e "${YELLOW}Warnings:${NC}"
    for warning in "${WARNINGS[@]}"; do
      echo "  - $warning"
    done
    echo ""
  fi
  
  determine_exit_code
  exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed${NC}"
  elif [ $exit_code -eq 2 ]; then
    echo -e "${YELLOW}⚠ Validation passed with warnings${NC}"
  else
    echo -e "${RED}✗ Validation failed${NC}"
  fi
  
  exit $exit_code
}

# Run main
main "$@"

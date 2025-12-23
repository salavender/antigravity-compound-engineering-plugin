#!/bin/bash
# Pre-push housekeeping checks
# Runs all cleanup checks and blocks push if issues found
#
# Usage: ./scripts/pre-push-housekeeping.sh [--fix]
#
# Exit codes:
#   0 = Clean, can push
#   1 = Cleanup needed, push blocked
#   2 = Script execution errors occurred

# Enhanced error handling - continue on individual check failures
set -uo pipefail

# Configuration
FIX_MODE=false
ISSUES_FOUND=0
FAILED_CHECKS=0
RECOVERY_SUGGESTIONS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix)
      FIX_MODE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--fix]"
      echo "  --fix   Auto-fix issues where possible"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced logging functions
log_check_error() {
    local check_name="$1"
    local error_msg="$2"
    echo -e "   ${RED}✗${NC} Check failed: $error_msg"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    RECOVERY_SUGGESTIONS+=("$check_name: $error_msg")
}

# Wrapper function for individual checks with error recovery
run_check() {
    local check_name="$1"
    local check_command="$2"
    local success_msg="$3"
    local error_context="$4"
    
    if eval "$check_command" 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} $success_msg"
        return 0
    else
        log_check_error "$check_name" "$error_context"
        return 1
    fi
}

# Comprehensive fix mode - runs all available automatic fixes
run_comprehensive_fixes() {
    echo ""
    echo -e "${BOLD}🔧 Comprehensive Fix Mode${NC}"
    echo ""
    
    local fixes_applied=0
    local fixes_failed=0
    
    # Fix 1: State drift
    echo -e "${BLUE}Applying fix 1: State drift correction...${NC}"
    if [[ -x ./scripts/audit-state-drift.sh ]]; then
        if ./scripts/audit-state-drift.sh --fix 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} State drift fix applied"
            fixes_applied=$((fixes_applied + 1))
        else
            echo -e "   ${RED}✗${NC} State drift fix failed"
            fixes_failed=$((fixes_failed + 1))
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} State drift script not available"
    fi
    
    # Fix 2: Archive completed items
    echo -e "${BLUE}Applying fix 2: Archive completed items...${NC}"
    if [[ -x ./scripts/archive-completed.sh ]]; then
        if ./scripts/archive-completed.sh --apply 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} Completed items archived"
            fixes_applied=$((fixes_applied + 1))
        else
            echo -e "   ${RED}✗${NC} Archiving failed"
            fixes_failed=$((fixes_failed + 1))
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} Archive script not available"
    fi
    
    # Fix 3: Enhanced file organization
    echo -e "${BLUE}Applying fix 3: File organization cleanup...${NC}"
    if [[ -x ./scripts/cleanup-redundancy.sh ]]; then
        if ./scripts/cleanup-redundancy.sh --fix 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} File organization fixes applied"
            fixes_applied=$((fixes_applied + 1))
        else
            # Check if it's just issues found (exit code 1) vs actual failure
            cleanup_exit_code=$?
            if [[ $cleanup_exit_code -eq 1 ]]; then
                echo -e "   ${YELLOW}⚠${NC} Some file organization issues couldn't be auto-fixed"
            else
                echo -e "   ${RED}✗${NC} File organization cleanup failed"
                fixes_failed=$((fixes_failed + 1))
            fi
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} Enhanced cleanup script not available"
    fi
    
    # Fix 4: Git hygiene
    echo -e "${BLUE}Applying fix 4: Git hygiene cleanup...${NC}"
    if [[ -x ./scripts/git-hygiene.sh ]]; then
        if ./scripts/git-hygiene.sh --fix 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} Git hygiene fixes applied"
            fixes_applied=$((fixes_applied + 1))
        else
            echo -e "   ${YELLOW}⚠${NC} Git hygiene fixes had issues"
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} Git hygiene script not available"
    fi
    
    # Summary of fixes
    echo ""
    echo -e "${BOLD}Fix Summary:${NC}"
    echo -e "  Fixes applied: ${GREEN}$fixes_applied${NC}"
    echo -e "  Fixes failed: ${RED}$fixes_failed${NC}"
    
    if [[ $fixes_applied -gt 0 ]]; then
        echo -e "  ${GREEN}✓${NC} Automatic fixes have been applied"
    fi
    
    if [[ $fixes_failed -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠${NC} Some fixes failed - manual intervention may be needed"
    fi
}

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  🧹 Pre-Push Housekeeping Check${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 0: Prerequisites Validation (Critical - must pass before other checks)
echo -e "${BLUE}🔧 Check 0: Prerequisites Validation${NC}"
if [[ -x ./scripts/validate-prerequisites.sh ]]; then
  if ./scripts/validate-prerequisites.sh --quick 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} All essential prerequisites met"
  else
    prereq_exit_code=$?
    if [[ $prereq_exit_code -eq 2 ]]; then
      echo -e "   ${RED}✗${NC} Critical prerequisites not met - cannot continue safely"
      echo -e "   ${RED}✗${NC} Run ${BLUE}./scripts/validate-prerequisites.sh${NC} for details"
      echo ""
      echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
      echo -e "${RED}  ✗ Prerequisites validation failed - push blocked${NC}"
      echo ""
      echo -e "  ${BOLD}Required action:${NC}"
      echo -e "    ${BLUE}./scripts/validate-prerequisites.sh${NC}  (detailed validation)"
      echo -e "    Fix the reported issues and try again"
      echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
      echo ""
      exit 2
    else
      echo -e "   ${YELLOW}⚠${NC} Some non-critical prerequisites not met"
      echo -e "      Continuing with limited functionality"
      RECOVERY_SUGGESTIONS+=("Prerequisites: Run ./scripts/validate-prerequisites.sh for details")
    fi
  fi
else
  echo -e "   ${YELLOW}⚠${NC} Prerequisites validation script not found"
  echo -e "      Continuing without prerequisite validation"
  RECOVERY_SUGGESTIONS+=("Prerequisites: Install ./scripts/validate-prerequisites.sh for better validation")
fi

# Run comprehensive fixes first if in fix mode
if [[ "$FIX_MODE" == "true" ]]; then
    run_comprehensive_fixes
fi

# Check 0: Documentation Validation Framework (Unified)
echo -e "${BLUE}📋 Check 0: Documentation Validation${NC}"
if [[ -x ./scripts/validate-docs.sh ]]; then
  if ./scripts/validate-docs.sh all 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} All documentation validations passed"
  else
    validation_exit_code=$?
    if [[ $validation_exit_code -eq 1 ]]; then
      echo -e "   ${RED}✗${NC} Critical documentation validation failed"
      ISSUES_FOUND=$((ISSUES_FOUND + 1))
      FAILED_CHECKS=$((FAILED_CHECKS + 1))
      RECOVERY_SUGGESTIONS+=("Documentation: Run ./scripts/validate-docs.sh --help for details")
    elif [[ $validation_exit_code -eq 2 ]]; then
      echo -e "   ${YELLOW}⚠${NC} Documentation validation warnings found"
      RECOVERY_SUGGESTIONS+=("Documentation: Run ./scripts/validate-docs.sh all to see warnings")
    fi
  fi
else
  echo -e "   ${YELLOW}⚠${NC} Validation framework not found; skipping"
fi
echo ""

# Check 1: State Drift
echo -e "${BLUE}📋 Check 1: State Drift${NC}"
if [[ -x ./scripts/audit-state-drift.sh ]]; then
  if ./scripts/audit-state-drift.sh 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} No state drift detected"
  else
    drift_exit_code=$?
    if [[ $drift_exit_code -eq 1 ]]; then
      echo -e "   ${YELLOW}⚠${NC} State drift found"
      ISSUES_FOUND=$((ISSUES_FOUND + 1))
      
      if [[ "$FIX_MODE" == "true" ]]; then
        echo -e "   ${BLUE}🔧 Auto-fixing: Correcting state drift...${NC}"
        if ./scripts/audit-state-drift.sh --fix 2>/dev/null; then
          echo -e "   ${GREEN}✓${NC} State drift corrected successfully"
          
          # Verify the fix by running the check again
          if ./scripts/audit-state-drift.sh 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} Verification: No state drift remaining"
            ISSUES_FOUND=$((ISSUES_FOUND - 1))  # Remove from issues count since fixed
          else
            echo -e "   ${YELLOW}⚠${NC} Verification: Some state drift may remain"
          fi
        else
          echo -e "   ${RED}✗${NC} Failed to fix state drift automatically"
          RECOVERY_SUGGESTIONS+=("State Drift: Run ./scripts/audit-state-drift.sh --fix manually")
        fi
      fi
    else
      log_check_error "State Drift" "Script execution failed (exit code: $drift_exit_code)"
    fi
  fi
else
  log_check_error "State Drift" "audit-state-drift.sh script not found or not executable"
fi

# Check 2: Completed items not archived
echo ""
echo -e "${BLUE}📦 Check 2: Unarchived Completed Items${NC}"

# Count completed todos not in archive
completed_todos=0
for file in todos/*.md; do
  [[ -f "$file" ]] || continue
  [[ "$(basename "$file")" == "todo-template.md" ]] && continue
  if [[ "$(basename "$file")" =~ -done- ]] || grep -qi "^status:.*done" "$file" 2>/dev/null; then
    completed_todos=$((completed_todos + 1))
  fi
done

# Count completed plans not in archive
completed_plans=0
for file in plans/*.md; do
  [[ -f "$file" ]] || continue
  [[ "$(basename "$file")" == "README.md" ]] && continue
  if grep -qiE "^>?\s*Status:.*Implemented" "$file" 2>/dev/null; then
    completed_plans=$((completed_plans + 1))
  fi
done

# Count completed specs not in archive
completed_specs=0
for spec_dir in docs/specs/*/; do
  [[ -d "$spec_dir" ]] || continue
  spec_name=$(basename "$spec_dir")
  [[ "$spec_name" == "templates" ]] && continue
  [[ "$spec_name" == "archive" ]] && continue
  
  readme="$spec_dir/README.md"
  if [[ -f "$readme" ]] && grep -qE "(100%|████████████████████)" "$readme" 2>/dev/null; then
    # Only count as completed if no parts are "Not Started" or "In Progress" or "0%"
    if ! grep -qE "(0%|50%|Not Started|In Progress)" "$readme" 2>/dev/null; then
      completed_specs=$((completed_specs + 1))
    fi
  fi
done

# Count completed explorations not in archive
completed_explorations=0
if [ -d "docs/explorations" ]; then
  for file in docs/explorations/*.md; do
    [[ -f "$file" ]] || continue
    [[ "$(basename "$file")" == "template.md" ]] && continue
    # This logic should match what's in archive-completed.sh
    if grep -qiE "^status:\s*(complete|done)" "$file" 2>/dev/null; then
      completed_explorations=$((completed_explorations + 1))
    elif grep -qi "^outcome:" "$file" 2>/dev/null && ! grep -qE "^- \[ \]" "$file" 2>/dev/null; then
      completed_explorations=$((completed_explorations + 1))
    fi
  done
fi

total_unarchived=$((completed_todos + completed_plans + completed_specs + completed_explorations))

if [[ $total_unarchived -eq 0 ]]; then
  echo -e "   ${GREEN}✓${NC} All completed items archived"
else
  echo -e "   ${YELLOW}⚠${NC} Found $total_unarchived unarchived completed items:"
  [[ $completed_todos -gt 0 ]] && echo -e "      - $completed_todos todo(s)"
  [[ $completed_plans -gt 0 ]] && echo -e "      - $completed_plans plan(s)"
  [[ $completed_specs -gt 0 ]] && echo -e "      - $completed_specs spec(s)"
  [[ $completed_explorations -gt 0 ]] && echo -e "      - $completed_explorations exploration(s)"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
  
  if [[ "$FIX_MODE" == "true" ]]; then
    echo ""
    echo -e "   ${BLUE}🔧 Auto-fixing: Archiving completed items...${NC}"
    if [[ -x ./scripts/archive-completed.sh ]]; then
      if ./scripts/archive-completed.sh --apply 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} Completed items archived successfully"
        # Recount to verify fix
        total_remaining=0
        for file in todos/*.md; do
          [[ -f "$file" ]] || continue
          [[ "$(basename "$file")" == "todo-template.md" ]] && continue
          if [[ "$(basename "$file")" =~ -done- ]] || grep -qi "^status:.*done" "$file" 2>/dev/null; then
            total_remaining=$((total_remaining + 1))
          fi
        done
        
        if [[ $total_remaining -eq 0 ]]; then
          echo -e "   ${GREEN}✓${NC} Verification: All completed items successfully archived"
          ISSUES_FOUND=$((ISSUES_FOUND - 1))  # Remove from issues count since fixed
        else
          echo -e "   ${YELLOW}⚠${NC} Verification: $total_remaining items still need archiving"
        fi
      else
        echo -e "   ${RED}✗${NC} Failed to archive completed items automatically"
        RECOVERY_SUGGESTIONS+=("Archive Completed Items: Run ./scripts/archive-completed.sh --apply manually")
      fi
    else
      echo -e "   ${RED}✗${NC} Archive script not found or not executable"
      RECOVERY_SUGGESTIONS+=("Archive Completed Items: Install or fix ./scripts/archive-completed.sh")
    fi
  fi
fi

# Check 3: Compound System Health (optional, non-blocking)
echo ""
echo -e "${BLUE}💚 Check 3: Compound System Health${NC}"
if [[ -x ./scripts/compound-health.sh ]]; then
  solution_count=$(find docs/solutions -name "*.md" -type f 2>/dev/null | grep -v template | grep -v schema | wc -l | tr -d ' ')
  exploration_count=$(find docs/explorations -name "*.md" -type f 2>/dev/null | grep -v template | grep -v schema | wc -l | tr -d ' ')
  echo -e "   ${GREEN}✓${NC} Solutions documented: $solution_count"
else
  echo -e "   ${YELLOW}ℹ${NC} Health check not available"
fi

# Check 4: Unchecked deferred work (enforces Pattern #3)
echo ""
echo -e "${BLUE}📝 Check 4: Deferred Work Validation${NC}"
if ./scripts/validate-compound.sh 2>/dev/null; then
  echo -e "   ${GREEN}✓${NC} No unchecked deferred work"
else
  echo -e "   ${YELLOW}⚠${NC} Found unchecked items in plans/"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check 5: Skill Discovery (suggests new skill opportunities)
echo ""
echo -e "${BLUE}🎯 Check 5: Skill Discovery${NC}"
skill_suggestions=$(./scripts/suggest-skills.sh 2>/dev/null | grep -c "💡 Potential Skill" || true)

if [[ "$skill_suggestions" -eq 0 ]]; then
  echo -e "   ${GREEN}✓${NC} No new skill opportunities"
else
  echo -e "   ${YELLOW}ℹ${NC} Found $skill_suggestions potential skill(s) - review with ./scripts/suggest-skills.sh"
fi


# Check 6: Deprecated ADRs (non-blocking, informational)
echo ""
echo -e "${BLUE}📜 Check 6: Deprecated ADRs${NC}"
if [[ -x ./scripts/check-deprecated-adrs.sh ]]; then
  adr_output=$(./scripts/check-deprecated-adrs.sh 2>/dev/null)
  if echo "$adr_output" | grep -q "^⚠"; then
    echo -e "   ${YELLOW}ℹ${NC} $adr_output"
  else
    echo -e "   ${GREEN}✓${NC} No deprecated ADRs need review"
  fi
else
  echo -e "   ${YELLOW}ℹ${NC} ADR check not available"
fi

# Check 7: Log Rotation
echo ""
echo -e "${BLUE}🔄 Check 7: Log Rotation${NC}"
if [[ -x ./scripts/rotate-logs.sh ]]; then
  # Automatically run rotation (it's safe and maintenance-only)
  rotation_output=$(./scripts/rotate-logs.sh 2>/dev/null)
  if [[ -n "$rotation_output" ]]; then
    echo -e "   ${GREEN}✓${NC} Logs rotated"
    echo -e "   ${YELLOW}ℹ${NC} Details: $rotation_output"
  else
    echo -e "   ${GREEN}✓${NC} Logs within retention limits"
  fi
else
  echo -e "   ${YELLOW}ℹ${NC} Log rotation script not found"
fi

# Check 8: Spec Consistency
echo ""
echo -e "${BLUE}📐 Check 8: Spec Consistency${NC}"
if [[ -x ./scripts/validate-spec-consistency.sh ]]; then
  if ./scripts/validate-spec-consistency.sh > /tmp/spec-consistency.out 2>&1; then
    echo -e "   ${GREEN}✓${NC} All completed spec phases have verification files"
  else
    echo -e "   ${YELLOW}⚠${NC} Spec consistency issues found"
    cat /tmp/spec-consistency.out | grep -E "(ERROR|WARNING)" | head -5 | sed 's/^/      /'
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
  fi
  rm -f /tmp/spec-consistency.out
else
  echo -e "   ${YELLOW}ℹ${NC} Spec consistency check not available"
fi

# Check 9: Documentation Freshness
echo ""
echo -e "${BLUE}📚 Check 9: Documentation Freshness${NC}"
if [[ -x ./scripts/validate-folder-docs.sh ]]; then
  if ./scripts/validate-folder-docs.sh 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} Hierarchical documentation is up to date"
  else
    echo -e "   ${YELLOW}⚠${NC} Documentation gaps or errors detected"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
  fi
else
  echo -e "   ${YELLOW}ℹ${NC} Documentation validation script not found"
fi

# Check 10: Codebase Map Integrity
echo ""
echo -e "${BLUE}🗺️  Check 10: Codebase Map Integrity${NC}"
if [[ -x ./scripts/validate-codebase-map.sh ]]; then
  if ./scripts/validate-codebase-map.sh 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} Codebase map is consistent with folder structure"
  else
    echo -e "   ${YELLOW}⚠${NC} Codebase map has broken links or unmapped folders"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
  fi
else
  echo -e "   ${YELLOW}ℹ${NC} Codebase map validation script not found"
fi

# Check 11: Git Hygiene
echo ""
echo -e "${BLUE}🧹 Check 11: Git Hygiene${NC}"
if [[ -x ./scripts/git-hygiene.sh ]]; then
  hyphen_fix_arg=""
  [[ "$FIX_MODE" == "true" ]] && hyphen_fix_arg="--fix"
  
  if ./scripts/git-hygiene.sh $hyphen_fix_arg 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} Git state is clean"
  else
    echo -e "   ${YELLOW}⚠${NC} Stale or merged branches found"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
  fi
else
  echo -e "   ${YELLOW}ℹ${NC} Git hygiene script not found"
fi

# Check 12: Enhanced File Organization (Comprehensive Detection)
echo ""
echo -e "${BLUE}🗂️  Check 12: Enhanced File Organization${NC}"
if [[ -x ./scripts/cleanup-redundancy.sh ]]; then
  # Run enhanced cleanup script with comprehensive detection
  cleanup_args=""
  [[ "$FIX_MODE" == "true" ]] && cleanup_args="--fix"
  
  if ./scripts/cleanup-redundancy.sh $cleanup_args > /tmp/cleanup-output.log 2>&1; then
    echo -e "   ${GREEN}✓${NC} All file organization checks passed"
  else
    cleanup_exit_code=$?
    echo -e "   ${YELLOW}⚠${NC} File organization issues detected"
    
    # Show summary of issues found
    if [[ -f /tmp/cleanup-output.log ]]; then
      issue_count=$(grep "Found.*:" /tmp/cleanup-output.log 2>/dev/null | wc -l | xargs)
      if [[ "$issue_count" -gt 0 ]]; then
        echo -e "      Issues found: $issue_count categories"
        # Show first few issue types for quick overview
        grep "Found.*:" /tmp/cleanup-output.log | head -3 | sed 's/^/      - /' 2>/dev/null || true
      fi
      
      # Show any auto-fixes that were applied
      fix_count=$(grep -E "✓.*Moved|✓.*Removed|🔧 Auto-fixing" /tmp/cleanup-output.log 2>/dev/null | wc -l | xargs)
      if [[ "$fix_count" -gt 0 && "$FIX_MODE" == "true" ]]; then
        echo -e "      Auto-fixes applied: $fix_count"
      fi
    fi
    
    # Only count as blocking issue if cleanup script failed with exit code 1 (issues found)
    # Exit code 2 indicates script execution errors, which are handled separately
    if [[ $cleanup_exit_code -eq 1 ]]; then
      ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    echo -e "      Run ${BLUE}./scripts/cleanup-redundancy.sh --verbose${NC} for details"
    if [[ "$FIX_MODE" == "false" ]]; then
      echo -e "      Run ${BLUE}./scripts/cleanup-redundancy.sh --fix${NC} to auto-resolve"
    fi
  fi
  
  # Clean up temporary output file
  rm -f /tmp/cleanup-output.log
else
  echo -e "   ${YELLOW}ℹ${NC} Enhanced cleanup script not found"
fi

# Check 13: Undocumented Folders
echo ""
echo -e "${BLUE}📁 Check 13: Undocumented Folders${NC}"
if [[ -x ./scripts/discover-undocumented-folders.sh ]]; then
  if ./scripts/discover-undocumented-folders.sh > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} No undocumented folders found"
  else
    echo -e "   ${YELLOW}⚠${NC} Found undocumented folders lacking README.md"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    echo -e "      Run ${BLUE}./scripts/discover-undocumented-folders.sh${NC} to view details"
  fi
else
  echo -e "   ${YELLOW}ℹ${NC} Documentation discovery script not found"
fi

# Post-cleanup verification (only in fix mode)
if [[ "$FIX_MODE" == "true" ]]; then
  echo ""
  echo -e "${BOLD}🔍 Post-Cleanup Verification${NC}"
  echo ""
  
  # Re-run critical checks to verify fixes
  verification_issues=0
  
  # Verify state drift is resolved
  echo -e "${BLUE}Verifying state drift resolution...${NC}"
  if [[ -x ./scripts/audit-state-drift.sh ]]; then
    if ./scripts/audit-state-drift.sh 2>/dev/null; then
      echo -e "   ${GREEN}✓${NC} State drift verification passed"
    else
      echo -e "   ${RED}✗${NC} State drift still present after fix attempt"
      verification_issues=$((verification_issues + 1))
    fi
  fi
  
  # Verify completed items are archived
  echo -e "${BLUE}Verifying completed items archival...${NC}"
  remaining_completed=0
  for file in todos/*.md; do
    [[ -f "$file" ]] || continue
    [[ "$(basename "$file")" == "todo-template.md" ]] && continue
    if [[ "$(basename "$file")" =~ -done- ]] || grep -qi "^status:.*done" "$file" 2>/dev/null; then
      remaining_completed=$((remaining_completed + 1))
    fi
  done
  
  if [[ $remaining_completed -eq 0 ]]; then
    echo -e "   ${GREEN}✓${NC} Completed items archival verification passed"
  else
    echo -e "   ${RED}✗${NC} $remaining_completed completed items still not archived"
    verification_issues=$((verification_issues + 1))
  fi
  
  # Verify enhanced file organization
  echo -e "${BLUE}Verifying file organization resolution...${NC}"
  if [[ -x ./scripts/cleanup-redundancy.sh ]]; then
    if ./scripts/cleanup-redundancy.sh > /dev/null 2>&1; then
      echo -e "   ${GREEN}✓${NC} File organization verification passed"
    else
      cleanup_exit_code=$?
      if [[ $cleanup_exit_code -eq 1 ]]; then
        echo -e "   ${YELLOW}⚠${NC} Some file organization issues remain"
        verification_issues=$((verification_issues + 1))
      else
        echo -e "   ${RED}✗${NC} File organization check failed to run"
        verification_issues=$((verification_issues + 1))
      fi
    fi
  fi
  
  # Verification summary
  echo ""
  if [[ $verification_issues -eq 0 ]]; then
    echo -e "${GREEN}✓ All automatic fixes verified successfully${NC}"
  else
    echo -e "${YELLOW}⚠ $verification_issues verification(s) failed - manual intervention may be needed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + verification_issues))
  fi
fi

# Summary
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"

# Report any failed checks first
if [[ $FAILED_CHECKS -gt 0 ]]; then
  echo -e "${RED}  ⚠ $FAILED_CHECKS check(s) failed to execute properly${NC}"
  echo ""
  echo -e "  ${BOLD}Recovery suggestions:${NC}"
  for suggestion in "${RECOVERY_SUGGESTIONS[@]}"; do
    echo -e "    • $suggestion"
  done
  echo ""
fi

# Overall status evaluation
if [[ $ISSUES_FOUND -eq 0 && $FAILED_CHECKS -eq 0 ]]; then
  echo -e "${GREEN}  ✓ All checks passed - ready to push!${NC}"
  echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 0
elif [[ $ISSUES_FOUND -eq 0 && $FAILED_CHECKS -gt 0 ]]; then
  echo -e "${YELLOW}  ⚠ No issues found, but some checks failed to run${NC}"
  echo ""
  echo -e "  ${BOLD}Recommended actions:${NC}"
  echo -e "    1. Review the failed checks above"
  echo -e "    2. Fix any missing dependencies or permissions"
  echo -e "    3. Re-run housekeeping: ${BLUE}./scripts/pre-push-housekeeping.sh${NC}"
  echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 2
else
  echo -e "${RED}  ✗ Found $ISSUES_FOUND issue(s) - push blocked${NC}"
  if [[ $FAILED_CHECKS -gt 0 ]]; then
    echo -e "${RED}  ✗ Additionally, $FAILED_CHECKS check(s) failed to execute${NC}"
  fi
  echo ""
  echo -e "  ${BOLD}To fix issues, run one of:${NC}"
  echo -e "    ${BLUE}./scripts/pre-push-housekeeping.sh --fix${NC}  (auto-fix)"
  echo -e "    ${BLUE}/housekeeping${NC}                            (agent workflow)"
  echo ""
  echo -e "  ${BOLD}For comprehensive file organization:${NC}"
  echo -e "    ${BLUE}./scripts/cleanup-redundancy.sh --verbose${NC}  (detailed view)"
  echo -e "    ${BLUE}./scripts/cleanup-redundancy.sh --dry-run --fix${NC}  (preview fixes)"
  echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 1
fi

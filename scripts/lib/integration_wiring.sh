#!/bin/bash
# Integration Wiring Module for Housekeeping System
# Connects all components: cleanup script, prevention layer, enforcement system, and housekeeping workflow
#
# This module provides the integration layer that wires together:
# - Enhanced cleanup script with file pattern recognition
# - Prevention layer for proactive file organization
# - Enforcement system with git hooks
# - Housekeeping workflow orchestration
# - Error handling and recovery mechanisms

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source required modules
if [[ -f "$SCRIPT_DIR/error_handling.sh" ]]; then
    source "$SCRIPT_DIR/error_handling.sh"
fi

if [[ -f "$SCRIPT_DIR/prerequisite_validation.sh" ]]; then
    source "$SCRIPT_DIR/prerequisite_validation.sh"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# INTEGRATION CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Component paths
CLEANUP_SCRIPT="$PROJECT_ROOT/scripts/cleanup-redundancy.sh"
PRE_PUSH_HOOK="$PROJECT_ROOT/scripts/pre-push-housekeeping.sh"
HOUSEKEEPING_WORKFLOW="$PROJECT_ROOT/.agent/workflows/housekeeping.md"

# Integration state tracking (using regular arrays for compatibility)
COMPONENT_STATUS_cleanup_script="unknown"
COMPONENT_STATUS_prevention_layer="unknown"
COMPONENT_STATUS_enforcement_system="unknown"
COMPONENT_STATUS_housekeeping_workflow="unknown"
COMPONENT_STATUS_error_handling="unknown"

INTEGRATION_METRICS_components_validated=0
INTEGRATION_METRICS_integrations_tested=0
INTEGRATION_METRICS_errors_handled=0
INTEGRATION_METRICS_start_time=0

INTEGRATION_LOG_FILE=""

# Initialize integration system
initialize_integration_system() {
    local component="INTEGRATION_WIRING"
    
    log_error_framework "INFO" "$component" "Initializing housekeeping system integration..."
    
    # Setup integration logging
    local log_dir="$PROJECT_ROOT/logs"
    mkdir -p "$log_dir"
    INTEGRATION_LOG_FILE="$log_dir/integration_$(date +%Y%m%d_%H%M%S).log"
    
    # Initialize component status tracking
    COMPONENT_STATUS_cleanup_script="unknown"
    COMPONENT_STATUS_prevention_layer="unknown"
    COMPONENT_STATUS_enforcement_system="unknown"
    COMPONENT_STATUS_housekeeping_workflow="unknown"
    COMPONENT_STATUS_error_handling="unknown"
    
    # Initialize metrics
    INTEGRATION_METRICS_components_validated=0
    INTEGRATION_METRICS_integrations_tested=0
    INTEGRATION_METRICS_errors_handled=0
    INTEGRATION_METRICS_start_time=$(date +%s)
    
    log_error_framework "SUCCESS" "$component" "Integration system initialized"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMPONENT VALIDATION AND WIRING
# ═══════════════════════════════════════════════════════════════════════════════

# Helper function to set component status
set_component_status() {
    local component_name="$1"
    local status="$2"
    
    case "$component_name" in
        "cleanup_script") COMPONENT_STATUS_cleanup_script="$status" ;;
        "prevention_layer") COMPONENT_STATUS_prevention_layer="$status" ;;
        "enforcement_system") COMPONENT_STATUS_enforcement_system="$status" ;;
        "housekeeping_workflow") COMPONENT_STATUS_housekeeping_workflow="$status" ;;
        "error_handling") COMPONENT_STATUS_error_handling="$status" ;;
    esac
}

# Helper function to get component status
get_component_status() {
    local component_name="$1"
    
    case "$component_name" in
        "cleanup_script") echo "$COMPONENT_STATUS_cleanup_script" ;;
        "prevention_layer") echo "$COMPONENT_STATUS_prevention_layer" ;;
        "enforcement_system") echo "$COMPONENT_STATUS_enforcement_system" ;;
        "housekeeping_workflow") echo "$COMPONENT_STATUS_housekeeping_workflow" ;;
        "error_handling") echo "$COMPONENT_STATUS_error_handling" ;;
        *) echo "unknown" ;;
    esac
}
# Validate individual component availability and functionality
validate_component() {
    local component_name="$1"
    local component_path="$2"
    local validation_command="$3"
    local component="INTEGRATION_WIRING"
    
    log_error_framework "DEBUG" "$component" "Validating component: $component_name"
    
    # Check if component exists
    if [[ ! -f "$component_path" ]]; then
        handle_file_error "$component" "component check" "$component_path" "Install or create the missing component"
        set_component_status "$component_name" "missing"
        return 1
    fi
    
    # Check if component is executable (for scripts)
    if [[ "$component_path" =~ \.sh$ && ! -x "$component_path" ]]; then
        handle_file_error "$component" "permissions" "$component_path" "Make the script executable: chmod +x $component_path"
        set_component_status "$component_name" "not_executable"
        return 1
    fi
    
    # Run validation command if provided
    if [[ -n "$validation_command" ]]; then
        if eval "$validation_command" >/dev/null 2>&1; then
            log_error_framework "SUCCESS" "$component" "Component validation passed: $component_name"
            set_component_status "$component_name" "available"
            INTEGRATION_METRICS_components_validated=$((INTEGRATION_METRICS_components_validated + 1))
            return 0
        else
            handle_validation_error "$component" "functional test" "Component $component_name failed validation test"
            set_component_status "$component_name" "validation_failed"
            return 1
        fi
    else
        log_error_framework "SUCCESS" "$component" "Component exists: $component_name"
        set_component_status "$component_name" "available"
        INTEGRATION_METRICS_components_validated=$((INTEGRATION_METRICS_components_validated + 1))
        return 0
    fi
}

# Validate all system components
validate_all_components() {
    local component="INTEGRATION_WIRING"
    local validation_failures=0
    
    log_error_framework "INFO" "$component" "Validating all housekeeping system components..."
    
    # Validate cleanup script
    if ! validate_component "cleanup_script" "$CLEANUP_SCRIPT" "test -x $CLEANUP_SCRIPT"; then
        validation_failures=$((validation_failures + 1))
    fi
    
    # Validate pre-push hook
    if ! validate_component "enforcement_system" "$PRE_PUSH_HOOK" "test -x $PRE_PUSH_HOOK"; then
        validation_failures=$((validation_failures + 1))
    fi
    
    # Validate housekeeping workflow
    if ! validate_component "housekeeping_workflow" "$HOUSEKEEPING_WORKFLOW" ""; then
        validation_failures=$((validation_failures + 1))
    fi
    
    # Validate error handling framework
    if [[ -n "$(declare -f handle_error)" ]]; then
        set_component_status "error_handling" "available"
        INTEGRATION_METRICS_components_validated=$((INTEGRATION_METRICS_components_validated + 1))
        log_error_framework "SUCCESS" "$component" "Error handling framework is available"
    else
        handle_validation_error "$component" "error handling" "Error handling framework not loaded"
        set_component_status "error_handling" "missing"
        validation_failures=$((validation_failures + 1))
    fi
    
    # Validate prevention layer (check for file organization functions)
    if [[ -n "$(declare -f match_file_pattern)" ]]; then
        set_component_status "prevention_layer" "available"
        INTEGRATION_METRICS_components_validated=$((INTEGRATION_METRICS_components_validated + 1))
        log_error_framework "SUCCESS" "$component" "Prevention layer functions are available"
    else
        log_error_framework "WARNING" "$component" "Prevention layer functions not loaded (may be embedded in cleanup script)"
        set_component_status "prevention_layer" "embedded"
    fi
    
    if [[ $validation_failures -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "All components validated successfully"
        return 0
    else
        log_error_framework "ERROR" "$component" "$validation_failures component(s) failed validation"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTEGRATION ORCHESTRATION
# ═══════════════════════════════════════════════════════════════════════════════

# Wire cleanup script with prevention layer
wire_cleanup_with_prevention() {
    local component="INTEGRATION_WIRING"
    
    log_error_framework "INFO" "$component" "Wiring cleanup script with prevention layer..."
    
    # Check if cleanup script has prevention layer integration
    if grep -q "FILE_PATTERNS\|match_file_pattern\|get_destination_suggestions" "$CLEANUP_SCRIPT"; then
        log_error_framework "SUCCESS" "$component" "Cleanup script has integrated prevention layer"
        return 0
    else
        handle_validation_error "$component" "integration check" "Cleanup script missing prevention layer integration"
        return 1
    fi
}

# Wire enforcement system with git hooks
wire_enforcement_with_git_hooks() {
    local component="INTEGRATION_WIRING"
    
    log_error_framework "INFO" "$component" "Wiring enforcement system with git hooks..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error_framework "WARNING" "$component" "Not in a git repository - git hook integration skipped"
        return 0
    fi
    
    local git_hooks_dir=".git/hooks"
    local pre_push_hook_file="$git_hooks_dir/pre-push"
    
    # Check if pre-push hook exists and calls our housekeeping script
    if [[ -f "$pre_push_hook_file" ]]; then
        if grep -q "pre-push-housekeeping.sh\|housekeeping" "$pre_push_hook_file"; then
            log_error_framework "SUCCESS" "$component" "Pre-push hook is properly integrated"
            return 0
        else
            log_error_framework "WARNING" "$component" "Pre-push hook exists but doesn't call housekeeping"
            return 1
        fi
    else
        log_error_framework "INFO" "$component" "Pre-push hook not installed - enforcement system available but not automatic"
        return 0
    fi
}

# Wire housekeeping workflow with all components
wire_housekeeping_workflow() {
    local component="INTEGRATION_WIRING"
    
    log_error_framework "INFO" "$component" "Wiring housekeeping workflow with all components..."
    
    # Check if housekeeping workflow references all components
    local workflow_content=""
    if [[ -f "$HOUSEKEEPING_WORKFLOW" ]]; then
        workflow_content=$(cat "$HOUSEKEEPING_WORKFLOW")
    else
        handle_file_error "$component" "workflow check" "$HOUSEKEEPING_WORKFLOW" "Create or restore the housekeeping workflow file"
        return 1
    fi
    
    # Check for references to key components
    local missing_references=()
    
    if ! echo "$workflow_content" | grep -q "cleanup-redundancy.sh\|enhanced.*cleanup"; then
        missing_references+=("cleanup script")
    fi
    
    if ! echo "$workflow_content" | grep -q "pre-push-housekeeping.sh\|enforcement"; then
        missing_references+=("enforcement system")
    fi
    
    if ! echo "$workflow_content" | grep -q "error.*handling\|recovery"; then
        missing_references+=("error handling")
    fi
    
    if [[ ${#missing_references[@]} -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "Housekeeping workflow properly references all components"
        return 0
    else
        log_error_framework "WARNING" "$component" "Housekeeping workflow missing references to: ${missing_references[*]}"
        return 1
    fi
}

# Test integration between components
test_component_integration() {
    local component1="$1"
    local component2="$2"
    local test_type="$3"
    local component="INTEGRATION_WIRING"
    
    log_error_framework "DEBUG" "$component" "Testing integration: $component1 <-> $component2 ($test_type)"
    
    case "$test_type" in
        "cleanup_to_enforcement")
            # Test that cleanup script can be called by enforcement system
            if bash "$PRE_PUSH_HOOK" --help >/dev/null 2>&1; then
                log_error_framework "SUCCESS" "$component" "Enforcement system can invoke cleanup operations"
                return 0
            else
                handle_validation_error "$component" "integration test" "Enforcement system cannot invoke cleanup operations"
                return 1
            fi
            ;;
        "workflow_to_cleanup")
            # Test that workflow can invoke cleanup script
            if bash "$CLEANUP_SCRIPT" --help >/dev/null 2>&1; then
                log_error_framework "SUCCESS" "$component" "Workflow can invoke cleanup script"
                return 0
            else
                handle_validation_error "$component" "integration test" "Workflow cannot invoke cleanup script"
                return 1
            fi
            ;;
        "error_handling_integration")
            # Test that error handling is integrated across components
            if [[ -n "$(declare -f handle_error)" ]] && grep -q "handle_error\|log_error_framework" "$CLEANUP_SCRIPT"; then
                log_error_framework "SUCCESS" "$component" "Error handling is integrated across components"
                return 0
            else
                handle_validation_error "$component" "integration test" "Error handling not properly integrated"
                return 1
            fi
            ;;
        *)
            log_error_framework "WARNING" "$component" "Unknown integration test type: $test_type"
            return 1
            ;;
    esac
}

# Run comprehensive integration tests
run_integration_tests() {
    local component="INTEGRATION_WIRING"
    local test_failures=0
    
    log_error_framework "INFO" "$component" "Running comprehensive integration tests..."
    
    # Test cleanup to enforcement integration
    if ! test_component_integration "cleanup_script" "enforcement_system" "cleanup_to_enforcement"; then
        test_failures=$((test_failures + 1))
    fi
    INTEGRATION_METRICS_integrations_tested=$((INTEGRATION_METRICS_integrations_tested + 1))
    
    # Test workflow to cleanup integration
    if ! test_component_integration "housekeeping_workflow" "cleanup_script" "workflow_to_cleanup"; then
        test_failures=$((test_failures + 1))
    fi
    INTEGRATION_METRICS_integrations_tested=$((INTEGRATION_METRICS_integrations_tested + 1))
    
    # Test error handling integration
    if ! test_component_integration "error_handling" "all_components" "error_handling_integration"; then
        test_failures=$((test_failures + 1))
    fi
    INTEGRATION_METRICS_integrations_tested=$((INTEGRATION_METRICS_integrations_tested + 1))
    
    if [[ $test_failures -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "All integration tests passed"
        return 0
    else
        log_error_framework "ERROR" "$component" "$test_failures integration test(s) failed"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN INTEGRATION ORCHESTRATION
# ═══════════════════════════════════════════════════════════════════════════════

# Execute complete integration wiring
execute_integration_wiring() {
    local component="INTEGRATION_WIRING"
    local wiring_failures=0
    
    log_error_framework "INFO" "$component" "Executing complete integration wiring..."
    
    # Initialize integration system
    if ! initialize_integration_system; then
        log_error_framework "CRITICAL" "$component" "Failed to initialize integration system"
        return 2
    fi
    
    # Validate all components
    if ! validate_all_components; then
        log_error_framework "ERROR" "$component" "Component validation failed"
        wiring_failures=$((wiring_failures + 1))
    fi
    
    # Wire cleanup script with prevention layer
    if ! wire_cleanup_with_prevention; then
        log_error_framework "ERROR" "$component" "Failed to wire cleanup with prevention layer"
        wiring_failures=$((wiring_failures + 1))
    fi
    
    # Wire enforcement system with git hooks
    if ! wire_enforcement_with_git_hooks; then
        log_error_framework "WARNING" "$component" "Git hooks integration has issues (non-critical)"
        # Don't count as failure since git hooks are optional
    fi
    
    # Wire housekeeping workflow
    if ! wire_housekeeping_workflow; then
        log_error_framework "ERROR" "$component" "Failed to wire housekeeping workflow"
        wiring_failures=$((wiring_failures + 1))
    fi
    
    # Run integration tests
    if ! run_integration_tests; then
        log_error_framework "ERROR" "$component" "Integration tests failed"
        wiring_failures=$((wiring_failures + 1))
    fi
    
    # Generate integration report
    generate_integration_report
    
    if [[ $wiring_failures -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "Integration wiring completed successfully"
        return 0
    else
        log_error_framework "ERROR" "$component" "Integration wiring completed with $wiring_failures failure(s)"
        return 1
    fi
}

# Generate integration status report
generate_integration_report() {
    local component="INTEGRATION_WIRING"
    local end_time=$(date +%s)
    local duration=$((end_time - INTEGRATION_METRICS_start_time))
    
    log_error_framework "INFO" "$component" "Generating integration status report..."
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  HOUSEKEEPING SYSTEM INTEGRATION REPORT"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Integration Duration: ${duration}s"
    echo "Components Validated: $INTEGRATION_METRICS_components_validated"
    echo "Integrations Tested: $INTEGRATION_METRICS_integrations_tested"
    echo "Errors Handled: $INTEGRATION_METRICS_errors_handled"
    echo ""
    echo "Component Status:"
    
    # List all component statuses
    local components=("cleanup_script" "prevention_layer" "enforcement_system" "housekeeping_workflow" "error_handling")
    for component_name in "${components[@]}"; do
        local status=$(get_component_status "$component_name")
        local status_symbol=""
        case "$status" in
            "available") status_symbol="✓" ;;
            "embedded") status_symbol="◐" ;;
            "missing") status_symbol="✗" ;;
            "not_executable") status_symbol="⚠" ;;
            "validation_failed") status_symbol="✗" ;;
            *) status_symbol="?" ;;
        esac
        printf "  %-20s %s %s\n" "$component_name" "$status_symbol" "$status"
    done
    echo ""
    
    # Integration health score
    local available_components=0
    local total_components=5
    
    for component_name in "${components[@]}"; do
        local status=$(get_component_status "$component_name")
        if [[ "$status" == "available" || "$status" == "embedded" ]]; then
            available_components=$((available_components + 1))
        fi
    done
    
    local health_score=$((available_components * 100 / total_components))
    echo "Integration Health Score: ${health_score}%"
    
    if [[ $health_score -ge 90 ]]; then
        echo "Status: ✓ Excellent - All components properly integrated"
    elif [[ $health_score -ge 75 ]]; then
        echo "Status: ◐ Good - Most components integrated, minor issues"
    elif [[ $health_score -ge 50 ]]; then
        echo "Status: ⚠ Fair - Some integration issues need attention"
    else
        echo "Status: ✗ Poor - Significant integration problems"
    fi
    
    echo ""
    echo "Integration Log: $INTEGRATION_LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════"
}

# Verify integration health (for monitoring)
verify_integration_health() {
    local component="INTEGRATION_WIRING"
    
    # Quick health check without full wiring
    local health_issues=0
    
    # Check critical components exist
    if [[ ! -f "$CLEANUP_SCRIPT" ]]; then
        log_error_framework "ERROR" "$component" "Critical component missing: cleanup script"
        health_issues=$((health_issues + 1))
    fi
    
    if [[ ! -f "$PRE_PUSH_HOOK" ]]; then
        log_error_framework "WARNING" "$component" "Enforcement component missing: pre-push hook"
        # Don't count as critical issue
    fi
    
    if [[ ! -f "$HOUSEKEEPING_WORKFLOW" ]]; then
        log_error_framework "ERROR" "$component" "Workflow component missing: housekeeping workflow"
        health_issues=$((health_issues + 1))
    fi
    
    # Check error handling availability
    if [[ -z "$(declare -f handle_error)" ]]; then
        log_error_framework "WARNING" "$component" "Error handling framework not loaded"
        # Don't count as critical issue for health check
    fi
    
    if [[ $health_issues -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "Integration health check passed"
        return 0
    else
        log_error_framework "ERROR" "$component" "Integration health check failed: $health_issues critical issue(s)"
        return 1
    fi
}

# Export functions for use by other scripts
export -f initialize_integration_system
export -f validate_component
export -f validate_all_components
export -f execute_integration_wiring
export -f verify_integration_health
export -f generate_integration_report
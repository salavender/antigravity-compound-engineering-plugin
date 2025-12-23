#!/bin/bash
# Housekeeping System Integration Script
# Wires all components together and validates the complete system
#
# Usage: ./scripts/integrate-housekeeping-system.sh [--validate-only] [--verbose] [--report]
#
# This script integrates:
# - Enhanced cleanup script with file pattern recognition
# - Prevention layer for proactive file organization  
# - Enforcement system with git hooks
# - Housekeeping workflow orchestration
# - Error handling and recovery mechanisms

set -uo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source required modules
if [[ -f "$SCRIPT_DIR/lib/error_handling.sh" ]]; then
    source "$SCRIPT_DIR/lib/error_handling.sh"
    setup_error_handling "logs" "integration.log"
else
    echo "ERROR: Error handling framework not found"
    exit 2
fi

if [[ -f "$SCRIPT_DIR/lib/integration_wiring.sh" ]]; then
    source "$SCRIPT_DIR/lib/integration_wiring.sh"
else
    echo "ERROR: Integration wiring module not found"
    exit 2
fi

# Command line options
VALIDATE_ONLY=false
VERBOSE_MODE=false
REPORT_ONLY=false

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --validate-only)
            VALIDATE_ONLY=true
            ;;
        --verbose)
            VERBOSE_MODE=true
            ;;
        --report)
            REPORT_ONLY=true
            ;;
        --help|-h)
            cat << 'EOF'
Housekeeping System Integration Script

USAGE:
    ./scripts/integrate-housekeeping-system.sh [OPTIONS]

OPTIONS:
    --validate-only    Only validate components, don't perform integration
    --verbose          Enable detailed logging output
    --report          Generate integration status report only
    --help, -h        Show this help message

DESCRIPTION:
    This script integrates all components of the housekeeping system:
    
    1. Enhanced cleanup script with file pattern recognition
    2. Prevention layer for proactive file organization
    3. Enforcement system with git hooks
    4. Housekeeping workflow orchestration
    5. Error handling and recovery mechanisms
    
    The integration ensures all components work together seamlessly
    and provides comprehensive error handling and recovery.

EXAMPLES:
    # Full integration
    ./scripts/integrate-housekeeping-system.sh
    
    # Validate components only
    ./scripts/integrate-housekeeping-system.sh --validate-only
    
    # Generate status report
    ./scripts/integrate-housekeeping-system.sh --report
    
    # Verbose integration with detailed logging
    ./scripts/integrate-housekeeping-system.sh --verbose

EXIT CODES:
    0 = Integration successful
    1 = Integration failed with recoverable errors
    2 = Critical failure, system unusable
EOF
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Use --help for usage information"
            exit 2
            ;;
    esac
done

# Logging configuration
if [[ "$VERBOSE_MODE" == "true" ]]; then
    export LOG_LEVEL="DEBUG"
else
    export LOG_LEVEL="INFO"
fi

# Color output (avoid conflicts with error handling framework)
if [[ -z "${RED:-}" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
fi

# Enhanced logging functions
log_info() {
    echo -e "${BLUE}ℹ $1${NC}"
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        log_error_framework "INFO" "INTEGRATION_MAIN" "$1"
    fi
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
    log_error_framework "SUCCESS" "INTEGRATION_MAIN" "$1"
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    log_error_framework "WARNING" "INTEGRATION_MAIN" "$1"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
    log_error_framework "ERROR" "INTEGRATION_MAIN" "$1"
}

log_verbose() {
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo -e "${BLUE}[VERBOSE] $1${NC}"
        log_error_framework "DEBUG" "INTEGRATION_MAIN" "$1"
    fi
}

# Validate prerequisites before integration
validate_prerequisites() {
    log_info "Validating integration prerequisites..."
    
    # Check if we're in the project root
    if [[ ! -f "$PROJECT_ROOT/package.json" && ! -f "$PROJECT_ROOT/README.md" ]]; then
        log_error "Not in project root directory"
        return 1
    fi
    
    # Check for required directories
    local required_dirs=("scripts" "scripts/lib" ".agent/workflows")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$PROJECT_ROOT/$dir" ]]; then
            log_error "Required directory missing: $dir"
            return 1
        fi
    done
    
    # Check for git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_warning "Not in a git repository - some features will be limited"
    fi
    
    # Check for essential tools
    local required_tools=("bash" "find" "grep" "sed")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Required tool missing: $tool"
            return 1
        fi
    done
    
    log_success "Prerequisites validation passed"
    return 0
}

# Install git hooks if needed
install_git_hooks() {
    log_info "Checking git hooks installation..."
    
    # Skip if not in git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_verbose "Not in git repository - skipping git hooks"
        return 0
    fi
    
    local git_hooks_dir=".git/hooks"
    local pre_push_hook="$git_hooks_dir/pre-push"
    local pre_push_script="$PROJECT_ROOT/scripts/pre-push-housekeeping.sh"
    
    # Check if pre-push hook exists and is properly configured
    if [[ -f "$pre_push_hook" ]]; then
        if grep -q "pre-push-housekeeping.sh" "$pre_push_hook"; then
            log_success "Git pre-push hook already installed and configured"
            return 0
        else
            log_warning "Pre-push hook exists but doesn't call housekeeping script"
        fi
    fi
    
    # Install or update pre-push hook
    if [[ -f "$pre_push_script" ]]; then
        log_info "Installing pre-push hook..."
        
        # Create hook content
        cat > "$pre_push_hook" << EOF
#!/bin/bash
# Pre-push hook for housekeeping validation
# Automatically installed by housekeeping system integration

# Run housekeeping checks before push
if [[ -x "$pre_push_script" ]]; then
    echo "Running pre-push housekeeping checks..."
    if ! "$pre_push_script"; then
        echo "Pre-push housekeeping checks failed. Push blocked."
        echo "Run './scripts/pre-push-housekeeping.sh --fix' to resolve issues."
        exit 1
    fi
else
    echo "Warning: Housekeeping script not found or not executable"
    echo "Skipping pre-push validation"
fi
EOF
        
        chmod +x "$pre_push_hook"
        log_success "Pre-push hook installed successfully"
    else
        log_warning "Pre-push housekeeping script not found - hook not installed"
    fi
    
    return 0
}

# Create integration status dashboard
create_integration_dashboard() {
    local dashboard_file="$PROJECT_ROOT/docs/reports/housekeeping-integration-status.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    log_info "Creating integration status dashboard..."
    
    # Ensure reports directory exists
    mkdir -p "$(dirname "$dashboard_file")"
    
    # Generate dashboard content
    cat > "$dashboard_file" << EOF
# Housekeeping System Integration Status

**Generated:** $timestamp  
**Integration Script:** \`scripts/integrate-housekeeping-system.sh\`

## Component Status

EOF
    
    # Add component status from integration wiring
    local components=("cleanup_script" "prevention_layer" "enforcement_system" "housekeeping_workflow" "error_handling")
    for component_name in "${components[@]}"; do
        local status=$(get_component_status "$component_name" 2>/dev/null || echo "unknown")
        local status_emoji=""
        local status_description=""
        
        case "$status" in
            "available")
                status_emoji="✅"
                status_description="Fully operational"
                ;;
            "embedded")
                status_emoji="🔄"
                status_description="Integrated within other component"
                ;;
            "missing")
                status_emoji="❌"
                status_description="Component not found"
                ;;
            "not_executable")
                status_emoji="⚠️"
                status_description="Exists but not executable"
                ;;
            "validation_failed")
                status_emoji="❌"
                status_description="Failed validation tests"
                ;;
            *)
                status_emoji="❓"
                status_description="Unknown status"
                ;;
        esac
        
        echo "- **${component_name}**: $status_emoji $status_description" >> "$dashboard_file"
    done
    
    cat >> "$dashboard_file" << EOF

## Integration Health

EOF
    
    # Add integration metrics if available
    echo "- **Components Validated:** ${INTEGRATION_METRICS_components_validated:-0}" >> "$dashboard_file"
    echo "- **Integrations Tested:** ${INTEGRATION_METRICS_integrations_tested:-0}" >> "$dashboard_file"
    echo "- **Errors Handled:** ${INTEGRATION_METRICS_errors_handled:-0}" >> "$dashboard_file"
    
    cat >> "$dashboard_file" << EOF

## Quick Commands

\`\`\`bash
# Run full integration
./scripts/integrate-housekeeping-system.sh

# Validate components only
./scripts/integrate-housekeeping-system.sh --validate-only

# Generate status report
./scripts/integrate-housekeeping-system.sh --report

# Run housekeeping workflow
./scripts/pre-push-housekeeping.sh

# Enhanced cleanup with auto-fix
./scripts/cleanup-redundancy.sh --fix --verbose
\`\`\`

## Troubleshooting

If integration issues occur:

1. **Validate Prerequisites:**
   \`\`\`bash
   ./scripts/validate-prerequisites.sh
   \`\`\`

2. **Check Component Status:**
   \`\`\`bash
   ./scripts/integrate-housekeeping-system.sh --validate-only --verbose
   \`\`\`

3. **Review Integration Logs:**
   \`\`\`bash
   tail -f logs/integration*.log
   \`\`\`

4. **Manual Component Testing:**
   \`\`\`bash
   # Test cleanup script
   ./scripts/cleanup-redundancy.sh --help
   
   # Test enforcement system
   ./scripts/pre-push-housekeeping.sh --help
   \`\`\`

---

*This dashboard is automatically updated by the integration system.*
EOF
    
    log_success "Integration dashboard created: $dashboard_file"
}

# Main integration workflow
main() {
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Housekeeping System Integration${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Handle report-only mode
    if [[ "$REPORT_ONLY" == "true" ]]; then
        log_info "Generating integration status report..."
        if verify_integration_health; then
            generate_integration_report
            create_integration_dashboard
            log_success "Integration status report generated"
            exit 0
        else
            log_error "Integration health check failed"
            exit 1
        fi
    fi
    
    # Validate prerequisites
    if ! validate_prerequisites; then
        log_error "Prerequisites validation failed"
        exit 2
    fi
    
    # Handle validate-only mode
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        log_info "Running validation-only mode..."
        if validate_all_components; then
            log_success "All components validated successfully"
            create_integration_dashboard
            exit 0
        else
            log_error "Component validation failed"
            exit 1
        fi
    fi
    
    # Full integration workflow
    log_info "Starting full housekeeping system integration..."
    
    # Execute integration wiring
    local integration_result=0
    if execute_integration_wiring; then
        log_success "Integration wiring completed successfully"
    else
        integration_result=$?
        log_error "Integration wiring failed"
    fi
    
    # Install git hooks
    if ! install_git_hooks; then
        log_warning "Git hooks installation had issues (non-critical)"
    fi
    
    # Create integration dashboard
    create_integration_dashboard
    
    # Final status
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    
    if [[ $integration_result -eq 0 ]]; then
        log_success "Housekeeping system integration completed successfully!"
        echo ""
        echo -e "${GREEN}Next steps:${NC}"
        echo -e "  1. Run housekeeping: ${BLUE}./scripts/pre-push-housekeeping.sh${NC}"
        echo -e "  2. Test cleanup: ${BLUE}./scripts/cleanup-redundancy.sh --dry-run${NC}"
        echo -e "  3. View dashboard: ${BLUE}docs/reports/housekeeping-integration-status.md${NC}"
        echo ""
        exit 0
    else
        log_error "Housekeeping system integration completed with errors"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo -e "  1. Check logs: ${BLUE}tail -f logs/integration*.log${NC}"
        echo -e "  2. Validate components: ${BLUE}./scripts/integrate-housekeeping-system.sh --validate-only --verbose${NC}"
        echo -e "  3. Check prerequisites: ${BLUE}./scripts/validate-prerequisites.sh${NC}"
        echo ""
        exit $integration_result
    fi
}

# Run main function
main "$@"
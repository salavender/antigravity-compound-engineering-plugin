#!/bin/bash
# Prerequisite Validation Script for Housekeeping System
#
# This script validates all prerequisites before running housekeeping operations.
# It can be run standalone or integrated into other housekeeping scripts.
#
# Usage: ./scripts/validate-prerequisites.sh [--quick] [--verbose]
#
# Exit codes:
#   0 = All prerequisites met
#   1 = Some prerequisites not met (non-critical)
#   2 = Critical prerequisites not met (cannot continue)

# Script directory and sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the prerequisite validation module
if [[ -f "$SCRIPT_DIR/lib/prerequisite_validation.sh" ]]; then
    source "$SCRIPT_DIR/lib/prerequisite_validation.sh"
else
    echo "ERROR: Prerequisite validation module not found at $SCRIPT_DIR/lib/prerequisite_validation.sh"
    exit 2
fi

# Parse command line arguments
QUICK_MODE=false
VERBOSE_MODE=false

for arg in "$@"; do
    case $arg in
        --quick)
            QUICK_MODE=true
            ;;
        --verbose)
            VERBOSE_MODE=true
            ;;
        --help|-h)
            echo "Prerequisite Validation Script for Housekeeping System"
            echo ""
            echo "Usage: $0 [--quick] [--verbose] [--help]"
            echo ""
            echo "Options:"
            echo "  --quick     Run only essential prerequisite checks (faster)"
            echo "  --verbose   Enable detailed output and debugging information"
            echo "  --help      Show this help message"
            echo ""
            echo "Exit codes:"
            echo "  0 = All prerequisites met"
            echo "  1 = Some prerequisites not met (non-critical)"
            echo "  2 = Critical prerequisites not met (cannot continue)"
            echo ""
            echo "Examples:"
            echo "  $0                    # Full prerequisite validation"
            echo "  $0 --quick           # Quick validation of essential prerequisites only"
            echo "  $0 --verbose         # Full validation with detailed output"
            echo "  $0 --quick --verbose # Quick validation with detailed output"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Use --help for usage information"
            exit 2
            ;;
    esac
done

# Export verbose mode for use by validation modules
export VERBOSE_MODE

# Main validation execution
main() {
    local component="PREREQUISITE_VALIDATOR"
    local exit_code=0
    
    echo "=========================================="
    echo "Housekeeping Prerequisite Validation"
    echo "=========================================="
    
    if [[ "$QUICK_MODE" == "true" ]]; then
        log_error_framework "INFO" "$component" "Running quick prerequisite validation..."
        
        if ! validate_essential_prerequisites; then
            log_error_framework "CRITICAL" "$component" "Essential prerequisites not met - housekeeping operations cannot continue safely"
            exit_code=2
        else
            log_error_framework "SUCCESS" "$component" "Essential prerequisites validated successfully"
        fi
    else
        log_error_framework "INFO" "$component" "Running comprehensive prerequisite validation..."
        
        if ! validate_all_prerequisites; then
            # Check if there are critical errors
            if has_critical_errors; then
                log_error_framework "CRITICAL" "$component" "Critical prerequisites not met - housekeeping operations cannot continue safely"
                exit_code=2
            else
                log_error_framework "WARNING" "$component" "Some prerequisites not met - housekeeping operations may have limited functionality"
                exit_code=1
            fi
        else
            log_error_framework "SUCCESS" "$component" "All prerequisites validated successfully"
        fi
    fi
    
    # Generate summary if there were any issues
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        generate_error_summary "$component"
    fi
    
    echo ""
    echo "=========================================="
    case $exit_code in
        0)
            echo "✓ PREREQUISITE VALIDATION PASSED"
            echo "System is ready for housekeeping operations"
            ;;
        1)
            echo "⚠ PREREQUISITE VALIDATION COMPLETED WITH WARNINGS"
            echo "Some non-critical prerequisites are not met"
            echo "Housekeeping operations can proceed but may have limited functionality"
            ;;
        2)
            echo "✗ PREREQUISITE VALIDATION FAILED"
            echo "Critical prerequisites are not met"
            echo "Please address the issues above before running housekeeping operations"
            ;;
    esac
    echo "=========================================="
    
    exit $exit_code
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
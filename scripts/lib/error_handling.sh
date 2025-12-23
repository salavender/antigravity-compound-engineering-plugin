#!/bin/bash
# Comprehensive Error Handling Framework for Housekeeping System
#
# This module provides robust error handling, categorization, logging, and recovery
# procedures for the housekeeping system components.
#
# Usage:
#   source scripts/lib/error_handling.sh
#   setup_error_handling
#   handle_error "COMPONENT" "ERROR_CODE" "Error message" "Recovery instructions"

# ═══════════════════════════════════════════════════════════════════════════════
# ERROR HANDLING CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Error categories and their severity levels
# Format: "category:severity:description"
ERROR_CATEGORIES=(
    "PERMISSION:high:Permission denied or insufficient access rights"
    "GIT_OPERATION:medium:Git command failed or repository state invalid"
    "FILE_OPERATION:medium:File system operation failed"
    "NETWORK:low:Network connectivity or external service unavailable"
    "DEPENDENCY:high:Required tool or dependency missing"
    "VALIDATION:medium:Input validation or prerequisite check failed"
    "SCRIPT_EXECUTION:medium:Script or command execution failed"
    "CONFIGURATION:low:Configuration file missing or invalid"
)

# Error codes with specific handling instructions
# Format: "error_code:category:description"
ERROR_CODES=(
    # Permission errors
    "PERM_001:PERMISSION:Cannot write to directory"
    "PERM_002:PERMISSION:Cannot read file or directory"
    "PERM_003:PERMISSION:Cannot execute script or command"
    
    # Git operation errors
    "GIT_001:GIT_OPERATION:Git mv command failed"
    "GIT_002:GIT_OPERATION:Git rm command failed"
    "GIT_003:GIT_OPERATION:Git add command failed"
    "GIT_004:GIT_OPERATION:Not in a git repository"
    "GIT_005:GIT_OPERATION:Git repository state is invalid"
    "GIT_006:GIT_OPERATION:Git merge conflict detected"
    
    # File operation errors
    "FILE_001:FILE_OPERATION:File or directory does not exist"
    "FILE_002:FILE_OPERATION:Cannot create directory"
    "FILE_003:FILE_OPERATION:Cannot move or copy file"
    "FILE_004:FILE_OPERATION:File already exists at destination"
    "FILE_005:FILE_OPERATION:Disk space insufficient"
    
    # Network errors
    "NET_001:NETWORK:Cannot connect to external service"
    "NET_002:NETWORK:DNS resolution failed"
    "NET_003:NETWORK:Request timeout"
    
    # Dependency errors
    "DEP_001:DEPENDENCY:Required command not found"
    "DEP_002:DEPENDENCY:Required file or library missing"
    "DEP_003:DEPENDENCY:Version requirement not met"
    
    # Validation errors
    "VAL_001:VALIDATION:Invalid file pattern or format"
    "VAL_002:VALIDATION:Prerequisite check failed"
    "VAL_003:VALIDATION:Configuration validation failed"
    
    # Script execution errors
    "EXEC_001:SCRIPT_EXECUTION:Command returned non-zero exit code"
    "EXEC_002:SCRIPT_EXECUTION:Script timeout exceeded"
    "EXEC_003:SCRIPT_EXECUTION:Script interrupted by signal"
    
    # Configuration errors
    "CONF_001:CONFIGURATION:Configuration file not found"
    "CONF_002:CONFIGURATION:Invalid configuration format"
    "CONF_003:CONFIGURATION:Required configuration key missing"
)

# Recovery procedures for common error patterns
# Format: "category:function_name"
RECOVERY_PROCEDURES=(
    "PERMISSION:check_and_fix_permissions"
    "GIT_OPERATION:recover_git_operation"
    "FILE_OPERATION:recover_file_operation"
    "NETWORK:retry_with_backoff"
    "DEPENDENCY:install_or_suggest_dependency"
    "VALIDATION:provide_validation_guidance"
    "SCRIPT_EXECUTION:analyze_script_failure"
    "CONFIGURATION:create_default_configuration"
)

# Global error tracking
ERROR_LOG_FILE=""
ERROR_COUNT=0
CRITICAL_ERROR_COUNT=0
ERROR_HISTORY=()
RECOVERY_ATTEMPTS=()

# Helper function to get error category info
get_error_category_info() {
    local category="$1"
    for entry in "${ERROR_CATEGORIES[@]}"; do
        IFS=':' read -r cat severity description <<< "$entry"
        if [[ "$cat" == "$category" ]]; then
            echo "$severity:$description"
            return 0
        fi
    done
    echo "medium:Unknown category"
    return 1
}

# Helper function to get error code info
get_error_code_info() {
    local error_code="$1"
    for entry in "${ERROR_CODES[@]}"; do
        IFS=':' read -r code category description <<< "$entry"
        if [[ "$code" == "$error_code" ]]; then
            echo "$category:$description"
            return 0
        fi
    done
    echo "UNKNOWN:Unknown error code"
    return 1
}

# Helper function to get recovery procedure
get_recovery_procedure() {
    local category="$1"
    for entry in "${RECOVERY_PROCEDURES[@]}"; do
        IFS=':' read -r cat procedure <<< "$entry"
        if [[ "$cat" == "$category" ]]; then
            echo "$procedure"
            return 0
        fi
    done
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING AND OUTPUT FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Color codes for consistent output
if [[ -t 1 ]]; then  # Only use colors if outputting to terminal
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly PURPLE='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly PURPLE=''
    readonly CYAN=''
    readonly BOLD=''
    readonly NC=''
fi

# Enhanced logging functions with error categorization
log_error_framework() {
    local level="$1"
    local component="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to file if configured
    if [[ -n "$ERROR_LOG_FILE" ]]; then
        echo "[$timestamp] [$level] [$component] $message" >> "$ERROR_LOG_FILE"
    fi
    
    # Log to console with appropriate formatting
    case "$level" in
        "CRITICAL")
            echo -e "${RED}${BOLD}🚨 CRITICAL [$component] $message${NC}" >&2
            ;;
        "ERROR")
            echo -e "${RED}✗ ERROR [$component] $message${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠ WARNING [$component] $message${NC}" >&2
            ;;
        "INFO")
            echo -e "${BLUE}ℹ INFO [$component] $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✓ SUCCESS [$component] $message${NC}"
            ;;
        "DEBUG")
            if [[ "${VERBOSE_MODE:-false}" == "true" ]]; then
                echo -e "${CYAN}🔍 DEBUG [$component] $message${NC}"
            fi
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# ERROR HANDLING CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Initialize error handling system
setup_error_handling() {
    local log_dir="${1:-logs}"
    local log_file="${2:-housekeeping_errors.log}"
    
    # Create log directory if it doesn't exist
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" 2>/dev/null || {
            log_error_framework "WARNING" "ERROR_HANDLER" "Cannot create log directory: $log_dir"
            ERROR_LOG_FILE=""
            return 1
        }
    fi
    
    ERROR_LOG_FILE="$log_dir/$log_file"
    
    # Initialize log file with header
    {
        echo "# Housekeeping Error Log"
        echo "# Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# PID: $$"
        echo "# Working Directory: $(pwd)"
        echo ""
    } > "$ERROR_LOG_FILE" 2>/dev/null || {
        log_error_framework "WARNING" "ERROR_HANDLER" "Cannot write to log file: $ERROR_LOG_FILE"
        ERROR_LOG_FILE=""
        return 1
    }
    
    log_error_framework "INFO" "ERROR_HANDLER" "Error handling initialized (log: $ERROR_LOG_FILE)"
    return 0
}

# Main error handling function
handle_error() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    local recovery_instructions="${4:-}"
    local exit_on_critical="${5:-false}"
    
    # Validate inputs
    if [[ -z "$component" || -z "$error_code" || -z "$error_message" ]]; then
        log_error_framework "ERROR" "ERROR_HANDLER" "Invalid parameters to handle_error function"
        return 1
    fi
    
    # Increment error counters
    ERROR_COUNT=$((ERROR_COUNT + 1))
    
    # Get error category and severity
    local category=""
    local severity=""
    local description=""
    
    if code_info=$(get_error_code_info "$error_code"); then
        IFS=':' read -r category description <<< "$code_info"
        if category_info=$(get_error_category_info "$category"); then
            IFS=':' read -r severity _ <<< "$category_info"
        else
            severity="medium"
        fi
    else
        category="UNKNOWN"
        severity="medium"
        description="Unknown error code"
    fi
    
    # Track critical errors
    if [[ "$severity" == "high" ]]; then
        CRITICAL_ERROR_COUNT=$((CRITICAL_ERROR_COUNT + 1))
    fi
    
    # Create error record
    local error_record="$component:$error_code:$category:$severity:$error_message"
    ERROR_HISTORY+=("$error_record")
    
    # Log the error with appropriate level
    local log_level="ERROR"
    if [[ "$severity" == "high" ]]; then
        log_level="CRITICAL"
    elif [[ "$severity" == "low" ]]; then
        log_level="WARNING"
    fi
    
    log_error_framework "$log_level" "$component" "[$error_code] $error_message"
    
    # Show error details if verbose mode is enabled
    if [[ "${VERBOSE_MODE:-false}" == "true" ]]; then
        log_error_framework "DEBUG" "$component" "Category: $category, Severity: $severity"
        if [[ -n "$description" ]]; then
            log_error_framework "DEBUG" "$component" "Description: $description"
        fi
    fi
    
    # Attempt automatic recovery
    local recovery_attempted=false
    if recovery_function=$(get_recovery_procedure "$category"); then
        log_error_framework "INFO" "$component" "Attempting automatic recovery using: $recovery_function"
        
        if declare -f "$recovery_function" >/dev/null 2>&1; then
            if "$recovery_function" "$component" "$error_code" "$error_message"; then
                log_error_framework "SUCCESS" "$component" "Automatic recovery successful"
                RECOVERY_ATTEMPTS+=("$error_record:SUCCESS")
                return 0
            else
                log_error_framework "WARNING" "$component" "Automatic recovery failed"
                RECOVERY_ATTEMPTS+=("$error_record:FAILED")
                recovery_attempted=true
            fi
        else
            log_error_framework "WARNING" "$component" "Recovery function not implemented: $recovery_function"
        fi
    fi
    
    # Provide manual recovery instructions
    if [[ -n "$recovery_instructions" ]]; then
        log_error_framework "INFO" "$component" "Manual recovery instructions:"
        echo -e "${CYAN}  → $recovery_instructions${NC}"
    else
        # Generate default recovery instructions based on category
        generate_recovery_instructions "$category" "$error_code" "$component"
    fi
    
    # Exit on critical errors if requested
    if [[ "$exit_on_critical" == "true" && "$severity" == "high" ]]; then
        log_error_framework "CRITICAL" "$component" "Critical error encountered, exiting as requested"
        exit 1
    fi
    
    return 1
}

# Generate default recovery instructions based on error category
generate_recovery_instructions() {
    local category="$1"
    local error_code="$2"
    local component="$3"
    
    case "$category" in
        "PERMISSION")
            echo -e "${CYAN}  → Check file/directory permissions: ls -la${NC}"
            echo -e "${CYAN}  → Fix permissions if needed: chmod/chown commands${NC}"
            echo -e "${CYAN}  → Ensure you have necessary access rights${NC}"
            ;;
        "GIT_OPERATION")
            echo -e "${CYAN}  → Check git repository status: git status${NC}"
            echo -e "${CYAN}  → Resolve any merge conflicts or uncommitted changes${NC}"
            echo -e "${CYAN}  → Try the operation manually: git <command>${NC}"
            ;;
        "FILE_OPERATION")
            echo -e "${CYAN}  → Check if file/directory exists: ls -la${NC}"
            echo -e "${CYAN}  → Verify disk space: df -h${NC}"
            echo -e "${CYAN}  → Check file permissions and ownership${NC}"
            ;;
        "NETWORK")
            echo -e "${CYAN}  → Check network connectivity: ping google.com${NC}"
            echo -e "${CYAN}  → Verify DNS resolution: nslookup <domain>${NC}"
            echo -e "${CYAN}  → Retry the operation after network issues are resolved${NC}"
            ;;
        "DEPENDENCY")
            echo -e "${CYAN}  → Install missing dependency using package manager${NC}"
            echo -e "${CYAN}  → Check PATH environment variable${NC}"
            echo -e "${CYAN}  → Verify version requirements are met${NC}"
            ;;
        "VALIDATION")
            echo -e "${CYAN}  → Review input parameters and format${NC}"
            echo -e "${CYAN}  → Check configuration files for errors${NC}"
            echo -e "${CYAN}  → Ensure all prerequisites are met${NC}"
            ;;
        "SCRIPT_EXECUTION")
            echo -e "${CYAN}  → Check script permissions: ls -la <script>${NC}"
            echo -e "${CYAN}  → Review script output for specific error messages${NC}"
            echo -e "${CYAN}  → Try running the script manually with verbose output${NC}"
            ;;
        "CONFIGURATION")
            echo -e "${CYAN}  → Create or restore configuration file${NC}"
            echo -e "${CYAN}  → Check configuration file syntax${NC}"
            echo -e "${CYAN}  → Refer to documentation for required settings${NC}"
            ;;
        *)
            echo -e "${CYAN}  → Review error message and context${NC}"
            echo -e "${CYAN}  → Check system logs for additional information${NC}"
            echo -e "${CYAN}  → Consult documentation or seek assistance${NC}"
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# RECOVERY PROCEDURE IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Check and fix common permission issues
check_and_fix_permissions() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Checking permissions for common issues..."
    
    # Check current directory permissions
    if [[ ! -w "." ]]; then
        log_error_framework "WARNING" "$component" "Current directory is not writable"
        return 1
    fi
    
    # Check git directory permissions if in a git repo
    if [[ -d ".git" && ! -w ".git" ]]; then
        log_error_framework "WARNING" "$component" "Git directory is not writable"
        return 1
    fi
    
    # Check if we can create temporary files
    local temp_file=$(mktemp 2>/dev/null) || {
        log_error_framework "WARNING" "$component" "Cannot create temporary files"
        return 1
    }
    rm -f "$temp_file"
    
    log_error_framework "SUCCESS" "$component" "Basic permissions check passed"
    return 0
}

# Recover from git operation failures
recover_git_operation() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Attempting git operation recovery..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error_framework "WARNING" "$component" "Not in a git repository"
        return 1
    fi
    
    # Check git repository status
    if ! git status >/dev/null 2>&1; then
        log_error_framework "WARNING" "$component" "Git repository is in an invalid state"
        return 1
    fi
    
    # Check for merge conflicts
    if git status --porcelain | grep -q "^UU\|^AA\|^DD"; then
        log_error_framework "WARNING" "$component" "Merge conflicts detected - manual resolution required"
        return 1
    fi
    
    log_error_framework "SUCCESS" "$component" "Git repository state appears valid"
    return 0
}

# Recover from file operation failures
recover_file_operation() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Attempting file operation recovery..."
    
    # Check disk space
    local available_space=$(df . | tail -1 | awk '{print $4}')
    if [[ "$available_space" -lt 1048576 ]]; then  # Less than 1GB
        log_error_framework "WARNING" "$component" "Low disk space: ${available_space}KB available"
        return 1
    fi
    
    # Check if we can write to current directory
    if [[ ! -w "." ]]; then
        log_error_framework "WARNING" "$component" "Cannot write to current directory"
        return 1
    fi
    
    log_error_framework "SUCCESS" "$component" "File system appears accessible"
    return 0
}

# Retry operations with exponential backoff
retry_with_backoff() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    local max_attempts="${4:-3}"
    local base_delay="${5:-1}"
    
    log_error_framework "INFO" "$component" "Network retry not implemented in this context"
    return 1
}

# Install or suggest missing dependencies
install_or_suggest_dependency() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Checking for missing dependencies..."
    
    # Extract command name from error message if possible
    local missing_cmd=""
    if [[ "$error_message" =~ command\ not\ found:\ ([a-zA-Z0-9_-]+) ]]; then
        missing_cmd="${BASH_REMATCH[1]}"
    elif [[ "$error_message" =~ ([a-zA-Z0-9_-]+):\ command\ not\ found ]]; then
        missing_cmd="${BASH_REMATCH[1]}"
    fi
    
    if [[ -n "$missing_cmd" ]]; then
        log_error_framework "INFO" "$component" "Missing command detected: $missing_cmd"
        
        # Provide installation suggestions for common commands
        case "$missing_cmd" in
            "git")
                echo -e "${CYAN}  → Install git: brew install git (macOS) or apt-get install git (Ubuntu)${NC}"
                ;;
            "shasum")
                echo -e "${CYAN}  → shasum should be available on macOS by default${NC}"
                echo -e "${CYAN}  → On Linux, try: apt-get install coreutils${NC}"
                ;;
            "find")
                echo -e "${CYAN}  → find should be available by default on Unix systems${NC}"
                echo -e "${CYAN}  → Check your PATH environment variable${NC}"
                ;;
            *)
                echo -e "${CYAN}  → Install $missing_cmd using your system's package manager${NC}"
                ;;
        esac
        return 1
    fi
    
    log_error_framework "INFO" "$component" "No specific dependency suggestions available"
    return 1
}

# Provide validation guidance
provide_validation_guidance() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Providing validation guidance..."
    
    case "$error_code" in
        "VAL_001")
            echo -e "${CYAN}  → Check file pattern syntax and ensure it matches expected format${NC}"
            ;;
        "VAL_002")
            echo -e "${CYAN}  → Review prerequisite requirements and ensure they are met${NC}"
            ;;
        "VAL_003")
            echo -e "${CYAN}  → Validate configuration file syntax and required fields${NC}"
            ;;
        *)
            echo -e "${CYAN}  → Review input parameters and ensure they meet requirements${NC}"
            ;;
    esac
    
    return 1  # Validation issues typically require manual intervention
}

# Analyze script execution failures
analyze_script_failure() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Analyzing script execution failure..."
    
    # Check if the script file exists and is executable
    if [[ "$error_message" =~ ([^[:space:]]+\.sh) ]]; then
        local script_file="${BASH_REMATCH[1]}"
        if [[ -f "$script_file" ]]; then
            if [[ ! -x "$script_file" ]]; then
                log_error_framework "INFO" "$component" "Script is not executable: $script_file"
                echo -e "${CYAN}  → Make script executable: chmod +x $script_file${NC}"
                return 0
            fi
        else
            log_error_framework "WARNING" "$component" "Script file not found: $script_file"
            return 1
        fi
    fi
    
    log_error_framework "INFO" "$component" "Script execution analysis complete"
    return 1
}

# Create default configuration
create_default_configuration() {
    local component="$1"
    local error_code="$2"
    local error_message="$3"
    
    log_error_framework "INFO" "$component" "Configuration recovery not implemented for this context"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# ERROR REPORTING AND SUMMARY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Generate comprehensive error summary
generate_error_summary() {
    local component="${1:-SYSTEM}"
    
    echo -e "\n${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                              ERROR SUMMARY                                    ${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [[ $ERROR_COUNT -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "No errors encountered during execution"
        return 0
    fi
    
    log_error_framework "INFO" "$component" "Total errors: $ERROR_COUNT (Critical: $CRITICAL_ERROR_COUNT)"
    
    # Categorize errors
    declare -A category_counts
    for error_record in "${ERROR_HISTORY[@]}"; do
        IFS=':' read -r comp code cat sev msg <<< "$error_record"
        category_counts["$cat"]=$((${category_counts["$cat"]:-0} + 1))
    done
    
    # Display error breakdown by category
    if [[ ${#category_counts[@]} -gt 0 ]]; then
        echo -e "\n${BOLD}Error Breakdown by Category:${NC}"
        for category in "${!category_counts[@]}"; do
            local count="${category_counts[$category]}"
            local severity=""
            if [[ -n "${ERROR_CATEGORIES[$category]:-}" ]]; then
                IFS=':' read -r severity _ <<< "${ERROR_CATEGORIES[$category]}"
            fi
            
            local color="$YELLOW"
            if [[ "$severity" == "high" ]]; then
                color="$RED"
            elif [[ "$severity" == "low" ]]; then
                color="$BLUE"
            fi
            
            echo -e "  ${color}$category: $count error(s) (severity: $severity)${NC}"
        done
    fi
    
    # Display recovery attempt results
    if [[ ${#RECOVERY_ATTEMPTS[@]} -gt 0 ]]; then
        echo -e "\n${BOLD}Recovery Attempts:${NC}"
        local successful_recoveries=0
        for attempt in "${RECOVERY_ATTEMPTS[@]}"; do
            IFS=':' read -r error_part result <<< "$attempt"
            if [[ "$result" == "SUCCESS" ]]; then
                successful_recoveries=$((successful_recoveries + 1))
                echo -e "  ${GREEN}✓ Successful recovery${NC}"
            else
                echo -e "  ${RED}✗ Failed recovery${NC}"
            fi
        done
        
        if [[ $successful_recoveries -gt 0 ]]; then
            log_error_framework "SUCCESS" "$component" "$successful_recoveries automatic recovery(ies) successful"
        fi
    fi
    
    # Provide next steps
    echo -e "\n${BOLD}Recommended Next Steps:${NC}"
    if [[ $CRITICAL_ERROR_COUNT -gt 0 ]]; then
        echo -e "  ${RED}1. Address critical errors immediately${NC}"
        echo -e "  ${YELLOW}2. Review error log for detailed information${NC}"
        echo -e "  ${BLUE}3. Follow recovery instructions provided above${NC}"
    else
        echo -e "  ${YELLOW}1. Review non-critical errors when convenient${NC}"
        echo -e "  ${BLUE}2. Consider implementing preventive measures${NC}"
    fi
    
    if [[ -n "$ERROR_LOG_FILE" && -f "$ERROR_LOG_FILE" ]]; then
        echo -e "  ${CYAN}4. Check detailed error log: $ERROR_LOG_FILE${NC}"
    fi
    
    return $ERROR_COUNT
}

# Check if there are any critical errors
has_critical_errors() {
    [[ $CRITICAL_ERROR_COUNT -gt 0 ]]
}

# Get error count by category
get_error_count_by_category() {
    local category="$1"
    local count=0
    
    for error_record in "${ERROR_HISTORY[@]}"; do
        IFS=':' read -r comp code cat sev msg <<< "$error_record"
        if [[ "$cat" == "$category" ]]; then
            count=$((count + 1))
        fi
    done
    
    echo $count
}

# Reset error tracking (useful for testing or multi-phase operations)
reset_error_tracking() {
    ERROR_COUNT=0
    CRITICAL_ERROR_COUNT=0
    ERROR_HISTORY=()
    RECOVERY_ATTEMPTS=()
    
    if [[ -n "$ERROR_LOG_FILE" ]]; then
        echo "# Error tracking reset at $(date '+%Y-%m-%d %H:%M:%S')" >> "$ERROR_LOG_FILE"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# CONVENIENCE FUNCTIONS FOR COMMON ERROR SCENARIOS
# ═══════════════════════════════════════════════════════════════════════════════

# Handle permission errors
handle_permission_error() {
    local component="$1"
    local operation="$2"
    local path="$3"
    local recovery_instructions="${4:-Check and fix file/directory permissions}"
    
    handle_error "$component" "PERM_001" "Permission denied for $operation: $path" "$recovery_instructions"
}

# Handle git operation errors
handle_git_error() {
    local component="$1"
    local git_command="$2"
    local error_output="$3"
    local recovery_instructions="${4:-Check git repository state and retry operation}"
    
    handle_error "$component" "GIT_001" "Git $git_command failed: $error_output" "$recovery_instructions"
}

# Handle file operation errors
handle_file_error() {
    local component="$1"
    local operation="$2"
    local file_path="$3"
    local recovery_instructions="${4:-Check file existence, permissions, and disk space}"
    
    handle_error "$component" "FILE_001" "File $operation failed: $file_path" "$recovery_instructions"
}

# Handle missing dependency errors
handle_dependency_error() {
    local component="$1"
    local dependency="$2"
    local recovery_instructions="${3:-Install missing dependency using package manager}"
    
    handle_error "$component" "DEP_001" "Required dependency not found: $dependency" "$recovery_instructions"
}

# Handle validation errors
handle_validation_error() {
    local component="$1"
    local validation_type="$2"
    local details="$3"
    local recovery_instructions="${4:-Review and correct input parameters}"
    
    handle_error "$component" "VAL_001" "$validation_type validation failed: $details" "$recovery_instructions"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALIZATION CHECK
# ═══════════════════════════════════════════════════════════════════════════════

# Verify that the error handling framework is properly loaded
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced
    log_error_framework "DEBUG" "ERROR_HANDLER" "Error handling framework loaded successfully"
else
    # Script is being executed directly
    echo "Error Handling Framework for Housekeeping System"
    echo "This script should be sourced, not executed directly."
    echo "Usage: source scripts/lib/error_handling.sh"
    exit 1
fi
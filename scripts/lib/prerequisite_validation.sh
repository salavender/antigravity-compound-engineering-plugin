#!/bin/bash
# Prerequisite Validation Module for Housekeeping System
#
# This module provides comprehensive validation of system prerequisites,
# dependencies, and environment requirements before executing housekeeping operations.
#
# Usage:
#   source scripts/lib/prerequisite_validation.sh
#   validate_all_prerequisites
#   validate_git_environment
#   validate_file_system_permissions

# Source the error handling framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/error_handling.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# PREREQUISITE VALIDATION CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Required commands and their minimum versions (if applicable)
# Format: "command:min_version" (empty min_version means no version check)
REQUIRED_COMMANDS=(
    "git:2.0.0"
    "find:"
    "grep:"
    "sed:"
    "awk:"
    "sort:"
    "uniq:"
    "head:"
    "tail:"
    "cut:"
    "basename:"
    "dirname:"
    "mkdir:"
    "rm:"
    "mv:"
    "cp:"
    "chmod:"
    "ls:"
    "stat:"
    "date:"
    "shasum:"
)

# Optional commands that enhance functionality
# Format: "command:description"
OPTIONAL_COMMANDS=(
    "xargs:Improves file processing performance"
    "parallel:Enables parallel processing of operations"
    "jq:JSON processing for configuration files"
    "curl:Network connectivity testing"
    "rsync:Enhanced file synchronization"
)

# Required directories and their purposes
# Format: "directory:description"
REQUIRED_DIRECTORIES=(
    ".:Current working directory (must be writable)"
    "scripts:Scripts directory (must exist and be readable)"
    "docs:Documentation directory (must exist)"
)

# Optional directories that may be created
# Format: "directory:description"
OPTIONAL_DIRECTORIES=(
    "logs:Log file storage"
    "tmp:Temporary file storage"
    "backup:Backup file storage"
)

# File system requirements
MIN_DISK_SPACE_KB=1048576  # 1GB minimum
MIN_INODES=1000           # Minimum available inodes

# ═══════════════════════════════════════════════════════════════════════════════
# COMMAND AND DEPENDENCY VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# Check if a command exists and optionally validate version
validate_command() {
    local command="$1"
    local min_version="$2"
    local component="PREREQUISITE_VALIDATOR"
    
    # Check if command exists
    if ! command -v "$command" >/dev/null 2>&1; then
        handle_dependency_error "$component" "$command" "Install $command using your system's package manager"
        return 1
    fi
    
    log_error_framework "DEBUG" "$component" "Command found: $command"
    
    # Version validation (if required and supported)
    if [[ -n "$min_version" ]]; then
        case "$command" in
            "git")
                local current_version
                if current_version=$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1); then
                    if ! version_compare "$current_version" "$min_version"; then
                        handle_validation_error "$component" "version" "$command version $current_version < required $min_version" "Upgrade $command to version $min_version or higher"
                        return 1
                    fi
                    log_error_framework "DEBUG" "$component" "$command version $current_version meets requirement ($min_version)"
                else
                    log_error_framework "WARNING" "$component" "Could not determine $command version"
                fi
                ;;
            *)
                log_error_framework "DEBUG" "$component" "Version checking not implemented for $command"
                ;;
        esac
    fi
    
    return 0
}

# Compare version strings (returns 0 if version1 >= version2)
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # Simple version comparison for major.minor.patch format
    local IFS='.'
    local -a v1=($version1)
    local -a v2=($version2)
    
    for i in {0..2}; do
        local num1=${v1[i]:-0}
        local num2=${v2[i]:-0}
        
        if [[ $num1 -gt $num2 ]]; then
            return 0
        elif [[ $num1 -lt $num2 ]]; then
            return 1
        fi
    done
    
    return 0  # Versions are equal
}

# Validate all required commands
validate_required_commands() {
    local component="PREREQUISITE_VALIDATOR"
    local failed_commands=()
    
    log_error_framework "INFO" "$component" "Validating required commands..."
    
    for entry in "${REQUIRED_COMMANDS[@]}"; do
        IFS=':' read -r command min_version <<< "$entry"
        if ! validate_command "$command" "$min_version"; then
            failed_commands+=("$command")
        fi
    done
    
    if [[ ${#failed_commands[@]} -gt 0 ]]; then
        log_error_framework "ERROR" "$component" "Missing required commands: ${failed_commands[*]}"
        return 1
    fi
    
    log_error_framework "SUCCESS" "$component" "All required commands are available"
    return 0
}

# Check optional commands and report availability
validate_optional_commands() {
    local component="PREREQUISITE_VALIDATOR"
    local available_optional=()
    local missing_optional=()
    
    log_error_framework "INFO" "$component" "Checking optional commands..."
    
    for entry in "${OPTIONAL_COMMANDS[@]}"; do
        IFS=':' read -r command description <<< "$entry"
        if command -v "$command" >/dev/null 2>&1; then
            available_optional+=("$command")
            log_error_framework "DEBUG" "$component" "Optional command available: $command ($description)"
        else
            missing_optional+=("$command")
            log_error_framework "DEBUG" "$component" "Optional command missing: $command ($description)"
        fi
    done
    
    if [[ ${#available_optional[@]} -gt 0 ]]; then
        log_error_framework "INFO" "$component" "Available optional commands: ${available_optional[*]}"
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_error_framework "INFO" "$component" "Missing optional commands: ${missing_optional[*]} (functionality may be limited)"
    fi
    
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# GIT ENVIRONMENT VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# Comprehensive git environment validation
validate_git_environment() {
    local component="GIT_VALIDATOR"
    local git_issues=()
    
    log_error_framework "INFO" "$component" "Validating git environment..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        handle_git_error "$component" "status" "Not in a git repository" "Initialize git repository or run from within a git repository"
        return 1
    fi
    
    # Get git repository root
    local git_root
    if ! git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
        handle_git_error "$component" "rev-parse" "Cannot determine git repository root" "Check git repository integrity"
        return 1
    fi
    
    log_error_framework "DEBUG" "$component" "Git repository root: $git_root"
    
    # Check git repository integrity
    if ! git fsck --no-progress >/dev/null 2>&1; then
        git_issues+=("Repository integrity check failed")
        log_error_framework "WARNING" "$component" "Git repository integrity issues detected"
    fi
    
    # Check if .git directory is writable
    if [[ ! -w "$git_root/.git" ]]; then
        git_issues+=("Git directory is not writable")
        handle_permission_error "$component" "write" "$git_root/.git" "Fix permissions on .git directory"
    fi
    
    # Check git configuration
    local git_user_name git_user_email
    git_user_name=$(git config user.name 2>/dev/null)
    git_user_email=$(git config user.email 2>/dev/null)
    
    if [[ -z "$git_user_name" || -z "$git_user_email" ]]; then
        git_issues+=("Git user configuration incomplete")
        log_error_framework "WARNING" "$component" "Git user name or email not configured"
        echo -e "${CYAN}  → Configure git user: git config user.name 'Your Name'${NC}"
        echo -e "${CYAN}  → Configure git email: git config user.email 'your.email@example.com'${NC}"
    else
        log_error_framework "DEBUG" "$component" "Git user configured: $git_user_name <$git_user_email>"
    fi
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_error_framework "INFO" "$component" "Repository has uncommitted changes (this is usually fine)"
    else
        log_error_framework "DEBUG" "$component" "Repository working directory is clean"
    fi
    
    # Check for untracked files that might interfere
    local untracked_count
    untracked_count=$(git ls-files --others --exclude-standard | wc -l)
    if [[ $untracked_count -gt 0 ]]; then
        log_error_framework "DEBUG" "$component" "$untracked_count untracked files present"
    fi
    
    # Check git hooks directory
    if [[ -d "$git_root/.git/hooks" && ! -w "$git_root/.git/hooks" ]]; then
        git_issues+=("Git hooks directory is not writable")
        log_error_framework "WARNING" "$component" "Cannot write to git hooks directory"
    fi
    
    # Check for large files that might cause issues
    local large_files
    if large_files=$(find "$git_root" -type f -size +100M -not -path "*/.git/*" 2>/dev/null | head -5); then
        if [[ -n "$large_files" ]]; then
            log_error_framework "INFO" "$component" "Large files detected (>100MB) - operations may be slower"
            if [[ "${VERBOSE_MODE:-false}" == "true" ]]; then
                echo "$large_files" | while read -r file; do
                    log_error_framework "DEBUG" "$component" "Large file: $file"
                done
            fi
        fi
    fi
    
    # Summary
    if [[ ${#git_issues[@]} -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "Git environment validation passed"
        return 0
    else
        log_error_framework "WARNING" "$component" "Git environment issues detected: ${git_issues[*]}"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# FILE SYSTEM VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# Validate file system permissions and space
validate_file_system_permissions() {
    local component="FILESYSTEM_VALIDATOR"
    local fs_issues=()
    
    log_error_framework "INFO" "$component" "Validating file system permissions and space..."
    
    # Check current directory permissions
    if [[ ! -r "." ]]; then
        fs_issues+=("Current directory is not readable")
        handle_permission_error "$component" "read" "." "Fix read permissions on current directory"
    fi
    
    if [[ ! -w "." ]]; then
        fs_issues+=("Current directory is not writable")
        handle_permission_error "$component" "write" "." "Fix write permissions on current directory"
    fi
    
    # Check required directories
    for entry in "${REQUIRED_DIRECTORIES[@]}"; do
        IFS=':' read -r dir description <<< "$entry"
        
        if [[ ! -d "$dir" ]]; then
            fs_issues+=("Required directory missing: $dir")
            handle_file_error "$component" "directory check" "$dir" "Create required directory: mkdir -p $dir"
            continue
        fi
        
        if [[ ! -r "$dir" ]]; then
            fs_issues+=("Cannot read required directory: $dir")
            handle_permission_error "$component" "read" "$dir" "Fix read permissions on $dir"
        fi
        
        # Check write permissions for directories that need it
        if [[ "$description" =~ "writable" && ! -w "$dir" ]]; then
            fs_issues+=("Cannot write to required directory: $dir")
            handle_permission_error "$component" "write" "$dir" "Fix write permissions on $dir"
        fi
        
        log_error_framework "DEBUG" "$component" "Directory OK: $dir ($description)"
    done
    
    # Check disk space
    local available_space_kb
    if available_space_kb=$(df . 2>/dev/null | tail -1 | awk '{print $4}'); then
        if [[ "$available_space_kb" -lt $MIN_DISK_SPACE_KB ]]; then
            fs_issues+=("Insufficient disk space")
            local available_mb=$((available_space_kb / 1024))
            local required_mb=$((MIN_DISK_SPACE_KB / 1024))
            handle_validation_error "$component" "disk space" "Only ${available_mb}MB available, need ${required_mb}MB" "Free up disk space or move to a location with more space"
        else
            local available_gb=$((available_space_kb / 1024 / 1024))
            log_error_framework "DEBUG" "$component" "Disk space OK: ${available_gb}GB available"
        fi
    else
        log_error_framework "WARNING" "$component" "Could not check disk space"
    fi
    
    # Check available inodes (Unix/Linux systems)
    if command -v df >/dev/null 2>&1; then
        local available_inodes
        if available_inodes=$(df -i . 2>/dev/null | tail -1 | awk '{print $4}'); then
            if [[ "$available_inodes" -lt $MIN_INODES ]]; then
                fs_issues+=("Insufficient inodes available")
                handle_validation_error "$component" "inodes" "Only $available_inodes inodes available, need $MIN_INODES" "Clean up files or move to a filesystem with more inodes"
            else
                log_error_framework "DEBUG" "$component" "Inodes OK: $available_inodes available"
            fi
        fi
    fi
    
    # Test file creation and deletion
    local test_file=".$$.housekeeping_test"
    if echo "test" > "$test_file" 2>/dev/null; then
        if [[ -f "$test_file" ]]; then
            rm -f "$test_file" 2>/dev/null || {
                fs_issues+=("Cannot delete test file")
                log_error_framework "WARNING" "$component" "Created test file but cannot delete it: $test_file"
            }
            log_error_framework "DEBUG" "$component" "File creation/deletion test passed"
        else
            fs_issues+=("File creation test failed")
            handle_file_error "$component" "create test file" "$test_file" "Check file system permissions and disk space"
        fi
    else
        fs_issues+=("Cannot create test file")
        handle_file_error "$component" "create test file" "$test_file" "Check write permissions and disk space"
    fi
    
    # Summary
    if [[ ${#fs_issues[@]} -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "File system validation passed"
        return 0
    else
        log_error_framework "ERROR" "$component" "File system issues detected: ${fs_issues[*]}"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# ENVIRONMENT AND SHELL VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# Validate shell environment and variables
validate_shell_environment() {
    local component="SHELL_VALIDATOR"
    local shell_issues=()
    
    log_error_framework "INFO" "$component" "Validating shell environment..."
    
    # Check shell type
    local current_shell
    if current_shell=$(ps -p $$ -o comm= 2>/dev/null); then
        log_error_framework "DEBUG" "$component" "Running in shell: $current_shell"
        
        # Warn about known problematic shells
        case "$current_shell" in
            "sh"|"dash")
                log_error_framework "WARNING" "$component" "Running in basic shell ($current_shell) - some features may not work"
                shell_issues+=("Basic shell detected")
                ;;
            "bash")
                log_error_framework "DEBUG" "$component" "Bash shell detected - full compatibility expected"
                ;;
            "zsh")
                log_error_framework "DEBUG" "$component" "Zsh shell detected - good compatibility expected"
                ;;
            *)
                log_error_framework "INFO" "$component" "Unknown shell ($current_shell) - compatibility uncertain"
                ;;
        esac
    fi
    
    # Check bash version if running in bash
    if [[ -n "$BASH_VERSION" ]]; then
        log_error_framework "DEBUG" "$component" "Bash version: $BASH_VERSION"
        
        # Check for minimum bash version (4.0+)
        local bash_major_version
        bash_major_version=$(echo "$BASH_VERSION" | cut -d. -f1)
        if [[ "$bash_major_version" -lt 4 ]]; then
            shell_issues+=("Old bash version")
            log_error_framework "WARNING" "$component" "Bash version $BASH_VERSION is old - some features may not work"
        fi
    fi
    
    # Check important environment variables
    local required_vars=("PATH" "HOME" "USER")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            shell_issues+=("Missing environment variable: $var")
            log_error_framework "WARNING" "$component" "Environment variable $var is not set"
        else
            log_error_framework "DEBUG" "$component" "Environment variable $var is set"
        fi
    done
    
    # Check PATH for common directories
    local common_paths=("/bin" "/usr/bin" "/usr/local/bin")
    for path_dir in "${common_paths[@]}"; do
        if [[ ":$PATH:" != *":$path_dir:"* ]]; then
            log_error_framework "WARNING" "$component" "Common directory $path_dir not in PATH"
        fi
    done
    
    # Check umask
    local current_umask
    current_umask=$(umask)
    log_error_framework "DEBUG" "$component" "Current umask: $current_umask"
    
    # Warn about overly restrictive umask
    if [[ "$current_umask" == "077" ]]; then
        log_error_framework "WARNING" "$component" "Very restrictive umask ($current_umask) may cause permission issues"
    fi
    
    # Summary
    if [[ ${#shell_issues[@]} -eq 0 ]]; then
        log_error_framework "SUCCESS" "$component" "Shell environment validation passed"
        return 0
    else
        log_error_framework "WARNING" "$component" "Shell environment issues detected: ${shell_issues[*]}"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMPREHENSIVE VALIDATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Validate all prerequisites
validate_all_prerequisites() {
    local component="PREREQUISITE_VALIDATOR"
    local validation_failed=false
    
    log_error_framework "INFO" "$component" "Starting comprehensive prerequisite validation..."
    
    # Initialize error handling if not already done
    if [[ -z "$ERROR_LOG_FILE" ]]; then
        setup_error_handling "logs" "prerequisite_validation.log"
    fi
    
    # Run all validation checks
    echo -e "\n${BOLD}1. Validating Required Commands${NC}"
    if ! validate_required_commands; then
        validation_failed=true
    fi
    
    echo -e "\n${BOLD}2. Checking Optional Commands${NC}"
    validate_optional_commands  # This doesn't fail the overall validation
    
    echo -e "\n${BOLD}3. Validating Git Environment${NC}"
    if ! validate_git_environment; then
        validation_failed=true
    fi
    
    echo -e "\n${BOLD}4. Validating File System${NC}"
    if ! validate_file_system_permissions; then
        validation_failed=true
    fi
    
    echo -e "\n${BOLD}5. Validating Shell Environment${NC}"
    validate_shell_environment  # This doesn't fail the overall validation
    
    # Generate summary
    echo -e "\n${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                        PREREQUISITE VALIDATION SUMMARY                        ${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [[ "$validation_failed" == "true" ]]; then
        log_error_framework "ERROR" "$component" "Prerequisite validation failed - some requirements are not met"
        log_error_framework "INFO" "$component" "Please address the issues above before running housekeeping operations"
        return 1
    else
        log_error_framework "SUCCESS" "$component" "All prerequisite validation checks passed"
        log_error_framework "INFO" "$component" "System is ready for housekeeping operations"
        return 0
    fi
}

# Quick validation for essential prerequisites only
validate_essential_prerequisites() {
    local component="PREREQUISITE_VALIDATOR"
    
    log_error_framework "INFO" "$component" "Running quick validation of essential prerequisites..."
    
    # Check only the most critical requirements
    local essential_commands=("git" "find" "grep" "mv" "rm")
    local failed_commands=()
    
    for command in "${essential_commands[@]}"; do
        if ! command -v "$command" >/dev/null 2>&1; then
            failed_commands+=("$command")
        fi
    done
    
    if [[ ${#failed_commands[@]} -gt 0 ]]; then
        handle_dependency_error "$component" "${failed_commands[*]}" "Install missing essential commands"
        return 1
    fi
    
    # Quick git check
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        handle_git_error "$component" "status" "Not in a git repository" "Run from within a git repository"
        return 1
    fi
    
    # Quick write permission check
    if [[ ! -w "." ]]; then
        handle_permission_error "$component" "write" "." "Fix write permissions on current directory"
        return 1
    fi
    
    log_error_framework "SUCCESS" "$component" "Essential prerequisites validated"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALIZATION CHECK
# ═══════════════════════════════════════════════════════════════════════════════

# Verify that the prerequisite validation module is properly loaded
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced
    log_error_framework "DEBUG" "PREREQUISITE_VALIDATOR" "Prerequisite validation module loaded successfully"
else
    # Script is being executed directly
    echo "Prerequisite Validation Module for Housekeeping System"
    echo "This script should be sourced, not executed directly."
    echo "Usage: source scripts/lib/prerequisite_validation.sh"
    exit 1
fi
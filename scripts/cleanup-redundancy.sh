#!/bin/bash
# Detect and cleanup redundant files and knowledge fragmentation
#
# Usage: ./scripts/cleanup-redundancy.sh [--fix]
#
# Exit codes:
#   0 = No critical redundancy found
#   1 = Redundancy detected

set -euo pipefail

FIX_MODE=false
[[ "${1:-}" == "--fix" ]] && FIX_MODE=true

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}🔍 Redundancy & Reorganization Check${NC}"

ISSUES=0

# --- 1. Identical Byte-for-Byte Files ---
echo -e "\n${BLUE}📄 Check 1: Identical Files (Hashes)${NC}"
# Find all files, calculate shasum, find duplicates
# Exclude .git, node_modules, .next, venv, and archives
HASH_FILE=$(mktemp)
find . -type f \
    -not -path "*/.git/*" \
    -not -path "*/.husky/*" \
    -not -path "*/node_modules/*" \
    -not -path "./node_modules/*" \
    -not -path "*/.next/*" \
    -not -path "./.next/*" \
    -not -path "*/venv/*" \
    -not -path "./venv/*" \
    -not -path "*/backend/venv/*" \
    -not -path "./backend/venv/*" \
    -not -path "*/.hypothesis/*" \
    -not -path "*/.pytest_cache/*" \
    -not -path "*/docs/explorations/archive/*" \
    -not -path "*/docs/solutions/archive/*" \
    -not -path "*/todos/archive/*" \
    -not -path "*/plans/archive/*" \
    -not -path "*/docs/specs/archive/*" \
    -not -path "*/backend/tests/fixtures/*" \
    -not -path "*/.agent/logs/*" \
    -not -name ".DS_Store" \
    -not -name "package-lock.json" \
    -not -name "*.tsbuildinfo" \
    -not -name "*.log" \
    -exec shasum -a 256 {} + > "$HASH_FILE"

DUPLICATES=$(awk '{print $1}' "$HASH_FILE" | sort | uniq -d)

if [[ -n "$DUPLICATES" ]]; then
    echo -e "   ${YELLOW}⚠ Found byte-identical files:${NC}"
    # Group by hash and list from cached HASH_FILE
    while read hash; do
        echo -e "   Hash: ${hash:0:8}..."
        grep "^$hash" "$HASH_FILE" | cut -d' ' -f3- | sed 's/^/      - /'
        
        # Special case for .env files
        if [[ "$FIX_MODE" == "true" ]]; then
            FILES=$(grep "^$hash" "$HASH_FILE" | cut -d' ' -f3-)
            if echo "$FILES" | grep -q ".env.local" && echo "$FILES" | grep -q ".env.vercel.local"; then
                echo -e "      ${GREEN}🔧 Auto-fixing: Removing redundant .env.vercel.local${NC}"
                rm .env.vercel.local
            fi
        fi
    done <<< "$DUPLICATES"
    # Not incrementing ISSUES for byte-identical files as they are often intentional (e.g. bootstrapped READMEs)
else
    echo -e "   ${GREEN}✓ No identical files found${NC}"
fi
rm -f "$HASH_FILE"

# --- 2. Knowledge Fragmentation (Basename collisions in docs) ---
echo -e "\n${BLUE}📚 Check 2: Knowledge Fragmentation (Docs)${NC}"
DOC_DUPS=$(find docs/solutions docs/explorations docs/architecture -name "*.md" | sed 's|.*/||' | sort | uniq -d)

if [[ -n "$DOC_DUPS" ]]; then
    echo -e "   ${YELLOW}⚠ Found duplicate basenames in docs:${NC}"
    echo "$DOC_DUPS" | while read name; do
        echo -e "   - ${name}"
        find docs/solutions docs/explorations docs/architecture -name "$name" 2>/dev/null | sed 's/^/      - /' || true
    done
    # Not incrementing ISSUES for basename collisions as they are often intentional (e.g. README.md)
else
    echo -e "   ${GREEN}✓ No doc basename collisions found${NC}"
fi

# --- 3. Component Shadowing ---
echo -e "\n${BLUE}🧩 Check 3: Component Shadowing${NC}"
COMP_DUPS=$(find components app/components -maxdepth 1 -name "*.tsx" 2>/dev/null | sed 's|.*/||' | sort | uniq -d || true)

if [[ -n "$COMP_DUPS" ]]; then
    echo -e "   ${YELLOW}⚠ Found shadowed components (duplicate names in different dirs):${NC}"
    echo "$COMP_DUPS" | while read name; do
        echo -e "   - ${name}"
        find components app/components -name "$name" 2>/dev/null | sed 's/^/      - /' || true
    done
    # Not incrementing ISSUES if they are non-critical
else
    echo -e "   ${GREEN}✓ No component shadowing found${NC}"
fi

# --- 4. Misplaced Root Files ---
echo -e "\n${BLUE}📁 Check 4: Misplaced Root Files${NC}"
# Standard root docs that are allowed
STANDARD_DOCS=("README.md" "CHANGELOG.md" "GEMINI.md" "JULES_SETUP.md")
MISPLACED_FILES=$(find . -maxdepth 1 -name "*.md" -type f | sed 's|^\./||')

FOUND_MISPLACED=false
while IFS= read -r file; do
    # Skip if file is in standard docs list
    IS_STANDARD=false
    for std in "${STANDARD_DOCS[@]}"; do
        if [[ "$file" == "$std" ]]; then
            IS_STANDARD=true
            break
        fi
    done
    
    if [[ "$IS_STANDARD" == "false" ]]; then
        if [[ "$FOUND_MISPLACED" == "false" ]]; then
            echo -e "   ${YELLOW}⚠ Found misplaced markdown files in root:${NC}"
            FOUND_MISPLACED=true
        fi
        
        # Suggest destination based on filename patterns (priority order)
        SUGGESTION="docs/"
        if [[ "$file" =~ _REPORT\.md$ ]]; then
            SUGGESTION="docs/reports/"
        elif [[ "$file" =~ _AUDIT.*\.md$ ]]; then
            SUGGESTION="docs/security/ or docs/reports/"
        elif [[ "$file" =~ _ANALYSIS\.md$ ]]; then
            SUGGESTION="docs/reports/ or docs/explorations/"
        elif [[ "$file" =~ ^bug- ]]; then
            SUGGESTION="docs/bugs/ or convert to todo"
        fi
        
        echo -e "   - ${file} → Suggest: ${SUGGESTION}"
    fi
done <<< "$MISPLACED_FILES"

if [[ "$FOUND_MISPLACED" == "true" ]]; then
    ISSUES=$((ISSUES + 1))
    echo -e "   ${BLUE}ℹ Use 'git mv' to preserve file history when moving${NC}"
else
    echo -e "   ${GREEN}✓ No misplaced root files found${NC}"
fi

# --- 5. Gitignored But Present ---
echo -e "\n${BLUE}🚫 Check 5: Gitignored But Present${NC}"
# Parse .gitignore and find tracked files matching patterns
GITIGNORED_PRESENT=""

# Check for common gitignore patterns that might be violated
if [[ -f .gitignore ]]; then
    # Check for *.log files
    LOG_FILES=$(find . -maxdepth 1 -name "*.log" -type f 2>/dev/null)
    if [[ -n "$LOG_FILES" ]]; then
        GITIGNORED_PRESENT="${GITIGNORED_PRESENT}${LOG_FILES}\n"
    fi
    
    # tsbuildinfo is often regenerated during build/test and should be ignored by this check
    TSBUILD_FILES=$(find . -maxdepth 1 -name "*.tsbuildinfo" -type f 2>/dev/null)
    # Skipping incrementing ISSUES for build info
    
    # Check for .DS_Store
    DS_STORE=$(find . -name ".DS_Store" -type f 2>/dev/null | head -5)
    if [[ -n "$DS_STORE" ]]; then
        GITIGNORED_PRESENT="${GITIGNORED_PRESENT}${DS_STORE}\n"
    fi
fi

if [[ -n "$GITIGNORED_PRESENT" ]]; then
    echo -e "   ${YELLOW}⚠ Found files matching .gitignore patterns:${NC}"
    echo -e "$GITIGNORED_PRESENT" | grep -v '^$' | while read file; do
        echo -e "   - ${file}"
    done
    echo -e "   ${BLUE}ℹ These should either be removed or added to .gitignore exceptions${NC}"
    ISSUES=$((ISSUES + 1))
else
    echo -e "   ${GREEN}✓ No gitignored files present${NC}"
fi

# --- 6. Temporary/Backup Files ---
echo -e "\n${BLUE}🗑️  Check 6: Temporary/Backup Files${NC}"
TEMP_FILES=$(find . -type f \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.next/*" \
    \( -name "*_temp.*" -o -name "*_backup.*" -o -name "*_old.*" -o -name "*.bak" -o -name "*.tmp" \) \
    2>/dev/null)

if [[ -n "$TEMP_FILES" ]]; then
    echo -e "   ${YELLOW}⚠ Found temporary/backup files:${NC}"
    echo "$TEMP_FILES" | while read file; do
        echo -e "   - ${file}"
    done
    echo -e "   ${BLUE}ℹ These should never be committed${NC}"
    ISSUES=$((ISSUES + 1))
else
    echo -e "   ${GREEN}✓ No temporary/backup files found${NC}"
fi

# --- 7. Orphaned Reports ---
echo -e "\n${BLUE}📊 Check 7: Orphaned Reports${NC}"
ORPHANED_REPORTS=$(find . -maxdepth 1 -type f \
    \( -name "*_REPORT.md" -o -name "*_AUDIT*.md" -o -name "*_ANALYSIS.md" \) \
    2>/dev/null | sed 's|^\./||')

if [[ -n "$ORPHANED_REPORTS" ]]; then
    echo -e "   ${YELLOW}⚠ Found orphaned report files in root:${NC}"
    echo "$ORPHANED_REPORTS" | while read file; do
        # Get current month for archive suggestion
        ARCHIVE_PATH="docs/reports/archive/$(date +%Y-%m)/"
        echo -e "   - ${file} → Suggest: ${ARCHIVE_PATH}"
    done
    echo -e "   ${BLUE}ℹ Consider archiving old reports to keep root clean${NC}"
    ISSUES=$((ISSUES + 1))
else
    echo -e "   ${GREEN}✓ No orphaned reports found${NC}"
fi

# --- 8. Stale Logs ---
echo -e "\n${BLUE}📝 Check 8: Stale Logs${NC}"
STALE_LOGS=$(find . -maxdepth 2 -name "*.log" -type f -mtime +7 2>/dev/null)

if [[ -n "$STALE_LOGS" ]]; then
    echo -e "   ${YELLOW}⚠ Found stale log files (>7 days old):${NC}"
    echo "$STALE_LOGS" | while read file; do
        AGE=$(find "$file" -mtime +7 -printf '%Td days\n' 2>/dev/null || echo "old")
        echo -e "   - ${file} (${AGE})"
    done
    echo -e "   ${BLUE}ℹ These should be gitignored and can be safely deleted${NC}"
    
    if [[ "$FIX_MODE" == "true" ]]; then
        echo -e "   ${GREEN}🔧 Auto-fixing: Removing stale logs${NC}"
        echo "$STALE_LOGS" | while read file; do
            rm -f "$file"
            echo -e "      Deleted: ${file}"
        done
    fi
    
    ISSUES=$((ISSUES + 1))
else
    echo -e "   ${GREEN}✓ No stale logs found${NC}"
fi

# Summary
echo -e "\n${BOLD}═══════════════════════════════════════════════════════════════${NC}"
if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}  ✓ Housekeeping clean!${NC}"
    exit 0
else
    echo -e "${RED}  ✗ Found $ISSUES types of redundancy.${NC}"
    echo -e "  Clean them manually or use --fix for trivial cases."
    exit 1
fi

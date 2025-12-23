#!/bin/bash

# scripts/validate-folder-docs.sh
# Validates documentation freshness and structure for key directories.

CORE_FOLDERS=(
    "src"
    "scripts"
    "docs/solutions"
    "docs/architecture"
    ".agent/workflows"
)

STRICT_MODE=false
TARGET_FOLDERS=("${CORE_FOLDERS[@]}")

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --folder)
            TARGET_FOLDERS=("$2")
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

EXIT_CODE=0
TODAY=$(date +%Y-%m-%d)

echo "🔍 Validating hierarchical documentation..."

for folder in "${TARGET_FOLDERS[@]}"; do
    if [ ! -d "$folder" ]; then
        # Silent skip if folder doesn't exist (optional features)
        # But warn if it's a core one that should exist
        if [[ "$folder" == "app/components" ]]; then
             echo "⚠️  Skipping non-existent core folder: $folder"
        fi
        continue
    fi

    README="$folder/README.md"
    
    # Check for README existence
    if [ ! -f "$README" ]; then
        echo "❌ Missing README.md in: $folder"
        EXIT_CODE=1
        continue
    fi

    # Check for required sections
    MISSING_SECTIONS=()
    grep -q "## Purpose" "$README" || MISSING_SECTIONS+=("Purpose")
    grep -qE "## (Key )?Components" "$README" || MISSING_SECTIONS+=("Components")
    grep -q "## Component Details" "$README" || MISSING_SECTIONS+=("Component Details")
    grep -q "## Changelog" "$README" || MISSING_SECTIONS+=("Changelog")

    if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
        echo "❌ README.md in $folder is missing sections: ${MISSING_SECTIONS[*]}"
        EXIT_CODE=1
    else
        # Check for placeholders
        if grep -q "{Brief 1-sentence description}" "$README" || grep -q "{filename}" "$README"; then
            echo "⚠️  README.md in $folder still contains template placeholders."
            # Not failing on placeholders yet, but could be P2/P3
        else
            # ---------------------------------------------------------
            # Changelog Gap Detection
            # ---------------------------------------------------------
            # 1. Get last git commit date for the folder, excluding README itself
            #    (We care if code changed, not if docs changed)
            last_code_change=$(git log -1 --format=%cd --date=short -- "$folder" ":(exclude)$README" 2>/dev/null)
            
            # 2. Get latest date from Changelog
            #    Looking for lines like "### 2023-10-27" or "### 2023-10-27 - Verified"
            last_changelog_entry=$(grep -E "^### [0-9]{4}-[0-9]{2}-[0-9]{2}" "$README" | head -n 1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || true)

            if [[ -n "$last_code_change" && -n "$last_changelog_entry" ]]; then
                # Compare dates strings
                # If code change > changelog entry, then docs are stale
                if [[ "$last_code_change" > "$last_changelog_entry" ]]; then
                     echo "⚠️  Changelog stale in $folder"
                     echo "      Last code change: $last_code_change"
                     echo "      Last changelog:   $last_changelog_entry"
                     # Optional: make this a failure in the future
                     EXIT_CODE=1
                else
                     echo "✅ $folder/README.md is valid (Freshness: OK)."
                fi
            elif [[ -z "$last_code_change" ]]; then
                # No code changes recorded in git for this folder yet
                echo "✅ $folder/README.md is valid."
            else
                echo "✅ $folder/README.md is valid (No changelog dates found)."
            fi

            # 3. Check for uncommitted changes
            # We combine multiple detection methods to ensure no code changes skip documentation:
            # - git diff: Tracked modified files
            # - git diff --cached: Staged files
            # - git ls-files: Untracked files
            # This ensures that even if a developer stages files but hasn't updated docs, they are caught.
            uncommitted_changes=$( (git diff --name-only -- "$folder" 2>/dev/null || true; \
                                   git diff --cached --name-only -- "$folder" 2>/dev/null || true; \
                                   git ls-files --others --exclude-standard -- "$folder" 2>/dev/null || true) \
                                   | grep -v "^$README$" | sort -u || true)

            if [[ -n "$uncommitted_changes" ]]; then
                # If there are uncommitted code changes, we expect today's date in the changelog
                if [[ "$last_changelog_entry" != "$TODAY" ]]; then
                    echo "❌ Uncommitted changes in $folder but no changelog entry for today ($TODAY)."
                    echo "      Uncommitted files:"
                    echo "$uncommitted_changes" | sed 's/^/      /'
                    EXIT_CODE=1
                else
                    echo "✅ $folder/README.md has today's entry for uncommitted changes."
                fi
            fi
        fi
    fi

    # Check for undocumented components (files without entries in README)
    # Using while loop to safely handle filenames with spaces
    find "$folder" -maxdepth 1 -type f | grep -E "\.(tsx|ts|js)$" | grep -v "\.test\." | while read -r filepath; do
        file=$(basename "$filepath")
        
        # Check for matching entry in README (expecting `filename.ext`)
        if ! grep -q "\`$file\`" "$README"; then
            echo "⚠️  Documented component missing entry: $file in $folder/README.md"
        fi

        # Check for matching detailed description if file is in table
        if grep -q "\`$file\`" "$README"; then
            if ! grep -q "###.*\`$file\`" "$README" && ! grep -q "###.*$file" "$README"; then
                 echo "⚠️  Component missing detailed description section: $file in $folder/README.md"
            fi
        fi
    done
done

if [ $EXIT_CODE -eq 0 ]; then
    echo "✨ All documentation checks passed!"
else
    echo "❌ Some documentation checks failed."
fi

exit $EXIT_CODE

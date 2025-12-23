#!/bin/bash

# scripts/validate-codebase-map.sh
# Validates that the codebase map accurately reflects the project structure.

MAP_FILE="docs/architecture/codebase-map.md"
EXIT_CODE=0

echo "🔍 Validating Codebase Map: $MAP_FILE"

if [ ! -f "$MAP_FILE" ]; then
    echo "❌ Codebase map not found at $MAP_FILE"
    exit 1
fi

# 1. Validate Links in the Navigation Table
echo "--- Checking Navigation Table Links ---"
# Extract links from the table (lines starting with | and containing [path](link))
# Pattern: [label](../../path/to/README.md)
links=$(grep -oE "\[[^]]+\]\([^)]+\)" "$MAP_FILE")

while read -r link_entry; do
    # Extract path from link: [label](path)
    # We remove [label]( and the trailing )
    path=$(echo "$link_entry" | sed -E 's/\[[^]]+\]\(([^)]+)\)/\1/')
    
    # Resolve relative path from docs/architecture/
    # If it starts with ../../, it's from the root
    if [[ "$path" == "../../"* ]]; then
        actual_path="${path#../../}"
    else
        # Internal doc link or something else
        continue
    fi
    
    if [ ! -f "$actual_path" ]; then
        echo "❌ Broken link in map: $link_entry (Resolved to: $actual_path)"
        EXIT_CODE=1
    else
        echo "✅ Valid link: $actual_path"
    fi
done <<< "$links"

# 2. Check for Unmapped Major Folders
echo ""
echo "--- Checking for Unmapped Major Folders ---"
# Check app/ for folders that aren't mentioned in the map
for folder in app/*/; do
    folder_name=$(basename "$folder")
    # Skip directories like .next, node_modules if they exist (though usually ignored)
    [[ "$folder_name" == "."* ]] && continue
    
    # Check if folder name is mentioned in the map file
    if ! grep -q "$folder_name" "$MAP_FILE"; then
        echo "⚠️  Unmapped folder detected in app/: $folder_name"
        # We don't fail on this yet, but we warn.
    fi
done

# Check backend/ for internal structure mention
if ! grep -q "backend/routers" "$MAP_FILE" && ! grep -q "backend/services" "$MAP_FILE"; then
    echo "⚠️  Backend internal services/routers are not detailed in the map."
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✨ Codebase Map validation passed (with warnings for missing folders)."
else
    echo ""
    echo "❌ Codebase Map validation failed."
fi

exit $EXIT_CODE

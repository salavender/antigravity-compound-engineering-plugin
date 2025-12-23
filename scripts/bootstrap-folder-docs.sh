#!/bin/bash

# scripts/bootstrap-folder-docs.sh
# Scaffolds a README.md for a given folder using the documentation template.

TEMPLATE="docs/templates/folder-readme-template.md"
TARGET_FOLDER=$1

if [ -z "$TARGET_FOLDER" ]; then
    echo "Usage: $0 {folder_path}"
    exit 1
fi

if [ ! -d "$TARGET_FOLDER" ]; then
    echo "Error: Directory $TARGET_FOLDER does not exist."
    exit 1
fi

README_PATH="${TARGET_FOLDER%/}/README.md"

if [ -f "$README_PATH" ]; then
    echo "README.md already exists at $README_PATH. Refusing to overwrite."
    exit 0
fi

# Get folder name for replacement
FOLDER_NAME=$(basename "$TARGET_FOLDER")

# Create initial README from template
cp "$TEMPLATE" "$README_PATH"

# Replace {Folder Name} with actual name
# Using a different delimiter for sed because path might contain slashes
sed -i '' "s/{Folder Name}/$FOLDER_NAME/g" "$README_PATH"

# Find components (tsx/ts/js files, excluding tests and README)
COMPONENTS=$(ls "$TARGET_FOLDER" | grep -E "\.(tsx|ts|js)$" | grep -v "\.test\." | grep -v "README.md" | sort)

# Build the components table content
TABLE_CONTENT=""
while read -r COMP; do
    if [ -n "$COMP" ]; then
        TABLE_CONTENT="${TABLE_CONTENT}| \`$COMP\` | | \`✅ Stable\` |"$'\n'
    fi
done <<< "$COMPONENTS"

# Replace {filename} entry in template with actual list
# We look for the line containing "{filename}" and replace it with our table content
if [ -n "$TABLE_CONTENT" ]; then
    # Create a temporary file for the table content to avoid escape hell with sed
    echo "$TABLE_CONTENT" > table_tmp.txt
    
    # Use sed to find the line with {filename} and replace it with the contents of table_tmp.txt
    # This is a bit tricky with BSD sed on macOS
    sed -i '' -e "/{filename}/r table_tmp.txt" -e "/{filename}/d" "$README_PATH"
    
    rm table_tmp.txt
fi

echo "✅ Bootstrapped documentation at $README_PATH"

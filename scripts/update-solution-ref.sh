#!/bin/bash
# Update solution reference date
# Usage: ./scripts/update-solution-ref.sh file1.md file2.md ...

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 file1.md file2.md ..."
    exit 1
fi

# Log usage
mkdir -p .agent/logs
echo "$(date +%Y-%m-%dT%H:%M:%S) update-solution-ref $*" >> .agent/logs/compound_usage.log

today=$(date +%Y-%m-%d)
count=0

for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "⚠️  File not found: $file"
        continue
    fi

    # Auto-add last_referenced field if missing (insert before tags: line)
    if ! grep -q "^last_referenced:" "$file"; then
        if grep -q "^tags:" "$file"; then
            sed -i '' '/^tags:/i\
last_referenced: ""
' "$file"
            echo "📝 Added last_referenced field to $file"
        else
            echo "⚠️  No tags field found in $file, skipping"
            continue
        fi
    fi

    # Update last_referenced field
    sed -i '' "s/^last_referenced: .*/last_referenced: \"$today\"/" "$file"
    echo "✅ Updated $file"
    count=$((count + 1))
done

echo "Updated $count files to $today"

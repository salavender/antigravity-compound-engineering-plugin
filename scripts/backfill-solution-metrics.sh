#!/bin/bash
# Backfill baseline metrics for existing solutions
# Sets last_referenced to file creation date or git commit date if missing

count=0
updated=0

echo "🔍 Scanning solutions for missing last_referenced..."

# Find all solution files
while read -r file; do
    count=$((count + 1))
    
    # Check if last_referenced exists
    if ! grep -q "^last_referenced:" "$file"; then
        echo "📝 Updating $file..."
        
        # Get creation date from git log (fallback to today)
        created_date=$(git log --diff-filter=A --follow --format=%aI -1 "$file" | cut -d'T' -f1)
        if [ -z "$created_date" ]; then
            created_date=$(date +%Y-%m-%d)
        fi
        
        # Add last_referenced field before tags
        if grep -q "^tags:" "$file"; then
             sed -i '' "/^tags:/i\\
last_referenced: \"$created_date\"\\
" "$file"
             updated=$((updated + 1))
        # If no tags, try to insert before second ---
        elif grep -c "^---$" "$file" | grep -q "2"; then
             # Insert before the second instance of ---
             # This is a bit tricky with sed, simpler to append to end of frontmatter if we can find line number
             # Assuming frontmatter ends at second ---
             end_line=$(grep -n "^---$" "$file" | sed -n '2p' | cut -d: -f1)
             if [ -n "$end_line" ]; then
                sed -i '' "${end_line}i\\
last_referenced: \"$created_date\"\\
" "$file"
                updated=$((updated + 1))
             else
                echo "⚠️  Could not find end of frontmatter in $file, skipping"
             fi
        else
            echo "⚠️  No tags field or valid frontmatter in $file, skipping"
        fi
    fi
done < <(find docs/solutions -name "*.md")

echo "✅ Scanned $count files, backfilled $updated solutions."

#!/bin/bash
# Rotate logs older than 12 weeks
# Usage: ./scripts/rotate-logs.sh

LOG_DIR=".agent/logs"
RETENTION_DAYS=90

# Check if log dir exists
if [ ! -d "$LOG_DIR" ]; then
    exit 0
fi

echo "🔄 Rotating logs older than $RETENTION_DAYS days..."

# Calculate cutoff date in ISO8601 format
# MacOS date command syntax
cutoff=$(date -v-${RETENTION_DAYS}d +%Y-%m-%dT%H:%M:%SZ)

count=0

# Find all usage logs
find "$LOG_DIR" -name "*_usage.log" -type f | while read -r file; do
    tmp=$(mktemp)
    
    # Use awk to filter lines
    # Assumes format: TIMESTAMP|...
    # Compares string timestamp >= cutoff
    awk -v cutoff="$cutoff" '$1 >= cutoff' "$file" > "$tmp"
    
    # Check if lines were removed
    orig_lines=$(wc -l < "$file" | tr -d ' ')
    new_lines=$(wc -l < "$tmp" | tr -d ' ')
    
    if [ "$orig_lines" -ne "$new_lines" ]; then
        mv "$tmp" "$file"
        diff=$((orig_lines - new_lines))
        echo "  - Pruned $diff lines from $file"
        count=$((count + 1))
    else
        rm "$tmp"
    fi
done

if [ "$count" -eq 0 ]; then
    echo "  (No logs needed rotation)"
fi

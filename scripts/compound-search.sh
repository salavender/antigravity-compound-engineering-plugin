#!/bin/bash
# Fuzzy search knowledge base and generate update command
# Usage: ./scripts/compound-search.sh "term1" "term2" ...

set -e

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 \"search term\" \"another term\""
    exit 1
fi

# Log usage
mkdir -p .agent/logs
echo "$(date +%Y-%m-%dT%H:%M:%S) compound-search $*" >> .agent/logs/compound_usage.log

echo "🔎 Searching Knowledge Base..."
echo ""

# Create temp file for results
results_file=$(mktemp)

# Search for each term
for term in "$@"; do
    grep -rli "$term" docs/solutions/ docs/explorations/ docs/decisions/ >> "$results_file" 2>/dev/null
done

# Deduplicate and sort
sort -u "$results_file" -o "$results_file"

file_count=$(wc -l < "$results_file" | tr -d ' ')

if [ "$file_count" -eq 0 ]; then
    echo "No matching solutions found."
    rm "$results_file"
    exit 0
fi


# Output Markdown Table
echo "| Solution | Relevance | Action |"
echo "|----------|-----------|--------|"

while IFS= read -r file; do
    # Extract title from file (first H1)
    title=$(grep -m 1 "^# " "$file" | sed 's/^# //')
    basename=$(basename "$file")
    echo "| [$title]($file) | ⭐️ Match | Referencing |"
done < "$results_file"

echo ""
echo "---"
echo "⬇️  **Copy this command to tracking usage:**"
echo ""
echo '```bash'
echo -n "./scripts/update-solution-ref.sh"
while IFS= read -r file; do
    echo -n " $file"
done < "$results_file"
echo ""
echo '```'

rm "$results_file"

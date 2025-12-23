#!/bin/bash
# Suggest new skill opportunities based on solution patterns
# Usage: ./scripts/suggest-skills.sh
#
# Analyzes solution tags and suggests new skills when patterns emerge.
# This script identifies capability gaps but does not auto-create todos
# to ensure human-in-the-loop validation of new skills.

set -euo pipefail

# Configuration
THRESHOLD=3  # Minimum solutions tagged to suggest a skill
LOG_FILE=".agent/logs/skill_suggestions.csv"

# Skill Validation Criteria:
# A tag is skill-worthy if it represents:
# 1. Domain-specific knowledge (e.g., supabase, react-hooks, mobile)
# 2. Reusable procedures (e.g., testing, debugging)
# 3. Concrete capabilities (NOT abstract philosophies like "automation")
#
# Tags that are NOT skill-worthy:
# - Philosophy tags: compound-learning, automation
# - Principle tags: single-source-of-truth, drift
# - Category tags: workflows, documentation

# Initialize log file with header if it doesn't exist
if [[ ! -f "$LOG_FILE" ]]; then
    mkdir -p .agent/logs
    echo "timestamp,tag,count,related_files_count" > "$LOG_FILE"
fi

# Log usage
mkdir -p .agent/logs
echo "$(date +%Y-%m-%dT%H:%M:%S) suggest-skills" >> .agent/logs/compound_usage.log

echo "🔍 Skill Opportunity Audit..."
echo "Analyzing knowledge base for patterns..."

# Temp files
tags_file=$(mktemp)
counts_file=$(mktemp)

# 1. Extract all tags from solutions (skipping existing skills)
# grep tags from docs/solutions, clean up yaml syntax, sort
grep -r "^  - " docs/solutions/ | grep -v "critical-patterns.md" | sed 's/^.*- //' | sed 's/"//g' | sed "s/'//g" | sort > "$tags_file"

# 2. Count occurrences
uniq -c "$tags_file" | sort -nr > "$counts_file"

echo ""
found_suggestion=0

# 3. Analyze top tags (count >= THRESHOLD)
while read -r count tag; do
    if [ "$count" -lt "$THRESHOLD" ]; then
        break
    fi
    
    # Check if a skill already exists for this tag (fuzzy match)
    # Check if directory exists in skills/ OR if any SKILL.md contains the tag
    if [ -d "skills/$tag" ] || grep -rqi "$tag" skills/*/SKILL.md 2>/dev/null; then
        continue 
    fi

    # Group related files for finding context
    related_files=$(grep -l "$tag" docs/solutions/**/*.md 2>/dev/null | head -n 3)
    
    echo "💡 Potential Skill: \"$tag\""
    echo "   - Frequency: $count solutions tagged"
    echo "   - Reference Solutions:"
    for file in $related_files; do
        title=$(grep -m 1 "^# " "$file" | sed 's/^# //')
        echo "     * $title"
    done
    
    # Only report if todo doesn't already exist
    # Robust pattern to match create-{tag}-skill.md or create-{tag}-agent-skill.md
    if ls todos/*-create-*${tag}*skill*.md 2>/dev/null | grep -q .; then
        echo "   - ℹ️  Todo already exists for this skill"
    else
        echo "   - Action: Run /create-agent-skill to formalize this capability."
    fi
    
    echo ""
    found_suggestion=1

    # Persist suggestion to log file for trend analysis
    echo "$(date +%Y-%m-%dT%H:%M:%S),${tag},${count},${count}" >> "$LOG_FILE"

done < "$counts_file"

if [ "$found_suggestion" -eq 0 ]; then
    echo "✅ No new skill clusters detected (all high-frequency patterns are covered)."
fi

# Cleanup
rm "$tags_file" "$counts_file"

# Exit 0 = success
exit 0

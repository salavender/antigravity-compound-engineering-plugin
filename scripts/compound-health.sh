#!/bin/bash
# Compound System Health Dashboard
# Usage: ./scripts/compound-health.sh

set -e

echo "🏥 COMPOUND SYSTEM HEALTH"
echo "========================"

# Metrics Calculation
solution_count=$(ls docs/solutions/**/*.md 2>/dev/null | wc -l | tr -d ' ')
exploration_count=$(ls docs/explorations/*.md 2>/dev/null | grep -v template | grep -v schema | wc -l | tr -d ' ')
pattern_count=$(grep -c "^## " docs/solutions/patterns/critical-patterns.md 2>/dev/null || echo 0)
todo_count=$(ls todos/*.md 2>/dev/null | grep -v template | wc -l | tr -d ' ')

# Coverage (Solutions with last_referenced set)
# Note: This is an approximation using grep
ref_count=$(grep -l "last_referenced: \"20" docs/solutions/**/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$solution_count" -gt 0 ]; then
    coverage=$(( (ref_count * 100) / solution_count ))
else
    coverage=0
fi

# Usage Metrics (Log lines in last 7 days)
log_file=".agent/logs/compound_usage.log"
if [ -f "$log_file" ]; then
    usage_count=$(wc -l < "$log_file" | tr -d ' ')
    search_count=$(grep -c "compound-search" "$log_file")
    update_count=$(grep -c "update-solution-ref" "$log_file")
else
    usage_count=0
    search_count=0
    update_count=0
fi

# Quality Metrics
# 1. Todo Quality
total_todo_score=0
count_todo_scored=0
# Loop through todos, avoid template
for todo in todos/*.md; do
    [ -e "$todo" ] || continue
    [[ "$(basename "$todo")" == "todo-template.md" ]] && continue
    
    # Capture score (first part before /)
    score=$(./scripts/score-todo.sh "$todo" 2>/dev/null | cut -d'/' -f1)
    if [ -n "$score" ]; then
        total_todo_score=$((total_todo_score + score))
        count_todo_scored=$((count_todo_scored + 1))
    fi
done

if [ "$count_todo_scored" -gt 0 ]; then
    avg_todo_quality=$((total_todo_score / count_todo_scored))
else
    avg_todo_quality=0
fi

# 2. Zombie Solutions (Ref < 90 days ago)
# Simple string comparison for ISO dates
cutoff_date=$(date -v-90d +%Y-%m-%d 2>/dev/null || date -d "90 days ago" +%Y-%m-%d)
zombie_count=0

# Iterate solutions to check date
# Note: This might be slow if 1000s of files. For <100, it's fine.
while read -r file; do
    # Extract date
    last_ref=$(grep "^last_referenced:" "$file" | cut -d'"' -f2)
    
    # If referenced and date is valid (starts with 20)
    if [[ "$last_ref" =~ ^20 ]]; then
        if [[ "$last_ref" < "$cutoff_date" ]]; then
            zombie_count=$((zombie_count + 1))
        fi
    fi
done < <(find docs/solutions -name "*.md")

# Output Dashboard
echo "Solutions: $solution_count"
echo "Patterns:  $pattern_count"
echo "Explorations: $exploration_count"
echo "Active Todos: $todo_count"
echo "Hit Rate:  $coverage% ($ref_count/$solution_count referenced)"
echo "Quality:   $avg_todo_quality/10 (Avg Todo Score)"
if [ "$zombie_count" -gt 0 ]; then
    echo "Zombies:   $zombie_count (Stale >90d)"
fi
echo "" 

echo "📊 Usage (All Time)"
echo "- Total Invocations: $usage_count"
echo "- Searches: $search_count"
echo "- Relation Updates: $update_count"
echo ""

# Instrumentation Metrics
echo "📈 Workflow & Skill Activity (Last 30 Days)"
workflow_log=".agent/logs/workflow_usage.log"
skill_log=".agent/logs/skill_usage.log"

if [ -f "$workflow_log" ]; then
    echo "Top Workflows:"
    # Parse timestamp (ISO8601), filter last 30 days (approx), sort by workflow name
    # Simply showing top 5 by count for now to avoid date math complexity in bash
    cut -d'|' -f2 "$workflow_log" | sort | uniq -c | sort -nr | head -5 | awk '{print "  - " $2 ": " $1}'
else
    echo "  (No workflow logs found)"
fi

if [ -f "$skill_log" ]; then
    echo "Top Skills:"
    cut -d'|' -f2 "$skill_log" | sort | uniq -c | sort -nr | head -5 | awk '{print "  - " $2 ": " $1}'
else
    echo "  (No skill logs found)"
fi
echo ""

echo "⚠️ Warnings"
if [ "$coverage" -lt 10 ]; then
    echo "- CRITICAL: Low hit rate (<10%). Knowledge is static."
fi
if [ "$avg_todo_quality" -lt 5 ]; then
    echo "- Low todo quality ($avg_todo_quality/10). Improve problem statements and acceptance criteria."
fi
if [ "$update_count" -eq 0 ]; then
    echo "- Solutions are not being actively linked (0 updates)."
fi

# Find orphaned solutions (never referenced)
echo "" 
orphans=$(grep -rL "last_referenced: \"20" docs/solutions/**/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "- $orphans solutions have never been referenced."

echo ""
echo "💡 Recommendations"
if [ "$search_count" -eq 0 ]; then
    echo "- Run './scripts/compound-search.sh' before starting your next Plan."
fi
if [ "$update_count" -eq 0 ]; then
    echo "- Run './scripts/update-solution-ref.sh' when you use a solution."
fi

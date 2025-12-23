#!/bin/bash
# scripts/compound-dashboard.sh
# Displays unified Compound System dashboard with trends
# Usage: ./scripts/compound-dashboard.sh

METRICS_FILE=".agent/metrics/compound_history.json"
CURRENT_DATE=$(date +%Y-%m-%d)
SEVEN_DAYS_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d "7 days ago" +%Y-%m-%d)

# Ensure metrics are collected for today
./scripts/compound-metrics.sh >/dev/null 2>&1

# Run freshness audit (capture output for display later)
# This populates ORPHANS count if not present in JSON
AUDIT_OUTPUT=$(./scripts/audit-solution-freshness.sh)
ORPHANS_FROM_AUDIT=$(echo "$AUDIT_OUTPUT" | grep "orphaned" | awk '{print $3}')
[ -z "$ORPHANS_FROM_AUDIT" ] && ORPHANS_FROM_AUDIT=0

# Read current metrics using jq
if [ ! -f "$METRICS_FILE" ]; then
    echo "No metrics history found."
    exit 1
fi

# Get latest entry
LATEST=$(jq '.[-1]' "$METRICS_FILE")
GRADE=$(echo "$LATEST" | jq -r '.health_grade')
HIT_RATE=$(echo "$LATEST" | jq -r '.solutions.hit_rate')
TODO_QUAL=$(echo "$LATEST" | jq -r '.todos.avg_quality')
ZOMBIES=$(echo "$LATEST" | jq -r '.solutions.zombies')
ORPHANS=$(echo "$LATEST" | jq -r '.solutions.orphans // 0')

# Use real-time audit count if available (more accurate than historical JSON)
if [ ! -z "$ORPHANS_FROM_AUDIT" ] && [ "$ORPHANS_FROM_AUDIT" -ne 0 ]; then
    ORPHANS=$ORPHANS_FROM_AUDIT
fi

# Use raw count instead of grep if possible, or just trust the JSON
# We need comparison for trends.

# Find entry for 7 days ago (or closest previous?)
# For now, let's just look if there is a 'previous' entry (index -2)
# Ideally we search by date, but let's compare vs "Previous" for simplicity in MVP
HAS_PREV=$(jq 'length > 1' "$METRICS_FILE")

TREND_ARROW=""
OLD_GRADE=""

if [ "$HAS_PREV" == "true" ]; then
    PREV=$(jq '.[-2]' "$METRICS_FILE")
    OLD_GRADE=$(echo "$PREV" | jq -r '.health_grade')
    OLD_HIT=$(echo "$PREV" | jq -r '.solutions.hit_rate')
    
    # Calculate trend
    # Logic: Improved if Grade up OR (Grade same AND Hit Rate +5%)
    # Grade mapping: F=0, D=1, C=2, B=3, A=4
    # Bash associative arrays are tricky in older bash, use case
    score_grade() {
        case $1 in
            A) echo 4 ;;
            B) echo 3 ;;
            C) echo 2 ;;
            D) echo 1 ;;
            *) echo 0 ;;
        esac
    }
    
    CUR_SCORE=$(score_grade "$GRADE")
    OLD_SCORE=$(score_grade "$OLD_GRADE")
    
    if [ "$CUR_SCORE" -gt "$OLD_SCORE" ]; then
        TREND_ARROW="↑ (Improved from $OLD_GRADE)"
    elif [ "$CUR_SCORE" -lt "$OLD_SCORE" ]; then
        TREND_ARROW="↓ (Declined from $OLD_GRADE)"
    else
        # Tie breaker: Hit Rate
        DIFF=$((HIT_RATE - OLD_HIT))
        if [ "$DIFF" -ge 5 ]; then
            TREND_ARROW="↑ (Hit Rate +$DIFF%)"
        elif [ "$DIFF" -le -5 ]; then
            TREND_ARROW="↓ (Hit Rate $DIFF%)"
        else
            TREND_ARROW="→ (Stable)"
        fi
    fi
else
    TREND_ARROW="(New)"
fi

# Colorize Grade
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m'

case $GRADE in
    A|B) COLOR="$COLOR_GREEN" ;;
    C) COLOR="$COLOR_YELLOW" ;;
    *) COLOR="$COLOR_RED" ;;
esac

echo -e "🏥 COMPOUND SYSTEM HEALTH: ${COLOR}${GRADE}${COLOR_NC} ${TREND_ARROW}"
echo "========================================"
echo "Solutions: $(echo "$LATEST" | jq -r '.solutions.total')"
echo "Hit Rate:  ${HIT_RATE}%"
echo "Quality:   ${TODO_QUAL}/10"
if [ "$ZOMBIES" -gt 0 ]; then
    echo "Zombies:   ${ZOMBIES} (Stale >90d)"
fi
if [ "$ORPHANS" -gt 0 ]; then
    echo "Orphans:   ${ORPHANS} (Never referenced)"
fi
echo ""
echo "📊 Activity"
echo "Active Todos: $(echo "$LATEST" | jq -r '.todos.active')"
echo "Workflows:    $(echo "$LATEST" | jq -r '.workflows.invocations')"
echo "$LATEST" | jq -r '.workflows.top[]? | "  - \(.name): \(.count)"'

echo "Skills:       $(echo "$LATEST" | jq -r '.skills.invocations // 0')"
echo "$LATEST" | jq -r '.skills.top[]? | "  - \(.name): \(.count)"'
echo ""

# --- Exploration & Quality Metrics ---
EXPLORE_COUNT=$(echo "$LATEST" | jq -r '.explorations.total // 0')
EXPLORE_UTIL=$(echo "$LATEST" | jq -r '.explorations.utilization_rate // 0')
AVG_USEFUL=$(echo "$LATEST" | jq -r '.quality.avg_usefulness // 0')

if [ "$EXPLORE_COUNT" -gt 0 ] || [ "$AVG_USEFUL" -gt 0 ]; then
    echo "📚 Knowledge Graph"
    [ "$EXPLORE_COUNT" -gt 0 ] && echo "Explorations: $EXPLORE_COUNT"
    [ "$EXPLORE_UTIL" -gt 0 ] && echo "Explore→Solution: ${EXPLORE_UTIL}%"
    [ "$AVG_USEFUL" -gt 0 ] && echo "Avg Usefulness: ${AVG_USEFUL}/10"
    echo ""
fi

# --- Drift Metrics ---
PLAN_DRIFT=$(echo "$LATEST" | jq -r '.drift.plan_drift // 0')
SPEC_DRIFT=$(echo "$LATEST" | jq -r '.drift.spec_drift // 0')
TOTAL_DRIFT=$((PLAN_DRIFT + SPEC_DRIFT))

if [ "$TOTAL_DRIFT" -gt 0 ]; then
    echo "⚠️  Drift Detected"
    [ "$PLAN_DRIFT" -gt 0 ] && echo "Plans Stale:  $PLAN_DRIFT (>7 days Draft)"
    [ "$SPEC_DRIFT" -gt 0 ] && echo "Specs Stalled: $SPEC_DRIFT (>14 days same phase)"
    echo ""
fi

echo "💡 Recommendations"
REC_COUNT=0
if [ "$HIT_RATE" -lt 30 ]; then
    echo "- 🧠 Search solutions before starting plans to improve Hit Rate."
    REC_COUNT=$((REC_COUNT + 1))
fi

if [ "$TODO_QUAL" -lt 5 ]; then
    echo "- 📝 Improve todo problem statements (longer descriptions, criteria)."
    REC_COUNT=$((REC_COUNT + 1))
fi

WF_UNUSED_COUNT=$(echo "$LATEST" | jq -r '.workflows.unused_count // 0')
if [ "$WF_UNUSED_COUNT" -gt 3 ]; then
    echo "- 🔧 Review unused workflows: $WF_UNUSED_COUNT workflows not invoked (see .agent/metrics/unused_workflows.txt)."
    echo "$LATEST" | jq -r '.workflows.unused[]?' > .agent/metrics/unused_workflows.txt
    REC_COUNT=$((REC_COUNT + 1))
fi

if [ "$PLAN_DRIFT" -gt 0 ]; then
    echo "- 📋 Triage stale plans: $PLAN_DRIFT draft plans >7 days old. Run /triage or convert to todos."
    REC_COUNT=$((REC_COUNT + 1))
fi

if [ "$ORPHANS" -gt 0 ]; then
    echo "- 🔗 Link orphaned solutions: $ORPHANS solutions never referenced. Run './scripts/update-solution-ref.sh'."
    REC_COUNT=$((REC_COUNT + 1))
fi

if [ "$SPEC_DRIFT" -gt 0 ]; then
    echo "- 🎯 Resume stalled specs: $SPEC_DRIFT specs >14 days in same phase. Revisit or archive."
    REC_COUNT=$((REC_COUNT + 1))
fi

AVG_USEFUL=$(echo "$LATEST" | jq -r '.quality.avg_usefulness // 0')
if [ "$AVG_USEFUL" -gt 0 ] && [ "$AVG_USEFUL" -lt 6 ]; then
    echo "- 💡 Review low-scoring solutions or improve documentation quality (avg: ${AVG_USEFUL}/10)."
    REC_COUNT=$((REC_COUNT + 1))
fi

if [ "$REC_COUNT" -eq 0 ]; then
    echo "- Keep up the good work!"
fi

echo ""
echo "History: $METRICS_FILE"

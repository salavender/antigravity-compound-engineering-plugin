#!/bin/bash
TOTAL=0
COUNT=0
for f in todos/*.md; do
  [[ "$(basename "$f")" == "todo-template.md" ]] && continue
  SCORE=$(./scripts/score-todo.sh "$f" | cut -d'/' -f1)
  echo "$(basename "$f"): $SCORE"
  TOTAL=$((TOTAL + SCORE))
  COUNT=$((COUNT + 1))
done
AVG=$((TOTAL / COUNT))
echo "Total: $TOTAL"
echo "Count: $COUNT"
echo "Average: $AVG"
echo "Exact Average: $(echo "scale=2; $TOTAL / $COUNT" | bc)"

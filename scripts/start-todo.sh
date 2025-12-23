#!/bin/bash
# Atomically transition a todo to in-progress status
# Usage: ./scripts/start-todo.sh <todo-file>

set -euo pipefail

# Parse flags
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
  shift
fi

TODO_FILE="${1:?Usage: start-todo.sh [--force] <todo-file>}"

# Validation
if [[ ! -f "$TODO_FILE" ]]; then
  echo "❌ File not found: $TODO_FILE" >&2
  exit 1
fi

STATUS=$(grep "^status:" "$TODO_FILE" | cut -d' ' -f2)

# Prevent starting done/deferred/rejected unless forced
if [[ "$STATUS" =~ (done|deferred|rejected) ]]; then
  if [[ "$FORCE" == "false" ]]; then
    echo "❌ Error: Todo is already in terminal state: $STATUS" >&2
    echo "Use --force to bypass (not recommended)." >&2
    exit 1
  else
    echo "⚠️  Warning: Forcing transition from $STATUS to in-progress."
  fi
fi

# Extract components
BASENAME=$(basename "$TODO_FILE")
DIR=$(dirname "$TODO_FILE")
ID=$(echo "$BASENAME" | grep -oE '^[0-9]+')
PRIORITY=$(echo "$BASENAME" | grep -oE 'p[123]')
# Extract description robustly (handling various incoming status lengths)
DESC=$(echo "$BASENAME" | sed -E 's/^[0-9]+-[a-z-]+-p[123]-//' | sed 's/\.md$//')

# Build new filename
NEW_NAME="${ID}-in-progress-${PRIORITY}-${DESC}.md"
NEW_PATH="${DIR}/${NEW_NAME}"

# Check for collision
if [[ -f "$NEW_PATH" ]] && [[ "$TODO_FILE" != "$NEW_PATH" ]]; then
  echo "❌ Collision: $NEW_PATH already exists" >&2
  exit 1
fi

# Update YAML status (portable sed)
sed -i.bak 's/^status:.*/status: in-progress/' "$TODO_FILE" && rm -f "${TODO_FILE}.bak"

# Rename file
mv "$TODO_FILE" "$NEW_PATH"

echo "🏁 Started: $NEW_NAME"

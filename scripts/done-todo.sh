#!/bin/bash
# Atomically mark a todo as done with validation
# Usage: ./scripts/done-todo.sh <todo-file>

set -euo pipefail

# Parse flags
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
  shift
fi

TODO_FILE="${1:?Usage: done-todo.sh [--force] <todo-file>}"

# Validation
if [[ ! -f "$TODO_FILE" ]]; then
  echo "❌ File not found: $TODO_FILE" >&2
  exit 1
fi

# Check checklist status (strict validation)
if grep -q "\- \[ \]" "$TODO_FILE"; then
  if [[ "$FORCE" == "false" ]]; then
    echo "❌ Error: Unchecked items found in checklist." >&2
    echo "All acceptance criteria must be checked before marking a todo as done." >&2
    echo "Use --force to bypass this check (not recommended)." >&2
    exit 1
  else
    echo "⚠️  Warning: Bypassing checklist validation (--force used)."
  fi
fi

# Extract components
BASENAME=$(basename "$TODO_FILE")
DIR=$(dirname "$TODO_FILE")
ID=$(echo "$BASENAME" | grep -oE '^[0-9]+')
PRIORITY=$(echo "$BASENAME" | grep -oE 'p[0123]')
DESC=$(echo "$BASENAME" | sed -E 's/^[0-9]+-[a-z-]+-p[0123]-//' | sed 's/\.md$//')

# Build new filename (standardize on 'done')
NEW_NAME="${ID}-done-${PRIORITY}-${DESC}.md"
NEW_PATH="${DIR}/${NEW_NAME}"

# Check for collision
if [[ -f "$NEW_PATH" ]] && [[ "$TODO_FILE" != "$NEW_PATH" ]]; then
  echo "❌ Collision: $NEW_PATH already exists" >&2
  exit 1
fi

# Update YAML status (portable sed)
sed -i.bak 's/^status:.*/status: done/' "$TODO_FILE" && rm -f "${TODO_FILE}.bak"

# Rename file
mv "$TODO_FILE" "$NEW_PATH"

echo "✅ Done: $NEW_NAME"

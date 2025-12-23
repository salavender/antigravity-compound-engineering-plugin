#!/bin/bash
# Validate that todo filenames match their YAML status
# Usage: ./scripts/validate-todo-consistency.sh [--fix]

set -euo pipefail

FIX_MODE=false
if [[ "${1:-}" == "--fix" ]]; then
  FIX_MODE=true
fi

echo "🔍 Checking todo filename-YAML consistency..."

drift_count=0

for file in todos/*.md; do
  # Skip template and archive directory
  if [[ "$file" == *"template"* ]] || [[ "$file" == "todos/archive"* ]]; then
    continue
  fi
  
  # Skip if file doesn't exist (glob didn't match)
  if [[ ! -f "$file" ]]; then
    continue
  fi
  
  # Extract filename status
  filename_status=$(basename "$file" | sed 's/^[0-9]*-//;s/-p[0-9]-.*$//')
  
  # Extract YAML status
  yaml_status=$(grep -m1 '^status:' "$file" | awk '{print $2}' || echo "")
  
  # Handle missing status in YAML
  if [[ -z "$yaml_status" ]]; then
    echo "⚠️  WARNING: No status found in $(basename "$file")"
    continue
  fi
  
  # Normalize for comparison (done == complete)
  if [[ "$filename_status" == "done" || "$filename_status" == "complete" ]]; then
    filename_normalized="done"
  else
    filename_normalized="$filename_status"
  fi
  
  if [[ "$yaml_status" == "done" || "$yaml_status" == "complete" ]]; then
    yaml_normalized="done"
  else
    yaml_normalized="$yaml_status"
  fi
  
  # Check for mismatch
  if [[ "$filename_normalized" != "$yaml_normalized" ]]; then
    echo "❌ DRIFT: $(basename "$file")"
    echo "   Filename status: $filename_status"
    echo "   YAML status: $yaml_status"
    drift_count=$((drift_count + 1))
    
    if [[ "$FIX_MODE" == "true" ]]; then
      # Rename file to match YAML (YAML is source of truth)
      new_filename=$(basename "$file" | sed "s/-${filename_status}-/-${yaml_status}-/")
      echo "   → Renaming to: $new_filename"
      mv "$file" "todos/$new_filename"
    fi
  fi
done

if [[ $drift_count -eq 0 ]]; then
  echo "✅ All todos consistent!"
  exit 0
else
  echo ""
  echo "Found $drift_count todo(s) with state drift."
  if [[ "$FIX_MODE" == "false" ]]; then
    echo "Run with --fix to automatically heal."
  fi
  exit 1
fi

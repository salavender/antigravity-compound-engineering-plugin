#!/bin/bash
# docs/templates/repro-script-template.sh
# Template for systematic bug reproduction scripts.
# 
# Purpose: Create a script that consistently reproduces a bug.
# Compounding: This script becomes a regression test once the fix is applied.

set -euo pipefail

# --- 1. Setup Environment ---
echo "🏗️ Setting up reproduction environment..."
# Example: Sync DB, set env vars, or start a local service
# ./scripts/push-env.sh
# export NODE_ENV=test

# --- 2. Define Reproduction Case ---
# This part should contain the minimal logic to trigger the bug.
reproduce_bug() {
  echo "🧪 Attempting to reproduce bug..."
  
  # TODO: Implement the trigger logic here.
  # Example: 
  # response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/buggy-endpoint)
  # if [ "$response" == "500" ]; then return 0; else return 1; fi
  
  # For now, we return failure to indicate "not yet reproduced" or "bug present"
  return 1 
}

# --- 3. Run and Verify ---
if reproduce_bug; then
  echo "✅ SUCCESS: Bug NOT reproduced (or fix is working)."
  exit 0
else
  echo "❌ FAILURE: Bug REPRODUCED (or regression found)."
  # In a repro script, exiting with 1 is GOOD because it confirms the bug exists.
  # Once fixed, the CI will expect this script to exit with 0.
  exit 1
fi

# --- 4. Teardown ---
# Cleanup any temporary files or states
# rm -rf /tmp/repro-data

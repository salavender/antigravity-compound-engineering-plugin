#!/bin/bash
# Automated import path consolidation for directory structure cleanup
# Part of architectural consolidation to align with Next.js App Router conventions

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  echo "🔍 DRY RUN MODE - No changes will be made"
  echo ""
fi

echo "🔄 Consolidating import paths..."
echo ""

# Count files that will be affected
CONTEXT_FILES=$(find app -type f \( -name "*.ts" -o -name "*.tsx" \) -exec grep -l "@/context/\|@/app/context/" {} + 2>/dev/null | wc -l | tr -d ' ')
COMPONENT_FILES=$(find app -type f \( -name "*.ts" -o -name "*.tsx" \) -exec grep -l "@/components/" {} + 2>/dev/null | wc -l | tr -d ' ')

echo "📊 Impact Summary:"
echo "  - Files with @/context/ or @/app/context/ imports: $CONTEXT_FILES"
echo "  - Files with @/components/ imports: $COMPONENT_FILES"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "📝 Sample changes (first 5 matches):"
  echo ""
  echo "Context imports:"
  find app -type f \( -name "*.ts" -o -name "*.tsx" \) -exec grep -n "@/context/\|@/app/context/" {} + 2>/dev/null | head -5
  echo ""
  echo "Component imports:"
  find app -type f \( -name "*.ts" -o -name "*.tsx" \) -exec grep -n "@/components/" {} + 2>/dev/null | head -5
  echo ""
  echo "✅ Dry run complete. Run without --dry-run to apply changes."
  exit 0
fi

# Phase 1: Consolidate context imports
echo "Phase 1: Updating context imports..."
find app -type f \( -name "*.ts" -o -name "*.tsx" \) -exec sed -i '' \
  -e "s|from '@/context/|from '@/app/contexts/|g" \
  -e "s|from '@/app/context/|from '@/app/contexts/|g" \
  {} +
echo "  ✅ Context imports updated"

# Phase 2: Consolidate component imports  
echo "Phase 2: Updating component imports..."
find app -type f \( -name "*.ts" -o -name "*.tsx" \) -exec sed -i '' \
  -e "s|from '@/components/|from '@/app/components/|g" \
  {} +
echo "  ✅ Component imports updated"

echo ""
echo "✅ Import paths consolidated successfully!"
echo ""
echo "🔍 Next steps:"
echo "  1. Run: npx tsc --noEmit (verify TypeScript compilation)"
echo "  2. Run: git diff (review all changes)"
echo "  3. If satisfied, commit changes"

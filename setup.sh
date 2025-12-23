#!/bin/bash
# Antigravity Compound Engineering Plugin - Setup Script
# This script initializes the compound system for your project

set -e

echo "🚀 Antigravity Compound Engineering Plugin - Setup"
echo "=================================================="
echo ""

# Make all scripts executable
echo "📝 Setting script permissions..."
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x scripts/lib/*.sh 2>/dev/null || true
chmod +x scripts/validators/*.sh 2>/dev/null || true
echo "   ✓ Scripts are now executable"

# Create telemetry directories
echo "📊 Creating telemetry directories..."
mkdir -p .agent/logs
mkdir -p .agent/metrics
touch .agent/logs/.gitkeep
touch .agent/metrics/.gitkeep
echo "   ✓ Telemetry directories created"

# Prompt for project name
echo ""
read -p "Enter your project name (or press Enter to skip): " PROJECT_NAME

if [ -n "$PROJECT_NAME" ]; then
    echo "📝 Updating GEMINI.md with project name..."
    # Apply to all markdown files for consistency
    find . -name "*.md" -not -path "./node_modules/*" -exec sed -i '' "s/{PROJECT_NAME}/$PROJECT_NAME/g" {} + 2>/dev/null || \
    find . -name "*.md" -not -path "./node_modules/*" -exec sed -i "s/{PROJECT_NAME}/$PROJECT_NAME/g" {} +
    echo "   ✓ Project name set to: $PROJECT_NAME"
fi

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    echo "   ✓ Git repository initialized"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Configure your AI agent to read GEMINI.md"
echo "  2. Run ./scripts/compound-dashboard.sh to check health"
echo "  3. Start using /plan, /work, /review, /compound workflows"
echo ""
echo "📚 Documentation: https://github.com/YOUR_USERNAME/antigravity-compound-engineering-plugin"
echo ""
echo "Inspired by: https://github.com/EveryInc/compound-engineering-plugin"

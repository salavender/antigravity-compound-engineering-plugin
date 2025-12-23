#!/bin/bash

# Script to push environment variables to Vercel project
# Reads from .env.vercel.local and pushes to all environments

set -e

ENV_FILE=".env.vercel.local"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found"
    exit 1
fi

echo "Pushing environment variables to Vercel project..."
echo "Note: Using -n flag to prevent newline injection"
echo ""

# Read env file and push each variable
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    if [[ $key =~ ^#.*$ ]] || [[ -z $key ]]; then
        continue
    fi
    
    # Remove quotes from value if present
    value=$(echo "$value" | sed 's/^"//;s/"$//')
    
    # Validate: warn if value contains newlines (should never happen in .env file)
    if [[ "$value" == *$'\n'* ]]; then
        echo "⚠️  WARNING: $key contains newline characters!"
        echo "   This may cause HTTP header errors. Please fix $ENV_FILE"
        continue
    fi
    
    echo "Updating $key..."
    
    # Remove existing variable from all environments to avoid conflicts and ensure clean values
    vercel env rm "$key" production --yes || true
    vercel env rm "$key" preview --yes || true
    vercel env rm "$key" development --yes || true
    
    # Push to all environments
    # CRITICAL: Use -n flag to prevent echo from adding newline
    echo -n "$value" | vercel env add "$key" production
    echo -n "$value" | vercel env add "$key" preview
    echo -n "$value" | vercel env add "$key" development
    
done < "$ENV_FILE"

echo ""
echo "✅ All environment variables updated successfully!"
echo "Note: Existing malformed variables in Vercel have been overwritten with clean values."

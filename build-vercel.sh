#!/usr/bin/env bash
set -e

# Ensure we're in the project root
cd "$(dirname "$0")"

# Use npm workspace commands from root to explicitly target each workspace
# This avoids npm workspace resolution issues
echo "Building data-provider..."
npm run build -w packages/data-provider

echo "Building data-schemas..."
npm run build -w packages/data-schemas

echo "Building api..."
npm run build -w packages/api

echo "Building client-package..."
npm run build -w packages/client

echo "Building client (frontend)..."
npm run build -w client

echo "Build completed successfully!"


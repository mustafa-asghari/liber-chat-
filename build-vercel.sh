#!/bin/bash
set -e

# Ensure we're in the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Building data-provider..."
cd packages/data-provider && npm run build && cd "$SCRIPT_DIR"

echo "Building data-schemas..."
cd packages/data-schemas && npm run build && cd "$SCRIPT_DIR"

echo "Building api..."
cd packages/api && npm run build && cd "$SCRIPT_DIR"

echo "Building client-package..."
cd packages/client && npm run build && cd "$SCRIPT_DIR"

echo "Building client (frontend)..."
cd client && npm run build && cd "$SCRIPT_DIR"

echo "Build completed successfully!"


#!/bin/bash
# Markdown Lint Validation Script
# Validates markdown files for proper formatting

set -e

echo "=== Markdown Lint Validation ==="
echo "Checking files in: .opencode/context/core/"
echo ""

# Check if markdownlint is available
if ! command -v markdownlint &> /dev/null; then
    echo "[WARN] markdownlint not installed, skipping lint checks"
    echo "Install with: npm install -g markdownlint-cli"
    exit 0
fi

# Run markdownlint on core directory
if [ -d ".opencode/context/core" ]; then
    markdownlint .opencode/context/core/**/*.md || {
        echo "[FAIL] Markdown lint errors found"
        exit 1
    }
    echo "[PASS] All markdown files pass lint checks"
else
    echo "[WARN] Core directory not found, skipping"
fi

exit 0

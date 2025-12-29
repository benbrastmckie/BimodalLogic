#!/bin/bash
# Schema Validation Script
# Validates JSON schemas in markdown files

set -e

echo "=== Schema Validation ==="
echo "Checking JSON schemas in: .opencode/context/core/"
echo ""

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "[WARN] jq not installed, skipping schema validation"
    echo "Install with: sudo apt-get install jq (or brew install jq)"
    exit 0
fi

# Extract and validate JSON code blocks
if [ -d ".opencode/context/core" ]; then
    schema_errors=0
    
    for file in .opencode/context/core/**/*.md; do
        if [ -f "$file" ]; then
            # Extract JSON code blocks and validate
            awk '/```json/,/```/' "$file" | grep -v '```' | while read -r line; do
                if [ -n "$line" ]; then
                    echo "$line" | jq empty 2>/dev/null || {
                        echo "[WARN] Invalid JSON in $file"
                        schema_errors=$((schema_errors + 1))
                    }
                fi
            done
        fi
    done
    
    if [ $schema_errors -gt 0 ]; then
        echo "[FAIL] Found $schema_errors JSON schema errors"
        exit 1
    else
        echo "[PASS] All JSON schemas valid"
    fi
else
    echo "[WARN] Core directory not found, skipping"
fi

exit 0

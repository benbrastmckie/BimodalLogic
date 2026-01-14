#!/bin/bash
# Link Check Validation Script
# Validates all internal links in markdown files

set -e

echo "=== Link Check Validation ==="
echo "Checking files in: .opencode/context/core/"
echo ""

# Check if markdown-link-check is available
if ! command -v markdown-link-check &> /dev/null; then
    echo "[WARN] markdown-link-check not installed, using grep fallback"
    echo "Install with: npm install -g markdown-link-check"
    
    # Fallback: Check for broken relative links using grep
    echo "Checking for broken relative links..."
    broken_links=0
    
    for file in .opencode/context/core/**/*.md; do
        if [ -f "$file" ]; then
            # Extract relative links and check if files exist
            grep -oP '\[.*?\]\(\K[^)]+(?=\))' "$file" 2>/dev/null | while read -r link; do
                # Skip external links
                if [[ "$link" =~ ^https?:// ]]; then
                    continue
                fi
                
                # Remove anchor
                link_file="${link%%#*}"
                
                # Check if file exists (relative to context directory)
                if [ -n "$link_file" ] && [ ! -f ".opencode/context/$link_file" ]; then
                    echo "[WARN] Broken link in $file: $link"
                    broken_links=$((broken_links + 1))
                fi
            done
        fi
    done
    
    if [ $broken_links -gt 0 ]; then
        echo "[WARN] Found $broken_links potentially broken links"
    else
        echo "[PASS] No broken links detected"
    fi
    
    exit 0
fi

# Run markdown-link-check on core directory
if [ -d ".opencode/context/core" ]; then
    for file in .opencode/context/core/**/*.md; do
        if [ -f "$file" ]; then
            markdown-link-check "$file" || {
                echo "[FAIL] Link check failed for $file"
                exit 1
            }
        fi
    done
    echo "[PASS] All links valid"
else
    echo "[WARN] Core directory not found, skipping"
fi

exit 0

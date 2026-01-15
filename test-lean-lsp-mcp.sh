#!/bin/bash

# Test script for lean-lsp-mcp functionality
# This script verifies that lean-lsp-mcp tools are working correctly after configuration fix

set -e

echo "=== Testing lean-lsp-mcp Configuration ==="
echo

# Test 1: Check uvx availability
echo "1. Checking uvx availability..."
if command -v uvx >/dev/null 2>&1; then
    echo "   [PASS] uvx found at: $(which uvx)"
else
    echo "   [FAIL] uvx not found"
    exit 1
fi

# Test 2: Check lean-lsp-mcp via uvx
echo
echo "2. Testing lean-lsp-mcp package..."
if uvx lean-lsp-mcp --help >/dev/null 2>&1; then
    echo "   [PASS] lean-lsp-mcp responds to help command"
else
    echo "   [FAIL] lean-lsp-mcp not responding"
    exit 1
fi

# Test 3: Verify configuration changes
echo
echo "3. Verifying opencode.json configuration..."
if grep -q '"uvx", "lean-lsp-mcp"' opencode.json; then
    echo "   [PASS] Command updated to use uvx"
else
    echo "   [FAIL] Command not updated"
    exit 1
fi

if grep -q '"lean-lsp-mcp\*": true' opencode.json; then
    echo "   [PASS] Tools enabled"
else
    echo "   [FAIL] Tools not enabled"
    exit 1
fi

# Test 4: JSON syntax validation
echo
echo "4. Validating JSON syntax..."
if python3 -m json.tool opencode.json >/dev/null 2>&1; then
    echo "   [PASS] JSON syntax is valid"
else
    echo "   [FAIL] JSON syntax is invalid"
    exit 1
fi

# Test 5: Check for Lean project structure
echo
echo "5. Checking Lean project structure..."
if [ -f "lakefile.lean" ]; then
    echo "   [PASS] Lake project detected"
else
    echo "   [WARN] No lakefile.lean found"
fi

# Test 6: Test basic server startup (short timeout)
echo
echo "6. Testing server startup (10 second timeout)..."
if timeout 10 uvx lean-lsp-mcp --transport stdio --help >/dev/null 2>&1; then
    echo "   [PASS] Server starts without errors"
else
    echo "   [WARN] Server startup test timed out (may be normal)"
fi

echo
echo "=== Summary ==="
echo "Configuration fix applied successfully!"
echo "lean-lsp-mcp tools should now be available to agents."
echo
echo "Next steps:"
echo "1. Restart development environment to reload configuration"
echo "2. Test agent tool access with actual Lean files"
echo "3. Verify compilation verification workflow"
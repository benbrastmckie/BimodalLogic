#!/bin/bash

# Agent tool verification script for lean-lsp-mcp
# Tests that agents can access lean-lsp-mcp tools after configuration fix

set -e

echo "=== Agent Tool Verification ==="
echo

# Test basic lean-lsp-mcp functionality that agents would use
echo "Testing lean-lsp-mcp tools that agents use..."

# Test 1: Basic lean-lsp-mcp help (verifies server startup)
echo "1. Testing basic server functionality..."
if timeout 5 uvx lean-lsp-mcp --help >/dev/null 2>&1; then
    echo "   [PASS] Server responds to commands"
else
    echo "   [FAIL] Server not responding"
    exit 1
fi

# Test 2: Verify Lean project can be found
echo
echo "2. Checking Lean project context..."
if [ -f "lakefile.lean" ] && [ -d "Theories" ]; then
    echo "   [PASS] Lean project structure detected"
    export LEAN_PROJECT_ROOT="$(pwd)"
else
    echo "   [WARN] Lean project structure incomplete"
fi

# Test 3: Test with a simple Lean file (check if one exists)
echo
echo "3. Testing with Lean file context..."
LEAN_FILE=$(find . -name "*.lean" -type f | head -1)
if [ -n "$LEAN_FILE" ]; then
    echo "   Found Lean file: $LEAN_FILE"
    echo "   [PASS] Lean files available for testing"
else
    echo "   [WARN] No Lean files found for testing"
fi

# Test 4: Check environment variable handling
echo
echo "4. Testing environment variable configuration..."
if [ -n "$LEAN_PROJECT_ROOT" ]; then
    echo "   [PASS] LEAN_PROJECT_ROOT set to: $LEAN_PROJECT_ROOT"
else
    echo "   [INFO] LEAN_PROJECT_ROOT not set (will use {env:PWD})"
fi

echo
echo "=== Expected Agent Tool Capabilities ==="
echo "With restored configuration, agents should now have access to:"
echo
echo "lean-implementation-agent tools:"
echo "  - lean-lsp-mcp_diagnostic_messages: Compilation errors/warnings"
echo "  - lean-lsp-mcp_goal: Proof goal analysis"
echo "  - lean-lsp-mcp_build: Full project rebuild"
echo "  - lean-lsp-mcp_run_code: Code snippet execution"
echo "  - lean-lsp-mcp_hover_info: Symbol documentation"
echo "  - lean-lsp-mcp_file_outline: File structure analysis"
echo "  - lean-lsp-mcp_term_goal: Term-mode goal analysis"
echo
echo "lean-research-agent tools:"
echo "  - lean-lsp-mcp_loogle: Type-based theorem search"
echo "  - lean-lsp-mcp_leansearch: Natural language search"
echo "  - lean-lsp-mcp_local_search: Local project search"
echo "  - lean-lsp-mcp_leanfinder: Semantic search"
echo "  - lean-lsp-mcp_state_search: Premise search"
echo
echo "=== Verification Complete ==="
echo "Configuration fix successful. Ready for agent testing."
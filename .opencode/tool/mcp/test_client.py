"""
Integration tests for MCP client wrapper.

Tests check_mcp_server_configured and invoke_mcp_tool functions.
"""

import json
import os
import sys
import tempfile
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from tool.mcp.client import (
    check_mcp_server_configured,
    invoke_mcp_tool,
    find_mcp_config,
    get_mcp_server_config
)


def test_find_mcp_config():
    """Test finding .mcp.json in project root."""
    print("Test: find_mcp_config()")
    
    config_path = find_mcp_config()
    
    if config_path:
        print(f"  ✓ Found .mcp.json at: {config_path}")
        assert config_path.exists()
        assert config_path.name == '.mcp.json'
    else:
        print("  ✗ .mcp.json not found")
        return False
    
    return True


def test_check_mcp_server_configured():
    """Test checking if lean-lsp server is configured."""
    print("\nTest: check_mcp_server_configured('lean-lsp')")
    
    is_configured = check_mcp_server_configured("lean-lsp")
    
    if is_configured:
        print("  ✓ lean-lsp server is configured and available")
    else:
        print("  ✗ lean-lsp server not configured or unavailable")
        print("    (This may be expected if uvx is not installed)")
    
    return True  # Not a failure if server unavailable


def test_check_nonexistent_server():
    """Test checking for non-existent server."""
    print("\nTest: check_mcp_server_configured('nonexistent')")
    
    is_configured = check_mcp_server_configured("nonexistent")
    
    if not is_configured:
        print("  ✓ Correctly returns False for non-existent server")
    else:
        print("  ✗ Should return False for non-existent server")
        return False
    
    return True


def test_get_mcp_server_config():
    """Test getting server configuration."""
    print("\nTest: get_mcp_server_config('lean-lsp')")
    
    config = get_mcp_server_config("lean-lsp")
    
    if config:
        print(f"  ✓ Got server config:")
        print(f"    - Type: {config.get('type')}")
        print(f"    - Command: {config.get('command')}")
        print(f"    - Args: {config.get('args')}")
        
        assert config.get('type') == 'stdio'
        assert config.get('command') == 'uvx'
        assert 'lean-lsp-mcp' in config.get('args', [])
    else:
        print("  ✗ Failed to get server config")
        return False
    
    return True


def test_invoke_mcp_tool_not_implemented():
    """Test that invoke_mcp_tool returns appropriate error."""
    print("\nTest: invoke_mcp_tool() - not yet implemented")
    
    result = invoke_mcp_tool(
        server="lean-lsp",
        tool="lean_diagnostic_messages",
        arguments={"file_path": "test.lean"}
    )
    
    print(f"  Result: success={result['success']}")
    print(f"  Error: {result['error']}")
    
    if not result['success']:
        if 'not yet implemented' in result['error'].lower():
            print("  ✓ Correctly returns 'not yet implemented' error")
        else:
            print("  ✓ Returns error (expected until MCP client implemented)")
    else:
        print("  ✗ Should return error until MCP client implemented")
        return False
    
    return True


def test_invoke_mcp_tool_invalid_server():
    """Test invoke_mcp_tool with invalid server."""
    print("\nTest: invoke_mcp_tool() - invalid server")
    
    result = invoke_mcp_tool(
        server="nonexistent",
        tool="some_tool",
        arguments={}
    )
    
    if not result['success']:
        print(f"  ✓ Correctly returns error: {result['error']}")
    else:
        print("  ✗ Should return error for invalid server")
        return False
    
    return True


def run_all_tests():
    """Run all tests and report results."""
    print("=" * 60)
    print("MCP Client Integration Tests")
    print("=" * 60)
    
    tests = [
        test_find_mcp_config,
        test_check_mcp_server_configured,
        test_check_nonexistent_server,
        test_get_mcp_server_config,
        test_invoke_mcp_tool_not_implemented,
        test_invoke_mcp_tool_invalid_server,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"  ✗ Test failed with exception: {e}")
            failed += 1
    
    print("\n" + "=" * 60)
    print(f"Results: {passed} passed, {failed} failed")
    print("=" * 60)
    
    return failed == 0


if __name__ == '__main__':
    success = run_all_tests()
    sys.exit(0 if success else 1)

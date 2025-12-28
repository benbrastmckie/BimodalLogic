"""
MCP client implementation for invoking lean-lsp-mcp and other MCP tools.

This module provides functions to check MCP server configuration and invoke
MCP tools from agent workflows.
"""

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, Any, Optional


def check_mcp_server_configured(server_name: str = "lean-lsp") -> bool:
    """
    Check if an MCP server is configured in .mcp.json.
    
    Args:
        server_name: Name of the MCP server to check (default: "lean-lsp")
    
    Returns:
        True if server is configured and command is available, False otherwise
    """
    try:
        # Find .mcp.json in current directory or parent directories
        mcp_config_path = find_mcp_config()
        if not mcp_config_path:
            return False
        
        # Load .mcp.json
        with open(mcp_config_path, 'r') as f:
            config = json.load(f)
        
        # Check if server is configured
        if 'mcpServers' not in config:
            return False
        
        if server_name not in config['mcpServers']:
            return False
        
        server_config = config['mcpServers'][server_name]
        
        # Verify command exists
        command = server_config.get('command')
        if not command:
            return False
        
        # Check if command is available
        try:
            result = subprocess.run(
                ['which', command],
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    except Exception:
        return False


def find_mcp_config() -> Optional[Path]:
    """
    Find .mcp.json file in current directory or parent directories.
    
    Returns:
        Path to .mcp.json if found, None otherwise
    """
    current = Path.cwd()
    
    # Search up to 5 levels
    for _ in range(5):
        mcp_path = current / '.mcp.json'
        if mcp_path.exists():
            return mcp_path
        
        parent = current.parent
        if parent == current:
            break
        current = parent
    
    return None


def invoke_mcp_tool(
    server: str,
    tool: str,
    arguments: Dict[str, Any],
    timeout: int = 30
) -> Dict[str, Any]:
    """
    Invoke an MCP tool on a configured server.
    
    This is a placeholder implementation that returns a standardized error.
    Full MCP protocol implementation requires an MCP client library.
    
    Args:
        server: MCP server name (e.g., "lean-lsp")
        tool: Tool name (e.g., "lean_diagnostic_messages")
        arguments: Tool arguments as dictionary
        timeout: Timeout in seconds (default: 30)
    
    Returns:
        Dictionary with keys:
        - success: bool - Whether tool invocation succeeded
        - result: dict | str - Tool result if successful
        - error: str | None - Error message if failed
    
    Example:
        >>> result = invoke_mcp_tool(
        ...     server="lean-lsp",
        ...     tool="lean_diagnostic_messages",
        ...     arguments={"file_path": "Logos/Core/Theorem.lean"}
        ... )
        >>> if result["success"]:
        ...     diagnostics = result["result"]
    """
    # Check if server is configured
    if not check_mcp_server_configured(server):
        return {
            "success": False,
            "result": None,
            "error": f"MCP server '{server}' not configured or unavailable"
        }
    
    # Load MCP configuration
    try:
        mcp_config_path = find_mcp_config()
        if not mcp_config_path:
            return {
                "success": False,
                "result": None,
                "error": ".mcp.json not found"
            }
        
        with open(mcp_config_path, 'r') as f:
            config = json.load(f)
        
        server_config = config['mcpServers'][server]
        
    except Exception as e:
        return {
            "success": False,
            "result": None,
            "error": f"Failed to load MCP configuration: {str(e)}"
        }
    
    # NOTE: Full MCP protocol implementation would go here
    # This requires an MCP client library (e.g., mcp Python package)
    # For now, return a clear error indicating MCP protocol support is needed
    
    return {
        "success": False,
        "result": None,
        "error": (
            f"MCP protocol client not yet implemented. "
            f"To invoke tool '{tool}' on server '{server}', "
            f"an MCP client library integration is required. "
            f"Server is configured at: {mcp_config_path}"
        )
    }


def get_mcp_server_config(server_name: str = "lean-lsp") -> Optional[Dict[str, Any]]:
    """
    Get MCP server configuration from .mcp.json.
    
    Args:
        server_name: Name of the MCP server
    
    Returns:
        Server configuration dictionary if found, None otherwise
    """
    try:
        mcp_config_path = find_mcp_config()
        if not mcp_config_path:
            return None
        
        with open(mcp_config_path, 'r') as f:
            config = json.load(f)
        
        if 'mcpServers' not in config:
            return None
        
        return config['mcpServers'].get(server_name)
    
    except Exception:
        return None

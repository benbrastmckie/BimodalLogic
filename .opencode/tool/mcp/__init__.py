"""
MCP (Model Context Protocol) client wrapper for invoking tools from agents.

This module provides utilities for agents to invoke MCP tools configured in .mcp.json.
"""

from .client import check_mcp_server_configured, invoke_mcp_tool, get_mcp_server_config

__all__ = ['check_mcp_server_configured', 'invoke_mcp_tool', 'get_mcp_server_config']

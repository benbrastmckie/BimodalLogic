# MCP Client - Custom Python Implementation

## Status: DEPRECATED for OpenCode Agents

**Important**: This custom MCP client is **NOT used by OpenCode agents**. OpenCode has native MCP support through configuration-based integration via `opencode.json`.

## Purpose

This directory contains a custom Python MCP (Model Context Protocol) client implementation. It was created as part of Task 212 to explore MCP integration patterns.

## Use Cases

### Supported Use Cases

1. **Standalone Python Scripts**: Scripts that need MCP functionality outside of OpenCode
2. **Testing and Development**: Testing MCP server functionality
3. **Custom Tooling**: Python tools that need MCP integration

### NOT Supported Use Cases

1. **OpenCode Agents**: OpenCode agents use configuration-based MCP integration
2. **Agent Definitions**: Agent markdown files cannot import Python modules

## Architecture

### Custom MCP Client (This Directory)

**File**: `client.py`

**Features**:
- Python MCP client implementation (192 lines)
- Functions: `check_mcp_server_configured()`, `invoke_mcp_tool()`
- Configuration: Reads `.mcp.json` (Claude Desktop format)
- Use case: Standalone Python scripts

**Limitations**:
- Cannot be imported by OpenCode agents (agents are markdown, not Python)
- Requires `.mcp.json` configuration (different from `opencode.json`)
- Manual process management

### OpenCode Native MCP Support (Recommended)

**File**: `opencode.json` (project root)

**Features**:
- Configuration-based MCP integration
- Natural language tool instructions
- Automatic process management
- Per-agent tool enablement
- Context window optimization

**Benefits**:
- No code required (0 lines)
- Works with OpenCode agents
- Follows OpenCode best practices
- Better error handling

## Migration Guide

### From Custom Client to OpenCode Native

If you have code using the custom MCP client:

**Before (Custom Client - DON'T USE IN AGENTS)**:
```python
from opencode.tool.mcp.client import check_mcp_server_configured, invoke_mcp_tool

# Check if MCP server configured
mcp_available = check_mcp_server_configured("lean-lsp")

# Invoke MCP tool
if mcp_available:
    result = invoke_mcp_tool(
        server="lean-lsp",
        tool="lean_diagnostic_messages",
        arguments={"file_path": "Logos/Core/Theorem.lean"},
        timeout=30
    )
```

**After (OpenCode Native - USE IN AGENTS)**:
```xml
<mcp_tools>
  Available lean-lsp-mcp tools:
  
  1. lean-lsp-mcp_diagnostic_messages
     - Purpose: Get compilation errors and warnings
     - Input: {"file_path": "path/to/file.lean"}
     - Output: Array of diagnostics
     - Use: Check compilation after writing Lean code
</mcp_tools>

<process_flow>
  <step>
    <action>Check compilation</action>
    <process>
      1. Use lean-lsp-mcp_diagnostic_messages tool to check compilation
      2. Parse diagnostic results
      3. Fix errors iteratively
    </process>
  </step>
</process_flow>
```

### Configuration Migration

**Before (`.mcp.json` - Claude Desktop format)**:
```json
{
  "mcpServers": {
    "lean-lsp": {
      "command": "npx",
      "args": ["-y", "lean-lsp-mcp"],
      "env": {
        "LEAN_PROJECT_ROOT": "/path/to/project"
      }
    }
  }
}
```

**After (`opencode.json` - OpenCode format)**:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "lean-lsp-mcp": {
      "type": "local",
      "command": ["npx", "-y", "lean-lsp-mcp"],
      "enabled": true,
      "environment": {
        "LEAN_PROJECT_ROOT": "{env:PWD}"
      },
      "timeout": 10000
    }
  },
  "tools": {
    "lean-lsp-mcp*": false
  },
  "agent": {
    "lean-implementation-agent": {
      "tools": {
        "lean-lsp-mcp_diagnostic_messages": true,
        "lean-lsp-mcp_goal": true
      }
    }
  }
}
```

## Files in This Directory

### `client.py`

Custom Python MCP client implementation.

**Functions**:
- `check_mcp_server_configured(server_name: str) -> bool`: Check if MCP server configured
- `invoke_mcp_tool(server: str, tool: str, arguments: dict, timeout: int) -> dict`: Invoke MCP tool

**Configuration**: Reads `.mcp.json` in project root

**Use Case**: Standalone Python scripts only

### `test_client.py`

Test suite for custom MCP client.

**Use Case**: Testing MCP client functionality

### `__init__.py`

Python package initialization.

## Documentation

### For OpenCode Agents

See `Documentation/UserGuide/MCP_INTEGRATION.md` for comprehensive guide on using MCP with OpenCode agents.

**Key Points**:
- Use `opencode.json` for configuration
- Use natural language tool instructions in agent definitions
- No Python imports required
- Graceful degradation when tools unavailable

### For Standalone Scripts

If you need to use MCP in standalone Python scripts:

1. Ensure `.mcp.json` configured with MCP server
2. Import client functions: `from opencode.tool.mcp.client import ...`
3. Check server availability: `check_mcp_server_configured("server-name")`
4. Invoke tools: `invoke_mcp_tool(server, tool, arguments, timeout)`

## Deprecation Notice

**Effective**: Task 218 (2025-12-28)

**Reason**: OpenCode has native MCP support through configuration-based integration. Custom Python client is incompatible with OpenCode agent architecture.

**Impact**:
- Custom MCP client remains available for standalone scripts
- OpenCode agents use `opencode.json` configuration instead
- No breaking changes to existing standalone scripts

**Recommendation**: Use OpenCode native MCP support for all agent-based workflows.

## References

### OpenCode MCP Integration

- **User Guide**: `Documentation/UserGuide/MCP_INTEGRATION.md`
- **Configuration**: `opencode.json` (project root)
- **OpenCode Docs**: https://opencode.ai/docs/mcp-servers/

### Custom MCP Client

- **Implementation**: `client.py` (this directory)
- **Tests**: `test_client.py` (this directory)
- **Configuration**: `.mcp.json` (project root, Claude Desktop format)

### External Resources

- **Model Context Protocol**: https://modelcontextprotocol.io/
- **lean-lsp-mcp**: https://pypi.org/project/lean-lsp-mcp/

## Future Work

### Potential Enhancements

1. **Standalone CLI Tool**: Create CLI wrapper for MCP client
2. **Testing Utilities**: Expand test suite for MCP server testing
3. **Documentation**: Add examples for standalone script usage

### Not Planned

1. **OpenCode Agent Integration**: Use OpenCode native support instead
2. **Feature Parity with OpenCode**: OpenCode native support is superior
3. **Active Maintenance**: Minimal maintenance, focus on OpenCode integration

## Support

For issues related to:
- **OpenCode MCP Integration**: See `Documentation/UserGuide/MCP_INTEGRATION.md`
- **Custom MCP Client**: File issue with "mcp-client" label
- **lean-lsp-mcp Server**: See https://pypi.org/project/lean-lsp-mcp/

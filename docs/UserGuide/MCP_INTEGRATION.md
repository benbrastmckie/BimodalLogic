# MCP Integration Guide for OpenCode

## Overview

This guide documents the integration of Model Context Protocol (MCP) servers with OpenCode for the ProofChecker project. OpenCode provides native MCP support through configuration-based integration, allowing agents to use MCP tools via natural language instructions.

**Key Concepts**:
- **MCP Servers**: External services providing tools to agents (e.g., lean-lsp-mcp)
- **Configuration-Based**: MCP servers defined in `opencode.json`, not custom code
- **Natural Language Tools**: Agents use tools via natural language, not Python imports
- **Selective Enablement**: Tools can be enabled globally or per-agent to minimize context window usage

## Architecture

### OpenCode Native MCP Support

OpenCode has built-in MCP support that differs from Claude Desktop's approach:

1. **Configuration File**: `opencode.json` in project root (JSON format, NOT JSONC)
2. **Schema Validation**: Uses `$schema` reference for validation
3. **Local Servers**: MCP servers run as local processes (e.g., `npx -y lean-lsp-mcp`)
4. **Tool Management**: Tools enabled/disabled via glob patterns
5. **Per-Agent Enablement**: Tools can be selectively enabled for specific agents

### Architectural Comparison

**Task 212 Approach (DEPRECATED for OpenCode agents)**:
- Custom Python MCP client (192 lines)
- Python imports in agent definitions
- `.mcp.json` configuration (Claude Desktop format)
- Agents execute Python code

**Task 218 Approach (CORRECT for OpenCode)**:
- OpenCode native MCP support (0 lines code)
- Natural language tool instructions
- `opencode.json` configuration (OpenCode format)
- Agents use tools via natural language

**Important**: OpenCode agents are markdown files with XML-structured instructions that the LLM interprets. They cannot import Python modules. MCP tools are made available through configuration, not code.

## Configuration Guide

### opencode.json Format

The `opencode.json` file follows the OpenCode configuration schema:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "server-name": {
      "type": "local",
      "command": ["command", "arg1", "arg2"],
      "enabled": true,
      "environment": {
        "ENV_VAR": "{env:SYSTEM_VAR}"
      },
      "timeout": 10000
    }
  },
  "tools": {
    "server-name*": false
  },
  "agent": {
    "agent-name": {
      "tools": {
        "server-name_tool1": true,
        "server-name_tool2": true
      }
    }
  }
}
```

### Configuration Fields

#### MCP Server Configuration

- **`$schema`**: Schema reference for validation (required)
  - Value: `"https://opencode.ai/config.json"`

- **`mcp`**: MCP server definitions (object)
  - Key: Server name (e.g., `"lean-lsp-mcp"`)
  - Value: Server configuration object

- **`type`**: Server type (required)
  - Value: `"local"` for local processes

- **`command`**: Command to start server (required)
  - Value: Array of strings (e.g., `["npx", "-y", "lean-lsp-mcp"]`)

- **`enabled`**: Whether server is enabled (optional, default: true)
  - Value: `true` or `false`

- **`environment`**: Environment variables (optional)
  - Value: Object with `{env:VAR}` syntax for dynamic values
  - Example: `{"LEAN_PROJECT_ROOT": "{env:PWD}"}`

- **`timeout`**: Server startup timeout in milliseconds (optional, default: 5000)
  - Value: Integer (e.g., `10000` for 10 seconds)

#### Tool Management

- **`tools`**: Global tool enablement (object)
  - Key: Tool name or glob pattern (e.g., `"lean-lsp-mcp*"`)
  - Value: `true` (enabled) or `false` (disabled)
  - Default: All tools enabled if not specified

- **`agent`**: Per-agent configuration (object)
  - Key: Agent name (e.g., `"lean-implementation-agent"`)
  - Value: Agent configuration object with `tools` subsection

### lean-lsp-mcp Configuration Example

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
        "lean-lsp-mcp_goal": true,
        "lean-lsp-mcp_build": true,
        "lean-lsp-mcp_run_code": true,
        "lean-lsp-mcp_hover_info": true,
        "lean-lsp-mcp_file_outline": true,
        "lean-lsp-mcp_term_goal": true
      }
    },
    "lean-research-agent": {
      "tools": {
        "lean-lsp-mcp_loogle": true,
        "lean-lsp-mcp_leansearch": true,
        "lean-lsp-mcp_local_search": true,
        "lean-lsp-mcp_leanfinder": true,
        "lean-lsp-mcp_state_search": true
      }
    }
  }
}
```

## Tool Management

### Global vs Per-Agent Enablement

**Global Enablement** (default):
- All tools from all MCP servers available to all agents
- Simple configuration
- **Problem**: High context window usage (2000-5000 tokens overhead)

**Selective Per-Agent Enablement** (recommended):
- Disable tools globally with glob pattern: `"lean-lsp-mcp*": false`
- Enable specific tools per agent: `"lean-lsp-mcp_diagnostic_messages": true`
- **Benefit**: Reduced context window usage (~50% reduction)

### Context Window Optimization

MCP tools add to the agent's context window. Each tool adds approximately 200 tokens of overhead (tool name, description, parameters, examples).

**Example Calculation**:
- 15 tools × 200 tokens = 3000 tokens overhead (global enablement)
- 7 tools × 200 tokens = 1400 tokens overhead (selective enablement)
- **Savings**: 1600 tokens (~50% reduction)

**Best Practice**: Enable only the tools each agent actually needs.

### Tool Naming Convention

MCP tools follow the naming pattern: `{server-name}_{tool-name}`

Examples:
- `lean-lsp-mcp_diagnostic_messages`
- `lean-lsp-mcp_goal`
- `lean-lsp-mcp_loogle`

## Agent Usage Patterns

### Natural Language Tool Instructions

Agents use MCP tools via natural language instructions in their markdown definitions. No Python imports required.

**Example (lean-implementation-agent.md)**:

```xml
<mcp_tools>
  Available lean-lsp-mcp tools:
  
  1. lean-lsp-mcp_diagnostic_messages
     - Purpose: Get compilation errors and warnings
     - Input: {"file_path": "path/to/file.lean"}
     - Output: Array of {severity, message, line, column}
     - Use: Check compilation after writing Lean code
  
  2. lean-lsp-mcp_goal
     - Purpose: Get proof state at cursor position
     - Input: {"file_path": "path/to/file.lean", "line": 45, "column": 10}
     - Output: Proof goal with hypotheses and target
     - Use: Inspect proof state when debugging tactics
</mcp_tools>

<process_flow>
  <step_4>
    <action>Check compilation using lean-lsp-mcp tools</action>
    <process>
      1. Write current Lean code to file
      
      2. Use lean-lsp-mcp_diagnostic_messages tool to check compilation:
         - Tool: lean-lsp-mcp_diagnostic_messages
         - Input: {"file_path": "path/to/file.lean"}
         - Output: Array of diagnostics
      
      3. Parse diagnostic results:
         - Severity 1 = Error (must fix)
         - Severity 2 = Warning (can ignore)
      
      4. If errors exist, analyze and fix iteratively
    </process>
  </step_4>
</process_flow>
```

### Graceful Degradation

Agents should handle MCP tool unavailability gracefully:

```xml
<graceful_degradation>
  If lean-lsp-mcp tools unavailable or fail:
  
  1. Continue with direct file modification
  2. Log warning: "lean-lsp-mcp tools unavailable, compilation not verified"
  3. Return partial status with warning
  4. Recommend manual compilation: "Run 'lake build' to verify compilation"
  
  Error handling for MCP tool failures:
  - Tool unavailable: Log warning, continue without verification
  - Timeout: Log timeout, fall back to file write
  - Connection error: Log error, fall back to file write
  
  All MCP tool usage is optional - agent never fails due to MCP unavailability
</graceful_degradation>
```

## Available lean-lsp-mcp Tools

### Implementation Tools (lean-implementation-agent)

1. **lean-lsp-mcp_diagnostic_messages**
   - **Purpose**: Get compilation errors and warnings
   - **Input**: `{"file_path": "path/to/file.lean"}`
   - **Output**: Array of `{severity, message, line, column, source}`
   - **Use Case**: Check compilation after writing Lean code

2. **lean-lsp-mcp_goal**
   - **Purpose**: Get proof state at cursor position
   - **Input**: `{"file_path": "path/to/file.lean", "line": 45, "column": 10}`
   - **Output**: Proof goal with hypotheses and target
   - **Use Case**: Inspect proof state when debugging tactics

3. **lean-lsp-mcp_build**
   - **Purpose**: Rebuild entire Lean project
   - **Input**: `{}`
   - **Output**: Build status and errors
   - **Use Case**: Verify full project compilation

4. **lean-lsp-mcp_run_code**
   - **Purpose**: Execute Lean code snippet
   - **Input**: `{"code": "theorem test : True := trivial"}`
   - **Output**: Execution result or error
   - **Use Case**: Test small code snippets quickly

5. **lean-lsp-mcp_hover_info**
   - **Purpose**: Get symbol documentation and type
   - **Input**: `{"file_path": "path/to/file.lean", "line": 45, "column": 10}`
   - **Output**: Symbol type and documentation
   - **Use Case**: Understand symbol types when fixing errors

6. **lean-lsp-mcp_file_outline**
   - **Purpose**: Get file structure (theorems, definitions, etc.)
   - **Input**: `{"file_path": "path/to/file.lean"}`
   - **Output**: File outline with symbols
   - **Use Case**: Navigate large Lean files

7. **lean-lsp-mcp_term_goal**
   - **Purpose**: Get term-mode goal at position
   - **Input**: `{"file_path": "path/to/file.lean", "line": 45, "column": 10}`
   - **Output**: Term goal with expected type
   - **Use Case**: Debug term-mode proofs

### Search Tools (lean-research-agent)

1. **lean-lsp-mcp_loogle**
   - **Purpose**: Type-based search in Lean libraries
   - **Input**: `{"query": "?a → ?b → ?a ∧ ?b"}`
   - **Output**: Array of `{name, type, module, doc}`
   - **Rate Limit**: 3 requests per 30 seconds
   - **Use Case**: Search for theorems by type signature

2. **lean-lsp-mcp_leansearch**
   - **Purpose**: Natural language search in Lean libraries
   - **Input**: `{"query": "list concatenation associativity"}`
   - **Output**: Array of `{name, type, module, doc, relevance}`
   - **Rate Limit**: 3 requests per 30 seconds
   - **Use Case**: Search for theorems using natural language

3. **lean-lsp-mcp_local_search**
   - **Purpose**: Search local project files
   - **Input**: `{"query": "modal logic", "file_pattern": "*.lean"}`
   - **Output**: Array of `{file, line, column, match}`
   - **Rate Limit**: None (local search)
   - **Use Case**: Find definitions/theorems in current project

4. **lean-lsp-mcp_leanfinder**
   - **Purpose**: Semantic search in Lean libraries
   - **Input**: `{"query": "commutativity of addition"}`
   - **Output**: Array of `{name, type, module, similarity}`
   - **Rate Limit**: 3 requests per 30 seconds
   - **Use Case**: Find semantically similar theorems

5. **lean-lsp-mcp_state_search**
   - **Purpose**: Premise search for proof states
   - **Input**: `{"goal": "n + m = m + n", "hypotheses": ["n : Nat", "m : Nat"]}`
   - **Output**: Array of `{name, type, module, applicability}`
   - **Rate Limit**: 3 requests per 30 seconds
   - **Use Case**: Find theorems applicable to current proof state

## Troubleshooting

### MCP Server Not Starting

**Symptom**: lean-lsp-mcp server does not appear in OpenCode server list

**Possible Causes**:
1. `opencode.json` syntax error (invalid JSON)
2. lean-lsp-mcp not installed
3. Server startup timeout (default 5s may be too short)
4. Environment variable resolution failure

**Solutions**:
1. Validate JSON syntax (no comments, trailing commas, etc.)
2. Install lean-lsp-mcp: `npm install -g lean-lsp-mcp`
3. Increase timeout: `"timeout": 10000` (10 seconds)
4. Check environment variables: `echo $PWD`

### Tools Not Available to Agent

**Symptom**: Agent cannot use lean-lsp-mcp tools

**Possible Causes**:
1. Tools disabled globally without per-agent enablement
2. Agent name mismatch in configuration
3. Tool name typo in agent definition

**Solutions**:
1. Check `tools` section: `"lean-lsp-mcp*": false` requires per-agent enablement
2. Verify agent name matches exactly (case-sensitive)
3. Verify tool names use correct prefix: `lean-lsp-mcp_*`

### Tool Timeout Errors

**Symptom**: MCP tool calls timeout

**Possible Causes**:
1. Default timeout too short (5s)
2. LSP server slow to respond
3. Large Lean file processing

**Solutions**:
1. Increase tool timeout in agent definition (30s recommended)
2. Implement retry logic with exponential backoff
3. Use smaller code snippets for testing

### Rate Limit Errors

**Symptom**: Search tools return rate limit errors

**Possible Causes**:
1. Too many requests in short time (>3 per 30s)
2. Multiple agents using same tools concurrently

**Solutions**:
1. Implement rate limiting in agent logic
2. Add exponential backoff retry strategy
3. Use local_search for local queries (no rate limit)

### Environment Variable Not Resolved

**Symptom**: `{env:PWD}` not resolved correctly

**Possible Causes**:
1. Incorrect syntax (missing braces)
2. Environment variable not set
3. OpenCode version doesn't support `{env:VAR}` syntax

**Solutions**:
1. Use exact syntax: `"{env:PWD}"`
2. Set environment variable: `export LEAN_PROJECT_ROOT=/path/to/project`
3. Use hardcoded absolute path as fallback

## Best Practices

### 1. Selective Tool Enablement

**DO**:
```json
{
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

**DON'T**:
```json
{
  "tools": {
    "lean-lsp-mcp*": true
  }
}
```

### 2. Graceful Degradation

**DO**: Handle tool unavailability gracefully
```xml
<graceful_degradation>
  If lean-lsp-mcp tools unavailable:
  1. Log warning
  2. Continue with fallback approach
  3. Return partial status
  4. Recommend manual verification
</graceful_degradation>
```

**DON'T**: Fail task if MCP tools unavailable

### 3. Error Handling

**DO**: Implement comprehensive error handling
- Tool unavailable: Log warning, continue
- Timeout: Retry with backoff, then fallback
- Rate limit: Wait and retry
- Connection error: Log error, fallback

**DON'T**: Assume MCP tools always work

### 4. Context Window Optimization

**DO**: Enable only needed tools per agent
- Implementation agent: 7 tools (diagnostic, goal, build, run, hover, outline, term_goal)
- Research agent: 5 tools (loogle, leansearch, local_search, leanfinder, state_search)

**DON'T**: Enable all tools globally (3000+ tokens overhead)

### 5. Natural Language Instructions

**DO**: Use clear natural language instructions
```xml
<process>
  1. Use lean-lsp-mcp_diagnostic_messages to check compilation
  2. Parse diagnostic results for errors
  3. Fix errors iteratively
</process>
```

**DON'T**: Try to import Python modules in agent definitions

## References

### OpenCode Documentation

- **MCP Servers**: https://opencode.ai/docs/mcp-servers/
- **Agents**: https://opencode.ai/docs/agents/
- **Configuration**: https://opencode.ai/config.json

### External Documentation

- **lean-lsp-mcp PyPI**: https://pypi.org/project/lean-lsp-mcp/
- **Model Context Protocol**: https://modelcontextprotocol.io/
- **Lean 4 Documentation**: https://lean-lang.org/lean4/doc/

### Local Files

- **opencode.json**: Project-level MCP configuration
- **lean-implementation-agent.md**: `.opencode/agent/subagents/lean-implementation-agent.md`
- **lean-research-agent.md**: `.opencode/agent/subagents/lean-research-agent.md`
- **Custom MCP Client**: `.opencode/tool/mcp/client.py` (deprecated for OpenCode agents)

## Future Enhancements

1. **Additional MCP Servers**
   - Context7: Documentation search
   - Grep: GitHub code search

2. **Usage Metrics**
   - Track MCP tool usage and effectiveness
   - Monitor context window impact
   - Optimize tool enablement based on usage

3. **Advanced Error Handling**
   - Retry with exponential backoff
   - Circuit breaker pattern
   - Fallback chain (MCP → CLI → Web)

4. **Tool Chaining**
   - Combine multiple MCP tools for complex workflows
   - Example: diagnostic_messages → goal → hover_info → fix

5. **Performance Optimization**
   - Adjust tool enablement based on actual usage patterns
   - Cache tool responses
   - Batch tool calls where possible

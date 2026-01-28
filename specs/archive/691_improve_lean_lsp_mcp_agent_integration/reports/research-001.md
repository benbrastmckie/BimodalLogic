# Research Report: Task #691

**Task**: 691 - improve_lean_lsp_mcp_agent_integration
**Started**: 2026-01-27T15:00:00Z
**Completed**: 2026-01-27T15:45:00Z
**Effort**: Medium (research + documentation)
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis (.claude/agents/, .claude/skills/, .mcp.json)
- Claude Code official documentation (code.claude.com)
- GitHub Issues (#13898, #14496, #13605, #6915, #4182)
- Web search for 2026 MCP best practices
**Artifacts**: - This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

The issue where "agents don't receive and continue with tokens the MCP returns" is a **known Claude Code platform bug**, not a configuration problem in this project. Custom subagents spawned via the Task tool have inconsistent or no access to project-level MCP servers. This affects the lean-lsp-mcp integration because:

1. **Custom subagents cannot access project-scoped MCP servers** (`.mcp.json`) - they hallucinate results instead of making real calls
2. **Complex prompts cause MCP tool access failures** - subagents claim tools don't exist
3. **Background subagents cannot access MCP tools at all**

**Key Finding**: The current architecture is correct. The issue is a known Claude Code bug documented in multiple GitHub issues (#13898, #14496, #13605).

## Context & Scope

### What Was Researched
1. Current lean-lsp-mcp configuration in this project
2. Agent and skill architecture for Lean workflows
3. Claude Code 2026 MCP documentation and best practices
4. Known issues with subagent MCP tool access

### Current Configuration

**MCP Server** (`.mcp.json`):
```json
{
  "mcpServers": {
    "lean-lsp": {
      "type": "stdio",
      "command": "uvx",
      "args": ["lean-lsp-mcp"],
      "env": {
        "LEAN_LOG_LEVEL": "WARNING",
        "LEAN_PROJECT_PATH": "/home/benjamin/Projects/ProofChecker"
      }
    }
  }
}
```

**Settings** (`.claude/settings.json`):
```json
{
  "permissions": {
    "allow": ["mcp__lean-lsp__*", ...]
  }
}
```

**Settings.local** (`.claude/settings.local.json`):
```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["lean-lsp"]
}
```

### Agent Architecture

Both lean-research-agent and lean-implementation-agent:
- Are custom agents in `.claude/agents/`
- Document MCP tools in their "Allowed Tools" section
- Are spawned via Task tool from thin wrapper skills
- Expected to use tools like `mcp__lean-lsp__lean_goal`, `mcp__lean-lsp__lean_leansearch`, etc.

## Findings

### 1. Root Cause: Known Claude Code Bugs

Multiple GitHub issues document the exact problem described:

| Issue | Title | Status |
|-------|-------|--------|
| [#13898](https://github.com/anthropics/claude-code/issues/13898) | Custom Subagents Cannot Access Project-Scoped MCP Servers | Open |
| [#14496](https://github.com/anthropics/claude-code/issues/14496) | Task tool subagents fail to access MCP tools with complex prompts | Closed (duplicate) |
| [#13605](https://github.com/anthropics/claude-code/issues/13605) | Custom plugin subagents cannot access MCP tools | Open |
| [#13254](https://github.com/anthropics/claude-code/issues/13254) | Background subagents cannot access MCP tools | Open |

**Test Matrix from #13898**:
| Subagent Type | MCP Server Location | Result |
|---|---|---|
| Built-in (`general-purpose`) | Local (`.mcp.json`) | Works |
| Built-in (`general-purpose`) | Global (`~/.claude/mcp.json`) | Works |
| Custom (`.claude/agents/`) | Local (`.mcp.json`) | **Hallucinates** |
| Custom (`.claude/agents/`) | Global (`~/.claude/mcp.json`) | Works |

**Hallucination Evidence**: When custom subagents try to use MCP tools, they return plausible-looking but **incorrect** results instead of making actual MCP calls.

### 2. Specific Failure Modes

**Mode A: Complex Prompt Failure**
- Simple, direct prompts successfully access MCP tools
- Complex multi-step prompts result in subagent claiming tools are unavailable
- Same tools work fine in the parent session

**Mode B: Project-Scope vs User-Scope**
- Project-level `.mcp.json` configuration is NOT inherited by custom subagents
- User-level `~/.claude.json` configuration IS inherited
- This contradicts [official documentation](https://code.claude.com/docs/en/sub-agents):
  > "MCP Tools: Subagents can access MCP tools from configured MCP servers. When the tools field is omitted, subagents inherit all MCP tools available to the main thread."

**Mode C: Background Execution**
- Background subagents (`run_in_background: true`) cannot access MCP tools at all
- This is by design according to docs, but applies even when foreground

### 3. Why Current Architecture Should Work

The agent definitions are correct:
- Agents document the MCP tools they need
- Skills use Task tool properly to spawn subagents
- MCP server is correctly configured and works in main conversation
- Permissions allow `mcp__lean-lsp__*`

The bug is in Claude Code's subagent MCP tool inheritance, not in this project's configuration.

### 4. Documented Workarounds

**Workaround 1: Move MCP to User Scope**
```bash
claude mcp add lean-lsp --scope user --transport stdio -- uvx lean-lsp-mcp
```
Or manually add to `~/.claude.json`:
```json
{
  "mcpServers": {
    "lean-lsp": {
      "command": "uvx",
      "args": ["lean-lsp-mcp"],
      "env": { "LEAN_PROJECT_PATH": "/home/benjamin/Projects/ProofChecker" }
    }
  }
}
```
**Tradeoff**: Configuration is no longer project-portable.

**Workaround 2: Use Built-in `general-purpose` Subagent**
Instead of custom agents, use:
```yaml
subagent_type: "general-purpose"
```
**Tradeoff**: Loses specialized system prompts and context loading.

**Workaround 3: Simple Prompt + Resume Pattern**
Start subagent with simple prompt to initialize MCP connection, then resume with complex work:
```python
# First call - simple (establishes MCP)
result1 = Task(prompt="Call mcp__lean-lsp__lean_local_search with query='Nat'", ...)

# Second call - resume with complex work
result2 = Task(prompt="Now execute the full research...", resume=result1.agentId, ...)
```
**Tradeoff**: Added complexity, extra API calls.

**Workaround 4: Perform MCP Calls at Skill Level**
Have the skill (not subagent) make MCP calls and pass results to subagent.
**Tradeoff**: Defeats purpose of thin wrapper pattern; bloats skill.

### 5. Claude Code 2026 MCP Best Practices

From official documentation:

**Scope Recommendations**:
- Use **project scope** (`.mcp.json`) for team-shared servers
- Use **user scope** (`~/.claude.json`) for personal utilities
- Use **local scope** for experimental configurations

**Subagent Limitations** (Documented):
- Subagents cannot spawn other subagents
- Background subagents cannot access MCP tools
- Tool Search activates when MCP tools exceed 10% of context

**Tool Permissions**:
- `mcp__lean-lsp__*` wildcard pattern is correct
- Use `/mcp` command to verify server status
- Use `--mcp-debug` flag for troubleshooting

## Decisions

1. **Do not change the fundamental architecture** - It is correct; the issue is a platform bug.
2. **Document the known issue** - Create awareness that this is not a local configuration problem.
3. **Evaluate workarounds based on tradeoffs** - User-scope migration is most reliable but least portable.
4. **Consider hybrid approach** - Use user-scope for reliability, keep `.mcp.json` for documentation.

## Recommendations

### Immediate (High Confidence)

1. **Migrate lean-lsp to user scope** as a workaround:
   ```bash
   claude mcp add lean-lsp --scope user --transport stdio -- uvx lean-lsp-mcp
   ```
   Add environment variables for project path.

2. **Keep `.mcp.json` for documentation** - Don't remove it; it documents the intended configuration.

3. **Add monitoring** - Have agents log when MCP tools return unexpected empty results or hallucination patterns.

### Medium-Term (When Bugs Are Fixed)

4. **Watch GitHub issues** - #13898 and #13605 are the primary tracking issues.

5. **Test after Claude Code updates** - Each release may fix the subagent MCP inheritance.

6. **Remove user-scope workaround** when project-scope works reliably.

### Architecture Improvements (Optional)

7. **Simplify agent prompts** - Shorter prompts may avoid the complex-prompt failure mode.

8. **Add MCP verification step** - Have agents verify tool availability before proceeding.

9. **Consider Tool Search** - When MCP tools are numerous, enable `ENABLE_TOOL_SEARCH=true`.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| User-scope config not portable | Medium | Keep `.mcp.json` for documentation; create setup script |
| Hallucinated results undetected | High | Add verification steps; check for "no goals" vs fake goals |
| Future Claude Code changes break workaround | Low | Monitor release notes; maintain both configs |
| Increased complexity | Medium | Document workarounds clearly; automate setup |

## Appendix

### Search Queries Used
- "Claude Code MCP server integration best practices 2026"
- "Claude Code subagent MCP tools not working Task tool delegation"

### Key Documentation References
- [Claude Code MCP Docs](https://code.claude.com/docs/en/mcp)
- [Claude Code Subagents Docs](https://code.claude.com/docs/en/sub-agents)
- [GitHub Issue #13898](https://github.com/anthropics/claude-code/issues/13898)
- [GitHub Issue #14496](https://github.com/anthropics/claude-code/issues/14496)

### Current Agent Tool Lists

**lean-research-agent MCP tools**:
- mcp__lean-lsp__lean_leansearch (3 req/30s)
- mcp__lean-lsp__lean_loogle (3 req/30s)
- mcp__lean-lsp__lean_leanfinder (10 req/30s)
- mcp__lean-lsp__lean_local_search (no limit)
- mcp__lean-lsp__lean_hover_info
- mcp__lean-lsp__lean_state_search (3 req/30s)
- mcp__lean-lsp__lean_hammer_premise (3 req/30s)

**lean-implementation-agent MCP tools**:
- mcp__lean-lsp__lean_goal (MOST IMPORTANT)
- mcp__lean-lsp__lean_diagnostic_messages
- mcp__lean-lsp__lean_hover_info
- mcp__lean-lsp__lean_completions
- mcp__lean-lsp__lean_multi_attempt
- mcp__lean-lsp__lean_local_search
- mcp__lean-lsp__lean_state_search (3 req/30s)
- mcp__lean-lsp__lean_hammer_premise (3 req/30s)

### Verification Commands

Check MCP server status:
```bash
# In Claude Code
/mcp

# Debug mode
claude --mcp-debug
```

Check configuration:
```bash
claude mcp list
claude mcp get lean-lsp
```

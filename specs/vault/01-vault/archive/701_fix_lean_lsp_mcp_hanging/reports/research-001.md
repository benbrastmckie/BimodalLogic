# Research Report: Task #701

**Task**: 701 - Fix lean-lsp-mcp hanging issue
**Date**: 2026-01-28
**Focus**: Root cause analysis of subagent hanging after MCP tool calls

## Summary

The lean-lsp-mcp hanging issue appears to be caused by **multiple independent bugs** at different layers of the system. The subagent makes MCP calls that may or may not return, but even when they DO return successfully, the agent appears to hang without processing the response. This is a critical finding that distinguishes this issue from simple MCP timeout problems.

## Root Cause Analysis

### Primary Hypothesis: Complex Prompt MCP Access Bug (Issue #14496)

Based on the observed behavior, the most likely root cause is [Claude Code Issue #14496](https://github.com/anthropics/claude-code/issues/14496): **Task tool subagents fail to access MCP tools with complex prompts**.

**Evidence**:
1. The lean-research-agent and lean-implementation-agent prompts are highly complex (400+ lines of instructions)
2. Issue #14496 describes exactly this pattern: simple prompts work, complex prompts cause MCP tools to become "unavailable" or hang
3. The screenshot shows MCP tool calls were made but the agent stopped processing afterward
4. Token counter stopped incrementing (1.7k tokens, later 2.2k tokens) indicating agent is not generating more output

**Key Symptom from Issue #14496**:
> "Complex multi-step prompts result in the subagent claiming tools are unavailable - even though the same tools work in the parent session."

### Secondary Factor: MCP Server Stuck Detection Missing (Issue #15945)

[Claude Code Issue #15945](https://github.com/anthropics/claude-code/issues/15945) documents that Claude Code has **NO timeout mechanism** for MCP server operations:

- MCP servers can hang indefinitely with no detection
- No watchdog timer to detect non-responsive servers
- No automatic cleanup or recovery mechanism
- Can result in 16+ hour complete system freezes

### Tertiary Factor: lean-lsp-mcp Diagnostic Hang (Issue #115)

[lean-lsp-mcp Issue #115](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115) describes the server halting specifically on `lean_diagnostic_messages` calls after import modifications:

- Server hangs in `_wait_for_diagnostics` function
- Underlying Lean language server bug in v4.24.0
- **Fixed in Lean 4.26.0+**

**Good news**: Your system runs Lean 4.27.0-rc1, so this specific issue should NOT affect you.

### Quaternary Factor: Silent MCP Tool Failures (Issue #13890)

[Claude Code Issue #13890](https://github.com/anthropics/claude-code/issues/13890) describes subagents losing the ability to call MCP tools **silently**:

- Subagent believes operation succeeded
- Nothing actually happens
- No error messages displayed

## The Multi-Bug Cascade

The hanging behavior you're experiencing appears to be this cascade:

```
1. Complex agent prompt loaded into Task tool subagent
   ↓
2. MCP tool access becomes flaky due to Issue #14496
   ↓
3. MCP calls either:
   a. Silently fail (Issue #13890) - agent thinks it worked
   b. Hang indefinitely (Issue #15945) - no timeout
   c. Return but agent doesn't process (Issue #14496 variant)
   ↓
4. Agent becomes stuck, token counter stops
   ↓
5. No recovery mechanism kicks in
```

## Environment Validation

| Component | Version | Status |
|-----------|---------|--------|
| Lean | 4.27.0-rc1 | OK (not affected by #115) |
| lean-lsp-mcp | via uvx | OK (user-scope config) |
| Claude Code | Latest | Affected by #14496, #15945 |

MCP configuration is correct in `~/.claude.json`:
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

## Workarounds

### Workaround 1: Resume Pattern (Most Promising)

From Issue #14496's documented workaround:

> "Split complex operations into multiple Task calls. Start with simple prompt, then use resume parameter for complex work."

**Implementation**:
1. Modify lean-research-agent to start with minimal prompt
2. Use `resume` parameter to continue with full instructions
3. This appears to restore MCP tool access

**Example**:
```
# First call - simple
Task(prompt="Start Lean research for task 697", subagent_type="lean-research-agent")

# Second call - resume with complex work
Task(resume=previous_agent_id, prompt="Now execute full research protocol")
```

### Workaround 2: Main Agent Direct Execution

For critical Lean tasks, bypass subagent entirely:
- Use Skill tool directly from main conversation
- Main conversation has reliable MCP access
- Trade-off: Uses more context tokens in main conversation

### Workaround 3: Reduced Agent Complexity

Simplify agent prompts significantly:
- Move detailed instructions to context files (loaded via @-references)
- Keep agent core instructions under 100 lines
- Test if this reduces MCP access failures

### Workaround 4: Pre-build Project

From lean-lsp-mcp documentation:
> "Some clients might timeout during the lake serve process. Therefore, it is recommended to run `lake build` manually before starting the MCP."

Run before Claude sessions:
```bash
cd /home/benjamin/Projects/ProofChecker && lake build
```

### Workaround 5: MCP Timeout Environment Variable

Configure timeout for MCP server startup:
```bash
MCP_TIMEOUT=60000 claude
```

This sets a 60-second timeout for MCP operations (default is lower).

## Recommendations

### Immediate (Today)

1. **Try Workaround 1**: Modify skill-lean-research to use the resume pattern
   - Start subagent with minimal prompt
   - Resume with full context after MCP tools are confirmed available

2. **Pre-build project**: Run `lake build` before research/implement sessions

### Short-Term (This Week)

3. **Simplify agent prompts**: Extract detailed instructions from agent files into context files
   - Target: <100 lines of core instructions per agent
   - Load details via @-references within subagent

4. **Add MCP availability check**: Have agents verify MCP tools are available before proceeding
   - Call `lean_local_search` with simple query as canary
   - If fails, return partial immediately rather than hanging

### Medium-Term (Track Upstream)

5. **Monitor Claude Code issues**:
   - Issue #14496 (complex prompts + MCP)
   - Issue #15945 (MCP timeout/stuck detection)
   - Issue #13890 (silent MCP failures)

6. **Consider fallback architecture**:
   - Detect MCP unavailability
   - Route to main agent for critical operations
   - Accept higher token usage for reliability

## Technical Details

### Screenshot Analysis

The screenshot shows the agent sequence:
1. MCP tool calls issued: `lean_local_search("set_lindenbaum")`, `lean_diagnostic_messages`
2. Agent entered "Waiting" state
3. Token counter stopped incrementing
4. No further progress

This suggests the MCP calls may have returned but the agent failed to process the response, consistent with Issue #14496's "complex prompt" failure mode.

### Related GitHub Issues

| Issue | Description | Status |
|-------|-------------|--------|
| [Claude Code #15945](https://github.com/anthropics/claude-code/issues/15945) | MCP causes 16+ hour hang, no timeout | Open |
| [Claude Code #14496](https://github.com/anthropics/claude-code/issues/14496) | Complex prompts fail MCP access | Closed (duplicate of #13890) |
| [Claude Code #13898](https://github.com/anthropics/claude-code/issues/13898) | Custom subagents can't access project-scoped MCP | Open |
| [Claude Code #13890](https://github.com/anthropics/claude-code/issues/13890) | Silent MCP/Write failures in subagents | Open |
| [lean-lsp-mcp #115](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115) | Diagnostic hang after imports | Open (Lean bug) |

## Next Steps

1. **Test resume pattern** by modifying skill-lean-research
2. **Create minimal reproduction case** for upstream bug report
3. If Workaround 1 works, document it in agent files
4. Consider implementing MCP canary check in all Lean agents

## Sources

- [Claude Code Issue #15945 - MCP Server Causes 16+ Hour Hang](https://github.com/anthropics/claude-code/issues/15945)
- [Claude Code Issue #14496 - Task tool subagents fail MCP with complex prompts](https://github.com/anthropics/claude-code/issues/14496)
- [Claude Code Issue #13890 - Subagents unable to write files and call MCP tools silently](https://github.com/anthropics/claude-code/issues/13890)
- [Claude Code Issue #13898 - Custom Subagents Cannot Access Project-Scoped MCP Servers](https://github.com/anthropics/claude-code/issues/13898)
- [lean-lsp-mcp Issue #115 - Server halts on lean_diagnostic_messages](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115)
- [lean-lsp-mcp GitHub Repository](https://github.com/oOo0oOo/lean-lsp-mcp)
- [Claude Code MCP Documentation](https://code.claude.com/docs/en/mcp)

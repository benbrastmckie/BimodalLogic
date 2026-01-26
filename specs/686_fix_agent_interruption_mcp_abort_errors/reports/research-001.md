# Research Report: Fix Agent Interruption MCP Abort Errors

- **Task**: 686 - Fix agent interruption MCP abort errors
- **Started**: 2026-01-26T06:00:00Z
- **Completed**: 2026-01-26T06:45:00Z
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: Related to 619, 672, 674
- **Sources/Inputs**:
  - Claude Code GitHub Issues (#6594, #18057, #19623)
  - MCP best practices documentation
  - Current agent files (.claude/agents/)
  - Error handling patterns (.claude/rules/error-handling.md)
  - Checkpoint patterns (.claude/context/core/patterns/)
  - Related task research (619, 672, 674)
- **Artifacts**: specs/686_fix_agent_interruption_mcp_abort_errors/reports/research-001.md
- **Standards**: report-format.md

## Executive Summary

- MCP AbortError -32001 is a request timeout error that occurs when MCP tool calls exceed timeout limits (typically 60 seconds)
- Claude Code has documented subagent termination bugs where errors cascade to kill all subagents via shared AbortController
- Agents fail to write metadata files when interrupted, leaving tasks stuck in "researching" or "implementing" status
- The current agent architecture lacks defensive patterns for MCP tool failures and interruption handling
- Solution requires three-pronged approach: early metadata file creation, MCP error recovery patterns, and interruption-aware cleanup

## Context & Scope

This research investigates MCP AbortError -32001 failures affecting the lean-research-agent and lean-implementation-agent. Root cause analysis from /research 657 and /implement 630 failures revealed:

1. lean-research-agent interrupted during `lean_local_search` calls
2. lean-implementation-agent interrupted during `lean_diagnostic_messages` call

Both agents failed to write return metadata files, leaving tasks stuck in intermediate status states. The system needs improvements for:
- Error recovery for MCP tool failures
- Graceful interruption handling
- Partial progress preservation
- Metadata file writing on timeout/abort

## Findings

### 1. Root Cause: MCP AbortError -32001

**Error Description**: The -32001 error code indicates a request timeout in the MCP protocol. This occurs when:
- MCP tool calls exceed the configured timeout (60 seconds default)
- Connection issues between Claude Code and MCP servers
- MCP server becomes unresponsive during long operations

**Source**: [MCPcat Guide on Error -32001](https://mcpcat.io/guides/fixing-mcp-error-32001-request-timeout/)

**Observed Behavior**:
- Tool call hangs for 30-60 seconds showing "Honking..." or similar status
- Eventually returns `AbortError: The operation was aborted`
- Agent execution terminates without completing cleanup operations

**Key Insight**: The lean-lsp MCP server tools (`lean_local_search`, `lean_diagnostic_messages`) can timeout during complex Lean file processing, triggering abort conditions.

### 2. Claude Code Subagent Termination Bug (Issue #6594)

**Critical Bug**: Claude Code versions 1.0.85+ introduced a regression where a **shared AbortController** causes all subagents to terminate when any single subagent encounters an error.

**Mechanism**:
```
- All subagents share single AbortController
- Any API error/rate limit triggers abortController.abort()
- All active subagents receive termination signal simultaneously
- No individual error isolation or recovery
```

**Impact**: When lean-lsp returns AbortError, the subagent terminates immediately without writing metadata files.

**Source**: [GitHub Issue #6594](https://github.com/anthropics/claude-code/issues/6594)

### 3. Skill Tool Abort Crash (Issue #18057)

**Related Bug**: When a subagent encounters a tool error (is_error: true), the subagent can crash instead of handling the error gracefully.

**Evidence from logs**:
```json
// Tool returns error
{"type":"tool_result","is_error":true,...}
// Log ends abruptly - process crashed
```

**Implication**: MCP tool errors may cause immediate agent termination before cleanup code executes.

**Source**: [GitHub Issue #18057](https://github.com/anthropics/claude-code/issues/18057)

### 4. Current Agent Error Handling Gaps

Analysis of current agent files reveals error handling gaps:

**lean-research-agent.md** (lines 254-288):
- Handles rate limiting with fallback chain
- Handles "no results found" with partial status
- Handles timeout/interruption with partial status
- **Gap**: No try-catch patterns around MCP tool calls
- **Gap**: Metadata file written only at Stage 6 (after all work done)
- **Gap**: No early checkpoint before MCP tool execution

**lean-implementation-agent.md** (lines 371-412):
- Handles build failure with diagnostics
- Handles proof stuck with state documentation
- Handles timeout with partial commit
- **Gap**: Same late-stage metadata writing pattern
- **Gap**: No MCP-specific error recovery

**Systemic Issue**: Both agents write metadata files as a final step (Stage 6-7). If interrupted before reaching that stage, no metadata is written.

### 5. Current Checkpoint Architecture

The checkpoint-in-commands pattern provides good infrastructure but has gaps:

**What Works**:
- Commands handle GATE IN/OUT checkpoints
- Session ID tracking throughout delegation
- Metadata file exchange pattern defined

**What's Missing**:
- Agents don't create metadata files incrementally
- No "early write, update later" pattern for metadata
- No MCP tool call wrapper with timeout/retry

### 6. Industry Best Practices for MCP Error Handling

**Timeout Handling**:
- Implement per-request timeouts with configurable limits
- Log timeout events with context
- Return structured error responses

**Graceful Degradation**:
- Circuit breakers for repeatedly failing services
- Fallback to cached data or safe defaults
- Application should start even when servers unavailable

**Retry Strategies**:
- Exponential backoff with jitter
- Circuit breaker to prevent cascading failures
- Maximum retry limits

**Sources**:
- [MCPcat Error Handling Guide](https://mcpcat.io/guides/error-handling-custom-mcp-servers/)
- [Stainless MCP Portal](https://www.stainless.com/mcp/error-handling-and-debugging-mcp-servers/)
- [Octopus MCP Timeout Retry](https://octopus.com/blog/mcp-timeout-retry)

### 7. Related Task Findings

**Task 619** (Agent System Architecture Upgrade):
- Investigated context:fork feature for subagent isolation
- GitHub #16803 shows plugin vs user-level distinction
- context:fork may work for user-level skills in .claude/

**Task 672** (Implement Agent System Upgrade):
- Proposed 4-phase upgrade with file-based metadata exchange
- Phase 2 addressed workflow ownership migration
- Implementation status: revised but not executed

**Task 674** (Systematic Architecture Improvement):
- Identified command bypass issues
- Documented integrated preflight/postflight patterns
- Proposed inline status updates to reduce halt points

**Key Pattern**: These tasks identified that skill postflight code may not execute due to Claude Code Issue #17351. This is exactly what happens when MCP tools abort - the agent terminates before reaching its cleanup/metadata-writing stage.

### 8. Current Error Types in errors.json

The existing error schema supports relevant error types:
- `timeout` - Operation exceeded time limit
- `tool_unavailable` - MCP tool not responding
- `delegation_hang` - Subagent not responding

**Gap**: No specific type for MCP AbortError, which is distinct from simple timeout.

## Decisions

Based on the research findings, the following architectural decisions are recommended:

1. **Early Metadata File Creation**: Agents should create metadata files at the START of execution with status "in_progress", then update to final status at completion. This ensures partial state is preserved on interruption.

2. **MCP Tool Wrapper Pattern**: Create a wrapper pattern for MCP tool calls that handles AbortError with retry and graceful degradation.

3. **Checkpoint-Aware Interruption**: Agents should write checkpoint information that allows resume from the last successful point.

4. **New Error Type**: Add `mcp_abort_error` to the error schema for proper categorization.

5. **Defensive Tool Invocation**: All MCP tool calls should be wrapped in try-catch equivalent patterns with timeout awareness.

## Recommendations

### Priority 1: Early Metadata File Pattern (High Impact, Low Risk)

**Current Flow**:
```
Stage 1-5: Execute work
Stage 6: Write metadata file  <-- INTERRUPTED HERE = NO METADATA
Stage 7: Return summary
```

**Proposed Flow**:
```
Stage 0: Create metadata file with status="in_progress"
Stage 1-5: Execute work (update metadata incrementally if significant progress)
Stage 6: Update metadata file with status="researched/implemented"
Stage 7: Return summary
```

**Implementation**:
Add to agent execution flow:
```markdown
### Stage 0: Initialize Metadata File

Create initial metadata file immediately upon starting:

Write to `specs/{N}_{SLUG}/.meta/{operation}-return-meta.json`:
{
  "status": "in_progress",
  "started_at": "{ISO8601}",
  "metadata": {
    "session_id": "{from delegation context}",
    "agent_type": "{agent-type}",
    "delegation_depth": 1
  },
  "partial_progress": {}
}

This ensures metadata exists for command postflight even if agent is interrupted.
```

### Priority 2: MCP Tool Error Recovery Pattern (High Impact, Medium Risk)

**Create new pattern file**: `.claude/context/core/patterns/mcp-tool-recovery.md`

**Content Summary**:
- Wrapper pattern for MCP tool calls
- Retry with exponential backoff (1s, 2s, 4s max)
- Graceful degradation when tool unavailable
- Fallback to alternative tools (e.g., lean_leansearch -> lean_loogle)
- Log errors to errors.json with mcp_abort_error type

**Agent Integration**:
```markdown
### MCP Tool Error Recovery

When MCP tool calls fail with AbortError (-32001):
1. Log the error with context
2. Retry once with 5-second delay
3. If retry fails, try alternative tool
4. If all fail, write partial status to metadata file
5. Continue with available information or return partial
```

### Priority 3: Add mcp_abort_error to Error Schema (Low Impact, Low Risk)

**Update errors.json schema**:
```json
{
  "type": "mcp_abort_error",
  "severity": "high",
  "message": "MCP tool {tool_name} aborted with error {error_code}",
  "context": {
    "tool_name": "lean_local_search",
    "error_code": -32001,
    "retry_attempted": true
  }
}
```

**Update .claude/rules/error-handling.md**:
Add new category under "External Errors":
- `mcp_abort_error` - MCP tool call aborted or timed out

### Priority 4: Update Agent Files (High Impact, Medium Risk)

**Files to Update**:
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/general-research-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/latex-implementation-agent.md`
- `.claude/agents/planner-agent.md`

**Changes per Agent**:
1. Add Stage 0 for early metadata file creation
2. Add MCP tool recovery patterns to error handling sections
3. Add incremental progress updates for long operations
4. Update Critical Requirements with interruption-aware patterns

### Priority 5: Command Postflight Enhancement (Medium Impact, Medium Risk)

**Enhance GATE OUT to handle partial metadata**:

Commands should check for partial/in_progress metadata and:
1. Keep task in "researching"/"implementing" status
2. Log the interruption to errors.json
3. Enable resume on next invocation

**Pattern addition to checkpoint-in-commands.md**:
```markdown
### Handling Interrupted Agents

If metadata file contains status="in_progress" or is missing entirely:
1. Check for partial_progress field in metadata
2. Keep task status unchanged (still "researching" etc.)
3. Log error to errors.json with type="delegation_interrupted"
4. Display message: "Agent interrupted. Run command again to resume."
```

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Early metadata file not cleaned up on success | Low | Commands already delete metadata in postflight |
| Retry logic adds latency to normal operations | Medium | Only retry after actual failure, use short timeouts |
| Incremental updates increase I/O | Low | Only update on significant progress milestones |
| Race condition in metadata file access | Low | Single writer (agent), single reader (command) |
| Claude Code internal abort not interceptable | High | Focus on defensive patterns within our control |

## Implementation Phases

**Phase 1 (Day 1): Core Patterns**
- Create mcp-tool-recovery.md pattern file
- Add mcp_abort_error to error types
- Update error-handling.md

**Phase 2 (Day 1-2): Agent Updates**
- Update lean-research-agent.md with early metadata + recovery
- Update lean-implementation-agent.md with same patterns
- Test with intentional timeout scenarios

**Phase 3 (Day 2): Complete Agent Coverage**
- Update remaining agent files
- Update planner-agent.md
- Create test scenarios for each agent type

**Phase 4 (Day 3): Command Integration**
- Enhance checkpoint-in-commands.md for partial metadata
- Test full workflow with interruption scenarios
- Document recovery procedures

## Appendix

### Search Queries Used
- "Claude Code MCP AbortError -32001 tool call interrupted"
- "Claude Code subagent Task tool termination abort interrupted"
- "MCP server timeout graceful degradation error handling best practices"

### Key GitHub Issues Referenced
- [#6594 - Subagent Termination Bug](https://github.com/anthropics/claude-code/issues/6594) - Shared AbortController cascade
- [#18057 - Skill Tool Abort Crash](https://github.com/anthropics/claude-code/issues/18057) - Error handling crash
- [#19623 - ExitPlanMode AbortError](https://github.com/anthropics/claude-code/issues/19623) - MCP interaction hang

### Documentation References
- [MCPcat Error Handling Guide](https://mcpcat.io/guides/error-handling-custom-mcp-servers/)
- [MCPcat Fix Error -32001](https://mcpcat.io/guides/fixing-mcp-error-32001-request-timeout/)
- [Stainless MCP Error Handling](https://www.stainless.com/mcp/error-handling-and-debugging-mcp-servers/)
- [Octopus MCP Timeout Retry](https://octopus.com/blog/mcp-timeout-retry)
- [Claude Code Subagents Doc](https://code.claude.com/docs/en/sub-agents)

### Related Internal Documentation
- .claude/agents/lean-research-agent.md
- .claude/agents/lean-implementation-agent.md
- .claude/rules/error-handling.md
- .claude/context/core/patterns/checkpoint-in-commands.md
- .claude/context/core/patterns/anti-stop-patterns.md
- specs/619_agent_system_architecture_upgrade/reports/research-003.md
- specs/674_systematic_command_skill_agent_architecture_improvement/reports/research-003.md

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
- **NEW FINDING**: Multiple concurrent lean-lsp-mcp instances via STDIO transport create resource contention, contributing significantly to timeout issues (confirmed by lean-lsp-mcp Issue #118 and #115)
- Claude Code has documented subagent termination bugs where errors cascade to kill all subagents via shared AbortController
- Agents fail to write metadata files when interrupted, leaving tasks stuck in "researching" or "implementing" status
- The current agent architecture lacks defensive patterns for MCP tool failures and interruption handling
- Solution requires four-pronged approach: optimize multi-instance setup, early metadata file creation, MCP error recovery patterns, and interruption-aware cleanup

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

### 9. Multi-Instance STDIO Transport Contention (NEW FINDING)

**Context**: ProofChecker workflow uses multiple concurrent Claude Code sessions (7+ instances) on the same project, each spawning independent lean-lsp-mcp server processes via STDIO transport.

**Root Cause Discovery**: Research confirms multiple concurrent lean-lsp-mcp instances via STDIO transport create resource contention and are a contributing factor to AbortError -32001 timeouts.

#### 9.1 STDIO Transport Architecture Limitation

**Source**: [MCP Framework - STDIO Transport](https://mcp-framework.com/docs/Transports/stdio-transport/), [MCPcat - Configuring Multiple Connections](https://mcpcat.io/guides/configuring-mcp-servers-multiple-simultaneous-connections/)

**Evidence**:
- STDIO transport supports **single client connection only**
- Each Claude session spawns **separate server process** (no sharing)
- Processes requests **sequentially** through stdin/stdout
- Benchmark performance: **0.64 requests/sec** under concurrent load
- Concurrent load failure rate: **96%** when handling multiple simultaneous requests
- Designed for "local, single-client scenarios like CLI tools and desktop applications"

**Impact**: 7 concurrent Claude sessions = 7 independent lean-lsp-mcp processes with 7x resource multiplication.

#### 9.2 Confirmed Resource Exhaustion Issue

**Source**: [lean-lsp-mcp Issue #118 - Build Concurrency Configuration](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118)

**Issue Description** (Opened Jan 23, 2026):
> "Some clients (or usage patterns) can cause **multiple concurrent lake build processes** to run, which may **exhaust memory and crash the MCP server** or host."

**Reported Behavior**:
> "Certain AI agents (notably Copilot) can trigger excessive memory consumption **exceeding 16GB** when improperly utilizing the server."

**Proposed Solution**: Three configurable build concurrency modes:
1. Permissive - Allow simultaneous builds (current behavior)
2. Abort with error - Cancel prior builds when new requests arrive
3. Abort with supersession - Replace prior builds, deliver final result to all subscribers

**Status**: Open issue with active discussion, no implementation yet.

#### 9.3 Confirmed Diagnostic Hang Issue

**Source**: [lean-lsp-mcp Issue #115 - Server Halts on Diagnostic Messages](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115)

**Issue Description** (Opened Jan 13, 2026, Reopened):
Server becomes unresponsive when calling `lean_diagnostic_messages` after editing Lean file imports (e.g., adding `import Mathlib`). Initial tool call works, but subsequent calls after import modifications cause indefinite hangs.

**Root Cause**:
> "Gets stuck in the function `_wait_for_diagnostics` of `leanclient/file_manager.py`, in particular on the loop `while pending_uris:` starting at line 877, as the `if future.done():` at line 888 is never satisfied"

Timeout detection fails because `any_rpc_pending` remains `True`, preventing loop exit.

**Reproducibility**: Fully reproducible on Lean 4.24.0 with Mathlib-dependent projects.

**Resolution**: Bug fixed in Lean 4.26.0 (LSP server bug, not lean-lsp-mcp bug).

**Workarounds**:
1. Upgrade to Lean 4.26.0
2. Restart server before tool calls
3. Run `lake build` manually before starting MCP server

#### 9.4 MCP General Concurrency Issues

**Source**: [agent0 Issue #912 - Resource Contention/Deadlock](https://github.com/agent0ai/agent-zero/issues/912)

**Evidence**:
> "When running multiple concurrent sessions, the system frequently **hangs or blocks** when both sessions attempt to use MCP tools simultaneously"

> "Sessions may be competing for the same MCP server process or local StdIO stream. If the framework does not isolate MCP instances per session or handle concurrent requests to a single-threaded MCP server, it results in **permanent block/timeout**"

**Key Insight**: Single-threaded MCP servers with STDIO transport cannot handle concurrent access safely.

#### 9.5 LSP Protocol Single-Server Assumption

**Source**: [Microsoft LSP Specification 3.17](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/), [GitHub Issue #1160 - Multiple Clients Support](https://github.com/microsoft/language-server-protocol/issues/1160)

**Protocol Limitation**:
> "The protocol currently assumes that **one server serves one tool**... Such sharing would require **additional protocol like document locking** to support concurrent editing."

**Resource Intensity**:
> "Language features can be resource intensive - to correctly validate a file, a Language Server needs to parse a large amount of files, build up Abstract Syntax Trees, and perform static program analysis."

#### 9.6 Lean 4 Build System Behavior

**Source**: [Lean 4 Lake README](https://github.com/leanprover/lean4/blob/master/src/lake/README.md), [Lean Theorem Prover - ArchWiki](https://wiki.archlinux.org/title/Lean_Theorem_Prover)

**Build System Behavior**:
- Each LSP instance triggers `lake build` on file changes
- Build cache (`.lake/` directory with `.olean` files) is **shared** across instances
- Build **processes** are independent (no coordination)
- Parallel compilation uses `j$(nproc)` workers per build
- Multiple concurrent builds = file locking contention on `.olean` files

**Calculation**: 7 instances × `lake build` × `j$(nproc)` workers = severe CPU/memory pressure

#### 9.7 Contributing Factor Analysis

**Why Multiple Instances Cause Timeouts**:

1. **Resource Multiplication**: 7 STDIO processes × memory footprint × CPU load = resource exhaustion
2. **Build Contention**: Concurrent `lake build` processes compete for:
   - Shared `.olean` file access (file locking)
   - CPU cores (7 × nproc parallel workers)
   - Memory (Issue #118: >16GB possible)
3. **Diagnostic Processing**: Each instance independently processes diagnostics for same files
4. **Timeout Cascade**: Resource exhaustion → slow diagnostics → 60s timeout → AbortError -32001
5. **Abort Controller Bug**: Claude Code Issue #6594 cascades abort to all subagents

**Why It Worked Before**:
- Fewer concurrent sessions (< 3-4 tolerable)
- Simpler Lean files (faster diagnostics)
- Smaller dependency graphs (less build overhead)
- Lean 4.24.0 LSP bug (Issue #115) recently emerged

**Critical Bottleneck Identified**:
```
Multiple STDIO instances × lake build × diagnostic processing
    ↓
Memory + CPU exhaustion
    ↓
lean_diagnostic_messages timeout (>60s)
    ↓
AbortError -32001
    ↓
Claude Code shared AbortController cascade
    ↓
All subagents terminated, no metadata written
```

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

### Priority 6: Optimize Multi-Instance lean-lsp-mcp Setup (High Impact, Low-Medium Risk)

**Context**: Multiple concurrent Claude Code sessions create resource multiplication via STDIO transport, contributing to timeout issues (Finding 9).

#### 6.1 Immediate Actions (Low Risk)

**A. Upgrade Lean to 4.26.0** (Fixes Issue #115):
```bash
cd /home/benjamin/Projects/ProofChecker
echo "leanprover/lean4:v4.26.0" > lean-toolchain
lake update
```

**Benefit**: Eliminates diagnostic hang bug in Lean LSP server

**B. Pre-build Project Before Sessions** (Prevents Issue #118):
```bash
cd /home/benjamin/Projects/ProofChecker
lake build
```

**Benefit**:
- Avoids concurrent `lake build` triggers
- Eliminates timeout on first diagnostic call
- Reduces memory pressure from parallel builds

**C. Configure Environment Variables**:

Add to `~/.claude.json` (user-scope MCP configuration):
```json
{
  "mcpServers": {
    "lean-lsp": {
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

**Benefit**:
- Reduces log I/O overhead
- Explicit project path prevents detection overhead
- Consistent configuration across sessions

#### 6.2 Moderate Actions (Medium Risk)

**D. Reduce Active Sessions During Lean Work**:
- Limit to 3-4 concurrent Claude sessions when using lean-lsp-mcp
- Keep other sessions for non-Lean tasks
- Monitor with `ps aux | grep lean-lsp-mcp | wc -l`

**Benefit**: Reduces resource multiplication factor by 50%+

#### 6.3 Advanced Solutions (Requires Testing)

**E. HTTP Transport Shared Server** (Medium Risk):

Instead of 7 STDIO instances, run 1 shared HTTP server:

```bash
# Terminal 1: Start single lean-lsp-mcp server
uvx lean-lsp-mcp --transport http --port 8080
```

Update **all** Claude sessions to connect:
```json
{
  "mcpServers": {
    "lean-lsp": {
      "transport": "http",
      "url": "http://localhost:8080",
      "env": {
        "LEAN_PROJECT_PATH": "/home/benjamin/Projects/ProofChecker"
      }
    }
  }
}
```

**Benefits**:
- 1 server process instead of 7 (7x resource reduction)
- HTTP transport designed for concurrent connections
- Shared build coordination (no parallel `lake build` conflicts)

**Risks**:
- Different latency characteristics than STDIO
- Single point of failure (one crash affects all sessions)
- Requires session restart to apply configuration

**Recommendation**: Test with 2-3 sessions before full adoption

#### 6.4 Future Solution (Awaiting Upstream)

**F. Monitor Issue #118 Implementation**:
- Track [lean-lsp-mcp Issue #118](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118)
- Implement build queue when available
- Expected behavior: Queue concurrent builds instead of parallel execution

**Benefit**: Prevents memory exhaustion without workflow changes

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Early metadata file not cleaned up on success | Low | Commands already delete metadata in postflight |
| Retry logic adds latency to normal operations | Medium | Only retry after actual failure, use short timeouts |
| Incremental updates increase I/O | Low | Only update on significant progress milestones |
| Race condition in metadata file access | Low | Single writer (agent), single reader (command) |
| Claude Code internal abort not interceptable | High | Focus on defensive patterns within our control |

## Implementation Phases

**Phase 0 (Immediate): Multi-Instance Optimization**
- Upgrade Lean to 4.26.0 (`echo "leanprover/lean4:v4.26.0" > lean-toolchain && lake update`)
- Run `lake build` before starting Claude sessions
- Configure environment variables in `~/.claude.json`
- Optional: Test HTTP transport shared server approach

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

**Phase 5 (Ongoing): Monitor Upstream**
- Track lean-lsp-mcp Issue #118 for build queue implementation
- Evaluate HTTP transport adoption based on Phase 0 testing
- Adjust session count recommendations based on observed performance

## Appendix

### Search Queries Used
- "Claude Code MCP AbortError -32001 tool call interrupted"
- "Claude Code subagent Task tool termination abort interrupted"
- "MCP server timeout graceful degradation error handling best practices"

### Key GitHub Issues Referenced

**Claude Code Issues**:
- [#6594 - Subagent Termination Bug](https://github.com/anthropics/claude-code/issues/6594) - Shared AbortController cascade
- [#18057 - Skill Tool Abort Crash](https://github.com/anthropics/claude-code/issues/18057) - Error handling crash
- [#19623 - ExitPlanMode AbortError](https://github.com/anthropics/claude-code/issues/19623) - MCP interaction hang

**lean-lsp-mcp Issues**:
- [#118 - Build Concurrency Configuration](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118) - Multiple concurrent builds exhaust memory
- [#115 - Server Halts on Diagnostic Messages](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115) - Diagnostic hang after import edits (fixed in Lean 4.26.0)

**MCP/LSP Protocol Issues**:
- [agent0 #912 - Resource Contention/Deadlock](https://github.com/agent0ai/agent-zero/issues/912) - MCP STDIO concurrent access hangs
- [LSP #1160 - Multiple Clients Support](https://github.com/microsoft/language-server-protocol/issues/1160) - Protocol single-server assumption

### Documentation References

**MCP Protocol & Transport**:
- [MCP Framework - STDIO Transport](https://mcp-framework.com/docs/Transports/stdio-transport/) - STDIO architecture and limitations
- [MCPcat - Configuring Multiple Connections](https://mcpcat.io/guides/configuring-mcp-servers-multiple-simultaneous-connections/) - Multi-connection best practices
- [MCPcat - Transport Comparison](https://mcpcat.io/guides/comparing-stdio-sse-streamablehttp/) - STDIO vs HTTP vs SSE
- [MCPcat Error Handling Guide](https://mcpcat.io/guides/error-handling-custom-mcp-servers/)
- [MCPcat Fix Error -32001](https://mcpcat.io/guides/fixing-mcp-error-32001-request-timeout/)
- [Stainless MCP Error Handling](https://www.stainless.com/mcp/error-handling-and-debugging-mcp-servers/)
- [Octopus MCP Timeout Retry](https://octopus.com/blog/mcp-timeout-retry)

**LSP Protocol**:
- [Microsoft LSP Specification 3.17](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) - Protocol assumptions and limitations
- [Claude Code Subagents Doc](https://code.claude.com/docs/en/sub-agents)

**Lean 4 & lean-lsp-mcp**:
- [lean-lsp-mcp GitHub](https://github.com/oOo0oOo/lean-lsp-mcp) - Main repository
- [lean-lsp-mcp PyPI](https://pypi.org/project/lean-lsp-mcp/) - Package documentation
- [Lean 4 Lake README](https://github.com/leanprover/lean4/blob/master/src/lake/README.md) - Build system documentation
- [Lean Theorem Prover - ArchWiki](https://wiki.archlinux.org/title/Lean_Theorem_Prover) - Build and cache behavior

### Related Internal Documentation
- .claude/agents/lean-research-agent.md
- .claude/agents/lean-implementation-agent.md
- .claude/rules/error-handling.md
- .claude/context/core/patterns/checkpoint-in-commands.md
- .claude/context/core/patterns/anti-stop-patterns.md
- specs/619_agent_system_architecture_upgrade/reports/research-003.md
- specs/674_systematic_command_skill_agent_architecture_improvement/reports/research-003.md

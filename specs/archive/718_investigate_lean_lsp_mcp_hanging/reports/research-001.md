# Research Report: Task #718

**Task**: 718 - Investigate lean-lsp MCP hanging during Lean tasks
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:30:00Z
**Effort**: Low-Medium
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Claude Code GitHub issues (#15945, #19623, #470, #424)
- lean-lsp-mcp GitHub issues (#115, #118)
- Project codebase (.claude/ documentation)
- Web search for MCP timeout issues
**Artifacts**:
- This research report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root cause identified**: Multiple contributing factors from both Claude Code platform and lean-lsp-mcp server
- **Primary issue**: lean-lsp-mcp issue #115 documents `lean_diagnostic_messages` halting after import edits, fixed in Lean v4.26+
- **Project is safe**: Uses Lean v4.27.0-rc1 toolchain (above the fix threshold)
- **Secondary issue**: Claude Code lacks proper timeout/watchdog for MCP tool calls (issue #15945)
- **Recommendations**: Focus on pre-build, timeout configuration, and MCP recovery patterns

## Context & Scope

### Problem Statement

Operations using `lean_diagnostic_messages` and `lean_file_outline` MCP tool calls hang indefinitely on file `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean`. This file is 936 lines with complex proof structures and currently has compilation errors.

### Research Questions

1. What causes MCP transport issues?
2. What lean-lsp server behaviors could cause hanging?
3. What file-specific compilation bottlenecks exist?
4. What known Claude Code MCP bugs apply?

## Findings

### 1. Claude Code Platform Issues (Known Bugs)

#### Issue #15945: MCP Server Causes 16+ Hour Hang (CRITICAL)

**Status**: Open, P0 priority requested

**Root Causes Identified**:
- No timeout configured for MCP server operations
- No watchdog/stuck detection mechanism
- Infinite resource accumulation (zombie processes)

**Impact**: MCP server connections can block indefinitely without any timeout or recovery mechanism. Claude Code waits forever without detecting stuck state.

**Reference**: https://github.com/anthropics/claude-code/issues/15945

#### Issue #19623: ExitPlanMode AbortError with MCP Servers

**Status**: Open

When MCP servers are active, certain tools hang for 30-60 seconds and fail with AbortError. The hypothesis is blocking in MCP server communication chain.

**Reference**: https://github.com/anthropics/claude-code/issues/19623

#### Issue #470: resetTimeoutOnProgress for Long MCP Calls

**Status**: Open

Requests `resetTimeoutOnProgress=True` to support long MCP tool calls. Currently MCP calls over 60 seconds fail due to -32001 timeout in MCP TypeScript SDK.

**Reference**: https://github.com/anthropics/claude-code/issues/470

### 2. lean-lsp-mcp Server Issues

#### Issue #115: Server Halts on `lean_diagnostic_messages` After Import Edits (DIRECTLY RELEVANT)

**Status**: Open (workaround available)

**Problem**: The lean-lsp-mcp server becomes unresponsive when calling `lean_diagnostic_messages` after adding imports.

**Root Cause**: Server gets stuck in `_wait_for_diagnostics` function. The `any_rpc_pending` flag remains true while awaiting diagnostic futures, causing timeout detection to fail.

**Workaround**: Upgrade Lean toolchain from v4.24.0 to v4.26.0 or later.

**Project Status**: **SAFE** - Uses Lean v4.27.0-rc1 (above fix threshold)

**Reference**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/115

#### Issue #118: Add Configurable Build Concurrency Modes

**Status**: Open

**Problem**: Multiple concurrent `lake build` processes can exhaust memory (>16GB), crash MCP server or host.

**Proposed Solutions**:
1. Permissive Mode: Maintain existing behavior
2. Abort with Error: Cancel prior builds, notify clients
3. Abort with Supersession: Terminate previous builds, deliver final result to all

**Relevance**: Multi-session Claude Code usage can trigger this issue.

**Reference**: https://github.com/oOo0oOo/lean-lsp-mcp/issues/118

### 3. File-Specific Analysis: SoundnessLemmas.lean

| Attribute | Value |
|-----------|-------|
| Lines | 936 |
| Size | 37KB |
| Imports | 3 (Truth, Derivation, Axioms) |
| Build Status | **FAILING** (type mismatch + sorry) |

**Compilation Issues Found**:
- Type mismatch error in `and_of_not_imp_not` usage
- Declaration uses `sorry` (2 instances: temp_t_future, temp_t_past)
- No .olean cache files exist for this module

**Impact on Diagnostics**: Files with compilation errors or incomplete proofs can cause extended diagnostic processing time. The LSP must process the entire file and dependent modules to report all errors.

### 4. Existing Project Mitigations

The project already has extensive documentation on MCP issues:

| Document | Content |
|----------|---------|
| `mcp-tool-recovery.md` | Error recovery patterns, fallback chains |
| `multi-instance-optimization.md` | Concurrency management, pre-build strategy |
| `early-metadata-pattern.md` | Interruption handling, progress preservation |
| `CLAUDE.md` | Direct execution migration for Lean skills |

**Key Finding**: Lean skills already use **direct execution** instead of subagent delegation to avoid MCP tool hanging issues (bugs #15945, #13254, #4580). This is documented in CLAUDE.md.

### 5. Transport and Configuration Analysis

**Current Configuration** (from .mcp.json):
```json
{
  "type": "stdio",
  "command": "uvx",
  "args": ["lean-lsp-mcp"],
  "env": {
    "LEAN_LOG_LEVEL": "WARNING",
    "LEAN_PROJECT_PATH": "/home/benjamin/Projects/ProofChecker"
  }
}
```

**STDIO Transport Limitations**:
- Single-threaded request handling
- No built-in connection pooling
- No automatic recovery/reconnection
- Each session spawns separate lean-lsp-mcp process

## Root Cause Synthesis

The hanging on SoundnessLemmas.lean is likely caused by a combination of:

1. **Compilation errors** - The file has active type mismatch errors requiring deep type elaboration
2. **No cached .olean** - Module must be compiled from scratch each time
3. **Claude Code timeout gap** - No timeout detection while waiting for MCP response
4. **STDIO blocking** - Single-threaded transport blocks on slow operations

**Why this specific file?**
- 936 lines with complex dependent type proofs
- Active compilation errors requiring full elaboration
- Located in deep module hierarchy (Boneyard/Metalogic/Soundness)
- Depends on Truth, Derivation, Axioms modules

## Decisions

1. **Continue using direct execution for Lean skills** - Correct mitigation already in place
2. **Pre-build is essential** - Always run `lake build` before diagnostic calls on modified files
3. **File with errors will be slow** - Accept that SoundnessLemmas.lean diagnostics will be slow until errors are fixed
4. **No upstream fix available yet** - Claude Code #15945 is open with no timeline

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Diagnostic calls hang indefinitely | Use pre-build, avoid diagnostics on files with known errors |
| Memory exhaustion from concurrent builds | Session throttling, pre-build strategy |
| Lost progress on timeout | Early metadata pattern already implemented |
| Future regressions | Monitor lean-lsp-mcp releases for fix to #118 |

## Recommendations

### Immediate Actions

1. **Fix SoundnessLemmas.lean compilation errors**
   - The type mismatch in `and_of_not_imp_not` usage
   - Complete the sorry'd temp_t_future and temp_t_past cases
   - This will significantly reduce diagnostic processing time

2. **Pre-build before diagnostic operations**
   ```bash
   cd /home/benjamin/Projects/ProofChecker && lake build
   ```

3. **Use lean_goal instead of lean_diagnostic_messages where possible**
   - `lean_goal` is faster for point-specific queries
   - `lean_diagnostic_messages` processes entire file

### Process Improvements

1. **Add timeout awareness to Lean workflows**
   - Document that files with errors may cause extended diagnostic delays
   - Recommend fixing compilation errors before running diagnostics

2. **Monitor upstream issues**
   - Claude Code #15945 (MCP timeout) - watch for fix
   - lean-lsp-mcp #118 (build concurrency) - watch for fix

### Long-term Considerations

1. **Consider SSE/HTTP transport** when lean-lsp-mcp supports it
   - Would allow connection pooling
   - Better timeout handling

2. **Contribute to lean-lsp-mcp #118**
   - Build queue functionality would help multi-session scenarios

## Appendix

### Search Queries Used

1. "Claude Code MCP hanging indefinitely diagnostic messages lean-lsp 2025 2026"
2. "lean-lsp-mcp diagnostic_messages hanging timeout issue 2025 2026"
3. "Claude Code MCP tool timeout AbortError 32001 github issues 2025 2026"

### References

**Claude Code Issues**:
- [#15945 - MCP Server Causes 16+ Hour Hang](https://github.com/anthropics/claude-code/issues/15945)
- [#19623 - ExitPlanMode AbortError with MCP](https://github.com/anthropics/claude-code/issues/19623)
- [#470 - resetTimeoutOnProgress for Long MCP Calls](https://github.com/anthropics/claude-code/issues/470)
- [#424 - MCP Timeout Configurability](https://github.com/anthropics/claude-code/issues/424)

**lean-lsp-mcp Issues**:
- [#115 - Server Halts on diagnostic_messages](https://github.com/oOo0oOo/lean-lsp-mcp/issues/115)
- [#118 - Build Concurrency Modes](https://github.com/oOo0oOo/lean-lsp-mcp/issues/118)

**Project Documentation**:
- `.claude/context/core/patterns/mcp-tool-recovery.md`
- `.claude/context/project/lean4/operations/multi-instance-optimization.md`
- `.claude/context/core/patterns/early-metadata-pattern.md`

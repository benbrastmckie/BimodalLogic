# Implementation Plan: Task #686

- **Task**: 686 - Fix agent interruption MCP abort errors
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: Related to 619, 672, 674 (architecture improvements)
- **Research Inputs**: specs/686_fix_agent_interruption_mcp_abort_errors/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation addresses MCP AbortError -32001 failures that leave agents stuck without writing metadata files. The research identified that multiple concurrent lean-lsp-mcp instances via STDIO transport create resource contention, and Claude Code's shared AbortController cascades aborts to all subagents. The solution implements early metadata file creation, MCP tool error recovery patterns, enhanced error schema, and agent-level defensive patterns.

### Research Integration

Key findings integrated from research-001.md:
- MCP AbortError -32001 is a request timeout (60s default) often caused by resource contention from multiple concurrent lean-lsp-mcp instances
- Claude Code Issue #6594: shared AbortController cascades errors to all subagents
- Agents currently write metadata files only as a final step - interruption before that stage leaves no metadata
- lean-lsp-mcp Issues #118 and #115 confirm multi-instance build contention and diagnostic hang scenarios

## Goals & Non-Goals

**Goals**:
- Ensure metadata files are written even when agents are interrupted
- Add recovery patterns for MCP tool failures with retry and graceful degradation
- Enable task resume after interruption
- Add proper error categorization for MCP abort errors
- Document multi-instance optimization strategies

**Non-Goals**:
- Fixing Claude Code platform bugs (Issue #6594 shared AbortController)
- Modifying upstream lean-lsp-mcp server code
- Implementing SSE/HTTP transport (would require lean-lsp-mcp changes)
- Automatic session management/throttling

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Early metadata file not cleaned up on success | Low | Low | Commands already delete metadata in postflight |
| Retry logic adds latency to normal operations | Medium | Low | Only retry after actual failure, use short timeouts |
| Agent file changes introduce regressions | Medium | Medium | Test each agent individually after changes |
| Incremental progress updates increase I/O | Low | Low | Only update on significant progress milestones |
| Claude Code internal abort not interceptable | High | High | Focus on defensive patterns within our control |

## Implementation Phases

### Phase 1: Core Patterns [COMPLETED]

**Goal**: Create foundational pattern documentation for MCP error recovery and early metadata

**Tasks**:
- [x] Create `.claude/context/core/patterns/mcp-tool-recovery.md` with:
  - Wrapper pattern for MCP tool calls
  - Retry with exponential backoff (1s, 2s, 4s max)
  - Graceful degradation when tool unavailable
  - Fallback to alternative tools
  - Error logging to errors.json with mcp_abort_error type
- [ ] Create `.claude/context/core/patterns/early-metadata-pattern.md` with:
  - Stage 0 metadata file creation template
  - Incremental progress update guidelines
  - Partial status handling specifications

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/patterns/mcp-tool-recovery.md` - Create new file
- `.claude/context/core/patterns/early-metadata-pattern.md` - Create new file

**Verification**:
- Pattern files exist and follow documentation standards
- Content matches research recommendations

---

### Phase 2: Error Schema Enhancement [NOT STARTED]

**Goal**: Add mcp_abort_error type to error handling infrastructure

**Tasks**:
- [ ] Update `.claude/rules/error-handling.md`:
  - Add `mcp_abort_error` to External Errors category
  - Document recovery strategy for MCP abort errors
- [ ] Update `.claude/context/core/formats/return-metadata-file.md`:
  - Document `in_progress` as valid status for early metadata
  - Add `partial_progress` field documentation
  - Add `started_at` field documentation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/rules/error-handling.md` - Add mcp_abort_error type
- `.claude/context/core/formats/return-metadata-file.md` - Add in_progress status docs

**Verification**:
- Error type documented with severity and recovery strategy
- Return metadata schema supports early/partial states

---

### Phase 3: Lean Agent Updates [NOT STARTED]

**Goal**: Update lean-research-agent and lean-implementation-agent with interruption-aware patterns

**Tasks**:
- [ ] Update `.claude/agents/lean-research-agent.md`:
  - Add Stage 0 for early metadata file creation with status="in_progress"
  - Add MCP tool recovery pattern to error handling section
  - Add incremental progress updates for long operations
  - Update Critical Requirements with interruption-aware patterns
- [ ] Update `.claude/agents/lean-implementation-agent.md`:
  - Add Stage 0 for early metadata file creation
  - Add MCP tool recovery for lean_diagnostic_messages and lean_goal
  - Add phase-level progress tracking to metadata
  - Update Critical Requirements with interruption-aware patterns

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add Stage 0, MCP recovery
- `.claude/agents/lean-implementation-agent.md` - Add Stage 0, MCP recovery

**Verification**:
- Both agents have Stage 0 before Stage 1
- Error handling sections reference mcp-tool-recovery.md
- Critical Requirements include interruption-aware patterns

---

### Phase 4: General Agent Updates [NOT STARTED]

**Goal**: Update remaining agents with consistent interruption-aware patterns

**Tasks**:
- [ ] Update `.claude/agents/general-research-agent.md`:
  - Add Stage 0 for early metadata file creation
  - Note: Web tools less prone to abort but consistency valuable
- [ ] Update `.claude/agents/general-implementation-agent.md`:
  - Add Stage 0 for early metadata file creation
  - Add incremental progress for multi-phase work
- [ ] Update `.claude/agents/latex-implementation-agent.md`:
  - Add Stage 0 for early metadata file creation
  - Add graceful handling for pdflatex timeouts
- [ ] Update `.claude/agents/planner-agent.md`:
  - Add Stage 0 for early metadata file creation
  - Planner is lower risk but consistency important

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Add Stage 0
- `.claude/agents/general-implementation-agent.md` - Add Stage 0
- `.claude/agents/latex-implementation-agent.md` - Add Stage 0
- `.claude/agents/planner-agent.md` - Add Stage 0

**Verification**:
- All six agents have consistent Stage 0 pattern
- Each agent's Critical Requirements updated

---

### Phase 5: Command Postflight Enhancement [NOT STARTED]

**Goal**: Enhance command postflight to handle partial/in_progress metadata

**Tasks**:
- [ ] Update `.claude/context/core/patterns/checkpoint-in-commands.md`:
  - Add "Handling Interrupted Agents" section
  - Document partial metadata detection and handling
  - Add error logging for delegation_interrupted
  - Add resume guidance messaging
- [ ] Update `.claude/context/core/formats/return-metadata-file.md`:
  - Add complete examples for partial/in_progress states
  - Document how skills should interpret these states

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/core/patterns/checkpoint-in-commands.md` - Add interrupted agent handling
- `.claude/context/core/formats/return-metadata-file.md` - Add partial state examples

**Verification**:
- Postflight pattern documented for interrupted agents
- Clear guidance for skill implementations

---

### Phase 6: Documentation and Optimization Guide [NOT STARTED]

**Goal**: Document multi-instance optimization and update system documentation

**Tasks**:
- [ ] Create `.claude/context/project/lean4/operations/multi-instance-optimization.md`:
  - Document pre-build workflow recommendation
  - Document environment variable configuration
  - Document session management strategy
  - Reference lean-lsp-mcp Issues #118, #115
- [ ] Update `.claude/CLAUDE.md`:
  - Add brief mention of MCP error recovery patterns under Error Handling section
  - Reference multi-instance optimization guide under Lean 4 Integration

**Timing**: 45 minutes

**Files to modify**:
- `.claude/context/project/lean4/operations/multi-instance-optimization.md` - Create new file
- `.claude/CLAUDE.md` - Add error recovery and optimization references

**Verification**:
- Optimization guide provides actionable steps
- CLAUDE.md references are concise and point to detailed docs

---

## Testing & Validation

- [ ] Verify each agent file has Stage 0 metadata creation pattern
- [ ] Verify pattern files exist and are well-structured
- [ ] Verify error-handling.md includes mcp_abort_error type
- [ ] Manual test: Interrupt an agent during MCP call and verify metadata file exists
- [ ] Verify CLAUDE.md references are correct and concise

## Artifacts & Outputs

- `.claude/context/core/patterns/mcp-tool-recovery.md` - MCP error recovery pattern
- `.claude/context/core/patterns/early-metadata-pattern.md` - Early metadata pattern
- `.claude/context/project/lean4/operations/multi-instance-optimization.md` - Optimization guide
- Updated agent files (6 files)
- Updated rules and format files (2 files)
- Updated checkpoint pattern (1 file)
- Updated CLAUDE.md (1 file)

## Rollback/Contingency

If implementation causes agent regressions:
1. Agents can continue working without Stage 0 (graceful degradation)
2. Pattern files are additive documentation, removal is safe
3. Error schema additions are backward compatible
4. Git history preserves all previous agent versions for rollback

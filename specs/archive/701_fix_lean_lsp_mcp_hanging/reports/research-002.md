# Research Report: Task #701 (Supplement)

**Task**: 701 - Fix lean-lsp-mcp hanging issue
**Date**: 2026-01-28
**Focus**: Analysis of second hanging example and elegant fix design

## New Evidence Analysis

### lean-research-2.md Output Analysis

The second output file reveals the exact failure sequence:

```
1. Agent receives complex prompt with JSON schema instructions
2. Agent makes several successful file operations:
   - Write to .return-meta.json (Error: file not read first)
   - Read UniversalCanonicalModel.lean (Success)
   - Search patterns (Success)
   - Read Metalogic files (Success)
3. Agent calls MCP tools:
   - lean-lsp - LeanSearch (MCP)(query: "Boolean algebra with operators...")
4. Error: MCP error -32001: AbortError: This operation was aborted
5. User forced interruption: "Interrupted - What should Claude do instead?"
```

### Key Observations

1. **MCP AbortError -32001** occurred during a `lean_leansearch` call - this is the actual MCP timeout
2. The agent made **many successful tool calls** before hitting the MCP error
3. The agent **did not recover** from the AbortError - it hung until user interrupted
4. The JSON metadata schema in the prompt was being followed but wasn't reached

### Pattern Identified: MCP Error Causes Agent Freeze

The evidence now shows a clearer pattern:
- **Issue #14496** (complex prompts) may not be the primary cause
- The agent IS making MCP calls successfully until one times out
- **Issue #15945** (no timeout recovery) IS the primary cause
- When AbortError -32001 occurs, the agent enters an unrecoverable state

## Refined Root Cause Hypothesis

### Primary Cause: AbortError -32001 Freezes Agent

When `mcp__lean-lsp__lean_leansearch` (or similar rate-limited MCP tool) times out:
1. Claude Code receives `AbortError: This operation was aborted`
2. The agent should handle this and continue with alternatives
3. Instead, the agent **freezes** and stops generating tokens
4. No error handling code in the agent executes because the API-level freeze prevents it

### Why Agent Instructions Don't Help

The agent instructions include MCP error recovery patterns:
```markdown
### MCP Tool Error Recovery
When MCP tool calls fail (AbortError -32001 or similar):
1. Log the error context
2. Retry once after 5-second delay
3. Try alternative search tool
```

**But these instructions never execute** because:
- The freeze happens at the Claude Code / API layer
- The agent's "brain" never gets the error to process
- It's as if the agent is suspended mid-thought

### Related Issue: stop_reason: null (Issue #20660)

[Issue #20660](https://github.com/anthropics/claude-code/issues/20660) shows API responses returning `stop_reason: null` instead of `"end_turn"`. This may be connected:
- Agent makes an MCP call
- MCP call times out or aborts
- Claude Code gets stuck waiting for a proper termination signal
- The agent appears frozen because the API layer is deadlocked

## Elegant Fix Design

### Option A: Fail-Fast MCP Canary Pattern (Recommended)

**Concept**: Before doing any substantive work, verify MCP tools are working with a fast, non-rate-limited call.

**Implementation in agent prompts**:

```markdown
### Stage 0.5: MCP Availability Check

Before proceeding with MCP-dependent research:

1. Call `lean_local_search` with a known-good query (e.g., "Nat.add")
2. If this fails or times out → immediately return partial with guidance
3. If this succeeds → MCP tools are available, proceed

This prevents the agent from getting stuck mid-operation when MCP is flaky.
```

**Why this works**:
- `lean_local_search` has NO rate limit (unlike leansearch, loogle, leanfinder)
- If the local search fails, MCP is broken - return early
- Avoids wasting work on a doomed session

### Option B: Simplified Agent Architecture

**Concept**: Reduce agent prompt complexity to stay below the threshold where MCP access becomes unreliable.

**Current state**:
- lean-research-agent.md: ~438 lines
- lean-implementation-agent.md: ~528 lines

**Target state**:
- Core agent: <100 lines (essentials only)
- Detailed instructions: Loaded via @-references on demand
- JSON schemas: Moved to separate context file

**Restructured agent**:
```markdown
---
name: lean-research-agent
description: Research Lean 4 and Mathlib for theorem proving tasks
---

# Lean Research Agent

## Quick Start
1. Check MCP availability with lean_local_search("Nat")
2. If MCP works: Read @.claude/context/project/lean4/agents/lean-research-flow.md
3. Execute the research flow
4. Write metadata to specs/{N}_{SLUG}/.return-meta.json
5. Return brief text summary

## On MCP Failure
Return immediately with partial status. Do not hang.

## Context References (load after MCP check passes)
- @.claude/context/project/lean4/agents/lean-research-flow.md
- @.claude/context/core/formats/return-metadata-file.md
```

### Option C: Main Agent Fallback

**Concept**: Detect when subagent is likely to fail and route work to main conversation.

**Implementation in skill-lean-research**:
```markdown
### Pre-Check for Subagent Viability

Before invoking Task tool:

1. Main agent calls `lean_local_search("test")` directly
2. If this fails → execute research in main conversation (not subagent)
3. If this succeeds → proceed with Task tool delegation

Rationale: Main conversation has more reliable MCP access than subagents.
```

### Option D: Timeout Wrapper (Advanced)

**Concept**: Wrap subagent invocation with explicit timeout handling.

**Implementation in skill**:
```markdown
### Stage 5: Invoke Subagent with Timeout

1. Start a timer (10 minutes max)
2. Invoke Task tool
3. Monitor for response
4. If no response after timeout:
   - Check metadata file for partial progress
   - Return partial status to orchestrator
   - User can resume later
```

**Note**: This requires Claude Code to expose timeout control, which may not be available currently.

## Recommended Approach: Combined A + B

1. **Immediate**: Add MCP canary check (Option A) to all Lean agents
   - Fast to implement (single check at start)
   - Prevents wasted work
   - Fails gracefully with guidance

2. **Short-term**: Restructure agent files (Option B)
   - Reduces prompt complexity
   - May improve MCP reliability
   - Easier to maintain

3. **If needed**: Implement main agent fallback (Option C)
   - Only if A+B don't fully resolve issue
   - Accept token overhead for reliability

## Implementation Plan

### Phase 1: MCP Canary Check (Day 1)

Modify these files:
- `.claude/agents/lean-research-agent.md` - Add Stage 0.5
- `.claude/agents/lean-implementation-agent.md` - Add Stage 0.5

Add this block after Stage 0 (Early Metadata):

```markdown
### Stage 0.5: MCP Availability Check

**CRITICAL**: Verify MCP tools are working before proceeding.

1. Call `lean_local_search` with query `"Nat"`:
   ```
   lean_local_search(query="Nat", limit=1)
   ```

2. **If this succeeds**: MCP tools are available. Proceed to Stage 1.

3. **If this fails** (AbortError, timeout, or empty response when results expected):
   - Update metadata to `status: "partial"` with:
     ```json
     {
       "partial_progress": {
         "stage": "mcp_unavailable",
         "details": "MCP tools not responding. Cannot proceed with Lean research."
       }
     }
     ```
   - Return immediately: "MCP tools unavailable. Run /research again later or check MCP configuration."
   - DO NOT attempt further MCP calls

**Why this matters**: A single failed canary call prevents the agent from freezing mid-operation when MCP becomes unresponsive.
```

### Phase 2: Agent Restructure (Day 2-3)

Create new context files:
- `.claude/context/project/lean4/agents/lean-research-flow.md` - Detailed research flow
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Detailed implementation flow

Simplify agent files:
- Keep only: Overview, Allowed Tools, Context References, Quick Start, Error Handling Summary
- Move: Detailed execution stages, JSON schemas, examples to context files

### Phase 3: Validation (Day 4)

Test the changes:
1. Run `/research` on a Lean task
2. Monitor for MCP canary success/failure
3. Verify agent doesn't hang on MCP errors
4. Test graceful fallback behavior

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Canary check adds latency | Low | lean_local_search is fast (~100ms) |
| Simplified agents lose functionality | Medium | Move details to context files, not delete |
| MCP canary fails on working system | Low | Use well-known query ("Nat") that always exists |
| Breaking changes to workflow | High | Test thoroughly before deploying |

## Conclusion

The hanging issue is caused by MCP AbortError -32001 freezing agents at the Claude Code API layer, not by agent instructions. The most elegant fix is:

1. **Add MCP canary check** - Detect failure early, fail fast
2. **Simplify agent prompts** - Reduce complexity, improve reliability
3. **Graceful degradation** - Always return partial status instead of hanging

This approach works with Claude Code's current limitations while providing a better user experience.

## Sources

- [Claude Code Issue #20660 - Hang after workflow completion](https://github.com/anthropics/claude-code/issues/20660)
- [Claude Code Issue #15945 - MCP causes 16+ hour hang](https://github.com/anthropics/claude-code/issues/15945)
- [Claude Code Issue #14496 - Complex prompts fail MCP access](https://github.com/anthropics/claude-code/issues/14496)
- [Claude Code Issue #13890 - Silent MCP/Write failures](https://github.com/anthropics/claude-code/issues/13890)
- [Claude Code MCP Documentation](https://code.claude.com/docs/en/mcp)
- [lean-lsp-mcp GitHub](https://github.com/oOo0oOo/lean-lsp-mcp)

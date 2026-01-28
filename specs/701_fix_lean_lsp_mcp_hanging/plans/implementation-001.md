# Implementation Plan: Task #701

**Task**: Fix lean-lsp-mcp hanging issue
**Version**: 001
**Created**: 2026-01-28
**Language**: meta

## Overview

Implement a two-pronged fix for the MCP hanging issue affecting lean-research-agent and lean-implementation-agent:

1. **MCP Canary Check**: Add fail-fast check at agent startup to detect MCP unavailability before doing substantive work
2. **Agent Simplification**: Extract detailed instructions to context files, reducing agent prompt complexity

The research identified that AbortError -32001 causes agents to freeze at the Claude Code API layer, not in agent instructions. This fix addresses the symptom (freezing) by failing fast and gracefully.

## Phases

### Phase 1: Add MCP Canary Check to Lean Agents

**Status**: [NOT STARTED]

**Objectives**:
1. Add Stage 0.5 (MCP Availability Check) to lean-research-agent.md
2. Add Stage 0.5 (MCP Availability Check) to lean-implementation-agent.md
3. Ensure graceful failure with clear guidance when MCP is unavailable

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add canary check after Stage 0
- `.claude/agents/lean-implementation-agent.md` - Add canary check after Stage 0

**Steps**:
1. Read lean-research-agent.md
2. Insert Stage 0.5 block after "### Stage 0: Initialize Early Metadata" section
3. Read lean-implementation-agent.md
4. Insert identical Stage 0.5 block after its Stage 0 section

**Canary Check Block to Insert**:
```markdown
### Stage 0.5: MCP Availability Check

**CRITICAL**: Verify MCP tools are working before proceeding.

1. Call `mcp__lean-lsp__lean_local_search` with query `"Nat"` and limit `1`

2. **If this succeeds** (returns results or empty array with isError: false):
   - MCP tools are available
   - Proceed to Stage 1

3. **If this fails** (AbortError, timeout, isError: true, or no response):
   - Update metadata to `status: "partial"` with:
     ```json
     {
       "status": "partial",
       "partial_progress": {
         "stage": "mcp_unavailable",
         "details": "MCP tools not responding. Cannot proceed with Lean research/implementation."
       },
       "errors": [{
         "type": "mcp_unavailable",
         "message": "lean_local_search failed - MCP tools not accessible",
         "recoverable": true,
         "recommendation": "Run command again later or check MCP configuration"
       }]
     }
     ```
   - Return immediately with message: "MCP tools unavailable. Please retry later or verify lean-lsp configuration in ~/.claude.json"
   - **DO NOT** attempt any further MCP calls

**Why this matters**: A single fast canary call prevents the agent from freezing mid-operation when MCP becomes unresponsive. Better to fail fast with clear guidance than hang indefinitely.
```

**Verification**:
- [ ] lean-research-agent.md contains Stage 0.5
- [ ] lean-implementation-agent.md contains Stage 0.5
- [ ] Stage 0.5 appears after Stage 0, before Stage 1

---

### Phase 2: Create Extracted Flow Context Files

**Status**: [NOT STARTED]

**Objectives**:
1. Create lean-research-flow.md with detailed research execution stages
2. Create lean-implementation-flow.md with detailed implementation execution stages
3. Move JSON schema examples to dedicated context file

**Files to create**:
- `.claude/context/project/lean4/agents/lean-research-flow.md`
- `.claude/context/project/lean4/agents/lean-implementation-flow.md`

**Steps**:
1. Create directory `.claude/context/project/lean4/agents/` if not exists
2. Extract Stages 1-7 from lean-research-agent.md to lean-research-flow.md
3. Extract Stages 1-8 from lean-implementation-agent.md to lean-implementation-flow.md
4. Include JSON schema examples in each flow file
5. Add appropriate headers and cross-references

**lean-research-flow.md Structure**:
```markdown
# Lean Research Execution Flow

Reference: Load this file when MCP canary check passes in lean-research-agent.

## Stage 1: Parse Delegation Context
[content from lean-research-agent.md]

## Stage 2: Analyze Task and Determine Search Strategy
[content]

## Stage 3: Execute Primary Searches
[content]

## Stage 4: Synthesize Findings
[content]

## Stage 5: Create Research Report
[content]

## Stage 6: Write Metadata File
[content with JSON schema]

## Stage 7: Return Brief Text Summary
[content with examples]

## Error Handling Details
[MCP recovery patterns, rate limit handling, etc.]
```

**Verification**:
- [ ] lean-research-flow.md created with complete Stages 1-7
- [ ] lean-implementation-flow.md created with complete Stages 1-8
- [ ] JSON schemas preserved in flow files
- [ ] Error handling sections included

---

### Phase 3: Simplify Agent Core Files

**Status**: [NOT STARTED]

**Objectives**:
1. Reduce lean-research-agent.md to <100 lines (core essentials only)
2. Reduce lean-implementation-agent.md to <100 lines
3. Replace detailed stages with @-reference to flow files
4. Preserve all MUST DO/MUST NOT requirements in agent files

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Simplify, keep essentials
- `.claude/agents/lean-implementation-agent.md` - Simplify, keep essentials

**Steps**:
1. Create backup copies of current agent files (in case of issues)
2. Rewrite lean-research-agent.md with simplified structure:
   - Frontmatter (name, description)
   - Overview (3-5 lines)
   - Allowed Tools (compact list)
   - Context References (with @-reference to flow file)
   - Stage 0: Early Metadata (keep)
   - Stage 0.5: MCP Canary Check (keep)
   - Execution: @-reference to lean-research-flow.md
   - Critical Requirements (MUST DO/MUST NOT - condensed)
3. Apply same pattern to lean-implementation-agent.md

**Simplified Agent Structure** (target ~80-100 lines):
```markdown
---
name: lean-research-agent
description: Research Lean 4 and Mathlib for theorem proving tasks
---

# Lean Research Agent

Research agent for Lean 4 theorem discovery. Uses lean-lsp MCP tools.

## Allowed Tools
[compact list]

## Context References
- @.claude/context/project/lean4/agents/lean-research-flow.md - Execution flow
- @.claude/context/core/formats/return-metadata-file.md - Metadata schema

## Stage 0: Initialize Early Metadata
[keep existing - critical for recovery]

## Stage 0.5: MCP Availability Check
[keep existing - critical for fail-fast]

## Execution
After MCP check passes, load and follow @.claude/context/project/lean4/agents/lean-research-flow.md

## Critical Requirements

**MUST DO**: [condensed list]
**MUST NOT**: [condensed list]
```

**Verification**:
- [ ] lean-research-agent.md is <100 lines
- [ ] lean-implementation-agent.md is <100 lines
- [ ] All critical requirements preserved
- [ ] @-references to flow files work correctly

---

### Phase 4: Validation and Testing

**Status**: [NOT STARTED]

**Objectives**:
1. Test MCP canary check with working MCP
2. Test MCP canary check with broken/unavailable MCP (if possible to simulate)
3. Verify agent simplification doesn't break normal operation
4. Document results

**Steps**:
1. Run `/research` on a simple Lean task (e.g., one of the not_started tasks)
2. Observe canary check execution in agent output
3. Verify research completes successfully
4. Test `/implement` similarly
5. Document any issues found
6. If issues found, iterate on Phase 1-3 changes

**Test Cases**:
1. **Happy path**: MCP available, research completes
2. **Graceful failure**: (if testable) MCP unavailable, agent returns partial with guidance
3. **Simplified agent**: Agent loads flow file correctly, executes all stages

**Verification**:
- [ ] /research completes successfully on test task
- [ ] /implement completes successfully on test task
- [ ] No hanging observed
- [ ] Clear error message on MCP failure (if testable)

---

## Dependencies

- None (self-contained meta task)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Simplified agents lose critical instructions | High | Medium | Keep MUST DO/MUST NOT in agent file, only move detailed stages |
| @-reference loading fails | High | Low | Test thoroughly in Phase 4, have rollback plan |
| Canary check false negatives | Medium | Low | Use well-known query ("Nat") that always exists in Lean |
| Canary check adds latency | Low | Low | lean_local_search is fast (~100ms) |
| Breaking changes to workflow | High | Medium | Create backups, test incrementally |

## Rollback Plan

If changes cause issues:
1. Backup copies of original agent files should be preserved
2. Git history allows reverting to pre-implementation state
3. Flow files can be deleted without affecting other components

## Success Criteria

- [ ] Lean agents include MCP canary check
- [ ] Agents fail fast with clear guidance when MCP unavailable
- [ ] Agent files simplified to <100 lines each
- [ ] Detailed instructions preserved in flow context files
- [ ] Normal /research and /implement operations work correctly
- [ ] No hanging observed during testing

## Estimated Effort

| Phase | Effort |
|-------|--------|
| Phase 1: MCP Canary Check | 0.5 hours |
| Phase 2: Create Flow Files | 1.5 hours |
| Phase 3: Simplify Agents | 1 hour |
| Phase 4: Validation | 0.5 hours |
| **Total** | **3.5 hours** |

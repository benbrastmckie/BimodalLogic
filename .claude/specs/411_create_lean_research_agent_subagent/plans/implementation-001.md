# Implementation Plan: Task #411

**Task**: Create lean-research-agent subagent with lazy context
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Create the `lean-research-agent.md` subagent file in `.claude/agents/` that will be invoked by `skill-lean-research` via the forked subagent pattern. The agent will load Lean-specific context on-demand, use MCP search tools for Mathlib exploration, create research reports following the standard format, and return structured JSON matching the subagent-return.md schema.

## Phases

### Phase 1: Create Agent Directory and File Structure

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create `.claude/agents/` directory
2. Create lean-research-agent.md with proper frontmatter
3. Define agent name, description, and allowed tools

**Files to create**:
- `.claude/agents/lean-research-agent.md` - Main agent file

**Steps**:
1. Create `.claude/agents/` directory if not exists
2. Create lean-research-agent.md with frontmatter:
   - name: lean-research-agent
   - description: Research agent for Lean 4 and Mathlib theorem discovery
   - allowed-tools: Read, Write, Edit, Glob, Grep, Bash, and all mcp__lean-lsp__* tools
3. Add context references section (for lazy loading)

**Verification**:
- [ ] File exists at `.claude/agents/lean-research-agent.md`
- [ ] Frontmatter validates with proper fields

---

### Phase 2: Define Context Loading Strategy

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Document which context files to load on-demand
2. Define loading conditions for each context file
3. Establish the search decision tree in agent body

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add context loading section

**Steps**:
1. Add Context References section with @-reference paths:
   - `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Always load for MCP usage
   - `@.claude/context/project/lean4/tools/leansearch-api.md` - Load for natural language queries
   - `@.claude/context/project/lean4/tools/loogle-api.md` - Load for type pattern queries
   - `@.claude/context/core/formats/report-format.md` - Load when creating report
   - `@.claude/context/core/formats/subagent-return.md` - Always load for return format
2. Document the search decision tree:
   - Local search first (no rate limit)
   - Route to leansearch, loogle, or leanfinder based on query type
   - Verify with hover_info after finding candidates

**Verification**:
- [ ] Context references documented with when-to-load conditions
- [ ] Search decision tree clearly defined

---

### Phase 3: Implement Execution Flow

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Define input parsing from delegation context
2. Define research execution stages
3. Define artifact creation workflow
4. Define return format generation

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add execution section

**Steps**:
1. Add Input Parsing section:
   - Extract task_number, task_name, description, language from task_context
   - Extract session_id, delegation_depth, delegation_path from metadata
   - Extract focus_prompt (optional)
2. Add Execution Stages:
   - Stage 1: Parse delegation context
   - Stage 2: Analyze task description to determine search strategy
   - Stage 3: Execute primary searches (leansearch, loogle, leanfinder)
   - Stage 4: Verify findings with local_search and hover_info
   - Stage 5: Synthesize into research report
   - Stage 6: Return structured JSON
3. Add Report Creation section:
   - Create directory `.claude/specs/{N}_{SLUG}/reports/`
   - Find next version number (research-001, 002, etc.)
   - Write report following report-format.md structure
4. Add Return Format section:
   - Template for completed status
   - Template for partial status (timeout)
   - Template for failed status (no results)

**Verification**:
- [ ] All 6 execution stages documented
- [ ] Report creation workflow defined
- [ ] Return format templates complete

---

### Phase 4: Add Error Handling and Edge Cases

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Handle MCP tool rate limits
2. Handle no results found scenarios
3. Handle timeout conditions
4. Handle invalid task numbers

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add error handling section

**Steps**:
1. Add Error Handling section:
   - Rate limit handling: Wait and retry, or use alternative tool
   - No results: Suggest alternative queries, return partial with recommendations
   - Timeout: Save partial progress, return partial status with recovery info
   - Invalid task: Return failed status immediately
2. Add Search Fallback Chain:
   - Primary: leansearch for natural language
   - Fallback 1: loogle for type patterns
   - Fallback 2: leanfinder for semantic search
   - Fallback 3: local_search only with broader terms
3. Add Partial Result Guidelines:
   - What constitutes useful partial results
   - How to save progress for resume

**Verification**:
- [ ] All error types have handling defined
- [ ] Fallback chain documented
- [ ] Partial result behavior specified

---

### Phase 5: Documentation and Integration Testing

**Estimated effort**: 30 minutes
**Status**: [IN PROGRESS]

**Objectives**:
1. Update CLAUDE.md with agent location
2. Verify integration with skill-lean-research
3. Document usage examples

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Add examples section
- `.claude/CLAUDE.md` - Update skill-to-agent mapping if needed

**Steps**:
1. Add Examples section to agent file:
   - Example 1: Researching a specific theorem by name
   - Example 2: Exploratory research for a proof strategy
   - Example 3: Finding lemmas with specific type pattern
2. Add Return Examples:
   - Completed return with artifact
   - Partial return with timeout
   - Failed return with error
3. Verify CLAUDE.md skill-to-agent table includes lean-research-agent

**Verification**:
- [ ] Examples are clear and actionable
- [ ] CLAUDE.md references lean-research-agent
- [ ] Agent file is self-contained and executable

## Dependencies

- Task 410: Remove eager context loading from skill frontmatter (optional but recommended)
  - This task works without 410 complete, but 410 establishes the pattern

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCP tools unavailable | High | Low | Document fallback to manual research |
| Rate limit exhaustion | Medium | Medium | Implement wait-and-retry with backoff |
| Agent not invoked correctly | Medium | Medium | Include detailed invocation example |
| Return format validation fails | Medium | Low | Use exact JSON template from subagent-return.md |

## Success Criteria

- [ ] Agent file exists at `.claude/agents/lean-research-agent.md`
- [ ] Agent has proper frontmatter with allowed-tools
- [ ] Context references use @-reference pattern (lazy loading)
- [ ] Execution flow covers all stages from input to output
- [ ] Return format matches subagent-return.md schema exactly
- [ ] Error handling covers rate limits, timeouts, no results
- [ ] Examples demonstrate common use cases

## Rollback Plan

If implementation fails or causes issues:
1. Delete `.claude/agents/lean-research-agent.md`
2. The skill-lean-research will continue to reference the agent but invocation will fail gracefully
3. Research can still be done manually using /research command without subagent

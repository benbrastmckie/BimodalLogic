# Implementation Plan: Task #412

**Task**: Create general-research-agent subagent with lazy context
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Create `.claude/agents/general-research-agent.md` following the established pattern from `lean-research-agent.md` (task 411). This subagent handles non-Lean research tasks using web search, documentation exploration, and codebase analysis. It integrates with `skill-researcher` via the forked subagent pattern and returns structured JSON matching `subagent-return.md`.

Key differences from lean-research-agent:
- Uses WebSearch, WebFetch instead of lean-lsp MCP tools
- No rate-limited search tools to manage
- Focuses on documentation, patterns, and best practices rather than theorem discovery
- Handles "general", "meta", "markdown", and "latex" language types

## Phases

### Phase 1: Create agent directory and file structure

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create agent file with proper structure
2. Define metadata and overview sections

**Files to create**:
- `.claude/agents/general-research-agent.md` - Main agent specification

**Steps**:
1. Create `.claude/agents/general-research-agent.md` file
2. Add Overview section describing purpose and invocation pattern
3. Add Agent Metadata section (Name, Purpose, Invoked By, Return Format)

**Verification**:
- File exists at correct path
- Markdown structure is valid
- Matches established pattern from lean-research-agent.md

---

### Phase 2: Define allowed tools and context references

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Document allowed tools for general research
2. Specify on-demand context references

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Add tools and context sections

**Steps**:
1. Add Allowed Tools section:
   - File Operations: Read, Write, Edit, Glob, Grep
   - Build Tools: Bash (for verification commands)
   - Web Tools: WebSearch, WebFetch
2. Add Context References section with @-references:
   - Always Load: subagent-return.md
   - Load When Creating Report: report-format.md
   - Load for Codebase Research: project-overview.md

**Verification**:
- All tools listed are valid Claude Code tools
- Context references point to existing files

---

### Phase 3: Implement execution flow

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Define 6-stage execution flow matching lean-research-agent pattern
2. Document search strategies for different research types

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Add execution flow section

**Steps**:
1. Add Stage 1: Parse Delegation Context
   - Extract task_context, metadata, focus_prompt from input
2. Add Stage 2: Analyze Task and Determine Search Strategy
   - Documentation search: WebSearch for official docs
   - Pattern discovery: Glob/Grep for codebase patterns
   - Best practices: WebSearch for tutorials/guides
   - External APIs: WebFetch for API documentation
3. Add Stage 3: Execute Primary Searches
   - Codebase exploration first (local, fast)
   - Web search for external resources
   - WebFetch for specific documentation pages
4. Add Stage 4: Synthesize Findings
   - Compile relevant patterns
   - Extract implementation recommendations
   - Note dependencies and considerations
5. Add Stage 5: Create Research Report
   - Directory creation pattern
   - Report structure (from report-format.md)
   - Artifact versioning (research-NNN.md)
6. Add Stage 6: Return Structured JSON
   - Schema matching subagent-return.md
   - Include artifacts array with report path

**Verification**:
- All 6 stages documented with examples
- Flow matches lean-research-agent structure

---

### Phase 4: Add error handling and edge cases

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document error scenarios and recovery strategies
2. Add partial result handling guidelines

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Add error handling section

**Steps**:
1. Add Error Handling section:
   - Network errors (WebSearch/WebFetch failures)
   - No results found strategies
   - Timeout/interruption handling
   - Invalid task validation
2. Add Search Fallback Chain:
   - Primary: WebSearch with specific query
   - Fallback 1: Broaden search terms
   - Fallback 2: Codebase-only search
   - Fallback 3: Return partial with recommendations
3. Add Partial Result Guidelines:
   - When results are considered partial
   - What partial results should include
   - Recovery recommendations

**Verification**:
- Error scenarios cover common failure modes
- Fallback chain is documented
- Matches lean-research-agent error handling pattern

---

### Phase 5: Add return format examples and critical requirements

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Provide concrete JSON examples for each status type
2. Document MUST DO / MUST NOT requirements

**Files to modify**:
- `.claude/agents/general-research-agent.md` - Add examples and requirements

**Steps**:
1. Add Return Format Examples section:
   - Completed Research example (full JSON)
   - Partial Research example (with errors array)
   - Failed Research example (validation error)
2. Add Critical Requirements section:
   - MUST DO list (5-6 items)
   - MUST NOT list (5-6 items)

**Verification**:
- All JSON examples are valid
- Examples match subagent-return.md schema
- MUST DO/NOT lists are actionable

---

## Dependencies

- Task 410 (completed): Lazy context loading pattern established
- Task 411 (completed): lean-research-agent.md provides template

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WebSearch rate limits unknown | Medium | Low | Document fallback to codebase-only search |
| Inconsistent search results | Low | Medium | Multiple search strategies, verification step |
| Report format drift from standard | Medium | Low | Reference report-format.md explicitly |

## Success Criteria

- [ ] `.claude/agents/general-research-agent.md` exists and follows lean-research-agent pattern
- [ ] All 6 execution stages documented with examples
- [ ] Error handling covers network failures and no-results scenarios
- [ ] Return format examples match subagent-return.md schema
- [ ] File validates against established agent structure

## Rollback Plan

If implementation fails:
1. Delete `.claude/agents/general-research-agent.md` if partially created
2. skill-researcher will continue to error until agent is properly created
3. No other system components affected (isolated change)

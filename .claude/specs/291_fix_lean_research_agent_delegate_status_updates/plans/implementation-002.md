# Implementation Plan: Ensure Lean Research Skill Uses MCP Tools Correctly

**Task**: 291 - Ensure lean research tools are used correctly for systematic and efficient lean research
**Version**: 002
**Created**: 2026-01-10
**Revision of**: implementation-001.md
**Reason**: Migrated from OpenCode (.opencode/) to Claude Code (.claude/) agent system. Previous plan targeted OpenCode subagents which are no longer used.

---

## Revision Summary

### What Changed and Why

The original plan (v001) targeted the OpenCode subagent architecture:
- `.opencode/agent/subagents/lean-research-agent.md`
- `.opencode/agent/subagents/status-sync-manager.md`
- `.opencode/agent/subagents/git-workflow-manager.md`

The project has migrated to Claude Code which uses:
- `.claude/skills/skill-lean-research/SKILL.md`
- Direct MCP tool calls (`mcp__lean-lsp__*`)
- No subagent delegation pattern

### Previous Plan Status
- Phase 1-6: [OBSOLETE] - Targeted OpenCode subagent files that are no longer used

### Key Changes
1. **Target Claude Code skill system** instead of OpenCode subagents
2. **Focus on MCP tool usage** instead of status-sync-manager delegation
3. **Simplify scope** to skill definition and documentation
4. **Remove subagent delegation** - Claude Code uses direct tool calls

---

## Overview

### Problem Statement (Revised)

The original task identified issues with lean-research-agent.md not properly delegating status updates. With the migration to Claude Code, the architecture has fundamentally changed:

1. **Skills replace subagents**: `skill-lean-research/SKILL.md` replaces `lean-research-agent.md`
2. **Direct MCP tools**: Claude Code calls `mcp__lean-lsp__*` tools directly
3. **No delegation pattern**: Status updates handled by the orchestrating command, not the skill

The revised goal is to ensure the Lean research skill correctly defines and uses MCP tools for systematic research.

### Current State

Task 218 (just completed) already addressed most configuration issues:
- Fixed `.mcp.json` with correct `LEAN_PROJECT_PATH`
- Updated `skill-lean-research/SKILL.md` with all MCP tools including `lean_state_search` and `lean_hammer_premise`
- Rewrote `mcp-tools-guide.md` for Claude Code

### Remaining Work

1. Verify skill documentation is complete for systematic research workflow
2. Add explicit tool usage patterns for Lean research
3. Ensure rate limit awareness is documented
4. Test with actual Lean research task

### Scope

**In Scope**:
- Enhance `skill-lean-research/SKILL.md` with systematic workflow patterns
- Add search decision tree to skill documentation
- Document rate limit management strategy
- Verify MCP tools work for Lean research

**Out of Scope**:
- OpenCode subagent files (deprecated, not used)
- Status-sync-manager delegation (handled by commands, not skills)
- Git workflow management (handled by commands, not skills)

### Definition of Done

- [ ] skill-lean-research/SKILL.md has comprehensive tool usage patterns
- [ ] Search decision tree documented in skill
- [ ] Rate limit management strategy documented
- [ ] Workflow for systematic Lean research documented
- [ ] MCP tools verified working for research task

---

## Goals and Non-Goals

### Goals

1. **Ensure systematic research**: Document step-by-step Lean research workflow
2. **Optimize tool selection**: Clear guidance on which MCP tool for which task
3. **Manage rate limits**: Strategy for working within API limits
4. **Enable efficient research**: Minimize redundant searches

### Non-Goals

1. **Fix OpenCode subagents**: Deprecated, will be removed
2. **Implement new MCP tools**: Using existing lean-lsp-mcp tools
3. **Change command structure**: Skills are invoked by commands, not vice versa

---

## Risks and Mitigations

### Risk 1: MCP Server Path Issue

**Likelihood**: Low (fixed in task 218)
**Impact**: High
**Mitigation**:
- Configuration verified in task 218
- Session restart applies fix
- Fallback to `lake build` for verification

### Risk 2: Rate Limit Exhaustion

**Likelihood**: Medium
**Impact**: Medium (slows research)
**Mitigation**:
- Use `lean_local_search` first (no rate limit)
- Document rate limits prominently
- Batch similar queries
- Use `lean_leanfinder` when possible (10/30s vs 3/30s)

---

## Implementation Phases

### Phase 1: Enhance Skill Documentation [NOT STARTED]

**Estimated Effort**: 30 minutes
**Status**: [NOT STARTED]

**Objective**: Add comprehensive workflow documentation to skill-lean-research.

**Tasks**:
1. Add systematic research workflow section:
   - Step 1: Understand task requirements
   - Step 2: Search local project first
   - Step 3: Search Mathlib with appropriate tool
   - Step 4: Verify and cross-reference findings
   - Step 5: Synthesize into research report

2. Add tool selection matrix:
   - When to use `lean_local_search` (always first)
   - When to use `lean_leansearch` (natural language)
   - When to use `lean_loogle` (type patterns)
   - When to use `lean_leanfinder` (concepts)
   - When to use `lean_state_search` (goal-directed)
   - When to use `lean_hammer_premise` (automation hints)

3. Add rate limit management section:
   - Document limits clearly
   - Recommend batching strategy
   - Suggest fallback approaches

4. Add common research patterns:
   - "Find theorem by name" pattern
   - "Find theorem by type" pattern
   - "Find tactic for goal" pattern

**Acceptance Criteria**:
- [ ] Systematic workflow documented
- [ ] Tool selection matrix added
- [ ] Rate limit management documented
- [ ] Common patterns documented

**Files to Modify**:
- `.claude/skills/skill-lean-research/SKILL.md`

---

### Phase 2: Verify MCP Tool Functionality [NOT STARTED]

**Estimated Effort**: 15 minutes
**Status**: [NOT STARTED]

**Objective**: Verify MCP tools work correctly for Lean research.

**Tasks**:
1. After MCP server restart (new session), test:
   - `lean_local_search` with "Frame" query
   - `lean_leansearch` with natural language query
   - `lean_loogle` with type pattern
   - `lean_hover_info` on a known symbol

2. Document any issues encountered
3. Verify rate limiting is enforced correctly

**Acceptance Criteria**:
- [ ] `lean_local_search` returns results
- [ ] `lean_leansearch` returns Mathlib theorems
- [ ] `lean_loogle` returns type matches
- [ ] `lean_hover_info` returns type signatures

**Note**: MCP server needs session restart to pick up corrected `LEAN_PROJECT_PATH` from task 218.

---

### Phase 3: Update TODO.md Entry [NOT STARTED]

**Estimated Effort**: 10 minutes
**Status**: [NOT STARTED]

**Objective**: Update task 291 to reflect revised scope.

**Tasks**:
1. Update task description to reflect Claude Code focus
2. Update acceptance criteria for revised scope
3. Mark task as [PLANNED] with revised plan link

**Acceptance Criteria**:
- [ ] Task description updated
- [ ] Acceptance criteria reflect revised scope
- [ ] Plan link points to v002

**Files to Modify**:
- `.claude/specs/TODO.md`
- `.claude/specs/state.json`

---

## Testing and Validation

### Tool Verification

After Phase 2, verify:
- MCP tools respond without errors
- Rate limits are respected
- Results are relevant and useful

### Documentation Review

After Phase 1, verify:
- Workflow is clear and actionable
- Tool selection guidance is complete
- Rate limit strategy is practical

---

## Artifacts and Outputs

### Modified Files

1. `.claude/skills/skill-lean-research/SKILL.md`
   - Enhanced workflow documentation
   - Tool selection matrix
   - Rate limit management

### Created Files

None (only modifying existing skill file)

---

## Rollback/Contingency

### If MCP Tools Don't Work

1. Document issue in errors.json
2. Use web search for Mathlib documentation
3. Use `lake build` for verification
4. Create follow-up task for MCP troubleshooting

### If Documentation Is Insufficient

1. Gather feedback from actual research usage
2. Iterate on documentation
3. Add examples from real research tasks

---

## Success Criteria

### Functional Success

- [ ] MCP tools work for Lean research
- [ ] Rate limits don't block research workflow
- [ ] Tool selection is clear and efficient

### Documentation Success

- [ ] Workflow is comprehensive
- [ ] Tool selection is unambiguous
- [ ] Rate limit strategy is practical

---

## Dependencies

### Upstream Dependencies

- **Task 218**: MCP configuration fixed (COMPLETED)
- **Session restart**: Required for MCP path fix to take effect

### External Dependencies

- **lean-lsp-mcp**: MCP server must be available via `uvx`
- **Mathlib search APIs**: leansearch.net, loogle.lean-lang.org, lean finder

---

## Notes

### OpenCode vs Claude Code

| Aspect | OpenCode (v001) | Claude Code (v002) |
|--------|-----------------|-------------------|
| Research agent | `lean-research-agent.md` | `skill-lean-research/SKILL.md` |
| Status updates | Delegation to status-sync-manager | Handled by orchestrator/commands |
| Git commits | Delegation to git-workflow-manager | Handled by orchestrator/commands |
| Tool invocation | Via Python wrapper | Direct `mcp__lean-lsp__*` calls |
| Tool declaration | Per-agent in config | `allowed-tools` in SKILL.md |

### What This Plan Does NOT Cover

- OpenCode subagent modifications (deprecated)
- Status synchronization (handled by commands)
- Git workflow management (handled by commands)
- New MCP tool implementation

### Relationship to Task 218

Task 218 (just completed) addressed:
- MCP configuration in `.mcp.json`
- Skill tool declarations in `allowed-tools`
- MCP tools guide rewrite

This task (291 revised) focuses on:
- Skill workflow documentation
- Tool usage patterns
- Research methodology

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 001 | 2026-01-04 | Planner | Initial plan for OpenCode subagents |
| 002 | 2026-01-10 | Claude | Revised for Claude Code skill system |

# Implementation Plan: Task #743

- **Task**: 743 - restore_lean_implementation_agent_thin_wrapper
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Priority**: high
- **Dependencies**: None (Task 742 completed successfully, provides parallel template)
- **Research Inputs**: specs/743_restore_lean_implementation_agent_thin_wrapper/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task restores lean-implementation-agent from deprecated state and converts skill-lean-implementation from 524-line direct execution to a ~100-line thin wrapper delegating via Task tool. The conversion parallels task 742 (lean-research-agent restoration) with additional complexity for completion_data generation and phase execution. Key patterns include: blocked MCP tools guardrails, early metadata (Stage 0), metadata file exchange, and completion_data propagation.

### Research Integration

- Research report (research-001.md) identified current skill at 524 lines with key stages to preserve (1-3, 10-14) and move to agent (4-9)
- Blocked tools section template available from lean-research-agent (task 742 result)
- Completion_data schema documented in return-metadata-file.md
- Early metadata pattern documented in early-metadata-pattern.md

## Goals & Non-Goals

**Goals**:
- Restore lean-implementation-agent from DEPRECATED state with explicit blocked tools guardrails
- Convert skill-lean-implementation to thin wrapper pattern (~100-120 lines)
- Ensure blocked tools (lean_diagnostic_messages, lean_file_outline) are prominently warned against
- Implement metadata file exchange via .return-meta.json
- Add Stage 0 early metadata pattern for interruption recovery
- Enable completion_data generation (completion_summary, roadmap_items)
- Update CLAUDE.md skill-to-agent mapping table

**Non-Goals**:
- Changing lean-implementation-flow.md (agent references this for execution details)
- Modifying MCP tool configurations
- Altering tactic selection strategies (preserved in agent or flow document)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent may call blocked tools despite warnings | Medium | Prominent BLOCKED TOOLS section with table, Critical Requirements checklist |
| MCP tool hanging in subagent | Medium | Early metadata ensures recovery; agent continues with partial |
| completion_data not propagated to state.json | High | Explicit Stage 6a in agent, explicit Stage 7 extraction in skill |
| Phase commit granularity lost | Low | Agent handles per-phase commits; skill handles final commit |
| Skill line count exceeds target ~100 lines | Low | May reach ~120 lines due to completion_data handling; acceptable |

## Implementation Phases

### Phase 1: Restore lean-implementation-agent.md [COMPLETED]

**Goal**: Remove DEPRECATED notice and add explicit blocked tools guardrails to the agent

**Tasks**:
- [ ] Remove DEPRECATED notice block (lines 1-5 approximately)
- [ ] Add BLOCKED TOOLS section before Allowed Tools (copy from lean-research-agent)
- [ ] Include table with Tool, Bug, Alternative columns
- [ ] Add "Why Blocked" explanations for each tool
- [ ] Remove lean_diagnostic_messages and lean_file_outline from Core Tools list
- [ ] Add MUST DO #10: "NEVER call lean_diagnostic_messages or lean_file_outline (blocked tools)"
- [ ] Add MUST NOT #11: "Call blocked tools (lean_diagnostic_messages, lean_file_outline)"
- [ ] Verify Stage 0 early metadata pattern is documented
- [ ] Verify completion_data generation is documented (Stage 6a or similar)
- [ ] Update agent to handle metadata file path from delegation context

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Restore from deprecated, add blocked tools

**Verification**:
- Agent file has no DEPRECATED notice
- BLOCKED TOOLS section appears before Allowed Tools
- lean_diagnostic_messages and lean_file_outline not in Allowed Tools or Core Tools
- Critical Requirements include explicit blocked tool prohibitions
- Stage 0 early metadata pattern is present
- completion_data generation is documented

---

### Phase 2: Convert skill-lean-implementation to Thin Wrapper [COMPLETED]

**Goal**: Replace 524-line direct execution with ~100-120 line thin wrapper delegating to lean-implementation-agent

**Tasks**:
- [ ] Update frontmatter: `allowed-tools: Task, Bash, Edit, Read, Write`
- [ ] Keep Stage 1: Input Validation (task validation, plan existence check)
- [ ] Keep Stage 2: Preflight Status Update (status to implementing)
- [ ] Keep Stage 3: Create Postflight Marker (.postflight-pending)
- [ ] Add Stage 4: Prepare Delegation Context (from skill-implementer pattern)
  - Include session_id, task_context, plan_path, metadata_file_path
  - Set timeout to 7200s (implementation takes longer than research)
- [ ] Add Stage 5: Invoke Subagent via Task tool
  - Use Task tool NOT Skill tool
  - Include agent prompt with context
- [ ] Add Stage 5a: Validate Subagent Return Format
  - Check for accidental JSON in console output
- [ ] Add Stage 6: Parse Subagent Return
  - Read .return-meta.json file
  - Extract status, artifacts, completion_data, partial_progress
- [ ] Modify Stage 7: Update Task Status (Postflight)
  - Extract completion_summary from completion_data
  - Extract roadmap_items from completion_data (if present)
  - Propagate to state.json
- [ ] Keep Stage 8: Link Artifacts in TODO.md
- [ ] Keep Stage 9: Git Commit (final commit only, agent does per-phase)
- [ ] Keep Stage 10: Cleanup (.postflight-pending removal)
- [ ] Keep Stage 11: Return Brief Summary
- [ ] Remove all direct MCP tool calls (lean_goal, lean_multi_attempt, etc.)
- [ ] Remove proof development loop (moved to agent)
- [ ] Remove tactic selection documentation (moved to agent or flow)

**Timing**: 60 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Convert to thin wrapper

**Verification**:
- Skill file approximately 100-120 lines
- No direct MCP tool calls remain
- Task tool invocation matches skill-implementer pattern
- completion_data extraction present in Stage 7
- frontmatter shows `allowed-tools: Task, Bash, Edit, Read, Write`

---

### Phase 3: Update CLAUDE.md Skill-to-Agent Mapping [COMPLETED]

**Goal**: Update documentation to reflect skill-lean-implementation now delegates to lean-implementation-agent

**Tasks**:
- [ ] Change skill-lean-implementation agent from "(direct execution)" to "lean-implementation-agent"
- [ ] Verify table alignment and formatting
- [ ] Verify no other references to direct execution for Lean implementation

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update Skill-to-Agent Mapping table

**Verification**:
- Table shows skill-lean-implementation maps to lean-implementation-agent
- Table formatting is correct

---

### Phase 4: Verification and Testing [COMPLETED]

**Goal**: Verify all files have valid syntax and patterns are correctly implemented

**Tasks**:
- [ ] Verify lean-implementation-agent.md has valid markdown
- [ ] Verify BLOCKED TOOLS appears before Allowed Tools section
- [ ] Verify blocked tools not in any allowed/core tools lists
- [ ] Verify skill-lean-implementation has valid markdown
- [ ] Verify Task tool invocation pattern matches skill-implementer
- [ ] Verify completion_data flow: agent generates -> skill extracts -> state.json
- [ ] Verify delegation context includes all required fields
- [ ] Cross-check with lean-research-agent patterns from task 742
- [ ] Verify early metadata pattern documented in agent

**Timing**: 30 minutes

**Files to verify**:
- `.claude/agents/lean-implementation-agent.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/CLAUDE.md`

**Verification**:
- All files pass syntax checks
- Patterns match task 742 results for consistency
- No blocked tools accessible in agent
- completion_data flows correctly

## Testing & Validation

- [ ] lean-implementation-agent.md contains BLOCKED TOOLS section with table
- [ ] lean-implementation-agent.md Critical Requirements includes blocked tool prohibitions
- [ ] skill-lean-implementation.md is approximately 100-120 lines (vs current 524)
- [ ] skill-lean-implementation.md uses Task tool for delegation
- [ ] skill-lean-implementation.md extracts completion_data in postflight
- [ ] CLAUDE.md shows lean-implementation-agent for skill-lean-implementation
- [ ] No direct MCP tool calls remain in skill file
- [ ] Delegation context includes session_id, task_context, plan_path, metadata_file_path
- [ ] Agent documents Stage 0 early metadata pattern

## Artifacts & Outputs

- `.claude/agents/lean-implementation-agent.md` - Restored agent with blocked tools guardrails
- `.claude/skills/skill-lean-implementation/SKILL.md` - Thin wrapper (~100-120 lines)
- `.claude/CLAUDE.md` - Updated skill-to-agent mapping
- `specs/743_restore_lean_implementation_agent_thin_wrapper/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Agent file changes are isolated to lean-implementation-agent.md - revert single file
2. Skill file changes are isolated to SKILL.md - revert single file
3. CLAUDE.md table change is minimal - easily reverted
4. Git history preserves all previous versions

If agent delegation proves problematic:
- Can revert to direct execution pattern (current state) as fallback
- Current skill at 524 lines remains functional until proven otherwise

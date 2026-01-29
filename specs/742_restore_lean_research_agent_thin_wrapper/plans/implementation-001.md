# Implementation Plan: Task #742

- **Task**: 742 - restore_lean_research_agent_thin_wrapper
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Priority**: high
- **Dependencies**: None
- **Research Inputs**: specs/742_restore_lean_research_agent_thin_wrapper/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Restore lean-research-agent from its deprecated state by adding explicit blocked tool guardrails, then convert skill-lean-research from 408-line direct execution to an ~80-line thin wrapper that delegates via Task tool. The conversion follows patterns established by skill-researcher and general-research-agent, ensuring consistent metadata file exchange and early metadata (Stage 0) pattern.

### Research Integration

Research report (research-001.md) provided:
- Thin wrapper pattern template extracted from skill-researcher (308 lines)
- Agent pattern template extracted from general-research-agent (404 lines)
- Blocked tools guardrails section template (lean_diagnostic_messages, lean_file_outline)
- Line-by-line mapping of content movement from skill to agent
- Stage 0 early metadata pattern documentation

## Goals & Non-Goals

**Goals**:
- Restore lean-research-agent.md to active status (remove deprecation notice)
- Add prominent BLOCKED TOOLS section to lean-research-agent before Allowed Tools
- Remove blocked tools from agent's Core Tools list
- Convert skill-lean-research to thin wrapper (~80 lines)
- Ensure skill delegates to lean-research-agent via Task tool
- Maintain metadata file exchange pattern (.return-meta.json)
- Update CLAUDE.md skill-to-agent mapping

**Non-Goals**:
- Modifying lean-research-flow.md (agent continues to reference it)
- Changing MCP tool behavior or fixing blocked tool bugs
- Adding new functionality beyond pattern alignment
- Modifying general-research-agent or skill-researcher

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agent may still call blocked tools despite guardrails | Medium | Low | Explicit BLOCKED TOOLS section at top of Allowed Tools, clear alternatives provided |
| MCP tools may hang in subagent | Medium | Medium | Document recovery pattern; agent continues with partial results |
| Line count exceeds ~80 estimate | Low | Medium | Reference external docs; consolidate repeated patterns |
| Skill-to-agent communication failure | Medium | Low | Early metadata pattern ensures metadata exists for resume |

## Implementation Phases

### Phase 1: Restore lean-research-agent.md [COMPLETED]

**Goal**: Remove deprecation and add blocked tool guardrails to lean-research-agent.md

**Tasks**:
- [ ] Read current lean-research-agent.md (deprecated, 151 lines)
- [ ] Read archived lean-research-agent.md.bak for reference (144 lines)
- [ ] Remove DEPRECATED notice block from top of file
- [ ] Add BLOCKED TOOLS section before Allowed Tools section
- [ ] Remove lean_diagnostic_messages from Core Tools list
- [ ] Remove lean_file_outline from Core Tools list
- [ ] Verify Stage 0 early metadata pattern is present
- [ ] Verify reference to lean-research-flow.md is preserved

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Remove deprecation, add BLOCKED TOOLS section

**Verification**:
- No DEPRECATED notice at top of file
- BLOCKED TOOLS section exists before Allowed Tools
- lean_diagnostic_messages and lean_file_outline not in Allowed Tools
- Stage 0 early metadata pattern documented
- File remains functional agent specification

---

### Phase 2: Convert skill-lean-research to Thin Wrapper [COMPLETED]

**Goal**: Transform skill-lean-research from 408-line direct execution to ~80-line thin wrapper

**Tasks**:
- [ ] Read current skill-lean-research/SKILL.md (408 lines)
- [ ] Read skill-researcher/SKILL.md as template (308 lines)
- [ ] Update frontmatter: `allowed-tools: Task, Bash, Edit, Read, Write`
- [ ] Keep Stage 1: Input Validation (adapt from lines 40-62)
- [ ] Keep Stage 2: Preflight Status Update (adapt from lines 64-82)
- [ ] Keep Stage 3: Create Postflight Marker (adapt from lines 84-102)
- [ ] Add Stage 4: Prepare Delegation Context (copy pattern from skill-researcher)
- [ ] Add Stage 5: Invoke Subagent via Task tool (copy pattern from skill-researcher)
- [ ] Add Stage 6: Parse Subagent Return (read .return-meta.json)
- [ ] Keep Stage 7-10: Postflight, Commit, Cleanup (adapt from current)
- [ ] Keep Stage 11: Return Brief Summary
- [ ] Remove all MCP tool calls and direct search execution logic
- [ ] Remove rate limit handling (moves to agent)
- [ ] Remove fallback chain logic (moves to agent)

**Timing**: 1 hour

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Replace with thin wrapper

**Verification**:
- SKILL.md is approximately 80-100 lines
- Frontmatter specifies `allowed-tools: Task, Bash, Edit, Read, Write`
- No direct MCP tool calls in skill
- Task tool invocation delegates to lean-research-agent
- Metadata file path passed to agent
- Postflight stages preserved for status update and commit

---

### Phase 3: Update CLAUDE.md Skill-to-Agent Mapping [COMPLETED]

**Goal**: Update documentation to reflect restored delegation pattern

**Tasks**:
- [ ] Read current CLAUDE.md skill-to-agent table
- [ ] Change skill-lean-research entry from `(direct execution)` to `lean-research-agent`
- [ ] Verify table alignment and formatting

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update skill-to-agent mapping table

**Verification**:
- skill-lean-research row shows `lean-research-agent` as Agent column
- Table maintains proper alignment

---

### Phase 4: Verification and Testing [COMPLETED]

**Goal**: Verify complete integration works correctly

**Tasks**:
- [ ] Verify lean-research-agent.md has no syntax errors
- [ ] Verify skill-lean-research/SKILL.md has valid frontmatter
- [ ] Verify blocked tools warning appears prominently in agent
- [ ] Verify Task tool invocation pattern matches skill-researcher
- [ ] Verify metadata file path follows correct naming convention
- [ ] Create brief summary of all changes made

**Timing**: 30 minutes

**Files to review**:
- `.claude/agents/lean-research-agent.md` - Structure and content
- `.claude/skills/skill-lean-research/SKILL.md` - Thin wrapper pattern
- `.claude/CLAUDE.md` - Mapping table

**Verification**:
- All files parse correctly (no YAML/markdown errors)
- Delegation pattern matches skill-researcher pattern
- Blocked tools prominently documented
- All cross-references valid

## Testing & Validation

- [ ] lean-research-agent.md contains BLOCKED TOOLS section
- [ ] lean-research-agent.md has no DEPRECATED notice
- [ ] skill-lean-research/SKILL.md is ~80-100 lines
- [ ] skill-lean-research/SKILL.md frontmatter has `allowed-tools: Task, Bash, Edit, Read, Write`
- [ ] CLAUDE.md skill-to-agent table shows lean-research-agent for skill-lean-research
- [ ] No references to lean_diagnostic_messages or lean_file_outline in agent Allowed Tools
- [ ] Stage 0 early metadata pattern present in agent

## Artifacts & Outputs

- `.claude/agents/lean-research-agent.md` - Restored with blocked tools guardrails
- `.claude/skills/skill-lean-research/SKILL.md` - Converted to thin wrapper
- `.claude/CLAUDE.md` - Updated skill-to-agent mapping
- `specs/742_restore_lean_research_agent_thin_wrapper/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails or causes issues:
1. Restore lean-research-agent.md from git (pre-modification state)
2. Restore skill-lean-research/SKILL.md from git
3. Restore CLAUDE.md from git
4. All files are version controlled; no data loss risk
5. Alternative: Keep skill-lean-research as direct execution (current state) while debugging agent issues

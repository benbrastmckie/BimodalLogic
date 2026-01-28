# Implementation Plan: Refactor Lean Skills to Direct Execution

- **Task**: 710 - Refactor Lean skills from subagent delegation to direct execution
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/710_refactor_lean_skills_direct_execution/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Refactor skill-lean-research and skill-lean-implementation from the thin wrapper delegation pattern to direct execution pattern. The current architecture delegates to subagents (lean-research-agent, lean-implementation-agent) via the Task tool, but MCP tools hang indefinitely in subagents due to Claude Code platform bugs (#15945, #13254, #4580). The solution is to move all MCP tool invocations directly into the skills, eliminating the problematic delegation layer while preserving all functionality.

### Research Integration

Research report (research-001.md) identified:
- Current skills use thin wrapper pattern with ~300-400 lines each
- Agents contain ~140 lines of execution logic each
- Direct execution pattern exists in skill-status-sync (295 lines) and skill-learn (677 lines)
- Migration requires updating frontmatter, inlining agent logic, removing Task tool invocation
- Risk of context window bloat mitigated by lazy @-reference loading

## Goals & Non-Goals

**Goals**:
- Eliminate MCP tool hanging in Lean workflows
- Preserve all research and implementation functionality
- Maintain compatibility with existing /research and /implement commands
- Keep existing preflight/postflight patterns
- Preserve error recovery and resume capabilities

**Non-Goals**:
- Changing the user-facing command interface
- Modifying MCP tool behavior
- Refactoring non-Lean skills
- Changing state.json or TODO.md formats

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Context window bloat | Medium | Low | Use lazy @-reference loading, not eager context inclusion |
| Losing subagent isolation | Low | Medium | Skills already accumulate context in main conversation; acceptable |
| MCP tool availability issues | Medium | Low | Keep MCP recovery pattern in skill; retry once, try alternative, continue |
| Rate limit management | Medium | Medium | Add rate limit tracking variables; prefer unlimited tools first |
| Breaking changes during migration | High | Medium | Test each skill independently before updating documentation |

## Implementation Phases

### Phase 1: Archive Existing Agents [COMPLETED]

**Goal**: Create backup copies of current agents before modification for reference and potential rollback.

**Tasks**:
- [ ] Create `.claude/agents/archive/` directory
- [ ] Copy `lean-research-agent.md` to `archive/lean-research-agent.md.bak`
- [ ] Copy `lean-implementation-agent.md` to `archive/lean-implementation-agent.md.bak`
- [ ] Add deprecation notice header to original agent files

**Timing**: 15 minutes

**Files to modify**:
- `.claude/agents/archive/lean-research-agent.md.bak` - Create (copy)
- `.claude/agents/archive/lean-implementation-agent.md.bak` - Create (copy)
- `.claude/agents/lean-research-agent.md` - Add deprecation header
- `.claude/agents/lean-implementation-agent.md` - Add deprecation header

**Verification**:
- Archive directory exists with both backup files
- Original agent files have deprecation notices

---

### Phase 2: Convert skill-lean-research to Direct Execution [COMPLETED]

**Goal**: Refactor skill-lean-research to execute MCP research tools directly instead of delegating to lean-research-agent.

**Tasks**:
- [ ] Update frontmatter: change `allowed-tools` from `Task, Bash, Edit, Read, Write` to include all Lean MCP search tools
- [ ] Remove Task tool invocation section (Stage 5)
- [ ] Inline search decision tree logic from lean-research-agent
- [ ] Inline rate limit management logic
- [ ] Inline search execution with fallback chain
- [ ] Inline findings synthesis and report creation
- [ ] Add Context Loading section with @-references
- [ ] Update error handling for direct MCP tool failures
- [ ] Keep existing preflight (Stages 1-3) and postflight (Stages 7-11) logic
- [ ] Simplify metadata exchange (no .return-meta.json file exchange needed)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Major rewrite

**Verification**:
- Skill file compiles without syntax errors
- No references to Task tool or lean-research-agent remain
- All MCP tools listed in allowed-tools
- Context Loading section present

---

### Phase 3: Convert skill-lean-implementation to Direct Execution [COMPLETED]

**Goal**: Refactor skill-lean-implementation to execute MCP implementation tools directly instead of delegating to lean-implementation-agent.

**Tasks**:
- [ ] Update frontmatter: change `allowed-tools` to include all Lean MCP implementation tools
- [ ] Remove Task tool invocation section (Stage 5)
- [ ] Inline plan parsing and resume point detection from lean-implementation-agent
- [ ] Inline proof development loop with lean_goal, lean_multi_attempt
- [ ] Inline phase checkpoint protocol (git commit per phase)
- [ ] Inline build verification with lean_build
- [ ] Inline summary creation and completion data generation
- [ ] Add Context Loading section with @-references
- [ ] Update error handling for direct MCP tool failures
- [ ] Keep existing preflight (Stages 1-3) and postflight (Stages 7-11) logic
- [ ] Simplify metadata exchange

**Timing**: 2 hours

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Major rewrite

**Verification**:
- Skill file compiles without syntax errors
- No references to Task tool or lean-implementation-agent remain
- All MCP tools listed in allowed-tools
- Context Loading section present
- Proof development loop includes lean_goal usage

---

### Phase 4: Update Documentation [COMPLETED]

**Goal**: Update CLAUDE.md and related documentation to reflect the architectural change.

**Tasks**:
- [ ] Update CLAUDE.md Skill-to-Agent Mapping table: change lean-research and lean-implementation to "(direct execution)"
- [ ] Update CLAUDE.md Language-Based Routing section if needed
- [ ] Update thin-wrapper-skill.md to note Lean skills as exception
- [ ] Add migration note to MCP Server Configuration section explaining why Lean skills use direct execution
- [ ] Update any references to subagent delegation for Lean workflows

**Timing**: 45 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Update Skill-to-Agent Mapping table
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Add note about Lean skills exception

**Verification**:
- CLAUDE.md Skill-to-Agent Mapping shows "(direct execution)" for lean-research and lean-implementation
- No documentation claims Lean skills delegate to subagents

---

### Phase 5: Verification and Testing [COMPLETED]

**Goal**: Verify refactored skills work correctly with actual Lean tasks.

**Tasks**:
- [ ] Create a test Lean task (or use existing pending Lean task)
- [ ] Run `/research {N}` on test task, verify MCP tools execute without hanging
- [ ] Verify research report is created correctly
- [ ] Verify status updates and git commit occur
- [ ] Run `/plan {N}` to create implementation plan
- [ ] Run `/implement {N}` on test task, verify proof development works
- [ ] Verify lean_goal returns proof states correctly
- [ ] Verify lake build executes successfully
- [ ] Verify implementation summary is created
- [ ] Test resume behavior (interrupt and re-run /implement)

**Timing**: 45 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- /research command completes without MCP hanging
- /implement command completes without MCP hanging
- All artifacts created correctly
- Resume from interruption works

---

## Testing & Validation

- [ ] skill-lean-research executes MCP search tools directly
- [ ] skill-lean-implementation executes MCP implementation tools directly
- [ ] Rate-limited tools (leansearch, loogle, leanfinder) respect limits
- [ ] lean_goal returns proof states during implementation
- [ ] lake build verification works
- [ ] Preflight/postflight patterns preserved
- [ ] Error recovery (MCP failure → retry → fallback) works
- [ ] Resume from partial implementation works
- [ ] Git commits include correct session IDs

## Artifacts & Outputs

- `specs/710_refactor_lean_skills_direct_execution/plans/implementation-001.md` (this file)
- `.claude/skills/skill-lean-research/SKILL.md` (modified)
- `.claude/skills/skill-lean-implementation/SKILL.md` (modified)
- `.claude/agents/archive/lean-research-agent.md.bak` (created)
- `.claude/agents/archive/lean-implementation-agent.md.bak` (created)
- `.claude/agents/lean-research-agent.md` (deprecated)
- `.claude/agents/lean-implementation-agent.md` (deprecated)
- `.claude/CLAUDE.md` (modified)
- `specs/710_refactor_lean_skills_direct_execution/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If the refactored skills fail:

1. **Immediate rollback**: Restore skills from git history (`git checkout HEAD~1 -- .claude/skills/skill-lean-research/SKILL.md .claude/skills/skill-lean-implementation/SKILL.md`)
2. **Agent restoration**: Remove deprecation notices from agent files
3. **Documentation rollback**: Revert CLAUDE.md changes
4. **Investigation**: Check errors.json for MCP failure patterns
5. **Alternative approach**: Consider partial migration (research only, or implementation only)

The archived agent files in `.claude/agents/archive/` provide reference material for understanding the original logic if needed during debugging.

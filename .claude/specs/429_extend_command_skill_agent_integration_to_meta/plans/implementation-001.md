# Implementation Plan: Task #429

- **Task**: 429 - Extend command-skill-agent integration to /meta
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Priority**: High
- **Dependencies**: Task 427 (completed - provides framework documentation)
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Extend the command-skill-agent integration pattern to `/meta` by creating `skill-meta` and `meta-builder-agent`. The current `/meta` command (508 lines, direct execution) will be refactored to use the thin wrapper pattern established by task 427, making it consistent with `/research`, `/plan`, and `/implement`.

### Research Integration

Research findings (research-001.md) recommend:
- **Option A: Full Three-Layer Integration** for consistency with established architecture
- Use `AskUserQuestion` tool within agent for interactive interview stages
- Load component guides (`creating-skills.md`, `creating-agents.md`, `creating-commands.md`) on-demand based on workflow
- Preserve all three modes: interactive, prompt, analyze

## Goals & Non-Goals

**Goals**:
- Create `skill-meta` following thin wrapper pattern with `context: fork`
- Create `meta-builder-agent` handling all three modes (interactive, prompt, analyze)
- Refactor `/meta` command to delegate to skill via Skill tool
- Maintain full backward compatibility with existing `/meta` usage patterns
- Leverage framework documentation from task 427 as agent context

**Non-Goals**:
- Creating multiple specialized agents per mode (keep single agent for simplicity)
- Adding new features to /meta (this is a refactoring task)
- Modifying the component creation guides themselves

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Interactive interview flow disrupted | High | Medium | Test AskUserQuestion extensively; preserve 7-stage structure |
| Token overhead from agent context | Medium | Low | Use lazy loading; only load guides when needed for specific mode |
| Breaking existing /meta users | Medium | Low | Keep command interface identical; only change internals |
| Agent file too large | Medium | Medium | Focus on mode routing; each mode's logic is self-contained |

## Implementation Phases

### Phase 1: Create skill-meta [NOT STARTED]

**Goal**: Create the thin wrapper skill that validates inputs and delegates to meta-builder-agent

**Tasks**:
- [ ] Create directory `.claude/skills/skill-meta/`
- [ ] Create `SKILL.md` with proper frontmatter (`context: fork`, `agent: meta-builder-agent`)
- [ ] Define trigger conditions for all three modes (interactive, prompt, analyze)
- [ ] Implement input validation for mode detection
- [ ] Define context preparation with session_id and mode information
- [ ] Document agent invocation expectations
- [ ] Add return validation and error handling sections

**Timing**: 30 minutes

**Files to create**:
- `.claude/skills/skill-meta/SKILL.md`

**Verification**:
- [ ] Frontmatter has `context: fork` and `agent: meta-builder-agent`
- [ ] Trigger conditions cover all three modes
- [ ] Input validation section handles all argument patterns
- [ ] Follows `creating-skills.md` template structure

---

### Phase 2: Create meta-builder-agent [NOT STARTED]

**Goal**: Create the agent that executes all /meta workflows including interactive interview

**Tasks**:
- [ ] Create `.claude/agents/meta-builder-agent.md`
- [ ] Define agent metadata (name, purpose, invoked by)
- [ ] Define allowed tools: Read, Write, Edit, Glob, Grep, Bash(git, jq, mkdir), AskUserQuestion
- [ ] Document context references for on-demand loading
- [ ] Implement 8-stage workflow:
  - Stage 1: Parse delegation context (mode, arguments)
  - Stage 2: Load context based on mode (component guides for create, architecture for analyze)
  - Stage 3: Execute mode-specific workflow
  - Stage 4: Generate outputs (task entries or analysis report)
  - Stage 5: Create artifacts (task directories, state updates)
  - Stage 6: Return structured JSON
  - Stage 7: Update TODO.md and state.json, git commit
  - Stage 8: Cleanup
- [ ] Add mode-specific sections for interactive, prompt, and analyze flows
- [ ] Add error handling for common failures
- [ ] Add return format examples for each mode

**Timing**: 1.5 hours

**Files to create**:
- `.claude/agents/meta-builder-agent.md`

**Verification**:
- [ ] All 8 stages documented
- [ ] Each mode has dedicated workflow section
- [ ] Uses AskUserQuestion for interactive stages
- [ ] Return format matches subagent-return.md schema
- [ ] Context references use @-syntax for lazy loading

---

### Phase 3: Refactor /meta command [NOT STARTED]

**Goal**: Update /meta command to delegate to skill-meta instead of direct execution

**Tasks**:
- [ ] Read current `/meta` command thoroughly
- [ ] Remove direct execution logic (~400 lines of interview, analyze, task creation)
- [ ] Keep frontmatter and basic structure
- [ ] Add mode detection logic (interactive, prompt, analyze)
- [ ] Add Skill tool invocation to skill-meta
- [ ] Preserve argument parsing for prompt and --analyze modes
- [ ] Update allowed-tools to include `Skill` tool
- [ ] Document that actual work is delegated to agent

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/meta.md` - Major refactoring (reduce from ~508 to ~100 lines)

**Verification**:
- [ ] Command file is significantly smaller (100-150 lines vs 508)
- [ ] Skill tool is invoked for all modes
- [ ] Argument hint unchanged for backward compatibility
- [ ] Model specification preserved (claude-opus-4-5-20251101)

---

### Phase 4: Update context index and documentation [NOT STARTED]

**Goal**: Document /meta's new architecture and update related documentation

**Tasks**:
- [ ] Update `.claude/context/index.md` with /meta-specific context loading patterns
- [ ] Update CLAUDE.md skill-to-agent mapping table to include skill-meta -> meta-builder-agent
- [ ] Verify component-selection.md references are accurate

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/index.md` - Add /meta section
- `.claude/CLAUDE.md` - Update skill-to-agent mapping table

**Verification**:
- [ ] Index includes /meta context loading patterns
- [ ] CLAUDE.md mapping table is complete
- [ ] Cross-references are accurate

---

### Phase 5: Testing and verification [NOT STARTED]

**Goal**: Verify all three modes work correctly through the new architecture

**Tasks**:
- [ ] Test interactive mode: run `/meta` with no arguments
  - Verify interview stages 1-7 execute through agent
  - Verify AskUserQuestion prompts appear correctly
  - Verify task creation works (TODO.md + state.json)
- [ ] Test prompt mode: run `/meta "add a new skill for X"`
  - Verify abbreviated flow works
  - Verify task creation from prompt analysis
- [ ] Test analyze mode: run `/meta --analyze`
  - Verify read-only analysis works
  - Verify component counts and recommendations appear

**Timing**: 30 minutes

**Verification**:
- [ ] All three modes produce expected outputs
- [ ] Task creation properly updates TODO.md and state.json
- [ ] Git commits are created for task creation
- [ ] Error handling works for edge cases

---

## Testing & Validation

- [ ] Interactive mode preserves 7-stage interview flow
- [ ] Prompt mode provides abbreviated analysis path
- [ ] Analyze mode produces component inventory
- [ ] Task creation updates both TODO.md and state.json
- [ ] Git commits follow `meta: create {N} tasks for {domain}` convention
- [ ] Agent returns valid JSON matching subagent-return.md
- [ ] Skill validates inputs before delegation
- [ ] Backward compatibility: existing /meta usage patterns work unchanged

## Artifacts & Outputs

**New Files**:
- `.claude/skills/skill-meta/SKILL.md` (~120 lines)
- `.claude/agents/meta-builder-agent.md` (~500 lines)

**Modified Files**:
- `.claude/commands/meta.md` (reduced from ~508 to ~100-150 lines)
- `.claude/context/index.md` (add /meta section)
- `.claude/CLAUDE.md` (update skill-to-agent mapping)

## Rollback/Contingency

If implementation fails:
1. Keep original `/meta` command backed up (git preserves history)
2. Remove skill-meta directory if incomplete
3. Remove meta-builder-agent.md if incomplete
4. Revert /meta command to direct execution mode
5. Document failure in errors.json for analysis

The original command can be restored from git history at any point.

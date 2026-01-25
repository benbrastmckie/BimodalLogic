# Implementation Plan: Task #676 (v4)

- **Task**: 676 - Investigate skill registration and integrate /task command with checkpoint pattern
- **Status**: [NOT STARTED]
- **Effort**: 16 hours (expanded from 12h to include all commands)
- **Priority**: High
- **Dependencies**: Coordinate with Tasks 674, 675
- **Research Inputs**:
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-001.md
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-002.md
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-003.md (root cause)
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-004.md (industry patterns validation)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan expands the checkpoint migration to **all command-skill-agent patterns** in the `.claude/` system. Research-004.md validates that 9 industry patterns unanimously support Option C: checkpoints belong in commands, not skills.

### Why Expand Beyond v3

Plan v3 focused on `/research`, `/plan`, and `/implement`. However, several other commands also use the command→skill→agent pattern and would benefit from consistent checkpoint placement:

| Command | Current State | Needs Migration? |
|---------|--------------|------------------|
| `/research` | Full checkpoint in command | Already correct |
| `/plan` | Partial (skill handles some) | Yes |
| `/implement` | Partial (skill handles some) | Yes |
| `/revise` | Inline updates in command | Minimal - already command-level |
| `/task` | Direct (no skill) | No - direct execution |
| `/todo` | Direct (no skill) | No - direct execution |
| `/meta` | skill-meta delegation | Yes |
| `/learn` | skill-learn delegation | Yes |
| `/errors` | Direct (no skill) | No - direct execution |
| `/review` | Direct (no skill) | No - direct execution |
| `/convert` | skill-document-converter | Yes |
| `/refresh` | skill-refresh | Minimal - direct execution skill |

### Key Changes from v3

| Aspect | v3 | v4 |
|--------|----|----|
| Scope | 3 commands (research, plan, implement) | 7 commands + documentation |
| Lean skills | lean-research, lean-implementation | Include in pattern |
| LaTeX skills | latex-implementation | Include in pattern |
| /meta command | Not covered | Full migration |
| /learn command | Not covered | Full migration |
| /convert command | Not covered | Full migration |
| Skill template | Single template | Language-specific templates |
| Documentation | Phase 5 only | Comprehensive Phase 7 |
| Effort | 12 hours | 16 hours |

### Industry Validation (from research-004.md)

All 9 patterns analyzed support checkpoints in commands:
1. **API Gateway Pattern** - Commands = gateway layer
2. **Cross-Cutting Concerns** - Checkpoints are cross-cutting
3. **Transaction Boundaries** - Commands own transactions
4. **Command Pattern & SRP** - Skills should focus on delegation only
5. **CQRS Pattern** - Commands handle write operations
6. **Workflow Orchestration** - Setup/teardown at workflow level
7. **AWS CLI Agent Orchestrator** - Industry example validates pattern
8. **Root Cause Analysis** - Issue #17351 confirms skill postflight never runs
9. **Architectural Principles** - Separation of concerns favors commands

## Goals & Non-Goals

**Goals**:
- Migrate ALL command-skill-agent patterns to command-level checkpoints
- Ensure uniformity across all workflow commands
- Create consistent documentation structure
- Simplify skills to pure delegation (thin wrappers)
- Enable reliable postflight execution for all commands

**Non-Goals**:
- Modifying direct-execution commands (/task, /todo, /errors, /review)
- Adding new commands or skills
- Changing agent implementations
- Fixing GitHub Issue #17351 (Claude Code internal)

## Command-Skill Inventory

### Commands Requiring Full Migration

These commands delegate to skills which spawn agents. All need checkpoint migration:

| Command | Skill | Agent | Status |
|---------|-------|-------|--------|
| `/research` | skill-researcher | general-research-agent | Template (already done) |
| `/research` | skill-lean-research | lean-research-agent | Migration needed |
| `/plan` | skill-planner | planner-agent | Migration needed |
| `/implement` | skill-implementer | general-implementation-agent | Migration needed |
| `/implement` | skill-lean-implementation | lean-implementation-agent | Migration needed |
| `/implement` | skill-latex-implementation | latex-implementation-agent | Migration needed |
| `/meta` | skill-meta | meta-builder-agent | Migration needed |
| `/learn` | skill-learn | (direct) | Evaluate if skill needed |
| `/convert` | skill-document-converter | document-converter-agent | Migration needed |

### Commands Already Correct (No Migration Needed)

These commands execute directly without skill delegation:

| Command | Pattern | Notes |
|---------|---------|-------|
| `/task` | Direct execution | State updates inline |
| `/todo` | Direct execution | Complex but self-contained |
| `/revise` | Direct execution | Updates inline |
| `/errors` | Direct execution | Reads/writes errors.json |
| `/review` | Direct execution | Reads codebase, updates ROAD_MAP |
| `/refresh` | skill-refresh | Skill executes directly (no agent) |

## Implementation Phases

### Phase 1: Complete /research Migration [NOT STARTED]

**Goal**: Ensure both research skills (general and Lean) use command-level checkpoints

**Current State**:
- `/research.md` already has full checkpoint pattern (lines 36-253)
- `skill-researcher/SKILL.md` attempts postflight but uses hooks
- `skill-lean-research/SKILL.md` may have similar issues

**Tasks**:
- [ ] Audit `skill-lean-research/SKILL.md` for checkpoint code
- [ ] Remove postflight logic from `skill-researcher/SKILL.md`
- [ ] Remove postflight logic from `skill-lean-research/SKILL.md`
- [ ] Verify `/research.md` handles both skill returns correctly
- [ ] Test with a Lean task and a general task

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Strip to thin wrapper
- `.claude/skills/skill-lean-research/SKILL.md` - Strip to thin wrapper

**Verification**:
- `/research N` (general) completes with correct state updates
- `/research N` (lean) completes with correct state updates
- Both skills return brief summaries, command handles metadata

**Timing**: 2 hours

---

### Phase 2: Migrate /plan Command [NOT STARTED]

**Goal**: Move checkpoint operations from skill-planner to /plan command

**Current State**:
- `/plan.md` has GATE IN and delegates to skill
- Unclear if skill or command handles postflight
- Need to consolidate in command

**Tasks**:
- [ ] Read current `skill-planner/SKILL.md` to identify checkpoint code
- [ ] Update `/plan.md` GATE OUT to handle:
  - Read metadata from `specs/{N}_{SLUG}/.meta/plan-return-meta.json`
  - Update state.json to "planned"
  - Update TODO.md to [PLANNED]
  - Link plan artifact
- [ ] Simplify `skill-planner/SKILL.md` to thin wrapper
- [ ] Test /plan end-to-end

**Files to modify**:
- `.claude/commands/plan.md` - Add/consolidate GATE OUT operations
- `.claude/skills/skill-planner/SKILL.md` - Simplify to thin wrapper

**Verification**:
- `/plan N` reliably updates to [PLANNED]
- Plan artifact linked in state.json
- Git commit includes session_id

**Timing**: 2 hours

---

### Phase 3: Migrate /implement Command [NOT STARTED]

**Goal**: Move checkpoint operations to /implement for all three implementation skills

**Current State**:
- `/implement.md` has GATE IN and language routing
- Three skills: general, lean, latex
- Each may have its own postflight logic

**Tasks**:
- [ ] Audit all three implementation skills for checkpoint code
- [ ] Update `/implement.md` GATE OUT to handle:
  - Read metadata file (language-agnostic path)
  - Update state.json (status based on result)
  - Update TODO.md ([IMPLEMENTING] → [COMPLETED] or stay [IMPLEMENTING])
  - Link summary artifact
  - Handle completion_summary population
- [ ] Simplify `skill-implementer/SKILL.md`
- [ ] Simplify `skill-lean-implementation/SKILL.md`
- [ ] Simplify `skill-latex-implementation/SKILL.md`
- [ ] Test with each language type

**Files to modify**:
- `.claude/commands/implement.md` - Consolidate GATE OUT
- `.claude/skills/skill-implementer/SKILL.md` - Thin wrapper
- `.claude/skills/skill-lean-implementation/SKILL.md` - Thin wrapper
- `.claude/skills/skill-latex-implementation/SKILL.md` - Thin wrapper

**Verification**:
- `/implement N` (general) completes correctly
- `/implement N` (lean) completes correctly
- `/implement N` (latex) completes correctly
- All populate completion_summary in state.json

**Timing**: 3 hours

---

### Phase 4: Migrate /meta Command [NOT STARTED]

**Goal**: Move checkpoint operations from skill-meta to /meta command

**Current State**:
- `/meta.md` delegates to skill-meta
- skill-meta spawns meta-builder-agent
- Checkpoint handling unclear

**Tasks**:
- [ ] Read `skill-meta/SKILL.md` to understand current flow
- [ ] Update `/meta.md` to add full checkpoint pattern:
  - GATE IN: Generate session_id, validate mode
  - DELEGATE: Invoke skill-meta
  - GATE OUT: Read metadata, verify task creation
  - COMMIT: Git commit with session_id
- [ ] Simplify `skill-meta/SKILL.md` to thin wrapper
- [ ] Test /meta interactive, prompt, and --analyze modes

**Files to modify**:
- `.claude/commands/meta.md` - Add checkpoint pattern
- `.claude/skills/skill-meta/SKILL.md` - Thin wrapper

**Verification**:
- `/meta` interactive mode creates tasks with commits
- `/meta --analyze` completes with proper state
- Session IDs tracked consistently

**Timing**: 2 hours

---

### Phase 5: Migrate /convert Command [NOT STARTED]

**Goal**: Move checkpoint operations to /convert command

**Current State**:
- `/convert.md` delegates to skill-document-converter
- skill spawns document-converter-agent
- Checkpoint handling unclear

**Tasks**:
- [ ] Read current flow in `skill-document-converter/SKILL.md`
- [ ] Update `/convert.md` to add checkpoint pattern if needed
- [ ] Simplify skill to thin wrapper
- [ ] Test PDF→MD and MD→PDF conversions

**Files to modify**:
- `.claude/commands/convert.md` - Add checkpoint pattern
- `.claude/skills/skill-document-converter/SKILL.md` - Thin wrapper

**Verification**:
- Conversions complete with proper session tracking
- Output files created correctly

**Timing**: 1.5 hours

---

### Phase 6: Clean Up Obsolete Code [NOT STARTED]

**Goal**: Remove hook-based workarounds and marker file logic

**Tasks**:
- [ ] Remove `.postflight-pending` marker logic from all skills
- [ ] Remove loop guard logic from skills
- [ ] Evaluate SubagentStop hook necessity
- [ ] Remove/archive unused hook files if no longer needed
- [ ] Update settings.json if hook config exists

**Files to potentially modify/delete**:
- All skills: Remove marker file creation/reading
- `.claude/hooks/` - Evaluate and archive if unused
- `.claude/settings.json` - Remove hook config if present
- `.claude/context/core/patterns/postflight-control.md` - Archive or update

**Verification**:
- All commands work without hook workarounds
- No orphaned marker files after operations
- Clean skill implementations

**Timing**: 1.5 hours

---

### Phase 7: Update Documentation [NOT STARTED]

**Goal**: Comprehensive documentation of new architecture

**Tasks**:
- [ ] Update `.claude/CLAUDE.md`:
  - Revise "Checkpoint-Based Execution Model" section
  - Update "Skill Architecture" to describe thin wrapper pattern
  - Add section on command-level checkpoint rationale
  - Update "Skill-to-Agent Mapping" table
- [ ] Create/update `.claude/context/core/patterns/checkpoint-in-commands.md`:
  - Document the pattern with rationale
  - Provide templates for new commands
  - Reference research-004.md findings
- [ ] Update `.claude/context/core/patterns/thin-wrapper-skill.md`:
  - Simplify to show minimal skill pattern
  - Remove postflight references
- [ ] Update agent guidance documents if they reference skill checkpoints

**Files to modify/create**:
- `.claude/CLAUDE.md` - Major architecture sections
- `.claude/context/core/patterns/checkpoint-in-commands.md` - Pattern doc
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Simplify
- `.claude/context/core/orchestration/orchestration-core.md` - Update if needed

**Verification**:
- Documentation matches implementation
- New commands have clear guidance
- Research-004.md findings are referenced

**Timing**: 2 hours

---

### Phase 8: Validation and Testing [NOT STARTED]

**Goal**: Comprehensive end-to-end testing

**Tasks**:
- [ ] Create test task for each command type
- [ ] Test full workflow: research → plan → implement
- [ ] Verify state.json consistency throughout
- [ ] Verify TODO.md consistency
- [ ] Verify git commits include session_ids
- [ ] Verify artifact linking works
- [ ] Test error recovery scenarios

**Test Matrix**:

| Command | Language | Expected Outcome |
|---------|----------|------------------|
| /research | general | [RESEARCHED], report linked |
| /research | lean | [RESEARCHED], report linked |
| /plan | any | [PLANNED], plan linked |
| /implement | general | [COMPLETED], summary linked |
| /implement | lean | [COMPLETED], summary linked |
| /implement | latex | [COMPLETED], summary linked |
| /meta | interactive | Tasks created, committed |
| /convert | pdf→md | Output created |

**Verification**:
- All commands complete successfully
- State synchronization maintained
- No regressions

**Timing**: 2 hours

---

## Thin Wrapper Skill Template (Updated)

After migration, ALL delegating skills should follow this minimal pattern:

```markdown
---
name: skill-{name}
description: {description}
---

# skill-{name}

Thin wrapper that delegates to `{agent-name}` subagent.

**Note**: This skill does NOT handle checkpoints (preflight/postflight).
The calling command handles all state management operations.

## Inputs

- task_number: Task to operate on
- session_id: Session tracking ID (from command)
- {other inputs as needed}

## Execution

1. **Validate Inputs**
   - Verify task_number exists in state.json
   - Verify required parameters present

2. **Invoke Agent**
   Use Task tool:
   - subagent_type: {agent-name}
   - prompt: {delegation context}

3. **Return Brief Summary**
   Return the agent's text summary to calling command.
   Agent writes metadata to `specs/{N}_{SLUG}/.meta/{operation}-return-meta.json`
```

## Command Checkpoint Template

All workflow commands should follow this structure:

```markdown
### CHECKPOINT 1: GATE IN (Preflight)

1. Generate session_id
2. Read task from state.json
3. Validate status allows operation
4. Update state.json to "{operation}ing" status
5. Update TODO.md to [{OPERATION}ING]

### STAGE 2: DELEGATE

Invoke skill via Skill tool with:
- Session ID
- Task context
- Operation-specific parameters

### CHECKPOINT 2: GATE OUT (Postflight)

1. Read metadata file from `specs/{N}_{SLUG}/.meta/{op}-return-meta.json`
2. Validate required fields (status, summary, artifacts)
3. Verify artifacts exist on disk
4. Update state.json to "{operation}ed" status
5. Update TODO.md to [{OPERATION}ED]
6. Link artifacts to state.json
7. Update TODO.md with artifact links

### CHECKPOINT 3: COMMIT

```bash
git add -A
git commit -m "task {N}: {action}

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Commands become complex | Medium | Medium | Use templates, keep checkpoint code minimal |
| Breaking existing workflows | High | Medium | Test each command thoroughly before moving on |
| Lean/LaTeX skills have unique needs | Medium | Medium | Allow skill-specific metadata paths |
| /meta has complex modes | Medium | Low | Handle each mode in command GATE IN |
| Missing edge cases | Medium | Medium | Comprehensive Phase 8 testing |

## Rollback Plan

If checkpoint migration causes issues:
1. Revert command changes via git
2. Skills retain original checkpoint code (still works)
3. Re-enable SubagentStop hooks if needed
4. Investigate specific failure case

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Postflight execution rate | ~60% | 100% | Track status updates completing |
| Artifact linking rate | ~60% | 100% | Track artifacts in state.json |
| Git commit rate | ~60% | 100% | Track commits with session_id |
| Hook workaround usage | Yes | No | SubagentStop hooks removed |
| Skills with checkpoint code | ~8 | 0 | Count skills with postflight logic |
| Commands with checkpoints | 1 | 7 | Count commands with full pattern |

## Summary

**Root Cause**: GitHub Issue #17351 causes skill postflight to never execute.

**Solution**: Move ALL checkpoint operations to commands where they execute reliably.

**Scope**: 7 commands with skill delegation:
- /research (2 skills: general, lean)
- /plan (1 skill)
- /implement (3 skills: general, lean, latex)
- /meta (1 skill)
- /convert (1 skill)

**Approach**: Migrate incrementally, test each command before proceeding.

**Effort**: 16 hours total
- Phase 1: 2 hours (complete /research migration)
- Phase 2: 2 hours (migrate /plan)
- Phase 3: 3 hours (migrate /implement - 3 skills)
- Phase 4: 2 hours (migrate /meta)
- Phase 5: 1.5 hours (migrate /convert)
- Phase 6: 1.5 hours (cleanup obsolete code)
- Phase 7: 2 hours (documentation)
- Phase 8: 2 hours (validation and testing)

**Industry Validation**: 9 architectural patterns confirm this is the correct approach.

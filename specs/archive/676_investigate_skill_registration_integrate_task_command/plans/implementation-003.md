# Implementation Plan: Task #676 (v3)

- **Task**: 676 - Investigate skill registration and integrate /task command with checkpoint pattern
- **Status**: [NOT STARTED]
- **Effort**: 12 hours (revised down from 16h)
- **Priority**: High
- **Dependencies**: Coordinate with Tasks 675, 677
- **Research Inputs**:
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-001.md
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-002.md
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-003.md (NEW - targeted findings)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses the root cause of unreliable preflight/postflight operations identified in research-003.md: **GitHub Issue #17351** causes subagent returns to go to the main session instead of the invoking skill, meaning postflight code in skills never executes.

The solution is **Option C**: Move checkpoint operations from skills to commands, where they execute in a stable context unaffected by Issue #17351.

### Key Changes from v2

| Aspect | v2 | v3 |
|--------|----|----|
| .opencode archival | Phase 3 (archive it) | REMOVED (preserve as-is per user) |
| Root cause | Simulation code bypassing skills | Issue #17351 - subagent returns to wrong context |
| Solution | Remove simulation, wire real skills | Move checkpoints to commands |
| Hooks | Phase 5 (guard rails) | NOT REQUIRED (commands handle checkpoints) |
| Effort | 16 hours | 12 hours |

### User Requirements Incorporated

1. ✅ Do NOT archive .opencode/ - preserved as-is
2. ✅ Skills ARE being invoked - confirmed, not simulation issue
3. ✅ Preflight/postflight unreliable - root cause is Issue #17351
4. ✅ No hooks required - Option C eliminates need for SubagentStop hooks

## Goals & Non-Goals

**Goals**:
- Move checkpoint operations (preflight/postflight) from skills to commands
- Simplify skills to thin wrappers that just invoke agents
- Make preflight/postflight execute reliably in command context
- Test pattern with /research first before wider rollout
- Update documentation to reflect new architecture

**Non-Goals**:
- Archiving .opencode/ (user wants to preserve it)
- Adding hook-based guard rails (no longer needed)
- Fixing GitHub Issue #17351 (Claude Code internal issue)
- Redesigning agent architecture (agents work correctly)

## Why This Works

1. **Commands execute in main context**: The main conversation context is stable - no subagent return issues
2. **Skills stay simple**: Just orchestrate agent execution, no checkpoint logic
3. **Agents stay unchanged**: Continue to write metadata files as they do now
4. **Checkpoints are guaranteed**: Command context doesn't have Issue #17351
5. **No hooks required**: Natural execution flow without SubagentStop workarounds

## Current vs Target Architecture

### Current (Broken)

```
User → /research → skill-researcher
                      |
                      +-- Stage 1: Validate       [RUNS]
                      +-- Stage 2: Preflight      [RUNS]
                      +-- Stage 3: Create marker  [RUNS]
                      +-- Stage 4: Prepare        [RUNS]
                      +-- Stage 5: Invoke Agent   [RUNS]
                            |
                            +--→ general-research-agent [RUNS]
                            |         |
                            |         v
                            |    Returns to MAIN SESSION (Issue #17351)
                            |
                      +-- Stage 6: Parse Return   [NEVER RUNS]
                      +-- Stage 7: Update Status  [NEVER RUNS]
                      +-- Stage 8: Link Artifacts [NEVER RUNS]
                      +-- Stage 9: Git Commit     [NEVER RUNS]
                      +-- Stage 10: Cleanup       [NEVER RUNS]
                      +-- Stage 11: Return        [NEVER RUNS]
```

### Target (Working)

```
User → /research.md (command handles checkpoints)
           |
           +-- GATE IN: Validate, update to [RESEARCHING]     [RUNS]
           +-- DELEGATE: Invoke skill-researcher              [RUNS]
                   |
                   +--→ skill-researcher (thin wrapper)       [RUNS]
                           |
                           +--→ general-research-agent        [RUNS]
                                    |
                                    v
                              Returns to MAIN SESSION (OK - command continues)
           |
           +-- GATE OUT: Read metadata, update to [RESEARCHED] [RUNS]
           +-- COMMIT: Git commit with session_id              [RUNS]
```

## Implementation Phases

### Phase 1: Migrate /research Command [NOT STARTED]

**Goal**: Move checkpoint operations from skill-researcher to /research command as proof of concept

**Tasks**:
- [ ] Read current `.claude/commands/research.md` and `.claude/skills/skill-researcher/SKILL.md`
- [ ] Update `/research.md` to handle preflight operations:
  ```markdown
  ### CHECKPOINT 1: GATE IN
  1. Generate session_id
  2. Read task from state.json
  3. Validate status allows research
  4. Update state.json to status: "researching"
  5. Update TODO.md to [RESEARCHING]
  ```
- [ ] Simplify `skill-researcher/SKILL.md`:
  - Remove Stages 2, 3, 6, 7, 8, 9, 10 (checkpoint operations)
  - Keep: Validate inputs, invoke agent, return brief summary
- [ ] Update `/research.md` to handle postflight operations:
  ```markdown
  ### CHECKPOINT 2: GATE OUT
  After skill returns:
  1. Read specs/{N}_{SLUG}/.meta/research-return-meta.json
  2. Validate metadata schema
  3. Verify artifacts exist
  4. Update state.json to status: "researched"
  5. Update TODO.md to [RESEARCHED]
  6. Link artifacts

  ### CHECKPOINT 3: COMMIT
  Git commit with session_id
  ```
- [ ] Test /research end-to-end with a test task

**Timing**: 4 hours

**Files to modify**:
- `.claude/commands/research.md` - Add checkpoint operations
- `.claude/skills/skill-researcher/SKILL.md` - Simplify to thin wrapper

**Verification**:
- `/research N` reliably updates status to [RESEARCHING] then [RESEARCHED]
- Artifacts are linked in state.json and TODO.md
- Git commit includes session_id
- No reliance on SubagentStop hooks

---

### Phase 2: Migrate /plan Command [NOT STARTED]

**Goal**: Apply same pattern to /plan command

**Tasks**:
- [ ] Update `/plan.md` to handle preflight operations
- [ ] Simplify `skill-planner/SKILL.md` to thin wrapper
- [ ] Update `/plan.md` to handle postflight operations
- [ ] Test /plan end-to-end

**Timing**: 3 hours

**Files to modify**:
- `.claude/commands/plan.md` - Add checkpoint operations
- `.claude/skills/skill-planner/SKILL.md` - Simplify to thin wrapper

**Verification**:
- `/plan N` reliably updates status to [PLANNING] then [PLANNED]
- Plan artifacts linked correctly
- Git commit with session_id

---

### Phase 3: Migrate /implement Command [NOT STARTED]

**Goal**: Apply same pattern to /implement command (most complex)

**Tasks**:
- [ ] Update `/implement.md` to handle preflight operations
- [ ] Simplify `skill-implementer/SKILL.md` to thin wrapper
- [ ] Update `/implement.md` to handle postflight operations
- [ ] Handle phase-by-phase commits within command
- [ ] Test /implement end-to-end

**Timing**: 3 hours

**Files to modify**:
- `.claude/commands/implement.md` - Add checkpoint operations
- `.claude/skills/skill-implementer/SKILL.md` - Simplify to thin wrapper

**Verification**:
- `/implement N` reliably updates status through phases
- Phase commits work correctly
- Final status is [COMPLETED]
- Summary artifacts linked

---

### Phase 4: Clean Up Obsolete Code [NOT STARTED]

**Goal**: Remove hook-based workarounds that are no longer needed

**Tasks**:
- [ ] Evaluate if SubagentStop hooks are still needed (likely not)
- [ ] Remove or disable `.claude/hooks/subagent-postflight.sh` if unused
- [ ] Remove marker file logic (`.postflight-pending`) from skills
- [ ] Remove loop guard logic from skills
- [ ] Update documentation to remove references to old pattern

**Timing**: 1 hour

**Files to potentially modify/delete**:
- `.claude/hooks/subagent-postflight.sh` - May be removable
- `.claude/settings.json` - Remove SubagentStop hook config if present
- `.claude/context/core/patterns/postflight-control.md` - Update or archive

**Verification**:
- All commands work without hook workarounds
- No orphaned marker files
- Documentation is accurate

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Document the new architecture where commands handle checkpoints

**Tasks**:
- [ ] Update `.claude/CLAUDE.md`:
  - Change "Checkpoint-Based Execution Model" to show commands handling checkpoints
  - Update "Skill Architecture" to describe thin wrapper pattern
  - Add note about GitHub Issue #17351 and why checkpoints are in commands
- [ ] Update or create `.claude/context/core/patterns/checkpoint-in-commands.md`:
  - Document the pattern
  - Explain why this is more reliable than skill-based checkpoints
  - Provide template for new commands

**Timing**: 1 hour

**Files to modify/create**:
- `.claude/CLAUDE.md` - Update architecture sections
- `.claude/context/core/patterns/checkpoint-in-commands.md` - New pattern doc

**Verification**:
- Documentation matches implementation
- Clear guidance for future commands
- Issue #17351 context documented

---

## Simplified Skill Pattern Template

After migration, skills should follow this simple pattern:

```markdown
---
name: skill-{name}
description: {description}
---

# skill-{name}

## Purpose
{Brief description of what this skill does}

## Inputs
- task_number: Task to operate on
- session_id: Session tracking ID
- {other inputs}

## Execution

1. **Validate Inputs**
   - Verify task_number is valid
   - Verify required parameters present

2. **Invoke Agent**
   Use Task tool with:
   - subagent_type: {agent-name}
   - prompt: {context for agent}

3. **Return Brief Summary**
   Return the agent's brief summary to calling command.

## Note
This skill does NOT handle preflight/postflight operations.
The calling command handles all checkpoint operations.
```

## Testing & Validation

- [ ] /research reliably updates status and links artifacts
- [ ] /plan reliably updates status and links artifacts
- [ ] /implement reliably updates status through all phases
- [ ] No commands require SubagentStop hook workarounds
- [ ] Git commits include session_id consistently
- [ ] state.json and TODO.md stay synchronized
- [ ] Documentation accurately reflects implementation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Commands become too complex | Medium | Medium | Keep checkpoint operations simple and templated |
| Skills may still be invoked directly | Low | Low | Skills still work, just don't do checkpoints |
| Migration breaks existing workflows | Medium | Low | Test each command thoroughly before moving to next |
| Unexpected interactions with other commands | Medium | Low | /task, /revise, etc. may need similar updates |

## Rollback Plan

If checkpoints in commands don't work:
1. Revert command changes (git revert)
2. Skills still have original checkpoint code
3. Re-enable SubagentStop hooks
4. Investigate why command context also fails

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Postflight execution rate | ~60% | 100% | Track status updates completing |
| Artifact linking rate | ~60% | 100% | Track artifacts appearing in state.json |
| Git commit rate | ~60% | 100% | Track commits with session_id |
| Hook workaround usage | Yes | No | Check if SubagentStop still needed |

## Summary

**Root Cause**: GitHub Issue #17351 causes subagent returns to go to main session, not invoking skill, so postflight code in skills never executes.

**Solution**: Move checkpoint operations to commands where they execute in stable main context.

**Approach**: Migrate /research first as proof of concept, then /plan and /implement, then clean up obsolete hook code.

**Effort**: 12 hours total
- Phase 1: 4 hours (migrate /research)
- Phase 2: 3 hours (migrate /plan)
- Phase 3: 3 hours (migrate /implement)
- Phase 4: 1 hour (clean up)
- Phase 5: 1 hour (documentation)

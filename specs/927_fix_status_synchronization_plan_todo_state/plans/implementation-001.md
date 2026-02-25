# Implementation Plan: Task #927

- **Task**: 927 - Fix status synchronization to ensure plan file status, TODO.md status, and state.json status all update together
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/927_fix_status_synchronization_plan_todo_state/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task fixes the status synchronization gap where plan file status (line 4 metadata block) is not consistently updated when task status changes, even though state.json and TODO.md are correctly synchronized. The solution centralizes plan file status updates into a reusable helper script, integrates it into postflight scripts, updates documentation to reflect three-file synchronization, and adds validation to detect/fix mismatches.

### Research Integration

- Research confirmed plan file update code EXISTS in skill files but is optional markdown instructions, not enforced
- Postflight scripts (`postflight-implement.sh`, etc.) only update state.json, not plan files
- `skill-status-sync` documents only two-file synchronization
- Task 926 demonstrates the issue: state.json and TODO.md show `[COMPLETED]`, plan file shows `[NOT STARTED]`

## Goals & Non-Goals

**Goals**:
- Create centralized `update-plan-status.sh` helper script
- Integrate helper into postflight scripts for automatic plan file updates
- Update `skill-status-sync` to document three-file synchronization
- Update implementation skills to use the centralized helper
- Add validation gate to detect and auto-fix status mismatches
- Ensure all future status changes propagate to plan files

**Non-Goals**:
- Retroactively fixing existing plan files with stale status (manual cleanup)
- Adding pre-commit hooks (avoids complexity per research recommendation)
- Changing the plan file format itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| sed pattern mismatch on edge cases | Medium | Low | Use exact pattern from plan-format.md, test with multiple plan files |
| Path construction fails if project_name unavailable | Medium | Medium | Add fallback glob pattern `specs/${N}_*/plans/implementation-*.md` |
| Breaking existing skill workflows | High | Low | Test each skill type after changes |
| Concurrent updates cause race conditions | Low | Low | Plan files are human-readable; conflicts are easily resolvable |

## Implementation Phases

### Phase 1: Create Helper Script [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create centralized `update-plan-status.sh` script for reusable plan file status updates

**Tasks:**
- [ ] Create `.claude/scripts/update-plan-status.sh` with parameters: TASK_NUMBER, PROJECT_NAME, NEW_STATUS
- [ ] Implement plan file discovery using glob pattern `specs/${N}_${PROJECT}/plans/implementation-*.md`
- [ ] Implement fallback discovery using `specs/${N}_*/plans/implementation-*.md` if PROJECT_NAME is empty
- [ ] Implement sed-based status update using exact pattern from plan-format.md
- [ ] Add validation that file exists before attempting update
- [ ] Return updated file path on success, empty string on no-op
- [ ] Make script executable

**Verification:**
- Script exists and is executable
- Script correctly updates plan file status when given valid inputs
- Script gracefully handles missing files

**Timing:** 30 minutes

---

### Phase 2: Integrate Helper into Postflight Scripts [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Ensure postflight scripts automatically update plan file status after updating state.json

**Tasks:**
- [ ] Update `postflight-implement.sh` to call `update-plan-status.sh` after state.json update
- [ ] Extract project_name from state.json using jq
- [ ] Map state.json status values to plan file markers (completed -> COMPLETED, partial -> PARTIAL, etc.)
- [ ] Log plan file update result
- [ ] Update `postflight-plan.sh` similarly (if it handles status changes)
- [ ] Verify postflight-research.sh does not need changes (research has no plan file)

**Verification:**
- Running `/implement` to completion updates plan file status
- Partial completions update plan file to [PARTIAL] or [IN PROGRESS]

**Timing:** 45 minutes

---

### Phase 3: Update skill-status-sync Documentation [NOT STARTED]

- **Dependencies:** None
- **Goal:** Document three-file synchronization (state.json, TODO.md, plan file) in skill-status-sync

**Tasks:**
- [ ] Read current `skill-status-sync/SKILL.md` content
- [ ] Add plan file as third synchronization target in documentation
- [ ] Document the `update-plan-status.sh` helper script usage
- [ ] Update "Atomic Synchronization" section to list all three files
- [ ] Add examples showing three-file status update pattern
- [ ] Update any synchronization flow diagrams if present

**Verification:**
- `skill-status-sync/SKILL.md` documents three-file synchronization
- Helper script usage is documented

**Timing:** 30 minutes

---

### Phase 4: Update Implementation Skills to Use Helper [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Replace inline sed commands in implementation skills with calls to centralized helper

**Tasks:**
- [ ] Update `skill-implementer/SKILL.md` to use `update-plan-status.sh` instead of inline sed
- [ ] Update `skill-lean-implementation/SKILL.md` similarly
- [ ] Update `skill-typst-implementation/SKILL.md` similarly
- [ ] Update `skill-latex-implementation/SKILL.md` similarly
- [ ] Verify no other skills have inline plan file update code
- [ ] Remove redundant inline sed commands from each skill

**Verification:**
- All implementation skills reference the centralized helper
- No duplicate inline sed commands remain

**Timing:** 45 minutes

---

### Phase 5: Add Validation Gate [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Add validation to detect plan file status mismatches and auto-fix them

**Tasks:**
- [ ] Create validation function in `update-plan-status.sh` or separate script
- [ ] Compare plan file status with state.json status for given task
- [ ] If mismatch detected: auto-fix and log warning
- [ ] Add validation call to postflight scripts after status updates
- [ ] Consider adding to `/todo` or `/errors` command for periodic checks
- [ ] Document validation behavior

**Verification:**
- Validation detects mismatches between plan file and state.json
- Mismatches are auto-fixed with warning logged

**Timing:** 30 minutes

---

### Phase 6: Verification and Testing [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5
- **Goal:** End-to-end verification that three-file synchronization works correctly

**Tasks:**
- [ ] Test helper script with various inputs (valid, missing file, empty project name)
- [ ] Simulate `/implement` workflow and verify plan file updates
- [ ] Verify existing task (e.g., task 926) can be manually fixed using helper
- [ ] Test status transitions: NOT STARTED -> IMPLEMENTING -> COMPLETED
- [ ] Test partial completion status update
- [ ] Verify no regressions in existing skill workflows
- [ ] Document any edge cases discovered

**Verification:**
- All tests pass
- Task 926 (or similar) can be manually corrected
- New implementations correctly update all three files

**Timing:** 30 minutes

## Testing & Validation

- [ ] `update-plan-status.sh` correctly updates plan file status
- [ ] Postflight scripts call helper and log results
- [ ] `skill-status-sync` documents three-file synchronization
- [ ] Implementation skills reference centralized helper
- [ ] Validation gate detects and fixes mismatches
- [ ] Manual test: complete a task and verify all three files show same status

## Artifacts & Outputs

- `.claude/scripts/update-plan-status.sh` - Centralized helper script
- `.claude/skills/skill-status-sync/SKILL.md` - Updated documentation
- `.claude/skills/skill-implementer/SKILL.md` - Updated to use helper
- `.claude/skills/skill-lean-implementation/SKILL.md` - Updated to use helper
- `.claude/skills/skill-typst-implementation/SKILL.md` - Updated to use helper
- `.claude/skills/skill-latex-implementation/SKILL.md` - Updated to use helper
- `.claude/scripts/postflight-implement.sh` - Updated with helper call
- `specs/927_fix_status_synchronization_plan_todo_state/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the changes cause issues:
1. Revert postflight script changes first (most critical path)
2. Skills can fall back to inline sed commands (kept as comments initially)
3. Helper script can be disabled by renaming/removing
4. Documentation changes are purely informational and can be reverted independently

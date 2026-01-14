# Implementation Plan: Task #397

**Task**: Enhance /revise to update description when no plan exists
**Version**: 001
**Created**: 2026-01-11
**Language**: meta

## Overview

Modify the `/revise` command to handle tasks without plans (status `not_started` or `researched`) by updating the task description instead of erroring. This involves restructuring the validation section to route to either plan revision (existing behavior) or description update (new behavior) based on task status.

## Phases

### Phase 1: Modify /revise command validation and routing

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Restructure section 2 "Validate Status" to route based on status
2. Add new section "2a. Description Update" for tasks without plans
3. Update output section to show description update results

**Files to modify**:
- `.claude/commands/revise.md` - Main command definition

**Steps**:

1. **Replace section 2 "Validate Status"** with "Validate Status and Route":
   ```markdown
   ### 2. Validate Status and Route

   Check task status to determine behavior:

   **If status in [planned, implementing, partial, blocked]:**
   → Continue to section 3 (Load Current Context) for plan revision

   **If status in [not_started, researched]:**
   → Jump to section 2a (Description Update)

   **If status is completed:**
   → Error "Task completed, no revision needed"

   **If status is abandoned:**
   → Error "Task abandoned, use /task --recover first"
   ```

2. **Add new section 2a** after section 2:
   ```markdown
   ### 2a. Description Update (for tasks without plans)

   When a task has no plan to revise, update the task description instead.

   **Read current description:**
   ```bash
   old_description=$(echo "$task_data" | jq -r '.description // ""')
   ```

   **Construct new description:**
   - If revision_reason is provided: Use it as the new description
   - If no revision_reason: Error "No revision reason provided. Usage: /revise N \"new description\""

   **Update state.json:**
   ```bash
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg desc "$new_description" \
     '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
       description: $desc,
       last_updated: $ts
     }' .claude/specs/state.json > /tmp/state.json && \
     mv /tmp/state.json .claude/specs/state.json
   ```

   **Update TODO.md:**
   Use Edit tool to replace the existing description:
   ```
   old_string: "**Description**: {old_description}"
   new_string: "**Description**: {new_description}"
   ```

   **Git commit:**
   ```bash
   git add .claude/specs/
   git commit -m "task {N}: revise description"
   ```

   **Output:**
   ```
   Description updated for Task #{N}

   Previous: {old_description}
   New: {new_description}

   Status: [{current_status}]
   ```

   **STOP** - Do not continue to plan revision sections.
   ```

3. **Update section 8 "Output"** to note it only applies to plan revisions:
   Add at the start: "This output applies to plan revisions (when task has existing plan):"

**Verification**:
- Read the modified `.claude/commands/revise.md` and verify the logic flow
- Check that all status cases are handled (not_started, researched, planned, implementing, partial, blocked, completed, abandoned)

---

### Phase 2: Test description update functionality

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Test /revise on a not_started task
2. Test /revise on a researched task
3. Verify state.json and TODO.md are both updated
4. Verify git commit is created

**Steps**:

1. **Find a test task with not_started status**:
   ```bash
   jq -r '.active_projects[] | select(.status == "not_started") | .project_number' .claude/specs/state.json | head -1
   ```

2. **Run /revise with description update**:
   ```
   /revise {N} "Updated description after testing revise enhancement"
   ```

3. **Verify state.json updated**:
   ```bash
   jq --arg num "{N}" '.active_projects[] | select(.project_number == ($num | tonumber)) | .description' .claude/specs/state.json
   ```

4. **Verify TODO.md updated**:
   ```bash
   grep -A 20 "^### {N}\." .claude/specs/TODO.md | grep "Description"
   ```

5. **Verify git commit created**:
   ```bash
   git log -1 --oneline
   ```

6. **Test edge case: /revise without revision reason**:
   Verify it errors appropriately.

**Verification**:
- All tests pass
- Both files updated atomically
- Commit message follows convention

---

## Dependencies

- None - this is a self-contained enhancement to an existing command

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Edit tool fails to match description | Med | Low | Use unique context around description line |
| Multi-line descriptions | Med | Med | Handle multi-paragraph descriptions carefully in Edit |
| State sync failure | High | Low | Follow two-phase commit pattern |

## Success Criteria

- [x] /revise on not_started task updates description (not error)
- [x] /revise on researched task updates description (not error)
- [x] Both state.json and TODO.md are updated atomically
- [x] Git commit created with correct message format
- [x] Original plan revision behavior unchanged for planned/implementing/partial/blocked tasks
- [x] Appropriate errors for completed/abandoned tasks

## Rollback Plan

If implementation fails:
1. `git checkout .claude/commands/revise.md` to restore original
2. Verify original behavior still works with `/revise` on a planned task

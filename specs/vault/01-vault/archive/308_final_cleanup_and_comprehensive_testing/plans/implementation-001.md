# Implementation Plan: Task #308

**Task**: Final cleanup and comprehensive testing (5/5)
**Version**: 001
**Created**: 2026-01-10
**Language**: general

## Overview

The research revealed that the original task scope (file cleanup) is not needed - the codebase is well-organized. However, a critical issue was discovered: state.json uses JSON Lines format instead of the expected JSON structure with `active_projects` array, blocking all jq-based workflow commands.

This plan focuses on fixing the state.json format and then testing all commands comprehensively.

## Phases

### Phase 1: Convert state.json to Proper JSON Format

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Convert JSONL format to proper JSON with wrapper structure
2. Add required `next_project_number` field matching TODO.md frontmatter
3. Wrap all task objects in `active_projects` array

**Files to modify**:
- `specs/state.json` - Convert from JSONL to proper JSON structure

**Steps**:
1. Read current state.json and parse each JSON object
2. Get `next_project_number` value from TODO.md frontmatter (currently 352)
3. Create new JSON structure:
   ```json
   {
     "_schema_version": "1.0.0",
     "_last_updated": "{current_timestamp}",
     "next_project_number": 352,
     "active_projects": [
       {task_objects...}
     ]
   }
   ```
4. Write the new structure to state.json
5. Validate with jq that `.next_project_number` and `.active_projects[]` work

**Verification**:
- `jq -r '.next_project_number' specs/state.json` returns 352
- `jq -r '.active_projects | length' specs/state.json` returns count matching task count
- `jq -r '.active_projects[] | select(.project_number == 308)' specs/state.json` returns task data

---

### Phase 2: Test Core Commands

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify jq-based task lookup works
2. Test status sync functionality
3. Test each command's basic operation

**Files to modify**:
- None (testing only)

**Steps**:
1. Test task lookup:
   ```bash
   jq -r --arg num "308" '.active_projects[] | select(.project_number == ($num | tonumber))' specs/state.json
   ```
2. Test /meta --analyze (should work)
3. Test /review (should work for basic review)
4. Verify skill-status-sync patterns work with new format

**Verification**:
- All jq lookup patterns from skill-status-sync work correctly
- Commands execute without jq errors

---

### Phase 3: Verify State Consistency

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify task counts match between state.json and TODO.md
2. Verify next_project_number is consistent
3. Document any remaining discrepancies

**Files to modify**:
- May need minor fixes to state.json or TODO.md if discrepancies found

**Steps**:
1. Count tasks in state.json: `jq '.active_projects | length' specs/state.json`
2. Count task entries in TODO.md
3. Compare next_project_number in both files
4. Document results

**Verification**:
- Task counts match or discrepancies documented
- next_project_number matches in both files

---

### Phase 4: Git Commit and Documentation

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Commit the state.json format fix
2. Update task status to COMPLETED
3. Create implementation summary

**Files to modify**:
- `specs/308_final_cleanup_and_comprehensive_testing/summaries/implementation-summary-20260110.md`
- `specs/state.json` - Status update
- `specs/TODO.md` - Status update

**Steps**:
1. Create implementation summary
2. Update task status to COMPLETED in both files
3. Git commit with appropriate message

**Verification**:
- Git commit successful
- Task shows as [COMPLETED] in TODO.md

---

## Dependencies

- None (this task unblocks other commands)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Data loss during format conversion | High | Low | Backup state.json before conversion; verify all tasks preserved |
| jq command syntax errors | Medium | Low | Test each pattern before committing |
| Inconsistency between files | Medium | Medium | Run consistency checks in Phase 3 |

## Success Criteria

- [ ] state.json has proper JSON structure with `active_projects` array
- [ ] `jq '.next_project_number'` returns 352
- [ ] `jq '.active_projects[]'` iterates over all tasks
- [ ] Task lookup by number works correctly
- [ ] All commands can read task data via jq
- [ ] Task counts consistent between state.json and TODO.md

## Rollback Plan

1. If format conversion fails, restore from git:
   ```bash
   git checkout HEAD -- specs/state.json
   ```
2. If partial corruption, use archive/state.json structure as template
3. As last resort, parse TODO.md to regenerate state.json

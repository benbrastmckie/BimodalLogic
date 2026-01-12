# Implementation Plan: Task #402

**Task**: Rename --divide flag to --expand
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Rename the `--divide` flag to `--expand` across all active documentation and command files in the `.claude/` system. This change aligns the flag name with the new `[EXPANDED]` status marker introduced in task 401. The `/research --divide` feature (for topic subdivision) will remain unchanged as it serves a different purpose.

## Phases

### Phase 1: Update Core Command Files

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update the main task command definition
2. Update the root CLAUDE.md quick reference

**Files to modify**:
- `.claude/commands/task.md` - Main command definition (3 changes)
- `.claude/CLAUDE.md` - Quick reference example (1 change)

**Steps**:
1. Edit `.claude/commands/task.md`:
   - Line 4: Change `--divide N` to `--expand N` in argument-hint
   - Line 32: Change `--divide N [prompt]` to `--expand N [prompt]`
   - Line 166: Change `## Divide Mode (--divide)` to `## Expand Mode (--expand)`
2. Edit `.claude/CLAUDE.md`:
   - Line 70: Change `/task --divide 326` to `/task --expand 326`

**Verification**:
- Run `grep -n "\-\-divide" .claude/commands/task.md` - should return no results
- Run `grep -n "\-\-divide" .claude/CLAUDE.md` - should return no results

---

### Phase 2: Update Standards Documentation

**Estimated effort**: 30 minutes
**Status**: [IN PROGRESS]

**Objectives**:
1. Update task management documentation
2. Update git integration documentation
3. Update status markers documentation
4. Update general documentation

**Files to modify**:
- `.claude/context/core/standards/task-management.md` - 4 changes
- `.claude/context/core/standards/git-integration.md` - 1 change
- `.claude/context/core/standards/status-markers.md` - 1 change
- `.claude/context/core/standards/documentation.md` - 1 change

**Steps**:
1. Edit `.claude/context/core/standards/task-management.md`:
   - Line 123: Change `--divide` to `--expand`
   - Line 153: Change `### Task Division (--divide)` to `### Task Expansion (--expand)`
   - Line 157: Change `/task --divide 326` to `/task --expand 326`
   - Line 158: Change `/task --divide 326 "Focus..."` to `/task --expand 326 "Focus..."`
2. Edit `.claude/context/core/standards/git-integration.md`:
   - Line 14: Change `Task division (\`/task --divide\`)` to `Task expansion (\`/task --expand\`)`
3. Edit `.claude/context/core/standards/status-markers.md`:
   - Line 258: Change `(/task --divide)` to `(/task --expand)`
4. Edit `.claude/context/core/standards/documentation.md`:
   - Line 122: Change `with --divide flag` to `with --expand flag`

**Verification**:
- Run `grep -rn "\-\-divide" .claude/context/core/standards/` - should return no results

---

### Phase 3: Update Orchestration Files

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update routing logic for task command
2. Update validation logic
3. Preserve /research --divide (different feature)

**Files to modify**:
- `.claude/context/core/orchestration/routing.md` - 3 changes (NOT line 215)
- `.claude/context/core/orchestration/validation.md` - 1 change

**Steps**:
1. Edit `.claude/context/core/orchestration/routing.md`:
   - Line 219: Change `| \`/task\` | \`--divide\` |` to `| \`/task\` | \`--expand\` |`
   - Line 233: Change `elif [[ "$ARGUMENTS" =~ --divide ]]; then` to `elif [[ "$ARGUMENTS" =~ --expand ]]; then`
   - Line 235: Change `args="${ARGUMENTS#*--divide }"` to `args="${ARGUMENTS#*--expand }"`
   - **DO NOT** change line 215 (`/research --divide`)
2. Edit `.claude/context/core/orchestration/validation.md`:
   - Line 161: Change `[[ "$ARGUMENTS" =~ --divide ]]` to `[[ "$ARGUMENTS" =~ --expand ]]`

**Verification**:
- Run `grep -n "\-\-divide" .claude/context/core/orchestration/routing.md` - should return ONLY line 215 (research)
- Run `grep -n "\-\-divide" .claude/context/core/orchestration/validation.md` - should return no results

---

### Phase 4: Final Verification

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify all task-related --divide references are updated
2. Confirm /research --divide is preserved
3. Confirm archive files are unchanged

**Files to check**:
- All files updated in phases 1-3
- `.claude/context/project/processes/research-workflow.md` (should retain --divide)

**Steps**:
1. Run comprehensive grep: `grep -rn "\-\-divide" .claude/` excluding specs/archive/
2. Verify remaining --divide references are all research-related
3. Verify research-workflow.md still contains `/research --divide`
4. Spot-check one archive file to confirm unchanged

**Verification**:
- `grep -rn "\-\-divide" .claude/ --exclude-dir=specs/archive | grep -v research` - should return nothing
- `grep -c "\-\-divide" .claude/context/project/processes/research-workflow.md` - should return 3+

---

## Dependencies

- Task 401 (Add [EXPANDED] status) - Should be completed first for consistency

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidentally modify /research --divide | Medium | Low | Explicit exclusion in steps, verification checks |
| Miss a --divide reference | Low | Low | Comprehensive grep verification in Phase 4 |
| Break existing documentation links | Low | Very Low | No links use flag names directly |

## Success Criteria

- [ ] All 8 files updated with correct changes
- [ ] /research --divide references preserved (3+ occurrences)
- [ ] No --divide references remain for /task command
- [ ] Archive files unchanged
- [ ] grep verification passes in Phase 4

## Rollback Plan

If issues are discovered after implementation:
1. Use `git diff HEAD~1` to review changes
2. Use `git checkout HEAD~1 -- <file>` to restore individual files
3. Or `git revert HEAD` to revert entire commit

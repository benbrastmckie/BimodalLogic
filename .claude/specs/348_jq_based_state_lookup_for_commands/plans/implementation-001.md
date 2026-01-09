# Implementation Plan: Task #348

**Task**: Implement jq-based state lookup for agent commands
**Version**: 001
**Created**: 2026-01-09
**Language**: meta

## Overview

This task standardizes how command files and skills interact with `state.json` and `TODO.md`. Instead of reading entire files (which can be extremely large), we use:
- **jq**: For efficient JSON queries and updates on `state.json`
- **grep**: For locating task sections in `TODO.md`
- **skill-status-sync**: As the single point of truth for synchronized updates

The existing `state-lookup.md` already documents optimal jq patterns. This implementation will:
1. Create a reusable lookup utility section in skill-status-sync
2. Update each command file to reference the standardized patterns
3. Ensure all state changes flow through skill-status-sync

## Phases

### Phase 1: Enhance skill-status-sync with Complete jq/grep Integration

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add comprehensive jq patterns for all CRUD operations on state.json
2. Add grep patterns for TODO.md task section lookup
3. Add jq-based update patterns (not just reads)
4. Document the lookup/update API that command files will use

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Complete rewrite of data access patterns

**Steps**:
1. Add "Lookup Patterns" section with jq read patterns:
   - Single task lookup by number
   - Field extraction
   - Status validation
   - next_project_number retrieval
2. Add "TODO.md Patterns" section with grep patterns:
   - Task section location (line number)
   - Frontmatter field extraction
   - Priority section location
3. Add "Update Patterns" section with jq write patterns:
   - Status update (atomic)
   - Artifact addition
   - Task creation (with next_project_number increment)
   - Task archival
4. Add "Frontmatter Sync" section documenting the critical next_project_number sync

**Verification**:
- All jq patterns are executable and tested in shell
- Patterns match those in state-lookup.md (consistency)
- Each operation type has read AND write patterns

---

### Phase 2: Update /research Command

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace "Read .claude/specs/state.json" with explicit jq lookup
2. Reference skill-status-sync for status updates
3. Add grep-based TODO.md lookup for section editing

**Files to modify**:
- `.claude/commands/research.md` - Update Parse and Validate section

**Steps**:
1. Replace step 1 with jq lookup pattern:
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     .claude/specs/state.json)
   ```
2. Update step 3 to explicitly invoke skill-status-sync for status change
3. Update step 6 to explicitly invoke skill-status-sync for final status

**Verification**:
- Command file shows explicit jq patterns
- Status updates reference skill-status-sync
- No "Read entire file" instructions remain

---

### Phase 3: Update /plan Command

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace generic "Read state.json" with explicit jq lookup
2. Reference skill-status-sync for status updates
3. Add grep-based context loading pattern

**Files to modify**:
- `.claude/commands/plan.md` - Update Parse/Validate and Status sections

**Steps**:
1. Add explicit jq lookup in step 1
2. Update step 4 (Update Status to PLANNING) to invoke skill-status-sync
3. Update step 6 (Update Status to PLANNED) to invoke skill-status-sync
4. Add artifact linking through skill-status-sync

**Verification**:
- Command file shows explicit jq patterns
- Both status transitions invoke skill-status-sync
- Artifact linking uses standardized pattern

---

### Phase 4: Update /implement Command

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace generic state.json read with explicit jq lookup
2. Reference skill-status-sync for all status updates
3. Standardize phase tracking updates

**Files to modify**:
- `.claude/commands/implement.md` - Update validation and status sections

**Steps**:
1. Add explicit jq lookup in step 1
2. Update step 5 (IMPLEMENTING status) to invoke skill-status-sync
3. Update step 6 phase completion to batch status updates
4. Update step 8 (COMPLETED status) to invoke skill-status-sync

**Verification**:
- Command file shows explicit jq patterns
- All status transitions invoke skill-status-sync
- Phase status updates are tracked

---

### Phase 5: Update /revise Command

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add explicit jq lookup pattern
2. Reference skill-status-sync for status reset

**Files to modify**:
- `.claude/commands/revise.md` - Update Parse/Validate and Status sections

**Steps**:
1. Add explicit jq lookup in step 1
2. Update step 6 to invoke skill-status-sync for status reset to PLANNED

**Verification**:
- Command file shows explicit jq patterns
- Status reset invokes skill-status-sync

---

### Phase 6: Update /task Command (Already Partially Done)

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify jq patterns are complete for all modes
2. Ensure --sync mode uses bidirectional jq/grep patterns
3. Document skill-status-sync invocation for create/abandon operations

**Files to modify**:
- `.claude/commands/task.md` - Verify and enhance all modes

**Steps**:
1. Verify Create mode has complete jq pattern (was already updated)
2. Add explicit jq patterns to Recover mode
3. Add explicit jq patterns to Divide mode
4. Enhance Sync mode with complete bidirectional patterns
5. Add explicit jq patterns to Abandon mode

**Verification**:
- All modes have explicit jq patterns
- Sync mode has complete bidirectional sync logic
- Create mode correctly updates frontmatter

---

### Phase 7: Update state-lookup.md Reference Documentation

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add cross-references to skill-status-sync
2. Ensure all patterns are current
3. Add examples for the new command integrations

**Files to modify**:
- `.claude/context/core/orchestration/state-lookup.md` - Add integration section

**Steps**:
1. Add "Integration with Command Files" section
2. Add cross-reference to skill-status-sync
3. Verify all jq patterns match those in skill-status-sync
4. Add practical examples showing full workflow

**Verification**:
- Documentation is consistent with skill-status-sync
- Examples are runnable and correct

---

## Dependencies

- jq must be available on system (standard tool)
- grep must be available (standard tool)
- No external dependencies

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq patterns may differ between skill and docs | Medium | Low | Phase 7 explicitly validates consistency |
| TODO.md format variations break grep | Medium | Low | Use anchored patterns (^### N.) |
| state.json corruption during updates | High | Low | Use temp file + mv pattern |
| Existing workflows break | Medium | Low | Changes are documentation-only |

## Success Criteria

- [ ] All command files use explicit jq patterns for state.json lookup
- [ ] All command files reference skill-status-sync for status updates
- [ ] skill-status-sync has complete jq/grep pattern documentation
- [ ] state-lookup.md cross-references skill-status-sync
- [ ] Frontmatter sync (next_project_number) is documented in both locations
- [ ] No command file contains "Read entire state.json" instructions

## Rollback Plan

Since these are documentation changes to command files and skills:
1. All changes are in git
2. `git revert` can undo any commit
3. No runtime code is affected (these are instruction files)
4. Previous behavior is preserved (agent interprets instructions)

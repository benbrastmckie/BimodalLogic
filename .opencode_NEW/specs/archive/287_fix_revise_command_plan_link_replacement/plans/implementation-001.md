# Implementation Plan: Fix /revise Command Plan Link Replacement

## Metadata

- **Task**: 287 - Fix /revise command to replace old plan link instead of appending new link
- **Status**: [NOT STARTED]
- **Estimated Effort**: 2.5 hours
- **Priority**: Medium
- **Language**: general
- **Created**: 2026-01-04
- **Plan Version**: 1
- **Research Integrated**: Yes
- **Research Report**: [Research Report](../reports/research-001.md)

## Overview

### Problem Statement

When running `/revise` for a task that already has a plan, the command appends the new plan link to the existing plan link instead of replacing it. This creates confusing entries in TODO.md like:

```markdown
- **Plan**: [Implementation Plan v1](283_.../plans/implementation-001.md) | [Implementation Plan v2](283_.../plans/implementation-002.md) (current)
```

The expected behavior is to replace the old plan link with the new plan link, showing only the current plan in TODO.md while preserving old plan files on disk for reference.

### Scope

**In Scope**:
- Fix status-sync-manager to replace plan links instead of appending
- Add artifact type detection (plan vs. research vs. implementation)
- Implement regex-based plan link replacement logic
- Preserve old plan files on disk (no deletion)
- Update only TODO.md plan link (state.json already works correctly)
- Support both initial plan creation and plan revision

**Out of Scope**:
- Changing plan file naming convention (implementation-NNN.md)
- Modifying plan version history in state.json (already correct)
- Deleting old plan files (they should be preserved)
- Changing /revise command workflow (only status-sync-manager needs changes)

### Constraints

- Must maintain atomic two-phase commit pattern in status-sync-manager
- Must not break existing /plan and /revise workflows
- Must handle edge cases (no existing plan, malformed links, multiple appended links)
- Must preserve backward compatibility with existing TODO.md format

### Definition of Done

- [ ] status-sync-manager replaces plan links instead of appending
- [ ] Old plan files remain on disk for reference
- [ ] Only current plan link shown in TODO.md
- [ ] state.json plan_path updated correctly
- [ ] All edge cases handled (no plan, malformed links, multiple links)
- [ ] Regression tests pass for /plan and /revise commands
- [ ] Task 283 plan links fixed (manual cleanup or automated)

## Goals and Non-Goals

### Goals

1. **Replace plan links atomically**: When a new plan is created via /revise, replace the old plan link in TODO.md with the new plan link
2. **Preserve historical plans**: Keep old plan files on disk for reference
3. **Maintain clarity**: Show only the current plan in TODO.md to avoid confusion
4. **Handle edge cases**: Support tasks with no plan, malformed links, and multiple appended links

### Non-Goals

1. **Change plan versioning**: Plan file naming (implementation-001.md, implementation-002.md) remains unchanged
2. **Modify state.json plan tracking**: state.json already correctly tracks plan_path and plan_versions
3. **Delete old plans**: Old plan files should be preserved, not deleted
4. **Change command workflows**: /plan and /revise workflows remain unchanged

## Risks and Mitigations

### Risk 1: Regex Replacement Breaks TODO.md Format

**Likelihood**: Medium  
**Impact**: High (corrupts TODO.md)

**Mitigation**:
- Use two-phase commit (prepare in memory, validate, then write)
- Add pre-commit validation (verify TODO.md well-formed after replacement)
- Add rollback mechanism (restore from backup if validation fails)
- Test with multiple task formats before deploying

### Risk 2: Edge Cases Not Handled

**Likelihood**: Medium  
**Impact**: Medium (some tasks have incorrect plan links)

**Mitigation**:
- Identify edge cases during implementation (no plan, malformed links, multiple links)
- Add specific handling for each edge case
- Add validation for malformed plan links
- Log warnings for unexpected formats

### Risk 3: Breaks Existing /revise Workflow

**Likelihood**: Low  
**Impact**: High (breaks /revise command)

**Mitigation**:
- Test /revise command end-to-end after changes
- Verify both /plan and /revise work correctly
- Test with tasks that have no plan, one plan, and multiple plans
- Add rollback instructions if deployment fails

## Implementation Phases

### Phase 1: Add Artifact Type Detection [NOT STARTED]

**Estimated Effort**: 30 minutes

**Objective**: Add logic to status-sync-manager to detect artifact type (plan vs. research vs. implementation) and determine whether to replace or append.

**Tasks**:
1. Update status-sync-manager step_3_prepare_updates to extract artifact type from validated_artifacts
2. Add conditional logic: if type == "plan", use replacement mode; otherwise, use append mode
3. Document artifact type detection in status-sync-manager.md

**Acceptance Criteria**:
- [ ] Artifact type extracted from validated_artifacts
- [ ] Replacement mode enabled for plan artifacts
- [ ] Append mode preserved for research and implementation artifacts
- [ ] Logic documented in status-sync-manager.md

**Files Modified**:
- `.opencode/agent/subagents/status-sync-manager.md`

### Phase 2: Implement Plan Link Search Logic [NOT STARTED]

**Estimated Effort**: 30 minutes

**Objective**: Add logic to search for existing plan link in TODO.md task entry using regex pattern matching.

**Tasks**:
1. Define regex pattern for plan link: `^- \*\*Plan\*\*:.*$`
2. Add search logic to extract existing plan link from TODO.md task entry
3. Set replacement_needed flag if existing plan link found
4. Handle edge case: no existing plan link (first plan creation)

**Acceptance Criteria**:
- [ ] Regex pattern correctly matches plan link lines
- [ ] Existing plan link extracted if present
- [ ] replacement_needed flag set correctly
- [ ] Edge case handled: no existing plan link

**Files Modified**:
- `.opencode/agent/subagents/status-sync-manager.md`

### Phase 3: Implement Plan Link Replacement Logic [NOT STARTED]

**Estimated Effort**: 45 minutes

**Objective**: Add logic to replace existing plan link with new plan link using sed or string replacement.

**Tasks**:
1. If replacement_needed: Replace entire plan link line with new plan link
2. If not replacement_needed: Append new plan link after description
3. Use sed or string replacement for atomic line replacement
4. Preserve TODO.md formatting (indentation, markdown syntax)
5. Handle edge case: multiple appended plan links (current bug)

**Acceptance Criteria**:
- [ ] Existing plan link replaced with new plan link
- [ ] New plan link appended if no existing link
- [ ] TODO.md formatting preserved
- [ ] Edge case handled: multiple appended links replaced with single link

**Files Modified**:
- `.opencode/agent/subagents/status-sync-manager.md`

### Phase 4: Add Validation and Error Handling [NOT STARTED]

**Estimated Effort**: 30 minutes

**Objective**: Add validation to verify plan link replacement succeeded and handle errors gracefully.

**Tasks**:
1. Verify new plan link exists in updated TODO.md task entry
2. Verify old plan link removed (if replacement occurred)
3. Verify old plan file still exists on disk
4. Verify new plan file exists on disk
5. Log warnings for malformed plan links
6. Add rollback mechanism if validation fails

**Acceptance Criteria**:
- [ ] New plan link verified in TODO.md
- [ ] Old plan link verified removed
- [ ] Old plan file verified on disk
- [ ] New plan file verified on disk
- [ ] Warnings logged for malformed links
- [ ] Rollback mechanism works if validation fails

**Files Modified**:
- `.opencode/agent/subagents/status-sync-manager.md`

### Phase 5: Testing and Validation [NOT STARTED]

**Estimated Effort**: 45 minutes

**Objective**: Test plan link replacement with various scenarios and edge cases.

**Test Cases**:
1. **Test 1: Initial plan creation** - Create plan for task with no existing plan, verify link appended
2. **Test 2: Plan revision** - Revise plan for task with existing plan, verify link replaced
3. **Test 3: Multiple revisions** - Revise plan multiple times, verify link replaced each time
4. **Test 4: Edge case - malformed link** - Manually corrupt plan link, run /revise, verify graceful handling
5. **Test 5: Edge case - multiple appended links** - Run /revise on task 283 (has appended links), verify single link
6. **Test 6: Old plan file preservation** - Verify old plan files still exist on disk after revision
7. **Test 7: state.json correctness** - Verify state.json plan_path and plan_versions updated correctly

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] No regression in /plan command
- [ ] No regression in /revise command
- [ ] Edge cases handled gracefully
- [ ] Old plan files preserved on disk
- [ ] state.json updated correctly

**Files Modified**:
- None (testing only)

## Testing and Validation

### Unit Tests

**Test 1: Artifact Type Detection**
- Input: validated_artifacts with type="plan"
- Expected: replacement_mode = true
- Input: validated_artifacts with type="research"
- Expected: replacement_mode = false

**Test 2: Plan Link Search**
- Input: TODO.md task entry with existing plan link
- Expected: existing_plan_line extracted, replacement_needed = true
- Input: TODO.md task entry with no plan link
- Expected: replacement_needed = false

**Test 3: Plan Link Replacement**
- Input: Task entry with single plan link, new plan path
- Expected: Old link replaced with new link
- Input: Task entry with multiple appended links, new plan path
- Expected: All old links replaced with single new link

### Integration Tests

**Test 1: /plan Command**
- Run /plan on task with no existing plan
- Verify plan link appended to TODO.md
- Verify state.json plan_path set correctly

**Test 2: /revise Command**
- Run /revise on task with existing plan
- Verify old plan link replaced with new link
- Verify old plan file still exists on disk
- Verify state.json plan_path updated to new version

**Test 3: Multiple Revisions**
- Run /revise multiple times on same task
- Verify plan link replaced each time (not appended)
- Verify all old plan files preserved on disk

### Edge Case Tests

**Test 1: No Existing Plan**
- Run /plan on new task
- Verify plan link appended (not replaced)

**Test 2: Malformed Plan Link**
- Manually corrupt plan link in TODO.md
- Run /revise
- Verify graceful handling (warning logged, new link appended)

**Test 3: Multiple Appended Links (Current Bug)**
- Use task 283 with appended links
- Run /revise
- Verify all old links replaced with single new link

**Test 4: Plan File Deleted**
- Delete old plan file from disk
- Run /revise
- Verify link still replaced (warning logged for missing file)

## Artifacts and Outputs

### Modified Files

1. `.opencode/agent/subagents/status-sync-manager.md`
   - Add artifact type detection in step_3_prepare_updates
   - Add plan link search logic (regex pattern matching)
   - Add plan link replacement logic (sed or string replacement)
   - Add validation and error handling

### Documentation Updates

1. `.opencode/agent/subagents/status-sync-manager.md`
   - Document artifact type detection logic
   - Document plan link replacement algorithm
   - Document edge case handling
   - Add examples of plan link replacement

### Test Artifacts

1. Test results for all unit tests, integration tests, and edge case tests
2. Validation report showing all acceptance criteria met

## Rollback/Contingency

### Rollback Plan

If plan link replacement causes issues:

1. **Immediate Rollback**: Revert status-sync-manager.md to previous version
2. **Manual Cleanup**: Fix any corrupted TODO.md entries manually
3. **Restore from Backup**: Use git to restore TODO.md if corrupted
4. **Disable Feature**: Add feature flag to disable plan link replacement if needed

### Contingency Plan

If regex replacement proves too fragile:

1. **Alternative Approach**: Use manual string parsing instead of regex
2. **Simplified Logic**: Only replace if exact match found, otherwise append
3. **Manual Cleanup**: Document manual cleanup process for existing appended links

## Success Metrics

### Functional Metrics

- [ ] Plan link replacement works for 100% of test cases
- [ ] No regression in /plan or /revise commands
- [ ] All edge cases handled gracefully
- [ ] Old plan files preserved in 100% of cases

### Quality Metrics

- [ ] Zero TODO.md corruption incidents
- [ ] Zero plan file deletion incidents
- [ ] All validation checks pass
- [ ] Rollback mechanism tested and working

### User Experience Metrics

- [ ] TODO.md plan links clear and unambiguous (single link shown)
- [ ] Old plans accessible in project directory for reference
- [ ] No user confusion about which plan is current

## Notes

### Research Findings Integration

Research identified the root cause as status-sync-manager's artifact link update logic in step_3_prepare_updates (lines 165-189). The current logic appends all artifact links without distinguishing between plan links (which should be replaced) and other artifact links (which should be appended).

Key research findings:
1. Planner correctly creates new plan files with incremented version numbers
2. state.json correctly tracks plan_path and plan_versions
3. Only TODO.md plan link needs fixing
4. Regex replacement is the recommended approach (simpler and more robust)

### Implementation Notes

- Use two-phase commit pattern (prepare in memory, validate, then write)
- Add pre-commit validation to prevent TODO.md corruption
- Log warnings for unexpected formats or edge cases
- Preserve backward compatibility with existing TODO.md format

### Future Enhancements

- Add automated cleanup script to fix existing appended plan links
- Add validation to prevent manual corruption of plan links
- Consider adding plan link history section to TODO.md (optional)

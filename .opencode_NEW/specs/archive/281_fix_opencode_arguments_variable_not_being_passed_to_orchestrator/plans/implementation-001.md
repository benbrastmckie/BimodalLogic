# Implementation Plan: Fix OpenCode $ARGUMENTS Variable Not Being Passed to Orchestrator

**Task**: 281  
**Created**: 2026-01-03  
**Status**: [NOT STARTED]  
**Estimated Effort**: 4 hours  
**Complexity**: Medium  
**Research Integrated**: Yes

---

## Metadata

**Type**: Bugfix  
**Priority**: High  
**Language**: general  
**Blocking**: None  
**Dependencies**: None  
**Research Report**: `specs/281_fix_opencode_arguments_variable_not_being_passed_to_orchestrator/reports/research-001.md`

**Key Insight from User**: 
- Task 278's fix to orchestrator argument parsing did NOT work
- `/research`, `/plan`, and `/revise` commands DO work correctly
- Only `/implement` command fails with empty `$ARGUMENTS`
- This means the issue is NOT with OpenCode's argument passing mechanism
- The issue is specific to the `/implement` command

**Root Cause Revision**:
The research report hypothesized that OpenCode doesn't pass `$ARGUMENTS` to agents. However, the fact that `/research`, `/plan`, and `/revise` work proves this hypothesis is **incorrect**. The real issue must be:
1. Something specific to the `/implement` command file
2. A difference in how `/implement` is structured vs. working commands
3. A configuration issue specific to `/implement`

---

## Success Criteria

- [ ] `/implement 275` successfully receives "275" in `$ARGUMENTS`
- [ ] Orchestrator Stage 1 validation passes for `/implement` commands
- [ ] `/implement` command works identically to `/research` and `/plan`
- [ ] No regression in other commands
- [ ] Root cause documented and understood

---

## Phase Breakdown

### Phase 1: Compare Working vs. Broken Commands [NOT STARTED]

**Objective**: Identify the exact difference between `/implement` (broken) and `/research`/`/plan` (working)

**Tasks**:
1. Read full content of `/research` command file
2. Read full content of `/plan` command file  
3. Read full content of `/implement` command file
4. Create side-by-side comparison of:
   - Frontmatter structure
   - Task Input declaration
   - Workflow stages
   - Any unique sections in `/implement`
5. Identify ALL differences between working and broken commands

**Acceptance Criteria**:
- [ ] All three command files read and compared
- [ ] Differences documented in comparison table
- [ ] Hypothesis formed about which difference causes the issue

**Estimated Effort**: 1 hour

---

### Phase 2: Test Hypothesis and Identify Root Cause [NOT STARTED]

**Objective**: Determine which specific difference causes `/implement` to fail

**Tasks**:
1. Based on Phase 1 comparison, identify most likely cause
2. Test hypothesis by temporarily modifying `/implement` to match working commands
3. Run `/implement 275` to verify if fix works
4. If fix works, document the exact root cause
5. If fix doesn't work, try next hypothesis from Phase 1

**Acceptance Criteria**:
- [ ] Root cause identified and verified
- [ ] Test confirms `/implement` works after modification
- [ ] Exact problematic section/configuration documented

**Estimated Effort**: 1 hour

---

### Phase 3: Apply Permanent Fix [NOT STARTED]

**Objective**: Fix `/implement` command file permanently

**Tasks**:
1. Apply the fix identified in Phase 2 to `/implement` command file
2. Ensure fix maintains all existing `/implement` functionality
3. Verify fix doesn't break language-based routing
4. Verify fix doesn't break resume support
5. Test with multiple task numbers: `/implement 271`, `/implement 275`, `/implement 281`

**Acceptance Criteria**:
- [ ] `/implement` command file updated with permanent fix
- [ ] All test cases pass
- [ ] No functionality regression
- [ ] Language-based routing still works

**Estimated Effort**: 1 hour

---

### Phase 4: Validation and Documentation [NOT STARTED]

**Objective**: Ensure fix is complete and well-documented

**Tasks**:
1. Test all task-based commands:
   - `/research 281` - Should work (already working)
   - `/plan 281` - Should work (already working)
   - `/implement 281` - Should work (newly fixed)
   - `/revise 281` - Should work (already working)
2. Test direct commands to ensure no regression:
   - `/meta` - Should work
   - `/review` - Should work
3. Update documentation:
   - Document the root cause in implementation summary
   - Update command-argument-handling.md if needed
   - Add note to creating-commands.md about the issue
4. Create git commit with clear explanation

**Acceptance Criteria**:
- [ ] All commands tested and working
- [ ] Documentation updated
- [ ] Git commit created
- [ ] Implementation summary written

**Estimated Effort**: 1 hour

---

## Risk Assessment

### Risk 1: Multiple Differences Between Commands

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**: Test each difference individually to isolate the cause

### Risk 2: Fix Breaks Existing Functionality

**Likelihood**: Low  
**Impact**: High  
**Mitigation**: 
- Test thoroughly before committing
- Keep backup of original `/implement` command
- Test language-based routing and resume support

### Risk 3: Issue is Not in Command File

**Likelihood**: Low  
**Impact**: High  
**Mitigation**: 
- If command file comparison reveals no differences, investigate orchestrator routing logic
- Check if `/implement` is being invoked differently than other commands

---

## Implementation Notes

### Key Insight

The fact that `/research`, `/plan`, and `/revise` work proves that:
1. OpenCode DOES pass `$ARGUMENTS` to the orchestrator
2. The orchestrator DOES receive arguments correctly
3. Task 278's orchestrator fix is NOT the issue
4. The problem is specific to `/implement` command

### Likely Causes (Ordered by Probability)

1. **Syntax Error in `/implement` Command File**: A typo or formatting issue that breaks argument passing
2. **Extra/Missing Section**: `/implement` has a section that interferes with argument passing
3. **Frontmatter Configuration**: A frontmatter field in `/implement` that's different from working commands
4. **Workflow Stage Issue**: A workflow stage in `/implement` that clears or overwrites `$ARGUMENTS`

### Testing Strategy

1. **Minimal Change Approach**: Make the smallest possible change to fix the issue
2. **Incremental Testing**: Test after each change to identify exact fix
3. **Regression Testing**: Ensure all existing functionality still works

---

## Files to Modify

**Primary**:
- `.opencode/command/implement.md` - Fix the issue causing `$ARGUMENTS` to be empty

**Documentation**:
- `specs/281_fix_opencode_arguments_variable_not_being_passed_to_orchestrator/summaries/implementation-summary-YYYYMMDD.md` - Document the fix
- `specs/TODO.md` - Update status to [COMPLETED]
- `specs/state.json` - Update status and completion timestamp

**Possibly**:
- `.opencode/context/core/standards/command-argument-handling.md` - Add note about the issue if it's a common pitfall
- `.opencode/docs/guides/creating-commands.md` - Add warning about the issue

---

## Rollback Plan

If the fix causes issues:

1. **Immediate Rollback**: 
   ```bash
   git checkout HEAD~1 .opencode/command/implement.md
   ```

2. **Verify Rollback**:
   - Test that `/implement` returns to previous behavior
   - Verify other commands still work

3. **Re-analyze**:
   - Review the failed fix
   - Identify why it didn't work
   - Try alternative approach

---

## Success Metrics

**Primary Metric**: `/implement 275` successfully executes without "Arguments provided: (empty)" error

**Secondary Metrics**:
- All task-based commands work correctly
- No regression in direct commands
- Root cause clearly documented
- Fix is minimal and maintainable

---

## Timeline

**Total Estimated Effort**: 4 hours

**Phase 1**: 1 hour - Compare commands and identify differences  
**Phase 2**: 1 hour - Test hypothesis and find root cause  
**Phase 3**: 1 hour - Apply permanent fix  
**Phase 4**: 1 hour - Validation and documentation

**Expected Completion**: Same day (4 hours of focused work)

---

## Appendix: Research Summary

The research report (research-001.md) hypothesized that OpenCode doesn't pass `$ARGUMENTS` to agents. However, this hypothesis is **contradicted** by the user's observation that `/research`, `/plan`, and `/revise` work correctly.

**Revised Understanding**:
- OpenCode DOES pass `$ARGUMENTS` to agents (proven by working commands)
- The orchestrator DOES receive and parse arguments correctly (Task 278 fix is working)
- The issue is specific to `/implement` command file
- The fix will be found by comparing `/implement` to working commands

**Key Lesson**: Always test hypotheses against real-world observations. The user's insight that other commands work is the critical clue that invalidates the research hypothesis and points to the real solution.

# Implementation Plan 002: Fix Typo in /implement Command (REVISED)

**Task**: 281  
**Created**: 2026-01-03  
**Status**: [NOT STARTED]  
**Estimated Effort**: 15 minutes  
**Complexity**: Trivial  
**Research Integrated**: Yes (research-002.md)  
**Supersedes**: implementation-001.md (overly complex, based on incorrect hypothesis)

---

## Metadata

**Type**: Bugfix  
**Priority**: High  
**Language**: general  
**Blocking**: None  
**Dependencies**: None  
**Research Report**: `.opencode/specs/281_fix_opencode_arguments_variable_not_being_passed_to_orchestrator/reports/research-002.md`

**Root Cause** (from research-002.md):
Line 34 of `/implement` command says "from **arguments**" instead of "from **$ARGUMENTS**". This single missing `$` character causes the orchestrator to not recognize where to extract the task number from.

**The Fix**:
Change one word in one line of one file. That's it.

---

## Success Criteria

- [ ] Line 34 of `/implement` command updated to reference `$ARGUMENTS`
- [ ] `/implement 275` successfully receives "275" in `$ARGUMENTS`
- [ ] Orchestrator Stage 1 validation passes for `/implement` commands
- [ ] No regression in other commands (`/research`, `/plan`, `/revise`)
- [ ] Implementation summary documents the fix

---

## Phase Breakdown

### Phase 1: Apply the Fix [NOT STARTED]

**Objective**: Fix the typo in `/implement` command file

**Tasks**:
1. Open `.opencode/command/implement.md`
2. Navigate to line 34
3. Change "from arguments" to "from $ARGUMENTS"
4. Save the file

**Current Line 34**:
```markdown
- **Stage 1 (PreflightValidation):** Parse task number or range from arguments, validate tasks exist
```

**Fixed Line 34**:
```markdown
- **Stage 1 (PreflightValidation):** Parse task number or range from $ARGUMENTS, validate tasks exist
```

**Change**: Add `$` prefix to "arguments"

**Acceptance Criteria**:
- [ ] Line 34 updated correctly
- [ ] File saved
- [ ] No other changes made

**Estimated Effort**: 2 minutes

---

### Phase 2: Test the Fix [NOT STARTED]

**Objective**: Verify `/implement` command now works

**Test Cases**:

**Test 1: Single Task Number**
```bash
/implement 275
```
**Expected**: Orchestrator extracts "275" from `$ARGUMENTS`, proceeds to implementation

**Test 2: Task Range**
```bash
/implement 105-107
```
**Expected**: Orchestrator extracts "105-107" from `$ARGUMENTS`, proceeds to batch implementation

**Test 3: Task with Prompt**
```bash
/implement 275 "Focus on error handling"
```
**Expected**: Orchestrator extracts "275" and prompt, proceeds to implementation

**Acceptance Criteria**:
- [ ] All three test cases pass
- [ ] No "Arguments provided: (empty)" error
- [ ] Orchestrator Stage 1 validation succeeds

**Estimated Effort**: 5 minutes

---

### Phase 3: Regression Testing [NOT STARTED]

**Objective**: Ensure other commands still work

**Test Cases**:

```bash
/research 281  # Should still work
/plan 281      # Should still work
/revise 281    # Should still work (if plan exists)
```

**Acceptance Criteria**:
- [ ] All working commands continue to work
- [ ] No unexpected errors
- [ ] No behavior changes

**Estimated Effort**: 3 minutes

---

### Phase 4: Documentation and Commit [NOT STARTED]

**Objective**: Document the fix and create git commit

**Tasks**:
1. Create implementation summary documenting:
   - The typo (missing `$` prefix)
   - The fix (added `$` prefix)
   - Why Task 278 didn't work (assumed correct `$ARGUMENTS` reference)
   - Lessons learned (check for typos before complex fixes)
2. Update TODO.md status to [COMPLETED]
3. Update state.json with completion timestamp
4. Create git commit with clear message

**Acceptance Criteria**:
- [ ] Implementation summary created
- [ ] TODO.md updated to [COMPLETED]
- [ ] state.json updated
- [ ] Git commit created with clear explanation

**Estimated Effort**: 5 minutes

---

## Risk Assessment

### Risk 1: Fix Doesn't Work

**Likelihood**: Very Low  
**Impact**: Low  
**Mitigation**: Research-002 provides strong evidence this is the correct fix. If it doesn't work, revert and investigate further.

### Risk 2: Breaks Other Commands

**Likelihood**: Very Low  
**Impact**: Medium  
**Mitigation**: The change is isolated to `/implement` command. Regression testing will catch any issues.

---

## Implementation Notes

### Why This Plan Is So Simple

Research-002 identified the **exact** root cause: a single missing `$` character. The fix is trivial:
- **Before**: "from arguments"
- **After**: "from $ARGUMENTS"

No need for:
- ❌ Comparing multiple command files (already done in research-002)
- ❌ Testing hypotheses (root cause already confirmed)
- ❌ Complex architectural changes (not needed)
- ❌ Orchestrator modifications (orchestrator is correct)

### Why Implementation-001 Was Overly Complex

Implementation-001 was created before research-002 identified the root cause. It proposed:
- Phase 1: Compare working vs. broken commands (4 phases, 4 hours)
- Phase 2: Test hypothesis and identify root cause
- Phase 3: Apply permanent fix
- Phase 4: Validation and documentation

This was necessary when the root cause was unknown. Now that research-002 has identified the exact issue, we can skip straight to the fix.

### Lessons Learned

1. **Do research first**: Research-002's comparative analysis saved hours of implementation time
2. **Simple fixes for simple bugs**: A typo requires a typo fix, not architectural changes
3. **User observations are gold**: The insight that other commands work led directly to finding the typo

---

## Files to Modify

**Primary**:
- `.opencode/command/implement.md` - Line 34: Change "arguments" to "$ARGUMENTS"

**Documentation**:
- `.opencode/specs/281_fix_opencode_arguments_variable_not_being_passed_to_orchestrator/summaries/implementation-summary-20260103.md` - Document the fix
- `.opencode/specs/TODO.md` - Update status to [COMPLETED]
- `.opencode/specs/state.json` - Update completion timestamp

---

## Comparison: Implementation-001 vs Implementation-002

| Aspect | Implementation-001 | Implementation-002 |
|--------|-------------------|-------------------|
| **Phases** | 4 phases | 4 phases |
| **Estimated Effort** | 4 hours | 15 minutes |
| **Complexity** | Medium | Trivial |
| **Approach** | Investigate then fix | Fix directly |
| **Research** | Incomplete (hypothesis) | Complete (root cause) |
| **Risk** | Medium | Very Low |

Implementation-002 is **16x faster** because research-002 already did the investigation work.

---

## Timeline

**Total Estimated Effort**: 15 minutes

**Phase 1**: 2 minutes - Fix the typo  
**Phase 2**: 5 minutes - Test the fix  
**Phase 3**: 3 minutes - Regression testing  
**Phase 4**: 5 minutes - Documentation and commit

**Expected Completion**: Same session (15 minutes of focused work)

---

## Success Metrics

**Primary Metric**: `/implement 275` executes without "Arguments provided: (empty)" error

**Secondary Metrics**:
- Fix applied in <5 minutes
- All test cases pass
- No regression in other commands
- Clear documentation of the fix

---

## Appendix: The Exact Change

**File**: `.opencode/command/implement.md`  
**Line**: 34  
**Column**: 67 (approximately)

**Before**:
```markdown
- **Stage 1 (PreflightValidation):** Parse task number or range from arguments, validate tasks exist
                                                                      ^^^^^^^^^ (missing $)
```

**After**:
```markdown
- **Stage 1 (PreflightValidation):** Parse task number or range from $ARGUMENTS, validate tasks exist
                                                                      ^^^^^^^^^^ ($ added)
```

**Diff**:
```diff
- - **Stage 1 (PreflightValidation):** Parse task number or range from arguments, validate tasks exist
+ - **Stage 1 (PreflightValidation):** Parse task number or range from $ARGUMENTS, validate tasks exist
```

**Character Count**:
- Before: 103 characters
- After: 104 characters
- Change: +1 character (`$`)

---

## Conclusion

This is a **trivial fix** for a **simple typo**. The complexity was in finding the bug (research-002), not in fixing it. Total implementation time: 15 minutes.

**Key Insight**: Sometimes the hardest part of fixing a bug is finding it. Once found, the fix can be trivial.

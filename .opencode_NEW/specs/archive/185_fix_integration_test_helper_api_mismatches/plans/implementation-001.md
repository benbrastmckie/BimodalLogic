# Implementation Plan: Fix Integration Test Helper API Mismatches

- **Task**: 185 - Fix integration test helper API mismatches
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Priority**: High
- **Dependencies**: 183 (DeductionTheorem.lean), 184 (resolved by task 219)
- **Research Inputs**: specs/185_fix_integration_test_helper_api_mismatches/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: lean
- **Lean Intent**: true

## Overview

Fix 3 API mismatches in LogosTest/Core/Integration/Helpers.lean that prevent test compilation after core build errors are resolved. Research identified root cause as confusion between validity (⊨ φ) and semantic consequence ([] ⊨ φ). All fixes are trivial using the valid_iff_empty_consequence conversion theorem. Once fixed, all 146 integration tests will compile and pass, delivering verified 82% integration test coverage and completing task 173.

## Goals & Non-Goals

**Goals:**
- Fix line 126 semantic consequence type mismatch in verify_validity function
- Fix line 131 validity unwrapping issue in verify_workflow function
- Fix line 129 unsolved goals in verify_workflow (automatically resolved by line 131 fix)
- Ensure Helpers.lean compiles successfully
- Verify all 146 integration tests compile and pass
- Maintain test execution time under 2 minutes

**Non-Goals:**
- Refactoring helper functions beyond fixing the 3 API mismatches
- Adding new helper functions or test utilities
- Modifying integration test files beyond Helpers.lean
- Changing core Logos API (Validity.lean, Soundness.lean)

## Risks & Mitigations

- **Risk**: Fixes break existing integration tests that depend on Helpers.lean
  - **Mitigation**: Research confirmed fixes align with correct API usage patterns from ProofSystemSemanticsTest.lean and SoundnessTest.lean. Run full test suite to verify.

- **Risk**: Test execution time exceeds 2 minutes after fixes
  - **Mitigation**: Fixes are type-level only, no runtime performance impact. Monitor with lake exe test.

- **Risk**: Dependencies (tasks 183, 184) not fully resolved
  - **Mitigation**: Task 184 resolved by task 219 (Truth.lean compiles). Verify task 183 completion before starting.

## Implementation Phases

### Phase 1: Fix Line 126 - verify_validity Type Mismatch [NOT STARTED]

- **Goal:** Convert semantic consequence ([] ⊨ φ) to validity (⊨ φ) using valid_iff_empty_consequence theorem
- **Tasks:**
  - [ ] Open LogosTest/Core/Integration/Helpers.lean
  - [ ] Locate verify_validity function (line 125-126)
  - [ ] Replace `soundness [] φ d` with `Validity.valid_iff_empty_consequence φ |>.mpr (soundness [] φ d)`
  - [ ] Verify syntax is correct (proper module qualification, pipe operator)
  - [ ] Save file
- **Timing:** 10 minutes
- **Acceptance Criteria:**
  - verify_validity function returns ⊨ φ type correctly
  - No type mismatch errors on line 126

### Phase 2: Fix Line 131 - verify_workflow Validity Unwrapping [NOT STARTED]

- **Goal:** Simplify verify_workflow to avoid incorrect validity unwrapping
- **Tasks:**
  - [ ] Locate verify_workflow function (line 129-132)
  - [ ] Review current implementation attempting to unwrap validity
  - [ ] Replace line 131 `have : ∀ F M τ t ht, truth_at M τ t ht φ := valid` with `have _valid : ⊨ φ := verify_validity φ d` (underscore prefix to mark unused)
  - [ ] Verify line 132 `trivial` completes the proof
  - [ ] Save file
- **Timing:** 10 minutes
- **Acceptance Criteria:**
  - verify_workflow compiles without type mismatch errors
  - Line 129 unsolved goals error automatically resolved
  - Function correctly returns True

### Phase 3: Compile Helpers.lean and Verify Fixes [NOT STARTED]

- **Goal:** Confirm Helpers.lean compiles successfully with all fixes applied
- **Tasks:**
  - [ ] Run `lake build LogosTest.Core.Integration.Helpers`
  - [ ] Verify no compilation errors
  - [ ] Check for any warnings related to the modified functions
  - [ ] Review compiler output for any unexpected issues
- **Timing:** 5 minutes
- **Acceptance Criteria:**
  - Helpers.lean compiles without errors
  - No type mismatch errors on lines 126, 129, or 131
  - No new warnings introduced

### Phase 4: Run Integration Test Suite [NOT STARTED]

- **Goal:** Verify all 146 integration tests compile and pass with fixed helpers
- **Tasks:**
  - [ ] Run `lake build LogosTest.Integration`
  - [ ] Verify all integration test files compile successfully
  - [ ] Run `lake exe test` to execute all tests
  - [ ] Verify all 146 integration tests pass
  - [ ] Measure test execution time
  - [ ] Check for any test failures or regressions
- **Timing:** 20 minutes
- **Acceptance Criteria:**
  - All 146 integration tests compile successfully
  - All 146 integration tests pass
  - Test execution time is under 2 minutes
  - No regressions in test coverage

### Phase 5: Validation and Documentation [NOT STARTED]

- **Goal:** Final validation and update task tracking
- **Tasks:**
  - [ ] Run full project build with `lake build`
  - [ ] Verify no build errors in any module
  - [ ] Confirm 82% integration test coverage achieved
  - [ ] Document changes in implementation summary
  - [ ] Verify all acceptance criteria met
  - [ ] Update TODO.md task 185 status to [COMPLETED]
- **Timing:** 15 minutes
- **Acceptance Criteria:**
  - Full project builds successfully
  - All acceptance criteria from task 185 verified
  - Implementation summary created
  - Task 185 marked [COMPLETED] in TODO.md

## Testing & Validation

**Compilation Tests:**
- [ ] `lake build LogosTest.Core.Integration.Helpers` succeeds
- [ ] `lake build LogosTest.Integration` succeeds
- [ ] `lake build` (full project) succeeds

**Integration Tests:**
- [ ] All 146 integration tests compile
- [ ] All 146 integration tests pass with `lake exe test`
- [ ] Test execution time < 2 minutes

**Regression Tests:**
- [ ] No new compilation errors introduced
- [ ] No test failures in previously passing tests
- [ ] No warnings introduced in modified code

**Coverage Verification:**
- [ ] 82% integration test coverage maintained
- [ ] Task 173 completion criteria satisfied

## Artifacts & Outputs

**Modified Files:**
- LogosTest/Core/Integration/Helpers.lean (lines 126, 131 modified)

**Generated Artifacts:**
- specs/185_fix_integration_test_helper_api_mismatches/plans/implementation-001.md (this file)
- specs/185_fix_integration_test_helper_api_mismatches/summaries/implementation-summary-YYYYMMDD.md (created on completion)

**State Updates:**
- specs/TODO.md (task 185 status → [COMPLETED])
- specs/state.json (task 185 status, completion timestamp)
- specs/185_fix_integration_test_helper_api_mismatches/state.json (project state)

## Rollback/Contingency

**If fixes introduce test failures:**
1. Revert Helpers.lean to original version
2. Re-analyze research findings for alternative fix approaches
3. Consider Option A (explicit unwrapping) or Option C (remove intermediate step) from research report
4. Test alternative approaches incrementally

**If compilation errors persist:**
1. Verify dependencies (tasks 183, 184) are fully resolved
2. Check for API changes in Validity.lean or Soundness.lean
3. Consult research report section "Correct Usage Patterns from Codebase"
4. Escalate to research phase if API has changed since research completion

**If test execution time exceeds 2 minutes:**
1. Profile test execution to identify slow tests
2. Verify no performance regression in helper functions
3. Consider test parallelization or optimization (separate task)

**Rollback Command:**
```bash
git checkout HEAD -- LogosTest/Core/Integration/Helpers.lean
```

## Research Integration Summary

Research (research-001.md) identified the root cause and provided exact fixes:

**Root Cause:** Confusion between validity (⊨ φ) and semantic consequence ([] ⊨ φ). These are logically equivalent but different types in Lean's type system.

**Key API Discovery:** `Validity.valid_iff_empty_consequence` theorem provides bidirectional conversion:
- `.mp` direction: (⊨ φ) → ([] ⊨ φ)
- `.mpr` direction: ([] ⊨ φ) → (⊨ φ)

**Fix Strategy:**
1. Line 126: Use `.mpr` to convert soundness result ([] ⊨ φ) to validity (⊨ φ)
2. Line 131: Simplify to avoid incorrect unwrapping (missing T parameter)
3. Line 129: Automatically resolved by line 131 fix

**Effort Estimate:** Research confirmed < 30 minutes implementation (trivial changes, well-understood API)

**Validation:** Research identified correct usage patterns from ProofSystemSemanticsTest.lean and SoundnessTest.lean confirming fix approach.

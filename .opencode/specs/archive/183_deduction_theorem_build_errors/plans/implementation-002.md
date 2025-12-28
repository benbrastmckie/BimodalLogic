# Implementation Plan: Fix DeductionTheorem.lean Build Errors

**Task**: 183  
**Plan Version**: 002  
**Created**: 2025-12-28  
**Status**: Ready for Implementation

---

## Metadata

- **Project Number**: 183
- **Type**: Bugfix
- **Priority**: High
- **Complexity**: Low (Purely Syntactic)
- **Estimated Hours**: 0.5 hours (30 minutes)
- **Phases**: 1

---

## Overview

Fix 3 build errors in `Logos/Core/Metalogic/DeductionTheorem.lean` by replacing term-mode `.elim` patterns with the `by_cases` tactic. All 3 errors stem from using `(em P).elim` inside `match` expressions - the `.elim` method is a term-mode construct that causes "unknown tactic" errors at lines 256, 369, and 376. The fix is straightforward: replace with `by_cases h : P` tactic and use bullet-point formatting.

**Root Cause**: Using term-mode `.elim` method inside tactic-mode `match` expressions.

**Solution**: Replace with `by_cases` tactic (proven pattern in Soundness.lean line 282, Truth.lean lines 789-825).

---

## Research Inputs

Research completed on 2025-12-25 (see `.opencode/specs/183_deduction_theorem_build_errors/reports/research-001.md`):

### Key Findings

1. **Error Pattern**: All 3 errors are "unknown tactic" errors from using `.elim` in tactic mode
   - Line 256: `(em (A ∈ Γ'')).elim` in `deduction_with_mem` weakening case
   - Line 369: `(em (Γ' = A :: Γ)).elim` in `deduction_theorem` outer case
   - Line 376: `(em (A ∈ Γ')).elim` in `deduction_theorem` inner case (nested)

2. **Root Cause Confirmed**: `.elim` is a term-mode method, not a tactic
   - Using it inside `match` expressions (which are in tactic mode) fails
   - The file already has `open Classical` at line 39, making `by_cases` available

3. **Proven Solution**: Replace with `by_cases h : P` tactic
   - Soundness.lean line 282 uses this pattern successfully
   - Truth.lean lines 789-825 uses nested `by_cases` successfully
   - Use `·` bullet points for case branches
   - Remove closing parentheses from converted patterns

4. **Termination Proofs**: Already correct, will work once tactic errors fixed
   - No changes needed to `decreasing_by` clauses
   - Purely syntactic conversion, no semantic changes

### Recommendations

- **Proceed immediately**: Simple syntactic fix with proven pattern
- **Estimated time**: 30 minutes (3 replacements + verification)
- **Risk level**: Very low (purely syntactic, proven pattern)
- **No refactoring needed**: Change only tactic syntax

---

## Phase Breakdown

### Phase 1: Apply All Fixes and Validate [COMPLETED] ✅
(Started: 2025-12-25, Completed: 2025-12-28)

**Estimated Effort**: 30 minutes
**Actual Effort**: 30 minutes (fixes applied in previous session, verified 2025-12-28)

**Objective**: Replace all 3 `.elim` patterns with `by_cases` tactic and verify build success.

**Tasks**:

1. **Fix Line 256 (deduction_with_mem weakening case)** (8 minutes)
   - Replace: `(em (A ∈ Γ'')).elim (fun hA' => ...) (fun hA' => ...)`
   - With: `by_cases hA' : A ∈ Γ''` + bullet points
   - Update case branches to use `·` bullets
   - Remove closing parentheses

2. **Fix Line 369 (deduction_theorem outer case)** (8 minutes)
   - Replace: `(em (Γ' = A :: Γ)).elim (fun h_eq => ...) (fun h_eq => ...)`
   - With: `by_cases h_eq : Γ' = A :: Γ` + bullet points
   - Update first branch to use `·` bullet
   - Keep inner `.elim` temporarily (will fix in next step)

3. **Fix Line 376 (deduction_theorem inner case)** (8 minutes)
   - Replace: `(em (A ∈ Γ')).elim (fun hA => ...) (fun hA => ...)`
   - With: `by_cases hA : A ∈ Γ'` + nested bullet points
   - Ensure nested bullets properly indented inside outer bullet
   - Remove closing parentheses

4. **Build and Verify** (6 minutes)
   - Run: `lake build Logos.Core.Metalogic.DeductionTheorem`
   - Expected: Zero errors, successful compilation
   - Run: `lake build Logos.Core.Metalogic`
   - Expected: All metalogic modules compile
   - Run: `lake exe test` (metalogic tests)
   - Expected: All existing tests pass

**Files Modified**:
- `Logos/Core/Metalogic/DeductionTheorem.lean` (3 replacements at lines 256, 369, 376)

**Acceptance Criteria**:
- [x] All 3 "unknown tactic" errors resolved (0 errors in build output)
- [x] DeductionTheorem.lean compiles successfully
- [x] All metalogic modules build without errors
- [x] Existing metalogic tests pass without regressions
- [x] Code follows Lean 4 style guide (bullet points, indentation)
- [x] Termination proofs work without changes

**Rollback Plan**:
If unexpected issues occur:
1. Revert changes: `git checkout Logos/Core/Metalogic/DeductionTheorem.lean`
2. Investigate error messages and adjust approach (unlikely to be needed)

**Notes**:
- No documentation changes needed (trivial syntactic fix)
- No API changes (only tactic syntax changed)
- No test file updates needed (existing tests should work unchanged)
- Comments added explaining classical case analysis for clarity

---

## Success Criteria

### Build Success
- [x] `lake build Logos.Core.Metalogic.DeductionTheorem` completes with 0 errors
- [x] `lake build Logos.Core.Metalogic` completes with 0 errors
- [x] No new warnings introduced

### Test Success
- [x] Existing metalogic tests pass without regressions
- [x] No test failures introduced

### Code Quality
- [x] Changes are minimal (3 tactic replacements)
- [x] No logic changes (only syntax conversion)
- [x] Follows Lean 4 style guide (bullet points, indentation)
- [x] Comments explain classical case analysis

### Unblocking
- [x] Task 173 unblocked (integration tests can now compile)
- [x] Dependent modules build successfully

---

## Risk Assessment

**Overall Risk**: Very Low

**Risk Factors**:
- **Simplicity**: 3 tactic replacements, no logic modifications
- **Proven Pattern**: `by_cases` is the idiomatic Lean 4 pattern (used in Soundness.lean, Truth.lean)
- **No Semantic Changes**: Only syntax conversion, logic remains identical
- **Termination Proofs**: Already correct, no changes needed
- **Isolated Impact**: Only affects DeductionTheorem.lean, no API changes

**Mitigation**:
- Full build verification catches any unexpected issues
- Test suite verification ensures no behavioral regressions
- Git rollback available if needed (though unlikely)

---

## Why by_cases?

The `by_cases` tactic is the idiomatic Lean 4 pattern for classical case analysis in tactic mode. Here's why `.elim` fails and `by_cases` succeeds:

### Term Mode vs Tactic Mode

- **Term Mode**: Building proof terms directly using functions and eliminators
  - `.elim` is a term-mode method on `Or` types
  - Works in term-mode contexts: `(em P).elim (fun h => term1) (fun h => term2)`

- **Tactic Mode**: Building proofs using tactics that manipulate goals
  - `by_cases` is a tactic that splits the goal into two cases
  - Works in tactic-mode contexts (inside `match` expressions, `by` blocks)

### Why DeductionTheorem.lean Uses Tactic Mode

The `match` expressions in DeductionTheorem.lean are in tactic mode because they're building derivation trees recursively. Using `.elim` inside these `match` expressions causes "unknown tactic" errors because Lean expects tactics, not term-mode methods.

### Proven Pattern in Codebase

- **Soundness.lean line 282**: Uses `by_cases` for classical case analysis
- **Truth.lean lines 789-825**: Uses nested `by_cases` for complex case splits
- Both files successfully use `by_cases` in similar contexts

### Could We Use rcases Instead?

Yes, `rcases Classical.em P` would also work, but `by_cases h : P` is more concise and idiomatic for simple binary case splits. The `rcases` pattern is better for destructuring complex data types with multiple constructors.

### Alternative: Rewrite to Term Mode?

We could rewrite the entire function to use term mode, but this would be a major refactoring with higher risk and no benefit. The current tactic-mode approach is clear and maintainable - we just need to use the right tactic syntax.

---

## Dependencies

### Prerequisites
- None (research complete, fix is straightforward)

### Blocked By
- None

### Blocks
- Task 173 (Implement integration tests) - blocked by this build error
- Task 185 (Fix integration test helper API mismatches) - depends on 183 completion

---

## Code Examples

### Before (Line 256)
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    -- Check if A ∈ Γ''
    (em (A ∈ Γ'')).elim
      (fun hA' =>
        -- A ∈ Γ'', recurse on h1
        have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
          deduction_with_mem Γ'' A ψ h1 hA'
        ...
      (fun hA' =>
        -- A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
        ...
```

### After (Line 256)
```lean
| DerivationTree.weakening Γ'' _ ψ h1 h2 =>
    -- Classical case analysis: either A ∈ Γ'' or A ∉ Γ''
    by_cases hA' : A ∈ Γ''
    · -- Case: A ∈ Γ'', recurse on h1
      have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
        deduction_with_mem Γ'' A ψ h1 hA'
      ...
    · -- Case: A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
      ...
```

### Before (Lines 369-376, Nested)
```lean
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    -- Subcase 1: Check if Γ' = A :: Γ
    (em (Γ' = A :: Γ)).elim
      (fun h_eq =>
        deduction_theorem Γ A φ (h_eq ▸ h1))
      (fun h_eq =>
        -- Subcase 2: Check if A ∈ Γ'
        (em (A ∈ Γ')).elim
          (fun hA =>
            ...
          (fun hA =>
            ...
```

### After (Lines 369-376, Nested)
```lean
| DerivationTree.weakening Γ' _ φ h1 h2 =>
    -- Classical case analysis: check if Γ' = A :: Γ
    by_cases h_eq : Γ' = A :: Γ
    · -- Case: Γ' = A :: Γ, recurse directly
      deduction_theorem Γ A φ (h_eq ▸ h1)
    · -- Case: Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
      -- Nested case analysis: check if A ∈ Γ'
      by_cases hA : A ∈ Γ'
      · -- Case: A ∈ Γ' but Γ' ≠ A :: Γ
        ...
      · -- Case: A ∉ Γ', so φ is derivable from Γ' without using A
        ...
```

---

## Implementation Checklist

- [x] Phase 1: Apply all fixes and validate (30 minutes) ✅ COMPLETED 2025-12-28
  - [x] Fix line 256 (deduction_with_mem weakening case) - Applied at line 260
  - [x] Fix line 369 (deduction_theorem outer case) - Applied at line 372
  - [x] Fix line 376 (deduction_theorem inner case) - Applied at line 378
  - [x] Build DeductionTheorem.lean (`lake build Logos.Core.Metalogic.DeductionTheorem`) - 0 errors
  - [x] Build all metalogic modules (`lake build Logos.Core.Metalogic`) - 0 errors
  - [x] Run metalogic tests (`lake exe test`) - All tests pass
  - [x] Verify task 173 unblocked (integration tests can compile) - Verified (DeductionTheorem no longer blocking)
  - [x] Git commit changes - Commits: 9379b5d, 68e2f99
  - [x] Update TODO.md status to [COMPLETED] - Updated
  - [x] Update state.json with completion timestamp - Updated

---

## References

- **Research Report**: `.opencode/specs/183_deduction_theorem_build_errors/reports/research-001.md`
- **Research Summary**: `.opencode/specs/183_deduction_theorem_build_errors/summaries/research-summary.md`
- **Previous Plan**: `.opencode/specs/183_deduction_theorem_build_errors/plans/implementation-001.md`
- **Source File**: `Logos/Core/Metalogic/DeductionTheorem.lean`
- **Proven Patterns**:
  - `Logos/Core/Metalogic/Soundness.lean` (line 282)
  - `Logos/Core/Semantics/Truth.lean` (lines 789-825)
- **Lean Documentation**: [Tactics in Lean 4](https://lean-lang.org/theorem_proving_in_lean4/tactics.html)

---

**Plan Ready**: 2025-12-28  
**Plan Status**: COMPLETED 2025-12-28  
**Implementation Summary**: [.opencode/specs/183_deduction_theorem_build_errors/summaries/implementation-summary-20251228.md]

---

## Implementation Completion

**Completed**: 2025-12-28  
**Status**: All phases completed successfully ✅

All 3 build errors in DeductionTheorem.lean have been fixed and verified:
- Line 260: `by_cases hA' : A ∈ Γ''` (was line 256)
- Line 372: `by_cases h_eq : Γ' = A :: Γ` (was line 369)
- Line 378: `by_cases hA : A ∈ Γ'` (was line 376)

Build verification:
- `lake build Logos.Core.Metalogic.DeductionTheorem` - **0 errors**
- `lake build Logos.Core.Metalogic` - **0 errors** (only Mathlib warnings)
- All existing tests pass without regressions

Git commits:
- 9379b5d: Marked task 183 as completed with status updates
- 68e2f99: Added comprehensive implementation summary

Task 183 marked [COMPLETED] in TODO.md and moved to completed_projects in state.json.

---

## Revision History

| Version | Date | Changes | Reason |
|---------|------|---------|--------|
| 001 | 2025-12-25 | Initial plan | Created from research findings |
| 002 | 2025-12-28 | Revised plan | Applied lessons from task 192's clean structure and educational approach |

### Changes in Version 002

**Improvements from Task 192 Pattern**:
1. **Simplified Phase Structure**: Consolidated 4 phases into 1 phase (all fixes are related and should be done together)
2. **Added "Why by_cases?" Educational Section**: Explains term mode vs tactic mode, proven patterns, and alternatives
3. **Improved Risk Assessment**: Concise bullet-point format with overall risk level upfront
4. **Streamlined Metadata**: Clean format matching task 192 (complexity, estimated hours, phases)
5. **Enhanced Code Examples**: Clear before/after examples for all 3 fixes
6. **Cleaner Structure**: Removed repetitive verification steps, consolidated into single verification section

**Preserved from Version 001**:
1. **Excellent Research Integration**: Kept comprehensive research findings and recommendations
2. **Detailed Code Examples**: Preserved helpful before/after code snippets
3. **Proven Pattern References**: Kept references to Soundness.lean and Truth.lean
4. **Comprehensive Acceptance Criteria**: Maintained thorough success criteria

**Result**: A plan that is both comprehensive (from v001) and approachable (from task 192), serving as a reference-quality implementation guide.

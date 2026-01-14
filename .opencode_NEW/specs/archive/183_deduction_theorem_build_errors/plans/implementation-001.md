# Implementation Plan: Fix DeductionTheorem.lean Build Errors

**Status**: [IN PROGRESS]  
**Project**: #183  
**Version**: 001  
**Date**: 2025-12-25  
**Started**: 2025-12-25  
**Complexity**: Simple  
**Language**: lean

## Metadata

```yaml
project_number: 183
project_name: deduction_theorem_build_errors
plan_version: 1
created: 2025-12-25
estimated_effort: 30-45 minutes
complexity: simple
language: lean
priority: high
blocks: [173]
```

## Research Inputs

This implementation plan is based on comprehensive research completed on 2025-12-26:

- **Main Research Report**: `.opencode/specs/183_deduction_theorem_build_errors/reports/research-001.md`
- **Research Summary**: `.opencode/specs/183_deduction_theorem_build_errors/summaries/research-summary.md`

**Key Research Findings**:
- Root cause: All 3 errors stem from using `(em P).elim` pattern inside `match` expressions
- The `.elim` method is a term-mode construct, not a tactic, causing "unknown tactic" errors
- Solution: Replace with `by_cases h : P` tactic (proven pattern in Soundness.lean and Truth.lean)
- Termination proofs are correct and will work once tactic errors are fixed
- No semantic changes required—purely syntactic conversion

## Overview

### Goals

1. Fix all 3 build errors in DeductionTheorem.lean by replacing term-mode `.elim` patterns with `by_cases` tactic
2. Unblock compilation of all test files, particularly the 106 new integration tests from task 173
3. Verify no regressions in existing metalogic tests
4. Ensure the deduction theorem logic remains semantically identical

### Scope

**In Scope**:
- Replace `(em P).elim` with `by_cases h : P` at lines 256, 369, and 376
- Update case branch formatting to use `·` bullet points
- Remove closing parentheses from converted patterns
- Verify build succeeds and termination proofs work
- Run existing metalogic tests to ensure no regressions

**Out of Scope**:
- Semantic changes to deduction theorem logic
- Refactoring other parts of DeductionTheorem.lean
- Fixing other build errors (Truth.lean error is task 184)
- Implementing new features or optimizations

### Success Criteria

- [ ] All 3 build errors in DeductionTheorem.lean are resolved
- [ ] `lake build Logos.Core.Metalogic.DeductionTheorem` succeeds
- [ ] No new errors introduced in dependent modules
- [ ] Existing metalogic tests pass without regressions
- [ ] Code follows Lean 4 style guide (bullet points, indentation)
- [ ] Integration tests from task 173 can now compile (verification in task 173)

## Complexity Assessment

**Level**: Simple  
**Estimated Effort**: 30-45 minutes (including build verification)  
**Required Knowledge**: 
- Basic Lean 4 tactic syntax (`by_cases` vs term-mode `.elim`)
- Understanding of classical logic patterns in Lean
- Familiarity with bullet-point proof structure (`·`)

**Potential Challenges**:
- Correct bullet-point indentation for case branches
- Removing closing parentheses after tactic conversion
- Ensuring hypothesis names match usage in branches

**Risk Assessment**: Low (purely syntactic changes with proven pattern)

## Technology Stack

**Languages**: Lean 4  
**Frameworks**: Lean 4 standard library, Classical logic module  
**Tools**: Lake build system  
**Dependencies**: 
- Logos.Core.ProofSystem.Derivation (already imported)
- Logos.Core.Theorems.Combinators (already imported)
- Classical module (already opened at line 39)

## Dependencies

### Required Modules/Packages

No new imports required. The file already has:
```lean
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Theorems.Combinators

open Classical
```

The `by_cases` tactic is available from the Classical module.

### Prerequisites

None. The fix is purely syntactic and can be implemented immediately.

### External Libraries

None. All required functionality is in Lean 4 standard library and existing Logos modules.

### Dependent Components

**Direct Dependents** (will need recompilation):
- `Logos.Core.Theorems.Propositional` (uses deduction_theorem for ECQ, RAA, contraposition)
- `Logos.Core.Theorems.GeneralizedNecessitation` (uses deduction_theorem for modal/temporal K rules)

**Transitive Dependents**:
- `Logos.Core.Theorems.ModalS4`
- `Logos.Core.Theorems.ModalS5`
- `Logos.Core.Theorems.Perpetuity`
- `Logos.Core.Metalogic.Soundness` (uses Propositional theorems)

**Test Files** (blocked by this fix):
- All 9 LogosTest files that import metalogic modules
- Particularly task 173 integration tests: BimodalIntegrationTest, TemporalIntegrationTest, EndToEndTest

## Implementation Steps

### Phase 1: Fix Line 256 Error (deduction_with_mem weakening case)

**Objective**: Replace first `.elim` pattern with `by_cases` tactic

**File**: `Logos/Core/Metalogic/DeductionTheorem.lean`

**Actions**:

1. **Locate the error** (line 256):
   ```lean
   | DerivationTree.weakening Γ'' _ ψ h1 h2 =>
       -- Check if A ∈ Γ''
       (em (A ∈ Γ'')).elim
         (fun hA' =>
           -- A ∈ Γ'', recurse on h1
           ...
   ```

2. **Replace with by_cases**:
   ```lean
   | DerivationTree.weakening Γ'' _ ψ h1 h2 =>
       -- Classical case analysis: either A ∈ Γ'' or A ∉ Γ''
       by_cases hA' : A ∈ Γ''
       · -- Case: A ∈ Γ'', recurse on h1
         have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
           deduction_with_mem Γ'' A ψ h1 hA'
         -- Weaken to removeAll Γ' A
         have h_sub : removeAll Γ'' A ⊆ removeAll Γ' A := by
           intro x hx
           unfold removeAll at hx ⊢
           simp [List.filter] at hx ⊢
           exact ⟨h2 hx.1, hx.2⟩
         DerivationTree.weakening (removeAll Γ'' A) (removeAll Γ' A) (A.imp ψ) ih h_sub
       · -- Case: A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
         have h_sub : Γ'' ⊆ removeAll Γ' A := by
           intro x hx
           unfold removeAll
           simp [List.filter]
           exact ⟨h2 hx, by
             intro h_eq
             subst h_eq
             exact absurd hx hA'⟩
         -- Γ'' ⊢ ψ and Γ'' ⊆ removeAll Γ' A
         have h_weak : (removeAll Γ' A) ⊢ ψ :=
           DerivationTree.weakening Γ'' (removeAll Γ' A) ψ h1 h_sub
         -- Use S axiom
         have s_ax : ⊢ ψ.imp (A.imp ψ) :=
           DerivationTree.axiom [] _ (Axiom.prop_s ψ A)
         have s_weak : (removeAll Γ' A) ⊢ ψ.imp (A.imp ψ) :=
           DerivationTree.weakening [] (removeAll Γ' A) _ s_ax (List.nil_subset _)
         DerivationTree.modus_ponens (removeAll Γ' A) ψ (A.imp ψ) s_weak h_weak
   ```

3. **Key changes**:
   - Replace `(em (A ∈ Γ'')).elim` with `by_cases hA' : A ∈ Γ''`
   - Replace `(fun hA' =>` with `· -- Case: A ∈ Γ''`
   - Replace `(fun hA' =>` (second branch) with `· -- Case: A ∉ Γ''`
   - Remove closing parentheses `)` at end of each branch
   - Add explanatory comment about classical case analysis

**Verification**:
- Syntax is correct (bullet points aligned, no unmatched parentheses)
- Hypothesis name `hA'` matches usage in both branches
- Logic is semantically identical to original

**Time Estimate**: 5-10 minutes

**Success Criteria**:
- [ ] Line 256 error replaced with `by_cases` pattern
- [ ] Bullet points properly formatted
- [ ] No syntax errors in this case

---

### Phase 2: Fix Line 369 Error (deduction_theorem outer case)

**Objective**: Replace outer `.elim` pattern in deduction_theorem weakening case

**File**: `Logos/Core/Metalogic/DeductionTheorem.lean`

**Actions**:

1. **Locate the error** (line 369):
   ```lean
   | DerivationTree.weakening Γ' _ φ h1 h2 =>
       -- Subcase 1: Check if Γ' = A :: Γ
       (em (Γ' = A :: Γ)).elim
         (fun h_eq =>
           deduction_theorem Γ A φ (h_eq ▸ h1))
         (fun h_eq =>
           -- Subcase 2: Check if A ∈ Γ'
           (em (A ∈ Γ')).elim
             ...
   ```

2. **Replace outer .elim with by_cases**:
   ```lean
   | DerivationTree.weakening Γ' _ φ h1 h2 =>
       -- Classical case analysis: check if Γ' = A :: Γ
       by_cases h_eq : Γ' = A :: Γ
       · -- Case: Γ' = A :: Γ, recurse directly
         deduction_theorem Γ A φ (h_eq ▸ h1)
       · -- Case: Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
         -- Nested case analysis: check if A ∈ Γ'
         (em (A ∈ Γ')).elim
           (fun hA =>
             ...
   ```

3. **Key changes**:
   - Replace `(em (Γ' = A :: Γ)).elim` with `by_cases h_eq : Γ' = A :: Γ`
   - Replace `(fun h_eq =>` with `· -- Case: Γ' = A :: Γ`
   - Replace second `(fun h_eq =>` with `· -- Case: Γ' ≠ A :: Γ`
   - Remove closing parenthesis after first branch
   - Keep inner `.elim` for now (will fix in Phase 3)

**Verification**:
- Outer case split uses `by_cases` correctly
- Inner `.elim` remains unchanged (temporary)
- Hypothesis name `h_eq` matches usage in first branch

**Time Estimate**: 5-10 minutes

**Success Criteria**:
- [ ] Line 369 outer error replaced with `by_cases` pattern
- [ ] First branch (Γ' = A :: Γ) works correctly
- [ ] Second branch still has inner `.elim` (to be fixed in Phase 3)

---

### Phase 3: Fix Line 376 Error (deduction_theorem inner case)

**Objective**: Replace inner `.elim` pattern in deduction_theorem weakening case

**File**: `Logos/Core/Metalogic/DeductionTheorem.lean`

**Actions**:

1. **Locate the inner error** (line 376, inside second branch from Phase 2):
   ```lean
   · -- Case: Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
     -- Nested case analysis: check if A ∈ Γ'
     (em (A ∈ Γ')).elim
       (fun hA =>
         -- A ∈ Γ' but Γ' ≠ A :: Γ
         have ih : removeAll Γ' A ⊢ A.imp φ :=
           deduction_with_mem Γ' A φ h1 hA
         ...
       (fun hA =>
         -- A ∉ Γ', so φ is derivable from Γ' without using A
         ...
   ```

2. **Replace inner .elim with by_cases**:
   ```lean
   · -- Case: Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
     -- Nested case analysis: check if A ∈ Γ'
     by_cases hA : A ∈ Γ'
     · -- Case: A ∈ Γ' but Γ' ≠ A :: Γ
       have ih : removeAll Γ' A ⊢ A.imp φ :=
         deduction_with_mem Γ' A φ h1 hA
       -- Weaken to Γ
       have h_sub : removeAll Γ' A ⊆ Γ :=
         removeAll_subset hA h2
       DerivationTree.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub
     · -- Case: A ∉ Γ', so φ is derivable from Γ' without using A
       have h_sub : Γ' ⊆ Γ := by
         intro x hx
         have := h2 hx
         simp at this
         cases this with
         | inl h_eq_x =>
           -- x = A, but A ∉ Γ', contradiction
           subst h_eq_x
           exact absurd hx hA
         | inr h_mem => exact h_mem
       -- Now Γ' ⊢ φ and Γ' ⊆ Γ, so Γ ⊢ φ
       have h_weak : Γ ⊢ φ := DerivationTree.weakening Γ' Γ φ h1 h_sub
       -- Use S axiom to get Γ ⊢ A → φ
       have s_ax : ⊢ φ.imp (A.imp φ) :=
         DerivationTree.axiom [] _ (Axiom.prop_s φ A)
       have s_weak : Γ ⊢ φ.imp (A.imp φ) :=
         DerivationTree.weakening [] Γ _ s_ax (List.nil_subset Γ)
       DerivationTree.modus_ponens Γ φ (A.imp φ) s_weak h_weak
   ```

3. **Key changes**:
   - Replace `(em (A ∈ Γ')).elim` with `by_cases hA : A ∈ Γ'`
   - Replace `(fun hA =>` with `· -- Case: A ∈ Γ'`
   - Replace second `(fun hA =>` with `· -- Case: A ∉ Γ'`
   - Remove closing parentheses at end of both branches
   - Ensure nested bullet points are properly indented

**Verification**:
- Nested `by_cases` is properly indented inside outer bullet point
- Hypothesis name `hA` matches usage in both branches
- All closing parentheses removed correctly
- Logic is semantically identical to original

**Time Estimate**: 5-10 minutes

**Success Criteria**:
- [ ] Line 376 inner error replaced with `by_cases` pattern
- [ ] Nested bullet points properly formatted
- [ ] All 3 errors now fixed

---

### Phase 4: Build Verification and Testing

**Objective**: Verify all errors are resolved and no regressions introduced

**Actions**:

1. **Build DeductionTheorem.lean**:
   ```bash
   lake build Logos.Core.Metalogic.DeductionTheorem
   ```
   
   **Expected**: Build succeeds with no errors

2. **Verify termination proofs**:
   - Check that `decreasing_by` clauses compile without errors
   - Termination proofs should work as-is (no changes needed)

3. **Build dependent modules**:
   ```bash
   lake build Logos.Core.Theorems.Propositional
   lake build Logos.Core.Theorems.GeneralizedNecessitation
   ```
   
   **Expected**: Both build successfully

4. **Build all metalogic modules**:
   ```bash
   lake build Logos.Core.Metalogic
   ```
   
   **Expected**: All metalogic modules compile

5. **Run existing metalogic tests**:
   ```bash
   lake build LogosTest.Metalogic
   ```
   
   **Expected**: All existing tests pass without regressions

6. **Verify integration tests can now compile** (task 173 verification):
   ```bash
   lake build LogosTest.Core.Integration.BimodalIntegrationTest
   lake build LogosTest.Core.Integration.TemporalIntegrationTest
   lake build LogosTest.Core.Integration.EndToEndTest
   ```
   
   **Expected**: Integration tests compile (may have other errors from task 173, but DeductionTheorem errors should be gone)

**Verification Checklist**:
- [ ] `lake build Logos.Core.Metalogic.DeductionTheorem` succeeds
- [ ] No "unknown tactic" errors at lines 256, 369, 376
- [ ] Termination proofs compile without errors
- [ ] Dependent modules (Propositional, GeneralizedNecessitation) build
- [ ] All metalogic modules build successfully
- [ ] Existing metalogic tests pass
- [ ] Integration tests from task 173 can compile

**Time Estimate**: 10-15 minutes (including build time)

**Success Criteria**:
- [ ] All build commands succeed
- [ ] No new errors introduced
- [ ] Existing tests pass
- [ ] Task 173 is unblocked (integration tests can compile)

---

## File Structure

```
Logos/Core/Metalogic/
├── DeductionTheorem.lean  (MODIFIED - 3 replacements)
├── Soundness.lean         (unchanged - reference for by_cases pattern)
├── Completeness.lean      (unchanged)
└── ...

LogosTest/Core/
├── Metalogic/
│   ├── SoundnessTest.lean      (run to verify no regressions)
│   └── CompletenessTest.lean   (run to verify no regressions)
└── Integration/
    ├── BimodalIntegrationTest.lean   (should now compile)
    ├── TemporalIntegrationTest.lean  (should now compile)
    └── EndToEndTest.lean             (should now compile)
```

## Testing Strategy

### Unit Tests

**Existing Tests**: Run existing metalogic tests to ensure no regressions
- `LogosTest.Metalogic.SoundnessTest`
- `LogosTest.Metalogic.CompletenessTest`

**Expected**: All existing tests pass without changes

### Integration Tests

**Task 173 Tests**: Verify integration tests can now compile
- `LogosTest.Core.Integration.BimodalIntegrationTest`
- `LogosTest.Core.Integration.TemporalIntegrationTest`
- `LogosTest.Core.Integration.EndToEndTest`

**Expected**: Tests compile (may have other errors from task 173, but DeductionTheorem errors should be resolved)

### Build Tests

**Module Builds**: Verify all dependent modules compile
- `Logos.Core.Metalogic.DeductionTheorem`
- `Logos.Core.Theorems.Propositional`
- `Logos.Core.Theorems.GeneralizedNecessitation`
- `Logos.Core.Metalogic` (all metalogic modules)

**Expected**: All modules build successfully

### Test Coverage

**Coverage Goals**: 
- 100% of changed code (3 case splits) verified by existing tests
- No new test coverage needed (purely syntactic changes)
- Existing deduction theorem tests provide full coverage

## Verification Checkpoints

- [x] Research completed and solution validated
- [ ] Phase 1: Line 256 error fixed
- [ ] Phase 2: Line 369 error fixed
- [ ] Phase 3: Line 376 error fixed
- [ ] Phase 4: Build verification passed
- [ ] All 3 errors resolved
- [ ] No new errors introduced
- [ ] Existing tests pass
- [ ] Task 173 unblocked

## Documentation Requirements

### Code Documentation

- Add brief comments explaining classical case analysis:
  ```lean
  -- Classical case analysis: either A ∈ Γ'' or A ∉ Γ''
  by_cases hA' : A ∈ Γ''
  ```

- Ensure case branches have clear comments:
  ```lean
  · -- Case: A ∈ Γ'', recurse on h1
  · -- Case: A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
  ```

### Update Registries

**SORRY_REGISTRY.md**: No changes needed (no sorrys added or removed)

**IMPLEMENTATION_STATUS.md**: Update status for task 183:
```markdown
| 183 | Fix DeductionTheorem.lean build errors | COMPLETED | 2025-12-25 | All 3 errors fixed using by_cases tactic |
```

**TACTIC_REGISTRY.md**: No changes needed (no new tactics added)

### Optional Documentation

Consider documenting classical reasoning patterns in LEAN_STYLE_GUIDE.md:
- When to use `by_cases` vs `rcases Classical.em` vs `.elim`
- Bullet-point formatting for case splits
- Classical reasoning in tactic mode vs term mode

## Success Criteria

### Primary Criteria

1. **All 3 build errors resolved**: Lines 256, 369, 376 no longer produce "unknown tactic" errors
2. **Build succeeds**: `lake build Logos.Core.Metalogic.DeductionTheorem` completes without errors
3. **No regressions**: Existing metalogic tests pass without changes
4. **Task 173 unblocked**: Integration tests can now compile

### Secondary Criteria

1. **Code quality**: Follows Lean 4 style guide (bullet points, indentation, comments)
2. **Semantic equivalence**: Logic is identical to original (only syntax changed)
3. **Termination proofs work**: No changes needed to `decreasing_by` clauses
4. **Dependent modules build**: Propositional and GeneralizedNecessitation compile

### Quality Metrics

- **Build time**: Should be similar to before (no performance impact)
- **Code readability**: `by_cases` is more idiomatic than `.elim` in tactic mode
- **Maintainability**: Follows proven patterns from Soundness.lean and Truth.lean

## Related Research

**Research Report**: `.opencode/specs/183_deduction_theorem_build_errors/reports/research-001.md`

**Key Sections**:
- Error Analysis (lines 30-136): Detailed breakdown of all 3 errors
- Key Findings (lines 138-299): Classical reasoning patterns in Lean 4
- Code Examples (lines 374-561): Before/after code for all 3 fixes
- Recommended Solution (lines 599-627): Rationale for using `by_cases`

**Research Summary**: `.opencode/specs/183_deduction_theorem_build_errors/summaries/research-summary.md`

**Proven Patterns**:
- Soundness.lean line 282: `by_cases` pattern
- Truth.lean lines 789-825: Nested `by_cases` pattern
- mathlib4 CategoryTheory: `rcases Classical.em` pattern

## Notes

### Implementation Notes

1. **Purely Syntactic**: This fix changes only syntax, not semantics
2. **Proven Pattern**: `by_cases` is the idiomatic Lean 4 pattern for classical case analysis
3. **No Logic Changes**: The deduction theorem logic remains identical
4. **Termination Proofs**: Already correct, will work once tactic errors fixed

### Risk Mitigation

1. **Low Risk**: Purely syntactic changes with proven pattern
2. **Verification**: Existing tests provide full coverage
3. **Rollback**: Easy to revert if issues arise (3 localized changes)
4. **Dependencies**: No breaking changes to API or semantics

### Future Considerations

1. **Style Guide**: Consider documenting classical reasoning patterns
2. **Other Files**: Check if other files use deprecated `.elim` pattern
3. **Linting**: Add linter rule to catch `.elim` in tactic mode (optional)

## Revision History

| Version | Date | Changes | Reason |
|---------|------|---------|--------|
| 001 | 2025-12-25 | Initial plan | Created from research findings |

---

**Plan Status**: In progress  
**Estimated Total Time**: 30-45 minutes  
**Risk Level**: Low  
**Blocking Tasks**: None  
**Blocked Tasks**: 173 (integration tests)

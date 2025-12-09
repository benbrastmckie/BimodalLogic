# Implementation Plan: Fix Pre-existing Soundness.lean Type Mismatch Errors

## Metadata

- **Plan ID**: 001-soundness-type-mismatch-fix
- **Status**: [COMPLETE]
- **Priority**: Medium
- **Complexity**: 2 (Low - Mechanical fixes)
- **Estimated Hours**: 2-3 hours
- **Actual Hours**: ~1.5 hours
- **Created**: 2025-12-08
- **Completed**: 2025-12-08
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/Soundness.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Overview

Fix the systematic type mismatch errors in Soundness.lean that occur because `intro` patterns don't match the quantifier structure of `semantic_consequence` and `valid` definitions. The fix is mechanical: add `T _` to intro patterns to capture the type parameter and its instance.

## Problem Statement

The `valid` and `semantic_consequence` definitions in Validity.lean quantify over:
```lean
∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
  (τ : WorldHistory F) (t : T) (ht : τ.domain t), ...
```

But Soundness.lean uses intro patterns like:
```lean
intro F M τ t ht ...  -- MISSING: T and instance!
```

This causes `F` to bind to `T`, `M` to bind to the instance, etc., leading to type mismatch errors.

## Research Reports

- [001-mathlib-theorems.md](../reports/001-mathlib-theorems.md) - Mathlib patterns for polymorphic validity
- [002-proof-strategies.md](../reports/002-proof-strategies.md) - Detailed fix strategy per function
- [003-project-structure.md](../reports/003-project-structure.md) - File dependencies and testing

## Dependencies

- dependencies: []
- blocking: None
- blocked_by: None

---

## Phase 1: Fix Axiom Validity Lemmas [COMPLETE]

**Goal**: Update intro patterns in all 12 axiom validity lemmas.

**Strategy**: Mechanical replacement of `intro F M τ t ht` with `intro T _ F M τ t ht`.

### Success Criteria

- [x] `prop_k_valid` (line 84-89) intro pattern fixed
- [x] `prop_s_valid` (line 99-103) intro pattern fixed
- [x] `modal_t_valid` (line 114-120) intro pattern fixed
- [x] `modal_4_valid` (line 133-142) intro pattern fixed
- [x] `modal_b_valid` (line 156-178) intro pattern fixed
- [x] `modal_k_dist_valid` (line 191-201) intro pattern fixed
- [x] `double_negation_valid` (line 211-217) intro pattern fixed
- [x] `temp_4_valid` (line 229-239) intro pattern fixed
- [x] `temp_a_valid` (line 254-289) intro pattern fixed
- [x] `temp_l_valid` (line 311-347) intro pattern fixed
- [x] `modal_future_valid` (line 363-386) intro pattern fixed
- [x] `temp_future_valid` (line 406-429) intro pattern fixed

### Theorems

- [x] `theorem_prop_k_valid`
  - Goal: `⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))`
  - Strategy: Change line 86 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_prop_s_valid`
  - Goal: `⊨ (φ.imp (ψ.imp φ))`
  - Strategy: Change line 100 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_modal_t_valid`
  - Goal: `⊨ (φ.box.imp φ)`
  - Strategy: Change line 115 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_modal_4_valid`
  - Goal: `⊨ ((φ.box).imp (φ.box.box))`
  - Strategy: Change line 134 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_modal_b_valid`
  - Goal: `⊨ (φ.imp (φ.diamond.box))`
  - Strategy: Change line 157 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_modal_k_dist_valid`
  - Goal: `⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box))`
  - Strategy: Change line 193 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_double_negation_valid`
  - Goal: `⊨ (φ.neg.neg.imp φ)`
  - Strategy: Change line 212 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple

- [x] `theorem_temp_4_valid`
  - Goal: `⊨ ((φ.all_future).imp (φ.all_future.all_future))`
  - Strategy: Change line 230 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple
  - Note: Also fixed `.future` → `.all_future` in goal

- [x] `theorem_temp_a_valid`
  - Goal: `⊨ (φ.imp (Formula.all_future φ.sometime_past))`
  - Strategy: Change line 255 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple
  - Note: Also fixed `unfold` to include `Formula.some_past`

- [x] `theorem_temp_l_valid`
  - Goal: `⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ)))`
  - Strategy: Change line 312 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple
  - Note: Also fixed `Int` → `T` type annotations and `Int.lt_trichotomy` → `lt_trichotomy`

- [x] `theorem_modal_future_valid`
  - Goal: `⊨ ((φ.box).imp ((φ.all_future).box))`
  - Strategy: Change line 364 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple
  - Note: Also fixed `omega` → `add_sub_cancel t s`

- [x] `theorem_temp_future_valid`
  - Goal: `⊨ ((φ.box).imp ((φ.box).all_future))`
  - Strategy: Change line 407 from `intro F M τ t ht` to `intro T _ F M τ t ht`
  - Complexity: Simple
  - Note: Also fixed `omega` → `add_sub_cancel t s`

### Verification

```bash
lake env lean Logos/Core/Metalogic/Soundness.lean 2>&1 | head -50
# PASSED - No errors from axiom lemmas
```

---

## Phase 2: Fix Soundness Theorem - Intro Patterns [COMPLETE]

**Goal**: Update intro patterns in all 8 soundness theorem cases.

**Strategy**: Add `T _` to each case's intro pattern.

### Success Criteria

- [x] `axiom` case (line 469-473) intro pattern fixed
- [x] `assumption` case (line 475-479) intro pattern fixed
- [x] `modus_ponens` case (line 481-489) intro pattern fixed
- [x] `necessitation` case (line 491-502) intro pattern fixed
- [x] `modal_k` case (line 504-534) intro pattern fixed
- [x] `temporal_k` case (line 536-566) intro pattern fixed
- [x] `temporal_duality` case (line 568-594) intro pattern fixed
- [x] `weakening` case (line 596-603) intro pattern fixed

### Theorems

- [x] `theorem_soundness_axiom_case`
  - Goal: Fix intro pattern for axiom case
  - Strategy: Change line 472 from `intro F M τ t ht _` to `intro T _ F M τ t ht _`
  - Complexity: Simple

- [x] `theorem_soundness_assumption_case`
  - Goal: Fix intro pattern for assumption case
  - Strategy: Change line 478 from `intro F M τ t ht h_all` to `intro T _ F M τ t ht h_all`
  - Complexity: Simple

- [x] `theorem_soundness_modus_ponens_case`
  - Goal: Fix intro pattern for modus_ponens case
  - Strategy: Change line 485 from `intro F M τ t ht h_all` to `intro T _ F M τ t ht h_all`
  - Complexity: Simple

- [x] `theorem_soundness_necessitation_case`
  - Goal: Fix intro pattern for necessitation case
  - Strategy: Change line 495 from `intro F M τ t ht _` to `intro T _ F M τ t ht _`
  - Complexity: Simple

- [x] `theorem_soundness_modal_k_case`
  - Goal: Fix intro pattern for modal_k case
  - Strategy: Change line 518 from `intro F M τ t ht h_all_box_gamma` to `intro T _ F M τ t ht h_all_box_gamma`
  - Complexity: Simple

- [x] `theorem_soundness_temporal_k_case`
  - Goal: Fix intro pattern for temporal_k case
  - Strategy: Change line 550 from `intro F M τ t ht h_all_future_gamma` to `intro T _ F M τ t ht h_all_future_gamma`
  - Complexity: Simple

- [x] `theorem_soundness_temporal_duality_case`
  - Goal: Fix intro pattern for temporal_duality case
  - Strategy: Change line 588 from `intro F M τ t ht _` to `intro T _ F M τ t ht _`
  - Complexity: Simple

- [x] `theorem_soundness_weakening_case`
  - Goal: Fix intro pattern for weakening case
  - Strategy: Change line 600 from `intro F M τ t ht h_all` to `intro T _ F M τ t ht h_all`
  - Complexity: Simple

### Verification

```bash
lake env lean Logos/Core/Metalogic/Soundness.lean 2>&1 | head -50
# PASSED - No errors from soundness theorem cases
```

---

## Phase 3: Fix Function and IH Call Sites [COMPLETE]

**Goal**: Update function applications and induction hypothesis calls to include `T` argument.

**Strategy**: Add `T` or `_` before `F` in function/IH calls.

### Success Criteria

- [x] `axiom_valid` call in soundness axiom case (line 473) fixed
- [x] `ih_imp` and `ih_phi` calls in modus_ponens case (lines 486-487) fixed
- [x] `ih` call in necessitation case (line 501) fixed
- [x] `ih` call in modal_k case (line 525) fixed
- [x] `ih` call in temporal_k case (line 557) fixed
- [x] `ih` call in weakening case (line 601) fixed

### Theorems

- [x] `theorem_fix_axiom_valid_call`
  - Goal: Fix `axiom_valid h_ax F M τ t ht` call
  - Strategy: Changed to `axiom_valid h_ax T F M τ t ht`
  - Complexity: Simple

- [x] `theorem_fix_modus_ponens_ih_calls`
  - Goal: Fix `ih_imp F M τ t ht h_all` and `ih_phi F M τ t ht h_all` calls
  - Strategy: Added `T` argument before F
  - Complexity: Simple

- [x] `theorem_fix_necessitation_ih_call`
  - Goal: Fix `ih F M σ t hs` call
  - Strategy: Added `T` argument before F
  - Complexity: Simple

- [x] `theorem_fix_modal_k_ih_call`
  - Goal: Fix `ih F M σ t hs` call
  - Strategy: Added `T` argument before F
  - Complexity: Simple
  - Note: Also fixed `List.mem_map_of_mem` → `Context.mem_map_of_mem`

- [x] `theorem_fix_temporal_k_ih_call`
  - Goal: Fix `ih F M τ s hs` call
  - Strategy: Added `T` argument before F
  - Complexity: Simple
  - Note: Also fixed `List.mem_map_of_mem` → `Context.mem_map_of_mem`

- [x] `theorem_fix_weakening_ih_call`
  - Goal: Fix `ih F M τ t ht` call
  - Strategy: Added `T` argument before F
  - Complexity: Simple

### Additional Fixes Required

- [x] Added `Context.mem_map_of_mem` lemma to Context.lean (Context.map is custom, not List.map)
- [x] Fixed `derivable_implies_swap_valid` call with explicit type: `@Semantics.TemporalDuality.derivable_implies_swap_valid T _ _ h_deriv_phi`

### Verification

```bash
lake env lean Logos/Core/Metalogic/Soundness.lean 2>&1
# PASSED - No errors
```

---

## Phase 4: Build and Test [COMPLETE]

**Goal**: Verify full project builds and tests pass.

### Success Criteria

- [x] `lake build Logos.Core.Metalogic.Soundness` succeeds with no errors
- [ ] `lake test` passes all tests (pre-existing test failures unrelated to this fix)
- [x] No new warnings introduced

### Verification Commands

```bash
# Soundness module build
lake build Logos.Core.Metalogic.Soundness
# PASSED - Build completed successfully

# Full build has pre-existing issues in test files (Formula.future → Formula.all_future)
# Not in scope for this fix
```

### Notes

Pre-existing test failures in:
- `AxiomsTest.lean` - Uses `Formula.future` (should be `Formula.all_future`)
- `DerivationTest.lean` - Has similar intro pattern issues
- `PerpetuityTest.lean` - Uses `Formula.future`

These are not caused by this fix and require a separate task.

---

## Phase 5: Update Documentation [COMPLETE]

**Goal**: Update project status files to reflect Task 17 completion.

### Success Criteria

- [ ] TODO.md updated - Task 17 marked complete (deferred - run /todo)
- [ ] IMPLEMENTATION_STATUS.md updated - Soundness.lean status corrected (deferred)
- [x] Implementation summary created in specs directory

### Files Updated

1. **Implementation Summary**
   - Created: `.claude/specs/046_soundness_type_mismatch_fix/summaries/001-implementation-summary.md`

2. **LogosTest/Core/Metalogic/SoundnessTest.lean**
   - Fixed test intro pattern (line 113): `intro F M τ t ht` → `intro T _ F M τ t ht`

3. **Logos/Core/Syntax/Context.lean**
   - Added `map_eq_list_map` lemma
   - Added `mem_map_iff` lemma
   - Added `mem_map_of_mem` lemma

---

## Risk Assessment

### Low Risk Items
- All fixes are mechanical intro pattern changes
- No logic changes to proofs
- No API changes

### Potential Complications
- Some proofs may need additional adjustments if they rely on specific variable names
- Time-shift proofs (modal_future_valid, temp_future_valid) have complex structures

### Mitigation
- Apply fixes incrementally, testing after each phase
- If a proof breaks unexpectedly, revert and analyze before proceeding

## Notes

- The `_` syntax for instance parameters works because Lean can infer `LinearOrderedAddCommGroup T` from context
- Using `T` explicitly (vs `_`) is preferred when the type is used later in the proof
- The proof bodies don't need changes - only the intro patterns and call sites
- Additional fixes were needed for:
  - `Int`-specific lemmas → generic lemmas (`lt_trans`, `lt_trichotomy`, `add_sub_cancel`)
  - Type annotations `(u : Int)` → `(u : T)`
  - `Context.map` vs `List.map` membership lemmas

## Completion Summary

**Files Modified**: 3
- `Logos/Core/Metalogic/Soundness.lean` - 20+ intro pattern fixes, proof body fixes
- `Logos/Core/Syntax/Context.lean` - 3 new lemmas for Context.map
- `LogosTest/Core/Metalogic/SoundnessTest.lean` - 1 test intro pattern fix

**Build Status**: `lake build Logos.Core.Metalogic.Soundness` - SUCCESS

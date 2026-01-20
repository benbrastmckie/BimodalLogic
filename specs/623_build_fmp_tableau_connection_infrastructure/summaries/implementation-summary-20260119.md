# Implementation Summary: Task #623

**Task**: Build FMP-tableau connection infrastructure
**Status**: Partial (Phase 1 of 6 complete, Phase 2 in progress)
**Updated**: 2026-01-19
**Session ID**: sess_1768866353_ab089c

## Status

Phase 1 (expansion_decreases_measure) was completed in a prior session. Phase 2 (branchTruthLemma) implementation was attempted but introduced compilation errors and was reverted to a working state.

## Current State

### Saturation.lean
- **Status**: Complete (prior session)
- No sorries remain
- BEq lemmas for SignedFormula added and working

### CountermodelExtraction.lean
- **Status**: In Progress
- Current sorries:
  - Line 193: `saturated_imp_expanded` - vacuously true because T(φ→ψ) cannot be in saturated branch
  - Line 217: `branchTruthLemma` - main truth lemma requiring structural induction
- Prior attempt to complete these introduced errors and was reverted

### Correctness.lean
- **Status**: Not Started
- Current sorries:
  - Line 114: `tableau_complete`
  - Line 163: `decide_complete`
  - Line 295: `decide_axiom_valid`

## Technical Analysis

### Phase 2 Challenge: branchTruthLemma

The attempted implementation revealed structural issues:

1. **`native_decide` limitation**: Theorems like `isExpanded_impPos_false` cannot use `native_decide` because `isExpanded` involves pattern matching on signed formula structures that are not fully decidable at compile time.

2. **Structure equality**: Using `cases sf` followed by `simp only [SignedFormula.sign, SignedFormula.formula]` fails because these are field accessors, not simp lemmas. Need explicit `ext` or manual unpacking.

3. **BEq vs Eq**: String equality (`(p == q) = true`) requires explicit conversion to propositional equality via `beq_iff_eq` or similar.

### Recommended Approach for Phase 2

1. First prove helper lemmas about `isExpanded`:
   - For each compound formula type, prove `isExpanded (SignedFormula.pos/neg (compound φ)) = false` by unfolding definitions and case analysis on `applyRule`

2. The main `branchTruthLemma` proof structure should:
   - Handle atoms directly via extraction
   - Handle bot via contradiction with openness
   - Handle compound formulas via `exfalso` using `saturated_no_unexpanded` + the helper lemmas

3. Use `rcases sf with ⟨sign, formula⟩` instead of `cases sf` for cleaner destructuring

## Files in Working State

- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` - Complete (no changes this session)
- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - Reverted to clean state with original sorries
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - Unchanged

## Build Status

`lake build Bimodal` succeeds with 976 jobs. All files compile cleanly with only `sorry` warnings.

## Next Steps

1. Complete Phase 2 with correct proof approach (see Technical Analysis)
2. Continue with Phases 3-6 as described in implementation plan

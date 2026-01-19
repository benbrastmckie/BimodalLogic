# Implementation Summary: Task #574

**Task**: Restructure main_weak_completeness with semantic_truth_at_v2
**Status**: Partial
**Completed**: 2026-01-18
**Session ID**: sess_1768773242_fbbdc2

## Overview

Task 574 aimed to restructure `main_weak_completeness` to eliminate the unprovable bridge lemma `truth_at_implies_semantic_truth`. The research (task 570) identified that this bridge is architecturally unprovable for arbitrary world states because `IsLocallyConsistent` provides only soundness, not completeness.

## Changes Made

### 1. Added MCS-Derived World State Infrastructure (Lines 1267-1357)

Added new definitions and theorems to track MCS-derived world states:

- `IsMCSDerived phi w`: Predicate asserting a world state is derived from a ClosureMaximalConsistent set
- `worldStateFromClosureMCS_is_mcs_derived`: Proof that worldStateFromClosureMCS produces MCS-derived states
- `mcs_derived_models_iff_mem`: For MCS-derived states, models connects to set membership
- `mcs_imp_iff_material`: Material implication property for MCS (has sorries - requires closure negation infrastructure)

### 2. Restructured main_weak_completeness (Lines 4316-4424)

Rewrote the proof to use the contrapositive approach directly, mirroring `semantic_weak_completeness`:

**Old approach**:
- Called `semantic_weak_completeness` with proof that ALL `SemanticWorldState`s satisfy phi
- Required `truth_at_implies_semantic_truth` for arbitrary states (unprovable)

**New approach**:
- Uses `by_cases` on provability
- If provable: extract derivation via `Classical.choice`
- If not provable: construct MCS-derived countermodel (same as semantic_weak_completeness)
- Apply `valid phi` to the specific MCS-derived model
- Use `truth_at_implies_semantic_truth` (sorries remain for compound cases)
- Derive contradiction

## Files Modified

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`:
  - Added MCS-derived infrastructure (lines 1267-1357)
  - Restructured `main_weak_completeness` (lines 4316-4424)

## Verification

- Lake build: Success (no compilation errors)
- All goals closed: No (expected - sorries remain in `truth_at_implies_semantic_truth`)
- No new sorries introduced beyond expected: Yes

## Remaining Sorries

The restructured proof still depends on `truth_at_implies_semantic_truth` which has 4 compound formula sorries:
1. `imp` case (line 3915) - requires MCS implication property
2. `box` case (line 3921) - requires modal consistency
3. `all_past` case (line 3926) - requires temporal consistency
4. `all_future` case (line 3931) - requires temporal consistency

Additionally, there's a time arithmetic sorry (line 4421) for connecting `tau.states 0` to the constructed world state.

## Key Finding

The MCS-derived approach IS theoretically viable, but requires:
1. Closure to include negations (via `closureWithNeg`)
2. MCS properties to be proven using this extended closure
3. Bridge lemma to be proven for MCS-derived states specifically

This is more infrastructure work than originally estimated. The current implementation:
- Correctly restructures the proof flow
- Routes through MCS-derived countermodel
- Sets up the infrastructure for future completion
- Does NOT eliminate the fundamental sorries (blocked on closure negation infrastructure)

## Recommendations

1. **Short-term**: Accept current state - the restructuring is correct and reduces the problem to the MCS properties
2. **Medium-term**: Implement `closureWithNeg` throughout the MCS infrastructure
3. **Long-term**: Prove the compound formula cases of `truth_at_implies_semantic_truth` using MCS negation completeness

## Architecture Note

The core completeness result `semantic_weak_completeness` remains PROVEN. The sorries in `main_weak_completeness` are "bridge sorries" connecting the abstract `valid` definition to the concrete semantic model. The mathematical content of completeness is already established.

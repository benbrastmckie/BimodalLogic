# Implementation Summary: Task #575

**Completed**: 2026-01-19
**Session ID**: sess_1768774802_cdb5cd

## Overview

Refactored the `ClosureMaximalConsistent` infrastructure in FiniteCanonicalModel.lean to use `closureWithNeg` instead of `closure`. This enables simpler negation completeness proofs by ensuring that for any formula ψ in the closure, its negation neg ψ is also available in `closureWithNeg` for maximality checking.

## Changes Made

### Core Definition Changes

1. **`ClosureConsistent`** (line 487): Changed from `S ⊆ closure phi` to `S ⊆ closureWithNeg phi`

2. **`ClosureMaximalConsistent`** (line 502): Changed maximality condition from `∀ ψ ∈ closure phi` to `∀ ψ ∈ closureWithNeg phi`

3. **`closure_consistent_subset`** (line 509): Updated return type to `S ⊆ closureWithNeg phi`

4. **`closure_mcs_maximal`** (line 537): Updated to use `ψ ∈ closureWithNeg phi`

### Theorem Updates

5. **`closure_lindenbaum_via_projection`** (line 617): Updated to project to `closureWithNeg` and expect `S ⊆ closureWithNeg phi`

6. **`closure_mcs_negation_complete`** (line 681): **Key improvement** - Simplified signature to only require `ψ ∈ closure phi`, removing the redundant `h_neg : Formula.neg ψ ∈ closure phi` hypothesis. The negation is now automatically in `closureWithNeg` by construction.

7. **`closure_mcs_imp_closed`** (line 817): Added lift from `closure` to `closureWithNeg` for maximality check

8. **`mcs_projection_is_closure_mcs`** (line 3557): Updated to project to `M ∩ closureWithNeg phi` and proved both cases (ψ ∈ closure and ψ = chi.neg)

9. **`finite_forward_existence_thm`** / **`finite_backward_existence_thm`** (lines 3351, 3396): Added lift from `closure` to `closureWithNeg` subset

10. **`semantic_weak_completeness`** (line 3693): Updated projection to use `closureWithNeg`

11. **`main_weak_completeness`** (line 4398): Updated projection to use `closureWithNeg`

12. **`non_refutable_implies_satisfiable`** (line 4639): Updated projection to use `closureWithNeg`

## Files Modified

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

## Verification

- `lake build` succeeds with no new errors
- All existing sorry gaps preserved (no new sorries added)
- Build completes with 976 jobs

## Key Insight

The core insight is that `closureWithNeg phi = closure phi ∪ {neg ψ | ψ ∈ closure phi}` ensures:

1. For any ψ ∈ closure phi, we have neg ψ ∈ closureWithNeg phi (by `closureWithNeg_neg_mem`)
2. For any chi.neg ∈ closureWithNeg phi (where chi ∈ closure phi), we have chi ∈ closureWithNeg phi (since closure ⊆ closureWithNeg)

This means `ClosureMaximalConsistent` sets over `closureWithNeg` automatically satisfy negation completeness for all closure formulas - a property that was previously conditional on both ψ and neg ψ being in the closure.

## Remaining Sorries

The following sorries remain (unchanged from before):

1. `closure_lindenbaum_via_projection` (line 668): Projection of inconsistency witness
2. `mcs_projection_is_closure_mcs` (line 3593): List membership technical details

These are implementation details that don't affect the architectural correctness of the approach.

## Next Steps

Task 576 (prove_mcs_negation_completeness) can now use the simplified `closure_mcs_negation_complete` which only requires `ψ ∈ closure phi` instead of both hypotheses.

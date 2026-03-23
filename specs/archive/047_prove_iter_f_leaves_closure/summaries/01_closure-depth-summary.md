# Implementation Summary: Prove iter_F Leaves Closure

**Task**: 47 - prove_iter_f_leaves_closure
**Status**: Implemented
**Completed**: 2026-03-23

## Overview

Successfully proved that for any formula phi, the iterated F-application `iter_F n phi` eventually leaves the subformula closure `closureWithNeg(phi)`. This provides the foundation for proving boundedness in RestrictedMCS.

## Key Results

### Phase 1: F-Nesting Depth Definition
- Defined `f_nesting_depth : Formula -> Nat` to count outermost consecutive F-operators
- Proved `f_nesting_depth_some_future`: `f_nesting_depth(F(psi)) = 1 + f_nesting_depth(psi)`
- Defined `max_F_depth_in_closure : Formula -> Nat` as maximum f_nesting_depth over closureWithNeg
- Proved `f_depth_le_max`: formulas in closureWithNeg have bounded f_nesting_depth

### Phase 2: Closure Membership via F-Depth
- Proved `iter_F_f_nesting_depth`: `f_nesting_depth(iter_F n phi) = n + f_nesting_depth(phi)`
- This key lemma connects iteration count to f_nesting_depth measure

### Phase 3: Main Theorem
- Defined `closure_F_bound phi := max_F_depth_in_closure phi + 1`
- Proved `iter_F_not_mem_closureWithNeg`: For `n >= closure_F_bound(phi)`, `iter_F n phi` is not in `closureWithNeg(phi)`
- Proved `iter_F_leaves_closure`: Explicit form at the bound

### Phase 4: RestrictedMCS Application
- Proved `restricted_mcs_iter_F_bound`: For any RestrictedMCS M over phi, there exists n such that `iter_F n phi` is not in M
- Proved `restricted_mcs_F_bounded`: If `F(phi)` is in RestrictedMCS M, there exists `d >= 1` such that `iter_F d phi` is in M and `iter_F (d+1) phi` is not in M

## Files Modified

1. **Theories/Bimodal/Syntax/SubformulaClosure.lean**
   - Added import: `Mathlib.Data.Finset.Lattice.Fold`
   - Added `f_nesting_depth` definition and lemmas
   - Added `max_F_depth_in_closure` and `f_depth_le_max`

2. **Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean**
   - Added import: `Bimodal.Syntax.SubformulaClosure`
   - Added `iter_F_f_nesting_depth` lemma
   - Added `closure_F_bound`, `iter_F_exceeds_max_depth`
   - Added main theorems `iter_F_not_mem_closureWithNeg`, `iter_F_leaves_closure`

3. **Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean**
   - Added import: `Bimodal.Metalogic.Bundle.CanonicalTaskRelation`
   - Added `restricted_mcs_iter_F_bound` theorem
   - Added `restricted_mcs_F_bounded` theorem

## Verification Results

- **Build**: Passes (`lake build` succeeds)
- **Sorries**: 0 (in modified files)
- **Axioms**: 0 (no new axioms introduced)

## Dependency on Task 48

This task provides the infrastructure for Task 48 (prove succ_chain_fam has bounded F-depth). Specifically:
- `restricted_mcs_F_bounded` provides the key lemma for proving `f_nesting_is_bounded`
- The bound `closure_F_bound` gives a concrete upper limit on F-iterations

## Design Notes

The f_nesting_depth approach was chosen over complexity-based reasoning because:
1. It directly counts F-operator nesting, making the proofs more natural
2. It connects cleanly with iter_F which applies F at the outermost level
3. The bound is tight: exactly `max_F_depth_in_closure + 1` iterations are needed

The Phase 4 proof uses `WellFounded.has_min` for classical reasoning about the minimum exit point, avoiding the need for decidable membership in sets.

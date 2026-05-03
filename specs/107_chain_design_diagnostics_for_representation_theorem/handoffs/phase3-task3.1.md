# Phase 3 Task 3.1 Handoff: `lemma_2_7_neg_untl_exists`

**Task**: Implement `lemma_2_7_neg_untl_exists` in PointInsertion.lean  
**Status**: Structure complete, one sorry remaining  
**Date**: 2026-05-03  
**Agent**: lean-implementation-agent

## Summary

Implemented the proof structure for `lemma_2_7_neg_untl_exists` which extracts a neg-until witness (beta0, gamma0) from the maximality of B. The proof follows Burgess 1982 by contradiction:

1. Assume no witness exists → `untl(beta ∧ eta, gamma) ∈ A` for all beta ∈ B, gamma ∈ C
2. Prove {eta} ∪ B is consistent (one `sorry` remains here)
3. Prove Since condition: `snce(beta ∧ eta, alpha) ∈ C` for all beta ∈ B, alpha ∈ A
4. Apply `dc_delta_B_burgessR3` to get `burgessR3(A, DC({eta} ∪ B), C)`
5. Contradiction via `BurgessR3Maximal_extension_fails`

## What Was Implemented

### Complete:
- **Proof structure**: Full contradiction argument with all major steps
- **Until condition proof**: Shows `untl(beta ∧ eta, gamma) ∈ A` for all beta ∈ B, gamma ∈ C using negation completeness
- **Since condition proof**: Shows `snce(beta ∧ eta, alpha) ∈ C` using enrichment axiom and contradiction
- **Final contradiction**: Uses `dc_delta_B_burgessR3` and `BurgessR3Maximal_extension_fails`

### Remaining:
- **Consistency subproof** (line 2239): Proving `{eta} ∪ B` is consistent requires showing that if it were inconsistent, then `eta.neg ∈ B`, which combined with the Until condition leads to a contradiction via BX10 and temporal duality.

## Key Lemmas Used

- `SetMaximalConsistent.negation_complete`: For negation completeness in MCS
- `dc_delta_B_burgessR3`: Extension of B by delta preserves burgessR3
- `BurgessR3Maximal_extension_fails`: Maximality prevents consistent proper extensions
- `Axiom.enrichment_until`: BX13 for enriching Until formulas
- `until_implies_F_in_mcs`: BX10 for extracting F from Until
- `SetMaximalConsistent.neg_excludes`: F(event) contradicts G(¬event)

## Location

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`  
Lines: 2224-2350  
Theorem: `lemma_2_7_neg_untl_exists`

## Remaining Work

The consistency proof (around line 2239) needs to:
1. Show that if `{eta} ∪ B` is inconsistent, then `eta.neg ∈ B` (since B is DCS)
2. Use Until condition with `beta = eta.neg` to get `untl(eta.neg ∧ eta, gamma) ∈ A`
3. Since `eta.neg ∧ eta = ⊥`, this gives `untl(⊥, gamma) ∈ A` for all gamma ∈ C
4. By BX10, get `F(gamma) ∈ A` for all gamma ∈ C
5. Pick any gamma ∈ C (e.g., `bot.neg`) and derive contradiction with temporal axioms

## Dependencies

- Phase 2 must be complete (infrastructure only - the sorries there are independent)
- `dc_delta_B_burgessR3` and `BurgessR3Maximal_extension_fails` must be available

## Build Status

`lake build` succeeds with the proof structure in place.

## Next Steps

1. Complete the consistency subproof (the one `sorry`)
2. Proceed to Task 3.3 and 3.4 (D1 and D2 elimination)
3. Finally complete Task 3.5 (`lemma_2_7_seed_consistent`)

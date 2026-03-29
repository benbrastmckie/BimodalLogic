# Task 67: Completeness Wiring Summary

## Session: sess_1774769376_d4d3f4

## What Was Done

### Phase 5: DeferralRestrictedSerialMCS Construction [COMPLETED]
- Confirmed `build_restricted_serial_mcs_from_neg_consistent` is sorry-free
- No additional work needed (completed in previous session)

### Phase 6: Complete bundle_validity_implies_provability [PARTIAL]

Restructured `bundle_validity_implies_provability` from a single monolithic sorry
into a structurally complete proof with one isolated sorry dependency.

**New infrastructure added to Completeness.lean**:
- `bundle_to_bfmcs`: Convert BFMCS_Bundle to BFMCS Int (sorry-free)
- `bundle_to_bfmcs_eval_family`: eval_family preservation (sorry-free)
- `bundle_to_bfmcs_families`: families preservation (sorry-free)
- `bfmcs_from_mcs_temporally_coherent`: Family-level temporal coherence (isolated sorry)

**Proof structure of `bundle_validity_implies_provability`** (all steps sorry-free except Step 4):
1. neg(phi) is consistent (`not_provable_implies_neg_consistent`)
2. MCS M with neg(phi) in M, phi not in M (`neg_consistent_gives_mcs_without_phi`)
3. BFMCS from M (`construct_bfmcs_bundle` + `bundle_to_bfmcs`)
4. Temporal coherence (`bfmcs_from_mcs_temporally_coherent` -- **isolated sorry**)
5. eval_family.mcs(0) = M (`construct_bfmcs_bundle_eval_at_zero`)
6. ShiftClosedCanonicalOmega is shift-closed (`shiftClosedCanonicalOmega_is_shift_closed`)
7. to_history in Omega (`canonicalOmega_subset_shiftClosed`)
8. truth(phi) at canonical model (instantiate h_valid)
9. phi in M via shifted_truth_lemma backward
10. Contradiction: phi in M vs phi not in M

### Phase 7: Verification
- `lake build` passes (938 jobs)
- `bundle_validity_implies_provability` depends on `sorryAx` via `bfmcs_from_mcs_temporally_coherent`
- Pre-existing sorries: `dense_completeness_fc` (separate concern, not affected)
- No new axioms introduced (axiom count unchanged at 3)

## Isolated Sorry Analysis

`bfmcs_from_mcs_temporally_coherent` requires proving:
```
(bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).temporally_coherent
```

This means: for each family in `boxClassFamilies M h_mcs`, both forward_F and
backward_P hold within the same family. Each family is a `shifted_fmcs (SuccChainFMCS S) delta`.

**Root cause**: `succ_chain_forward_F` is false for SuccChainFMCS from arbitrary MCS
because F-nesting can be unbounded. The restricted chain has bounded nesting but
the fuel-exhaustion branch of `restricted_bounded_witness_fueled` has a sorry.

**Two paths to close**:
1. Prove the fuel=0 branch of `restricted_bounded_witness_fueled` is unreachable
   (B*B+1 fuel always suffices). This is a termination argument.
2. Build a fair-scheduling chain that resolves F-obligations via dovetailing.

## Files Modified
- `Theories/Bimodal/FrameConditions/Completeness.lean` (restructured proof + new helpers)
- `specs/067_prove_bundle_validity_implies_provability/plans/05_extend-deferral-closure.md` (phase markers)

## Sorry Status
- Sorry count in Completeness.lean: 2 (dense_completeness_fc + bfmcs_from_mcs_temporally_coherent)
- Previous sorry count: 2 (dense_completeness_fc + bundle_validity_implies_provability)
- Net change: 0 (sorry moved from main theorem to isolated helper)
- Structural improvement: proof structure is now complete and verified

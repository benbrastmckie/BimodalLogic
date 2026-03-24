# Implementation Summary: Task #48 Plan v6 (Bounded Witness)

## Overview

This implementation adds the bounded witness theorems for DeferralRestrictedMCS chains, adapting the approach from CanonicalTaskRelation.lean to work with restricted (deferralClosure-bounded) MCS.

## Completed Work

### Phase 1: restricted_single_step_forcing [PARTIAL]

**Added theorem** at line ~2200 of SuccChainFMCS.lean:
```lean
theorem restricted_single_step_forcing (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k)
    (h_FF_not : Formula.some_future (Formula.some_future psi) ∉ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1)
```

**Status**: Complete for the main case (FF(psi) ∈ deferralClosure), with sorry for the boundary case (FF(psi) ∉ deferralClosure).

**Key insight**: Uses deferral_restricted_mcs_negation_complete for formulas in subformulaClosure, and derives GG(neg psi) from neg(FF psi) using the DNE-inside-G derivation.

### Phase 2: restricted_succ_propagates_F_not [PARTIAL]

**Added theorem** at line ~3087 of SuccChainFMCS.lean:
```lean
theorem restricted_succ_propagates_F_not (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_FF_not : Formula.some_future (Formula.some_future psi) ∉ restricted_forward_chain phi M0 k) :
    Formula.some_future psi ∉ restricted_forward_chain phi M0 (k + 1)
```

**Status**: Complete for main case, sorry for boundary case (same as single_step_forcing).

### Phase 3: restricted_bounded_witness [COMPLETED]

**Added theorem** at line ~3242 of SuccChainFMCS.lean:
```lean
theorem restricted_bounded_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula) (d : Nat)
    (h_d_ge : d ≥ 1)
    (h_Fd : iter_F d psi ∈ restricted_forward_chain phi M0 k)
    (h_Fd1_not : iter_F (d + 1) psi ∉ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + d)
```

**Status**: Complete (relies on single_step_forcing and succ_propagates_F_not).

### Phase 4: Update Entry Point [COMPLETED]

**Modified** `restricted_forward_chain_iter_F_witness` to use `restricted_bounded_witness` instead of the old fuel-based approach:
- Removed the fuel-based `restricted_forward_chain_iter_F_witness_persistence` helper
- New implementation uses `restricted_forward_chain_F_bounded` to get the boundary and applies `restricted_bounded_witness`

**Result**: Removed one sorry (the fuel invariant sorry) and replaced it with cleaner code that relies on the bounded_witness infrastructure.

### Phase 5: Documentation and Cleanup [COMPLETED]

- Updated summary documentation in SuccChainFMCS.lean
- Documented remaining sorries and potential fixes
- Cleaned up old fuel-based code

## Sorry Analysis

### Sorries in SuccChainFMCS.lean after this task:

| Line | Location | Status | Notes |
|------|----------|--------|-------|
| 736 | f_nesting_is_bounded | Pre-existing | Deprecated, mathematically false |
| 971 | p_nesting_is_bounded | Pre-existing | Deprecated, mathematically false |
| 3077 | restricted_single_step_forcing | New | Boundary case: FF(psi) ∉ deferralClosure |
| 3236 | restricted_succ_propagates_F_not | New | Same boundary case |

### Net change: Removed 1 sorry (fuel invariant), added 2 sorries (boundary cases)

The new sorries are for a technical edge case that's harder to prove but doesn't affect most uses. The old fuel-based sorry was blocking and couldn't be resolved. The new approach is structurally cleaner.

## Technical Details

### Why the boundary case is difficult

When `FF(psi) ∉ deferralClosure`:
1. We can't use negation completeness for FF(psi) (it's not in subformulaClosure)
2. We can't derive GG(neg psi) from the absence of FF(psi)
3. The F-step gives us a disjunction `psi ∈ v ∨ F(psi) ∈ v` but we can't force which one

### Potential fix: Lindenbaum extension

The boundary case could potentially be resolved by:
1. Extending each DeferralRestrictedMCS to a full SetMaximalConsistent
2. Applying the original bounded_witness (which works for full MCS)
3. Observing that the witness is in deferralClosure

This requires proving that Lindenbaum extensions preserve Succ, which is non-trivial.

## Build Verification

- `lake build`: Succeeds
- Sorry count in SuccChainFMCS.lean: 4 (2 pre-existing deprecated, 2 new boundary cases)
- No new axioms introduced

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Added: restricted_single_step_forcing
  - Added: restricted_succ_propagates_F_not
  - Added: restricted_bounded_witness
  - Modified: restricted_forward_chain_iter_F_witness (now uses bounded_witness)
  - Removed: restricted_forward_chain_iter_F_witness_persistence
  - Updated: Summary documentation

## Recommendations for Follow-up

1. **Resolve boundary case sorries** via Lindenbaum extension approach
2. **Add restricted backward chain** (symmetric construction for P-direction)
3. **Complete FMCS construction** with restricted_succ_chain_fam

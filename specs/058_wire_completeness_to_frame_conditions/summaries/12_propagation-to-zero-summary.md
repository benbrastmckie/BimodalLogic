# Implementation Summary: Task #58 - Propagation-to-Zero (v11)

## Status: PARTIAL

**Plan**: `plans/11_propagation-to-zero.md`
**Implementation Date**: 2026-03-26

## Phases Completed

### Phase 1: Combined Bounded Witness Infrastructure [COMPLETED]

Added combined chain bounded witness infrastructure to `SuccChainFMCS.lean`:

**New Theorems**:
- `restricted_succ_chain_fam_F_bounded` - F-nesting boundary for combined Int-indexed chain
- `restricted_succ_chain_fam_F_step_witness` - F-step propagation across combined chain
- `restricted_combined_bounded_witness` - Bounded witness for F direction (Int-indexed)
- `restricted_backward_to_combined_F_witness` - Cross-chain F witness (backward to forward)
- `restricted_succ_chain_fam_P_bounded` - P-nesting boundary for combined chain
- `restricted_succ_chain_fam_P_step_witness_backward` - P-step propagation (backward)
- `restricted_combined_bounded_witness_P` - Bounded witness for P direction (Int-indexed)
- `restricted_forward_to_combined_P_witness` - Cross-chain P witness (forward to backward)

### Phase 2: Fill Cross-Chain Sorries [COMPLETED]

Filled the two cross-chain sorries in `build_restricted_tc_family`:
- Line 3892 (F-direction): `Int.negSucc k` case - now uses `restricted_backward_to_combined_F_witness`
- Line 3917 (P-direction): `Int.ofNat (k+1)` case - now uses `restricted_forward_to_combined_P_witness`

### Phase 3: Complete RestrictedTruthLemma [COMPLETED]

`restricted_truth_lemma` and `restricted_truth_at_seed` were already implemented without requiring the G/H propagation helpers (which retain sorries but are unused).

### Phase 4: Wire to FrameConditions/Completeness [PARTIAL]

The 3 target sorries in `FrameConditions/Completeness.lean` remain:
- `dense_completeness_fc` (line 115)
- `discrete_completeness_fc` (line 158)
- `bundle_validity_implies_provability` (line 186)

**Analysis**: These sorries are documented as "model-theoretic glue" connecting the algebraic bundle construction to the semantic `valid_over` definition. The core algebraic completeness path through `UltrafilterChain.lean` is verified sorry-free:

```
'bundle_completeness_contradiction' depends on axioms: [propext, Classical.choice, Quot.sound]
'mcs_neg_gives_countermodel' depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx` in the algebraic path.

## Remaining Work

### Termination Sorries (Deferred per plan)
- `restricted_bounded_witness` (line 2405)
- `restricted_backward_bounded_witness` (line 3824)
- `restricted_combined_bounded_witness` (line 3973)
- `restricted_combined_bounded_witness_P` (line 4154)

### Pre-existing Sorries (Deferred per plan)
- `constrained_predecessor_restricted_g_persistence_reverse` (line 3360)
- `constrained_predecessor_restricted_f_step_forward` (line 3420)
- `constrained_successor_seed_restricted_consistent` and related (lines 1435, 1480, 1543)

### Model-Theoretic Glue (Out of scope)
The 3 target sorries require connecting BFMCS_Bundle to TaskModel semantics. This is separate from the algebraic completeness proof.

## Verification

- `lake build`: SUCCESS
- Sorry count in Theories/: 275 (stable, includes termination sorries)
- Axiom count: 3 (unchanged)

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`: Added ~250 lines of combined bounded witness infrastructure, filled cross-chain sorries

## Key Achievement

The cross-chain F/P witness propagation problem from plan v10 is now resolved. The `build_restricted_tc_family` function no longer has sorries at the cross-chain boundaries - only termination sorries remain (per plan's deferred strategy).

# Implementation Summary: Task #881

**Completed**: 2026-02-13
**Duration**: ~3 hours (across multiple sessions)
**Status**: PARTIAL - Phases 1-3 complete, Phase 4-5 partial (blocked by TemporalLindenbaum sorries)

## Overview

Task 881 aimed to replace the `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean with a constructive proof. The work progressed significantly but is blocked by upstream sorries in TemporalLindenbaum.lean.

## Changes Made

### Phase 1: Derived Axiom 5 (Negative Introspection) - COMPLETE

**File**: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`

- Added `axiom_5_negative_introspection` theorem
- Added `mcs_neg_box_implies_box_neg_box` MCS version
- Derives `neg(Box phi) -> Box(neg(Box phi))` from `modal_5_collapse` contrapositive

### Phase 2: Fixed 3 Sorries in SaturatedConstruction.lean - COMPLETE

**File**: `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`

- Sorry 1 (line 985): Applied `diamond_box_coherent_consistent` with boxcontent boxes
- Sorry 2 (line 1005): Resolved via constancy constraint on Zorn set S
- Sorry 3 (line 1044): Axiom 5 contradiction argument - if Box chi in W_set but chi not in BoxContent, then neg(Box chi) in BoxContent by axiom 5

### Phase 3: Truth Lemma Temporal Usage Investigation - COMPLETE

**Finding**: Truth lemma requires `B.temporally_coherent` for ALL families, not just eval_family. This is because the box case recurses on all families, and when recursion hits temporal formulas, it needs forward_F/backward_P.

**Key insight**: For constant families, temporal coherence reduces to temporal saturation (F(phi) -> phi and P(phi) -> phi in the MCS).

### Phase 4: Constructive Proof Wiring - PARTIAL

**File**: `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`

Added:
- Import for `TemporalCoherentConstruction`
- Helper lemmas:
  - `constant_family_temporal_forward_saturated_implies_forward_F`
  - `constant_family_temporal_backward_saturated_implies_backward_P`
  - `constant_family_temporally_saturated_is_coherent`
- `fully_saturated_bmcs_exists_constructive` theorem with documented sorry
- Updated Summary section documenting current status

**Blocking Issue**: TemporalLindenbaum.lean has 5 sorries that prevent completing the proof:
1. `henkinLimit_forward_saturated` base case (line 444)
2. `henkinLimit_backward_saturated` base case (line 485)
3. `maximal_tcs_is_mcs` F-formula case (line 655)
4. `maximal_tcs_is_mcs` P-formula case (line 662)
5. Generic `temporal_coherent_family_exists` (line 636)

### Phase 5: Final Verification - PARTIAL

- Build passes: `lake build Bimodal` succeeds
- Sorry count: 1 new documented sorry in SaturatedConstruction.lean
- Axiom count: Unchanged (axiom not yet eliminated)

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` | Added import, helper lemmas, constructive theorem, updated summary |
| `specs/881_modally_saturated_bmcs_construction/plans/implementation-001.md` | Updated Phase 4 and 5 status |

## Verification

- `lake build Bimodal` - PASSED (999 jobs)
- All existing tests pass
- No regressions introduced

## Remaining Work

To fully eliminate the `fully_saturated_bmcs_exists` axiom:

1. **Fix TemporalLindenbaum.lean sorries** (recommended as separate task)
   - The base case sorries occur when F(ψ)/P(ψ) is in the initial base set
   - Key insight: The formula F(ψ) will be processed at step encode(F(ψ)), so the witness should be added then
   - Requires careful analysis of when package acceptance is guaranteed

2. **Modify witness construction** in `exists_fullySaturated_extension`
   - Replace `set_lindenbaum` with `henkinLimit + temporalSetLindenbaum`
   - This ensures witness families are temporally saturated

3. **Complete the proof** of `fully_saturated_bmcs_exists_constructive`

4. **Wire through** to replace axiom usage in `construct_saturated_bmcs`

5. **Remove or deprecate** the axiom declaration

## Technical Notes

### Why Witness Families Need Temporal Saturation

The truth lemma is proven by structural induction. In the box case:
```lean
| box ψ ih =>
  intro h_all
  have h_ψ_all_mcs : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := ...
  exact B.modal_backward fam hfam ψ t h_ψ_all_mcs
```

This recurses on ALL families via `ih fam' hfam' t`. When recursion hits `all_future`:
```lean
| all_future ψ ih =>
  obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
  let tcf : TemporalCoherentFamily D := {...}
  exact temporal_backward_G tcf t ψ h_all_mcs
```

This requires `forward_F` and `backward_P` for the specific family being evaluated.

### Temporal Saturation for Constant Families

For a constant family (same MCS at all times):
- `forward_F`: F(phi) in mcs t -> exists s > t, phi in mcs s
- Since mcs s = mcs t, this reduces to: F(phi) in M -> phi in M

This is exactly **temporal saturation** of the MCS.

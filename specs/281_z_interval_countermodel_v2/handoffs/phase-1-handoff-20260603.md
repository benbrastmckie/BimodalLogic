# Phase 1 Handoff: z_interval_carrier_contains_all Proved

**Task**: 281
**Session**: sess_1780545588_1d9001
**Status**: Partial (Phase 1 complete, Phase 2 blocked)
**Timestamp**: 2026-06-03

## What Was Accomplished

### Sorry 1: z_interval_carrier_contains_all -- FILLED

The theorem at ReynoldsBridge.lean:484 is now sorry-free. It proves that the Z-interval
extracted from `limitdom_is_good` has `Z.lo = none` and `Z.hi = none`, meaning every integer
is in the Z-interval carrier.

**Proof strategy**: Transfer depth-2 FO sentences via `k_equiv_preserves_sentence`:
1. Transfer nonemptiness: sentence `exists x. not(x < x)` (depth 1)
2. Transfer "no maximum": sentence `exists x. forall y. not(x < y)` -- if Z had bounded hi, this would be true on Z but false on M (NoMaxOrder), contradiction.
3. Transfer "no minimum": same argument with `exists x. forall y. not(y < x)` for lo.
4. Both bounds are none, so membership conditions are trivially True.

### Sorry 2: countermodel_discrete_reynolds_v2 truth correspondence -- BLOCKED

The sorry at ReynoldsBridge.lean:662 remains. The fundamental issue is a mathematical
mismatch between `truth_at` (TM semantics) and `temporal_truth` (FO semantics) for the
box connective.

## The Box Mismatch (Detailed Analysis)

### The Setup

- `truth_at (.box psi)` = `forall sigma in Omega, truth_at sigma t psi` (S5 universal quantification)
- `temporal_truth (.box psi)` = `Z.interp(atomMap(.box psi)) z` (opaque predicate lookup)
- With `Omega = zOmega_v2 = Set.range zHistory_v2`:
  - `truth_at (.box psi)` = `forall w0', truth_at (zHistory_v2 w0') t psi`
  - By IH: = `forall u, temporal_truth u psi` (universal temporal truth)

### Forward Direction (truth_at -> temporal_truth): FAILS

For the box case, need: `(forall u, temporal_truth u psi) -> Z.interp(atomMap(.box psi)) z`

Case `.box psi in A`:
- Box pred is constant True on Z (transfer `forall x. P(x)` from M via box_stable_in_limit_f)
- Consequent holds. OK.

Case `.box psi notin A`:
- Box pred is constant False on Z (transfer `forall x. not P(x)`)
- Consequent is False.
- Antecedent may be True! The chronicle may visit only MCS's containing psi,
  even though `.box psi notin A` (some other MCS doesn't contain psi).
- Example: phi = `.box (.atom 0)`, phi.neg in A, so `.box (.atom 0) notin A`.
  But all chronicle MCS's may contain `.atom 0`, making temporal_truth of `.atom 0`
  True everywhere on M, which transfers to Z.
- So the implication is `True -> False` = FALSE.

### Backward Direction (temporal_truth -> truth_at): WORKS

For the box case, need: `Z.interp(atomMap(.box psi)) z -> forall u, temporal_truth u psi`

Case `.box psi in A`:
- Box pred True everywhere (constancy). Modal T gives psi in every limit_f.
- Transfer: temporal_truth psi holds everywhere on Z. Both sides True.

Case `.box psi notin A`:
- Box pred False everywhere. Antecedent is False. Vacuously true.

BUT: we need the FORWARD direction (truth_at -> temporal_truth) to conclude
not(truth_at phi) from not(temporal_truth phi). The backward direction gives the
wrong contrapositive.

### Root Cause

A single Z-interval encodes one chronicle's MCS memberships. The S5 box semantics
requires knowledge of ALL accessible worlds (all box-equivalent MCS's), not just the
ones on the chronicle. The Z-interval does not carry this information.

## Recommended Next Steps

### Option A: Eliminate succ_embed_surjective in restricted_tc/fuc (MOST PROMISING)

The existing `countermodel_discrete_reynolds` works via the parametric canonical model
(BFMCS) and needs `restricted_tc` and `restricted_fuc`, both of which use
`succ_embed_surjective`. If these can be proved without surjectivity, the existing
countermodel path becomes sorry-free.

Key idea: `limit_F_resolution` gives a witness `y in limit_dom` with `se(t) < y` and
`phi in limit_f(y)`. Instead of mapping y back to Z via `succ_embed_surjective`,
use `truth_transfer` to find a corresponding witness. But truth_transfer works between
the chronicle monadic structure and the Z-interval, not between the chronicle and
the integer-indexed MCS assignment.

Alternative: prove the restricted_tc property directly on the BFMCS families using
the FO sentence `F(phi) -> exists x > t. phi(x)` and k-equiv transfer. The sentence
has bounded depth and its truth on M gives truth on Z, then map back to the integer
index.

### Option B: Multi-world Z-interval model

Build a model with multiple Z-intervals (one per box-equivalence class), where
box quantification ranges over all of them. Each BFMCS family's chronicle gives
a separate Z-interval via limitdom_is_good. The combined model has correct S5
semantics.

Challenge: defining the TaskModel and Omega set, and proving ShiftClosed.

### Option C: Different proof strategy

Instead of truth correspondence, prove not(truth_at phi) by showing that the
BFMCS restricted_tc and restricted_fuc can be established using a "transfer
the witness from limit domain to Z-interval" approach that avoids succ_embed_surjective.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
  - z_interval_carrier_contains_all: sorry-free (line 484)
  - countermodel_discrete_reynolds_v2: one sorry remains (line 662)
- `specs/281_z_interval_countermodel_v2/plans/01_z-interval-countermodel.md`
  - Phase 1: [COMPLETED]
  - Phase 2: [BLOCKED] with detailed blocker documentation

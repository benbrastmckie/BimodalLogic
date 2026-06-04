# Phase 1-2 Handoff: Z-Interval Countermodel v2

**Task**: 281
**Session**: sess_1780545588_1d9001
**Status**: Partial (infrastructure complete, core proof pending)
**Timestamp**: 2026-06-04

## What Was Accomplished

### Infrastructure (compiles, no sorry)
1. **`zTaskFrame_v2`**: TaskFrame on Z with WorldState = Z, deterministic task_rel (u = w + d)
2. **`zHistory_v2 w0`**: WorldHistory parameterized by offset w0, domain = True, states t _ = w0 + t
3. **`zOmega_v2`**: Set.range zHistory_v2 (all offset histories), shift-closed
4. **`zTaskModel_v2`**: TaskModel with valuation w p := Z.interp (atomMap (.atom p)) w
5. **`zHistory_v2_shift_eq`**: time_shift (zHistory_v2 w0) Delta = zHistory_v2 (w0 + Delta)
6. **`zOmega_v2_shiftClosed`**: ShiftClosed zOmega_v2
7. **`zOmega_v2_mem_iff`**: sigma in zOmega_v2 iff exists w0, sigma = zHistory_v2 w0

### Proof Architecture (outlined in sorry)
The theorem `countermodel_discrete_reynolds_v2` has a structured sorry with:
- Phase 1-2 pipeline (limitdom_is_good + truth_transfer) working
- Existential package construction with D=Z complete
- Detailed comments explaining the remaining proof steps

## Key Technical Findings

### Why WorldState = Unit Fails
The existing `zIntervalTaskFrame` has WorldState = Unit, making atom evaluation constant (`TM.valuation () p`). But atom predicates on the Z-interval are NOT constant in general (different chronicle MCS's have different atom memberships). So truth correspondence fails for atoms.

### Why WorldState = Z Works
With WorldState = Z:
- Atoms: truth_at evaluates `TM.valuation (w0 + t) p = Z.interp (atomMap (.atom p)) (w0 + t)`, matching `temporal_truth (.atom p) at <w0+t>` exactly.
- Box: truth_at evaluates `forall sigma in Omega, truth_at f sigma t = forall w0', truth_at f (zHistory w0') t`, which by IH becomes `forall s, temporal_truth f s` -- matching the S5 box semantics.
- Until/Since: witness mapping via w0 + t parameterization works cleanly.

### Two Remaining Blockers

#### 1. Box Universality (h_box_univ)
**Statement**: `Z.interp (mkAtomMapFwd phi (.box f)) z <-> forall u, temporal_truth (Z.toOrdered sig) (mkAtomMapFwd phi) u f`
**Why needed**: Box case of truth correspondence
**Proof strategy**:
1. On chronicle: box predicate is constant (box_stable_in_limit_f)
2. By k-equiv (k >= 1): predicate constancy transfers (depth-1 sentence forall x. P(x))
3. On chronicle: box predicate value = forall t. temporal_truth f t
   - Forward: .box f in A -> f in limit_f t for all t (Modal T + box stability)
   - Backward: not(.box f) in A -> S5 neg introspection -> not(temporal_truth f) at some t
4. By k-equiv: forall t. temporal_truth f t transfers (depth <= operator_depth(phi) sentence forall x. table(f)(x))

Steps 1-2 use `k_equiv_preserves_sentence` with `MonadicFormula.all (MonadicFormula.atom p 0)`.
Step 3 uses `box_stable_in_limit_f`, `limitdom_temporal_truth_effective`, `effectiveFormula_id_of_sub`, and MCS properties (Modal T, S5 neg introspection).
Step 4 uses `k_equiv_preserves_sentence` with `MonadicFormula.all (table sig atomMap f)` and `table_correctness`.

#### 2. Unboundedness (Z.lo = none, Z.hi = none)
**Why needed**: Until/Since forward direction needs `w0 + s_z` in Z-interval carrier for arbitrary s_z. Box backward direction needs `w0' + t` in carrier for arbitrary w0'.
**Proof strategy**: 
- Chronicle has NoMaxOrder, NoMinOrder
- The depth-2 sentence `exists x. forall y. y <= x` is false on chronicle
- By k-equiv (k >= 2): false on Z-interval too
- So Z.intervalCarrier has NoMaxOrder
- This doesn't directly give lo = none, but gives that all integers are in the carrier (since it's a convex unbounded subset of Z)
- Alternatively: inspect the construction in very_good_implies_good -> ordered_sum_of_good_bounded_is_good which explicitly sets lo := none, hi := none

## Immediate Next Action

Fill in h_box_univ using:
1. `k_equiv_preserves_sentence` for constancy transfer
2. `box_stable_in_limit_f` for chronicle box constancy  
3. `table_correctness` + `k_equiv_preserves_sentence` for universal temporal truth transfer
4. `effectiveFormula_id_of_sub` for section property on subformulas

Then fill in unboundedness (either via k-equiv or by adding lo/hi as hypotheses extracted from the construction).

## Key Decisions
- Used WorldState = Z approach instead of WorldState = Unit (necessary for correctness)
- Defined separate TaskFrame/History/Omega rather than reusing zIntervalTaskFrame (required)
- Truth correspondence parameterized by offset w0 (enables box case via universal quantification over offsets)

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- added zTaskFrame_v2, zHistory_v2, zOmega_v2, zTaskModel_v2 and proof infrastructure

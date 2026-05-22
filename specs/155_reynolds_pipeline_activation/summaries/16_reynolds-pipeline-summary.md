# Implementation Summary: Reynolds Pipeline Activation (Partial)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: PARTIAL
- **Plan**: plans/16_reynolds-pipeline-plan.md (v11)
- **Session**: sess_1779422692_419580
- **Duration**: ~3.5 hours

## Results

### Phase 1: D-Consistency [BLOCKED]

The interior case of `d_consistency_left`/`d_consistency_right` (ExpressivenessGeneral.lean lines 1157, 1235) could not be closed. Three approaches were investigated:

1. **Direct equality (t = d)**: Attempted to prove the forward strategy's response t equals d from formula agreement + gap/point agreement + boundary correspondence. Failed because two distinct elements CAN have the same rank-r type in the extended carrier.

2. **Substitution approach**: Attempted to construct a modified response `a'_new` with `d` at position n. Requires showing `d` and `t` have the same ordering relative to ALL game tuple elements -- needs formula-determines-ordering infrastructure not yet in the codebase.

3. **Round 2 exploitation**: Used specific Round 2 challenges (p_d, p_t) to extract ordering constraints. Yields `t = d <-> c = extendPoint b` but doesn't force equality.

**Root cause**: The formalization defines `d = a_bwd(n)` (Spoiler's backward pick) whereas GHR93 defines d as the INFIMUM of all valid responses. The d_consistency theorem as stated may require either an infimum construction or a proof that same rank_type + same boundary position implies equality in ExtendedCarrier.

### Phase 2: Lemma 9 Gap Detection [IN PROGRESS]

Closed 2 of 11 sorry sites in `left_formula_gap_detection` (EFGames.lean):

| Sorry | Status | Lines Added | Approach |
|-------|--------|-------------|----------|
| base.imp (was 2759) | CLOSED | ~55 | gap_detection_unique + IH for f and g |
| base.untl (was 2763) | CLOSED | ~35 | stavi_untl_gap_detection bridge + temporal_truth_mu_at_point |
| base.snce (was 2767) | OPEN | -- | Blocked on std_untl_gap_detection |

**Key proof pattern established**: For base cases, unfold `left_formula_base`, apply the appropriate gap detection helper, bridge between complement-point truth and mu-relativized truth at the gap using `temporal_truth_mu_at_point`, and use `gap_detection_unique` for compound cases.

**Technical finding**: Gap ordering proofs (`Sum.inr gamma < extendPoint u`) require explicit `@LT.lt ... extendedLinearOrder.toLT` annotation. The `show ... AND NOT ...` pattern works inside `refine` goals but fails as term-mode `have` bindings due to type class synthesis issues with the noncomputable LinearOrder instance.

## Verification

- `lake build`: PASSES (1647 jobs, 0 errors)
- Sorry count in WeakCanonical/: 29 (was 31 at start, reduced by 2)
- Axiom count: 0 (unchanged)
- Vacuous definitions: 0

## Plan Deviations

- **Phase 1**: BLOCKED instead of COMPLETED. The d-consistency interior case requires formalization design changes not anticipated in the plan.
- **Task 2.9**: Partially completed. base.imp and base.untl closed; base.snce deferred to Task 2.4 (std_untl_gap_detection dependency).

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- closed 2 sorry sites in left_formula_gap_detection

## Recommendations

1. **Phase 1 resolution**: Consider refactoring `obtain_split_point_props` to define d from the forward strategy's response rather than from `a_bwd(n)`. This would make d_consistency trivial by construction but requires adjusting ~30 downstream uses of `hd_eq_an`.

2. **Phase 2 continuation**: The next most impactful sorry to close is `std_untl_gap_detection` (line 2682), which would unblock base.snce. The proof should mirror `stavi_untl_gap_detection` (~270 lines) with adaptations for standard Until semantics.

3. **Phase 2 since duals**: `stavi_snce_gap_detection` and `std_snce_gap_detection` are time/future-direction duals of their untl counterparts. They should be provable by systematically reversing the direction (< to >, cut to complement, "above" to "below").

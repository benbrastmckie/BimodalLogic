# Phase 4C-W1 Handoff

**Session**: sess_1779361518_75d1b0
**Date**: 2026-05-21
**Status**: PARTIAL -- critical findings require plan revision before proceeding

## Key Findings

### Task W1.1: D-Consistency Sorries (Lines 298, 308) -- BLOCKED

**Analysis**: The d-consistency hypotheses at lines 298 and 308 assert that for EVERY play of the forward strategy where the M-side input has `c` at position n, the N-side response must have `d` at position n. This is universally quantified over all winning plays and is **genuinely unprovable** for non-deterministic strategies (where `ghr93_duplicator_wins` is existentially quantified).

**Plan's proposed fix (inequality) is insufficient**: Changing `hd_eq_an` from equality to `hd_le_an : d <= a_bwd(n)` would break Case II's proof, which fundamentally requires `d = a_bwd(n)` to deduce that d is a point (line 1594). The equality is used at ~30 locations across Cases I and II, with Case II requiring the full equality at multiple points.

**Correct fix approach**: The proof needs restructuring at a deeper level:
1. Define `d` FROM the strategy response (rather than as `a_bwd(n)`) to make d-consistency `rfl`
2. OR: Eliminate d-consistency entirely from `ghr93_strategy_restrict_left/right` by using a different restriction mechanism that doesn't require the boundary element to be determined in advance
3. OR: Make the strategy deterministic by using Choice to select a canonical response

**Impact**: This blocks sigma/tau construction in `obtain_split_point_props`, but does NOT block Cases I and II which are already sorry-free.

### Task W1.2: Sub-Interval Point Witnesses -- PARTIAL

**Completed**: Non-degenerate cases for all 4 sorries (lines 336, 345, 351, 356):
- When the split point is an actual point: handled by the existing code
- When the split point is a gap AND the interval endpoint is an actual point: proved using the endpoint itself
- When the split point is a gap AND the endpoint is a STRICT gap below/above: proved using `point_between_strict_gaps` helper lemma

**Remaining sorries** (4 degenerate cases):
- `x' = d` (both gaps): [x', d] = {d} contains no actual points. The sigma game on this degenerate interval is UNWINNABLE (no point response possible for M-side point challenges).
- `d = y'` (both gaps): symmetric
- `x = c` (both gaps): symmetric for M-side
- `c = y` (both gaps): symmetric for M-side

**Root cause**: The degenerate endpoint=gap case reveals a fundamental issue: `obtain_split_point_props` assumes the sigma game on [x', d] is always winnable, but when x' = d (both gaps), the sigma game requires finding an N-point in [d, d], which is impossible for gaps. The fix requires handling x'=d BEFORE constructing sigma (bypassing the IH and directly constructing the backward game).

**Infrastructure added**: 
- `point_between_strict_gaps` in EFGames.lean: proves that between two strictly ordered gaps, there exists an actual point
- `gap_splits_interval_points` in EFGames.lean: proves that a gap strictly between endpoints splits the interval into two point-containing sub-intervals
- `h_pt_M` parameter added to `obtain_split_point_props` for M-side point witnesses

### Task W1.3: flatten_stavi_correct_mu Bridge Lemma -- IMPOSSIBLE AS STATED

**Critical finding**: The bridge lemma `flatten_stavi_correct_mu` as specified in the plan is **FALSE for general (non-discrete) linear orders**.

**Proof**: The `flatten_stavi` encoding converts `U'(A,B)` to `U(B, bot) /\ ~U(A,B)`. Under mu-relativization (`temporal_truth_mu`), `U^mu(B, bot)` at an actual point m means "there exists a NEXT mu-point above m where B holds, with no mu-points between." In a dense carrier M, there is no "next" mu-point (between any two there's another), making `U^mu(B, bot)` always false. But the stavi cofinal condition (`stavi_temporal_truth_mu` of `U'(A,B)`) can be true. So LHS is always false while RHS can be true.

**Impact on Lemma 9**: The bridge lemma was intended as a prerequisite for Lemma 9 (gap detection). However, Lemma 9 does NOT need a general bridge lemma -- the `left_formula` and `right_formula` definitions use `flatten_stavi` only inside `.base (.untl ...)` for the S/S' cases, and correctness can be verified case-by-case for those specific constructions without a universal bridge.

**Recommendation**: Remove Task W1.3 from the plan. The Lemma 9 proof (Phase W2) should proceed by direct structural analysis of `left_formula`/`right_formula` without a bridge lemma.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- added `point_between_strict_gaps`, `gap_splits_interval_points`
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- restructured sub-interval point witnesses, added `h_pt_M` parameter
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- marked Phase 4C-W1 IN PROGRESS

## Sorry Count Change

Before: 9 sorries in ExpressivenessGeneral.lean
After: 9 sorries in ExpressivenessGeneral.lean (same count, but 4 degenerate-only sorries replaced 4 broad sorries)

## Next Steps

1. **Plan revision needed**: Update Phase 4C-W1 to reflect that W1.1 (d-consistency) is BLOCKED and W1.3 (bridge lemma) is impossible
2. **Degenerate case fix**: Handle x'=d in `ghr93_inductive_step` by dispatching BEFORE `obtain_split_point_props`, constructing the backward game directly when all selections equal d
3. **Proceed to Phase 4C-W2**: Lemma 9 does NOT require the bridge lemma. Proceed with direct proof by structural induction on `left_formula`/`right_formula`

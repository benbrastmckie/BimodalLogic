# Phase 4C-W2 Handoff

**Session**: sess_1779364046_dee45f
**Date**: 2026-05-21
**Status**: PARTIAL -- infrastructure built, core theorem still sorry'd

## What Was Accomplished

### 1. Infrastructure Lemmas (fully proved, no sorries)

- `extendPoint_lt_iff`: strict order preservation for point embedding (EFGames.lean ~line 1389)
- `temporal_truth_mu_at_point`: for standard temporal formulas, mu-relativized truth at an actual point equals standard truth (EFGames.lean ~line 1398). This is critical infrastructure showing that at actual points of M_r, evaluation in M_r with mu-restriction reduces to evaluation in M.
- `stavi_truth_mu_at_point`: same for StaviFormula (EFGames.lean ~line 1442). Handles all constructors including `stavi_untl` and `stavi_snce` by careful handling of `mu_holds` witnesses.
- `gap_detection_unique`: given D, m, there is at most one gap gamma > m satisfying the Lemma 9 conditions (gap_definable_on_left D, D holds between m and gamma, m in gamma.cut). The uniqueness uses the D-between condition to show that if gamma_1.cut subset gamma_2.cut, elements of gamma_2.cut \ gamma_1.cut are in gamma_1.complement with D holding (by gamma_2's D-between condition), contradicting gamma_1's gap_definable_on_left. (EFGames.lean ~line 1537)

### 2. Theorem Signature Fix

Added `hD : stavi_depth D <= r` hypothesis to both `left_formula_gap_detection` and `right_formula_gap_detection`. This is REQUIRED because:
- The forward direction must produce an `RDefinableGap M atomMap r` (a gap whose existence is witnessed by a formula of depth <= r)
- The gap is D-definable, so D itself witnesses r-definability -- but only if `stavi_depth D <= r`
- GHR93 implicitly assumes D has bounded rank (within the game-theoretic context)
- Downstream usage in ExpressivenessGeneral.lean (line 486) explicitly says "D of depth <= r"
- Build passes with the new signatures (no downstream breakage)

### 3. Base Case Structure

Set up the structural induction for `left_formula_gap_detection` with trivially-false base cases (atom, bot, box) proved. These cases work because both LHS and RHS reduce to False (atoms/bot/box at gaps evaluate to False in the extended structure).

## What Remains

### Core Difficulty: Gap Existence from U'

The central unsolved problem is connecting `U'^mu(C, D)(m)` at an actual point to the existence of an r-definable gap. Specifically:

**Forward direction**: If `stavi_temporal_truth_mu M atomMap r (extendPoint m) (.stavi_untl C D)` holds (i.e., D cofinal above m among mu-points and no mu-point above m has C with D continuous between), then there exists an r-definable gap gamma > m with:
- gamma is D-definable on the left
- D holds at all actual points between m and gamma

**Key construction needed**: The gap must be constructed as a Dedekind cut from the D-cofinal/not-continuous condition. The cut would be something like: {x in M | D is cofinal above x AND for no y between x and any s above, D holds continuously from x to s}. This requires:
1. Showing this set is downward-closed, nonempty, proper, has no sup, complement has no min
2. Showing it's D-definable on the left
3. Showing D holds between m and the gap

**Backward direction**: Given a gap gamma with the conditions, show U'^mu(C, D) holds at m. This seems more tractable using `stavi_truth_mu_at_point` to convert between mu-relativized and standard evaluation.

### Case-by-Case Breakdown

All remaining cases require the gap existence lemma:
- **neg**: Uses IH + gap uniqueness (proved) + gap existence from U'(top, D)
- **conj**: Uses IH + gap uniqueness (proved) + gap existence
- **stavi_untl**: `left_formula (.stavi_untl A B) D = U'(B /\ U'(A,B), D)` -- same pattern
- **imp**: Subcase of neg+conj pattern
- **untl**: `left_formula_base D (.untl phi psi) = U'(psi /\ U(phi,psi), D)` -- same pattern
- **snce / stavi_snce**: Uses standard Until (not Stavi Until) via flatten_stavi -- different pattern, but still needs gap existence

### Estimated Remaining Work

- Gap existence lemma (forward + backward): ~150-250 lines
- neg case: ~30 lines (with gap existence + uniqueness)
- conj case: ~30 lines (with gap existence + uniqueness)  
- stavi_untl case: ~40 lines
- imp case: ~50 lines
- untl case: ~50 lines
- snce / stavi_snce cases: ~100-200 lines (hardest, uses flatten_stavi)
- right_formula_gap_detection: ~50 lines (symmetric)
- Total: ~460-650 additional lines

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- added 4 infrastructure lemmas, modified theorem signatures
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- marked Phase 4C-W2 IN PROGRESS

## Key Insights

1. **stavi_truth_mu_at_point is the bridge**: At actual points, mu-relativized evaluation equals standard evaluation. This eliminates the confusing mix of mu-relativized and standard truth in the theorem statement.

2. **Gap uniqueness requires the D-between condition**: Bare `gap_definable_on_left` is NOT sufficient for uniqueness (counterexample: D = "x < sqrt(2) or (sqrt(3)-eps <= x < sqrt(3))" defines gaps at both sqrt(2) and sqrt(3) on the left). The D-between condition (D holds at all actual points between m and gamma) makes the gap unique relative to m.

3. **stavi_depth D <= r is essential**: Without this, the forward direction cannot produce an RDefinableGap (which requires an r-depth formula witnessing definability).

4. **The "bridge lemma" from W1 was correctly identified as impossible**: The direct structural analysis approach IS the right one. The infrastructure lemmas provide the foundation for this approach.

## Immediate Next Action

Prove the gap existence lemma: `U'(top, D)(m) <-> exists gap gamma > m, gap_def_left D, D_between m gamma`. This is the single biggest remaining blocker. Start with the backward direction (gap -> U') which is simpler.

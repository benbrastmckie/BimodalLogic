# Phase 4C-W2 Handoff: Backward Direction Progress

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 4C-W2 (Lemma 9 Gap Detection Correctness)
**Session**: sess_1779414608_630458
**Date**: 2026-05-21

## Current State

### stavi_untl_gap_detection (EFGames.lean:2407)

The proof has been split into forward and backward directions via `constructor`.

**Forward direction** (line 2428): `sorry` -- entire forward direction pending.

**Backward direction** (lines 2429-2497): Substantially proved. Structure:
- Given: gamma (RDefinableGap), gap conditions (m < gamma, gap_definable_on_left, D-between, X^mu(gamma))
- Witness: s0 = any complement point (exists since cut is proper)
- **Condition (1) cut case**: PROVED. Uses no_sup to find y > u in cut, D on (m,y) from D-between + downward-closure.
- **Condition (1) complement case, neg-D witness**: PROVED. Uses complement_no_min + h_neg_init.
- **Condition (1) complement case, X witnesses**: `sorry` (line 2467). Requires showing stavi_temporal_truth M atomMap v X for complement points v from X^mu(gamma). This is the hardest sub-obligation.
- **Condition (2)**: PROVED. Uses complement_no_min + h_neg_init.
- **Condition (3)**: PROVED. Uses no_sup to find cut point above m, D from D-between.

### Key Remaining Sorries

1. **Forward direction** (line 2428): Full gap construction from FO table.
   - Cut definition: {x | forall u, m < u -> u <= x -> D(u)}
   - Need: nonempty (m in cut), proper (u_fail not in cut), downward-closed (by definition), no_sup (condition 1 argument), complement_no_min (condition 1 argument), gap_definable_on_left, r-definability, X^mu(gamma).
   - The no_sup argument was fully worked out in comments: apply condition (1) at sup for m < sup < s case; sup = m case contradicts existence of cut elements above m from condition (3).
   - The complement_no_min argument was also worked out: apply condition (1) at complement minimum, first disjunct contradicts not-in-cut.
   - X^mu(gamma) is the hardest piece: need to show X^mu at the gap from condition (1) second disjunct at complement points.

2. **Backward direction X at complement points** (line 2467): Need `forall v, u < v -> v < s0 -> stavi_temporal_truth M atomMap v X`.
   - This requires extracting X at individual M.carrier complement points from X^mu(gamma).
   - For X = base(top), this is trivially True.
   - For general X, this is the deep mathematical content.
   - The key uses of `stavi_untl_gap_detection.mpr` only need X = base(top) (neg case at line 2578).

### Build Status

`lake build Bimodal` passes with only sorry warnings (44 total, pre-existing). No compilation errors.

### Also Fixed

Converted orphaned doc comment at line 2743-2748 to section comment (`/-! ... -/`) to fix pre-existing build error.

## Immediate Next Actions

1. Close the backward direction X-at-complement sorry for the special case X = base(top) by showing temporal_truth_mu of top at any point is True.
2. Alternatively: factor out the backward direction for X = top as a separate easier lemma since that's what the neg case actually needs.
3. For the forward direction: implement the gap construction using the cut definition and verify all five gap axioms.

## Key Decisions Made

1. Split the proof into forward/backward via `constructor` instead of a single monolithic proof.
2. Extracted reusable helpers: `h_neg_init` (negation of initial segment condition), `h_compl_gt_m` (complement points above m).
3. Chose s0 = arbitrary complement point as the FO table witness for the backward direction. This works for conditions (2), (3), and the cut case of (1). The complement case of (1) requires X at points between u and s0.

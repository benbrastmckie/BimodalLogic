# Research Report: Task #273 — Last Blocker Analysis

**Task**: chronicle_gap_contradiction_proof
**Date**: 2026-06-09
**Mode**: Team Research (4 teammates)
**Session**: sess_1781025906_c3b3a1

## Summary

The last sorry at DiscreteStaviCompleteness.lean:338 (backward direction of `exist_sf_correct`) is confirmed architecturally unprovable at the standalone lemma level — `nf_exist_sf_guarded` does not encode the quantifier part of 2-var NFs, so the backward direction cannot determine which `sub_nf` the witness realizes from the formula alone. However, the critical strategic finding is that **this sorry is NOT on the publication critical path**: the models in `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean:512) explicitly lack `IsSuccArchimedean`, making the discrete bypass chain inapplicable to the actual completeness proof.

## Key Findings

### 1. The "Unprovable" Diagnosis Is Correct (Teammates A, B, C agree)

`nf_exist_sf_guarded` encodes only: (1) witness existence with atom-compatible 1-var NF, (2) correct ordering (Until/Since/equality), (3) a tautological interval guard. It does NOT encode `sub_nf.quant_assgn`. Multiple distinct sub_nfs with identical atom parts and ordering map to the same formula. At depth k >= 1, the backward direction cannot distinguish which quantifier assignment is realized.

### 2. The Sorry IS Closable via the Game Pipeline (Teammates A, B)

Despite being unprovable at the standalone lemma level, the full game pipeline provides the missing information. The approach:

1. Extract witness x from formula truth (case-split on Until/Since/equality)
2. Recover 1-var NF data via `char_k_correct` (IH)
3. Construct `discrete_universal_decomp` from NF bridge hypotheses (~40-60 new lines)
4. Apply `discrete_ghr93_proposition7` (sorry-free) for game wins at arbitrary n
5. Use `game_win_to_formula_agree` + `existential_transfer_from_nf` + `nf_fraisse_compression` for 2-var NF equality
6. Conclude via `nf_eval_unique`

**Estimated new code**: 200-350 lines (Tasks 4.2-4.3 of plan v10)

### 3. The Single-Model Problem (Teammate C)

The game infrastructure assumes two distinct models M and N. The sorry at line 338 operates within a single model. Closing the sorry requires constructing a reference model M' (possibly via Classical.choice) where `sub_nf` is known to be realized, then proving the game produces matching interval types. This is non-trivial but not insurmountable.

### 4. Critical Path Analysis (Teammate D) — THE KEY FINDING

**DiscreteStaviCompleteness.lean:338 is NOT on the critical path to `completeness_discrete`.**

The import chain: `completeness_discrete` <- `countermodel_discrete_reynolds_v2` <- `no_gaps_discrete_model_surgery` <- `gap_prior_UZ_contradiction` <- `US_expressively_complete_over_prior` <- `stavi_expressive_completeness` (GENERAL, sorry-tainted at StaviCompleteness.lean:2805).

The models in `gap_prior_UZ_contradiction` explicitly prove `NOT IsSuccArchimedean` (GoodStructuresModelSurgery.lean line 512). Therefore, `discrete_stavi_expressive_completeness` (which requires `IsSuccArchimedean`) cannot substitute for `stavi_expressive_completeness` on this path.

**The true publication-blocking sorry is StaviCompleteness.lean:2805** (`nf_exist_sf_guarded_backward` for general linear orders, not just discrete ones).

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A/B say closable, C says problematic | Both correct at different levels: closable via full pipeline (A/B), but requires non-trivial reference model construction (C). The single-model problem is real but addressable. |
| A/B propose 200-350 lines of work, D says it doesn't matter | D's strategic insight dominates: the work is technically viable but not on the critical path. The 200-350 lines would close a sorry that doesn't block publication. |

### Gaps Identified

1. **General case is the true blocker**: StaviCompleteness.lean:2805 needs `nf_exist_sf_guarded_backward` for ALL linear orders, not just discrete ones. The discrete game pipeline (Theorem 6, Proposition 7) doesn't help here.
2. **No analysis of the general case**: All 15 implementation cycles focused on the discrete bypass, but the general case may have a different (possibly simpler) proof structure.
3. **Reference model construction**: Neither the codebase nor the handoffs contain a concrete plan for constructing the Classical.choice reference model needed for the single-model problem.

### Recommendations

**Recommendation 1 (Highest Priority)**: Declare task 273 **substantially complete**. DiscreteGameTransfer.lean sorry-free (0 sorries, was 5) is genuine mathematical value — Theorem 6 and Proposition 7 for discrete orders are fully formalized. Mark the remaining sorry in DiscreteStaviCompleteness.lean as a known limitation.

**Recommendation 2**: Create a **new task** targeting StaviCompleteness.lean:2805 directly — the general `nf_exist_sf_guarded_backward`. This is the publication-blocking sorry. Research should focus on whether the general case can use the game pipeline (via `ghr93_forward_to_backward`, which is sorry-free for general orders too) or needs a different approach.

**Recommendation 3**: If the DiscreteStaviCompleteness.lean sorry is pursued later (low priority), follow the A/B approach: construct `discrete_bridge_hyps_to_univ_decomp` + `discrete_nf_exist_sf_guarded_backward` using the game pipeline with a Classical.choice reference model. Estimated 200-350 lines.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Implementation approaches | completed | high |
| B | Alternative patterns / prior art | completed | medium |
| C | Critic / gap analysis | completed | high |
| D | Strategic horizons | completed | high |

## References

- GHR93 (Gabbay, Hodkinson, Reynolds): Theorem 6, Proposition 7, characterization theorem
- StaviCompleteness.lean: lines 2353, 2435, 2805 (sorry sites)
- GoodStructuresModelSurgery.lean: line 512 (`NOT IsSuccArchimedean`)
- DiscreteGameTransfer.lean: sorry-free infrastructure
- NFGameBridge.lean: `discrete_nf_to_decomposition_agreement`, `existential_transfer_from_nf`

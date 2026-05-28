# Phase 3C Handoff: char_k Threaded, U(B,A) Construction Next

**Date**: 2026-05-27
**Session**: sess_1779931340_a5cbb4
**Phase**: 3C (char_k threading + U(B,A) witness)
**Status**: IN PROGRESS — 3C.1 and 3C.2 complete, 3C.3-3C.8 remaining

## What Was Done

### 3C.1: char_k Threading (COMPLETED)

Threaded `k_nf`, `char_k`, `char_k_correct`, and `char_k_depth` through the entire backward game call chain:

1. `ghr93_case_II` (CaseAnalysis.lean:1188) — consumes char_k for U(B,A)
2. `ghr93_cases_II_III_IV` (CaseAnalysis.lean:4274) — passes through to Case II
3. `ghr93_inductive_step` (CaseAnalysis.lean:4331) — passes through to cases
4. `ghr93_forward_to_backward_core` (Theorem6.lean:31) — reverts char_k_depth with r
5. `ghr93_forward_to_backward` (Theorem6.lean:179) — public API
6. `ghr93_forward_to_backward_rank_varying` (Theorem6.lean:235) — rank-varying variant

**Design decision**: Used `k_nf`-based (fixed NF depth) instead of rank-polymorphic:
- `k_nf : Nat` — NF depth from outer completeness induction
- `char_k : NormalForm sig k_nf 1 → StaviFormula` — characteristic formula constructor
- `char_k_correct : ∀ nf M t, stavi_temporal_truth M atomMap t (char_k nf) ↔ nf_eval_nf M k_nf 1 (fun _ => t) nf`
- `char_k_depth : ∀ nf, stavi_depth (char_k nf) + 2 ≤ r` — ensures U(B,sf_top) has depth ≤ r

**Why not rank-polymorphic**: `NormalForm sig r 1` where r is the game rank produces formulas with `stavi_depth ~ 2r`, which exceeds the game's rank-r preservation capability. The k_nf depth from the outer induction gives formulas with `stavi_depth ~ 2k_nf`, and `k_nf << r` in the completeness proof (r = game_depth sig (k_nf+1) >> 2k_nf).

### 3C.2: stavi_temporal_truth Bridge (COMPLETED — no code needed)

The bridge `stavi_truth_mu_at_point` already exists at GapDetection.lean:417:
```lean
stavi_temporal_truth_mu M atomMap r (extendPoint m) A ↔ stavi_temporal_truth M atomMap m A
```

### Key Finding: same_side Cannot Be Proved Even With char_k

**Nine approaches tried** in prior cycles (documented in handoff phase-3C-same-side-analysis-20260527.md) all fail. Additional analysis with char_k confirms: rank-r formula agreement between a'_big(k) and a_init(k) (from hform_abig_ainit) CANNOT determine their ordering relative to p_n, because:

- `std_untl B (.base Formula.top)` (depth r) detects "B-point above exists" but doesn't discriminate ordering
- The formula holds at both points below and points above p_n (if other B-points exist)
- No depth-r formula can distinguish "below p_n" from "above p_n" without additional structural assumptions

**Conclusion**: The `same_side` lemma is fundamentally unprovable from rank-r type agreement alone. The GHR93 resolution is to REPLACE e_n with the U(B,A) witness, making sel_pn_ord true by construction.

## Immediate Next Action

### 3C.3-3C.6: Replace e_n with U(B,A) Witness Construction

Inside `ghr93_case_II` (CaseAnalysis.lean), replace the e_n construction at lines ~1241-1270 with:

1. **Construct B** = char_k (nf_characteristic N k_nf 1 (fun _ => p_n))
   - B has stavi_depth ≤ r - 2 (from char_k_depth)

2. **Construct phi** = StaviFormula.std_untl B (.base Formula.top)
   - stavi_depth phi = stavi_depth B + 2 ≤ r

3. **For each k < n with n > 0**: prove phi holds at a_init(k) in N at rank r
   - If a_init(k) < extendPoint p_n: witnessed by p_n
   - All a_init(k) < extendPoint p_n because a_bwd is sorted and a_bwd(n) = extendPoint p_n, so a_bwd(k) ≤ a_bwd(n) = p_n for k < n

   Wait — are the selections sorted? They may not be! Spoiler's selections need not be sorted. Let me check...

   Actually in the current code, a_init(k) = a_bwd(k) for k < n. The selections a_bwd are NOT necessarily sorted. So a_init(k) may be above p_n.

   The GHR93 paper assumes sorted selections (or handles unsorted ones). If selections are not sorted, then a_init(k) < p_n is not guaranteed for k < n.

   **This changes the approach**: phi holds at a_init(k) only when a_init(k) < p_n. We transfer phi via tau to resp_tau(k). Since phi has depth ≤ r, the transfer is valid. Then:
   - phi true at a_init(k) iff phi true at resp_tau(k) (tau formula agreement)
   - phi true at a_init(k) implies a_init(k) < p_n (by definition of std_untl)
   - phi true at resp_tau(k) implies exists s > resp_tau(k) in M with B(s)
   - The witness s gives us a carrier point e_k above resp_tau(k)

   But the REVERSE doesn't hold: phi could be true at a_init(k) even when a_init(k) > p_n (if there's another B-point above a_init(k)).

   **Critical realization**: The GHR93 approach requires sorted selections. In our code, the "sorted" property comes from the fact that the backward game's selections can always be sorted without loss of generality (by permuting the response). This is Lemma 10 / ghr93_winning_condition_perm.

   Actually, re-reading the code: a_bwd is the SPOILER's choice. The SPOILER picks n+1 elements, and a_bwd(n) = p_n is a specific one (the last). The others (a_init(k) for k < n) can be anywhere in [d, y']. They are NOT necessarily below p_n.

4. **Alternative approach**: Instead of proving phi for all k, construct a single e_n from the rank-r tau formula transfer at a specific position. The GHR93 approach picks the maximum of all a_init(k), but our code picks a_bwd(n) = p_n which is NOT necessarily the maximum.

   Looking at GHR93 more carefully: the selections are a_0 < ... < a_n (SORTED in increasing order). So a_n IS the maximum. Our code's p_n = a_bwd(⟨n, ...⟩) is the LAST element (index n), but it's NOT necessarily the largest.

   Wait, but the proof extracts p_n from h_point at index n. The index n doesn't correspond to "the largest". It's just the element at index n.

   **However**: the GHR93 proof sorts selections. If Spoiler picks unsorted, Duplicator permutes her response. Our code handles this via ghr93_winning_condition_perm. So we CAN assume the selections are sorted.

   But the current code does NOT sort a_bwd. It just takes them as-is and assigns a_init(k) = a_bwd(k) for k < n.

   This is a fundamental issue with the current code structure. The GHR93 approach works with sorted selections.

## Key Decisions Made

1. char_k uses k_nf-based depth, not rank-polymorphic
2. char_k_depth hypothesis ensures formula transferability at rank r
3. stavi_truth_mu_at_point bridge exists (GapDetection.lean:417)
4. same_side is fundamentally unprovable — e_n replacement is required
5. The e_n replacement requires careful handling of sorted vs unsorted selections

## Files Modified

- `CaseAnalysis.lean`: Added char_k params to ghr93_case_II, ghr93_cases_II_III_IV, ghr93_inductive_step
- `Theorem6.lean`: Added char_k params to ghr93_forward_to_backward_core, ghr93_forward_to_backward, ghr93_forward_to_backward_rank_varying

## Build State

`lake build` passes. All existing sorries remain (no new ones added). The char_k params are threaded but not yet used in proofs.

## Sorries in CaseAnalysis.lean

| Line | Description | Status |
|------|-------------|--------|
| 426  | Case I ordering | Existing, not in Phase 3C scope |
| 1588 | same_side (Case A) | Phase 3C target — needs e_n replacement |
| 1968 | same_side (Case B) | Phase 3C target — needs e_n replacement |
| 2183 | b_resp vs p_n (Case B) | Phase 3C target |
| 2236 | Case B dead code sorry | Phase 3C target |
| 4268 | Cases III/IV winning condition | Phase 5 target |

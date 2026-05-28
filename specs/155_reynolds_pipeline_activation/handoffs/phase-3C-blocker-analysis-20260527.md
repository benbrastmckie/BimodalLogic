# Phase 3C Handoff: same_side Proved Mathematically False — Sorting Required

**Date**: 2026-05-27
**Session**: sess_1779931340_a5cbb4
**Phase**: 3C (char_k threading + U(B,A) witness)
**Status**: BLOCKED — same_side is mathematically false for unsorted selections

## Executive Summary

Exhaustive analysis (8+ approaches) proves that the `same_side` lemma at lines 1593, 1973, and the `b_resp vs p_n` goal at line 2188 of CaseAnalysis.lean are **mathematically false** for unsorted Spoiler selections. The GHR93 proof assumes sorted selections; our code does not sort. The fix requires restructuring ghr93_case_II to preprocess selections with sorting.

## Proof That same_side Is False

### Goal
```
(a'_big k < extendPoint p_n <-> a_init k < extendPoint p_n) /\
(a'_big k = extendPoint p_n <-> a_init k = extendPoint p_n)
```

### Available Hypotheses
- `hform_abig_ainit`: a'_big(k) and a_init(k) agree on ALL depth-r formulas in N
- `hord_big_sel_en`: resp_tau(k) < e_n <-> a'_big(k) < p_n (from big game ordering)

### Counterexample
Let a_init(k) = extendPoint p_n (Spoiler selected the same point at position k and position n). Then:
- a_init(k) < extendPoint p_n is FALSE
- a'_big(k) is Duplicator's N-side response in the big game to resp_tau(k). Since a'_big(k) and a_init(k) = extendPoint p_n agree on depth-r formulas, a'_big(k) has the same rank-r type as p_n. But a'_big(k) could be at a DIFFERENT position in the linear order.
- If a'_big(k) < extendPoint p_n: the biconditional `a'_big(k) < p_n <-> a_init(k) < p_n` becomes TRUE <-> FALSE, which is FALSE.
- This is possible: two points with the same depth-r type can be at different positions in a linear order.

More general argument: for any two points t1, t2 in a linear order that agree on ALL StaviFormulas of depth <= r, their ordering relative to a third point p can differ. This is because depth-r formulas detect the rank-r type (a finite combinatorial invariant), but the rank-r type does not determine absolute position. In an infinite structure, there are multiple realizations of the same rank-r type.

## Approaches Tried and Why They Fail

### 1. Formula Transfer with phi = std_untl B sf_top (depth <= r)
- B = char_k(nf_pn), phi = std_untl B (.base Formula.top)
- stavi_depth phi = stavi_depth B + 2 <= r (from char_k_depth)
- phi(t) = "exists B-point strictly above t"
- a_init(k) < p_n => phi(a_init(k)) TRUE (witnessed by p_n)
- By hform_abig_ainit: phi(a'_big(k)) <-> phi(a_init(k))
- Problem: phi(a'_big(k)) TRUE does NOT imply a'_big(k) < p_n. There could be other B-points above a'_big(k) even when a'_big(k) > p_n.

### 2. phi AND NOT psi (Until + neg Since)
- psi = std_snce B (.base Formula.top) = "exists B-point strictly below"
- chi = conj(phi, neg(psi)) = "B-point above, NO B-point below"
- Depth chi <= r (valid for transfer)
- Problem: p_n might not be the ONLY B-point. Other points with the same k_nf NF type could exist both above and below any given t, making chi unreliable.

### 3. tau_r2 (rank r+2 backward game) Direct Ordering
- tau_r2 played with rank_embed(a_init(0)),...,rank_embed(a_init(n-1)), then b-challenged with e_n_pt
- Gives ordering rank_embed(a_init(k)) < extendPoint(b_r2) <-> resp_r2(k) < rank_embed(e_n)
- Problem: b_r2 != p_n in general (Duplicator's response, not controllable). resp_r2(k) != rank_embed(resp_tau(k)) (different games). No projection from rank r+2 to rank r.

### 4. Playing Big Game with Different b-Challenges
- hwin_big b_resp gives ordering data, but produces different M-response (e_b != e_n)
- Cannot compare e_b with e_n without additional games

### 5. Constructing e_n from U(B,sf_top) Witness
- Get e_n_new > all resp_tau(k) where phi transfers
- Problem: e_n_new > resp_tau(k) for ALL k where a_init(k) < p_n, but ALSO for some k where a_init(k) > p_n (if phi happens to be true there). Cannot make sel_pn_ord selectively true.

### 6-8. Various Game Composition and Round Counting Approaches
- All fail because tau has n rounds handling n selections, but we need n+1 elements (n a_init + p_n) in the game simultaneously.

## Resolution: Sorting Preprocessing

### GHR93 Approach
GHR93 (pp. 115-116) assumes sorted selections a_0 < a_1 < ... < a_n where a_n = p_n is a carrier point. With sorted selections:
- All a_init(k) < p_n strictly (for k < n)
- sel_pn_ord becomes: TRUE <-> (resp_tau(k) < e_n) where e_n is the U(B,sf_top) witness
- Since e_n > resp_tau(n-1) >= resp_tau(k), both sides are TRUE
- Biconditional holds trivially

### Implementation Plan

#### Option A: Sort-then-generalize (preferred)
1. At the start of ghr93_case_II, find a permutation sigma such that `a_bwd ∘ sigma` is monotone (using Tuple.sort, already imported)
2. Identify the position of the point in the sorted sequence: sigma_inv(n)
3. Generalize the proof to handle the point at an ARBITRARY position (not just position n)
4. Prove the theorem for sorted selections
5. Use ghr93_winning_condition_perm to permute the result back

Complication: After sorting, the point position sigma_inv(n) might not be the LAST position (n). Elements above the point are gaps. The proof currently assumes the point is at position n.

Estimate: 500-800 lines of changes (significant refactor of the 1100-line ghr93_case_II proof).

#### Option B: Wrapper with point-at-max assumption
1. Prove a helper lemma: given any selections with at least one point, there exists a permutation that puts a maximal carrier point at the last position
2. Elements above this carrier point are all gaps (gaps can be above points in the extended carrier)
3. Modify ghr93_case_II to handle mixed point/gap selections above p_n

This requires understanding the structure of gaps vs points in the extended carrier above a given carrier point.

#### Option C: Restructure Case II to partition selections
1. Partition a_bwd into: elements below p_n (L), elements equal to p_n (E), elements above p_n (H)
2. For elements in L: use U(B,sf_top) transfer (resp_tau(k) < e_n by construction)
3. For elements in E: use NF-type equality (resp_tau(k) = e_n from formula agreement)
4. For elements in H: use dual argument S(B,sf_top) or direct gap properties

This avoids full sorting but requires careful case analysis. The H partition consists of gaps only (if p_n is the maximum carrier point in [d,y']), which simplifies the argument.

## Immediate Next Action

The successor should:
1. Verify whether ALL elements in a_bwd that are above extendPoint p_n are necessarily gaps (this would significantly simplify Option C)
2. If yes: implement Option C by partitioning selections and using gap properties for the "above" case
3. If no: implement Option A (full sorting with generalized point position)

## Current State

- Build passes with `lake build`
- No new sorries added (char_k parameters threaded but not yet consumed)
- 3 sorry sites in scope: lines 1593, 1973, 2188 of CaseAnalysis.lean
- 2 sorry sites NOT in scope: line 426 (Case I), line 4273 (Cases III/IV)

## Key Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (main target)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` (ghr93_winning_condition_perm, Tuple.sort import)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/TypeFormulas.lean` (rank_embed infrastructure)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean` (stavi_truth_mu_at_point)

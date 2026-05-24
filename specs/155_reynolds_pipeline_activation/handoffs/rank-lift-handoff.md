# Handoff: Rank Lift Infrastructure and d_consistency Restructuring

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779565373_9bf0c5
**Date**: 2026-05-23
**Status**: Partial -- infrastructure built, restructuring strategy documented

---

## 1. What Was Built

### 1.1 Sorry-Free Infrastructure (EFGames.lean)

All additions are in `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`.
Build passes, zero new sorries, zero new axioms.

**Rank embedding injectivity** (after rank_embed_lt, ~line 703):
- `rank_embed_injective`: If `rank_embed h a = rank_embed h b` then `a = b`.
  Uses `Sum.map_injective` and the fact that `rank_embed_gap` preserves the underlying `Gap` value.
- `rank_embed_ne`: Contrapositive form -- distinct elements have distinct embeddings.

**Rank lifting infrastructure** (after ghr93_duplicator_wins_round_mono, ~line 7120):
- `rank_embed_game_tuple`: Commutation lemma -- `rank_embed (game_tuple x y a b i) = game_tuple (rank_embed x) (rank_embed y) (rank_embed . a) b i`.
- `rank_embed_same_order_type`: If `same_order_type n tM tN` at rank r, then `same_order_type n (rank_embed . tM) (rank_embed . tN)` at rank r'.
- `rank_embed_gap_point_agreement`: Gap/point agreement transfers through rank_embed.
- `rank_embed_formula_agreement`: Formula agreement at depth <= r transfers from rank r to rank r' at rank-embedded positions. (Note: only depth <= r, not depth <= r'.)
- `ghr93_strategy_rank_lift`: Structural theorem showing rank-r strategy can produce rank-embedded responses.

### 1.2 What Was NOT Built

- Full GHR93 Lemma 10 rank monotonicity (requires gap characterization formula infrastructure)
- Gap characterization formula D_gap = (not-D and K+D) or (D and not-K-D)
- d_consistency_left/right restructuring (requires Lemma 10 infrastructure)
- Deletion of h_d_unique (depends on d_consistency restructuring)

---

## 2. Critical Analysis: Why the Handoff's Option A Doesn't Work as Stated

The previous handoff (d-consistency-restructure-handoff.md, Section 5, Option A) proposed:

> "If Duplicator wins G_{n;r}(M,xy; N,x'y'), then Duplicator wins G_{n;r+k}(...rank_embed endpoints...) with responses that are ALL rank-embeddings of rank-r elements."

**This statement is FALSE for the full ghr93_duplicator_wins at rank r+k.**

### 2.1 The Formula Agreement Gap

`ghr93_duplicator_wins` at rank r' requires `formula_agreement` at depth <= r'. At rank-embedded positions, formula evaluation at rank r' equals evaluation at rank r (by `rank_embed_stavi_truth_mu`). So formula agreement at rank-embedded positions at rank r' reduces to formula agreement at rank r.

But the rank-r game only provides formula agreement at depth <= r. For formulas of depth in (r, r'], the agreement is NOT guaranteed.

**Example**: A StaviFormula `std_untl(B, C)` of depth r+2 quantifies over ALL elements of M_r, including rank-r gaps. The truth of this formula at rank r depends on the structure of M_r around the evaluation point. Two elements with the same depth-r type can have different depth-(r+2) types, so formula agreement at depth > r cannot be inferred from the rank-r game.

### 2.2 Why K^-(not-D) Cannot Be Transferred via the Lifted Strategy

The d_consistency use case needs the K^-(not-D) formula (depth r+2) to transfer between the M-side and N-side game responses. The lifted strategy from rank r gives formula agreement only at depth <= r. Since K^-(not-D) has depth r+2 > r, the lifted strategy CANNOT transfer it.

### 2.3 What rank_embed_stavi_truth_mu Actually Gives

`rank_embed_stavi_truth_mu h e A : truth_{M_{r'}}(rank_embed(e), A) <-> truth_{M_r}(e, A)`

This relates truth at a SINGLE structure M across ranks. It does NOT relate truth between M and N. Formula agreement between M and N requires the game.

---

## 3. The Correct Approach

### 3.1 Overview

The correct approach uses the EXISTING rank-(r+2) forward strategy `h_fwd_r1` (which handles ALL Spoiler selections at rank r+2, not just rank-embedded ones) combined with GHR93 Lemma 10 to project responses back to rank r.

### 3.2 Strategy

**Step 1**: In d_consistency_left, instead of using h_fwd (rank r) and trying to prove response = d:

1. Take Spoiler's rank-r selection `a_pad` (with `a_pad(n) = c`)
2. Rank-embed each element: `rank_embed(a_pad(i))` at rank r+2
3. Apply h_fwd_r1 (rank r+2 game) to get responses `a'_r2(i)` at rank r+2
4. Show `a'_r2(n) = rank_embed(d)` -- this is the existing Claim 1 proof (lines 3189-3793, sorry-free for main case, 2 edge case sorries at 3759/3793)
5. Show each `a'_r2(i)` for i < n is a rank-embedding of a rank-r element (GHR93 Lemma 10 gap transfer)
6. Define `a'_full(i) = rank_embed_inverse(a'_r2(i))` at rank r
7. Verify winning condition at rank r transfers from rank r+2

**Step 2**: Verify the winning condition at rank r:
- `same_order_type`: rank_embed preserves order, so order at rank r+2 gives order at rank r (via rank_embed_lt + rank_embed_injective)
- `gap_point_agreement`: rank_embed preserves IsPoint/IsGap (via rank_embed_isPoint)
- `formula_agreement` at depth <= r: truth at rank_embed(e) at rank r' = truth at e at rank r (via rank_embed_stavi_truth_mu). The rank-(r+2) game gives depth <= r+2 agreement, which subsumes depth <= r.

### 3.3 GHR93 Lemma 10 Gap Transfer (the key missing infrastructure)

**Statement**: If Spoiler plays `rank_embed(g)` where `g` is a gap defined by formula D of depth <= r, and Duplicator's response `e'` satisfies formula agreement at depth <= r+2 with `rank_embed(g)`, then `e'` is also a rank-embedding of a rank-r gap.

**Proof idea** (from GHR93 Lemma 10):
1. Define gap characterization formula: `D_gap = (not-D and K+D) or (D and K-not-D)` where K+X = not-U(T, not-X) and K-X = not-S(T, not-X)
2. `stavi_depth(D_gap) = stavi_depth(D) + 1 <= r + 1 <= r + 2`
3. `D_gap` holds at `rank_embed(g)` in M at rank r+2 (because g is defined by D)
4. Formula agreement gives `D_gap(e')` in N at rank r+2
5. `D_gap(e')` implies `e'` is a gap defined by D, hence r-definable
6. Therefore `e' = rank_embed(some rank-r gap)`

**Infrastructure needed**:
- Definition of `K_plus` and `K_minus` operators on StaviFormulas
- Definition of `gap_char_formula D` = the characterization formula
- Proof that `gap_char_formula D` holds at a gap defined by D
- Proof that `gap_char_formula D` holding at a position implies it's a gap defined by D
- Depth bound: `stavi_depth(gap_char_formula D) <= stavi_depth(D) + 1`

**Estimated effort**: 200-300 lines

### 3.4 Alternative: Avoid Lemma 10 for Carrier Point Responses

For the specific use in d_consistency, if we can show that the rank-(r+2) responses (for i < n) are all CARRIER POINTS (not gaps), then no Lemma 10 is needed. Carrier points at rank r+2 are the same as carrier points at rank r (extendPoint x = rank_embed(extendPoint x)).

This might be achievable if:
- Spoiler's selections `a_pad(i)` for i < n are all carrier points
- Formula agreement between carrier points preserves the carrier-point property

However, Spoiler can play gaps, so this simplification doesn't work in general.

### 3.5 Alternative: Direct K^-(not-D) Semantic Argument Without Rank Lift

Instead of projecting h_fwd_r1's responses to rank r, prove t = d DIRECTLY using semantic properties of the continuation set.

1. From h_fwd (rank r), get response t at position n
2. Show t in S_C (continuation set) -- gives d <= t
3. Show K^-(not-D)(d) = TRUE at rank r (Since(T,D) false at d -- D fails cofinally below d)
4. If d < t: show K^-(not-D)(t) = FALSE at rank r (Since(T,D) true at t -- D holds on (d,t))
5. K^-(not-D) has depth r+2 > r, so this doesn't contradict the rank-r game's formula agreement

**This approach CANNOT prove t = d from the rank-r game alone.** The rank-r game is too weak. We MUST use h_fwd_r1 (rank r+2) and the restructured approach from 3.2.

---

## 4. Immediate Next Steps (Priority Order)

1. **Build gap characterization formula infrastructure** (~200-300 lines)
   - K_plus, K_minus operators on StaviFormulas
   - gap_char_formula definition
   - Depth bounds
   - Semantic correctness at gaps

2. **Build GHR93 Lemma 10 gap transfer** (~100-200 lines)
   - Using gap_char_formula + formula agreement
   - Show responses to rank-embedded gaps are rank-embeddings

3. **Restructure d_consistency_left/right** (~200 lines)
   - Remove h_d_unique parameter
   - Use h_fwd_r1 + Lemma 10 gap transfer
   - Project responses from rank r+2 to rank r

4. **Delete h_d_unique** (lines 2755-2859, removes 2 sorries)

5. **Update call sites** (lines 2860-2865)

---

## 5. Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (+207 lines, 0 new sorries)

## 6. Current State

- **Build**: Passes (lake build succeeds)
- **Sorry count**: Unchanged (1 in EFGames.lean at line 9640, 10+ in ExpressivenessGeneral.lean)
- **New theorems**: 7 (all sorry-free)
- **Key gap**: GHR93 Lemma 10 gap characterization formula not yet built

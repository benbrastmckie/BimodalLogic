# Phase 1 Implementation Spec v18: GHR93 Claim 1 — Exact Proof

**Task**: 155
**Date**: 2026-05-23
**Purpose**: Precise implementation guide for closing the 2 h_d_unique sorries

## GHR93's Exact Proof (from report 22, pp.115-117)

### Setup
- d = inf(S_C^N) where S_C^N = continuation_set x' y' (a_bwd ⟨n⟩). Already constructed.
- c = inf(S_C^M) where S_C^M is the cross-structure continuation set. NEEDS CONSTRUCTION.
- S_C^M uses the SAME formulas as S_C^N (those holding on (a_bwd(n), y') in N) but evaluates them in M.

### Claim 1: In the forward game at rank r+2, if Spoiler picks c and Duplicator responds with t, then t = d.

**Proof direction d-bar ≤ d (our d ≤ t, GHR93 Step 2.3):**
- Assume t < d for contradiction
- t < d = inf(S_C^N), so t ∉ S_C^N
- ∃ mu u, t < u ≤ d, ¬cont_holds(u) (from h_cofinal_failure_below_d at t)
- Extract formula A ≤ r: A holds on (a_bwd(n), y') in N, ¬A(u in N)
- Game Round 2: Spoiler picks carrier point p_u from N, Duplicator responds with b from M
- Formula agreement: ¬A(u) → ¬A(extendPoint(b) in M)
- Order at (n+1, n+2): t < u → c < extendPoint(b). So extendPoint(b) > c.
- c ∈ S_C^M and extendPoint(b) > c, so c < extendPoint(b) < y gives cont_holds_cross(extendPoint(b))
- cont_holds_cross(extendPoint(b)): A holds on (a_bwd(n), y') in N → A(extendPoint(b) in M) = TRUE
- Contradiction: A(extendPoint(b) in M) = TRUE vs ¬A(extendPoint(b) in M)

**Proof direction d ≤ d-bar (our t ≤ d, GHR93 Step 2.2):**
- Assume t > d for contradiction  
- c = inf(S_C^M): below c, cont_holds_cross fails cofinally
- M-side pigeonhole: extract D_M (single formula, depth ≤ r) failing cofinally below c in M
- Construct K⁻(¬D_M) = neg(std_snce(base(.bot.imp.bot), D_M)), depth ≤ r+2
- K⁻(¬D_M)(c in M) = TRUE: Since(⊤, D_M) at c is FALSE because D_M fails cofinally below c
- Game at rank r+2: K⁻(¬D_M)(rank_embed(c)) ↔ K⁻(¬D_M)(t_r2). So K⁻(¬D_M)(t_r2) = TRUE
- t_r2 ≥ rank_embed(d) (from Direction 1 applied at rank r+2)
- If t_r2 > rank_embed(d): D_M holds at all mu in (d, y') in N (continuation formula)
  So Since(⊤, D_M)(t_r2) = TRUE at any mu above rank_embed(d). Contradicts K⁻(¬D_M)(t_r2) = TRUE
- So t_r2 ≤ rank_embed(d). Combined with ≥: t_r2 = rank_embed(d).
- Project: construct rank-r winning condition from rank-(r+2) via rank_embed_stavi_truth_mu

## What Needs to Change in the Code

### Step 1: Define cross-structure cont_holds_cross (~10 lines)

Add after line 137 (after cont_holds definition):

```lean
private def cont_holds_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (a_n_N y'_N : ExtendedCarrier N atomMap r)
    (t_M : ExtendedCarrier M atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v : ExtendedCarrier N atomMap r,
      a_n_N < v → v < y'_N → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu M atomMap r t_M A
```

### Step 2: Define cross-structure continuation_set_cross (~10 lines)

```lean
private def continuation_set_cross {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x_M y_M : ExtendedCarrier M atomMap r)
    (a_n_N y'_N : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier M atomMap r) :=
  { t | inClosedInterval x_M y_M t ∧
    ∀ u : ExtendedCarrier M atomMap r,
      t < u → u < y_M → mu_holds u → cont_holds_cross a_n_N y'_N u }
```

### Step 3: Prove S_C^M properties (~40 lines)

Mirror the existing proofs:
- `continuation_set_cross_nonempty` (mirror of line 163)
- `continuation_set_cross_upward_closed` (mirror of line 175)
- `a_n_in_continuation_set_cross` — NOT applicable (a_n is in N, not M)

### Step 4: Construct c = inf(S_C^M) inside obtain_split_point_props (~80 lines)

In the `suffices h_exists` proof (line 1984+), replace the current c construction (which uses the game) with c = inf(continuation_set_cross x y (a_bwd ⟨n⟩) y').

Mirror the d construction (lines 1460-1614): 3-way case split on carrier-point minimum, carrier-point GLB, gap.

### Step 5: Prove c ∈ S_C^M and cofinal failure below c (~30 lines)

Mirror hd_in_SC (line 1701) and h_cofinal_failure_below_d (line 1714).

### Step 6: Direction 1 (d ≤ t) inside d_consistency_left (~60 lines)

Replace sorry 2 (line 1845, the d ≤ t' direction in current h_d_unique). The proof:
1. by_contra h_not_le (assume t' < d)
2. h_cofinal_failure_below_d t' ... h_not_le → get ⟨u, ht'u, hu_le_d, huy', hmu_u, h_not_cont_u⟩
3. Unfold ¬cont_holds to get ⟨A, hA_depth, hA_interval, hA_fail⟩
4. Extract carrier point p_u from mu_holds u
5. Play h_mono_left Round 2 with p_u → get ⟨b, hb_in, hcond⟩
6. Formula agreement at position (n+1, n+2): ¬A(extendPoint(b) in M)
7. Order at (n+1, n+2): u > t' → extendPoint(b) > c
8. c ∈ S_C^M and extendPoint(b) > c, extendPoint(b) < y → cont_holds_cross(extendPoint(b))
9. A(extendPoint(b) in M) = TRUE from cont_holds_cross
10. Contradiction

### Step 7: Direction 2 (t ≤ d) — harder, needs K⁻ formula (~100 lines)

This is sorry 1 (line 1821, the d < t' case inside the t' ≤ d direction). The proof uses the M-side pigeonhole formula:

1. Apply pigeonhole to M-side: cofinal cont_holds_cross failure below c gives pigeonhole chain, extracting D_M (single StaviFormula, depth ≤ r) failing cofinally below c in M
2. Construct K⁻(¬D_M) = StaviFormula.neg (StaviFormula.std_snce (StaviFormula.base (.bot.imp .bot)) D_M)
3. Verify stavi_depth(K⁻(¬D_M)) ≤ r+2
4. Prove K⁻(¬D_M)(c in M) = TRUE: unfold Since semantics, use cofinal D_M-failure
5. Play h_fwd_r1 with rank_embed(c) as one of Spoiler's selections → get t_r2
6. K⁻(¬D_M)(rank_embed(c)) = K⁻(¬D_M)(c) = TRUE (by rank_embed_stavi_truth_mu)
7. Transfer: K⁻(¬D_M)(t_r2) = K⁻(¬D_M)(rank_embed(c)) = TRUE
8. Show t_r2 ≥ rank_embed(d): apply Direction 1 at rank r+2
9. Show t_r2 ≤ rank_embed(d): if t_r2 > rank_embed(d), D_M holds at mu above d in N (it's a continuation formula), so Since(⊤, D_M)(t_r2) = TRUE, contradicting K⁻(¬D_M)(t_r2) = TRUE
10. So t_r2 = rank_embed(d). Contradiction with t > d (because the rank-(r+2) game places the response at rank_embed(d), but the assumption t > d means the rank-r game placed it above d — the rank-(r+2) game's response constrains the possible rank-r responses).

**NOTE on step 10**: The projection from t_r2 = rank_embed(d) to t = d needs careful handling. d_consistency_left's existential output only requires ∃ a'_full with a'_full(n) = d. We can construct such a'_full by defining a'_full(n) = d and using the rank-(r+2) winning condition projected to rank r. The rank-r game response t becomes irrelevant — we bypass it entirely by constructing the output directly from the rank-(r+2) game.

## Implementation Order

1. Steps 1-3: Cross-structure definitions + properties (low risk, ~60 lines)
2. Step 4: c = inf(S_C^M) construction (medium risk, ~80 lines, mirrors existing code)
3. Step 5: c properties (low risk, ~30 lines, mirrors existing code)
4. Step 6: Direction 1 in d_consistency_left (medium risk, ~60 lines, predicate-level)
5. Step 7: Direction 2 (high risk, ~100 lines, formula materialization + game transfer)
6. Cleanup: remove h_d_unique, update callers

## Key Infrastructure (all sorry-free)

- pigeonhole_definable_formula: line 625
- rank_embed_stavi_truth_mu: EFGames.lean:1050
- stavi_temporal_truth_mu for std_snce: EFGames.lean:877
- continuation_set_upward_closed: line 175
- ghr93_duplicator_wins_round_mono: EFGames.lean
- hd_in_SC: line 1701 (reference for mirror)
- h_cofinal_failure_below_d: line 1714 (reference for mirror)

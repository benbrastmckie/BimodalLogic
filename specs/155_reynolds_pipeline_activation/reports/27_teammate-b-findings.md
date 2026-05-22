# Teammate B Findings: Infrastructure Inventory & Alternative Approaches

**Task**: 155 (Reynolds Pipeline Activation)
**Angle**: Existing Lean infrastructure and alternative proof strategies for h_d_unique
**Date**: 2026-05-22

## Key Findings

### 1. Complete Infrastructure for K⁻(¬D) Formula Construction

The formula K⁻(¬D) can be built from existing StaviFormula constructors:

```lean
-- K⁻(¬D) = neg(std_snce(base top, D))
-- where top = Formula.bot.imp Formula.bot (defined at Formula.lean:112)
let K_neg_D := StaviFormula.neg (StaviFormula.std_snce (.base Formula.top) D)
```

**Depth calculation** (verified from definitions):
- `stavi_depth (.base Formula.top) = operator_depth Formula.top = max (operator_depth .bot) (operator_depth .bot) = 0`
- `stavi_depth (.std_snce (.base Formula.top) D) = max 0 (stavi_depth D) + 2 = stavi_depth D + 2`
- `stavi_depth (.neg (…)) = stavi_depth (…) = stavi_depth D + 2`
- With `stavi_depth D ≤ r`, we get `stavi_depth K_neg_D ≤ r + 2` ✓

**Semantics** (from EFGames.lean:877-882):
```
std_snce A B at t = ∃ s < t, mu_holds s ∧ A(s) ∧ ∀ u ∈ (s,t), mu_holds u → B(u)
```
So `Since(⊤, D)(t)` = ∃ mu-point s < t, ∀ mu-point u ∈ (s,t), D(u) = "D holds on a final segment of mu-points below t"

And `K⁻(¬D)(t) = ¬Since(⊤, D)(t)` = "D fails cofinally below t among mu-points"

### 2. rank_embed_stavi_truth_mu — The Truth Transfer Bridge (EFGames.lean:1050)

```lean
theorem rank_embed_stavi_truth_mu {sig} {M} {atomMap} {r r'} (h : r ≤ r')
    (e : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r' (rank_embed h e) A ↔
    stavi_temporal_truth_mu M atomMap r e A
```

This is the key bridge: a formula's truth at `rank_embed(c)` in M_{r+2} equals its truth at `c` in M_r. This means if we construct K⁻(¬D) with `stavi_depth ≤ r+2`, we can evaluate it at `rank_embed c` in the rank-(r+2) game and transfer the result back to `c` in the rank-r structure.

### 3. Game Winning Condition Structure

`ghr93_winning_condition` (EFGames.lean:6878) = `same_order_type ∧ gap_point_agreement ∧ formula_agreement`

`formula_agreement` (EFGames.lean:6855):
```lean
∀ (i : Fin (n + 3)) (A : StaviFormula), stavi_depth A ≤ r →
    (stavi_temporal_truth_mu M atomMap r (tM i) A ↔
     stavi_temporal_truth_mu N atomMap r (tN i) A)
```

When the game is at rank r+2, formula_agreement gives: for all A with `stavi_depth A ≤ r+2`, truth agrees. So K⁻(¬D) with depth ≤ r+2 is within budget.

### 4. h_fwd_r1 Signature (ExpressivenessGeneral.lean:1445)

```lean
h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
  (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
  (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y')
```

This is a rank-(r+2) game on rank-embedded endpoints. The game tuple positions are in `ExtendedCarrier M atomMap (r+2)` and `ExtendedCarrier N atomMap (r+2)`. When Spoiler picks `rank_embed c`, Duplicator's response e satisfies `formula_agreement` at rank r+2 — i.e., for all A with `stavi_depth A ≤ r+2`, truth at `rank_embed c` ↔ truth at e.

### 5. The Density Problem is CRITICAL

The Round 14 handoff identified that `pigeonhole_definable_formula` requires universal cofinal failure (`∀ p ∈ cut, ...`), which fails when d is a carrier-point minimum with cont_holds at d.

**Analysis**: This is not a density issue per se. The issue is that when d is a carrier-point minimum of S_C (Case 1, line 1480), d ∈ S_C, so cont_holds holds at d. This means ALL rank-r formulas that hold on (a_n, y') ALSO hold at d. So no formula A with depth ≤ r can fail at d itself. The pigeonhole chain requires failure points, but d breaks the chain.

**However**: The h_d_unique proof doesn't actually need pigeonhole_definable_formula. It needs a SINGLE formula that separates d from t'. The question is: can we build such a formula without the universal pigeonhole?

### 6. Alternative Approach: Direct Semantic Separation (No Pigeonhole Needed)

The key insight is that h_d_unique has the following hypotheses:
- `hd_in_SC : d ∈ S_C` (just proved in Round 14)
- `h_cofinal_failure_below_d : ∀ s < d, ∃ mu-point u ∈ (s, d] with ¬cont_holds u` (just proved in Round 14)
- `ht'_form : ∀ A, stavi_depth A ≤ r → (truth t' A ↔ truth d A)` (hypothesis)

The GHR93 argument goes:
1. d ∈ S_C means cont_holds holds at all mu-points in (d, y').
2. h_cofinal_failure_below_d means cont_holds fails cofinally below d.

For the h_d_unique proof, we DON'T need pigeonhole. We need:

**Separation of d from t' (when d < t')**:
- Since d < t' and d ∈ S_C, cont_holds holds on (d, y'), hence at t' (if mu_holds t').
- But if t' ∈ S_C too (by upward closedness), then we'd need d ≤ t' from hd_glb.
- Wait — this is already in the proof structure. The actual blocker is the case where d < t' AND t' ∉ S_C, which shouldn't happen since S_C is upward-closed.

Actually, re-reading the proof at lines 1774-1821: the first sorry (t' ≤ d direction) has established that if s ∈ S_C with s < t', then t' ∈ S_C, hence d ≤ t'. The contradiction from d < t' is the blocker — we need to show this leads to a formula separating them.

**The actual needed formula**: When we know d < t' and want to derive a contradiction:
- cont_holds holds at all mu-points in (d, y') (from d ∈ S_C)  
- In particular, if t' is a mu-point, cont_holds holds at t'
- But then t' ∈ S_C (since t' ∈ [x', y'] and the tail condition holds: for u ∈ (t', y'), u > d, so u is above S_C's infimum, and d ∈ S_C gives cont_holds at u)
- Then d ≤ t' (from hd_glb), contradicting d < t'... wait, but the code ALREADY has this at line 1786-1789.

Wait — the sorry is at line 1821, inside the case `d < t'` (line 1790). The code reached: d < t' and d ≤ t' (from hd_glb of t' ∈ S_C). These two are consistent (d < t' implies d ≤ t'). The contradiction should come from somewhere else.

Let me re-read: at line 1787, rcases on `hd_le_t' : d ≤ t'`:
- `hd_eq_t'` (d = t'): contradiction with s < t' = d ≤ s
- `hd_lt_t'` (d < t'): **THIS IS THE SORRY** at line 1821

So the actual blocker is: we've derived d < t' AND t' ∈ S_C AND d = inf(S_C) AND s < t', s ∈ S_C... and the code splits on whether d = t' or d < t'. When d < t', we have d < t', t' ∈ S_C, d = inf(S_C). But d < t' with t' ∈ S_C and d = inf(S_C) ≤ t' is perfectly consistent — we already KNOW d ≤ t'. The issue is that we ASSUMED s < t' for contradiction, so we have s ∈ S_C, s < t', d ≤ s. But d < t' doesn't help complete the contradiction.

The real issue is: the proof at line 1776-1821 is trying to show t' ≤ d by showing t' is a lower bound of S_C (hd_is_inf). It assumes s ∈ S_C with s < t' for contradiction. It derives t' ∈ S_C (upward-closedness), hence d ≤ t'. Then it cases on d = t' vs d < t'. When d = t', s < t' = d contradicts d ≤ s. When d < t', the current proof can't find a contradiction.

**The missing contradiction when d < t'**: We know:
- s ∈ S_C, s < t'  
- d ≤ s (from d = inf(S_C) and s ∈ S_C)
- d < t' (assumption)
- t' ∈ S_C (from upward-closedness)

Can we get a contradiction? We have d ≤ s < t', d < t', and both s, t' ∈ S_C. There's no contradiction from these purely order-theoretic facts. So the rank-r formula separation IS needed.

### 7. A DIFFERENT Architecture: Avoid Pigeonhole, Use Game Directly

Instead of materializing a formula D via pigeonhole and then building K⁻(¬D), consider using h_fwd_r1 DIRECTLY as a separation tool.

**Strategy**: To show t' ≤ d (assuming s ∈ S_C, s < t' for contradiction):

1. We have d < t' and want a contradiction with rank-r formula agreement between d and t'.
2. d ∈ S_C means cont_holds at d. Since s ∈ S_C with d ≤ s < t', cont_holds holds at s.
3. h_cofinal_failure_below_d gives: for any element below d, cont_holds fails cofinally.
4. **Key**: cont_holds at d but cont_holds fails cofinally below d. This is a SEMANTIC discontinuity at d.
5. Since d and t' have the same rank-r formulas (ht'_form), and d < t', we need rank-(r+2) to separate them.
6. Play h_fwd_r1: Spoiler puts rank_embed(c) into the rank-(r+2) game. Duplicator responds with some e.
7. From Claim 1 (the original h_d_unique argument), e should equal rank_embed(d). But this IS what we're trying to prove.

This circularity is the fundamental issue. We can't use h_d_unique to prove h_d_unique.

### 8. The Correct Path: Weaken pigeonhole_definable_formula

Solution A from Round 14 handoff is correct. Create a variant that only requires failure for p with extendPoint p < d (strictly below d), not for p at d itself. The chain argument goes through unchanged since:

1. When d is a carrier-point minimum of S_C, the cut = {p : extendPoint p ≤ d} includes d's point.
2. The pigeonhole chain starts at some p₀ below d (from h_cofinal_failure_below_d).
3. Each step produces u ≥ p₀ still in the cut with a formula failure.
4. The chain stays at u with extendPoint u < d (since cont_holds holds at d, no formula can fail at d).
5. After K+1 steps, pigeonhole gives a repeat → single formula D failing cofinally below d.

The variant's signature would be:

```lean
private theorem pigeonhole_definable_formula_below_d
    -- ... same as pigeonhole_definable_formula but:
    (d : ExtendedCarrier N atomMap r)
    (hd_in_SC : d ∈ S_C)
    (h_cofinal_failure_below : ∀ p : N.carrier,
      p ∈ inf_carrier_cut S_C →
      (extendPoint p : ExtendedCarrier N atomMap r) < d →  -- STRICT inequality
      ∃ (u : N.carrier), p ≤ u ∧
        u ∈ inf_carrier_cut S_C ∧
        (extendPoint u : ExtendedCarrier N atomMap r) < d ∧  -- stays below d
        ∃ (A : StaviFormula), stavi_depth A ≤ r ∧ ... ∧ ¬ stavi_temporal_truth N atomMap u A) :
    ∃ (D : StaviFormula), stavi_depth D ≤ r ∧ ...
```

The chain stays below d because:
- cont_holds at d means ALL formulas from (a_n, y') hold at d
- So the failure point u from h_cofinal_failure_below_d is at extendPoint u ≤ d
- If extendPoint u = d, cont_holds at d → no formula fails at d → contradiction
- So extendPoint u < d

### 9. EFGameTactics.lean Status (Task 195)

File exists at `Theories/Bimodal/Automation/EFGameTactics.lean` (218 lines). Exports:
- `simp_game_tuple` — simp rewrite set for game_tuple normalization
- `game_tuple_unfold` — dite-based unfold
- `pivot_chain_order'` / `pivot_chain_order_rev'` — pair-based convenience wrappers
- `order_refl` / `order_refl_pair` — diagonal case closer
- `gap_point_agreement_of_cases` — 4-way dispatch for gap/point
- `formula_agreement_of_cases` — 4-way dispatch for formulas
- `same_order_type_grid` — grid setup macro
- `extract_order` — ordering extraction helper

All imported via `import Bimodal.Metalogic.WeakCanonical.EFGames`. Ready for use.

### 10. No Prior Art for EF Game Formalization in Lean

Web search found:
- [LeanearTemporalLogic](https://github.com/mrigankpawagi/LeanearTemporalLogic) — basic LTL formalization, no EF games
- [Lean4 Logic Formalization](https://formalizedformallogic.github.io/Book/) — propositional/first-order logic, no EF games
- [Obendrauf 2024](https://drops.dagstuhl.de/storage/00lipics/lipics-vol309-itp2024/LIPIcs.ITP.2024.28/LIPIcs.ITP.2024.28.pdf) — coalition logic, unrelated
- Mathlib's `Mathlib.Combinatorics.Pigeonhole` — weighted pigeonhole, potentially useful for chain argument

No Lean 4 formalization of EF games, temporal expressive completeness, or game-theoretic model theory exists. This project appears to be the first.

## Recommended Approach

**Phase 1 h_d_unique resolution** (in order of execution):

1. **Create `pigeonhole_definable_formula_strict`** (~30-50 lines): A variant of `pigeonhole_definable_formula` with the weakened precondition (failure only for p with extendPoint p < d). The proof is nearly identical — the chain argument doesn't change.

2. **Derive D from h_cofinal_failure_below_d** (~20-30 lines): Bridge from `h_cofinal_failure_below_d` to the weakened pigeonhole precondition. For any p in the cut with extendPoint p < d, h_cofinal_failure_below_d gives a failure mu-point u with p < u ≤ d. Need to show u's carrier-point representative is in the cut and < d.

3. **Construct K⁻(¬D)** (~10 lines): `let K_neg_D := .neg (.std_snce (.base Formula.top) D)`

4. **Prove Since(⊤,D) semantics at d and t'** (~40-60 lines):
   - At d: Since(⊤,D) is FALSE (D fails cofinally below d from pigeonhole output)
   - At t' (when d < t'): Since(⊤,D) is TRUE (witness = any mu-point s with d ≤ s < t', and D holds on (s, t') from d ∈ S_C)

5. **Derive formula contradiction** (~20-30 lines): K⁻(¬D) true at d, false at t'. depth ≤ r+2 ≤ r+2. But ht'_form gives rank-r agreement, not rank-(r+2). Need to use h_fwd_r1 game to get rank-(r+2) separation.

6. **Use h_fwd_r1 for rank-(r+2) separation** (~40-60 lines): Play the rank-(r+2) game. Spoiler challenges Duplicator to match c. The Duplicator's response gives formula agreement at rank r+2 between rank_embed(c) in M and some response e in N. By rank_embed_stavi_truth_mu, K⁻(¬D) at rank_embed(c) = K⁻(¬D) at c. The response e must agree on K⁻(¬D). But K⁻(¬D)(d) ≠ K⁻(¬D)(t'). The game response pins down the position.

**Total estimate for h_d_unique**: 160-240 lines.

## Evidence/Examples

All lemma names and line numbers verified against the current codebase (commit 22fd249):

| Infrastructure | File | Line | Status |
|---------------|------|------|--------|
| `StaviFormula.neg`, `.std_snce` | StaviConnectives.lean | 143, 149 | Available |
| `stavi_depth` for neg, std_snce | EFGames.lean | 189, 192 | depth = inner + 0 / + 2 |
| `stavi_temporal_truth_mu` for std_snce | EFGames.lean | 877 | ∃ s < t, mu(s) ∧ A(s) ∧ ∀u... |
| `rank_embed_stavi_truth_mu` | EFGames.lean | 1050 | Bidirectional transfer |
| `ghr93_duplicator_wins` | EFGames.lean | 6901 | Game structure |
| `formula_agreement` | EFGames.lean | 6855 | rank-r agreement |
| `pigeonhole_definable_formula` | ExpressivenessGeneral.lean | 625 | Needs weakening for Case 1 |
| `hd_in_SC` | ExpressivenessGeneral.lean | 1701 | d ∈ S_C (Round 14) |
| `h_cofinal_failure_below_d` | ExpressivenessGeneral.lean | 1714 | Failure below d (Round 14) |
| `operator_depth Formula.top` | Table.lean | 42 | = 0 |

## Confidence Level

**High** on infrastructure inventory — all pieces exist and types align.

**Medium-High** on the weakened pigeonhole approach — the chain argument is nearly identical to the existing proof.

**Medium** on the full h_d_unique proof — the game-to-formula bridge (step 6) requires careful construction. The h_fwd_r1 game gives formula agreement between rank_embed(c) and some response e, but connecting e to d (vs t') is non-trivial. This is essentially the same Claim 1 argument we're trying to prove, suggesting a more careful reading of GHR93's proof is needed to avoid circularity.

**Key risk**: Steps 5-6 may involve circularity. The proof needs to show the game response MUST be d (not t'), which IS h_d_unique. The GHR93 paper resolves this by constructing C' = ¬C ∨ K⁻(¬C) where C is the continuation predicate, and showing C' has rank r+1 (our r+2). The proof then says "d satisfies C' but d̄ < d would not" — this is a DIRECT formula argument, not a game argument. The formula C' separates d from any t' ≠ d via the infimum property, without needing to play the game first. The game is only used in the OUTER proof (d_consistency_left/right) to show the game response equals d.

**Revised recommendation**: The h_d_unique proof should be a PURE formula argument: construct K⁻(¬D), show it's true at d and false at t' (or vice versa), and contradict ht'_form since K⁻(¬D) has depth ≤ r+2 > r. Wait — ht'_form gives rank-r agreement, but K⁻(¬D) has depth r+2. So the contradiction needs rank-(r+2) agreement, which ht'_form doesn't provide!

**CRITICAL REALIZATION**: h_d_unique's hypothesis `ht'_form` only gives rank-r agreement. K⁻(¬D) has depth r+2 > r. So we CANNOT directly contradict ht'_form with K⁻(¬D). We need an INDIRECT argument:

1. Construct K⁻(¬D) with depth ≤ r+2
2. K⁻(¬D)(d) ≠ K⁻(¬D)(t') semantically
3. Use h_fwd_r1 (the rank-(r+2) game) to play: Spoiler puts rank_embed(c) in, gets response e
4. e agrees with rank_embed(c) on ALL depth ≤ r+2 formulas, including K⁻(¬D)
5. By rank_embed_stavi_truth_mu: K⁻(¬D)(rank_embed c) ↔ K⁻(¬D)(c)
6. So K⁻(¬D)(e) ↔ K⁻(¬D)(c)
7. By hcd_form (rank-r agreement c ↔ d): ... but K⁻(¬D) is rank r+2, not r!

This doesn't work directly. GHR93 handles this differently: Claim 1 is about the game response, not about rank-r agreement. The claim says: in ANY play of the (m; r')-game with r' ≥ r, the response to c is d. The proof works because C' has rank r+1 (our r+2), within the r' budget.

So h_d_unique should NOT be phrased in terms of rank-r formula agreement. It should be about the game: "in any play of the rank-(r+2) game where Spoiler places c, the response is d." Then d_consistency uses this to conclude a'_full(n) = d.

**BUT**: h_d_unique IS currently phrased as a formula agreement property (lines 1741-1750). The current formulation says: if t' has same rank-r type as d, same gap/point status, same boundary position, then t' = d. This IS the right formulation for Claim 1, but the proof needs rank-(r+2) formulas, which t' might not agree with d on.

The resolution: h_d_unique doesn't need t' to agree with d on rank-(r+2) formulas. It only needs: K⁻(¬D) separates them at rank r+2, so they DON'T have the same rank-(r+2) type. But by hypothesis they DO have the same rank-r type. This isn't a contradiction. The proof needs to use the GAME to show that same rank-r type + same position → same rank-(r+2) type → equality.

Wait, re-reading GHR93 Claim 1 (p.116): "As the strategy is winning, any rank r' temporal formula satisfied by one of V's choices must also be satisfied by the corresponding choice of Ξ." This works because the game is at rank r' ≥ r+1 (our r+2). The formula C' = ¬C ∨ K⁻(¬C) has rank r+1. Since the winning condition requires rank r' formula agreement, and r' ≥ r+1, C' must agree between c and d. But C' TRUE at c (by infimum properties) and FALSE if d < d̄. Hence d = d̄.

In our formalization: the game response e to `rank_embed(c)` has rank-(r+2) agreement with `rank_embed(c)`. The h_d_unique proof needs to show that this game response, when projected back to rank r, equals d. This IS what d_consistency_left/right prove. h_d_unique is used BY d_consistency to show that the response is unique. But h_d_unique's proof should use C' = K⁻(¬D) to show that if t' ≠ d, then t' disagrees with d on a rank-(r+2) formula, hence cannot be a game response in a rank-(r+2) game.

The h_d_unique proof doesn't use the game. It uses the FORMULA C' to show that d and t' are distinguishable at rank r+2. Then d_consistency uses the GAME h_fwd_r1 to show the game response must equal d (since any other element is distinguishable at rank r+2).

So h_d_unique is: given t' with same rank-r type, gap/point, boundary as d, if t' ≠ d, then K⁻(¬D) distinguishes them at rank r+2. But the conclusion is t' = d, so the hypothesis must include rank-(r+2) agreement OR we must derive it.

**FINAL ANSWER**: h_d_unique's current formulation (rank-r agreement → t' = d) is UNPROVABLE without additional hypotheses. It needs EITHER:
- (a) rank-(r+2) agreement between t' and d (not just rank-r), OR
- (b) a game hypothesis (t' is a game response to c in a rank-(r+2) game)

Option (b) is what GHR93 actually uses. The current formulation with only rank-r agreement is too weak. This is the fundamental blocker.

**Recommendation**: Restructure h_d_unique to take h_fwd_r1 as a parameter and use the game directly. Or add `ht'_form_r2 : ∀ A, stavi_depth A ≤ r+2 → (truth t' A ↔ truth d A)` as a hypothesis (which d_consistency can provide from the game winning condition).

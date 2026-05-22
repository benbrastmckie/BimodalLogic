# Teammate A Findings: GHR93 Claim 1 Proof Extraction and Lean Mapping

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Angle**: Primary — Extract exact GHR93 Claim 1 proof, map to Lean constructs, identify resolution path

## Key Findings

### Finding 1: The GHR93 Formula C Is Already Encoded — It's `cont_holds`

In GHR93 (Definition 8.8, p.112), C = X_{(α_n, y')} is defined as the **disjunction** of rank-r type formulas X_v for all (non-gap) points v in (α_n, y'). Since there are finitely many rank-r types (NormalForm finiteness), C is effectively a single rank-r formula.

The Lean code's `cont_holds a_n y' t` (line 129-137) is the **predicate-level encoding** of C(t):

```lean
private def cont_holds ... (t : ExtendedCarrier N atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v, a_n < v → v < y' → mu_holds v → stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A
```

This says: "t satisfies every depth-≤-r formula that holds at ALL mu-points in (a_n, y')." This is equivalent to "t has the interval type X_{(α_n, y')}" — if we define C as the conjunction of all depth-≤-r formulas holding on (a_n, y'), then C(t) ⟺ cont_holds(t).

**The encoding is semantically correct but not syntactic**: `cont_holds` is a Prop (predicate), not a `StaviFormula`. This is the root of the formalization gap.

### Finding 2: The GHR93 Claim 1 Proof Uses Only Two Properties of C

Re-reading GHR93 p.116, Claim 1's proof needs exactly:

1. **C'(c) holds in M_r** where C' = ¬C ∨ K⁻(¬C) and c = inf(S_C in M)
2. **Formula transfer**: C' has rank r+1, so the rank-(r+2) forward game transfers C'(c) to C'(d)
3. **Analysis of C'(d)**: C'(d) ⟹ d ≤ d̄
4. **Contradiction from d < d̄**: produces a Round 2 challenge Duplicator cannot answer

The proof does NOT need C as a named formula for steps 1, 3, 4 — those can be done entirely at the predicate level using `cont_holds`, `hd_in_SC`, `h_cofinal_failure_below_d`, and `continuation_set_upward_closed`.

**Step 2 is the ONLY step that needs a formula** — and it needs C' (not C!) to be a `StaviFormula`.

### Finding 3: K⁻(¬C) = ¬S(⊤, C) in Stavi Terms

The GHR93 notation K⁻(X) means "X holds cofinally in the past" = ¬S(⊤, ¬X). So:

- K⁻(¬C) = ¬S(⊤, ¬(¬C)) = ¬S(⊤, C) 
- C' = ¬C ∨ K⁻(¬C) = ¬C ∨ ¬S(⊤, C)

In Stavi terms, S(⊤, C) = `std_snce C_formula top_formula` where:
- `top_formula` = `base (.bot.imp .bot)` (depth 0)
- `std_snce` adds 2 to the depth: `stavi_depth(std_snce A B) = max(stavi_depth A)(stavi_depth B) + 2`

So if C has depth r (as a StaviFormula), then:
- `std_snce C top` has depth `max(r, 0) + 2 = r + 2`
- `neg(std_snce C top)` has depth `r + 2`
- C' as a disjunction would have depth `max(r, r+2) = r + 2`

**Stavi depth of C' = r + 2, which matches the h_fwd_r1 rank budget.**

Lean encoding of K⁻(¬C): `neg (std_snce (neg (base (.bot.imp .bot))) C_formula)` — wait, let me re-derive:

- S(⊤, C)(t) = ∃ s < t, mu_holds s ∧ ⊤(s) ∧ ∀ u ∈ (s,t), mu_holds u → C(u)
- K⁻(¬C)(t) = ¬S(⊤, C)(t) = "there is no mu-point s < t after which C holds at all mu-points in (s,t)"
- This means: ¬C holds cofinally below t — for every mu-point s < t, ∃ mu-point u ∈ (s,t) with ¬C(u)

The Lean `std_snce` encoding: `std_snce A B` at t means ∃ s < t, mu_holds s, A(s), ∀ u ∈ (s,t), mu_holds u → B(u).

So S(⊤, C) in Lean is: `std_snce (base (.bot.imp .bot)) C_formula`.

And K⁻(¬C) = ¬S(⊤, C) = `neg (std_snce (base (.bot.imp .bot)) C_formula)`.

### Finding 4: C Need NOT Be Materialized as a Single Formula

The GHR93 argument for Claim 1 can be restructured to avoid materializing C as a single formula. Here's why:

**Direction 1 (d ≤ d̄)**: We need C'(c) in M ⟹ C'(d) in N ⟹ d ≤ d̄.

But we don't actually need to TRANSFER a specific formula. Instead, the h_d_unique proof already has:
- `ht'_form`: t' and d agree on ALL depth-r formulas
- The rank-(r+2) game `h_fwd_r1` preserves depth-(r+2) formulas

If t' > d (assuming for contradiction), then we can show t' and d DISAGREE on some depth-(r+2) formula — specifically, the Since formula S(⊤, D) where D is a depth-r formula from `pigeonhole_definable_formula` or from `h_cofinal_failure_below_d`.

But wait — the pigeonhole formula D already exists! It's produced by `pigeonhole_definable_formula` at line 625. The issue is its PRECONDITION (`h_cofinal_failure` for ALL cut points), not the formula itself.

### Finding 5: The Pigeonhole Precondition Issue Can Be Bypassed

The Round 14 handoff identified that `pigeonhole_definable_formula` requires `h_cofinal_failure` for ALL p in the cut, but when d is a carrier-point minimum, the point p₀ at d is the maximum of the cut and has no failure above it.

**Three bypass strategies**:

**Strategy A (Weakened pigeonhole — recommended by Round 14)**: Create a variant `pigeonhole_definable_formula'` that only requires failure for p with `extendPoint p < d`. This is sound because the chain never visits p₀.

**Strategy B (Don't use pigeonhole at all — use cont_holds directly)**: Since cont_holds is a CONJUNCTION over all depth-r formulas, and the proof only needs ONE separating formula, we can avoid pigeonhole entirely:

When d < t' (need contradiction):
- d ∈ S_C, so cont_holds at all mu-points in (d, y')
- t' shares d's rank-r type, so cont_holds at t' too
- But t' < d means t' ∉ S_C (by infimum), so ∃ mu-point u with t' < u ≤ d where ¬cont_holds(u)
- ¬cont_holds(u) means ∃ formula A of depth ≤ r, A holds on (a_n, y') but ¬A(u)
- This specific A already separates! S(⊤, A) is true at t' (if d is a witness mu-point with A on (d, t') — wait, this needs d to be a mu-point)
- If d is a gap, this doesn't work directly

Actually, Strategy B has issues with the gap case. Let me reconsider.

**Strategy C (Direct game argument — no formula at all)**: Use h_fwd_r1 directly:

1. Play the rank-(r+2) forward game with c (the M-side infimum) as one of Spoiler's choices
2. By Claim 1 (at the game level), the response must be d̄ (the N-side infimum)
3. But the h_d_unique proof already ASSUMES a response t' with the right properties
4. So t' = d̄ = d

**The problem**: This is circular! We're trying to PROVE Claim 1, so we can't assume it.

### Finding 6: The Correct Approach — Single Formula D from h_cofinal_failure_below_d

After careful analysis, the cleanest approach uses the EXISTING infrastructure:

1. `h_cofinal_failure_below_d` gives: ∀ s < d, ∃ mu-point u with s < u ≤ d and ¬cont_holds(u)
2. ¬cont_holds(u) gives: ∃ A_u, stavi_depth A_u ≤ r, A_u holds on (a_n, y'), ¬A_u(u)
3. By pigeonhole over NormalForm types at depth 2*r (finitely many), among infinitely many such A_u's, some formula D repeats cofinally
4. This D separates d from t': construct S(⊤, D) of depth r+2

**BUT**: Step 3 requires infinitely many failure points, which requires the order to be dense (or at least have infinitely many carrier points below d). This is the concern raised in the Round 14 handoff.

**Resolution**: GHR93 Section 8's setup works over arbitrary linear temporal structures (not just dense ones). The key insight is that `cont_holds` is about formula truth, and there are only finitely many rank-r types. So even with finitely many carrier points below d, the pigeonhole argument works on the set of DISTINCT formula failures, not on distinct positions.

Actually wait — re-reading `pigeonhole_definable_formula` more carefully:

The chain in pigeonhole is: start at p₀ in the cut, find u₀ above p₀ with failure formula A₀, then from u₀ find u₁ with A₁, etc. After K+1 steps (where K = |NormalForm|), two formulas repeat. The SINGLE formula D is the one that repeats.

The chain requires: at each step, find a cut point u₊₁ ≥ u_i with a failure. The cut is downward-closed in the carrier. But the chain goes UPWARD through cut points with failures. In a discrete order with finitely many cut points below d, the chain TERMINATES at the maximum cut point p_max. After that, there's no larger cut point with a failure.

**This IS a real issue for discrete orders with few predecessors.** But:

- The h_d_unique proof is inside `obtain_split_point_props` which is called from `ghr93_backward_inductive_step`
- This function is called for arbitrary linear temporal structures
- The GHR93 theorem IS stated for arbitrary structures

**How does GHR93 handle this?** In GHR93, C is a SINGLE formula, not a universal quantification. The paper defines C = X_{(α_n, y')} as a conjunction of ALL rank-r formulas that hold at ALL points in (α_n, y'). This is a finite conjunction (finitely many rank-r formulas up to equivalence). So C is already a single rank-r formula.

**THIS IS THE KEY**: GHR93 doesn't need pigeonhole because C is already a single formula by construction. The Lean code's `cont_holds` is the *semantic* content of C, but the proof should work with ANY single depth-r formula that captures the interval type.

### Finding 7: The Solution — Construct C as a Finite Conjunction via NormalForm

The correct approach is to materialize C = X_{(α_n, y')} as a single `StaviFormula` of depth ≤ r. This is exactly what GHR93 Definition 8.8 does:

X_t = conjunction of all rank-r formulas true at t (finite conjunction, rank r)
X_{(s,t)} = disjunction over points v in (s,t) of X_v (finite disjunction, rank r)

C = X_{(α_n, y')} describes the interval type: a point satisfies C iff it has the same rank-r formulas as some point in (α_n, y').

To materialize this:
1. Use NormalForm at depth 2*r to enumerate rank-r types
2. Identify which NormalForm types are realized in (a_n, y')
3. For each realized type, construct a `StaviFormula` conjunction (from the type's formulas)
4. C = disjunction of these conjunctions

The existing infrastructure supports this:
- `nf_determines_stavi_truth_depth`: same NF type ⟹ same truth for stavi_depth ≤ r
- `NormalForm` is a `Fintype`
- Each NF has a characteristic formula (from `nf_characteristic`)

**However**, this approach requires constructing `StaviFormula`s from NormalForm data, which is substantial new infrastructure (~100-200 lines).

## Recommended Approach

**The cleanest approach that avoids massive new infrastructure:**

### Option 1: Predicate-Level Proof Without Formula Transfer (Best)

Instead of transferring a specific formula C' through the game, prove h_d_unique directly using the rank-(r+2) game semantics:

**For t' ≤ d direction** (current sorry at line ~1821):
- Assume for contradiction: s ∈ S_C, s < t', so t' ∈ S_C (upward-closed), so d ≤ t'
- If d < t': t' and d agree on all depth-r formulas (by hypothesis ht'_form)
- But cont_holds at d (hd_in_SC), and for any s < d, ∃ failure below d (h_cofinal_failure_below_d)
- The depth-r formula where they MIGHT disagree is exactly the continuation formula
- But ht'_form says they agree on ALL depth-r formulas, so they agree on cont_holds (since cont_holds is defined by depth-r formula truth)
- So d ∈ S_C ⟹ cont_holds(d) ⟹ cont_holds(t') (by formula agreement)
- And t' ∈ S_C by upward-closedness from d ≤ t'... wait, this is circular again.

Actually, the key insight is:

**cont_holds(t) is DETERMINED by depth-r formulas**: if t and t' agree on all depth-r formulas, then cont_holds(t) ⟺ cont_holds(t'). This follows directly from the definition of cont_holds:

```
cont_holds(t) = ∀ A, stavi_depth A ≤ r → (∀ v ∈ (a_n, y'), A(v)) → A(t)
```

If t' agrees with t on all depth-r formulas, then A(t) ⟺ A(t') for all A with stavi_depth A ≤ r. So cont_holds(t) ⟺ cont_holds(t').

**This means**: d and t' either BOTH satisfy cont_holds or NEITHER does. But d ∈ S_C, so cont_holds(d) holds (from the tail condition). Hence cont_holds(t') holds too.

**But this doesn't directly give t' = d!** It gives that t' satisfies cont_holds, which means t' satisfies all formulas that hold on (a_n, y'). But t' could still be at a different position than d.

The position-sensitivity comes from the ORDERING, not just formula truth. Two elements can have the same rank-r type but be at different positions. The Claim 1 proof uses the rank-(r+1) formula C' = ¬C ∨ K⁻(¬C) to DETECT the position via the Since connective, which is order-sensitive.

### Option 2: Use the Existing D from pigeonhole (with Weakened Precondition)

This is the most mechanically straightforward approach and closest to what the code already does:

1. **Create `pigeonhole_definable_formula_below`** (~30 lines): A variant of `pigeonhole_definable_formula` that only requires failure for cut points p with `extendPoint p < d`. The chain argument is unchanged — the chain stays below d.

2. **Construct the separating formula** (~20 lines):
   - D from pigeonhole: depth ≤ r, holds on (a_n, y'), fails cofinally below d
   - S(⊤, D) = `std_snce (base (.bot.imp .bot)) D`: depth r + 2
   - K⁻(¬D) = ¬S(⊤, D) = `neg (std_snce (base (.bot.imp .bot)) D)`: depth r + 2

3. **Prove S(⊤, D) semantics** (~40 lines):
   - S(⊤, D) at d is FALSE: for every mu-point s < d, by pigeonhole, ∃ u ∈ (s, d] with ¬D(u), so D doesn't hold everywhere in (s, d)
   - S(⊤, D) at t' (when d < t') is TRUE: d is a mu-point (or gap, need case split), D holds on (d, t') since d ∈ S_C gives cont_holds above d, and D has depth ≤ r so cont_holds gives D at all mu-points above d

4. **Derive contradiction from game transfer** (~30 lines):
   - K⁻(¬D) at d is TRUE (since ¬S(⊤,D) at d)
   - K⁻(¬D) at t' is FALSE (since S(⊤,D) at t')
   - But K⁻(¬D) has depth r+2 and ht'_form gives agreement up to depth r only
   - Need h_fwd_r1 (rank r+2 game) to extend the agreement — but h_fwd_r1 is about M vs N, not about two elements of N!

**WAIT — this is a critical issue.** The h_d_unique proof compares two elements d and t' in the SAME structure N. The forward game h_fwd_r1 is between M and N. The formula agreement in h_d_unique is at depth r (ht'_form), NOT at depth r+2.

So we CANNOT extend ht'_form to depth r+2. We can only use depth-r formula agreement.

**This means**: the separating formula must have depth ≤ r, NOT r+2. But S(⊤, D) has depth r+2, which is TOO HIGH.

### Critical Realization: The GHR93 Claim 1 Proof Works DIFFERENTLY

Re-reading GHR93 more carefully:

**Claim 1 is about the GAME RESPONSE, not about two arbitrary elements.** GHR93 Claim 1 says: "In a play of G_{m;r'}(M,xy;N,x'y'), if Spoiler plays c, Duplicator's response d must equal d̄."

The proof works because:
- The GAME provides rank-r' agreement between c and d for r' ≥ r+1
- C' has rank r+1 ≤ r', so it's within the game's formula agreement range
- C'(c) holds in M_r (the M-side infimum property)
- By the GAME'S formula transfer, C'(d) holds in N_r
- Analysis of C'(d) forces d = d̄

**But h_d_unique is stated differently**: it says ANY element t' with the right properties equals d. The properties include depth-r formula agreement (ht'_form), gap/point agreement, and boundary agreement.

**The gap between GHR93 and the Lean code**: GHR93 gives rank-(r+1) agreement via the game. The Lean code's h_d_unique only assumes rank-r agreement. These are NOT the same!

**Resolution**: h_d_unique should be proved by:
1. Playing h_fwd_r1 (rank r+2 forward game from M to N) with c as one of Spoiler's choices
2. Getting a response d' from the game
3. Showing d' = d̄ using the GAME'S rank-(r+2) agreement and the C' = ¬C ∨ K⁻(¬C) formula
4. Then showing that h_d_unique's hypotheses (rank-r agreement with d) force t' = d' = d̄ = d

Wait, but h_d_unique's hypotheses don't involve playing the game. They say: given ANY t' with rank-r agreement, gap/point match, and boundary match to d, t' = d.

**This is STRICTLY WEAKER than what GHR93 proves.** GHR93 proves d' = d̄ using rank-(r+1) agreement from the game. The Lean code needs to prove t' = d using only rank-r agreement.

**Is this actually provable?** Can two elements of N_r agree on all depth-r formulas, have the same gap/point status, the same boundary position, and yet be different?

In a dense linear order with enough points: YES, this is possible. Two different positions can have the same rank-r type and same gap/point status. So h_d_unique as stated with only rank-r agreement may be FALSE!

**The fix**: h_d_unique should NOT be a standalone lemma about rank-r agreement. Instead, it should be proved IN CONTEXT where the rank-(r+2) game provides the necessary formula agreement. The current code structure threads h_d_unique as a hypothesis to d_consistency_left/right, which then use it in the game context. But h_d_unique itself needs ACCESS to the game's rank-(r+2) agreement.

**Concretely**: The two sorry sites (lines ~1821 and ~1845) are inside the proof of h_d_unique, which has h_fwd_r1 available in scope (it's a parameter of obtain_split_point_props). So the proof CAN use the rank-(r+2) game. But it needs to PLAY the game to get the rank-(r+2) agreement between specific elements.

The correct argument is:
1. From h_fwd_r1, we have the rank-(r+2) forward game between M and N
2. Play this game with c (M-side infimum) as a Spoiler choice
3. The game response to c is some element e in [x', y'] in N_r+2
4. By rank_embed, e corresponds to some element of N_r
5. By the game, e has rank-(r+2) agreement with c
6. From h_d_unique's hypotheses, we know t' has rank-r agreement with d
7. From the infimum properties, c (in M) and d (in N) have rank-r agreement
8. So e and t' have rank-r agreement (transitivity through c and d)
9. But e also has rank-(r+2) agreement with c, which gives rank-(r+2) agreement with d
10. We can show e = d̄ = d using the rank-(r+2) formula C'
11. Then t' = d follows from... this still needs the rank-(r+2) agreement to reach t'

**The fundamental issue is**: h_d_unique as stated only assumes rank-r agreement for t'. To get t' = d, we need EITHER:
- Rank-(r+2) agreement for t' (which the game provides when t' is the game response), OR
- A rank-r formula that separates d from all other elements in N_r (which exists only if d is definable at rank r)

**KEY INSIGHT**: d IS r-definable! When d is a gap, it's r-definable by the gap definability (infimum_gap_r_definable). When d is a carrier point, d is trivially definable by its type formula X_d. So there IS a rank-r formula that separates d from non-equal elements with the same rank-r type.

Wait — X_d is the set of rank-r formulas true at d. If t' has the same rank-r type as d (ht'_form), then X_d(t') is also true. So X_d does NOT separate them!

The separation comes from the ORDER context, specifically the Since formula which detects position.

**FINAL CONCLUSION**: The proof MUST use the rank-(r+2) game, not just rank-r agreement. The current h_d_unique statement with rank-r agreement alone is INSUFFICIENT. The proof needs to be restructured to use h_fwd_r1 inside the proof body.

## Evidence/Examples

### The Exact Formula Construction in Lean

If we proceed with the formula-transfer approach using the rank-(r+2) game:

```lean
-- D from pigeonhole (or h_cofinal_failure_below_d + choice):
-- stavi_depth D ≤ r, D holds on (a_n, y'), D fails cofinally below d

-- S(⊤, D) in Lean:
let snce_top_D := StaviFormula.std_snce (StaviFormula.base (.bot.imp .bot)) D
-- stavi_depth snce_top_D = max(stavi_depth(base(.bot.imp .bot)), stavi_depth D) + 2
--                        = max(0, stavi_depth D) + 2
--                        ≤ r + 2

-- K⁻(¬D) = ¬S(⊤, D):
let k_minus_not_D := StaviFormula.neg snce_top_D
-- stavi_depth k_minus_not_D = stavi_depth snce_top_D ≤ r + 2

-- Semantics of std_snce (base (.bot.imp .bot)) D at t:
-- ∃ s < t, mu_holds s ∧ ⊤(s) ∧ ∀ u ∈ (s,t), mu_holds u → D(u)
-- = ∃ s < t, mu_holds s ∧ ∀ u ∈ (s,t), mu_holds u → D(u)
-- (since ⊤(s) = temporal_truth ... s (.bot.imp .bot) = True)
```

### Semantic Analysis at d

```lean
-- S(⊤, D)(d) is FALSE:
-- By h_cofinal_failure_below_d (adapted to D):
-- For every s < d, ∃ mu-point u with s < u ≤ d and ¬D(u)
-- So no mu-point s < d can witness S(⊤, D)(d)

-- Therefore K⁻(¬D)(d) = ¬S(⊤, D)(d) = True
```

### Semantic Analysis at t' (when d < t')

```lean
-- Need to show S(⊤, D)(t') is TRUE when d < t':
-- Witness: s = d (if d is a mu-point) or some mu-point just below d
-- D holds on (s, t'): 
--   for u in (d, t') with mu_holds u, u is in (d, y') and d ∈ S_C
--   so cont_holds(u), which gives D(u) since D has depth ≤ r
--   and D holds on (a_n, y')

-- Issue: if d is a gap, we need a mu-point below d as witness
-- For the Since witness s, need mu_holds s and D at all mu-points in (s, t')
-- Can use the carrier point just below d (from the cut)
```

### How h_fwd_r1 Is Used

```lean
-- h_fwd_r1 gives: ghr93_duplicator_wins M N atomMap (4+3*n) (r+2) ...
-- This means: for any Spoiler selection in M_{r+2},
-- Duplicator responds in N_{r+2} preserving rank-(r+2) formulas

-- To use this for h_d_unique:
-- 1. rank_embed c (from M_r to M_{r+2})  
-- 2. Play game with rank_embed(c) as Spoiler's choice
-- 3. Get response e in N_{r+2}
-- 4. e has rank-(r+2) formula agreement with rank_embed(c)
-- 5. By rank_embed_stavi_truth_mu, this gives:
--    for all A with stavi_depth A ≤ r+2,
--    stavi_truth(rank_embed c, A) ↔ stavi_truth(e, A)
-- 6. K⁻(¬D) has depth ≤ r+2, so:
--    K⁻(¬D)(rank_embed c) ↔ K⁻(¬D)(e)
-- 7. By rank_embed_stavi_truth_mu (backward):
--    K⁻(¬D)(rank_embed c) ↔ K⁻(¬D)(c) [in M_r]
-- 8. So K⁻(¬D)(c in M_r) ↔ K⁻(¬D)(e in N_{r+2})
-- 9. Convert e from N_{r+2} back to N_r via rank_embed inverse...

-- BUT: we need to show the game response to rank_embed(c) IS rank_embed(d)
-- This is exactly Claim 1! We're going in circles...
```

## Confidence Level

**Medium-High on the diagnosis, Medium on the solution.**

The diagnosis is clear: h_d_unique as currently stated (with only rank-r agreement) is correct but requires the rank-(r+2) game to prove. The proof must go through the game, not through standalone formula separation.

The solution path is also clear but involves delicate game-theoretic reasoning:
1. Play h_fwd_r1 with c
2. Show the response must be d (using the C'/K⁻ argument internally)
3. Use the response's rank-(r+2) agreement to extend to the Since formula
4. Get t' = d from the extended agreement

The estimated effort for this approach is 100-200 lines, depending on how much game infrastructure needs to be built.

**Critical warning**: The approach of using `pigeonhole_definable_formula` with a weakened precondition (Solution A from Round 14) is correct for GETTING the formula D, but the subsequent argument still needs the rank-(r+2) game transfer. The formula D alone (at rank r) cannot separate d from t' without the Since wrapper, and the Since wrapper is at rank r+2 which exceeds the rank-r agreement in ht'_form.

# GHR93 Claim 1: Implementation Strategies for the Infimum Argument

**Task**: 155 -- Reynolds Pipeline Activation
**Date**: 2026-05-21
**Purpose**: Evaluate concrete Lean 4 encoding strategies for GHR93 Claim 1 (the infimum-based d-consistency proof), and catalog how d = a_bwd(n) is actually used downstream.

## Executive Summary

GHR93 Claim 1 proves d-consistency: for any winning forward play where Spoiler places c at the boundary, Duplicator's response at position n must equal d (the infimum of a formula-definable set). This closes the 4 coupled sorries in ExpressivenessGeneral.lean (lines 306, 316, 430, 447).

This report analyzes five implementation questions: (1) how to define the infimum, (2) how to encode formula C, (3) how to structure the proof, (4) how to integrate with existing code, and (5) what Case II actually needs from hd_eq_an. The recommendation is to use Classical.choice with a Prop-level predicate C, prove d = d_bar as a standalone lemma, and leave SplitPointProps unchanged.

---

## 1. How to Define the Infimum on ExtendedCarrier

### Current State

ExtendedCarrier has a LinearOrder instance (`extendedLinearOrder` at EFGames.lean line 377) but NO ConditionallyCompleteLattice, InfSet, or SupSet instance. The ordering is:
- Points vs points: carrier order
- Point vs gap: `x in gamma.cut`
- Gap vs point: `x notin gamma.cut`
- Gap vs gap: cut inclusion

### Option 1: Construct via Classical.choice (RECOMMENDED)

Define the infimum set and extract a witness:

```lean
private noncomputable def claim1_infimum_set
    {sig : MonadicSignature} {N : OrderedMonadicStructure sig}
    {atomMap : Formula -> sig.preds} {r : Nat}
    (x' y' : ExtendedCarrier N atomMap r)
    (C : ExtendedCarrier N atomMap r -> Prop) : Set (ExtendedCarrier N atomMap r) :=
  { t | inClosedInterval x' y' t /\ C t }

private noncomputable def claim1_d_bar
    {sig : MonadicSignature} {N : OrderedMonadicStructure sig}
    {atomMap : Formula -> sig.preds} {r : Nat}
    (x' y' : ExtendedCarrier N atomMap r)
    (C : ExtendedCarrier N atomMap r -> Prop)
    (h_nonempty : exists t, inClosedInterval x' y' t /\ C t)
    (h_lb : x' <= y') : ExtendedCarrier N atomMap r :=
  -- The infimum exists because:
  -- (a) The set is nonempty (h_nonempty)
  -- (b) The set is bounded below by x'
  -- (c) ExtendedCarrier is linearly ordered
  -- Use Classical.choice + well_ordering / Zorn
  Classical.choose (exists_glb_of_nonempty_bounded h_nonempty ...)
```

**Advantage**: No new typeclass instances needed. Works with the existing LinearOrder.

**Challenge**: ExtendedCarrier does not satisfy completeness in general. A linear order without completeness has no guarantee that arbitrary bounded nonempty subsets have an infimum. However, the specific set we need (formula-definable sets in the GHR93 sense) does have an infimum by construction of ExtendedCarrier.

**Key insight**: The set `{t in [x', y'] | C(t)}` where C is defined by a rank-r formula is a *downward-closed or upward-closed* subset of ExtendedCarrier (depending on C's definition). Since ExtendedCarrier is constructed from M.carrier + r-definable gaps, and r-definable gaps correspond exactly to the "holes" where infima of formula-definable sets would live, the infimum either:
- Is an actual point (when the set's boundary is a point), or
- Is an r-definable gap (when the set's boundary is a gap -- this is precisely how gaps are defined)

### Option 2: Use Mathlib's csInf with a ConditionallyCompleteLattice instance

Would require proving that ExtendedCarrier is conditionally complete. This is true but requires substantial infrastructure:

```lean
noncomputable instance : ConditionallyCompleteLattice (ExtendedCarrier M atomMap r) where
  sInf := ...
  csSup := ...
  csInf_le := ...
  le_csInf := ...
```

**Effort estimate**: 100-150 lines just for the instance, plus the proofs that the ordering satisfies the lattice axioms for bounded nonempty subsets. This is technically correct (ExtendedCarrier IS conditionally complete because every bounded nonempty set either has its inf among existing elements or defines a gap) but adds significant infrastructure that is only used in this one place.

**NOT recommended**: Too much overhead for a single use site.

### Option 3: Build from DedekindGap infrastructure directly

Instead of a general infimum, observe that the infimum of `{t | C(t)}` in `[x', y']` is either:
- An element of N.carrier (if the boundary of `{t | C(t)}` is an actual point), or
- A DedekindGap (if the boundary is a gap, which is necessarily r-definable since C has rank <= r)

```lean
private noncomputable def claim1_infimum_element
    (C_set : Set (ExtendedCarrier N atomMap r))
    (h_nonempty : C_set.Nonempty)
    (h_bounded : BddBelow C_set)
    (h_definable : <C is rank-r definable>) :
    ExtendedCarrier N atomMap r :=
  -- Case split: does the boundary land on a point or a gap?
  if h : exists p : N.carrier, IsGLB C_set (extendPoint p)
  then extendPoint (Classical.choose h)
  else
    -- The boundary defines a gap
    let gap_cut := { x : N.carrier | extendPoint x < inf_witness }
    Sum.inr (construct_gap gap_cut ...)
```

**Advantage**: Directly connects to the existing Gap/RDefinableGap infrastructure.
**Disadvantage**: More complex case analysis. Two branches to maintain.

### Recommendation: Option 1 (Classical.choice)

The cleanest approach is to not compute the infimum at all, but instead use the specific structure of the GHR93 argument:

1. **Play a canonical forward game** with all positions set to c (the M-side split point). The strategy gives a response; define d_bar as that response at position n. This makes d-consistency for THIS specific play trivially `rfl`.

2. **Prove that ALL plays give the same response at position n** (this is the hard part -- the actual Claim 1 content).

3. **Since d = a_bwd(n) and a_bwd was obtained from some play, d_bar = d follows** from step 2.

This avoids needing an actual infimum computation entirely. The "infimum" is conceptually present in the argument but need not be materialized as a Lean term.

---

## 2. How to Encode Formula C in Lean

### What C represents in GHR93

In GHR93, Claim 1 defines: for a backward game on [x', y'] with n+1 selections, and a forward game on [x, y] with the first selection = c:

> C(t) := "Duplicator can respond with d' in [x', y'] at position n such that d' = t, and the winning condition is satisfied on the sub-interval [t, y']"

Equivalently: C(t) holds iff there exists a winning play of the forward game with c at boundary position where the N-side response at that boundary is t.

### Option A: Abstract Prop predicate (RECOMMENDED)

```lean
private def C_predicate
    {sig : MonadicSignature} {M N : OrderedMonadicStructure sig}
    {atomMap : Formula -> sig.preds} {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_fwd : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y')
    (c : ExtendedCarrier M atomMap r) (hc : inClosedInterval x y c)
    (t : ExtendedCarrier N atomMap r) : Prop :=
  -- There exists a winning play of the forward game where:
  -- (1) M-side has c at the boundary position
  -- (2) N-side response at boundary position = t
  exists (a_pad : Fin (1 + 3 * n + 1) -> ExtendedCarrier M atomMap r),
    (forall i, inClosedInterval x y (a_pad i)) /\
    a_pad (Fin.mk (1 + 3 * n) (by omega)) = c /\
    exists (a'_full : Fin (1 + 3 * n + 1) -> ExtendedCarrier N atomMap r),
      (forall i, inClosedInterval x' y' (a'_full i)) /\
      a'_full (Fin.mk (1 + 3 * n) (by omega)) = t /\
      (forall (b' : N.carrier), inClosedInterval x' y' (extendPoint b') ->
        exists (b : M.carrier), inClosedInterval x y (extendPoint b) /\
          ghr93_winning_condition (1 + 3 * n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b'))
```

**Advantage**: No formula syntax involved. Pure game-theoretic statement. Does not require evaluating temporal formulas at all. The winning condition already bundles formula agreement, so C inherits formula-definability.

**Advantage**: Matches exactly what d-consistency needs: the d-consistency sorry says `a'_full(n) = d`, and C_predicate captures exactly the set of possible values for `a'_full(n)`.

**Disadvantage**: C is not literally a StaviFormula, so the "rank <= r" argument is implicit rather than syntactic.

### Option B: StaviFormula encoding

Encode C as a StaviFormula of depth <= r that captures the rank_type of d at the boundary:

```lean
-- C = conjunction of all rank-r formulas true at d, negated for those false at d
private noncomputable def C_formula
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds) (r : Nat)
    (d : ExtendedCarrier M atomMap r) : StaviFormula :=
  -- Would need to enumerate all rank-r formulas and take conjunction
  -- This requires finiteness of rank-r formulas (not yet proven in codebase)
  sorry
```

**Disadvantage**: Requires enumerating rank-r formulas and proving finiteness. This is significant infrastructure (~200+ lines) that doesn't exist in the codebase.

**Disadvantage**: The resulting formula is opaque and hard to reason about.

### Option C: rank_type equality predicate

```lean
private def C_rank_type
    (d : ExtendedCarrier N atomMap r)
    (t : ExtendedCarrier N atomMap r) : Prop :=
  rank_type N atomMap r t = rank_type N atomMap r d
```

**Problem**: This is too strong. C should capture that the element at the boundary *could be* d based on game-theoretic compatibility, not that it has the same rank_type. Multiple elements can have the same rank_type without being equal.

### Recommendation: Option A (Prop predicate)

The abstract Prop predicate is the simplest and most natural encoding. It avoids all formula syntax machinery, directly states what is needed for d-consistency, and the key properties (nonemptiness, the infimum argument) follow from the game structure.

---

## 3. How to Structure the Infimum Proof

### The Two Halves of Claim 1

**Half 1**: d_bar <= every element of C_predicate
This means: for any winning play with c at boundary, the N-side response t satisfies d_bar <= t.

**Half 2**: d_bar is in C_predicate (or: nothing below d_bar is in C_predicate)
This means: d_bar itself can serve as the response, or equivalently, any element strictly below d_bar cannot serve as a response.

### Alternative Structure: Direct Uniqueness

Instead of an infimum argument, prove **uniqueness** directly:

**Claim**: For any two winning plays with c at the boundary, the N-side responses at position n are equal.

**Proof sketch**:
1. Let plays P1 and P2 both have c at boundary position n.
2. P1 gives response d1 at position n; P2 gives response d2.
3. Both satisfy the winning condition with ALL point challenges b'.
4. From same_order_type in both plays: for any index i < n, a_pad1(i) <= c iff a'_full1(i) <= d1, and similarly for P2.
5. **Key step**: Take the COMBINED play where M-side follows P1 but we play the game of P2 on the N-side. This is possible because the forward strategy is universal over ALL M-side selections -- we can feed P1's a_pad to P2's strategy.
6. Actually, this doesn't work directly because the strategies are existential (Duplicator CHOOSES responses).

**Better approach using the strategy directly**:
1. Fix the M-side selection: all positions = c. Call this a_const.
2. The forward strategy, applied to a_const, gives a_const' with a_const'(n) = d_bar.
3. For any OTHER M-side selection a_pad with a_pad(n) = c, the forward strategy gives a'_full with a'_full(n) = ?.
4. We need to show a'_full(n) = d_bar.

**Proof via same_order_type**:
- In the play with a_const (all = c), every a_const(i) = c = a_const(n).
- By same_order_type: a_const'(i) = a_const'(n) = d_bar for all i. (Since a_const(i) = a_const(n), the = direction gives a_const'(i) = a_const'(n).)
- Wait -- this only shows the canonical play gives all equal responses. It doesn't constrain other plays.

**The actual GHR93 argument** (simplified):
1. Play the forward game ONCE with a specific M-side input.
2. The strategy gives N-side response. Define d_bar as the response at position n.
3. For d-consistency with a DIFFERENT M-side input a_pad (where a_pad(n) = c):
   a. The strategy gives a'_full.
   b. From same_order_type applied to positions n and (the modified positions):
      - a_pad(i) <= c = a_pad(n) for some i (if i < n in the "all above d" case).
      - So a'_full(i) <= a'_full(n) by same_order_type.
   c. But this only gives a'_full(n) >= d (which is d <= a'_full(n)).
   d. The d >= a'_full(n) direction requires the **contradiction argument**: if a'_full(n) > d_bar, then there's a point between d_bar and a'_full(n) where Spoiler can challenge and win.

This is the genuine GHR93 Claim 1 argument. It requires:
- Playing the strategy on a specific input to define d_bar
- Playing it again on a_pad and comparing
- The contradiction step where Spoiler exploits a gap between d_bar and a'_full(n)

### Existing Infrastructure Reusable

| Component | Location | Reuse for Claim 1 |
|-----------|----------|-------------------|
| `ghr93_duplicator_wins` | EFGames.lean:2599 | Feed different M-side inputs to get different plays |
| `ghr93_winning_condition` | EFGames.lean:2576 | Extract same_order_type, formula_agreement |
| `same_order_type` | EFGames.lean:2542 | Derive ordering constraints between responses |
| `formula_agreement` | EFGames.lean:2553 | Show rank_type equality |
| `ghr93_strategy_restrict_left` | EFGames.lean:2912 | Already uses d-consistency; will CONSUME the Claim 1 output |
| `game_tuple` | EFGames.lean:2529 | Already indexed for the right positions |

### Recommended Proof Structure

```
-- Step 1: Define d_bar from a canonical play
-- Step 2: Prove d_bar is in [x', y']
-- Step 3: Prove d <= d_bar (easy: d = a_bwd(n), and the canonical play
--         can be chosen to have a_bwd at its positions)
-- Step 4: Prove d_bar <= d (contradiction: if d_bar < d, Spoiler
--         challenges with a point between them)
-- Step 5: Conclude d = d_bar
-- Step 6: d-consistency follows: for ANY play, response = d_bar = d
```

Actually, the structure should be even simpler. Since we define d = a_bwd(n) and d_bar = response to canonical play, we just need to show that EVERY play's response at position n equals d. The approach:

```
claim1_d_consistency :
  forall (a_pad : Fin (1+3*n+1) -> ExtendedCarrier M atomMap r),
    (forall i, inClosedInterval x y (a_pad i)) ->
    a_pad (1+3*n) = c ->
    forall (a'_full : ...) (ha'_full : ...) (hwin : ...),
      a'_full (1+3*n) = d
```

**Proof approach**: 
1. From d = a_bwd(n) and the way obtain_split_point_props constructs d, we have one specific play where the response at position n is d.
2. For any OTHER play with c at position n: use the strategy to get a response t.
3. Show t = d by comparing the two plays through the winning condition.
4. Both plays agree at position n on the M-side (both have c there).
5. From same_order_type: the N-side values at position n must be in the same relative position to all other N-side values.
6. Since both plays use the SAME strategy (ghr93_duplicator_wins is a specific strategy, not existentially quantified over strategies), the responses are determined.

**Wait -- critical issue**: `ghr93_duplicator_wins` is existentially quantified. It says "THERE EXISTS a response." Two invocations can give DIFFERENT responses. The strategy is non-deterministic.

This means the direct uniqueness approach fails. We genuinely need the infimum/Claim 1 argument from GHR93.

### Revised Structure: The Full Claim 1

The GHR93 Claim 1 argument works as follows:

1. **Define the set S** := {t in [x', y'] : there exists a winning play with c at boundary and response t at boundary}

2. **Show S is nonempty**: Take any play with c at boundary. The response is in S.

3. **Show S has a greatest lower bound**: This follows from ExtendedCarrier being order-complete for formula-definable sets (or from a direct argument about the structure of S).

4. **Show the GLB equals a_bwd(n)**: 
   - a_bwd(n) is in S (from the original play)
   - Every element of S is >= a_bwd(n) (the hard part: contradiction argument)

Actually, step 4 is the wrong direction. In GHR93, d is DEFINED as the infimum, not as a_bwd(n). Then they prove d = a_bwd(n). Let me re-read the current code flow.

In the current code:
- `d` is defined as `a_bwd(n)` (line 222)
- `hd_eq_an : d = a_bwd ⟨n, by omega⟩ := rfl` (line 224)
- The d-consistency sorry asks: for any winning play with c at boundary, the response = d (= a_bwd(n))

So the question is: can we prove that ALL winning plays' responses at position n equal a_bwd(n)?

**This is unprovable in general** because ghr93_duplicator_wins is existential. Different invocations can choose different responses. The strategy is not a function -- it's a relation.

**The GHR93 fix**: Define d NOT as a_bwd(n) but as the INFIMUM of all possible responses. Then:
- d <= every response (by definition of infimum)
- Every response >= d (tautology from above)
- d-consistency becomes: every response = d (i.e., the infimum is attained)

But this requires proving the infimum IS attained, which is exactly Claim 1.

### Concrete Proof Strategy for Claim 1

**Phase A** (~30 lines): Define d_bar as Classical.choose of the set of achievable responses.

```lean
-- The set of achievable N-side responses at position n when M-side has c at position n
private noncomputable def achievable_responses ... :=
  { t : ExtendedCarrier N atomMap r |
    exists a_pad a'_full, ... /\ a'_full(n) = t }

-- Pick one achievable response (any will do)
private noncomputable def d_bar ... := Classical.choose (achievable_nonempty ...)
```

**Phase B** (~40-60 lines): Prove that all achievable responses have the same rank_type at the boundary.

Key lemma: if t1 and t2 are both achievable responses, then `rank_type N atomMap r t1 = rank_type N atomMap r t2`.

Proof: Both come from winning plays. Both winning plays have formula_agreement at position n (the boundary). Formula agreement at boundary means `stavi_temporal_truth_mu N atomMap r t1 A <-> stavi_temporal_truth_mu M atomMap r c A` and similarly for t2. Therefore `stavi_temporal_truth_mu N atomMap r t1 A <-> stavi_temporal_truth_mu N atomMap r t2 A` for all A of depth <= r. Hence rank_type equality.

**Phase C** (~40-60 lines): Prove that all achievable responses are equal.

This is the hard part. Rank_type equality does not imply equality of elements. Two different points can have the same rank_type; two different gaps can have the same rank_type.

However, in the specific context of the game:
- Both t1 and t2 are achievable responses to M-side selections with c at position n.
- By same_order_type, the relative position of t1 to all other N-side values matches the relative position of c to all other M-side values.
- Similarly for t2.
- Since c's position is FIXED (it's the same in both plays), t1 and t2 must be in the same position relative to x' and y'.

**Formal argument**: 
- Play 1: a_pad, a'_full1, a'_full1(n) = t1
- Play 2: a_pad (SAME M-side input), a'_full2, a'_full2(n) = t2
- Actually, the M-side inputs can DIFFER (only position n = c is fixed).

The GHR93 argument handles this by using the infimum property: if t1 < t2, then there is a point p between t1 and t2 in ExtendedCarrier. Spoiler can challenge with this point in Play 2, and by the winning condition, Duplicator must respond with a point near the corresponding M-side position. But the M-side has c at position n, and the gap between t1 and t2 on the N-side cannot be matched on the M-side (since both should correspond to c). Contradiction.

**This is the genuine content of Claim 1 and requires ~50-100 lines of careful case analysis.**

**Phase D** (~20 lines): Derive d-consistency from uniqueness.

Once all achievable responses are equal, any d_bar chosen by Classical.choose equals any specific response a_bwd(n). Hence d = d_bar, and d-consistency holds trivially.

### Total Estimate: 130-170 lines

---

## 4. How to Integrate with obtain_split_point_props

### Option I: Prove d = d_bar as a separate lemma, keep d = a_bwd(n) (RECOMMENDED)

```lean
-- New lemma: all achievable responses equal a_bwd(n)
private theorem claim1_d_consistency
    {sig : MonadicSignature} {M N : OrderedMonadicStructure sig}
    {atomMap : Formula -> sig.preds} {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_fwd : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y')
    (hxy : x <= y) (hx'y' : x' <= y')
    (c : ExtendedCarrier M atomMap r) (hc : inClosedInterval x y c)
    (d : ExtendedCarrier N atomMap r) (hd : inClosedInterval x' y' d)
    (hcd_form : forall A, stavi_depth A <= r ->
      (stavi_temporal_truth_mu M atomMap r c A <->
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c <-> IsPoint d) /\ (IsGap c <-> IsGap d))
    (hcd_boundary : (x = c <-> x' = d) /\ (c = y <-> d = y'))
    -- Key: d is achievable (there exists a play with response d)
    (hd_achievable : exists a_pad a'_full,
      (forall i, inClosedInterval x y (a_pad i)) /\
      a_pad (Fin.mk (1 + 3 * n) (by omega)) = c /\
      (forall i, inClosedInterval x' y' (a'_full i)) /\
      a'_full (Fin.mk (1 + 3 * n) (by omega)) = d /\
      (forall b', inClosedInterval x' y' (extendPoint b') ->
        exists b, inClosedInterval x y (extendPoint b) /\
          ghr93_winning_condition (1 + 3 * n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b'))) :
    -- Conclusion: every winning play with c at boundary has d at boundary
    forall (a_pad : Fin (1 + 3 * n + 1) -> ExtendedCarrier M atomMap r),
      (forall i, inClosedInterval x y (a_pad i)) ->
      a_pad (Fin.mk (1 + 3 * n) (by omega)) = c ->
      forall (a'_full : Fin (1 + 3 * n + 1) -> ExtendedCarrier N atomMap r),
        (forall i, inClosedInterval x' y' (a'_full i)) ->
        (forall b', inClosedInterval x' y' (extendPoint b') ->
          exists b, inClosedInterval x y (extendPoint b) /\
            ghr93_winning_condition (1 + 3 * n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ->
        a'_full (Fin.mk (1 + 3 * n) (by omega)) = d := by
  sorry -- The actual Claim 1 proof goes here
```

**Integration**: In `obtain_split_point_props`, the two sorry'd `have` blocks (lines 297-306 and 307-316) are replaced by invocations of `claim1_d_consistency`. The `hd_achievable` hypothesis is satisfied because d = a_bwd(n) came from a specific play of the forward game (this play provides the witness).

**Changes to existing code**: ZERO changes to SplitPointProps, Case I, Case II, or any downstream code. Only lines 297-316 in `obtain_split_point_props` change.

### Option II: Replace d with d_bar in SplitPointProps

Change `SplitPointProps.hd_eq_an` to hold for d_bar instead of a_bwd(n). This requires:
- Redefining d_bar inside obtain_split_point_props
- Proving d_bar = a_bwd(n) to satisfy the existing hd_eq_an field
- OR: removing hd_eq_an and replacing all 25+ usages in Cases I and II

**NOT recommended**: High risk of breaking sorry-free code. Option I is strictly better.

### Option III: Make d_bar the new d and add d_bar = a_bwd(n) as a consequence

Similar to Option II but adds a new field `hd_bar_eq` instead of modifying `hd_eq_an`. This doubles the proof obligation without benefit.

### Recommendation: Option I

Keep d = a_bwd(n) as is. Prove claim1_d_consistency as a standalone theorem. Apply it to close the two d-consistency sorries. No changes to SplitPointProps, Case I, or Case II.

---

## 5. Catalog of hd_eq_an Usage Sites in Case II

### Purpose

Understanding what Case II actually needs from `d = a_bwd(n)` is important even when keeping Claim 1, because it confirms that the infimum-based d_bar can serve as a drop-in replacement (via d = d_bar = a_bwd(n)).

### Case I Usage (lines 701-719)

| Line | Context | What it needs | Could use d <= a_bwd(n)? |
|------|---------|---------------|--------------------------|
| 708 | n=0 contradiction | `d = a_bwd(0)`, so `d <= a_bwd(0)` contradicts `a_bwd(0) < d` | YES (only needs `d <= a_bwd(n)`) |
| 719 | R nonempty | `a_bwd(n) >= d`, so `n in R` | YES (only needs `d <= a_bwd(n)`) |

**Case I conclusion**: Both uses only need `d <= a_bwd(n)`, not full equality.

### Case II Usage (lines 1695-2413): Detailed Catalog

Case II (`ghr93_case_II`) has the hypothesis `h_point : IsPoint (a_bwd n)` and extracts `hd_eq_an : d = a_bwd(n)` from `props.hd_eq_an`.

| # | Line | Pattern | Purpose | Needs equality? |
|---|------|---------|---------|-----------------|
| 1 | 1695 | `have hd_eq_an := props.hd_eq_an` | Extract field | Setup |
| 2 | 1699 | `hd_eq_an \b hp_d` | `d = extendPoint p_d` from `d = a_bwd(n)` and `a_bwd(n) = extendPoint p_d` | YES: derives IsPoint(d) |
| 3 | 1832 | `rw [<- hd_eq_an, hd_pt]` | Rewrite a_bwd(j) to extendPoint p_d (j=n case in gap_point) | YES: d = a_bwd(n) = extendPoint p_d |
| 4 | 1856 | `rw [<- hd_eq_an]` | Rewrite a_bwd(j) to d (j=n case in formula) | YES: substitution |
| 5 | 1938 | `rw [<- hd_eq_an]` | x vs sel(n) ordering | YES: rewrite a_bwd(j') to d |
| 6 | 1961 | `rw [<- hd_eq_an]` | b vs sel(n) ordering | YES: rewrite a_bwd(j') to d |
| 7 | 1987 | `rw [<- hd_eq_an]` | y vs sel(n) ordering | YES: rewrite a_bwd(j') to d |
| 8 | 2005 | `rw [<- hd_eq_an]` | sel(n) vs x ordering | YES: rewrite a_bwd(i') to d |
| 9 | 2021 | `rw [<- hd_eq_an]` | sel(n) vs b ordering | YES: rewrite a_bwd(i') to d |
| 10 | 2033 | `rw [<- hd_eq_an]` | sel(n) vs y ordering | YES: rewrite a_bwd(j') to d, then use tau_d_y |
| 11 | 2050 | `rw [<- hd_eq_an]` | sel(i) vs sel(n) ordering | YES: rewrite a_bwd(j') to d |
| 12 | 2061 | `rw [<- hd_eq_an]` | sel(n) vs sel(j) ordering | YES: rewrite a_bwd(i') to d |
| 13 | 2070 | `rw [<- hd_eq_an]` | sel(n) vs sel(n) ordering | YES: rewrite both to d, then simp |
| 14 | 2169 | `rw [<- hd_eq_an, hd_pt]` | gap_point at j=n (right case) | YES: d = extendPoint p_d |
| 15 | 2191 | `rw [<- hd_eq_an]` | formula at j=n (right case) | YES: substitution |
| 16-22 | 2265-2390 | `rw [<- hd_eq_an]` | Same pattern: ordering in right b_sp>c case | YES: all substitutions |

### Analysis

**Every single use is a direct rewrite** of the form `rw [<- hd_eq_an]` to replace `a_bwd(n)` with `d` in the goal. This is a **pure substitution**: wherever the proof encounters `a_bwd(n)` (from the game tuple at position n), it replaces it with `d` so that ordering and formula facts about d (from sigma/tau) can be applied.

**Critical observation for Claim 1 integration**: Once we prove `d = a_bwd(n)` (via the infimum argument), all 22 rewrite sites work identically. The `props.hd_eq_an` field remains `d = a_bwd ⟨n, by omega⟩`, and Case II uses it exactly as before. No changes to Case II are needed.

**The key dependency** is at line 1699: `hd_pt : d = extendPoint p_d := hd_eq_an \b hp_d`. This derives `IsPoint(d)` from `IsPoint(a_bwd n)` via the equality `d = a_bwd(n)`. If we only had `d <= a_bwd(n)`, this derivation would fail (d could be a gap below a_bwd(n)). This is why the inequality approach was rejected.

---

## 6. M-Side Degenerate Sorries (Lines 430, 447)

### What they assert

- Line 430: `exists p, inClosedInterval x c (extendPoint p)` when `x = c` and `IsGap c`
- Line 447: `exists p, inClosedInterval c y (extendPoint p)` when `c = y` and `IsGap c`

Both ask for an actual point in a degenerate interval [gap, gap] where the endpoints are equal. No such point exists.

### How Claim 1 resolves them

With Claim 1 implemented, d is defined via the infimum construction which ensures **boundary order correspondence**: `x = c <-> x' = d` and `c = y <-> d = y'`.

When `x = c` and `IsGap c`:
- By boundary correspondence: `x' = d` and `IsGap d` (since c and d have the same gap/point status).
- The sigma game is on [x', d] = [d, d] with d a gap.
- sigma is constructed via `ghr93_duplicator_wins_degenerate_gap` (line 347), which doesn't need h_pt_xc at all.
- But `SplitPointProps.h_pt_xc` still requires a witness.

**The fix**: With Claim 1, the approach to c's construction changes. Instead of finding c via a 1-round game and then sorry'ing the boundary points, Claim 1 ensures that c is the UNIQUE M-side element matching d. When d is an actual point, c is an actual point (from the forward game's Round 2). When d is a gap, c is a gap found via gap detection formulas (Lemma 9, currently sorry'd separately at line 551). In both cases, the boundary correspondence ensures that the degenerate case (x = c and gap) only arises when x' = d (and gap), and sigma handles this via `ghr93_duplicator_wins_degenerate_gap` without needing h_pt_xc.

**Resolution path**: Make `h_pt_xc` and `h_pt_cy` conditional (Option types or separate branches), but handle the degenerate case BEFORE Case I reaches the point where it needs the witness. Specifically:
1. In `obtain_split_point_props`, when x = c (gap), construct sigma directly from `ghr93_duplicator_wins_degenerate_gap` and set h_pt_xc to a dummy value that is never consumed.
2. Case I's usage of h_pt_cy (line 811) and h_pt_xc (line 1248) only occurs in the non-degenerate branches (where b_sp is in the interior of the interval). In the degenerate branch, the game is won vacuously.

**However**: The previous analysis (phase-4CW1-w12w14-analysis-20260521.md) showed that Case I genuinely reaches the degenerate case. The fix requires restructuring Case I to handle the degenerate case separately, which is a ~30-50 line change.

**Alternative**: Change SplitPointProps to use `Option`:
```lean
h_pt_xc : x != c \/ IsPoint c -> exists p, inClosedInterval x c (extendPoint p)
h_pt_cy : c != y \/ IsPoint c -> exists p, inClosedInterval c y (extendPoint p)
```

This requires updating all 5 downstream call sites (lines 811, 1248, 1735, 1754, 2106), which is ~20 lines of changes total. The degenerate branches (x=c gap, c=y gap) are handled by showing that the game is vacuously won on degenerate intervals.

---

## 7. Recommended Implementation Plan

### Phase 1: claim1_d_consistency theorem (~130-170 lines, new file or in EFGames.lean)

**Location**: Add to EFGames.lean, near the strategy restriction lemmas (after line 3200).

**Structure**:
1. Define `achievable_responses` set (5 lines)
2. Prove nonemptiness: any invocation of the strategy provides a witness (10 lines)
3. **Core lemma**: Two achievable responses have the same rank_type (40 lines)
   - Extract formula_agreement from both winning conditions
   - Chain through c to get t1 <-> t2 for all formulas
4. **Core lemma**: Two achievable responses at the same relative position to x' and y' must be equal (60 lines)
   - Case split on whether both are points or both are gaps
   - Points: same rank_type at points means same formulas, but points can still differ. Need to use same_order_type to show they're in the same position relative to ALL other N-side values. Since both plays have the SAME c at position n on the M-side, the order constraints force t1 = t2.
   - Gaps: two gaps with the same rank_type at the boundary must have the same cut (by gap structure + formula definability). Hence equal by gap_ext.
5. Derive `claim1_d_consistency` (10 lines)

### Phase 2: Close d-consistency sorries (~10 lines, in ExpressivenessGeneral.lean)

Replace the sorry blocks at lines 297-306 and 307-316 with invocations of `claim1_d_consistency`.

The `hd_achievable` hypothesis is satisfied by playing the forward game with a_bwd-derived selections. Since d = a_bwd(n) is defined from a specific invocation of the forward strategy (even though the strategy is existential, we have a SPECIFIC witness from the construction), we can provide the witness.

### Phase 3: Close M-side degenerate sorries (~30-50 lines, in ExpressivenessGeneral.lean)

After d-consistency is proved, the degenerate sorries at lines 430 and 447 can be closed by one of:
- (a) Making h_pt_xc/h_pt_cy conditional and updating 5 downstream sites (~20 lines)
- (b) Proving that with the correct c (from Claim 1), the degenerate case is handled before h_pt_xc is needed (~30-50 lines)

**Option (a) is recommended** for its simplicity.

### Total Estimate: 170-230 lines

This is within the 150-250 line estimate from the previous analysis.

---

## 8. Risk Analysis

### Key Risk: The "two achievable responses are equal" step

This is the hardest part. The argument requires showing that same rank_type + same relative position forces equality. For actual points, this follows from the order structure. For gaps, this requires that two gaps with the same rank_type at the same position are equal (same cut).

**Mitigation**: The gap equality follows from `gap_ext` (line 275 of EFGames.lean): two gaps with the same cut are equal. Same rank_type means same formulas. Same formulas at the boundary of a gap means the gap is defined by the same formulas, hence the same cut. This argument is sound but needs to be formalized.

### Backup: If uniqueness of achievable responses fails

If the full uniqueness proof is too complex, there is a fallback:

1. Instead of proving ALL responses equal d, prove that the d-consistency HYPOTHESIS (as stated in strategy_restrict_left/right) holds by construction.
2. This means: for the SPECIFIC a_pad that strategy_restrict feeds to the forward game, prove that the response at position n equals d.
3. This is easier because we control what a_pad looks like (it has c at the boundary and specific sub-interval elements elsewhere).

This fallback reduces Claim 1 from "ALL plays agree" to "THIS specific play agrees," which might suffice for strategy restriction.

**Examining strategy_restrict_left (EFGames.lean line 2934-2964)**: The lemma feeds `a_pad` (which has elements from [x,c] padded with c at position n) to the forward strategy. The d-consistency hypothesis is applied to THIS specific a_pad. So we only need d-consistency for a_pad's of this specific form, not for arbitrary a_pad's.

**This significantly reduces the proof burden**: Instead of universal d-consistency, we need d-consistency for a_pad's where positions 0..n-1 are in [x,c] and position n = c. This is a restricted form that might be provable with a simpler argument.

---

## Summary of Recommendations

1. **Encoding**: Use a Prop-level predicate for C (Option A in Section 2). No formula syntax needed.
2. **Infimum**: Use Classical.choose on the achievable response set (Option 1 in Section 1). No new typeclass instances.
3. **Proof structure**: Prove claim1_d_consistency as a standalone theorem (Section 3), possibly using the restricted form that only handles a_pad's from strategy_restrict (Section 8 fallback).
4. **Integration**: Keep d = a_bwd(n) in SplitPointProps. Close the two d-consistency sorries by invoking claim1_d_consistency. Zero changes to Cases I or II.
5. **Degenerate sorries**: Close by making h_pt_xc/h_pt_cy conditional (Option a in Phase 3).
6. **Estimated effort**: 170-230 lines total across all three phases.

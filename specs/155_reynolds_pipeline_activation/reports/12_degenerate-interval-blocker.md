# Degenerate Interval Blocker Analysis

**Task**: 155 (Reynolds Pipeline Activation)
**Date**: 2026-05-21
**Focus**: How does GHR93 handle x' = d? Is the degenerate sub-interval [x', d] avoidable?

## 1. Problem Analysis

### The Four Sorry'd Lines

In `ExpressivenessGeneral.lean`, `obtain_split_point_props` constructs backward strategies sigma (on [x', d] / [x, c]) and tau (on [d, y'] / [c, y]) by applying the IH to restricted forward strategies. The IH has precondition:

```
exists p, inClosedInterval x0' y0' (extendPoint p)
```

Four sorry's arise at lines 347, 367, 387, 404 when this precondition fails:

| Line | Interval | Condition | Why it fails |
|------|----------|-----------|--------------|
| 347  | [x', d] on N | x' = d, both gaps | [d, d] contains no actual N-points |
| 367  | [d, y'] on N | d = y', both gaps | [d, d] contains no actual N-points |
| 387  | [x, c] on M  | x = c, both gaps  | [x, x] contains no actual M-points |
| 404  | [c, y] on M  | c = y, both gaps  | [c, c] contains no actual M-points |

These fail because the IH requires an actual point in the sub-interval, but a degenerate interval [g, g] where g is a gap contains no actual points.

### What Sigma Is Used For

Sigma (`ghr93_duplicator_wins N M atomMap n r x' d x c`) is used in Cases II-IV for:

1. **Boundary ordering** (sig_x_d at line 2090): `(x' < d <-> x < c) /\ (x' = d <-> x = c)`
2. **Boundary gap/point agreement** (hgp_x at line 2141): `(IsPoint x' <-> IsPoint x) /\ (IsGap x' <-> IsGap x)`
3. **Boundary formula agreement** (hform_x at line 2160): `stavi_temporal_truth_mu N r x' A <-> stavi_temporal_truth_mu M r x A`
4. **Round 2 delegation** (line 1706): When Spoiler picks b_sp in [x, c], sigma provides the N-side response b_resp_sig in [x', d]

When x' = d (gap) and x = c (gap):
- Uses 1-3 are extractable from the **forward strategy** directly (not from sigma)
- Use 4 is vacuously unnecessary: [x, c] = {x} has no actual M-points, so Spoiler never picks b_sp <= c

### Dependency Chain

```
h_pt_left (line 327) -----> ih (...) h_pt_left h_restrict_left --> sigma
h_pt_right (line 352) ----> ih (...) h_pt_right h_restrict_right --> tau
h_pt_xc_w (line 373) -----> SplitPointProps.h_pt_xc
h_pt_cy_w (line 390) -----> SplitPointProps.h_pt_cy

sigma --> used in Case I (main strategy), Cases II-IV (boundary info + b_sp <= c delegation)
tau   --> used in Case I (main strategy), Cases II-IV (main strategy)
```

## 2. Literature Review

### GHR93 Definition of d

GHR93 (page 27, line 1381) defines d differently from the formalization:

**Paper**: `d = inf {t in [x', y'] : N |= C(u) for all u in (t, y')}`

This is a formula-defined infimum based on the continuation formula C. The split point d is where the "type pattern changes" -- it does NOT depend on Spoiler's choices.

**Formalization**: `d = a_bwd(n)` (Spoiler's last backward pick, line 217).

This is a significant structural divergence. The paper's d is a property of the structure, while the formalization's d is Spoiler's choice.

### Can d = x' in GHR93?

**Yes.** If the continuation formula C holds throughout all of (x', y'), then the infimum is x'. This happens when the "type beyond a_n" is uniform across the entire interval.

However, GHR93 assumes **strict inequality** x' < y' (line 1359: "if x < y in M_r, x' < y' in N_r"). The paper does not explicitly address d = x' as a special case. Instead, it relies on two implicit facts:

1. **Claim 2** (page 28): The strategy restriction from [x, y] to [x, c] / [c, y] is done by adding c to Spoiler's choices in the full-interval game and using the master strategy's response as d. When d = x', this means the sub-interval [x', d] = {x'} has no interior, and the restricted strategy on [x, c] is vacuously valid.

2. **The case analysis** (page 29): All four cases have "all a_0,...,a_n lie in (d, y')" (Cases II-IV) or "a_0 < d" (Case I). When d = x', Case I is impossible (all a_i >= x' = d), so only Cases II-IV apply. In Cases II-IV, sigma is used only for boundary ordering at x/x', which the paper extracts from the original forward strategy.

### GHR93's Implicit Handling

GHR93 never explicitly constructs sigma on a degenerate interval. The paper's argument in Cases II-IV uses:
- tau for the main play (all selections are in [d, y'])
- The original forward strategy for boundary information at x/x'
- Sigma is conceptually available but never invoked with a Round 2 point challenge from [x, c] (because when d = x', the corresponding c would satisfy c = x, and [x, c] has no points to challenge with)

The paper's approach works because sigma is a restriction of the master forward strategy, and restricting to an empty sub-interval produces a vacuously valid strategy.

### Key Difference: IH Structure

GHR93's Theorem 6 uses strict inequality x < y, x' < y' as the only precondition. The IH applies to all sub-intervals with strict inequality.

The formalization uses weak inequality x <= y with a point-existence hypothesis. The IH requires:
```
x0 <= y0, x0' <= y0', exists p in [x0', y0'] ∩ N, forward_strategy_on_subinterval
```

This extra point-existence requirement is what causes the degenerate case to fail. In GHR93, the IH would simply not apply to [x', x'] (since x' < x' is false), and the paper avoids needing it.

## 3. Solution Design

### Recommended Approach: Two-Track Fix

**Track 1: Direct degenerate-interval backward strategy** (PRIMARY)

Add a lemma that constructs `ghr93_duplicator_wins` on degenerate intervals without the IH:

```lean
/-- When endpoints are equal and both are gaps, the backward game is
    vacuously winnable on one side. Round 2 requires Spoiler to pick
    an actual point from the degenerate interval, which is impossible
    for gap endpoints. -/
theorem ghr93_duplicator_wins_degenerate_gap
    {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {d : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    (hd_gap : IsGap d) (hc_gap : IsGap c)
    (hcd_form : forall (A : StaviFormula), stavi_depth A <= r ->
      (stavi_temporal_truth_mu N atomMap r d A <->
       stavi_temporal_truth_mu M atomMap r c A))
    (hcd_gp : (IsPoint d <-> IsPoint c) /\ (IsGap d <-> IsGap c)) :
    ghr93_duplicator_wins N M atomMap n r d d c c
```

Proof sketch:
- Round 1: All Spoiler picks from [c, c] must be c. Respond with all d's.
- Round 2: Spoiler picks actual M-point from [c, c]. Since c is a gap, no such point exists. Vacuously true.

This lemma provides sigma when x' = d (by instantiating with c = x when x = c is established).

**Track 2: Establish x = c when x' = d** (SUPPORTING)

When d = x' and both are gaps, prove c = x using the forward strategy's formula agreement. The forward strategy gives:
- Formula agreement between x and x' at the boundary
- The continuation formula C holds at x' (and throughout (x', y'))
- By the forward strategy, C also holds at x (and throughout (x, y))
- Therefore c = inf{t in [x,y] : C on (t,y)} = x

This requires the forward strategy to preserve formula C at the boundary, which is guaranteed by the winning condition at index 0 (the x/x' position).

Alternatively, extract c's correspondence to d directly from the forward strategy without the infimum: since c is obtained from a play of the forward strategy matching d, and d = x', the response to x' (which maps to x in the boundary) gives c = x.

### Implementation in obtain_split_point_props

Replace the sorry at line 347 with:

```lean
-- x' = d (degenerate): Set c = x, construct sigma directly
-- Since d = a_bwd(n) = x' and both are gaps, use the forward strategy
-- to show c corresponds to x'. Then sigma on [x', x'] / [x, x] is
-- vacuously true (no actual points in degenerate gap intervals).

-- 1. Derive formula/gap agreement between x' and x from forward strategy
-- 2. Set c = x
-- 3. Apply ghr93_duplicator_wins_degenerate_gap for sigma
-- 4. tau = IH on [d, y'] / [c, y] = [x', y'] / [x, y] (original interval)
```

But this requires restructuring: when x' = d, the entire `obtain_split_point_props` needs to produce a SplitPointProps with c = x, sigma from the degenerate lemma, and tau from the original forward strategy.

### Alternative: Weaken SplitPointProps

Make `h_pt_xc` and `sigma` optional when x' = d:

```lean
structure SplitPointProps ... where
  ...
  -- Either we have points and a strategy, or the interval is degenerate
  h_left_data : (exists p, inClosedInterval x c (extendPoint p)) ∧
                ghr93_duplicator_wins N M atomMap n r x' d x c
              ∨ (x' = d ∧ x = c ∧ IsGap d ∧ IsGap c ∧
                 -- boundary agreement from forward strategy
                 (forall A, stavi_depth A <= r ->
                   (stavi_temporal_truth_mu ... x' A <-> ... x A)) ∧
                 (IsPoint x' <-> IsPoint x) ∧ (IsGap x' <-> IsGap x))
```

This is more invasive but avoids constructing sigma when it's not needed. Cases II-IV would case-split on `h_left_data` and use the boundary info directly in the degenerate case.

### Recommended: Track 1 + inline degenerate handler

The cleanest approach:

1. Add `ghr93_duplicator_wins_degenerate_gap` to EFGames.lean
2. In `obtain_split_point_props`, when x' = d (both gaps):
   - Establish c = x (or more precisely, choose c = x)
   - Provide sigma via `ghr93_duplicator_wins_degenerate_gap` with appropriate formula/gap agreement from the forward strategy
   - h_pt_left is bypassed (sigma doesn't come from IH)
   - h_pt_xc is bypassed (sigma is constructed directly, not via IH)
3. Handle symmetric cases (d = y', x = c, c = y) analogously

## 4. Implementation Sketch

### Step 1: New lemma in EFGames.lean

```lean
theorem ghr93_duplicator_wins_degenerate_gap
    {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {e_N : ExtendedCarrier N atomMap r}
    {e_M : ExtendedCarrier M atomMap r}
    (h_gap_N : IsGap e_N) (h_gap_M : IsGap e_M)
    (h_form : forall (A : StaviFormula), stavi_depth A <= r ->
      (stavi_temporal_truth_mu N atomMap r e_N A <->
       stavi_temporal_truth_mu M atomMap r e_M A))
    (h_gp : (IsPoint e_N <-> IsPoint e_M) /\ (IsGap e_N <-> IsGap e_M)) :
    ghr93_duplicator_wins N M atomMap n r e_N e_N e_M e_M := by
  intro a ha
  -- All a(i) must equal e_M (since inClosedInterval e_M e_M forces it)
  have ha_eq : forall i, a i = e_M := by
    intro i; exact le_antisymm (ha i).2 (ha i).1
  -- Respond with all e_N
  refine ⟨fun _ => e_N, fun _ => ⟨le_refl _, le_refl _⟩, ?_⟩
  -- Round 2: forall b' : M.carrier, inClosedInterval e_M e_M (extendPoint b') -> ...
  intro b' hb'
  -- e_M is a gap, but extendPoint b' is a point. inClosedInterval requires
  -- e_M <= extendPoint b' <= e_M, i.e., extendPoint b' = e_M.
  -- But extendPoint b' = Sum.inl b' and e_M = Sum.inr g for some g (since IsGap).
  -- Sum.inl != Sum.inr, contradiction.
  obtain ⟨g_M, hg_M⟩ := h_gap_M
  have : extendPoint b' = e_M := le_antisymm hb'.2 hb'.1
  rw [hg_M] at this
  exact absurd this (by simp [extendPoint])
```

The proof is essentially: Round 2 requires an actual M-point equal to e_M, but e_M is a gap, so this is contradictory. The universal quantifier over impossible challenges is vacuously true.

### Step 2: Modify obtain_split_point_props

In the degenerate branches (lines 344-347, 365-367, 385-387, 402-404):

For the x' = d case (line 344-347):

```lean
· -- x' = d (degenerate): [x',d] = [d,d] has no actual points
  -- But we don't need a point. We construct sigma directly.
  -- The forward strategy gives formula/gap agreement between x' and x.
  -- We set c = x (justified by the forward strategy correspondence).
  -- Then sigma on [d,d]/[x,x] is vacuously true.
  --
  -- However, this requires restructuring: the surrounding code expects
  -- h_pt_left for the IH. Instead, we short-circuit: provide sigma
  -- via ghr93_duplicator_wins_degenerate_gap.
  subst hx'd_eq  -- x' = d
  -- Extract forward strategy's boundary properties at x/x'=d
  -- ... use the forward strategy to get formula/gap agreement ...
  -- This is available from the suffices block above, which gives
  -- hcd_form and hcd_gp for c/d. But here we need x/x' properties.
  sorry -- placeholder: needs forward strategy boundary extraction
```

The implementation requires extracting x/x' boundary info from the forward strategy, which is already done in the base case (lines 2509-2524) but not yet factored out as a reusable lemma.

### Step 3: Factor out forward strategy boundary extraction

Add a helper that extracts boundary formula/gap/point agreement from any forward game:

```lean
theorem forward_strategy_boundary_agreement
    (h_fwd : ghr93_duplicator_wins M N atomMap k r x y x' y')
    (h_pt : exists p, inClosedInterval x' y' (extendPoint p)) :
    (forall A, stavi_depth A <= r -> (stavi_temporal_truth_mu M r x A <-> ... N r x' A)) /\
    (IsPoint x <-> IsPoint x') /\ (IsGap x <-> IsGap x') /\
    (forall A, stavi_depth A <= r -> (stavi_temporal_truth_mu M r y A <-> ... N r y' A)) /\
    (IsPoint y <-> IsPoint y') /\ (IsGap y <-> IsGap y')
```

## 5. Impact Assessment

### What Changes

| Component | Impact |
|-----------|--------|
| EFGames.lean | +1 new lemma (ghr93_duplicator_wins_degenerate_gap, ~20 lines) |
| ExpressivenessGeneral.lean | Modify 4 sorry branches in obtain_split_point_props |
| SplitPointProps structure | Possibly weaken h_pt_xc/h_pt_cy (make them conditional) |
| Case I | No impact (Case I requires strict a_i < d, incompatible with x' = d) |
| Case II | Minor: when x' = d, d is a point (Case II assumption), so x' is a point too, and [x', d] has an actual point. No degenerate case in Case II. |
| Cases III-IV | These are sorry'd. When implemented, they will need to handle x' = d with the degenerate sigma. The fix ensures SplitPointProps is constructible. |

### Scope

- 4 sorry's removed from obtain_split_point_props (lines 347, 367, 387, 404)
- Total sorry count should decrease by 4
- No impact on already-proved Cases I and II (their code paths don't hit the degenerate case)
- Prerequisites: forward strategy boundary extraction lemma

### Risk Assessment

- **Low risk**: The degenerate lemma is mathematically straightforward (vacuous quantifier)
- **Medium risk**: Establishing c = x when d = x' requires the forward strategy's formula correspondence, which involves the partially sorry'd gap case for c construction (line 496)
- **Mitigation**: If c = x cannot be established from the current infrastructure, an alternative is to leave c as-is and prove that when x' = d (gap), x must also be a gap AND c must equal x by forward strategy correspondence. This follows from the forward strategy winning condition at the boundary.

## 6. Confidence Level

**High confidence** in the mathematical correctness of the solution:
- The degenerate game is vacuously winnable (Round 2 over empty domain)
- GHR93 implicitly handles this by never needing sigma on a degenerate interval
- The fix is structurally local to obtain_split_point_props

**Medium confidence** in implementation feasibility:
- The forward strategy boundary extraction is well-understood (used in base case already)
- The main uncertainty is whether c = x follows cleanly from the current infrastructure
- If the gap case for c (line 496) remains sorry'd, the degenerate fix may need to be structured differently (e.g., making SplitPointProps conditional rather than constructing sigma)

## 7. Answers to Specific Questions

### Q(a): Can d ever equal x' in GHR93?

**Yes.** When the continuation formula C holds throughout all of (x', y'), the infimum d = x'. This happens when the type pattern is uniform across the entire interval.

### Q(b): Does the paper handle d = x' as a special case?

**No.** The paper does not explicitly address d = x'. It handles this implicitly: when d = x', all selections lie in [d, y'] = [x', y'], Case I is impossible, and Cases II-IV use only tau (sigma is never invoked with a meaningful Round 2 challenge).

### Q(c): What could guarantee x' < d strictly?

Nothing in the current formalization. The formalization sets d = a_bwd(n), and Spoiler can choose a_bwd(n) = x'. In the paper's approach (infimum), d = x' is possible when C holds uniformly.

### Q(d): Could we add h_x'_lt_d as a hypothesis to the IH?

**No.** This would be mathematically unsound. The IH is applied to sub-intervals, and there's no guarantee that the split point is strictly between the endpoints.

### Q(e): Is the degenerate case avoidable by construction?

**Partially.** If d were defined as an infimum (as in GHR93) rather than as a_bwd(n), the degenerate case would still arise (C can hold everywhere). The case is not avoidable but IS handleable: the backward game on a degenerate gap interval is vacuously true.

### Q(f): Can we bypass sigma when x' = d?

**Yes.** When x' = d (both gaps), sigma's Round 2 is vacuously satisfied (no actual N-points in [d, d]). The boundary information (ordering, gap/point, formulas at x/x') can be extracted from the original forward strategy instead of from sigma. This is the recommended solution.

### Q(5): Does Round 2 require a point response when the interval is degenerate?

Round 2 is universally quantified: "for all actual points b' in [x', y'] ∩ N". When the interval is degenerate [d, d] and d is a gap, there are no actual points. The universal quantifier ranges over an empty set, making Round 2 vacuously true. Duplicator wins without needing to respond.

However, in the backward game sigma = `ghr93_duplicator_wins N M atomMap n r x' d x c`, the Round 2 quantifier is over actual M-points in [x, c] (not N-points in [x', d]). So even when [x', d] is degenerate, Round 2 fires if [x, c] has actual M-points. The response must be an N-point in [x', d], which is impossible. The fix requires either:
- Showing [x, c] is also degenerate (x = c, both gaps) -- making Round 2 vacuous
- Providing a direct degenerate-interval winning strategy that proves the contradiction

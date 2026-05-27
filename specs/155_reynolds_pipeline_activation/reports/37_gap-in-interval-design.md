# Interval-Restricted Gap Detection Design for GapDetection.lean

## Executive Summary

This report designs the approach for closing the two interval bound sorries in `ghr93_cases_III_IV` (CaseAnalysis.lean lines ~3360 and ~3809):
- Sorry #1 (LEFT case): `Sum.inr gamma_M <= y`
- Sorry #2 (RIGHT case): `x <= Sum.inr gamma_M`

The analysis confirms that **no new definitions are needed in GapDetection.lean**. The existing code in CaseAnalysis.lean already contains a complete proof-by-contradiction for Sorry #1 (LEFT case), fully implemented at lines 3359-3498. The RIGHT case sorry at line 3809 follows the same pattern. The handoff document (phase-5-interval-bound-handoff-20260527.md) describes the correct strategy, and most of the implementation is already in place.

## 1. Current Infrastructure Inventory

### 1.1 Core Definitions (Defs.lean)

| Definition | Location | Signature |
|------------|----------|-----------|
| `Gap T` | Defs.lean:236 | Structure with `cut : Set T`, `nonempty`, `proper`, `downward_closed`, `no_sup`, `complement_no_min` |
| `gap_ext` | Defs.lean:254 | `gamma1.cut = gamma2.cut -> gamma1 = gamma2` |
| `gap_cuts_total` | Defs.lean:262 | `gamma1.cut ⊆ gamma2.cut \/ gamma2.cut ⊆ gamma1.cut` |
| `gap_definable_on_left` | Defs.lean:287 | D holds on final segment of cut AND D does NOT hold on initial segment of complement |
| `gap_definable_on_right` | Defs.lean:301 | D holds on initial segment of complement AND D does NOT hold on final segment of cut |
| `r_definable_gap` | Defs.lean:313 | `exists D, stavi_depth D <= r /\ (gap_definable_on_left ... D \/ gap_definable_on_right ... D)` |
| `RDefinableGap` | Defs.lean:321 | `{ g : Gap M.carrier // r_definable_gap M atomMap g r }` |
| `ExtendedCarrier` | Defs.lean:335 | `M.carrier + RDefinableGap M atomMap r` |
| `extendedLE` | Defs.lean:342 | Ordering: point x <= gap g iff x in g.cut |

### 1.2 Gap Detection Formulas (GapDetection.lean)

| Definition | Lines | Purpose |
|------------|-------|---------|
| `left_formula_base` | 48-77 | Left gap detection for base (Formula) constructors |
| `left_formula` | 92-127 | Left gap detection for StaviFormula; converts A^mu(gamma) to evaluable formula at actual points |
| `right_formula_base` | 131-156 | Right gap detection for base constructors (dual) |
| `right_formula` | 166-200 | Right gap detection for StaviFormula (dual) |

### 1.3 Rank Bounds (GapDetection.lean)

| Theorem | Lines | Bound |
|---------|-------|-------|
| `stavi_depth_left_formula` | 276-303 | `stavi_depth (left_formula A D) <= max (stavi_depth A) (stavi_depth D) + 4` |
| `stavi_depth_right_formula` | 311-350 | Same bound for right_formula |

### 1.4 Truth at Actual Points (GapDetection.lean)

| Theorem | Lines | Purpose |
|---------|-------|---------|
| `extendPoint_lt_iff` | 360-367 | `extendPoint x < extendPoint y <-> x < y` |
| `temporal_truth_mu_at_point` | 371-413 | mu-truth at actual point = standard truth |
| `stavi_truth_mu_at_point` | 417-761 | Same for StaviFormula (long inductive proof) |

### 1.5 Gap Uniqueness (GapDetection.lean)

| Theorem | Lines | Signature |
|---------|-------|-----------|
| `gap_detection_unique` | 776-813 | Two left-D-definable gaps above same m with D-between => equal |
| `gap_detection_unique_right` | 3130-3159 | Two right-D-definable gaps below same m with D-between => equal |

### 1.6 Gap Detection Correctness (GapDetection.lean, Lemma 9)

| Theorem | Lines | Summary |
|---------|-------|---------|
| `stavi_untl_gap_detection` | 840-1091 | `U'(X,D)(m) <-> exists gamma above m, D-def-left, D-between, X at complement points` |
| `stavi_snce_gap_detection` | ~2870 (approx.) | Dual for `S'(X,D)` and right-definable gaps |
| `left_formula_gap_detection` | 1131-~2700 | `left_formula(A,D)(m) <-> exists gamma above m, D-def-left, D-between, A^mu(gamma)` |
| `right_formula_gap_detection` | 3161-~4800 | Dual for right_formula |

### 1.7 Auxiliary Infrastructure (CustomGame.lean)

| Definition | Lines | Purpose |
|------------|-------|---------|
| `sf_verum` | 687 | StaviFormula for True (`.neg (.base .bot)`) |
| `gap_char_formula D` | 782-787 | `(S'(T,D) /\ ~U'(T,D)) \/ (U'(T,D) /\ ~S'(T,D))` — characterizes D-definable gaps |
| `stavi_depth_gap_char_formula` | 791-793 | `stavi_depth (gap_char_formula D) = stavi_depth D + 2` |

### 1.8 TypeFormulas.lean Infrastructure

| Definition | Purpose |
|------------|---------|
| `rank_embed` | Order-preserving embedding `ExtendedCarrier M atomMap r -> ExtendedCarrier M atomMap r'` |
| `rank_embed_point` | `rank_embed h (extendPoint x) = extendPoint x` |
| `rank_embed_le` | `rank_embed h a <= rank_embed h b <-> a <= b` |
| `r_definable_gap_mono` | If gap is r-definable, it is r'-definable for r' >= r |

## 2. Analysis of the Sorry Sites

### 2.1 Sorry #1: LEFT case `Sum.inr gamma_M <= y` (line ~3360)

**Context**: Non-degenerate LEFT case where `gamma_N` is D-definable on the left and `y' > Sum.inr gamma_N`.

**What is already implemented** (lines 3359-3498): The code already contains a COMPLETE proof by contradiction:

1. **Line 3360**: Lower bound proved: `le_of_lt (lt_of_le_of_lt hm_M_in.1 hm_lt_gamma_M)`
2. **Line 3361**: Upper bound starts `by_contra h_not_le; push_neg at h_not_le`
3. **Lines 3364-3393**: Step 2a: Find complement element `t0` of `gamma_N` with `extendPoint t0 <= y'`
4. **Lines 3394-3396**: Step 2b: Apply `_h_no_init` to get `p_N` with `not D(p_N)` and `p_N not in gamma_N.cut`
5. **Lines 3398-3400**: Step 2c: Show `m_N < p_N` from cut/complement
6. **Lines 3402-3403**: Step 2d: `p_N in [m_N, y']`
7. **Lines 3405-3441**: Step 2e: Sub-interval forward game via `h_r1_univ`
8. **Lines 3443-3472**: Step 2f-2g: Order agreement gives `m_M < p_M`
9. **Lines 3474-3481**: Step 2h: `p_M in gamma_M.cut` since `extendPoint p_M <= y < Sum.inr gamma_M`
10. **Lines 3483-3484**: Step 2i: `D(p_M)` from `h_D_bet_gamma_M`
11. **Lines 3486-3498**: Step 2j: Formula agreement at p_M/p_N gives `D(p_N)`, contradicting `not D(p_N)`

**Verdict**: This sorry is ALREADY CLOSED. The proof is fully written inline. There is no `sorry` keyword in the LEFT case interval bound. The `by` block at line 3361 contains the complete proof ending at line 3498 with `exact hpN_not_D hD_p_N`.

### 2.2 Sorry #2: RIGHT case `x <= Sum.inr gamma_M` (line ~3809)

**Context**: Non-degenerate RIGHT case where `gamma_N` is D-definable on the right.

**What is at line 3809**: Reading the code more carefully, line 3809 shows `by sorry` inside the `hgamma_M_in` construction for the RIGHT case. This is inside the degenerate boundary case (`x' = Sum.inr gamma_N`), specifically in the sub-case where `c = y, d = y', both gaps`. Looking at the exact code:

```lean
have hγ_M_in : inClosedInterval x y (Sum.inr γ_M) :=
  ⟨by sorry,
   le_of_lt (lt_of_lt_of_le hm_gt_γM hm_M_in.2)⟩
```

This is inside the RIGHT case, non-degenerate section, and the `sorry` is for the lower bound `x <= Sum.inr gamma_M`.

**Strategy**: Symmetric to the LEFT case. The proof by contradiction assumes `Sum.inr gamma_M < x` and derives a contradiction using:
1. Find complement element `t0` of `gamma_N` with `x' <= extendPoint t0` (complement elements are below the gap for right-definable gaps)
2. Apply the negated-final-segment condition to get `p_N` with `not D(p_N)` in the complement
3. Show `p_N < m_N` from complement/cut membership  
4. Sub-interval forward game on `[x, m_M]` vs `[x', m_N]` via `h_r1_univ`
5. Order agreement gives `p_M < m_M`
6. `p_M not in gamma_M.cut` since `extendPoint p_M >= x > Sum.inr gamma_M`
7. `D(p_M)` from `h_D_bet_gamma_M`
8. Formula agreement gives `D(p_N)`, contradicting `not D(p_N)`

### 2.3 Sorry #3: Winning condition assembly (line ~3923)

This is a separate concern (the full `sorry` at line 3923 for the winning condition assembly) and is not part of the interval bound question. It is blocked on sel_pn_ord (Phase 3C).

## 3. GHR93 Faithful Design

### 3.1 What GHR93 Does (pp. 116-119)

GHR93 does NOT restrict gap detection to an interval. Instead:
1. `left_formula_gap_detection` finds a D-definable gap GLOBALLY above a reference point m
2. The interval bound is derived AFTER gap detection by using the gap's defining formula D
3. For a left-D-definable gap gamma_M: D holds at all points beyond gamma_M in the cut. If gamma_M > y (outside the interval), then any point p_M with m_M < p_M <= y must be in gamma_M.cut, hence D(p_M). But the forward game transfers NOT-D from the N-side, giving a contradiction.

### 3.2 Why No New GapDetection.lean Infrastructure Is Needed

The current `left_formula_gap_detection` and `right_formula_gap_detection` are perfectly adequate. The interval bound is NOT a property of gap detection -- it is a consequence of the contradiction argument in the calling code. The key insight from GHR93 (and confirmed in report 35) is:

> The gap is automatically in the interval because any gap OUTSIDE the interval would create a D-truth contradiction via the forward game.

This is exactly what the existing proof at lines 3361-3498 implements for the LEFT case.

### 3.3 Formal Statement of the Interval Bound Lemma (NOT Recommended)

One could define a standalone lemma:

```lean
theorem gap_in_interval_left {gamma_M : RDefinableGap M atomMap r}
    {D : StaviFormula} {m_M : M.carrier} {y : ExtendedCarrier M atomMap r}
    (h_def : gap_definable_on_left M atomMap gamma_M.val D)
    (h_D_bet : forall u, m_M < u -> u in gamma_M.val.cut -> 
        stavi_temporal_truth_mu M atomMap r (extendPoint u) D)
    (hm_lt : extendPoint m_M < Sum.inr gamma_M)
    (hm_le_y : extendPoint m_M <= y)
    (h_no_D_above : exists p_M : M.carrier, m_M < p_M /\ 
        extendPoint p_M <= y /\ not (stavi_temporal_truth M atomMap p_M D)) :
    Sum.inr gamma_M <= y
```

However, this is NOT recommended because:
1. The witness `p_M` (the point with NOT-D) comes from the sub-interval forward game, which requires the full game infrastructure context
2. Extracting this into a standalone lemma would require passing many parameters
3. The inline proof (already written for the LEFT case) is the cleanest approach

## 4. Integration Points

### 4.1 LEFT Case (Lines 3359-3498): ALREADY CLOSED

The proof at lines 3359-3498 is complete. The `by` block starting at line 3361 contains the full contradiction argument. No changes needed.

### 4.2 RIGHT Case (Line ~3809): Needs Implementation

The `sorry` at line 3809 is for `x <= Sum.inr gamma_M` in the RIGHT non-degenerate case. This needs a symmetric proof to the LEFT case:

**Location**: Inside `h_gap_match` in the RIGHT case, after:
```lean
obtain ⟨γ_M, hm_gt_γM, h_def_γM_right, h_D_bet_γM, _⟩ := ...
```

**Proof structure** (symmetric to LEFT, swapping directions):
1. Assume `Sum.inr gamma_M > x` (i.e., `x < Sum.inr gamma_M`)
2. Find complement element `t0` of `gamma_N` with `x' <= extendPoint t0`:
   - For right-definable gaps, complement is ABOVE the gap
   - `x' <= Sum.inr gamma_N < extendPoint t_N` (since `t_N not in gamma_N.cut`)
   - Case split on x' being a point or gap to find t0
3. Apply the negated-final-segment condition `_h_no_final` (pushed neg):
   - `forall t in gamma_N.cut, exists u in gamma_N.cut, t <= u /\ not D(u)`
   - This gives `p_N in gamma_N.cut` with `not D(p_N)` and `p_N <= t0`
4. Show `p_N < m_N` (m_N is in complement, p_N is in cut)
5. Sub-interval forward game on `[x, m_M]` vs `[x', m_N]` via `h_r1_univ`
6. Order agreement: `p_M < m_M` (from `p_N < m_N`)
7. `p_M not in gamma_M.cut` since `extendPoint p_M >= x > Sum.inr gamma_M`
8. `D(p_M)` from `h_D_bet_gamma_M` (D holds at complement elements above gamma_M below m_M)
9. Formula agreement gives `D(p_N)`, contradicting `not D(p_N)`

**Wait -- re-reading the code**: Actually, for the RIGHT case, the D-between condition is:
```
h_D_bet_γM : forall u, u < m_M -> u not in gamma_M.cut -> 
    stavi_temporal_truth_mu M atomMap r (extendPoint u) D
```

And `gap_definable_on_right` means:
- D holds at initial segment of complement (elements NOT in cut, i.e., above the gap)  
- D does NOT hold at any final segment of the cut

For the RIGHT case, `gamma_M < m_M` (gap is below the reference point). If `x > Sum.inr gamma_M`, then any point p_M with `x <= extendPoint p_M < m_M` has `p_M not in gamma_M.cut` (since `extendPoint p_M >= x > Sum.inr gamma_M`). Then `h_D_bet_gamma_M` gives `D(p_M)`.

The N-side uses the negated final segment condition: `_h_no_final` (negated): `forall t in gamma_N.cut, exists u in gamma_N.cut, t <= u /\ not D(u)`. Wait -- actually for `gap_definable_on_right`, the second conjunct is:
```
not (exists t, t in gamma.cut /\ forall u, t <= u -> u in gamma.cut -> D(u))
```
This says there is NO final segment of the cut where D holds everywhere.

Hmm, let me re-examine. For the right case, `gamma_N` is D-definable on the right:
- First conjunct: `exists t not in gamma_N.cut, forall u not in gamma_N.cut, u <= t -> D(u)` (D on initial complement segment)
- Second conjunct: `not (exists t in gamma_N.cut, forall u >= t in gamma_N.cut -> D(u))` (no D on final cut segment)

The negated second conjunct gives: `forall t in gamma_N.cut, exists u >= t in gamma_N.cut, not D(u)`.

For the contradiction: if `x > Sum.inr gamma_M`, find p_N in `gamma_N.cut` with `not D(p_N)`. Then:
- `p_N in gamma_N.cut` means `extendPoint p_N < Sum.inr gamma_N < extendPoint m_N`
- So `p_N < m_N`
- Also need `x' <= extendPoint p_N`. Since `x' <= Sum.inr gamma_N` and `p_N in gamma_N.cut`, we need `x' <= extendPoint p_N`. This requires careful choice of the cut witness.

**Revised approach for RIGHT sorry #2**:

Actually, let me re-read the exact sorry context more carefully.

Actually, looking at the code at line 3809 again:
```lean
have hγ_M_in : inClosedInterval x y (Sum.inr γ_M) :=
  ⟨by sorry,
   le_of_lt (lt_of_lt_of_le hm_gt_γM hm_M_in.2)⟩
```

The upper bound `Sum.inr gamma_M <= y` is already proved: `le_of_lt (lt_of_lt_of_le hm_gt_γM hm_M_in.2)` (since `gamma_M < m_M <= y`).

The sorry is for the LOWER bound `x <= Sum.inr gamma_M`. 

For right-definable gaps: `gamma_M < m_M` (gap is below reference point). We need `x <= Sum.inr gamma_M`.

Proof by contradiction: Assume `Sum.inr gamma_M < x`.
- gamma_M.cut is below gamma_M, so gamma_M.cut is entirely below x
- Points NOT in gamma_M.cut with extendPoint >= x are above the gap AND in [x, y]
- From `_h_no_final` (pushed neg from right-definable): forall t in gamma_N.cut, exists u >= t in gamma_N.cut, not D(u)
- Find t0 in gamma_N.cut with `x' <= extendPoint t0` (lower bound witness)
- Apply the cut-cofinal to get `p_N in gamma_N.cut` with `not D(p_N)` above t0
- `p_N < m_N` (both in [x', m_N] since p_N in cut and m_N not in cut)
- Sub-interval game on [x, m_M] vs [x', m_N]
- Challenge with p_N, get p_M
- Order agreement: p_M < m_M
- `p_M not in gamma_M.cut` since x <= extendPoint p_M but Sum.inr gamma_M < x, so extendPoint p_M > Sum.inr gamma_M
- Actually wait -- `p_M not in gamma_M.cut` means `extendPoint p_M > Sum.inr gamma_M`, which would be true if `extendPoint p_M >= x > Sum.inr gamma_M`
- `D(p_M)` from `h_D_bet_gamma_M` since `p_M < m_M` and `p_M not in gamma_M.cut`
- Formula agreement gives `D(p_N)`, contradiction

But we need `extendPoint p_M >= x`. That comes from the game bounds: `p_M in [x, m_M]` from the sub-interval game.

Actually, looking more carefully at the sub-interval: the game is on [x, m_M] vs [x', m_N]. The N-side challenge p_N must be in [x', m_N]. The M-side response p_M is in [x, m_M]. So `x <= extendPoint p_M` is guaranteed by the game.

## 5. Estimated Complexity

### 5.1 Sorry #1 (LEFT interval bound): Already Closed

Lines 3359-3498 contain the complete proof. No further work needed.

**Verification needed**: Confirm the code builds without sorry. The current sorry list from grep shows no sorry at line 3360. The `by` block is a complete proof.

### 5.2 Sorry #2 (RIGHT interval bound, line ~3809): ~120-150 lines

The proof follows the same structure as the LEFT case (lines 3361-3498) with the following swaps:
- `left` <-> `right` for gap definability
- `m < u` <-> `u < m` for D-between
- `u in cut` <-> `u not in cut` for D-between
- `x` <-> `y` for interval bounds
- Sub-interval: `[x, m_M]` vs `[x', m_N]` instead of `[m_M, y]` vs `[m_N, y']`
- The negated condition: `_h_no_final` instead of `_h_no_init`

Key steps (estimated lines):
1. Find complement element t0 of gamma_N with x' <= extendPoint t0: ~30 lines (case split on x')
2. Apply negated-no-final to get p_N not D, p_N in cut: ~10 lines  
3. Show p_N < m_N: ~5 lines
4. p_N in [x', m_N]: ~5 lines
5. Sub-interval forward game setup: ~30 lines
6. Challenge + order agreement: ~30 lines
7. D(p_M) from h_D_bet_gamma_M: ~10 lines
8. Formula agreement contradiction: ~15 lines

Wait -- let me re-examine. For the RIGHT case, the D-between condition works differently. From `gap_definable_on_right`:
- D holds at an initial segment of the COMPLEMENT (points NOT in cut)
- D does NOT hold at any final segment of the CUT

The negated second conjunct gives: for all t in cut, exists u >= t in cut, not D(u).

So p_N is found in the CUT (not complement). Since p_N is in the cut: `extendPoint p_N <= Sum.inr gamma_N`. And m_N is NOT in the cut: `extendPoint m_N > Sum.inr gamma_N`. So `extendPoint p_N < extendPoint m_N`, hence `p_N < m_N`.

For the t0 witness: need t0 in gamma_N.cut with `x' <= extendPoint t0`. Since `x' <= Sum.inr gamma_N` and the cut is non-empty with elements below the gap, we need a cut element above x'. Case split:
- x' is a point p_x: if p_x in gamma_N.cut, use p_x (or gap_cut_exists_gt for a larger one)
- x' is a gap g_x with g_x.cut subset gamma_N.cut: find m0 in gamma_N.cut \ g_x.cut

This mirrors the LEFT case reference point construction at lines 3115-3209.

### 5.3 Sorry #3 (Winning condition, line ~3923): ~200 lines, BLOCKED on sel_pn_ord

Not related to interval bounds. Requires Phase 3C.

### 5.4 New GapDetection.lean definitions: 0 lines

No new definitions or lemmas needed in GapDetection.lean.

## 6. Risk Assessment

### 6.1 Low Risk: LEFT case already closed
The proof is fully written. Only verification needed.

### 6.2 Medium Risk: RIGHT case proof symmetry
The RIGHT case is symmetric to the LEFT case, but "symmetric" in Lean means manually writing the dual proof. Risks:
- The `_h_no_final` negation may have a different shape than `_h_no_init`
- The reference point construction for the RIGHT case may differ in subtle ways (cut vs complement membership conditions are swapped)
- The sub-interval game direction is reversed (lower endpoint instead of upper)

### 6.3 Mitigations
- The LEFT case proof (lines 3361-3498) provides a complete template
- The handoff document describes the exact strategy
- The rank embedding mechanics are already resolved (rank_embed_comp, rank_embed_point)
- `h_r1_univ` provides games at any rank and any sub-interval

### 6.4 No Risk of Sorry Introduction
The approach uses only existing infrastructure. No new sorries needed. No axioms introduced.

## 7. Recommendations

1. **Verify LEFT case is sorry-free**: Run `lake build` and confirm no sorry at line ~3360. The grep output shows sorries at lines 3809 and 3923 but NOT at line 3360, confirming the LEFT case is closed.

2. **Implement RIGHT case sorry #2**: Write the symmetric proof at line 3809. Estimated 120-150 lines, 2-4 hours. Follow the LEFT case template (lines 3361-3498) with the direction swaps documented above.

3. **Do NOT add new GapDetection.lean infrastructure**: The existing `left_formula_gap_detection` and `right_formula_gap_detection` are sufficient. The interval bound follows from the contradiction argument in the calling code, exactly as GHR93 intended.

4. **Do NOT attempt sorry #3 (winning condition)**: This is blocked on sel_pn_ord (Phase 3C) and is a separate concern from interval bounds.

# EF Game Composition Techniques for Linear Orders

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-26
**Focus**: Cross-boundary ordering composition in Case II of the GHR93 inductive step

---

## 1. The Technical Problem (Precise Statement)

In CaseAnalysis.lean, `ghr93_case_II` constructs Duplicator's response in the backward (n+1)-round game when all of Spoiler's selections lie in [d,y'] and a_bwd(n) is an actual carrier point p_n.

The proof assembles orderings from THREE sub-games:

| Sub-game | Interval (N-side / M-side) | Positions it orders |
|----------|---------------------------|---------------------|
| **tau** | [d, y'] / [c, y] | a_init(k), b_resp vs d, y' / resp_tau(k), b_sp vs c, y |
| **sigma** | [x', d] / [x, c] | b_resp vs x', d / b_sp vs x, c (Case A only) |
| **d-compatible forward** | [x, y] / [x', y'] | c vs e_n, x vs e_n, e_n vs y / d vs p_n, x' vs p_n, p_n vs y' |

The ordering goals that must be discharged form an (N+3) x (N+3) grid where N = n+1 positions plus x/x', b/b_resp, y/y'. The grid cases decompose into:

- **Tau-internal**: a_init(k) vs a_init(k'), b_resp vs a_init(k), etc. -- all available from tau.
- **Forward-internal**: x vs e_n, e_n vs y, x vs y -- all available from the d-compatible game.
- **Cross-boundary**: a_init(k) vs extendPoint p_n, b_resp vs extendPoint p_n -- these cross the tau/forward boundary.
- **x/x' vs tau positions**: x vs resp_tau(k), x' vs a_init(k) -- these require (x' < d <-> x < c) plus tau's (d < a_init(k) <-> c < resp_tau(k)), composed via pivot_chain_order.

### Sorry Sites

There are **3 sorry locations** in Case II:

1. **Line 1569** (Case A, `same_order_type`): 1 fallback sorry in the `first | ... | sorry` chain. Most grid goals close, but some edge cases involving sel(i) vs p_n with index arithmetic mismatches fall through.

2. **Line 1657** (Case B, `same_order_type`): Full sorry. The comment at line 1712 states: "The proof needs (x' < d <-> x < c) for pivot_chain_order but this is not directly available from forward or tau games."

3. **Line 2628** (Cases III-IV): Full sorry pending Lemma 9 (gap detection). Separate blocker, not analyzed here.

## 2. Literature: EF Game Composition on Linear Orders

### 2.1 Standard Composition Theorem (Shelah, Gurevich)

The classical EF game composition theorem for linear orders states:

**Theorem (Composition)**: Given linear orders A, B, and their ordered sum A + B, Duplicator's strategy on A + B can be composed from strategies on A and B separately. Specifically, if Duplicator wins the k-round game on A vs A' and the k-round game on B vs B', then Duplicator wins the k-round game on A+B vs A'+B'.

The key insight for cross-boundary orderings is simple: **positions from different sub-intervals have a natural ordering inherited from the ambient linear order**. If a is from the left interval [x, c] and b is from the right interval [c, y], then a <= c <= b in the ambient order. The game does NOT need to establish this ordering game-theoretically -- it follows from the sub-interval containment.

### 2.2 The Pivot-Chain Method (What the Codebase Uses)

The codebase implements composition via `pivot_chain_order`:

```
Given: a <= p <= b  and  a' <= q <= b'
Given: (a < p <-> a' < q) and (a = p <-> a' = q)   -- "left leg"
Given: (p < b <-> q < b') and (p = b <-> q = b')   -- "right leg"
Derive: (a < b <-> a' < b') and (a = b <-> a' = b')
```

This composes orderings through a common pivot point. The standard use pattern:
- Sigma gives orderings relative to d/c
- Tau gives orderings relative to d/c  
- Forward game gives orderings relative to c/d and e_n/p_n
- Chain: x/x' -- [sigma] --> d/c -- [tau] --> a_init(k)/resp_tau(k)

### 2.3 Cross-Boundary via Ambient Order (Standard Approach)

In the model theory literature (Hodges, Poizat, Rosenstein), when composing EF game strategies on sub-intervals [a,b] and [b,c] of a single linear order, cross-boundary orderings are NOT derived from the games themselves. Instead:

- Any position from the left game lies in [a,b], hence is <= b
- Any position from the right game lies in [b,c], hence is >= b
- Therefore left positions <= b <= right positions
- The ordering DIRECTION is known by containment
- The ORDER-EQUIVALENCE (whether the iff holds between the two structures) follows by chaining through b/b' using the two games' orderings at their shared boundary

This is exactly what `pivot_chain_order` formalizes.

## 3. Codebase Infrastructure Inventory

### 3.1 What Exists and Works

| Infrastructure | Location | Status |
|----------------|----------|--------|
| `pivot_chain_order` / `pivot_chain_order'` | CustomGame.lean, EFGameTactics.lean | Complete, sorry-free |
| `pivot_chain_order_rev` / `pivot_chain_order_rev'` | Same | Complete, sorry-free |
| `same_order_type_grid` | EFGameTactics.lean | Tactic, works |
| `simp_game_tuple` | EFGameTactics.lean | Tactic, works |
| `order_refl` / `order_refl_pair` | EFGameTactics.lean | Complete |
| `ghr93_strategy_restrict_left/right` | CustomGame.lean | Complete, sorry-free |
| `ghr93_duplicator_wins_round_mono` | CustomGame.lean | Complete, sorry-free |
| `ghr93_duplicator_wins_degenerate_gap` | CustomGame.lean | Complete, sorry-free |
| `d_consistency_left/right` | DConsistencyTransport.lean | Boundary sorry-free; interior sorry'd |

### 3.2 What's Missing

1. **No general game composition combinator**: There is no `compose_games` or `merge_winning_conditions` lemma that takes two sub-game winning conditions and produces a combined winning condition. Each case (I, II, III-IV) does ad-hoc assembly.

2. **No (x' < d <-> x < c) extraction lemma**: This fact can be obtained by instantiating sigma with a trivial selection, but there is no reusable lemma for "extract boundary orderings from a game." Each call site must manually construct and instantiate.

3. **No cross-boundary ordering bridge**: No lemma takes tau's orderings on [d,y']/[c,y] and the forward game's orderings on [x,y]/[x',y'] and produces orderings involving both sets of positions.

## 4. Analysis: "Use the Ambient Linear Order" Approach

### 4.1 Viability Assessment

The ambient-linear-order approach IS the standard approach and IS what the codebase already uses via `pivot_chain_order`. The issue is not conceptual but operational: Case B is missing one link in the pivot chain.

The pivot chain for cross-boundary orderings works as follows:

```
a_init(k) vs p_n:
  a_init(k) >= d (by h_no_split, all selections >= d)
  p_n >= d (by h_no_split at position n, plus hp_n)
  resp_tau(k) >= c (by hresp_tau_in)
  e_n >= c (by hc_le_en, derived from hord_cd_en_pn + hd_le_pn)

  Chain: d/c -- [tau_d_sel] --> a_init(k)/resp_tau(k)  (left leg)
         d/c -- [hord_cd_en_pn] --> p_n/e_n              (right leg)
  
  By pivot_chain_order_rev (since both endpoints >= the pivot):
    (a_init(k) < p_n <-> resp_tau(k) < e_n)
```

This chain works perfectly. The pivot is d/c and both a_init(k) and p_n are >= d (resp. resp_tau(k) and e_n >= c).

### 4.2 Why This Already Works for Case A

In Case A (lines 1512-1516), the code already uses exactly this chain:

```lean
| (exact pivot_chain_order_rev' hd_le_pn (hd_le_sel ...)
        hc_le_en (hc_le_rtau ...)
        hord_cd_en_pn (tau_d_sel ...))
| (exact pivot_chain_order' (hd_le_sel ...) hd_le_pn
        (hc_le_rtau ...) hc_le_en (tau_d_sel ...) hord_cd_en_pn)
```

### 4.3 Why Case B Is Blocked

Case B (b_sp > c) uses tau for Round 2 instead of sigma. The critical difference: in Case A, sigma is instantiated (with trivial selection), giving `sig_x_d : (x' < d <-> x < c)` which is needed for x/x' vs tau positions. In Case B, sigma is NOT instantiated, so `sig_x_d` is unavailable.

However, for the **a_init(k) vs p_n** orderings specifically, sigma is NOT needed -- the pivot through d/c using tau_d_sel and hord_cd_en_pn suffices (as shown in Section 4.1). The dead code at lines 1793-1798 confirms this chain is used for sel vs sel cross-boundary cases even in Case B.

The sorry at line 1657 is the OUTER sorry that encompasses the entire same_order_type grid. The dead code below (lines 1658-1812) shows all G0-G12 goals with their proofs. Some goals (G0, G2, G3, G9 -- involving x/x') use sigma orderings and are therefore blocked. Other goals (G4, G5, G10, G11, G12 -- purely tau + forward) should work.

**Root cause**: The sorry was placed at the top level because SOME goals (x/x' vs tau positions) require sigma, and the dead code wasn't functional. But the sel vs p_n orderings are NOT among the blocked goals.

## 5. Analysis: b_en = p_n Uniqueness Argument

### 5.1 What the Task Description Asks

Could we show that the tau game's Round 2 response `b_en` to challenge `e_n_pt` equals `p_n`? If so, tau would directly give orderings between a_init(k) and p_n.

### 5.2 Assessment: Not Viable

The tau game runs on [d,y'] (N-side) vs [c,y] (M-side). When challenged with b_sp (an M-carrier point in [c,y]), tau responds with some b_resp (N-carrier point in [d,y']). There is no uniqueness guarantee for b_resp.

In general, for EF games on linear orders, the response to a Round 2 challenge is NOT unique. Given a challenge point, any carrier point with the same type relative to existing positions is a valid response. The tau game guarantees winning condition, not response identity.

Furthermore, `b_en` (tau's response to e_n challenge) lives in [d,y'] while `p_n` also lives in [d,y'], but they need not be equal. They have the same rank-r type (from formula agreement), but the game allows multiple elements with the same type.

**Verdict**: The uniqueness approach is NOT viable for the general case.

## 6. The Solution: Sigma Instantiation in Case B

### 6.1 Strategy

The solution is straightforward: instantiate sigma with a trivial selection in Case B, purely to extract boundary orderings. This is the approach mentioned at line 1714.

**Key observation**: sigma is `ghr93_duplicator_wins N M atomMap n r x' d x c`, universally quantified over all selections from [x',d]. We can instantiate it with `(fun _ : Fin n => d)` (all elements = d, which is in [x',d] since d <= d). This gives a response in [x,c] and a Round 2 play from which we can extract:

```
sig_x_d : (x' < d <-> x < c) ∧ (x' = d <-> x = c)
```

This is already done in Case A (line 1339-1343). The same construction works in Case B.

### 6.2 What Sigma Instantiation Provides

After instantiating sigma in Case B with trivial selection and an arbitrary [x,c] point for Round 2:

```lean
have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
-- Need a point in [x,c] for Round 2. Use h_pt_xc.
obtain ⟨p_xc, hp_xc⟩ : ∃ p, inClosedInterval x c (extendPoint p) := by
  rcases props.h_pt_xc with ⟨p, hp⟩ | ⟨hxc_eq, _, _, _⟩
  · exact ⟨p, hp⟩
  · -- degenerate: x = c, both gaps -> no point needed, just use any point
    -- Actually in Case II, a_bwd(n) is a point so d is a point,
    -- and hcd_gp says c is also a point. Contradiction with IsGap c.
    -- So this branch is impossible.
    ...
obtain ⟨_resp_sig_triv, _, hwin_sig_triv⟩ :=
  props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
obtain ⟨_, _, hcond_sig_triv⟩ := hwin_sig_triv p_xc hp_xc
obtain ⟨hord_sig_triv, _, _⟩ := hcond_sig_triv
-- Now extract boundary orderings:
have sig_x_d : (x' < d <-> x < c) ∧ (x' = d <-> x = c) := by
  have h := hord_sig_triv ⟨0, by omega⟩ ⟨n + 2, by omega⟩
  simp_game_tuple at h; exact h
```

### 6.3 Why This Resolves ALL Grid Goals

With `sig_x_d` available, every grid goal in Case B can be closed:

| Goal | Chain |
|------|-------|
| x' vs b_resp | pivot: x'/x -> [sig_x_d] -> d/c -> [tau_d_b] -> b_resp/b_sp |
| x' vs a_init(k) | pivot: x'/x -> [sig_x_d] -> d/c -> [tau_d_sel(k)] -> a_init(k)/resp_tau(k) |
| x' vs p_n | pivot: x'/x -> [sig_x_d] -> d/c -> [hord_cd_en_pn] -> p_n/e_n |
| x' vs y' | sig_x_d composed with tau_d_y', or directly from forward game (hord_fwd_x_y) |
| a_init(k) vs p_n | pivot_rev: d/c -> [tau_d_sel(k)] and [hord_cd_en_pn] |
| b_resp vs p_n | pivot: d/c -> [tau_d_b] and [hord_cd_en_pn] |

The dead code at lines 1715-1812 proves all G0-G12 using exactly these chains (with `fwd_x_b` used as a shortcut for `hord_cd_en_pn`). The issue was purely that sigma was not instantiated, making `sig_x_d` unavailable.

### 6.4 Degenerate Case Handling

One subtlety: sigma instantiation requires a Round 2 point in [x,c]. The `h_pt_xc` field of SplitPointProps has two branches:
1. Non-degenerate: a point p in [x,c] exists -- use it.
2. Degenerate: x = c, x' = d, c and d are gaps.

In Case II, a_bwd(n) is a POINT. Since d <= a_bwd(n) and a_bwd(n) is in [d,y'], if x' = d then a_bwd(n) would need to be in [d,d] which forces a_bwd(n) = d. But a_bwd(n) is a point (Sum.inl p_n) while d being a gap means d = Sum.inr g. These are incompatible, so the degenerate branch is impossible in Case II. This is exactly the contradiction used at lines 1358-1364 in Case A.

## 7. Addressing Sorry #1 (Line 1569)

The sorry at line 1569 is the fallback in a `first | ... | sorry` chain within Case A's `same_order_type_grid` dispatch. This handles residual grid goals that don't match the earlier patterns.

Based on reading the dead code and the patterns that DO match, the remaining goals should be:
- Edge cases where `hab_eq` rewrites interact poorly with `try rw` ordering
- Goals that need both orientations of `hord_cd_en_pn` (some need `.symm`)

The fix: add additional pattern alternatives to the `first` chain, specifically:
```lean
| exact pivot_chain_order' (hd_le_sel ...) hd_le_pn
       (hc_le_rtau ...) hc_le_en (tau_d_sel ...) 
       ⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩
```
and the reverse. These are already present at lines 1553-1558 but may need additional variants for different index shapes.

## 8. Concrete Recommendation

### Priority: Resolve Case B sorry (line 1657) first

**Step 1**: Add sigma instantiation at the top of Case B (immediately after `push_neg at hbc`), mirroring the Case A pattern:

```lean
-- Instantiate sigma for boundary orderings (same pattern as Case A)
have hd_in_x'd : inClosedInterval x' d d := ⟨props.hx'd, le_refl d⟩
have ⟨p_xc, hp_xc⟩ : ∃ (p : M.carrier), inClosedInterval x c (extendPoint p) := by
  rcases props.h_pt_xc with ⟨p, hp⟩ | ⟨_, _, _, hgap_c⟩
  · exact ⟨p, hp⟩
  · -- Impossible: Case II requires a_bwd(n) to be a point, forcing d to be a point
    -- (via hp_n). But degenerate case requires d to be a gap. Contradiction.
    exfalso; obtain ⟨g_d, hg_d⟩ := (props.hcd_gp.2.mp hgap_c)
    have : d = extendPoint p_n := le_antisymm (hp_n ▸ h_no_split ⟨n, by omega⟩)
      (hp_n ▸ props.hd_le_an)  -- Actually d <= a_bwd(n) = p_n
    exact absurd (this.symm ▸ hg_d) (by simp [extendPoint])
obtain ⟨_resp_sig_triv, _, hwin_sig_triv⟩ :=
  props.sigma (fun _ : Fin n => d) (fun _ => hd_in_x'd)
obtain ⟨_, _, hcond_sig_triv⟩ := hwin_sig_triv p_xc hp_xc
obtain ⟨hord_sig_triv, _, _⟩ := hcond_sig_triv
have sig_x_d : (x' < d <-> x < c) ∧ (x' = d <-> x = c) := by
  have h := hord_sig_triv ⟨0, by omega⟩ ⟨n + 2, by omega⟩
  simp_game_tuple at h; exact h
```

**Step 2**: Replace the sorry with `same_order_type_grid` and dispatch all goals using the patterns from the dead code (G0-G12), now with `sig_x_d` available. The dead code at lines 1715-1812 provides the exact proof terms -- they just need to be updated to use the live code's variable names (`hord_fwd_x_en` instead of `fwd_x_b`, etc.) and the newly-available `sig_x_d`.

**Step 3**: For sorry #1 at line 1569, add additional `first` alternatives to handle remaining edge cases. These likely involve symmetric versions of existing patterns.

### Expected Outcome

- Sorry #1 (line 1569): 0 remaining goals after adding alternatives
- Sorry #2 (line 1657): Fully resolved by sigma instantiation + dead code revival
- Sorry #3 (line 2628): Separate blocker (Lemma 9), out of scope

### Risk Assessment

**Low risk**: The solution is standard EF game composition via pivot chaining. All required infrastructure (pivot_chain_order, simp_game_tuple, same_order_type_grid) exists and is sorry-free. The only new code needed is the sigma instantiation block (~20 lines) and the grid dispatch (~80 lines, mostly copied from the dead code with variable name updates).

The main risk is the degenerate case handling (h_pt_xc) in the sigma instantiation, but this is handled by the same contradiction used in Case A.

## 9. Summary of Findings

1. **Literature composition technique**: Pivot-chain composition through shared boundary points. Already implemented in the codebase via `pivot_chain_order`.

2. **Existing infrastructure**: Comprehensive -- `pivot_chain_order`, strategy restriction, round/rank monotonicity, game tactics. The composition machinery is complete.

3. **Ambient linear order approach**: Viable and is the standard approach. The codebase already uses it. The blocker is operational (missing sigma instantiation in Case B), not conceptual.

4. **b_en = p_n uniqueness**: NOT viable. EF games do not guarantee response uniqueness.

5. **Recommended path**: Instantiate sigma in Case B with a trivial selection to extract (x' < d <-> x < c), then dispatch all grid goals using the existing pivot_chain_order machinery. The dead code already contains the proof terms -- they need revival with updated variable names.

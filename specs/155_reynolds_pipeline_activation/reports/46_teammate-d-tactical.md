# Teammate D: Lean Proof State and Tactical Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Method**: MCP tool inspection (lean_hover_info, lean_goal, lean_verify, lean_local_search)

---

## 1. ExtendedCarrier and Interval Structures

### 1.1 ExtendedCarrier Definition (Defs.lean:335)

```lean
ExtendedCarrier {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
  (atomMap : Formula -> sig.preds) (r : Nat) : Type :=
  M.carrier + RDefinableGap M atomMap r
```

The extended carrier is the sum type: actual carrier points (M.carrier) plus r-definable gaps. It carries a linear order (extendedLinearOrder, Defs.lean:358) that interleaves points and gaps via cut membership.

### 1.2 inClosedInterval (CustomGame.lean:39)

```lean
inClosedInterval {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
  {atomMap : Formula -> sig.preds} {r : Nat}
  (x y e : ExtendedCarrier M atomMap r) : Prop :=
  x <= e /\ e <= y
```

Simple conjunction of two ordering constraints. The interval is over the FULL extended carrier, not restricted to carrier points. A `rank_embed_inClosedInterval` lemma bridges rank levels.

---

## 2. Until Semantics (Critical Finding)

### 2.1 sf_untl_truth_mu (CharacteristicFormula.lean:556)

Exact type from lean_hover_info:

```lean
sf_untl_truth_mu {sig} {M} {atomMap} {r} {t} (B A : StaviFormula) :
  stavi_temporal_truth_mu M atomMap r t (sf_untl B A) <->
    exists s : ExtendedCarrier M atomMap r,
      t < s /\ mu_holds s /\
        stavi_temporal_truth_mu M atomMap r s B /\
          forall (w : ExtendedCarrier M atomMap r),
            t < w -> w < s -> mu_holds w ->
              stavi_temporal_truth_mu M atomMap r w A
```

**CRITICAL**: The witness `s` quantifies over ALL elements of `ExtendedCarrier M atomMap r`. There is NO interval restriction. The witness can be anywhere in the extended carrier that is greater than `t`.

### 2.2 untl_extract_witness (CharacteristicFormula.lean:610)

```lean
untl_extract_witness {sig} {M} {atomMap} {r} {t}
  {B A : StaviFormula}
  (h : stavi_temporal_truth_mu M atomMap r t (sf_untl B A)) :
  exists z : ExtendedCarrier M atomMap r,
    t < z /\ mu_holds z /\
      stavi_temporal_truth_mu M atomMap r z B /\
        forall w, t < w -> w < z -> mu_holds w ->
          stavi_temporal_truth_mu M atomMap r w A
```

This is just `(sf_untl_truth_mu B A).mp h`. The witness `z` has:
- `t < z` (z above reference point)
- `mu_holds z` (z is an actual carrier point, i.e., IsPoint z)
- `B(z)` (z satisfies the target formula)
- `A` holds on all mu-points in `(t, z)`

**NO upper bound constraint on z.** No guarantee that z is in any interval.

### 2.3 temporal_truth_mu (.untl case) (TypeFormulas.lean:281-286)

```lean
| .untl phi psi =>
    exists s : ExtendedCarrier M atomMap r, t < s /\ mu_holds s /\
      temporal_truth_mu M atomMap r s phi /\
      forall u : ExtendedCarrier M atomMap r, t < u -> u < s -> mu_holds u ->
        temporal_truth_mu M atomMap r u psi
```

Same pattern: witness quantifies over ALL of ExtendedCarrier, not any sub-interval.

### 2.4 mu_holds (TypeFormulas.lean:233)

```lean
def mu_holds (e : ExtendedCarrier M atomMap r) : Prop := IsPoint e
```

Equivalent to `exists x : M.carrier, e = Sum.inl x`. Verified axiom-clean.

---

## 3. The e_n Construction in Current ghr93_case_II

### 3.1 Goal State at Step 3 (CaseAnalysis.lean:1257)

From lean_goal, the proof state before e_n construction has:
- `tau_r : ghr93_duplicator_wins N M atomMap n r d y' c y`
- `resp_tau : Fin n -> ExtendedCarrier M atomMap r`
- `hresp_tau_in : forall i, inClosedInterval c y (resp_tau i)` -- resp_tau in [c, y]
- `hwin_tau : forall b', inClosedInterval c y (extendPoint b') -> exists b, inClosedInterval d y' (extendPoint b) /\ ghr93_winning_condition ...`

### 3.2 Forward Game e_n (CaseAnalysis.lean:1268-1286)

The current code uses `props.h_d_compat_left` (a (1+3n+1)-round forward game):
1. Builds `a_pad_big` from resp_tau values plus c at last position
2. Plays h_d_compat_left with a_pad_big
3. Challenges with `p_n` (N-side carrier point) to get `e_n_pt`

The forward game guarantees **`he_n_pt_in : inClosedInterval x y (extendPoint e_n_pt)`** because `hwin_big` returns a point in [x, y]:
```lean
hwin_big :
  forall (b' : N.carrier),
    inClosedInterval x' y' (extendPoint b') ->
      exists b,
        inClosedInterval x y (extendPoint b) /\
          ghr93_winning_condition (1 + 3 * n + 1) ...
```

### 3.3 Goal State at Line 1286 (After e_n Definition)

From lean_goal, after `let e_n := extendPoint e_n_pt`:
- `e_n : ExtendedCarrier M atomMap r := extendPoint e_n_pt`
- `he_n_pt_in : inClosedInterval x y (extendPoint e_n_pt)` -- e_n IN [x, y]
- `hcond_big : ghr93_winning_condition ...` -- formula agreement from forward game

The goal remains the same existential: provide a'_resp in [x, y] with winning condition.

---

## 4. SplitPointProps (SplitPoint.lean:43)

### 4.1 Full Field List (from lean_hover_info)

| Field | Type | Purpose |
|-------|------|---------|
| `hc_interval` | `inClosedInterval x y c` | c in [x, y] |
| `hd_interval` | `inClosedInterval x' y' d` | d in [x', y'] |
| `hd_le_an` | `d <= a_bwd (n, ...)` | d below last selection |
| `hxc` | `x <= c` | sub-interval bound |
| `hcy` | `c <= y` | sub-interval bound |
| `hx'd` | `x' <= d` | sub-interval bound |
| `hdy'` | `d <= y'` | sub-interval bound |
| `h_pt_xc` | point or degenerate gap in [x, c] | sub-interval non-degeneracy |
| `h_pt_cy` | point or degenerate gap in [c, y] | sub-interval non-degeneracy |
| `hcd_form` | formula agreement c <-> d at rank r | split point agreement |
| `hcd_gp` | gap/point correspondence c <-> d | split point type match |
| `sigma` | `ghr93_duplicator_wins N M n (r+delta) (rank_embed d) (rank_embed x') (rank_embed x) (rank_embed c)` | left sub-interval game at r+delta |
| `tau` | `ghr93_duplicator_wins N M n (r+delta) (rank_embed d) (rank_embed y') (rank_embed c) (rank_embed y)` | right sub-interval game at r+delta |
| `h_fwd_n1` | `ghr93_duplicator_wins M N (n+1) r x y x' y'` | (n+1)-round forward game |
| `h_d_compat_left` | d-compatible (1+3n+1)-round forward game | forward game with d anchoring |

### 4.2 tau Field (lean_hover_info)

```lean
SplitPointProps.tau ... (self : SplitPointProps n delta x y x' y' c d a_bwd) :
  ghr93_duplicator_wins N M atomMap n (r + delta)
    (rank_embed ... d) (rank_embed ... y')
    (rank_embed ... c) (rank_embed ... y)
```

tau plays at rank `r + delta` on rank-embedded positions. Its winning condition gives formula agreement at depth `<= r + delta`.

### 4.3 Tau's Formula Budget

- tau at rank `r + delta` gives formula agreement at depth `<= r + delta`
- `U(B, A)` has depth `<= r + 2` (from `untl_type_depth`)
- With `hd : 2 <= delta`, we get `r + 2 <= r + delta`
- Therefore U(B, A) IS within tau's formula budget -- transfer is sound

---

## 5. The Until Witness Containment Problem (THE BLOCKER)

### 5.1 The Issue

The proposed GHR93 rewrite constructs e_n as follows:
1. Build `U(B, A)` where B = `x_t_formula N atomMap r (a_bwd n)`, A = `x_interval_formula N atomMap r ref_N (a_bwd n)`
2. Show `U(B, A)` holds at `ref_N` in N (via `untl_type_holds_at_witness`)
3. Transfer through tau to get `U(B, A)` holds at `ref_M` in M
4. Extract witness z from `untl_extract_witness`

The witness z satisfies `ref_M < z`, `mu_holds z`, `B(z)`. But the GOAL requires `inClosedInterval x y (a'_resp i)` for all i, meaning **e_n must be in [x, y]**.

Since ref_M is in [c, y] (as resp_tau values are in [c, y]), we have `z > c >= x`, so `x <= z`. But there is NO guarantee that `z <= y`. The Until semantics quantifies z over ALL of ExtendedCarrier, which extends beyond y.

### 5.2 Why the Current Code Avoids This

The current forward-game approach constructs e_n via the d-compatible forward game `h_d_compat_left`. This game's winning condition EXPLICITLY guarantees `inClosedInterval x y (extendPoint e_n_pt)` because the game is played on [x, y] and Duplicator's response must be in [x, y].

### 5.3 Mathematical Analysis of the Blocker

**Is the blocker real or can it be resolved?**

In GHR93, the argument implicitly assumes that the Until witness can be chosen within the relevant interval. This works in the paper because GHR93 operates on a dense linear order where tau maps [d, y'] isomorphically (in terms of type distribution) to [c, y]. If U(B, A) holds at ref_M, and the formula content of [c, y] mirrors [d, y'], then a witness MUST exist in [c, y].

However, in the Lean formalization:
1. The order may not be dense (ExtendedCarrier has gaps, but may still have discrete stretches)
2. `stavi_temporal_truth_mu` evaluates formulas on the ENTIRE extended carrier, not restricted to any interval
3. There is no existing lemma restricting an Until witness to a sub-interval

**Potential Resolution Path**: If `U(B, A)(ref_M)` holds and a point satisfying B exists in (ref_M, y] (which follows from tau's formula preservation -- tau maps p_n to some corresponding point), then by well-ordering (or by taking the first B-witness), that witness is <= the first B-witness which might still be > y. The key question: does formula transfer through tau guarantee a B-point in [c, y]?

**Answer**: YES, indirectly. tau's winning condition includes a Round 2 point challenge. If we challenge tau with a point in [c, y] that has matching rank_type to p_n, we get a point in [d, y'] with matching formula content. Conversely, for any formula of depth <= r+delta that holds at a position in [d, y'] (like p_n), the formula also holds at the corresponding position in [c, y] (the Round 2 response). So B = X_{p_n} holds at some point in [c, y].

But this reasoning doesn't give us the EXACT Until witness -- it gives us that B holds at SOME point in [c, y]. To get the Until semantics' full data (including the A condition on (ref_M, z)), we need the witness z itself to be in [c, y].

### 5.4 Possible Solutions

**Solution A (Hybrid)**: Keep the forward game for e_n EXISTENCE and interval containment, but use U(B, A) for formula PROPERTIES. This was recommended in report 45 Section 5.4.

**Solution B (Interval-restricted Until)**: Prove a new lemma:
```lean
theorem untl_witness_in_interval {t y : ExtendedCarrier M atomMap r}
  {B A : StaviFormula}
  (h : stavi_temporal_truth_mu M atomMap r t (sf_untl B A))
  (h_bound : exists z, t < z /\ z <= y /\ mu_holds z /\
    stavi_temporal_truth_mu M atomMap r z B) :
  exists z, t < z /\ z <= y /\ mu_holds z /\
    stavi_temporal_truth_mu M atomMap r z B /\
    forall w, t < w -> w < z -> mu_holds w ->
      stavi_temporal_truth_mu M atomMap r w A
```
This says: if U(B, A)(t) holds AND there is a B-point in (t, y], then we can choose a witness in (t, y]. This is NOT trivially true -- the first B-point in (t, y] might not be the same as the Until's canonical witness.

Actually, this IS true by taking z' = min{z in (t, y] : mu_holds z /\ B(z)}. Since U(B, A)(t) holds, ALL mu-points in (t, z_canonical) satisfy A. If z' <= z_canonical, then all mu-points in (t, z') also satisfy A (subset of (t, z_canonical)), so z' is a valid Until witness.

If z' > z_canonical (impossible since z_canonical > t and z' is the minimum B-point in (t, y] and z_canonical might be > y)... wait, z_canonical might be > y in which case z' exists in (t, y] only if the "bound" hypothesis holds.

**This lemma IS provable and solves the containment problem**, but requires:
1. Proving the existence of a B-point in [c, y] (from tau's formula transfer)
2. Proving the interval-restricted Until lemma (new infrastructure)

**Solution C (Direct construction without Until)**: Instead of using the Until formula at all, use tau's formula preservation directly to construct e_n. For each depth-<= r formula phi true at p_n in N, tau gives a point in [c, y] where phi holds in M. Since rank_type is determined by finitely many formulas (NormalForm is Fintype), and tau preserves all of them, there exists a point in [c, y] matching p_n's rank_type. Use Classical.choice to select such a point.

This approach avoids the Until formula entirely but still gets e_n with the right formula agreement. The A (interval type) information for Round 2 would then come from tau's formula preservation directly.

---

## 6. CharacteristicFormula.lean Axiom Audit

All key theorems verified axiom-clean via lean_verify:

| Theorem | Axioms |
|---------|--------|
| x_t_formula_exists | propext, Classical.choice, Quot.sound |
| untl_extract_witness | propext, Classical.choice, Quot.sound |
| untl_type_holds_at_witness | propext, Classical.choice, Quot.sound |
| sf_untl_truth_mu | propext, Classical.choice, Quot.sound |
| x_interval_formula_exists | propext, Classical.choice, Quot.sound |
| untl_type_depth | propext, Classical.choice, Quot.sound |
| formula_transfer_rank_embed | propext, Classical.choice, Quot.sound |

**No sorryAx in any of these.** CharacteristicFormula.lean has ZERO sorries. Its import of StaviCompleteness.lean is safe -- it only uses sorry-free lemmas (stavi_table_mu, nf_characteristic, doets_lemma_1_1, etc.).

**Key implication**: Adding `import CharacteristicFormula` to CaseAnalysis.lean would NOT introduce any sorryAx onto the bx_completeness critical path.

---

## 7. Search Results

### 7.1 lean_local_search

| Query | Results |
|-------|---------|
| `untl_interval` | (empty) |
| `interval_until` | (empty) |
| `witness_containment` | (empty) |
| `restrict` (project-scoped) | No relevant results |

No existing interval-restricted Until lemma exists in the codebase.

### 7.2 lean_leanfinder

Query: "Until formula witness restricted to closed interval in linear order"
Results: Only Mathlib hitting time theorems (irrelevant to this domain).

---

## 8. Current Sorry Inventory

### CaseAnalysis.lean (3295 lines, 3 sorries)

| Line | Context | Description |
|------|---------|-------------|
| 434 | Case I ordering | Complex index mapping between full-game and sub-game game_tuples |
| 1979 | (comment only) | Reference to Lemma 9 gap detection |
| 3146 | Cases III/IV body | Full winning condition assembly for gap case |

### Theorem6.lean (0 sorries in code)

The rank-varying version (`ghr93_forward_to_backward_rank_varying`) is complete and sorry-free. The only sorry reference is in a comment about Phase R3 which was resolved.

---

## 9. Recommended Path

### Primary Recommendation: Solution B (Interval-Restricted Until Lemma)

1. **Prove a B-point exists in [c, y]**: Use tau's Round 2 to show that a carrier point with rank_type matching p_n exists in [c, y]. This follows from tau's point challenge mechanism -- challenge with any carrier point in [c, y], extract formula agreement, show x_t_formula holds.

2. **Prove interval-restricted Until lemma** (~20-30 lines): If U(B,A)(t) holds and a B-point exists in (t, bound], the MINIMUM B-point in (t, bound] is a valid Until witness. Proof: take z_min = minimum B-point in (t, bound]. Since U(B,A)(t) holds with canonical witness z_canon, all mu-points in (t, z_canon) satisfy A. If z_min <= z_canon, then (t, z_min) is a subset of (t, z_canon), so A holds on (t, z_min). Since z_min is a B-point, we have a valid Until witness in (t, bound].

   **Complication**: ExtendedCarrier may not have a well-ordering compatible with the linear order. Need to use WellFounded or Classical.choice to select the minimum.

   **Simpler approach**: Instead of taking the minimum, just observe that z_min (any B-point in (t, bound]) works as an Until witness as long as (t, z_min) is a subset of (t, z_canon). This holds iff z_min <= z_canon. If z_min > z_canon, then z_canon itself is in (t, z_min) subset of (t, bound], and z_canon satisfies B. But z_canon might be > bound. Hmm.

   **Actually, the correct argument**: U(B,A)(t) says: exists z_canon > t with mu_holds z_canon, B(z_canon), A on (t, z_canon). If there also exists z_small in (t, bound] with B(z_small) and mu_holds z_small, then either:
   - z_small <= z_canon: Then (t, z_small) subset (t, z_canon), so A holds on (t, z_small). Done.
   - z_small > z_canon: Then z_canon is in (t, z_small) intersect (t, bound], and z_canon < z_small <= bound, so z_canon is in (t, bound]. But z_canon satisfies B and mu_holds. This contradicts z_small being chosen (z_canon is a closer B-point). If we simply CHOOSE the minimum B-point in (t, bound], this case cannot arise.

   **Final form**:
   ```lean
   theorem untl_witness_bounded (h_untl : ... sf_untl B A)
     (h_bound : exists z, t < z /\ z <= bound /\ mu_holds z /\ B(z)) :
     exists z, t < z /\ z <= bound /\ mu_holds z /\ B(z) /\
       forall w, t < w -> w < z -> mu_holds w -> A(w)
   ```

3. **Apply to Case II**: After transferring U(B,A) through tau and establishing a B-point in [c, y], apply the interval-restricted Until lemma with bound = y to get e_n in (ref_M, y] subset [c, y] subset [x, y].

### Fallback Recommendation: Solution A (Hybrid)

If the interval-restricted Until lemma proves difficult:
- Keep the forward game `h_d_compat_left` for e_n existence and containment
- Use U(B,A) transfer for sel_pn_ord and Round 2 simplification
- This hybrid avoids the containment problem entirely while still gaining the GHR93 ordering benefits

### Key Finding for Decision-Making

**CharacteristicFormula.lean can be safely imported** from CaseAnalysis.lean. The lean_verify audit confirms all relevant theorems (x_t_formula_exists, untl_extract_witness, untl_type_holds_at_witness, sf_untl_truth_mu, etc.) are axiom-clean with NO sorryAx. The StaviCompleteness.lean import in CharacteristicFormula.lean does NOT propagate sorries to the theorems used for Case II.

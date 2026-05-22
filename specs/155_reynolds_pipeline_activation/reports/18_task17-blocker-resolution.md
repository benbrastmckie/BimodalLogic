# Task 1.7 Blocker Resolution: IH h_fwd_r1 Sorry at Line 3836

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Resolve the architectural blocker at line 3836 of ExpressivenessGeneral.lean

---

## 1. Problem Statement

In `ghr93_forward_to_backward` (line 3755), the induction on `n` reverts ALL hypotheses
including `h_r1` (the rank `r+1` forward strategy) before inducting:

```lean
revert x y x' y' hxy hx'y' h_pt h_pt_M h h_r1
induction n with
```

This makes the IH `ih_gen` universally quantified over `h_r1`, so the IH has type:

```
ih_gen : ∀ (x₀ y₀ x₀' y₀'),
  x₀ ≤ y₀ → x₀' ≤ y₀' → ...
  → ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀'
  → ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 1)
      (rank_embed ... x₀) ... (rank_embed ... y₀')
  → ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀
```

The sorry at line 3836 fills the rank `r+1` argument for sub-interval endpoints:

```
sorry : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 1)
  (rank_embed ... x₀) (rank_embed ... y₀) (rank_embed ... x₀') (rank_embed ... y₀')
```

## 2. Why `h_r1` Must Be Reverted (Lean Dependency Constraint)

`h_r1`'s type depends on `x, y, x', y'` (via `rank_embed ... x`, etc.) and on `n` (via the round count `1 + 3 * n`). Lean's `revert` mechanism requires that when reverting a variable, ALL terms that depend on it must be reverted first. Since:

- `h_r1` depends on `x, y, x', y'` (endpoint variables)
- `h_r1` depends on `n` (induction variable)
- The endpoints MUST be reverted (so the IH is universal over sub-intervals)
- The induction MUST be on `n`

There is no way in the current formulation to revert endpoints without also reverting `h_r1`.

## 3. Why Sub-Interval Rank r+1 Cannot Be Derived from Full-Interval Rank r+1

Deriving rank `r+1` on sub-intervals `[x₀, y₀]` from rank `r+1` on the full interval `[x, y]` requires strategy restriction at rank `r+1`. The chain is:

1. Strategy restriction at rank `r+1` needs `h_d_consistent` at rank `r+1`
2. `d_consistency_left` at rank `r+1` needs `h_fwd_r1` at rank `r+2` (for Claim 1)
3. Claim 1 at rank `r+1` uses formula C' of depth `r+1`, requiring the game at rank `>= r+2`

Each level of strategy restriction escalates the rank requirement by 1. With `h_r1` at rank `r+1` only, there is no rank `r+2` strategy available. This creates an infinite tower:

```
Sub-interval at r+1 → needs d_consistency at r+1 → needs Claim 1 at r+2 → needs forward at r+2
Sub-interval at r+2 → needs d_consistency at r+2 → needs Claim 1 at r+3 → needs forward at r+3
...
```

## 4. How GHR93 Avoids the Tower

GHR93 Theorem 6 states (*)_n: **for all r**, if forward at rank `r+4n`, then backward at rank `r`.

Key differences from our formalization:

1. **Rank-varying forward game**: The forward game uses rank `r+4n`, providing `4n` levels of rank headroom above `r`.

2. **Universal rank quantification**: (*)_n quantifies over ALL ranks `r`. The IH at level `n` says: for all `r'`, forward at `r'+4n` implies backward at `r'`.

3. **Rank consumption**: At each induction level:
   - Claim 1 consumes 1 rank level (needs `r+1`)
   - Cases II-IV consume up to 3 additional levels (need `r+2`, `r+3`)
   - Total: 4 rank levels consumed per induction step
   - With `n+1` levels and `4(n+1)` rank headroom, the budget balances exactly

4. **Sub-interval strategies**: The IH at rank `r' = r+4` gives: forward at `(r+4)+4n = r+4+4n` implies backward at `r+4`. The sub-interval forward strategy is at rank `r+4(n+1) = r+4+4n` (same rank as needed). Backward at `r+4` then downgrades to backward at `r`.

5. **Rank downgrade**: In GHR93's framework, `M_r ⊆ M_{r'}` (cumulative), so a backward strategy at higher rank gives a backward strategy at lower rank (weaker winning condition). This is implicit in their framework.

## 5. Analysis of Proposed Solutions

### 5.1 Option B: Don't Revert h_r1

**Verdict: INFEASIBLE as stated.**

`h_r1` depends on both `n` (round count) and `x, y, x', y'` (endpoints). Both must be universalized for the induction. Lean's type system prevents keeping `h_r1` in scope while reverting its dependencies.

### 5.2 Option B' Variants (Factored Parameters)

Several variants were explored:

- **Separate round count**: Take `rounds_r1` as parameter independent of `n`. But `h_r1` still depends on endpoints.
- **Universal h_r1_fn**: Take `h_r1_univ : ∀ endpoints, forward rounds_r1 (r+1) ...`. This succeeds in keeping `h_r1_univ` out of the IH, BUT requires the caller to provide a rank `r+1` strategy on ALL intervals -- which cannot be derived from a single-interval `h_r1`.
- **provide_r1 function**: Similar to above; same issue with universality.

**Verdict: Partially feasible.** The core mechanism (factored round count + universal endpoint) works at the Lean level. The blocker is providing the universal `h_r1` from a single-interval hypothesis.

### 5.3 Option E: d_consistency Vacuous at IH Level

**Verdict: INCORRECT.** D_consistency is genuinely needed at each induction level (for strategy restriction to produce sigma/tau). The IH IS called on sub-intervals, and `ghr93_inductive_step` needs `h_fwd_r1` at each level.

The confusion arose from the observation that `ghr93_inductive_step`'s `ih` parameter only needs rank `r`. But the IH (`ih_gen` from induction) effectively provides the FULL `ghr93_forward_to_backward` behavior at the next level, which DOES need rank `r+1`.

### 5.4 Rank-Varying Approach (GHR93-Faithful)

**Verdict: CORRECT approach, requires new infrastructure.**

This is the mathematically correct solution, matching GHR93's actual proof. Required new lemmas:

#### 5.4.1 Rank Downgrade Lemma

```lean
theorem ghr93_duplicator_wins_rank_down {r r' : Nat} (hr : r ≤ r')
    (h : ghr93_duplicator_wins M N atomMap n r'
      (rank_embed hr x) (rank_embed hr y)
      (rank_embed hr x') (rank_embed hr y')) :
    ghr93_duplicator_wins M N atomMap n r x y x' y'
```

This is the most technically challenging new lemma. The proof requires:
- Embedding Spoiler's rank-`r` selections to rank `r'` (via `rank_embed`)
- Applying the rank-`r'` strategy
- Projecting Duplicator's rank-`r'` responses back to rank `r`

The projection issue: responses at rank `r'` may include rank-`r'` gaps (from `RDefinableGap M atomMap r'`) that don't correspond to rank-`r` gaps. However:

- For **point** responses: carrier elements exist at all ranks. No projection needed.
- For **gap** responses: the gap at rank `r'` has the same cut as the corresponding rank-`r` gap (by `rank_embed_gap_cut`). The response gap agrees on all rank-`r'` formulas with the selection gap. The rank-`r` formula agreement is a SUBSET of rank-`r'` agreement. The question is whether a rank-`r'` gap with the same cut as a rank-`r` gap IS a valid rank-`r` element.

Since `rank_embed_gap h g` preserves the cut (`rank_embed_gap_cut`), and the original gap `g` is `r`-definable, the embedded gap is `r'`-definable (with the same cut). Any rank-`r'` strategy response that has the SAME cut as `rank_embed_gap h g` should correspond to `g` at rank `r`. But the strategy might respond with a DIFFERENT cut.

**Key insight**: By `gap_point_agreement` in the winning condition, if Spoiler plays a gap, Duplicator responds with a gap. By `formula_agreement` at rank `r'` (which includes rank-`r` formulas), the response gap has the same rank-`r` formula type. The question is whether formula type uniquely determines the gap at rank `r`.

This depends on whether `nf_determines_stavi_truth` (which exists and is sorry-free) can be used to reconstruct the rank-`r` gap from the rank-`r'` response.

**Estimated effort**: 150-250 lines. The proof is non-trivial due to the gap projection issue.

#### 5.4.2 Rank-Varying Induction

```lean
theorem ghr93_forward_to_backward_rank_varying (n r : Nat)
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n)
           (rank_embed ... x) ... (rank_embed ... y')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y
```

The induction structure:
1. Quantify over `r` (universally) in the IH
2. At level `n+1`: forward at `r + 4(n+1) = (r+4) + 4n`
3. Strategy restriction at rank `r + 4(n+1)` (same rank, 1 round consumed)
4. IH at `r' = r+4`: forward at `(r+4) + 4n` gives backward at `r+4`
5. Rank downgrade: backward at `r+4` gives backward at `r`

**Estimated effort**: 80-120 lines for the induction structure.

## 6. Recommendation

### Primary Recommendation: Universal h_r1 with Decoupled Round Count

**This is the path of least resistance.** Instead of implementing the full rank-varying approach (which requires the difficult rank downgrade lemma), change the theorem signature to decouple `n` from `h_r1`:

```lean
private theorem ghr93_forward_to_backward_core {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n : Nat) (rounds_r1 r : Nat)
    {M N : OrderedMonadicStructure sig}
    (h_enough : 4 + 3 * n ≤ rounds_r1)
    (h_r1_univ : ∀ {x₁ y₁ : ExtendedCarrier M atomMap r}
                   {x₁' y₁' : ExtendedCarrier N atomMap r},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap rounds_r1 (r + 1)
                   (rank_embed (Nat.le_succ r) x₁)
                   (rank_embed (Nat.le_succ r) y₁)
                   (rank_embed (Nat.le_succ r) x₁')
                   (rank_embed (Nat.le_succ r) y₁'))
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  -- h_r1_univ does NOT depend on n or specific endpoints
  -- Revert only what depends on n and endpoints
  revert h_enough x y x' y' hxy hx'y' h_pt h_pt_M h
  induction n with
  | zero =>
    intro _ x y x' y' hxy hx'y' h_pt h_pt_M h
    -- Base case unchanged (same as current lines 3772-3820)
    ...
  | succ n ih_gen =>
    intro h_enough x y x' y' hxy hx'y' h_pt h_pt_M h
    -- ih_gen : (4 + 3 * n ≤ rounds_r1) → ∀ x₀..., forward (1+3n) r → backward n r
    -- ih_gen does NOT include h_r1_univ!
    have h_r1_here := ghr93_duplicator_wins_round_mono
      (show 4 + 3 * n ≤ rounds_r1 from h_enough)
      ((rank_embed_le (Nat.le_succ r) x y).mpr hxy)
      ((rank_embed_le (Nat.le_succ r) x' y').mpr hx'y')
      (h_r1_univ hxy hx'y')
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    exact ghr93_inductive_step atomMap n r hxy hx'y' h_pt h_pt_M
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd =>
        ih_gen (by omega) hle hle' hpt' (by
          obtain ⟨p_N, hp_N⟩ := hpt'
          obtain ⟨a'_play, _, hwin_play⟩ := hfwd (fun _ => x₀) (fun _ => ⟨le_refl x₀, hle⟩)
          obtain ⟨b_M, hb_M_in, _⟩ := hwin_play p_N hp_N
          exact ⟨b_M, hb_M_in⟩) hfwd)
      h h_r1_here
```

**Key properties**:
- `h_r1_univ` does NOT depend on `n` (it uses `rounds_r1`, a fixed parameter)
- `h_r1_univ` does NOT depend on specific endpoints (it's universally quantified)
- After `revert h_enough x y ... h` and `induction n`, `h_r1_univ` stays in scope
- The IH `ih_gen` is rank-`r`-only (no rank `r+1` obligation)
- `ghr93_inductive_step` gets `h_r1_here` from `h_r1_univ` + round_mono

### Providing h_r1_univ

The external caller must provide `h_r1_univ`. This requires showing that the rank `r+1` forward strategy holds for ALL sub-intervals, not just the original one.

**Two ways to provide this**:

1. **From EF game characterization**: If M and N are `(K, r+1)`-equivalent (Duplicator wins the K-round, rank-(r+1) game on any sub-interval), then `h_r1_univ` holds. This is the natural setting in the completeness proof.

2. **From a single-interval strategy + interval containment**: If `[x₁, y₁] ⊆ [x, y]` and we have a strategy on `[x, y]` at rank `r+1`, we can restrict to `[x₁, y₁]` via round monotonicity + containment (selections from the sub-interval are also in the full interval). The response might go outside the sub-interval, but the winning condition gives order constraints that keep it in.

   **Concretely**: Given `h_r1 : ghr93_duplicator_wins M N atomMap K (r+1) (embed x) (embed y) (embed x') (embed y')`, for any `[x₁, y₁] ⊆ [x, y]`, we have `[embed x₁, embed y₁] ⊆ [embed x, embed y]`. Spoiler selections from `[embed x₁, embed y₁]` are in `[embed x, embed y]`, so `h_r1` applies. The response is in `[embed x', embed y']`. By `same_order_type`, the response elements corresponding to `[embed x₁, embed y₁]` selections are in `[embed x₁', embed y₁']`.

   **This is essentially round monotonicity extended to sub-intervals.** The key step: show that a forward strategy on `[x, y]` restricts to `[x₁, y₁]` without consuming a round (unlike `ghr93_strategy_restrict_left/right` which consumes 1 round and needs d_consistency).

   A simpler restriction lemma is needed:

   ```lean
   theorem ghr93_duplicator_wins_sub_interval
       (hx₁ : x ≤ x₁) (hy₁ : y₁ ≤ y) (hx₁' : x' ≤ x₁') (hy₁' : y₁' ≤ y')
       (h : ghr93_duplicator_wins M N atomMap n r x y x' y') :
       ghr93_duplicator_wins M N atomMap n r x₁ y₁ x₁' y₁'
   ```

   This says: if Duplicator wins on a bigger interval, she wins on any sub-interval. This should be provable using the same strategy: Spoiler's selections from `[x₁, y₁]` are also in `[x, y]`, so apply the big-interval strategy. The responses are in `[x', y']`, and by order preservation (same_order_type), they're actually in `[x₁', y₁']`.

   **BUT**: This is NOT true in general! The responses are in `[x', y']`, not necessarily in `[x₁', y₁']`. The strategy might respond with elements outside the sub-interval. Only if there's an order-matching guarantee (all selections ≤ some boundary → all responses ≤ corresponding boundary) does this work.

   Actually, `same_order_type` gives: `tM(i) < tM(j) ↔ tN(i) < tN(j)`. If Spoiler's selections are all ≤ some value, the responses preserve this ordering relative to the boundary. But the boundary itself (from the game_tuple) includes x, y (the big interval endpoints), not x₁, y₁.

   So sub-interval restriction is NOT trivial.

### Alternative for Providing h_r1_univ

The simplest approach: **the caller provides h_r1_univ directly**. In the completeness proof context (where `ghr93_forward_to_backward` is ultimately called), the forward strategy comes from the decomposition formula, which naturally gives a strategy on any sub-interval. The completeness proof instantiates the forward strategy for the specific interval needed.

**If the caller cannot easily provide h_r1_univ**, an alternative is to prove `ghr93_duplicator_wins_sub_interval_r1` as a helper:

```lean
-- Forward strategy on bigger interval implies forward strategy on sub-interval
-- (with potentially reduced round count for the response confinement argument)
theorem ghr93_forward_to_backward_sub_interval_r1 ...
```

This would be a new lemma (~80-120 lines) but avoids the difficult rank downgrade machinery.

### Estimated Lines of Change

| Component | Lines | Status |
|-----------|-------|--------|
| `ghr93_forward_to_backward_core` (new helper) | 80-100 | New theorem with decoupled round count |
| `ghr93_forward_to_backward` (wrapper) | 10-15 | Calls core with appropriate `h_r1_univ` |
| `ghr93_inductive_step` | 0 | Unchanged |
| `obtain_split_point_props` | 0 | Unchanged |
| `d_consistency_left/right` | 0 | Unchanged (separate sorry, Task 1.5) |
| `ghr93_duplicator_wins_sub_interval` (if needed) | 80-120 | New helper for deriving h_r1_univ |
| **Total** | **170-235** | |

### Risk Assessment

- **Low risk**: The core mechanism (factored round count keeping h_r1_univ out of IH) is sound at the Lean type level.
- **Medium risk**: Providing `h_r1_univ` from a single-interval `h_r1` may require a sub-interval monotonicity lemma that is non-trivial.
- **Mitigation**: If sub-interval monotonicity is hard, change the outer theorem's signature to take `h_r1_univ` directly and push the obligation to the caller.

### Secondary Recommendation: GHR93 Rank-Varying (if primary fails)

If the universal `h_r1` approach proves inadequate (e.g., the caller cannot provide it), fall back to the rank-varying approach:

1. Prove `ghr93_duplicator_wins_rank_down` (~150-250 lines)
2. Reformulate `ghr93_forward_to_backward_rank_varying` with proper induction (~80-120 lines)
3. Derive the uniform-rank version as a corollary

Total: ~230-370 additional lines. Higher effort but mathematically complete.

## 7. Impact on Other Sorry Sites

Resolving Task 1.7 (line 3836 sorry) is INDEPENDENT of the other Phase 1 sorries:
- Lines 1170, 1249 (d_consistency interior): Depend on Claim 1 (Task 1.4), not on Task 1.7
- Lines 1564, 1581 (degenerate gaps): Phase 3, independent
- Line 2890 (Case II): Phase 1 Task 1.6, depends on tau transfer, not on Task 1.7
- Line 3877 (rank_varying): Depends on Task 1.7 resolution, as it would use the resolved theorem

The Task 1.7 sorry is on the CRITICAL PATH only for the rank_varying theorem (line 3877) and the downstream completeness chain.

## 8. Conclusion

The Task 1.7 blocker stems from a mismatch between the Lean induction structure (which universalizes h_r1 over sub-intervals) and the GHR93 proof structure (which provides rank headroom via the r+4n forward game rank). The recommended fix is to decouple the round count from `n` and take h_r1 as universally quantified over endpoints, keeping it out of the IH. This requires either a sub-interval monotonicity lemma or pushing the universal hypothesis requirement to the caller. Estimated effort: 170-235 lines.

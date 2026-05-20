# Case I Strategy: Closing `ghr93_case_I`

## 1. Current State

The sorry is at line 277 of `ExpressivenessGeneral.lean`. The goal after entering the proof is:

```
∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
  (∀ i, inClosedInterval x y (a'_resp i)) ∧
  ∀ (b_sp : M.carrier),
    inClosedInterval x y (extendPoint b_sp) →
    ∃ (b_resp : N.carrier),
      inClosedInterval x' y' (extendPoint b_resp) ∧
      ghr93_winning_condition (n + 1)
        (game_tuple x' y' a_bwd b_resp)
        (game_tuple x y a'_resp b_sp)
```

Available hypotheses:
- `props : SplitPointProps n x y x' y' c d a_bwd` (provides sigma, tau, interval bounds)
- `ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)`
- `h_split : ∃ i : Fin (n + 1), a_bwd i < d`

From `props`:
- `props.sigma : ghr93_duplicator_wins N M atomMap n r x' d x c`
- `props.tau : ghr93_duplicator_wins N M atomMap n r d y' c y`
- Interval bounds: `hxc, hcy, hx'd, hdy'`, etc.

## 2. Proof Strategy

### Step 1: Partition indices into L and R

Define the predicate `P : Fin (n+1) -> Prop := fun i => a_bwd i < d`.

```lean
let P : Fin (n + 1) → Prop := fun i => a_bwd i < d
haveI : DecidablePred P := fun i => inferInstance  -- LinearOrder gives Decidable
let L := Finset.univ.filter P        -- indices with a_bwd i < d
let R := Finset.univ.filter (fun i => ¬P i)  -- indices with d ≤ a_bwd i
```

### Step 2: Establish cardinality bounds

Key lemma: `Finset.card_filter_add_card_filter_not` gives
`L.card + R.card = Fintype.card (Fin (n+1)) = n + 1`.

From `h_split`: L is non-empty, so `L.card >= 1`.
From `props.hd_le_an`: `d ≤ a_bwd ⟨n, _⟩`, so index `⟨n, _⟩ ∈ R`, so `R.card >= 1`.

Therefore: `L.card ≤ n` and `R.card ≤ n`.

This is pure `omega` arithmetic once we have `L.card + R.card = n + 1`,
`1 ≤ L.card`, and `1 ≤ R.card`.

### Step 3: Extract sorted bijections

Use `Finset.orderEmbOfFin` to get order-preserving maps:
- `embL : Fin L.card ↪o Fin (n+1)` from `L.orderEmbOfFin rfl`
- `embR : Fin R.card ↪o Fin (n+1)` from `R.orderEmbOfFin rfl`

These give order-preserving enumerations of the L and R indices.

### Step 4: Construct sub-selections for sigma and tau

For sigma (left sub-interval, `[x', d]` / `[x, c]`):
- Selection: `a_L : Fin L.card → ExtendedCarrier N atomMap r`
  defined by `a_L i := a_bwd (embL i)`
- Each `a_L i` is in `[x', d]` because `a_L i < d` (by L membership)
  and `x' ≤ a_L i` (from `ha_bwd`).
- Need `L.card ≤ n` elements for an n-round game, apply via
  `ghr93_duplicator_wins_round_mono`.

For tau (right sub-interval, `[d, y']` / `[c, y]`):
- Selection: `a_R : Fin R.card → ExtendedCarrier N atomMap r`
  defined by `a_R i := a_bwd (embR i)`
- Each `a_R i` is in `[d, y']` because `d ≤ a_R i` (by R membership)
  and `a_R i ≤ y'` (from `ha_bwd`).
- Need `R.card ≤ n`, apply via `ghr93_duplicator_wins_round_mono`.

### Step 5: Apply sigma and tau to get responses

Apply round monotonicity + sigma:
```lean
have h_sigma_mono := ghr93_duplicator_wins_round_mono hL_le props.hx'd (le_refl d)
                       props.hxc (le_refl c) props.sigma
-- h_sigma_mono : ghr93_duplicator_wins N M atomMap L.card r x' d x c
obtain ⟨resp_L, hresp_L_interval, hwin_L⟩ := h_sigma_mono a_L ha_L
```

Similarly for tau:
```lean
have h_tau_mono := ghr93_duplicator_wins_round_mono hR_le (le_refl d) props.hdy'
                     (le_refl c) props.hcy props.tau
obtain ⟨resp_R, hresp_R_interval, hwin_R⟩ := h_tau_mono a_R ha_R
```

This gives:
- `resp_L : Fin L.card → ExtendedCarrier M atomMap r` with each in `[x, c]`
- `resp_R : Fin R.card → ExtendedCarrier M atomMap r` with each in `[c, y]`

### Step 6: Merge responses into a single function

Construct `a'_resp : Fin (n+1) → ExtendedCarrier M atomMap r` by:
```lean
let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
  if h : P i then
    resp_L ((L.orderIsoOfFin rfl).symm ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ i, h⟩⟩)
  else
    resp_R ((R.orderIsoOfFin rfl).symm ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ i, h⟩⟩)
```

Alternatively, a simpler approach avoids `orderIsoOfFin.symm`:

For each index `i : Fin (n+1)`:
- If `a_bwd i < d`: this index was processed by sigma. We need the
  position of `i` within L. Use `Finset.orderIsoOfFin` inverse.
- If `d ≤ a_bwd i`: processed by tau. Use position within R.

The interval containment of `a'_resp` follows because:
- L-responses are in `[x, c] ⊆ [x, y]`
- R-responses are in `[c, y] ⊆ [x, y]`

### Step 7: Round 2 handling

Given `b_sp : M.carrier` with `extendPoint b_sp ∈ [x, y]`:

Case split on whether `extendPoint b_sp ≤ c`:
- If `extendPoint b_sp ∈ [x, c]`: use sigma's Round 2 response.
  Apply `hwin_L b_sp` to get `b_resp_L` in `[x', d]`.
  Then `b_resp_L` is in `[x', y']` since `[x', d] ⊆ [x', y']`.
- If `extendPoint b_sp ∈ (c, y]`: use tau's Round 2 response.
  Apply `hwin_R b_sp` to get `b_resp_R` in `[d, y']`.

### Step 8: Verify winning condition

The winning condition has three components. Each decomposes over the
partition:

**same_order_type**: For indices `i, j` in `game_tuple`:
- If both correspond to L: order preserved by sigma's winning condition.
- If both correspond to R: order preserved by tau's winning condition.
- If one from L, one from R: L-responses are in `[x, c]`, R-responses
  are in `[c, y]`, so order is determined by the L/R partition, which
  matches the original ordering (`a_bwd i < d ≤ a_bwd j`).
- Boundary elements (x, y, b) are handled by the game_tuple structure.

**gap_point_agreement**: Same decomposition. L-elements matched by sigma,
R-elements by tau.

**formula_agreement**: Same decomposition. L-elements matched by sigma,
R-elements by tau.

## 3. Required Mathlib Infrastructure

### Already Available (verified via search)

| Lemma | Purpose |
|-------|---------|
| `Finset.card_filter_add_card_filter_not` | `\|L\| + \|R\| = n+1` |
| `Fintype.card_fin` | `Fintype.card (Fin (n+1)) = n+1` |
| `Finset.orderEmbOfFin` | Sorted bijection `Fin k ↪o α` |
| `Finset.orderIsoOfFin` | Order isomorphism `Fin k ≃o ↥s` |
| `Finset.mem_filter` | Membership in filtered Finset |
| `ghr93_duplicator_wins_round_mono` | Round monotonicity (in codebase) |

### Not Needed from Mathlib

The partition/merge is all done with `Finset.filter` on `Finset.univ`
(the universal Finset over `Fin (n+1)`) and basic `if-then-else`. No
exotic Mathlib infrastructure is required.

## 4. Estimated Complexity

| Sub-step | Lines | Difficulty |
|----------|-------|------------|
| Partition and cardinality bounds | 15-20 | Easy (omega) |
| Sub-selections and interval containment | 20-30 | Medium |
| Apply sigma/tau via round_mono | 10-15 | Easy (direct) |
| Merge responses | 15-25 | Medium (index juggling) |
| Round 2 case split | 15-25 | Medium |
| Winning condition: same_order_type | 30-50 | Hard (cross-partition cases) |
| Winning condition: gap_point + formula | 20-30 | Medium (mimic order proof) |
| **Total** | **125-195** | |

## 5. Blockers and Risks

### No Hidden Blockers

Case I is genuinely the simplest case. It does NOT require:
- Stavi connective construction (Cases III/IV only)
- Gap detection formulas (Cases III/IV only)
- Lemma 9 (Cases III/IV only)
- New axioms or sorry deferral

### Technical Risks

1. **game_tuple index arithmetic**: The `game_tuple` function uses a
   specific index convention (0=x, 1..n=selections, n+1=b, n+2=y).
   Cross-referencing the merged response with game_tuple indices
   requires careful bookkeeping. Mitigation: define helper lemmas
   that relate game_tuple indices to L/R membership.

2. **OrderIsoOfFin inverse**: Using `Finset.orderIsoOfFin.symm` to
   map from a `Fin (n+1)` index back to its position within L or R
   may produce complex terms. Mitigation: use `Finset.orderEmbOfFin`
   directly and prove the needed properties by `simp`.

3. **Cross-partition order**: Showing that L-responses (in [x,c]) are
   ordered correctly relative to R-responses (in [c,y]) requires
   proving that `resp_L j ≤ c ≤ resp_R k` for appropriate j, k.
   This follows from `hresp_L_interval` and `hresp_R_interval`.

4. **Round 2 winning condition merge**: After getting the Round 2
   response from sigma or tau, the winning condition is stated in
   terms of sub-interval game tuples. Need to show this implies the
   full-interval winning condition. This requires relating the sub-game
   game_tuple to the full game_tuple via the L/R partition. This is the
   most complex sub-step but follows a clear pattern.

### Simplification Opportunity

A cleaner approach avoids `Finset.orderIsoOfFin` entirely:

Since `ghr93_duplicator_wins` takes `Fin n → ExtendedCarrier` as input,
and we need to pass sub-selections of size `≤ n`, we can:

1. Pad the L-selection to exactly n elements (fill extras with `x'`).
2. Pad the R-selection to exactly n elements (fill extras with `d`).
3. Apply sigma and tau directly (no round_mono needed, since the
   padded selections have exactly n elements).
4. Extract only the meaningful responses.

This avoids cardinality juggling but requires tracking which response
positions are "real" vs "padding" -- likely more complex overall.

The `ghr93_duplicator_wins_round_mono` approach (Step 5 above) is
cleaner because it handles the size mismatch uniformly.

## 6. Recommended Implementation Order

1. **Partition infrastructure** (standalone helper lemma):
   ```lean
   private lemma partition_bound {n : Nat} (P : Fin (n+1) → Prop) [DecidablePred P]
       (hL : ∃ i, P i) (hR : ∃ i, ¬P i) :
       (Finset.univ.filter P).card ≤ n ∧
       (Finset.univ.filter (fun i => ¬P i)).card ≤ n
   ```

2. **Sub-selection containment** (show a_L elements are in [x',d], etc.)

3. **Apply sigma/tau + round_mono** (get resp_L, resp_R)

4. **Define merged response** (a'_resp via if-then-else)

5. **Round 2 handler** (case split on b_sp position)

6. **Winning condition verification** (the bulk of the work)

## 7. Conclusion

Case I is feasible with approximately 125-195 lines of Lean code. The
proof decomposes cleanly into partition, application of sub-strategies
via round monotonicity, merge, and verification. All required Mathlib
infrastructure exists. The main technical challenge is index arithmetic
in the winning condition verification, which is tedious but
straightforward. No blockers identified.

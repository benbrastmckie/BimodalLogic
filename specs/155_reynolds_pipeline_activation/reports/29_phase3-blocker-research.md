# Phase 3 Blocker Research Report

**Task**: 155 - reynolds_pipeline_activation
**Focus**: Phase 3 blockers (S8/S9/S10 cross-boundary ordering in `ghr93_case_II`)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (8524 lines)

## Executive Summary

Phase 3 is blocked on 4 of 5 remaining goals at the sorry site on line 7075 (Case A) and the full sorry at line 7175 (Case B). The root cause is that the forward game N-side response `a_N(n)` is NOT guaranteed to equal the split point `d`, so the ordering `(d < p_n <-> c < e_n)` cannot be derived. The fix is to add a new field to `SplitPointProps` that exports the d-compatibility property already proved internally by `obtain_split_point_props`. No new mathematical content is needed -- only architectural wiring.

## Finding 1: `obtain_split_point_props` Has NO Sorries

Contrary to what the task description suggests, `obtain_split_point_props` (lines 2485-3383) contains ZERO sorry statements. The infimum construction (d as inf(S_C), c as inf(S_C_M)) is fully proved, including all three sub-cases (carrier-point minimum, carrier-point GLB, gap infimum). The comments at lines 2481-2484 that say "sorry'd pending full proofs" are stale -- the proofs have been completed.

The `SplitPointProps` structure (lines 2404-2456) is fully populated:
- `hd_le_an`, `hxc`, `hcy`, `hx'd`, `hdy'` -- interval bounds (proved)
- `h_pt_xc`, `h_pt_cy` -- point witnesses (proved)
- `hcd_form`, `hcd_gp` -- formula and gap/point agreement (proved via K^-(neg D) argument)
- `sigma`, `tau` -- sub-interval backward strategies (proved via IH + strategy restriction)
- `h_fwd_n1` -- (n+1)-round forward strategy (proved via round_mono from h_fwd)

## Finding 2: The Root Cause Is `a_N(n) != d`

In `ghr93_case_II` (line 6805), the forward game is played with:
```
a_M = (resp_tau(0), ..., resp_tau(n-1), c)   -- M-side selections
```
The forward game produces N-side responses `a_N(i)` and round-2 carrier `e_n_pt` (M-side response to p_n).

The forward game ordering at positions (n+1, n+2) gives:
```
c < e_n  <->  a_N(n) < extendPoint p_n
```

But `a_N(n)` is the N-side game response to `a_M(n) = c`. It is NOT equal to `d` in general. The game only guarantees that `a_N(n)` has the same rank-r type as `c` (and therefore the same rank-r type as `d`), but two distinct points can share a rank-r type in a dense order.

The needed property `d < p_n <-> c < e_n` would follow immediately from `a_N(n) = d`.

## Finding 3: The d-Compatibility Property IS Already Proved

Inside `obtain_split_point_props`, the suffices block (line 3105) constructs `c = c_inf` with a property called "GHR93 Claim 1 interior" that GUARANTEES `a'_full(n) = d` when the last M-side selection is c. This property is proved via the K^-(neg D) argument at rank r+2 (lines 4967-5641).

The proof shows:
1. Play the rank r+2 game with `rank_embed(a_pad)` selections
2. The response `mr_resp` at the boundary position satisfies `mr_resp = rank_embed(d)`:
   - Direction 1 (`mr_resp <= rank_embed(d)`): K^-(neg D_M) pigeonhole argument
   - Direction 2 (`rank_embed(d) <= mr_resp`): cont_holds transfer via game Round 2
3. Project `mr_resp` back to rank r, getting `a'_full(n) = d`

This property feeds into `d_consistency_left` (line 1688) and then into `ghr93_strategy_restrict_left` to build sigma and tau. But it is NOT exported as a field of `SplitPointProps`.

## Finding 4: The Fix Is a New SplitPointProps Field

Add a field to `SplitPointProps` that exports the d-compatibility property:

```lean
h_fwd_n1_d_compat : ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a_pad i)) →
    a_pad ⟨n, by omega⟩ = c →
    ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a'_full i)) ∧
      (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
      a'_full ⟨n, by omega⟩ = d
```

**Filling this field**: Apply `d_consistency_left` with `n+1` rounds at rank r and `n+1` rounds at rank r+2. The Claim 1 interior property for `(n+1)` rounds is provable using the same K^-(neg D) argument as for `(1+3*n+1)` rounds -- the proof structure is identical, only the game_tuple index arithmetic changes. The required rounds are available: `h_fwd` provides `4+3*n >= n+1` and `h_fwd_r1` provides `4+3*n >= n+1` at rank r+2.

**Impact on ghr93_case_II**: Replace the current line 6854 (`obtain ... := props.h_fwd_n1 a_M ha_M`) with:
```lean
obtain ⟨a_N, ha_N, hwin_fwd, ha_N_n_eq_d⟩ := props.h_fwd_n1_d_compat a_M ha_M (by simp [a_M])
```

Then the forward game ordering at (n+1, n+2) gives:
```
c < e_n  <->  d < extendPoint p_n
```
And this closes ALL remaining cross-boundary ordering goals.

## Finding 5: Exact Sorry Inventory

Seven sorry sites remain in ExpressivenessGeneral.lean:

| Line | Location | Description | Status |
|------|----------|-------------|--------|
| 5147 | `h_mr_resp_le_d` (left interior) | Multi-round K^-(neg D_M) argument | S4 — mechanical copy (~350 lines) |
| 5485 | `h_mr_resp_le_d` (right interior) | Multi-round K^-(neg D_M) argument | S7-right — mechanical copy (~350 lines) |
| 7075 | `ghr93_case_II` Case A | 5 cross-boundary ordering goals | S8 — 2 closeable now, 3 need d-compat field |
| 7175 | `ghr93_case_II` Case B | Full same_order_type | S9 — needs sigma extraction + d-compat field |
| 7228 | Dead code in Case B | Inside sorry block | Subsumed by line 7175 |
| 8158 | `ghr93_cases_III_IV` | Lemma 9 gap detection | S11 — independent |
| 8520 | `ghr93_forward_to_backward_rank_varying` | Lemma 10 strategy restriction | S12 — independent |

## Finding 6: Goal States at Line 7075

The sorry at line 7075 has 5 remaining goals from `same_order_type_grid`:

1. `(extendPoint b_resp < x' <-> extendPoint b_sp < x)` -- **CLOSEABLE** (both False: `b_resp >= x'`, `b_sp >= x`)
2. `(extendPoint b_resp < extendPoint p_n <-> extendPoint b_sp < e_n)` -- **NEEDS d-compat**
3. `(y' < a_bwd(j-1) <-> y < resp_tau(j-1))` -- **CLOSEABLE** (both False: `a_bwd(j-1) <= y'`, `resp_tau(j-1) <= y`)
4. `(extendPoint p_n < extendPoint b_resp <-> e_n < extendPoint b_sp)` -- **NEEDS d-compat**
5. `(a_bwd(i-1) < extendPoint p_n <-> resp_tau(i-1) < e_n)` where `i-1 < n, j-1 = n` -- **NEEDS d-compat**
6. `(extendPoint p_n < a_bwd(j-1) <-> e_n < resp_tau(j-1))` where `i-1 = n, j-1 < n` -- **NEEDS d-compat**

Goals 1 and 3 can be closed immediately with `absurd (lt_of_lt_of_le h bound) (lt_irrefl _)` patterns. Goals 2, 4, 5, 6 all require `(d < p_n <-> c < e_n)`.

## Finding 7: S4 and S7-right Are Independent Mechanical Work

Lines 5147 and 5485 are the multi-round K^-(neg D_M) argument for `h_mr_resp_le_d`. These are ~350-line copies of the 1-round version (proved at lines 3562-3937) with game_tuple indices adapted for multi-round play (`2+3n, 3+3n, 4+3n` instead of `1, 2, 3`). They do NOT depend on the d-compat field and can be closed independently. They are needed for S4 and S7-right.

## Recommended Implementation Path

### Step 1: Add d-compat field to SplitPointProps (lines 2404-2456)
Add `h_fwd_n1_d_compat` field. Estimated: ~30 lines of field definition.

### Step 2: Prove Claim 1 interior for (n+1) rounds (new code near line 4967)
Copy the existing `h_interior_left` proof (lines 4970-5641) and adapt for `(n+1)` rounds instead of `(1+3*n+1)`. The proof is structurally identical -- only game_tuple index arithmetic changes. Alternatively, parameterize the existing proof.

**Critical dependency**: The existing `h_interior_left` at line 4970 has TWO sorries at lines 5147 and 5485 (the `h_mr_resp_le_d` pigeonhole argument). These must be closed FIRST, or alternatively, a separate `(n+1)`-round version must be proved that avoids these sorries.

Wait -- this changes the analysis. Let me re-check.

### Step 2 (revised): Check if h_interior_left sorries block the d-compat field

The sorries at 5147 and 5485 are inside `h_interior_left` (the Claim 1 interior proof for `(1+3*n+1)` rounds). If we need a NEW Claim 1 interior proof for `(n+1)` rounds, it would have the SAME structure and the SAME sorries.

However, `d_consistency_left` (line 1688) does NOT use the interior proof when `d` is at a boundary (`x' = d` or `d = y'`). It only delegates to `h_interior_d` for the INTERIOR case (`x' != d` and `d != y'`).

So the d-compat field CAN be filled with a sorry-free proof for the boundary cases, and the interior case would need the Claim 1 proof.

Actually, re-reading `d_consistency_left` more carefully (lines 1733-1774): it handles three cases:
- `x' = d`: Uses the regular forward game, derives `a'_full(n) = d` from boundary agreement. NO SORRY.
- `d = y'`: Uses the regular forward game, derives `a'_full(n) = d` from boundary agreement. NO SORRY.
- Interior (`x' != d` and `d != y'`): Delegates to `h_interior_d`.

For `ghr93_case_II`, the case `d = y'` implies `a_bwd(n) = d = y'` which makes `a_bwd(n) = y'`. Since `a_bwd(n)` is a point and `a_bwd(n) <= y'`, this means `y' = extendPoint p_n`. In this case the cross-boundary goals `(d < p_n <-> c < e_n)` become `(y' < extendPoint p_n <-> ...)` which are trivially False since `y' = extendPoint p_n`.

Similarly, `x' = d` makes `d = x'` which combined with `d <= a_bwd(n) = extendPoint p_n` and `a_bwd(n) in [x', y']` gives `x' <= extendPoint p_n`, and `d < p_n` becomes `x' < extendPoint p_n`.

So the boundary cases may already provide enough structure. But the interior case (where sorries exist) is the common case and must be resolved.

### Revised Step 2: Close S4/S7-right first, then add d-compat field

The correct dependency order is:
1. Close S4 (line 5147) and S7-right (line 5485) -- mechanical K^-(neg D_M) argument
2. This makes `h_interior_left` sorry-free
3. Add Claim 1 interior for `(n+1)` rounds (copying the now sorry-free h_interior_left)
4. Add `h_fwd_n1_d_compat` field using `d_consistency_left` with the new Claim 1 interior
5. Close S8/S9/S10 using the d-compat field

### Step 3: Close goals 1 and 3 at line 7075 (immediate, no dependency)
These are both-False goals. ~20 lines.

### Step 4: Close remaining goals at line 7075 and line 7175
Use `props.h_fwd_n1_d_compat` to get `a_N(n) = d`, then derive `d < p_n <-> c < e_n`.

## Effort Estimate

| Item | Lines | Dependency |
|------|-------|-----------|
| Close S4 (line 5147) | ~350 | None |
| Close S7-right (line 5485) | ~350 | None |
| Claim 1 interior for (n+1) rounds | ~500 | S4 + S7-right |
| Add d-compat field + fill it | ~50 | Claim 1 interior |
| Close S8 goals 1,3 (immediate) | ~20 | None |
| Close S8 goals 2,4,5,6 | ~80 | d-compat field |
| Close S9/S10 (Case B) | ~100 | d-compat field |
| Total | ~1450 | S4/S7-right -> Claim 1 -> d-compat -> S8/S9/S10 |

## Alternative: Factor Out the K^-(neg D_M) Argument

Instead of copying the 350-line proof twice (S4 and S7-right), consider factoring it into a shared lemma parameterized by the game position. This would save ~400 lines and make the Claim 1 interior for `(n+1)` rounds trivial (just instantiate the shared lemma with different index arithmetic).

Shared lemma signature:
```lean
private theorem k_neg_d_m_argument {n_sel : Nat} ...
    (h_sel_pos : Nat) -- position of c_inf in game_tuple
    (hc_pos : h_sel_pos < n_sel)
    ... : mr_resp ≤ rank_embed d
```

This is the recommended approach as it also simplifies maintenance.

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|-----------|
| S4/S7-right take longer than estimated | M | L | Mechanical copy; well-understood proof structure |
| Claim 1 interior for (n+1) rounds has subtle index issues | M | M | Test with lean_multi_attempt before committing |
| d-compat field changes SplitPointProps, breaking downstream | M | L | Only adds a new field; existing fields unchanged |
| Factoring K^-(neg D_M) is harder than copying | L | M | Fall back to copy-paste if factoring is blocked |

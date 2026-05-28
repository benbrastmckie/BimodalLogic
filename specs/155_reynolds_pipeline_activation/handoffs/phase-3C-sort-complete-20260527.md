# Phase 3C Handoff: 3C-Sort Complete, 3C-UBA Analysis

**Date**: 2026-05-27
**Session**: sess_1779931340_a5cbb4
**Phase**: 3C-Sort [COMPLETED], 3C-UBA [IN PROGRESS]
**Status**: Phase 3C-Sort implemented and verified. Phase 3C-UBA blocked on modified-response approach.

## What Was Done (Phase 3C-Sort)

### Sorting Wrapper at ghr93_inductive_step

Added sorting preprocessing at `ghr93_inductive_step` (CaseAnalysis.lean):

1. After `intro a_bwd ha_bwd`, compute `sigma := Tuple.sort a_bwd`
2. Define `a_sorted := a_bwd . sigma` with `Monotone a_sorted` (from `Tuple.monotone_sort`)
3. Use `suffices` to reduce to sorted case, then transfer back via `ghr93_winning_condition_perm` with `sigma.symm`
4. The `h_unsort_N : a_sorted . sigma.symm = a_bwd` identity closes the goal

### h_mono Threading

Added `(h_mono : Monotone a_bwd)` parameter to:
- `ghr93_case_II` (line ~1221)
- `ghr93_cases_II_III_IV` (line ~4315)

Threaded from `ghr93_inductive_step` through the call chain. Build passes.

### Key Properties Now Available Inside ghr93_case_II

```lean
h_mono : Monotone a_bwd  -- a_bwd is sorted (monotone non-decreasing)

-- From h_mono:
h_le : a_init k <= extendPoint p_n  -- for all k < n
  -- Proof: h_mono (Fin.mk_le_mk.mpr (by omega))

-- From tau_sel_sel + h_mono:
h_tau_mono : Monotone resp_tau  -- tau preserves monotonicity
  -- Proof: from a_init monotone + tau_sel_sel biconditionals
```

## Phase 3C-UBA Analysis

### Why same_side Remains Unprovable (Even With Sorting)

The `same_side` goal at lines 1593 and 1973:
```
(a'_big k < extendPoint p_n <-> a_init k < extendPoint p_n) /\
(a'_big k = extendPoint p_n <-> a_init k = extendPoint p_n)
```

With sorting: `a_init k <= p_n` (from h_mono). But `a'_big k` is Duplicator's N-side response in the big forward game. It agrees with `a_init k` on rank-r formulas (hform_abig_ainit), but rank-r formula agreement does NOT determine ordering relative to p_n. Two points with identical rank-r types can be at different positions in the linear order.

The U(B,A) formula `std_untl (char_k nf_pn) (.base Formula.top)` (depth <= r) detects "exists B-point above" but does NOT distinguish "below p_n" from "above p_n" (other B-points may exist above both).

### The Equality Case Problem

With `Monotone` (not `StrictMono`), duplicates are possible: `a_init(k) = extendPoint p_n` for some k < n.

When a_init(k) = p_n and the existing M-response is resp_tau(k):
- `a_init(k) < p_n` is FALSE
- `resp_tau(k) < e_n` may be TRUE (e_n from forward game, resp_tau from tau)
- sel_pn_ord biconditional: FALSE <-> TRUE = FALSE

This means the CURRENT response function `a'_resp(k) = resp_tau(k) for k < n, e_n for k = n` CANNOT satisfy the winning condition when Spoiler plays duplicates.

### Proposed Resolution: Modified Response Function

Replace:
```lean
let a'_resp := fun i => if h : i.val < n then resp_tau ⟨i.val, h⟩ else e_n
```

With:
```lean
let a'_resp := fun i =>
  if h : i.val < n then
    if a_init ⟨i.val, h⟩ < extendPoint p_n then resp_tau ⟨i.val, h⟩
    else e_n  -- duplicate: respond same as position n
  else e_n
```

**Equality case**: When a_init(k) = p_n, respond with e_n. Then:
- sel_pn_ord: `False <-> False` (both a'_resp(k) = e_n, so not <) and `True <-> True` (both =). Holds.
- Formula agreement: from hform_en_an (e_n agrees with p_n = a_init(k) on rank-r formulas).
- Gap/point: both e_n and p_n are points (Sum.inl).

**Strict case**: When a_init(k) < p_n, respond with resp_tau(k). Then:
- sel_pn_ord needs: `True <-> (resp_tau(k) < e_n)`. So need `resp_tau(k) < e_n`.
- This requires e_n > resp_tau(k) for ALL k where a_init(k) < p_n.
- With Monotone resp_tau: resp_tau(k) <= resp_tau(k_max) where k_max is the largest index with a_init(k_max) < p_n.
- NEED: e_n > resp_tau(k_max).

### How to Get e_n > resp_tau(k_max)

The EXISTING e_n from the forward game does NOT guarantee this. Two approaches:

**Approach A**: Replace e_n with U(B,A) witness.
- phi = std_untl (char_k nf_pn) sf_top, depth <= r
- phi holds at a_init(k_max) in N (witnessed by p_n)
- Transfer via tau: phi holds at resp_tau(k_max) in M
- Extract witness s > resp_tau(k_max) with char_k(nf_pn)(s)
- Set e_n = extendPoint s
- PROBLEM: This e_n only has char_k_depth formula agreement with p_n, NOT full rank-r agreement. The winning condition needs rank-r agreement.

**Approach B**: Keep existing e_n, prove resp_tau(k) < e_n for strict case from tau + forward game properties.
- This requires showing the fan structure resolves to a chain. Still unprovable without additional structural assumptions.

**Approach C (Recommended)**: Use BOTH forward game and U(B,A).
1. Keep the existing forward-game e_n (provides rank-r formula agreement with p_n, interval properties, etc.)
2. Use U(B,A) to construct e_n_uba > resp_tau(k_max) with char_k(nf_pn) agreement
3. Show e_n = e_n_uba (or e_n >= e_n_uba) using the uniqueness of the rank-r type and the forward game ordering

This is speculative. The key open question: can the forward-game e_n be shown to be >= resp_tau(k_max) using a combination of the forward game ordering and U(B,A) transfer?

### Alternative: Restructure As Two Separate Games

Instead of one (n+1)-round game with mixed tau/forward-game responses, play:
1. An n-round backward game (tau) for positions where a_init(k) < p_n
2. A separate 1-round game for the p_n/e_n pair

This avoids sel_pn_ord entirely but requires proving the composed game's winning condition from the two sub-games. This is essentially Proposition 12.8.18 (full composition), which is Phase 6E of the plan.

## Immediate Next Action

The successor should focus on ONE of:

**Option 1 (Modified response + U(B,A) e_n)**:
1. Implement the modified response function (e_n for equal, resp_tau for strict)
2. Construct e_n from U(B,A) (std_untl transfer through tau)
3. Prove e_n has rank-r formula agreement with p_n
4. Establish e_n > resp_tau(k) for strict case
5. Rebuild the winning condition assembly

**Option 2 (Defer to Phase 6E composition)**:
1. Implement Proposition 12.8.18 (Phase 6E)
2. Use full m-tuple composition to avoid sel_pn_ord entirely
3. This is the mathematically cleaner approach but requires ~500 additional lines

**Option 3 (Degenerate case elimination)**:
1. Prove that in the generic case (no duplicates), sel_pn_ord holds
2. Handle duplicates separately by reducing to a lower-round game
3. This is surgical but requires careful case analysis

## Files Modified

- `CaseAnalysis.lean`: Sorting wrapper (lines ~4378-4425), h_mono threading (lines ~1221, ~4315, ~4325, ~4424)

## Build State

`lake build` passes. Same sorry count as before (3 in Case II: lines 1594, 1974, 2189; plus Case I line 427, Cases III/IV line 4275).

## Key Decision Points for Successor

1. Is the modified response function approach viable? (Main question: does the winning condition assembly survive the change?)
2. Should e_n be replaced with U(B,A) witness or kept from forward game?
3. Is the equality case handleable without full composition (Phase 6E)?

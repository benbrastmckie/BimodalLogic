# Phase 3 Handoff: Sorry Closure Attempt (CaseAnalysis.lean lines 1594/1866)

## Status: BLOCKED

## What Was Attempted

Attempted to close the 2 remaining sorry sites (lines 1594 and 1866) in Case A and Case B of `ghr93_case_II` in `CaseAnalysis.lean`.

### Approach 1: `refine` destructuring with `<;> first`

Replaced the `| sorry)` at line 1594 with:
```lean
| (refine ⟨⟨fun h => ?_, fun h => ?_⟩, ⟨fun h => ?_, fun h => ?_⟩⟩ <;>
   first
   | exact absurd (lt_of_lt_of_le h ...) (lt_irrefl _)  -- y' < sel impossible
   | (have := (tau_sel_y ...).2.mpr h.symm; convert ...)  -- y' = sel
   | (have key := (pivot_chain_order' ...).1.mp; ...)     -- sel < p_n
   | ...)
```

**Result**: This successfully closes the y-vs-sel goals (1 of 3 goal types), but the sel-vs-p_n and p_n-vs-sel goals CANNOT be closed by `pivot_chain_order'` because the arguments don't align.

The fatal issue: adding ~20 alternatives to `first | ...` for 3 goal types x 4 Iff directions = 12 subgoals generates 12 * ~20 = 240+ error messages from backtracking, exceeding Lean's maxErrors=100 cap and aborting the build.

### Approach 2: `simp only [hab_eq]` normalization

Tried to normalize `a_bwd ⟨k, _⟩` to `extendPoint p_n` using `simp only [hab_eq _ _ (by assumption)]`. This works when `¬(k < n)` is in context with a name accessible to `assumption`, but fails for some goals where the hypothesis names are inaccessible (`h✝`).

### Approach 3: `multi_attempt` with inaccessible names

`lean_multi_attempt` can reference `i✝`/`j✝` and `hab_eq _ (by omega) (by assumption)` to rewrite. This reports `goals: []` but has diagnostic errors, and the approach doesn't translate to actual source code because inaccessible names can't be referenced.

## Mathematical Analysis: sel-vs-p_n Ordering Gap

The sel-vs-p_n goals require proving:
```
(a_init k < extendPoint p_n ↔ resp_tau k < e_n)
```

Available facts:
- `hd_le_sel k : d ≤ a_init k`
- `hd_le_pn : d ≤ extendPoint p_n`
- `hc_le_rtau k : c ≤ resp_tau k`
- `hc_le_en : c ≤ e_n`
- `tau_d_sel k : (d < a_init k ↔ c < resp_tau k)`
- `hord_cd_en_pn : (c < e_n ↔ d < extendPoint p_n)`

For `pivot_chain_order'(a ≤ p ≤ b)` with pivot d:
- d ≤ a_init k and d ≤ extendPoint p_n — both on the SAME side of d
- No chain d ≤ a_init k ≤ extendPoint p_n (or reverse) is available
- Cannot construct a pivot chain to derive the ordering

For `pivot_chain_order_rev'(b ≤ p ≤ a)` with pivot d:
- Same issue: need a_init k ≤ d, but have d ≤ a_init k (wrong direction)

**Conclusion**: The sel-vs-p_n ordering IS mathematically true (both orderings are preserved by the game) but requires a DIFFERENT proof approach than pivot-chain. It needs either:
1. A direct game argument providing `(a_init k < extendPoint p_n ↔ resp_tau k < e_n)`
2. An `sel_pn_ord` field added to `SplitPointProps`
3. A modified `hwin_tau` game that includes p_n/e_n as an additional position

## Recommended Fix: Refactor `same_order_type_grid`

The root cause of the maxErrors problem is the anonymous hypotheses from `split_ifs`. Create a new macro variant:

```lean
macro "same_order_type_grid_named" : tactic =>
  `(tactic| (intro i j; simp only [game_tuple]; split_ifs <;> rename_i hi hj))
```

With named `hi`/`hj`, you can:
1. `by_cases` on whether the index is in the sel range
2. `rw [hab_eq _ _ hj]` targeting the correct `a_bwd`
3. Avoid the `first | ...` combinatorial explosion

However, this doesn't solve the mathematical gap — even with named indices, the sel-vs-p_n ordering proof still requires new infrastructure.

## Build Status

Build passes cleanly (996 jobs) with sorry fallbacks in place.

## Remaining Sorry Sites

- Line 1594: Case A sorry (3 blocked goals: y-vs-sel closable, sel-vs-p_n blocked, p_n-vs-sel blocked)
- Line 1866: Case B sorry (7 blocked goals: same patterns plus additional b/p_n cross-boundary)
- Line 2837: Lemma 9 sorry (Phase 5, separate)

## Next Action: Research new infrastructure for sel_pn_ord

The recommended approach is option 2 from the plan's Rollback/Contingency:
> Modify `hwin_tau` to return (n+1)-round game: Include p_n/e_n as the (n+1)-th position in the tau game, providing all pairwise orderings including sel-vs-p_n.

This requires changes in `SplitPoint.lean` to modify `obtain_split_point_props` to provide a tau game that includes the (n+1)-th position p_n alongside the first n positions. The tau game currently covers positions `a_init(0..n-1)` but NOT `extendPoint p_n`.

## Session

Session: sess_1779830567_4cbdda

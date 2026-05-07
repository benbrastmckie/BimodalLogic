# Phase 4 Handoff: Walk Implementation Progress

## Status: PARTIAL (walk structure complete, 2 sorry stubs remain)

## Session: sess_1778114001_749277

## Changes Made

### 1. Defined C5ForwardWalkResult structure (line ~645)

New structure bundling all fields needed for the walk result:
- `val`, `dom_sub`, `c0`, `c2'`, `f_agrees`, `g_agrees` (chronicle extension)
- `witness`, `witness_mem`, `witness_gt`, `witness_event`, `witness_guard` (C5 witness with guard)
- `g_sub_f_insert`, `g_sub_g_new`, `dom_new_unique` (omega chain invariants)
- `new_point_after` -- KEY ADDITION: all new domain points are strictly after `start`. This enables the guard composition proof in the recursive case.

### 2. Defined c5_forward_walk recursive function (line ~683)

Private noncomputable def with `termination_by (dom.filter (> pt)).card`.

**Base case** (pt = max_old): Uses `lemma_2_4_with_guard` to insert witness beyond max_old. Fully implemented and compiles.

**Recursive case, condition (i)** (conj in f(x') AND xi in g(pt, x')): 
- Derives h_no_wit at x' from h_no_wit at pt (guard composition argument)
- Recurses: `c5_forward_walk chi ... x' ...`
- Composes guard: at (pt, x') from condition (i), at pairs after x' from recursive result
- Uses `new_point_after` to prove no new point falls between pt and x'
- Fully implemented, compiles with the termination sorry

**Recursive case, not condition (i)**: SORRY stub (line 959). Needs splitting at (pt, x') using lemma_2_7/2_8/2_6. The code is already written in a block comment right below -- it just needs to be uncommented and adapted to use `pt` instead of `start` and fix the `simp`/`rcases` issues with `val` vs `chi'`.

### 3. Replaced Walk A + Walk B code in eliminate_potential_counterexample (line ~1389)

The entire condition (i) branch (previously ~415 lines of Walk A + Walk B code) is now a ~20 line call to `c5_forward_walk` that converts the result to `EliminationResult`. Net deletion: ~395 lines from the condition (i) branch.

### 4. Build Status

- 3 forward C5 errors: FIXED (replaced by walk helper call)
- 6 backward C5 errors: remain (pre-existing, Phase 5 task)
- 2 sorry in walk function: termination proof + not-condition(i) splitting

## Remaining Sorry Sites

### Sorry 1: Termination proof (line 1171)

```
decreasing_by all_goals sorry
```

**Root cause**: Lean 4's `termination_by` renames function parameters when elaborating the `decreasing_by` clause. The parameter `pt` gets renamed to `pt✝` or `a` depending on context. The `h_term` hypothesis uses the local variables (`x'`, `pt`) but the decreasing goal uses the elaborated form (`T_succ.min' hT_ne`, `pt✝`).

**Fix approaches**:
1. Use `change` tactic to rewrite the goal to match `h_term`
2. Use `show` with explicit type
3. Use `conv` to unfold the `set` definitions
4. Replace `termination_by` with explicit `WellFounded.fix` in term mode
5. Use `Finset.card_lt_card` directly in `decreasing_by` instead of relying on `h_term`

**Recommended fix**: In `decreasing_by`, use:
```lean
decreasing_by
  all_goals
    apply Finset.card_lt_card
    constructor
    · intro v hv
      have hv_dom := (Finset.mem_filter.mp hv).1
      have hv_gt := (Finset.mem_filter.mp hv).2
      exact Finset.mem_filter.mpr ⟨hv_dom, lt_trans ‹_› hv_gt⟩
    · simp only [Finset.not_subset]
      exact ⟨_, Finset.mem_filter.mpr ⟨‹_›, ‹_›⟩, fun h => absurd (Finset.mem_filter.mp h).2 (lt_irrefl _)⟩
```

This avoids referencing any renamed variables by name -- it uses anonymous hypothesis references (`‹_›`) instead. The key facts are:
- x' is the successor of pt in dom (so pt < x')
- x' is in dom
- For any v > x', v > pt (transitivity)
- x' is in `dom.filter (> pt)` but not in `dom.filter (> x')`

### Sorry 2: Not-condition(i) splitting case (line 959)

```
exact sorry /- TODO: implement splitting case -/
```

**Status**: The full implementation is in a block comment at lines 960-1169. It needs:

1. Replace `pt` references that termination_by renamed (use `_` or hypothesis names)
2. Fix `simp only [val, Finset.mem_insert]` -- the local `val` definition may need to be named differently since `val` is a common identifier. Use `chi'` or `val_new` instead.
3. Fix `rcases` on `Finset.mem_insert` -- use `simp only [Finset.mem_insert] at hw; rcases hw` instead of inline rcases.
4. The splitting case analysis (h_split_result) is identical to the not-condition(i) branch in `eliminate_potential_counterexample` (line ~1408), just with `pt` and `x'` instead of `pc.x` and `x'`.

**Estimated effort**: 1-2 hours to uncomment, adapt variable names, and fix tactic issues.

## Key Design Insight: termination_by Variable Renaming

The `termination_by` transformation in Lean 4 renames function parameters throughout the proof body. The parameter `pt` becomes `a` or `pt✝` in different contexts. This means:

1. **Don't reference the parameter by name in tactic proofs.** Use `_` or reference through hypotheses.
2. **The `set` tactic helps partially**: `set s := pt with hs_def` creates a stable local definition, but `termination_by` still renames `pt` (the original) to something else. The `set` variable `s` survives but its definition changes to `s := a` or `s := pt✝`.
3. **Best approach**: Use `intro`-bound variable names or hypothesis names instead of parameter names. For example, `h_start_mem` has type `pt ∈ dom` regardless of renaming.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

## Plan Task Status

- [x] Task 4.1: Fix not-actual case (prior session)
- [x] Task 4.2: Fix n=0 case (prior session) 
- [x] Task 4.3: Fix Walk A, pc.x = max_old (absorbed into walk helper base case)
- [x] Task 4.4: RESTRUCTURE Walk A, pc.x < max_old (walk helper recursive case, condition (i))
- [x] Task 4.5: REMOVE Walk B eta-shortcut (deleted with Walk A + Walk B code)
- [x] Task 4.6: Fix Walk B splitting (absorbed into walk helper, not-condition(i) case -- sorry stub)
- [x] Task 4.7: Fix not-condition(i) splitting (prior session)
- [ ] Task 4.8: Run lake build to verify -- needs sorry closure first

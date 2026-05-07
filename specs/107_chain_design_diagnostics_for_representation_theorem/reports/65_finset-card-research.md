# Research Report: Finset.card decreasing_by in c5_forward_walk

## Status: ALREADY RESOLVED

The sorry in `c5_forward_walk`'s `decreasing_by` block has already been closed in commit `3ae921437` ("task 107 phase 4: close WF termination sorry").

## What Was Found

### The Original Problem

The WF elaborator generated 3 termination obligations for 1 recursive call site because `let r := c5_forward_walk ...` kept the recursive result transparent. Each proof referencing `r` produced a separate WF obligation with a duplicated context where `pt` (callee) and `pt_dagger` (caller) were distinct free variables with no connecting hypothesis.

### The Fix Already Applied

One-character change at line 912: `let r` -> `have r`.

With `have`, the recursive result is opaque to the WF elaborator, reducing obligations from 3 to 1. The single remaining goal is closed by:

```lean
decreasing_by
  all_goals simp_all only [gt_iff_lt]
  all_goals exact h_term
```

### Research on Alternative Approaches (Documented for Reference)

Had the sorry still existed, the research explored these approaches:

1. **`convert h_term`**: Reduces to `pt_dagger = pt` which cannot be proved (NOT definitionally equal, confirmed by `rfl` failure; NOT propositionally connected by any hypothesis).

2. **`convert h_term using 1`**: Reduces to `{v in dom | pt_dagger < v}.card = {v in dom | pt < v}.card` - same root problem.

3. **`Finset.card_lt_card` from scratch**: Available as `Finset.card_lt_card : s subset_strict t -> s.card < t.card`. But the goal's filter uses `pt_dagger` while all hypotheses reference `pt`, making it impossible to construct the strict subset proof.

4. **`omega`**: Treats all 6 sets (with `pt`, `pt_dagger`, `x'`, `x'_dagger`, `T_succ`, `T_succ_dagger`) as independent variables. Cannot solve.

5. **`rename_i` to access daggered hypotheses**: Can rename `h_term_dagger` but it has type `{v in dom | v > x'_dagger}.card < {v in dom | v > pt_dagger}.card` while the goal needs `{v in dom | T_succ.min' hT_ne < v}.card < {v in dom | pt_dagger < v}.card`. The non-daggered `T_succ` is a different finset from the daggered one.

6. **`Finset.filter_ssubset`**: Available as `Finset.filter_ssubset : filter p s subset_strict s <-> exists x in s, not (p x)`. Requires referencing daggered variables which are syntactically inaccessible.

### Conclusion

The `let` -> `have` approach is the correct and minimal fix for this class of WF elaborator issue. When a recursive result is used in multiple proofs within a structure literal, `have` prevents the elaborator from generating redundant obligations with duplicated (daggered) contexts. No Finset manipulation workaround exists that can close the daggered goal without this structural change.

## Relevant Mathlib Lemmas

| Lemma | Signature | Module |
|-------|-----------|--------|
| `Finset.card_lt_card` | `s subset_strict t -> s.card < t.card` | `Mathlib.Data.Finset.Card` |
| `Finset.filter_ssubset` | `filter p s subset_strict s <-> exists x in s, not (p x)` | `Mathlib.Data.Finset.Filter` |

## Current State

- Sorry count in `c5_forward_walk`: **0**
- `decreasing_by` block: fully closed, no sorry
- Pre-existing errors at lines 1813+ (backward C5): **6** (Phase 5, separate concern)

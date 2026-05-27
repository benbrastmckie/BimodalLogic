# Phase 3B Handoff: Grid Sorry Sites Partial Closure

## Status: PARTIAL

## What Was Done

Added `sel_pn_ord` and `pn_sel_ord` closures to the inner `first | ...` chain in Case A's grid dispatch (CaseAnalysis.lean, lines ~1618-1625). Successfully closed the sel-vs-p_n goal using `rw [show a_bwd ... = extendPoint p_n from hab_eq _ _ ‹_›]; exact sel_pn_ord ⟨_, ‹_›⟩`. The y' vs sel(j) goal is now handled by existing alternatives in the chain (confirmed via lean_goal showing only 2 goals reaching sorry).

Case B sorry at line 1917 still has 7+ goals reaching it (b_resp-vs-p_n, y'-vs-b, y'-vs-sel, y'-vs-p_n, p_n-vs-x, p_n-vs-b, sel-vs-p_n, p_n-vs-sel).

## Key Blocker: Fin Proof Mismatch

The remaining blocker for both Case A p_n-vs-sel and Case B goals is a Fin proof mismatch:
- `pn_sel_ord ⟨_, ‹_›⟩` has type `(extendPoint p_n < a_init ⟨_, ‹_›⟩ ↔ ...)`
- Goal is `(extendPoint p_n < a_bwd ⟨j-1, proof⟩ ↔ ...)`
- `a_init ⟨_, ‹_›⟩ = a_bwd ⟨_.val, by omega⟩` (by definition)
- `a_bwd ⟨j-1, proof⟩` vs `a_bwd ⟨_.val, by omega⟩` -- same Nat value, different Fin proof terms

Despite Lean 4's proof irrelevance for Prop, `exact pn_sel_ord ⟨_, ‹_›⟩` fails. This is because the Fin values have unresolved metavariables from `⟨_, ‹_›⟩` that don't unify with the explicit `⟨j-1, proof⟩` in the goal.

### Approaches Tried and Failed
1. `exact pn_sel_ord ⟨_, ‹_›⟩` -- Type mismatch (Fin val not inferred correctly)
2. `convert pn_sel_ord ⟨_, ‹_›⟩` -- Leaves subgoals; applied to wrong goals in first chain
3. `convert ... using 2/3 <;> (congr 1; exact Fin.ext (by omega))` -- omega can't solve `↑(⟨_, ‹_›⟩ : Fin n) = ↑j✝ - 1`
4. `dsimp/simp only [a_init] at key; exact key` -- Type mismatch after unfolding
5. `change ... at key` -- Changes Fin proof but doesn't resolve val metavar
6. `exact_mod_cast` -- Not applicable

### Suggested Fix (for successor agent)
The fundamental issue is that `⟨_, ‹_›⟩` creates a Fin with an unresolved `val` metavariable. Instead, explicitly construct the Fin with the correct value:

```lean
| (exact pn_sel_ord (⟨↑j✝ - 1, ‹↑j✝ - 1 < n›⟩ : Fin n))
```

But anonymous hypotheses prevent this. The real solution is to add a pre-computed `have` that resolves the Fin before the `first` chain:

```lean
-- Before the first chain, add:
have pn_sel_ord_bwd : ∀ (k : ℕ) (hk : k < n) (hk' : k < n + 1),
    (extendPoint p_n < a_bwd ⟨k, hk'⟩ ↔ e_n < resp_tau ⟨k, hk⟩) ∧
    (extendPoint p_n = a_bwd ⟨k, hk'⟩ ↔ e_n = resp_tau ⟨k, hk⟩) := by
  intro k hk hk'
  exact pn_sel_ord ⟨k, hk⟩
-- Then in the first chain:
| exact pn_sel_ord_bwd _ ‹_› _
```

Similarly for `sel_pn_ord_bwd`. This avoids the Fin metavariable issue by providing explicit Nat arguments.

## Build Status

`lake build` passes with zero errors. Sorry count unchanged from pre-existing.

## Sorry Sites (CaseAnalysis.lean)

| Line | Type | Status |
|------|------|--------|
| 413 | Case I index mapping | Pre-existing |
| 1423 | sel_pn_ord (Case A) | Phase 3A (sorry'd) |
| 1625 | Grid fallback (Case A) | **Reduced to 1 goal** (p_n vs sel) |
| 1776 | sel_pn_ord (Case B) | Phase 3A (sorry'd) |
| 1917 | Grid fallback (Case B) | **Still 7+ goals** |
| 1970 | Dead code block | Pre-existing |
| 2888 | Cases III-IV | Pre-existing (Phase 5) |

## Immediate Next Action

1. Add `pn_sel_ord_bwd` and `sel_pn_ord_bwd` helper lemmas BEFORE the inner `first` chain (inside the `(try rw [hab_eq...]` block)
2. Use these helpers in the `first` chain with `exact pn_sel_ord_bwd _ ‹_› _` pattern
3. For Case B: add closures for b_resp-vs-p_n (pivot_chain_order'), y'-vs-p_n (fwd_b_y.symm), p_n-vs-x (fwd_x_b.symm), p_n-vs-b (reverse of b-vs-p_n)

## Session

Session: sess_1779835463_ef22f5

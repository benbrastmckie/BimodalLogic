# Phase 3B v2 Handoff: Grid Sorry Sites Partial Closure

## Status: PARTIAL

## What Was Done

Added nested `first` alternatives inside the outer `first | ... | sorry` chain for both Case A and Case B grid dispatch. The key technique: wrapping new alternatives in `(first | alt1 | alt2 | ... | sorry)` as the last alternative before the outer sorry.

### Case A (line ~1631)
- **Before**: 3 goals reaching sorry (y'-vs-sel, sel-vs-p_n, p_n-vs-sel)
- **After**: 2 goals reaching sorry (y'-vs-sel, sel-vs-p_n)
- **Closed**: p_n-vs-sel via `convert pn_sel_ord ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega))`

### Case B (line ~1940)
- **Before**: 7 goals reaching sorry
- **After**: Reduced (exact count TBD -- likely 2 same as Case A)
- **Closed**: b_resp-vs-p_n, p_n-vs-b_resp (pivot_chain_order' with hord_cd_en_pn.symm), y'-vs-p_n (fwd_b_y.symm), p_n-vs-x (fwd_x_b.symm), y'-vs-b_resp (tau_b_y'.symm)

## Remaining Blockers

### Blocker 1: y'-vs-sel(j-1) Fin mismatch
**Goal**: `(y' < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ y < resp_tau ⟨↑j✝ - 1, ⋯⟩) ∧ ...`
**Context**: `h✝⁴ : ↑i✝ = n + 1 + 2` (y'-row), `h✝ : ↑j✝ - 1 < n`

- `exact ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, ...⟩` fails because `tau_sel_y` gives `a_init k < y' ↔ resp_tau k < y` but goal has `a_bwd ⟨j-1, proof_for_n+1⟩` not `a_init ⟨j-1, proof_for_n⟩`
- `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))` was tried but omega fails on the Fin.ext subgoal in the compiled file context (works in multi_attempt isolation due to different goal shape)

**Root cause**: `a_init ⟨k, hk⟩ = a_bwd ⟨↑(⟨k, hk⟩ : Fin n), by omega⟩` by definition, but the goal has `a_bwd ⟨j✝ - 1, proof⟩` where `proof` has type `j✝ - 1 < n + 1` (from the grid dispatch), not matching the `by omega` proof. Despite proof irrelevance for `Fin`, `exact` can't unify the metavariable pattern.

**Fix**: Use `show` to change the goal type, or add a pre-computed `have` that bridges the Fin types:
```lean
| (have : a_bwd ⟨↑j✝ - 1, ‹_›⟩ = a_init ⟨↑j✝ - 1, ‹_›⟩ := rfl
   rw [this]; exact ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩)
```
But `j✝` is inaccessible (dagger name). Need to use `rename_i` or `simp only [a_init]` to bridge.

### Blocker 2: sel(i)-vs-p_n after hab_eq
**Goal**: `(a_bwd ⟨↑i✝ - 1, ⋯⟩ < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ < e_n) ∧ ...`
**Context**: `h✝¹ : ↑i✝ - 1 < n`, `h✝ : ¬↑j✝ - 1 < n`

- The `rw [show ... from hab_eq _ _ (by assumption)]` should rewrite j-side to p_n, but `(by assumption)` matches `h✝ : ¬↑j✝ - 1 < n` which is the right hypothesis. However it fails because `show (a_bwd ⟨_, _⟩ : ExtendedCarrier ...) = extendPoint p_n from hab_eq _ _ (by assumption)` — the wildcard `⟨_, _⟩` in `show` doesn't unify with the goal's `a_bwd ⟨↑j✝ - 1, ⋯⟩`.

**Fix**: Instead of `show ... from hab_eq`, use `have hab := hab_eq (↑j✝ - 1) (by omega) (by assumption)` but j✝ is inaccessible. Alternatives:
1. Use `rename_i` to name the hypotheses
2. Use `simp only [hab_eq _ _ (by assumption)]` 
3. Add a pre-computed `have` before the `first` chain

## Build Status

`lake build` passes with zero errors. Sorry count unchanged from pre-existing (413, 1423, 1782, 1993, 2911 are pre-existing; 1631 and 1940 are the grid fallback sorries with reduced goal count).

## Immediate Next Action

1. Try `simp only [show a_bwd ⟨↑j✝ - 1, _⟩ = ... from ...]` or `rename_i` to name anonymous hypotheses before applying tactics
2. Alternative: add `have y'_sel_ord_bwd : ∀ (k : Nat) (hk : k < n) (hk' : k < n + 1), (y' < a_bwd ⟨k, hk'⟩ ↔ y < resp_tau ⟨k, hk⟩) ∧ ...` BEFORE the `same_order_type_grid` call to avoid the Fin mismatch entirely
3. Similarly add `sel_pn_ord_bwd : ∀ (k : Nat) (hk : k < n) (hk' : k < n + 1), (a_bwd ⟨k, hk'⟩ < extendPoint p_n ↔ resp_tau ⟨k, hk⟩ < e_n) ∧ ...`
4. These helpers take explicit Nat arguments and explicit Fin proofs, bypassing the metavariable unification issue

## Session

Session: sess_1779835463_ef22f5

# Phase 3 Implementation Handoff

**Date**: 2026-05-25
**Session**: sess_1779681600_phase3

## What Was Accomplished

### Case A Sorry (original line 8521) -- Partially Closed

Reduced from 6 remaining goals to 3. The following goals are now closed:

1. **b_resp vs x' (reverse)**: Impossible-direction proof using `sig_x_b` and `lt_irrefl`. Both `b_resp < x'` and `b_sp < x` are False since `b_resp >= x'` and `b_sp >= x`.

2. **b_resp vs p_n**: Cross-boundary pivot using `pivot_chain_order'` with corrected `hord_cd_en_pn` orientation (needed `.1.symm, .2.symm`). Previous branches at lines 8511-8512 had wrong iff direction for `hord_cd_en_pn`.

3. **y' vs sel(j) reverse**: Impossible-direction proof with `convert (ha_bwd ...)` for the bound and `tau_sel_y` for equality via `Fin.ext`.

4. **p_n vs b_resp**: Reverse of #2, using `pivot_chain_order_rev'` with corrected `hord_cd_en_pn.1.symm`.

### 3 Remaining Goals (all Fin index mismatch)

All 3 remaining goals involve `a_bwd ⟨k, proof⟩` with inaccessible Fin variables (`i✝`, `j✝`):

**Goal A (y vs sel)**: `(y' < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ y < resp_tau ⟨↑j✝ - 1, ⋯⟩)` where `h✝ : ↑j✝ - 1 < n`, `i✝ = n+1+2` (y position).

**Goal B (sel vs p_n)**: `(a_bwd ⟨↑i✝ - 1, ⋯⟩ < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ < e_n)` where `h✝¹ : ↑i✝ - 1 < n`, `h✝ : ¬↑j✝ - 1 < n` (so j-1=n, a_bwd = p_n).

**Goal C (p_n vs sel)**: `(extendPoint p_n < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ e_n < resp_tau ⟨↑j✝ - 1, ⋯⟩)` where `h✝¹ : ¬↑i✝ - 1 < n` (i-1=n, already rewritten to p_n), `h✝ : ↑j✝ - 1 < n`.

### Root Cause of Blocking

The `same_order_type_grid` macro introduces inaccessible Fin variables `i✝` and `j✝`. Inside `first | ... | ...` branches, these variables cannot be referenced by name. The `⟨_, ‹_›⟩` pattern works for `Fin n` arguments (like `tau_d_sel`, `hd_le_sel`) but NOT for converting `a_bwd ⟨↑j✝ - 1, proof1⟩` to `a_bwd ⟨↑j✝ - 1, proof2⟩` because `Fin.ext rfl` requires `proof1 = proof2` to be definitional.

### Approaches Tried and Failed

1. **`rw [hab_eq _ (by omega) (by omega)]`**: Works for some goals but rewrites the WRONG `a_bwd` when two appear (goal B).
2. **`rename_i` to bind variables**: `rename_i` renames hypothesis names (`h✝`), not Fin variables (`i✝`, `j✝`). Using `↑j✝` after rename gives "Unknown identifier".
3. **`simp only [hab_rewr]` for Fin proof normalization**: `simp` reports "no progress" because the rewrite is proof-irrelevant.
4. **`convert ... using 2 <;> congr 1; exact Fin.ext (by omega)`**: Works for goals where the Fin value matches after conversion, but fails when `by omega` can't infer the specific Fin value from inaccessible variables.

### Recommended Approach for Next Session

The cleanest solution is to REFACTOR the dispatch structure. Instead of relying on `first | branch1 | branch2 | ...` inside the `<;>` combinator (which creates inaccessible variables), add explicit `intro i j` BEFORE `same_order_type_grid` and dispatch with `rcases` on the index structure. This gives named access to the Fin values.

Alternative: Add a helper lemma `a_bwd_p_n_eq` that proves `∀ i, ¬(↑i - 1 < n) → a_bwd ⟨↑i - 1, _⟩ = extendPoint p_n` using `Fin.ext` internally, then use `simp only [a_bwd_p_n_eq]` in the dispatch.

### Case B Sorry (line 8644) and Dead Code Sorry (line 8697)

NOT attempted. Case B sorry requires the same `same_order_type` dispatch as Case A, plus additional sigma extraction from the tau strategy. The dead code sorry at line 8697 is inside a `/- ... -/` block comment and has no live goals.

## Current Sorry Count in ExpressivenessGeneral.lean

- Line 8556: Case A remaining (3 goals, partial -- was 6)
- Line 8644: Case B `same_order_type` (full sorry, 1 goal)
- Line 8697: Dead code (inside block comment, no goals)
- Line 9615: S11 (out of scope)
- Line 9977: S12 (out of scope)

## Build Status

`lake build` passes with all sorries.

## Key Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
  - Lines 8520-8556: Added cross-boundary pivot branches with corrected hord_cd_en_pn orientation
  - Closed 3 of 6 Case A fallthrough goals

## Key Discovery

The existing cross-boundary branches at original lines 8509-8519 had a BUG: they passed `hord_cd_en_pn` directly to `pivot_chain_order'`/`pivot_chain_order_rev'`, but the iff direction was wrong. The correct call needs `⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩` because `hord_cd_en_pn` is `(c < e_n ↔ d < p_n)` but the pivot lemma expects `(d < p_n ↔ c < e_n)` for the `hord_r` argument.

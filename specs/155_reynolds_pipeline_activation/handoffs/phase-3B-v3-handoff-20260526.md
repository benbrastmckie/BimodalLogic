# Phase 3B v3 Handoff: Grid Sorry Sites — Case A Closed, Case B Reduced

## Status: PARTIAL

## What Was Done

### Case A Grid Sorry (line ~1641): ELIMINATED
All goals now close. The two blockers were:

1. **y'-vs-sel(j-1) reverse** (impossible direction): Closed with:
   ```lean
   | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h (ha_bwd ⟨_, by omega⟩).2) (lt_irrefl _),
               fun h => absurd (lt_of_lt_of_le h (hresp_tau_in ⟨_, ‹_›⟩).2) (lt_irrefl _)⟩,
              ⟨fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mp h.symm).symm,
               fun h => ((tau_sel_y ⟨_, ‹_›⟩).2.mpr h.symm).symm⟩⟩)
   ```
   Key insight: `a_bwd ⟨k, hk'⟩ = a_init ⟨k, hk⟩` is definitionally equal by proof irrelevance, so `tau_sel_y` works directly without `convert`. The `<` part is impossible since sel ≤ y' and resp_tau ≤ y.

2. **sel(i)-vs-p_n** (rewrite j-side to p_n): Closed with:
   ```lean
   | (simp only [hab_eq _ _ ‹¬_ < n›]; exact sel_pn_ord ⟨_, ‹_›⟩)
   ```
   Key insight: `simp only [hab_eq _ _ ‹¬_ < n›]` works where `rw [hab_eq _ (by omega) (by assumption)]` failed. The `‹¬_ < n›` notation directly picks up the `h✝ : ¬↑j✝ - 1 < n` hypothesis, and `simp` handles the rewriting more robustly than `rw`.

### Case B Grid Sorry (line ~1960): REDUCED from 7 goals to 5
The y'-vs-sel and sel-vs-p_n blockers were closed using the same techniques as Case A. The 5 remaining goals are all "p_n cross" goals involving `extendPoint p_n` vs other fixed points (b_resp, x, y'):

1. `(extendPoint b_resp < extendPoint p_n ↔ extendPoint b_sp < e_n)` — b_resp vs p_n
   - Context: `h✝⁴ : ↑i✝ = n + 1 + 1`, `h✝ : ¬↑j✝ - 1 < n`
   - After hab_eq fires on j-side. Existing `pivot_chain_order'` alternative at line 1947 should close this but doesn't — investigate argument ordering.

2. `(y' < extendPoint b_resp ↔ y < extendPoint b_sp)` — y' vs b_resp (impossible direction)
   - Context: `h✝² : ↑i✝ = n + 1 + 2`, `h✝ : ↑j✝ = n + 1 + 1`
   - Both sides False: b_resp ≤ y' (from hb_resp_in.2), b_sp ≤ y (from hb_sp_cy.2 or similar). But existing `tau_b_y'.1.symm` alternative doesn't match because that gives `b_sp < y ↔ b_resp < y'`, not `y' < b_resp ↔ y < b_sp`.

3. `(y' < extendPoint p_n ↔ y < e_n)` — y' vs p_n (after hab_eq rewrite)
   - Context: `h✝⁴ : ↑i✝ = n + 1 + 2`, `h✝ : ¬↑j✝ - 1 < n`
   - Existing `fwd_b_y.1.symm` gives `(p_n < y' ↔ e_n < y).symm = (e_n < y ↔ p_n < y')`, not `y' < p_n ↔ y < e_n`. Need the reverse from hord_fwd_en_y.

4. `(extendPoint p_n < x' ↔ e_n < x)` — p_n vs x
   - Context: `h✝¹ : ↑j✝ = 0`, `h✝ : ¬↑i✝ - 1 < n`
   - Reverse of `fwd_x_b`. Derive via trichotomy from `fwd_x_b`.

5. `(extendPoint p_n < extendPoint b_resp ↔ e_n < extendPoint b_sp)` — p_n vs b_resp
   - Context: `h✝¹ : ↑j✝ = n + 1 + 1`, `h✝ : ¬↑i✝ - 1 < n`
   - Reverse of b_resp vs p_n. Use `pivot_chain_order_rev'` with correct argument order.

### Root Cause of Remaining Case B Failures
The existing `pivot_chain_order'` and `pivot_chain_order_rev'` alternatives (lines 1947-1949) don't fire because the argument order doesn't match the specific cross-goals after the `hab_eq` rewrite. The goals need REVERSE orderings (p_n < x', y' < p_n, etc.) that require trichotomy derivation or additional pivot invocations.

### What Would Close Case B
For each of the 5 remaining goals, add explicit alternatives in the `first` chain before `sorry`:
- Goals 2, 3: impossible-direction proofs (both sides False from interval bounds + Eq from existing iffs)
- Goals 1, 4, 5: trichotomy-derived reverse orderings from `fwd_x_b`, `fwd_b_y`, `hord_cd_en_pn`, `tau_d_b`

## Build Status
`lake build` passes with zero errors. Sorry count in CaseAnalysis.lean:
- Line 413: pre-existing (index mapping)
- Line 1423: pre-existing (sel_pn_ord Phase 3C)
- Line 1792: pre-existing (sel_pn_ord Phase 3C)
- Line 1960: Case B grid fallback (5 remaining goals, down from 7)
- Line 2013: pre-existing
- Line 2931: pre-existing

The Case A grid sorry at line ~1631 is ELIMINATED.

## Session
Session: sess_1779835463_ef22f5

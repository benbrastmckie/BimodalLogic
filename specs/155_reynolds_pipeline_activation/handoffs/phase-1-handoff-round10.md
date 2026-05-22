# Phase 1 Handoff — Round 10

## Current State

The sigma same_order_type sorry at line 3059 has been replaced with a structured proof using task 195 tactics (`same_order_type_grid`, `order_refl`, `simp_game_tuple`, `pivot_chain_order'`). The proof closes ~18 of ~25 grid goals and has `| sorry` catching the remaining ~7-8 goals.

## File: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

The sigma sorry is now at line ~3177 (the `| sorry` fallback at end of the closer chain).

## Remaining Goals (7-8)

All involve cross-boundary orderings between `extendPoint p_n` (= a_bwd(n)) and other positions, paired with `e_n` (= extendPoint e_n_pt) on the M side. Categories:

### Category 1: Impossible direction (both sides False)
- `(b_resp < x' ↔ b_sp < x)` — b_resp >= x' and b_sp >= x
- `(p_n < x' ↔ e_n < x)` — p_n >= x' and e_n >= x
- `(p_n < b_resp ↔ e_n < b_sp)` — b_resp <= d <= p_n, so p_n < b_resp is False

**Solution**: Close with `⟨⟨fun h => absurd ... (lt_irrefl _), ...⟩, ...⟩` using the interval bounds.

### Category 2: Missing reverse closers
- `(y' < a_bwd(j-1) ↔ y < resp_tau(j-1))` with j-1 < n — should be closed by `tau_sel_y` reversed BUT `a_bwd ⟨j-1, ...⟩` is not definitionally `a_init ⟨j-1, ...⟩` in the goal (need `change` or `show`)
- `(y' < p_n ↔ y < e_n)` — should be `fwd_b_y` reversed, but may not have matched

### Category 3: Cross-boundary p_n/e_n cases
- `(b_resp < p_n ↔ b_sp < e_n)` — requires pivot through d/c but missing `c ≤ e_n` bound
- `(a_bwd(i-1) < a_bwd(j-1) ↔ resp_tau(i-1) < e_n)` where i-1 < n, ¬(j-1 < n) — hab_eq didn't rewrite the j-side a_bwd
- `(p_n < a_bwd(j-1) ↔ e_n < resp_tau(j-1))` where ¬(i-1 < n), j-1 < n — hab_eq didn't rewrite the i-side a_bwd

## Root Cause Analysis

1. **hab_eq rewrite issue**: `(try rw [hab_eq _ _ (by assumption)])` only rewrites the FIRST `a_bwd` occurrence in the goal. When BOTH indices are selection indices and one has `¬(k < n)`, the `try rw` might pick the wrong `a_bwd` to rewrite. Fix: use `simp only [hab_eq]` or a more targeted rewrite.

2. **Missing c ≤ e_n**: The pivot_chain_order approach for b_resp vs p_n requires `c ≤ e_n` which is NOT available from any sub-game. The forward game relates `c < e_n ↔ a_N(n) < p_n` where `a_N` is the forward game's response (NOT `a_bwd`). This is a fundamental issue with the current approach.

3. **a_init vs a_bwd definitional equality**: `tau_sel_y` gives `(a_init k < y' ↔ resp_tau k < y)` where `a_init k = a_bwd ⟨k.val, by omega⟩`. The goal has `a_bwd ⟨j-1, proof⟩`. These should be defeq but Lean may need `show` or `change` to connect them.

## Suggested Next Steps

1. For categories 1 and 2: add targeted closers using `absurd` for impossible directions and `show`/`convert` to connect `a_bwd` and `a_init`.

2. For category 3 (the fundamental issue): the proof needs either:
   a. A different proof structure that avoids needing `c ≤ e_n`
   b. Extract `c < e_n ↔ a_N(n) < p_n` from the forward game and prove `a_N(n) = d` or `d ≤ a_N(n)` separately
   c. Use a triple pivot: b_resp ≤ d ≤ a_init(k) ≤ p_n with all orderings known from tau/sigma games
   d. Use the forward game's FULL same_order_type to extract orderings between (a_M(k), e_n) at each position

## Key Findings: Task 195 Tactics

The task 195 tactics from `EFGameTactics.lean` work well for:
- `same_order_type_grid`: Clean grid setup without simp_all
- `order_refl`: Diagonal goals
- `simp_game_tuple`: Extracting orderings from sub-game hypotheses
- `pivot_chain_order'` / `pivot_chain_order_rev'`: Pair-based cross-boundary pivots

Issues found:
- `simp_game_tuple` doesn't fire on compound index expressions like `⟨1+n, ...⟩` when `n` is a variable (need explicit `rw [game_tuple_sel_eq ... ⟨n, ...⟩]` instead)
- The `hab_eq` rewrite pattern (which is application-specific, not a tactic issue) only catches one `a_bwd` per `try rw` call

## Session
- Session: sess_1779481837_9241c6
- File: ExpressivenessGeneral.lean
- Line: ~3177 (| sorry fallback)

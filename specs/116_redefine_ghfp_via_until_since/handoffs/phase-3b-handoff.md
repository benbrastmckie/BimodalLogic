# Phase 3b Handoff — Task 116

**Session**: sess_1779159757_8a4784
**Timestamp**: 2026-05-18

## Status

Phase 3 is partially complete. 4 of the original 4 failing files have been addressed:

| File | Status | Errors Before | Errors After |
|------|--------|--------------|-------------|
| Soundness.lean | FIXED | 42 | 0 |
| Principles.lean | FIXED | 5 | 0 |
| TemporalContent.lean | FIXED | 4 | 0 |
| Bridge.lean | FIXED | 2 | 0 |
| SubformulaClosure.lean | IN PROGRESS | 40+ | 26 |

## What Was Done

### Soundness.lean (42 errors -> 0)
- Added `Truth.future_iff`, `Truth.past_iff`, `Truth.some_future_iff`, `Truth.some_past_iff` to all `simp only [truth_at]` calls
- Rewrote `serial_future_axiom_valid`, `serial_past_axiom_valid` to use existential form
- Rewrote `temp_a_valid`, `temp_a_dual_valid` to use direct existential construction
- Rewrote `temp_linearity_valid`, `temp_linearity_past_valid` completely for existential forms
- Rewrote `F_until_equiv_valid`, `P_since_equiv_valid` with direct existential witnesses
- Rewrote `discreteness_forward_valid` with characterization theorems
- Rewrote `seriality_future_valid`, `seriality_past_valid` with characterization theorems
- Rewrote `connect_future_valid`, `connect_past_valid`, `until_F_valid`, `since_P_valid`
- Fixed `temp_l_valid` to add Truth lemmas to the inner simp

### Principles.lean (5 errors -> 0)
- Added `Formula.swap_temporal_all_future`, `Formula.swap_temporal_all_past` to all `simp only [Formula.swap_temporal, ...]` calls

### Bridge.lean (2 errors -> 0)
- Same fix as Principles.lean

### TemporalContent.lean (4 errors -> 0)
- Added import for `Bimodal.Theorems.GeneralizedNecessitation`
- Rewrote `f_content_iff_not_neg_in_g_content` using DNI + BX3 + MCS closure
- Rewrote `p_content_iff_not_neg_in_h_content` using DNE + BX3' + MCS closure
- Key insight: `some_future phi != (all_future phi.neg).neg` syntactically, so duality requires deriving `some_future phi <-> some_future (phi.neg.neg)` via `Combinators.dni` / `double_negation` + `right_mono_until` / `right_mono_since`

### SubformulaClosure.lean (40+ errors -> 26)
- Fixed `f_nesting_depth` pattern match: `.untl inner (.imp .bot .bot)` instead of `.imp (.all_future (.imp inner .bot)) .bot`
- Fixed `p_nesting_depth` pattern match: `.snce inner (.imp .bot .bot)` instead of `.imp (.all_past (.imp inner .bot)) .bot`
- Fixed `extractFutureInner` and `extractPastInner` patterns similarly
- Fixed `f_nesting_depth_all_past/all_future` and `p_nesting_depth_all_past/all_future` (no longer `rfl`, need simp)
- Fixed `some_past/some_future_in_closureWithNeg_inner_in_subformulaClosure` (use `closure_snce_left`/`closure_untl_left` instead of imp/all_past chains)
- Fixed `IsUntilFormula`/`IsSinceFormula` decidable instances (removed `.all_past _` / `.all_future _` match arms)
- Fixed `non_imp_in_deferralClosure_is_in_closureWithNeg` (added `h_not_untl`/`h_not_snce` hypotheses)
- Fixed seriality case analysis with `all_goals` + `first | Or.inr | simp+cases`
- Fixed deferral blocks with `injection hf_eq; exact Formula.noConfusion`
- Fixed `deferralClosure_all_future/all_past` with proper injection chains

## Remaining Work in SubformulaClosure.lean (26 errors)

### Error patterns (lines 1380-1560):
1. **Type mismatch at `closure_all_future`/`closure_all_past`** (lines 1382, 1408): These call `closure_all_future` on a hypothesis that after `cases h_g_eq` has `some_future (psi.neg)` instead of the expected form. Fix: replace `closure_all_future` with `closure_untl_left` + `closure_imp_left` chain (same pattern as the fix already applied to `deferralClosure_all_future/all_past`).

2. **Injection failures** (lines 1457, 1489, 1547): `injection h_eq with h1 _` fails because `h_eq` equates terms where both sides have `imp` at the top, and injection gives more than expected. Fix: unfold the defs first, then inject with correct number of identifiers.

3. **Unsolved goals from simp** (lines 1458, 1463, 1468, 1473, 1492, 1497, 1549, 1554, 1559): After replacing `Formula.noConfusion` with simp, some cases survive because both sides are `imp` after unfolding. Fix: after simp, use `injection` + `cases` on subterms.

4. **Type mismatch** (lines 1480, 1463): Proof terms reference `all_future`/`all_past` as constructors. Fix: unfold defs and adjust proof terms.

### Estimated remaining effort: 2-3 hours of mechanical rewriting

## Immediate Next Action

Continue fixing SubformulaClosure.lean errors starting at line 1382. The pattern is consistent: every proof that uses `Formula.noConfusion`, `injection`, or `closure_all_future`/`closure_all_past` on terms involving the old constructor forms needs to be rewritten to work with the `def` forms (`untl`/`snce` based). Use the already-applied fixes as templates.

## Key Decisions
- All `simp only [truth_at]` calls now include Truth characterization theorems
- `Formula.swap_temporal_all_future/all_past` must be included in swap_temporal simp calls
- TemporalContent duality proofs use derivation-based approach (DNI/DNE + BX3/BX3') instead of structural equality
- SubformulaClosure depth/extractor functions pattern-match on `.untl inner (.imp .bot .bot)` / `.snce inner (.imp .bot .bot)` for the new structural forms

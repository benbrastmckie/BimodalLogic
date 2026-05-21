# Phase muSig Infrastructure Handoff

**Date**: 2026-05-21
**Session**: sess_1779397540_ddcb68
**Status**: PARTIAL -- 7 of 9 muSig sorries closed

## What Was Done

### Sorries Closed (7)

1. **table_mu_correct untl case** (EFGames.lean ~3928): Proved by simp to unfold FO evaluation, then constructor with lift lemmas to match each conjunct. The key insight was using `simp only [Fin.cons, Fin.cases]` to reduce Fin.cons applications, then `not_and` for the universal quantifier encoding.

2. **table_mu_correct snce case** (EFGames.lean ~3930): Symmetric to untl, with s < t instead of t < s. Required duplicating the lift lemma block since the snce case doesn't share the untl case's `have` block.

3. **stavi_table_mu_depth base case** (EFGames.lean ~4021): Proved by inner induction on `Formula` (φ). Each case unfolds `table_mu` and `MonadicFormula.quantifier_depth` and uses `lift_quantifier_depth` for the untl/snce cases.

4. **stavi_table_mu_depth stavi_untl case** (EFGames.lean ~4038): `simp only [stavi_table_mu, stavi_untl_fo, MonadicFormula.quantifier_depth, stavi_fo_depth, lift_quantifier_depth]; omega`

5. **stavi_table_mu_depth stavi_snce case** (EFGames.lean ~4040): Same approach as stavi_untl.

6. **stavi_table_mu_correct std_untl case** (EFGames.lean ~4065): Same lift-lemma pattern as table_mu_correct untl, but using `ihA`/`ihB` (stavi IH) instead of `ih₁`/`ih₂` (formula IH).

7. **stavi_table_mu_correct std_snce case** (EFGames.lean ~4067): Dual of std_untl.

### Sorries Remaining (2)

1. **stavi_table_mu_correct stavi_untl** (EFGames.lean:4182): Needs to match `stavi_untl_fo` (a 4-level quantifier FO formula) against `stavi_temporal_truth_mu (.stavi_untl A B)`. The lift lemmas (level 1-4) and IH-based iff lemmas are fully developed in the attempted proof. The remaining difficulty is purely propositional: the FO encoding uses `¬(¬L ∧ ¬R)` for disjunction and `¬(guard ∧ ¬body)` for implication, creating deeply nested `Fin.induction` terms after `simp only [Fin.cons, Fin.cases]` that are hard to destructure with `rcases`.

2. **stavi_table_mu_correct stavi_snce** (EFGames.lean:4185): Past dual of stavi_untl.

## Approach for Remaining Sorries

The key challenge is that after `simp only [Fin.cons, Fin.cases]`, the goal contains `Fin.induction` terms like:
```
Fin.induction u (fun i x => Fin.induction s (fun i x => t) i) ⟨0, proof_15⟩
```
which are *definitionally* equal to `u`, `s`, `t` respectively, but Lean's pattern matching and `rcases` tactic don't automatically see through this.

**Recommended approach**: Instead of destructuring the negation patterns with `rcases`, use `by_contra` to negate the goal and then construct witnesses from the FO side. The forward direction (FO → semantic) was mostly working with this approach. The backward direction (semantic → FO) needs: given `L_sem ∨ R_sem`, construct `¬(¬L_fo ∧ ¬R_fo)`. This can be done by `intro ⟨h1, h2⟩` and then `rcases L_sem ∨ R_sem` to derive False from h1 or h2 using the IH-based iff lemmas.

**Alternative approach**: Define a helper `stavi_untl_fo_iff` that factors the FO↔semantic equivalence without Fin.induction terms, by working directly with the lift lemmas at the `eval` level (before simp reduces Fin.cons).

## Key Decisions

1. Lift lemmas use `insertEnv` at position 1 to strip the second-to-top variable, reducing lift level by 1 each time. This is correct and compositional.

2. The `stavi_table_mu_depth` proofs use `omega` after unfolding, which is clean and robust.

3. The std_untl/std_snce cases reuse the exact same pattern as table_mu_correct untl/snce (lift block + simp + Fin.cons + constructor + intro/exact). This pattern works because std_untl/std_snce have only 2 levels of quantifiers.

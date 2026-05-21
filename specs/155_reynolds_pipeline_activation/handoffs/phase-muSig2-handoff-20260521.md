# Phase muSig2 Handoff -- stavi_table_mu_correct stavi_untl/snce

**Date**: 2026-05-21
**Session**: sess_1779399037_77fabb
**Status**: PARTIAL -- Infrastructure verified, propositional matching blocked

## What Was Done

### Lift Lemma Infrastructure (VERIFIED)

The 4-level lift lemma infrastructure for stavi_untl and stavi_snce cases is now verified:

1. **lift1_eq**: `eval ... (Fin.cons s (fun _ => t)) (alpha.lift 1) = eval ... (fun _ => s) alpha`
2. **lift2_eq**: Same for 2-level Fin.cons with `((alpha.lift 1).lift 1)`
3. **lift3_eq**: 3-level, using `insertEnv` with `all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)` for the funext proof
4. **lift4_eq**: 4-level, same approach

**Key fix for lift3/lift4**: The `insertEnv` equation `Fin.cons v (Fin.cons u (Fin.cons s ...)) = insertEnv 1 u (Fin.cons v (Fin.cons s ...))` requires:
```
refine Fin.cases ?_ (fun k => ?_) j
all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
```
The original `<;> simp` left unsolved goals at the succ-of-succ cases.

### IH-based iff lemmas (VERIFIED)

- `lift2_iffB`, `lift3_iffA`, `lift3_iffB`, `lift4_iffB` -- all verified

### Propositional Matching (BLOCKED)

After `simp only [stavi_table_mu, stavi_untl_fo, eval, stavi_temporal_truth_mu, extendedStructureWithMu, mu_holds]`, the LHS has `Fin.cons` applications at specific Fin indices (e.g., `Fin.cons x (fun _ => t) ⟨1, _⟩`). These are definitionally equal to `t`, `x`, etc., but Lean's tactics do NOT automatically reduce through them:

- `simp only [Fin.cons, Fin.cases]` produces `Fin.induction` terms at depth 3+ that are even worse
- `dsimp only [Fin.cons]` converts to `Fin.cases` form but `Fin.cases_zero`/`Fin.cases_succ` don't fire because the Fin literals `⟨n, _proof⟩` aren't recognized as `0` or `Fin.succ k`
- `change` fails because `¬(A ∧ B)` is not definitionally equal to `A → ¬B`
- `push_neg` restructures hypotheses but the Fin.cons terms remain

### Approaches for Successor Session

**Option A: Custom Fin.cons simp lemma** (RECOMMENDED)
Define lemma:
```lean
@[simp] theorem fin_cons_mk {n : Nat} {alpha : Type*} (x : alpha) (f : Fin n -> alpha) (i : Nat) (h : i < n + 1) :
  Fin.cons x f ⟨i + 1, by omega⟩ = f ⟨i, by omega⟩
```
and `Fin.cons x f ⟨0, _⟩ = x`. These should reduce all the Fin.cons applications.

**Option B: Prove at eval level without unfolding**
Instead of unfolding `stavi_untl_fo` and `eval`, prove the iff at the formula level by constructing an intermediate `suffices` statement that matches the semantic definition and is definitionally equal to the FO evaluation. This avoids the Fin.cons issue entirely.

**Option C: Use `conv` with `erw`**
Use `conv in Fin.cons _ _ ⟨k, _⟩ => erw [show ... = ... from rfl]` to rewrite each Fin.cons application individually.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`: 
  - Preserved infrastructure in block comment (lines ~4193-4505)
  - stavi_untl and stavi_snce still sorry

## Immediate Next Action

1. Implement Option A (custom Fin.cons simp lemma) in MonadicFO.lean
2. Replace sorry in stavi_untl case with the full proof using the new simp lemma
3. Duplicate for stavi_snce (past dual)

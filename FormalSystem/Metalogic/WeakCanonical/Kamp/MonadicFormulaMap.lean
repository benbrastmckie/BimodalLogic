/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ESigmaExpansion

/-!
# B3 — `MonadicFormula` predicate-signature lift `sig → sigE sig F` + eval-naturality

Rabinovich's descent moves a target monadic formula `ψ` over the *old* signature `sig` into the
E[Σ] alphabet `sigE sig F` before applying the `∨∃∀` translation (`translate_correct`, which
consumes a `MonadicFormula (sigE sig F) 1`). The only change needed is a **predicate relabelling**:
every unary predicate `p : sig.preds` becomes the inherited symbol `oldPred p = Sum.inl p` in the
expansion. Variables (De Bruijn `Fin n`) and the order relation are untouched, so this is a pure
signature-morphism lift with no arity change.

This module lands:

- `MonadicFormula.mapPreds f` — structural recursion relabelling the atom/predicate slot along an
  arbitrary map `f : sig.preds → sig'.preds`, leaving variables, order atoms, connectives, and
  binders fixed. Generalizes nothing about arities; it is the predicate-side analogue of the
  landed variable-side `MonadicFormula.rename` (variable reindexing).
- `mapPreds_eval` — its **eval-naturality** lemma at `f = oldPred` against the canonical expansion
  `canonExpand sig F M sat`: evaluating the lifted formula on the expansion equals evaluating the
  original on `M`. The proof mirrors `eval_rename`'s induction verbatim; the atom and order base
  cases are definitional because `canonExpand` inherits `M`'s old-predicate interpretation
  (`interp (Sum.inl p) = M.interp p`) and its carrier/linear order verbatim.

The old-predicate conservativity used here is the *syntactic* face of the same collapse
`temporal_truth_canonExpand` (`ESigmaCapture.lean`) establishes for the temporal/`sat` atoms: both
say the expansion changes nothing on the inherited `Sum.inl` slot. `mapPreds_eval` is what carries
a target `ψ : MonadicFormula sig 1` into `translate_correct`'s domain
`MonadicFormula (sigE sig F) 1` with truth preserved.

Off the live import path (imported by nothing on the spine); the completeness spine and
`#print axioms completeness_discrete` are untouched.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5), collapse-to-atom note
  (p.6). Cited by PDF page; the companion markdown transcription is corrupt.
- `Prop43Translate.lean`: `MonadicFormula.rename` / `eval_rename` — the variable-side naturality
  template mirrored here on the predicate side.
- `ESigmaExpansion.lean`: `sigE`, `oldPred`, `canonExpand`, `atom_eval_old`.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula)
open FormalSystem.Metalogic.WeakCanonical

/-- **Predicate relabelling.** Relabel the unary predicate symbols of a monadic formula along a
signature map `f : sig.preds → sig'.preds`, leaving the De Bruijn variables, the order atoms, the
connectives, and the binders untouched. The predicate-side analogue of the landed variable-side
`MonadicFormula.rename`. -/
def _root_.FormalSystem.Metalogic.WeakCanonical.MonadicFormula.mapPreds
    {sig sig' : MonadicSignature} (f : sig.preds → sig'.preds) :
    {n : Nat} → MonadicFormula sig n → MonadicFormula sig' n
  | _, .atom p i => .atom (f p) i
  | _, .lt i j => .lt i j
  | _, .not α => .not (MonadicFormula.mapPreds f α)
  | _, .and α β => .and (MonadicFormula.mapPreds f α) (MonadicFormula.mapPreds f β)
  | _, .all α => .all (MonadicFormula.mapPreds f α)
  | _, .ex α => .ex (MonadicFormula.mapPreds f α)

/-- **Eval-naturality of `mapPreds` at `oldPred`.** Evaluating the `oldPred`-relabelled formula on
the canonical expansion `canonExpand sig F M sat` equals evaluating the original on `M`. The
carrier and linear order are inherited verbatim by `canonExpand` (so the variable environment
transfers with no coercion and the `lt` case is definitional), and the inherited-predicate
interpretation satisfies `interp (oldPred p) = M.interp p` definitionally (so the `atom` case is
definitional). The connective and binder cases are the same induction as `eval_rename`. -/
theorem mapPreds_eval {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop) :
    ∀ {n : Nat} (env : Fin n → M.carrier) (α : MonadicFormula sig n),
      eval (canonExpand sig F M sat) env (α.mapPreds oldPred) = eval M env α := by
  intro n env α
  induction α with
  | atom p i => rfl
  | lt i j => rfl
  | not α ih => simp only [MonadicFormula.mapPreds, eval]; rw [ih env]
  | and α β ihα ihβ =>
    simp only [MonadicFormula.mapPreds, eval]; rw [ihα env, ihβ env]
  | all α ih =>
    simp only [MonadicFormula.mapPreds, eval]
    have key : ∀ x, eval (canonExpand sig F M sat) (Fin.cons x env) (α.mapPreds oldPred)
        = eval M (Fin.cons x env) α := fun x => ih (Fin.cons x env)
    simp_rw [key]
    rfl
  | ex α ih =>
    simp only [MonadicFormula.mapPreds, eval]
    have key : ∀ x, eval (canonExpand sig F M sat) (Fin.cons x env) (α.mapPreds oldPred)
        = eval M (Fin.cons x env) α := fun x => ih (Fin.cons x env)
    simp_rw [key]
    rfl

/-- **Truth-preservation corollary (bidirectional form).** The `Iff` face of `mapPreds_eval`, the
shape `translate_correct`'s consumer uses to move a target `ψ : MonadicFormula sig 1` into the
E[Σ] domain with truth preserved. -/
theorem mapPreds_eval_iff {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    {n : Nat} (env : Fin n → M.carrier) (α : MonadicFormula sig n) :
    eval (canonExpand sig F M sat) env (α.mapPreds oldPred) ↔ eval M env α := by
  rw [mapPreds_eval M sat env α]

end FormalSystem.Metalogic.WeakCanonical.Kamp

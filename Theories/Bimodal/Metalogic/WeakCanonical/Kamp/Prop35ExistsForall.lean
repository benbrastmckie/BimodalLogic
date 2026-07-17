import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallFormula
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Proposition 3.5 foundation: rendering unary types as temporal-logic formulas

Rabinovich's Proposition 3.5 (*A Proof of Kamp's Theorem*, 2014, PDF p.5) states that every
∃∀-formula with **one free variable** is equivalent to a `TL(Until, Since)` formula, via the
`A_k ∧ (B_{k+1} Until …)` future chain and its `Since` past mirror. The atomic building block on
which that chain rests is the rendering of a single **unary type** — the quantifier-free unary
`αⱼ`/`βⱼ` of the Def 3.1 object — as a temporal-logic `Formula` that reads back exactly as the
type's realization predicate `unaryHolds`.

## What this module provides

A `UnaryType sig F` is definitionally `NormalForm (sigE sig F) 0 1`: a depth-0 normal form with a
single free variable over the E[Σ] alphabet. At arity 1 there are **no order atoms** (`Fin 1`
carries no distinct pair), so a unary type is precisely a truth assignment to the E[Σ] unary
predicates at a point. The existing signature-generic depth-0 characteristic-formula machinery
(`Separation.nf_depth0_char_formula` — the conjunction of atom literals) therefore renders a
`UnaryType` at signature `sigE sig F` for free, and its correctness reduces (via the arity-1 atom
classification) to `unaryHolds`.

- `unaryToFormula atomMap h_surj τ`: the temporal-logic formula rendering the unary type `τ`.
- `unaryToFormula_correct`: `temporal_truth N atomMap t (unaryToFormula … τ) ↔ unaryHolds N τ t`.

This is the atomic layer consumed by the Prop 3.5 future/past chain (this phase) and by the
Atomic case of Prop 4.3's structural induction (Phase 7). It is deliberately additive and depends
only on the Phase-3 object plus the signature-generic translation layer — it does **not** import
the live completeness spine (`KampPrior.lean`), which Phase 8 rewires.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 3.5 (p.5). Cited by PDF page; the
  companion markdown transcription is corrupt.
- `ExistsForallFormula.lean`: the Def 3.1 object, `UnaryType`, `unaryHolds`.
- `Separation/KampTranslation.lean`: `nf_depth0_char_formula`, `atom_literal`, `temporal_truth`.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## 1. Arity-1 atom classification -/

/-- At arity 1 every atom is a predicate atom applied to the single variable: `Fin 1` carries no
distinct pair, so no order atom exists. -/
private theorem atomKind1_is_pred {sig : MonadicSignature} (a : AtomKind sig 1) :
    ∃ p : sig.preds, a = AtomKind.pred p ⟨0, by omega⟩ := by
  cases a with
  | pred p i =>
    refine ⟨p, ?_⟩
    have : i = (⟨0, by omega⟩ : Fin 1) := Subsingleton.elim _ _
    rw [this]
  | order i j h =>
    exact absurd (Subsingleton.elim i j) h

/-! ## 2. Rendering a unary type as a temporal-logic formula -/

/-- The temporal-logic formula rendering a unary type `τ` over the E[Σ] alphabet: the conjunction
of atom literals asserting, for every E[Σ] predicate, whether it holds at the point according to
`τ`. Reuses the signature-generic depth-0 characteristic formula at signature `sigE sig F`. -/
noncomputable def unaryToFormula {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) : Formula :=
  nf_depth0_char_formula atomMap h_surj τ

/-- **Prop 3.5 atomic layer.** The rendered unary formula holds at `t` (under temporal truth) iff
the unary type `τ` is realized at `t`. The correctness of the signature-generic depth-0
characteristic formula bridges predicate agreement to full atom agreement via the arity-1 atom
classification. -/
theorem unaryToFormula_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) (t : N.carrier) :
    temporal_truth N atomMap t (unaryToFormula atomMap h_surj τ) ↔ unaryHolds N τ t := by
  rw [unaryToFormula, nf_depth0_char_formula_correct]
  unfold unaryHolds
  simp only [nf_eval_nf]
  constructor
  · intro h_preds a
    obtain ⟨p, rfl⟩ := atomKind1_is_pred a
    simpa [atom_eval] using h_preds p
  · intro h_atoms p
    have h := h_atoms (.pred p ⟨0, by omega⟩)
    simpa [atom_eval] using h

end Bimodal.Metalogic.WeakCanonical

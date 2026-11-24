/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragments.Calculus

/-!
# Conservativity by translation

The argument for a conservativity edge, stated once. Let `L` be a sublanguage and `tr` a map on
formulas that commutes with `⊥` and implication. Suppose

1. the translation of every axiom instance admissible at `fc` is derivable inside `L`;
2. derivability inside `L` of `tr φ` gives that of `tr (□φ)`, of `tr (Gφ)` and of the translation
   of the time reflection of `φ`;
3. `tr` is the identity on `L`.

Then every formula of `L` that TM derives at `fc` is derivable inside `L`. The proof is one
induction on the derivation: (1) and (2) carry the translation through the axioms and the three
rules for theorems, the commutation with implication carries it through modus ponens, and (3)
removes the translation at the end.

The translation is a semantic bridge read on formulas: it sends a formula of the larger language
to what it says in a model where the added operators are trivial.

## Main statements

* `conservative_of_translation`: the parametric theorem.
-/

namespace FormalSystem.Metalogic.Conservativity.Fragments

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- The translation of every closed derivation of the full system is derivable inside the
sublanguage, under hypotheses (1) and (2) of `conservative_of_translation`. -/
theorem cellDerivable_translation {L : Formula → Prop} (hL : Sublanguage L) {fc : FrameClass}
    (tr : Formula → Formula) (tr_imp : ∀ φ ψ : Formula, tr (φ.imp ψ) = (tr φ).imp (tr ψ))
    (h_ax : ∀ (φ : Formula) (h : Axiom φ), h.minFrameClass ≤ fc → CellDerivable L fc [] (tr φ))
    (h_nec : ∀ φ : Formula, CellDerivable L fc [] (tr φ) → CellDerivable L fc [] (tr φ.box))
    (h_tnec : ∀ φ : Formula, CellDerivable L fc [] (tr φ) →
      CellDerivable L fc [] (tr φ.allFuture))
    (h_refl : ∀ φ : Formula, CellDerivable L fc [] (tr φ) →
      CellDerivable L fc [] (tr φ.reflectTime))
    {Γ : Context} {φ : Formula} (d : DerivationTree fc Γ φ) (hΓ : Γ = []) :
    CellDerivable L fc [] (tr φ) := by
  induction d with
  | «axiom» Γ φ h hfc => exact h_ax φ h hfc
  | assumption Γ φ h => subst hΓ; cases h
  | modus_ponens Γ φ ψ _ _ ih1 ih2 =>
    have h1 := ih1 hΓ
    rw [tr_imp] at h1
    exact CellDerivable.mp hL h1 (ih2 hΓ)
  | necessitation φ _ ih => exact h_nec φ (ih rfl)
  | temporal_necessitation φ _ ih => exact h_tnec φ (ih rfl)
  | time_reflection φ _ ih => exact h_refl φ (ih rfl)
  | weakening Γ Δ φ _ h ih =>
    subst hΓ
    exact ih (List.subset_nil.mp h)

/-- **Conservativity by translation.** If a map `tr` on formulas commutes with implication, sends
every axiom instance admissible at `fc` to a formula derivable inside the sublanguage `L`,
preserves derivability inside `L` under the three rules for theorems, and is the identity on
`L`, then every formula of `L` with a closed derivation of the full system at `fc` is derivable
inside `L`.

Paper: — (the formalization's own; the translation argument for a conservative extension). -/
theorem conservative_of_translation {L : Formula → Prop} (hL : Sublanguage L) {fc : FrameClass}
    (tr : Formula → Formula) (tr_imp : ∀ φ ψ : Formula, tr (φ.imp ψ) = (tr φ).imp (tr ψ))
    (h_ax : ∀ (φ : Formula) (h : Axiom φ), h.minFrameClass ≤ fc → CellDerivable L fc [] (tr φ))
    (h_nec : ∀ φ : Formula, CellDerivable L fc [] (tr φ) → CellDerivable L fc [] (tr φ.box))
    (h_tnec : ∀ φ : Formula, CellDerivable L fc [] (tr φ) →
      CellDerivable L fc [] (tr φ.allFuture))
    (h_refl : ∀ φ : Formula, CellDerivable L fc [] (tr φ) →
      CellDerivable L fc [] (tr φ.reflectTime))
    (h_fix : ∀ φ : Formula, L φ → tr φ = φ)
    {φ : Formula} (hφ : L φ) (h : Nonempty (DerivationTree fc [] φ)) :
    CellDerivable L fc [] φ := by
  obtain ⟨d⟩ := h
  have := cellDerivable_translation hL tr tr_imp h_ax h_nec h_tnec h_refl d rfl
  rwa [h_fix φ hφ] at this

end FormalSystem.Metalogic.Conservativity.Fragments

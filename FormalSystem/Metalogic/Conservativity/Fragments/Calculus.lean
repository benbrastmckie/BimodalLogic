/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation

/-!
# The calculus of a sublanguage

A fragment of the language `L` has no proof system of its own. Its logic is the part of TM that
stays inside it: the axiom instances and rule applications all of whose formulas lie in the
fragment. This module states that as a calculus.

A **sublanguage** is a set of formulas `L` that contains `⊥`, contains an implication exactly
when it contains both parts, and is closed under time reflection. `CellDerivable L fc Γ φ` holds
when `φ` has a derivation from `Γ`, by the axioms admissible at `fc` and the seven rules of TM,
in which every derived formula lies in `L`.

The relation is `Prop`-valued, so its deduction theorem is a plain induction on the derivation.

## Main definitions

* `Sublanguage`: the closure conditions on a set of formulas.
* `CellDerivable`: derivability inside a sublanguage.

## Main statements

* `CellDerivable.mem`: every derived formula lies in the sublanguage.
* `CellDerivable.mono`: a larger sublanguage derives at least as much.
* `CellDerivable.toDerivationTree`: a derivation inside a sublanguage is a derivation of TM.
* `CellDerivable.deduction`: the deduction theorem inside a sublanguage.
-/

namespace FormalSystem.Metalogic.Conservativity.Fragments

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- The closure conditions on a set of formulas that make it a sublanguage: it contains `⊥`, it
contains an implication exactly when it contains both parts, and it is closed under time
reflection. -/
structure Sublanguage (L : Formula → Prop) : Prop where
  /-- Falsum is in the sublanguage. -/
  bot : L Formula.bot
  /-- An implication is in the sublanguage exactly when both parts are. -/
  imp_iff : ∀ φ ψ : Formula, L (φ.imp ψ) ↔ L φ ∧ L ψ
  /-- The sublanguage is closed under time reflection. -/
  reflectTime : ∀ φ : Formula, L φ → L φ.reflectTime

/-- A sublanguage is closed under implication. -/
theorem Sublanguage.imp {L : Formula → Prop} (hL : Sublanguage L) {φ ψ : Formula}
    (hφ : L φ) (hψ : L ψ) : L (φ.imp ψ) :=
  (hL.imp_iff φ ψ).mpr ⟨hφ, hψ⟩

/-- A sublanguage is closed under negation. -/
theorem Sublanguage.neg {L : Formula → Prop} (hL : Sublanguage L) {φ : Formula}
    (hφ : L φ) : L φ.neg :=
  hL.imp hφ hL.bot

/-- Derivability inside a sublanguage `L` at the frame class `fc`: the rules are those of
`DerivationTree`, and each requires its conclusion to lie in `L`. Weakening needs no side
condition, because its conclusion is the conclusion of its premise. -/
inductive CellDerivable (L : Formula → Prop) (fc : FrameClass) : Context → Formula → Prop where
  /-- An axiom instance admissible at `fc` that lies in `L`. -/
  | ax (Γ : Context) (φ : Formula) (h : Axiom φ) (hfc : h.minFrameClass ≤ fc) (hL : L φ) :
      CellDerivable L fc Γ φ
  /-- A formula of the context that lies in `L`. -/
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) (hL : L φ) : CellDerivable L fc Γ φ
  /-- Modus ponens, with the conclusion in `L`. -/
  | modusPonens (Γ : Context) (φ ψ : Formula) (d1 : CellDerivable L fc Γ (φ.imp ψ))
      (d2 : CellDerivable L fc Γ φ) (hL : L ψ) : CellDerivable L fc Γ ψ
  /-- Necessitation, from the empty context, with the conclusion in `L`. -/
  | necessitation (φ : Formula) (d : CellDerivable L fc [] φ) (hL : L φ.box) :
      CellDerivable L fc [] φ.box
  /-- Temporal necessitation, from the empty context, with the conclusion in `L`. -/
  | temporalNecessitation (φ : Formula) (d : CellDerivable L fc [] φ) (hL : L φ.allFuture) :
      CellDerivable L fc [] φ.allFuture
  /-- Time reflection, from the empty context, with the conclusion in `L`. -/
  | timeReflection (φ : Formula) (d : CellDerivable L fc [] φ) (hL : L φ.reflectTime) :
      CellDerivable L fc [] φ.reflectTime
  /-- Weakening of the context. -/
  | weakening (Γ Δ : Context) (φ : Formula) (d : CellDerivable L fc Γ φ) (h : Γ ⊆ Δ) :
      CellDerivable L fc Δ φ

namespace CellDerivable

variable {L L' : Formula → Prop} {fc : FrameClass} {Γ Δ : Context} {φ ψ : Formula}

/-- Every formula derived inside a sublanguage lies in it. -/
theorem mem (d : CellDerivable L fc Γ φ) : L φ := by
  induction d with
  | ax _ _ _ _ hL => exact hL
  | assumption _ _ _ hL => exact hL
  | modusPonens _ _ _ _ _ hL => exact hL
  | necessitation _ _ hL => exact hL
  | temporalNecessitation _ _ hL => exact hL
  | timeReflection _ _ hL => exact hL
  | weakening _ _ _ _ _ ih => exact ih

/-- A larger set of formulas derives at least as much. -/
theorem mono (h : ∀ φ, L φ → L' φ) (d : CellDerivable L fc Γ φ) : CellDerivable L' fc Γ φ := by
  induction d with
  | ax Γ φ a hfc hL => exact .ax Γ φ a hfc (h _ hL)
  | assumption Γ φ hm hL => exact .assumption Γ φ hm (h _ hL)
  | modusPonens Γ φ ψ _ _ hL ih1 ih2 => exact .modusPonens Γ φ ψ ih1 ih2 (h _ hL)
  | necessitation φ _ hL ih => exact .necessitation φ ih (h _ hL)
  | temporalNecessitation φ _ hL ih => exact .temporalNecessitation φ ih (h _ hL)
  | timeReflection φ _ hL ih => exact .timeReflection φ ih (h _ hL)
  | weakening Γ Δ φ _ hsub ih => exact .weakening Γ Δ φ ih hsub

/-- Weakening of the context, with the derivation as the last argument. -/
theorem weaken (h : Γ ⊆ Δ) (d : CellDerivable L fc Γ φ) : CellDerivable L fc Δ φ :=
  .weakening Γ Δ φ d h

/-- A derivation inside a sublanguage is a derivation of the full system. -/
theorem toDerivationTree (d : CellDerivable L fc Γ φ) : Nonempty (DerivationTree fc Γ φ) := by
  induction d with
  | ax Γ φ a hfc _ => exact ⟨.axiom Γ φ a hfc⟩
  | assumption Γ φ hm _ => exact ⟨.assumption Γ φ hm⟩
  | modusPonens Γ φ ψ _ _ _ ih1 ih2 =>
    obtain ⟨d1⟩ := ih1
    obtain ⟨d2⟩ := ih2
    exact ⟨.modus_ponens Γ φ ψ d1 d2⟩
  | necessitation φ _ _ ih =>
    obtain ⟨d⟩ := ih
    exact ⟨.necessitation φ d⟩
  | temporalNecessitation φ _ _ ih =>
    obtain ⟨d⟩ := ih
    exact ⟨.temporal_necessitation φ d⟩
  | timeReflection φ _ _ ih =>
    obtain ⟨d⟩ := ih
    exact ⟨.time_reflection φ d⟩
  | weakening Γ Δ φ _ hsub ih =>
    obtain ⟨d⟩ := ih
    exact ⟨.weakening Γ Δ φ d hsub⟩

/-- Modus ponens inside a sublanguage; the conclusion lies in it because the implication does. -/
theorem mp (hL : Sublanguage L) (d1 : CellDerivable L fc Γ (φ.imp ψ))
    (d2 : CellDerivable L fc Γ φ) : CellDerivable L fc Γ ψ :=
  .modusPonens Γ φ ψ d1 d2 ((hL.imp_iff φ ψ).mp d1.mem).2

/-- A formula of the context that lies in the sublanguage is derivable. -/
theorem assume (h : φ ∈ Γ) (hφ : L φ) : CellDerivable L fc Γ φ :=
  .assumption Γ φ h hφ

/-- A derivable formula is derivable under any hypothesis of the sublanguage. -/
theorem imp_intro_const (hL : Sublanguage L) (d : CellDerivable L fc Γ φ) (hψ : L ψ) :
    CellDerivable L fc Γ (ψ.imp φ) :=
  mp hL (.ax Γ _ (Axiom.prop_s φ ψ) (FrameClass.base_le fc) (hL.imp d.mem (hL.imp hψ d.mem))) d

/-- The general form of the deduction theorem: a derivation from any context included in
`A :: Γ` gives a derivation of the implication from `Γ`. Stating it over an arbitrary included
context makes the weakening case an instance of the induction hypothesis. -/
theorem deduction_of_subset (hL : Sublanguage L) {A : Formula} (hA : L A)
    (d : CellDerivable L fc Δ φ) : ∀ {Γ : Context}, Δ ⊆ A :: Γ →
    CellDerivable L fc Γ (A.imp φ) := by
  induction d with
  | ax Δ φ a hfc hφ =>
    intro Γ _
    exact imp_intro_const hL (.ax Γ φ a hfc hφ) hA
  | assumption Δ φ hm hφ =>
    intro Γ hsub
    rcases List.mem_cons.mp (hsub hm) with rfl | hmem
    · have h1 : CellDerivable L fc Γ (φ.imp ((φ.imp φ).imp φ)) :=
        .ax Γ _ (Axiom.prop_s φ (φ.imp φ)) (FrameClass.base_le fc)
          (hL.imp hφ (hL.imp (hL.imp hφ hφ) hφ))
      have h2 : CellDerivable L fc Γ (φ.imp (φ.imp φ)) :=
        .ax Γ _ (Axiom.prop_s φ φ) (FrameClass.base_le fc) (hL.imp hφ (hL.imp hφ hφ))
      have h3 : CellDerivable L fc Γ
          ((φ.imp ((φ.imp φ).imp φ)).imp ((φ.imp (φ.imp φ)).imp (φ.imp φ))) :=
        .ax Γ _ (Axiom.prop_k φ (φ.imp φ) φ) (FrameClass.base_le fc)
          (hL.imp h1.mem (hL.imp h2.mem (hL.imp hφ hφ)))
      exact mp hL (mp hL h3 h1) h2
    · exact imp_intro_const hL (.assumption Γ φ hmem hφ) hA
  | modusPonens Δ φ ψ d1 _ hψ ih1 ih2 =>
    intro Γ hsub
    have hφ : L φ := ((hL.imp_iff φ ψ).mp d1.mem).1
    have hk : CellDerivable L fc Γ ((A.imp (φ.imp ψ)).imp ((A.imp φ).imp (A.imp ψ))) :=
      .ax Γ _ (Axiom.prop_k A φ ψ) (FrameClass.base_le fc)
        (hL.imp (hL.imp hA d1.mem) (hL.imp (hL.imp hA hφ) (hL.imp hA hψ)))
    exact mp hL (mp hL hk (ih1 hsub)) (ih2 hsub)
  | necessitation φ d hφ _ =>
    intro Γ _
    exact imp_intro_const hL (weaken (List.nil_subset Γ) (.necessitation φ d hφ)) hA
  | temporalNecessitation φ d hφ _ =>
    intro Γ _
    exact imp_intro_const hL (weaken (List.nil_subset Γ) (.temporalNecessitation φ d hφ)) hA
  | timeReflection φ d hφ _ =>
    intro Γ _
    exact imp_intro_const hL (weaken (List.nil_subset Γ) (.timeReflection φ d hφ)) hA
  | weakening Δ' Δ φ _ hsub' ih =>
    intro Γ hsub
    exact ih (fun _ hx => hsub (hsub' hx))

/-- The deduction theorem inside a sublanguage: a derivation of `φ` from `A :: Γ` gives a
derivation of `A → φ` from `Γ`, when `A` lies in the sublanguage. -/
theorem deduction (hL : Sublanguage L) {A : Formula} (hA : L A)
    (d : CellDerivable L fc (A :: Γ) φ) : CellDerivable L fc Γ (A.imp φ) :=
  deduction_of_subset hL hA d (List.Subset.refl _)

end CellDerivable

end FormalSystem.Metalogic.Conservativity.Fragments

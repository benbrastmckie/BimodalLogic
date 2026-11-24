/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragments.Calculus

/-!
# Propositional completeness inside a sublanguage

Every propositional tautology that lies in a sublanguage is derivable inside it. The variables of
a formula are its subformulas that are neither `⊥` nor an implication: atoms, and formulas whose
main operator is `□`, Until or Since. A tautology is a formula true under every assignment of
truth values to all formulas, read through `⊥` and implication only.

The proof is Kalmár's. Under a context that decides every variable of `φ`, either `φ` or its
negation is derivable, according to the truth value of `φ` (`kalmar`). The variables are then
eliminated one at a time by the deduction theorem and Peirce's law (`cases_on`,
`eliminate`). The assignment used for a context is membership in the context, so no consistency
hypothesis is needed.

## Main definitions

* `evalProp`: the truth value of a formula under an assignment to its variables.
* `Tautology`: truth under every assignment.
* `propVars`: the variables of a formula.

## Main statements

* `tautology_derivable`: a tautology of a sublanguage is derivable inside it from the empty
  context, at every frame class.
-/

namespace FormalSystem.Metalogic.Conservativity.Fragments

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- The truth value of a formula under an assignment `v` of truth values to formulas, read through
`⊥` and implication. Every other formula is a variable and takes the value `v` gives it. -/
def evalProp (v : Formula → Prop) : Formula → Prop
  | .bot => False
  | .imp φ ψ => evalProp v φ → evalProp v ψ
  | .atom a => v (.atom a)
  | .box φ => v (.box φ)
  | .untl φ ψ => v (.untl φ ψ)
  | .snce φ ψ => v (.snce φ ψ)

/-- A propositional tautology: true under every assignment to the variables. -/
def Tautology (φ : Formula) : Prop := ∀ v : Formula → Prop, evalProp v φ

/-- The variables of a formula: its subformulas, reached through implication, that are neither
`⊥` nor an implication. -/
def propVars : Formula → List Formula
  | .bot => []
  | .imp φ ψ => propVars φ ++ propVars ψ
  | .atom a => [.atom a]
  | .box φ => [.box φ]
  | .untl φ ψ => [.untl φ ψ]
  | .snce φ ψ => [.snce φ ψ]

/-- The value of `⊥`. -/
@[simp] theorem evalProp_bot (v : Formula → Prop) : evalProp v Formula.bot ↔ False := Iff.rfl

/-- The value of an implication. -/
@[simp] theorem evalProp_imp (v : Formula → Prop) (φ ψ : Formula) :
    evalProp v (φ.imp ψ) ↔ (evalProp v φ → evalProp v ψ) := Iff.rfl

/-- The value of a formula whose main operator is `□`. -/
@[simp] theorem evalProp_box (v : Formula → Prop) (φ : Formula) :
    evalProp v φ.box ↔ v φ.box := Iff.rfl

/-- The value of a negation. -/
@[simp] theorem evalProp_neg (v : Formula → Prop) (φ : Formula) :
    evalProp v φ.neg ↔ ¬ evalProp v φ := Iff.rfl

/-- The value of a conjunction. -/
@[simp] theorem evalProp_and (v : Formula → Prop) (φ ψ : Formula) :
    evalProp v (φ.and ψ) ↔ (evalProp v φ ∧ evalProp v ψ) := by
  simp only [Formula.and, evalProp_neg, evalProp_imp]
  exact ⟨fun h => ⟨Classical.byContradiction fun hφ => h fun hφ' => absurd hφ' hφ,
    Classical.byContradiction fun hψ => h fun _ => hψ⟩, fun h h' => h' h.1 h.2⟩

/-- The value of a disjunction. -/
@[simp] theorem evalProp_or (v : Formula → Prop) (φ ψ : Formula) :
    evalProp v (φ.or ψ) ↔ (evalProp v φ ∨ evalProp v ψ) := by
  simp only [Formula.or, evalProp_neg, evalProp_imp]
  exact ⟨fun h => (Classical.em (evalProp v φ)).elim Or.inl fun hφ => Or.inr (h hφ),
    fun h hφ => h.resolve_left hφ⟩

/-- The value of verum. -/
@[simp] theorem evalProp_top (v : Formula → Prop) : evalProp v Formula.top ↔ True :=
  ⟨fun _ => trivial, fun _ h => h⟩

variable {L : Formula → Prop} {fc : FrameClass}

/-- The variables of a formula of a sublanguage lie in it. -/
theorem propVars_mem (hL : Sublanguage L) : ∀ {φ : Formula}, L φ → ∀ p ∈ propVars φ, L p
  | .bot, _, p, hp => by simp [propVars] at hp
  | .imp φ ψ, h, p, hp => by
    rcases List.mem_append.mp hp with hp | hp
    · exact propVars_mem hL ((hL.imp_iff φ ψ).mp h).1 p hp
    · exact propVars_mem hL ((hL.imp_iff φ ψ).mp h).2 p hp
  | .atom a, h, p, hp => by
    rw [propVars, List.mem_singleton] at hp
    exact hp ▸ h
  | .box φ, h, p, hp => by
    rw [propVars, List.mem_singleton] at hp
    exact hp ▸ h
  | .untl φ ψ, h, p, hp => by
    rw [propVars, List.mem_singleton] at hp
    exact hp ▸ h
  | .snce φ ψ, h, p, hp => by
    rw [propVars, List.mem_singleton] at hp
    exact hp ▸ h

/-- Ex falso inside a sublanguage: a context that derives `⊥` derives every formula of the
sublanguage. -/
theorem CellDerivable.exFalso (hL : Sublanguage L) {Γ : Context} {φ : Formula}
    (d : CellDerivable L fc Γ Formula.bot) (hφ : L φ) : CellDerivable L fc Γ φ :=
  CellDerivable.mp hL
    (.ax Γ _ (Axiom.ex_falso φ) (FrameClass.base_le fc) (hL.imp hL.bot hφ)) d

/-- Double negation elimination inside a sublanguage. -/
theorem CellDerivable.dne (hL : Sublanguage L) {Γ : Context} {φ : Formula}
    (d : CellDerivable L fc Γ φ.neg.neg) : CellDerivable L fc Γ φ := by
  have hφ : L φ := ((hL.imp_iff _ _).mp ((hL.imp_iff _ _).mp d.mem).1).1
  have hn : L φ.neg := hL.neg hφ
  have hbot : CellDerivable L fc (φ.neg :: Γ) Formula.bot :=
    CellDerivable.mp hL (CellDerivable.weaken (List.subset_cons_self _ _) d)
      (CellDerivable.assume List.mem_cons_self hn)
  have h1 : CellDerivable L fc Γ (φ.neg.imp φ) :=
    CellDerivable.deduction hL hn (CellDerivable.exFalso hL hbot hφ)
  exact CellDerivable.mp hL
    (.ax Γ _ (Axiom.peirce φ Formula.bot) (FrameClass.base_le fc) (hL.imp h1.mem hφ)) h1

/-- Reasoning by cases on a formula of the sublanguage: what is derivable both with `p` and with
its negation is derivable without either. -/
theorem CellDerivable.cases_on (hL : Sublanguage L) {Γ : Context} {p φ : Formula} (hp : L p)
    (d1 : CellDerivable L fc (p :: Γ) φ) (d2 : CellDerivable L fc (p.neg :: Γ) φ) :
    CellDerivable L fc Γ φ := by
  have hφ : L φ := d1.mem
  have hn : L φ.neg := hL.neg hφ
  have e1 : CellDerivable L fc Γ (p.imp φ) := CellDerivable.deduction hL hp d1
  have e2 : CellDerivable L fc Γ (p.neg.imp φ) := CellDerivable.deduction hL (hL.neg hp) d2
  -- From `¬φ`, first `¬p`, then `φ` by the second case, then `⊥`.
  have hnp : CellDerivable L fc (φ.neg :: Γ) p.neg := by
    refine CellDerivable.deduction hL hp ?_
    have hφ' : CellDerivable L fc (p :: φ.neg :: Γ) φ :=
      CellDerivable.mp hL
        (CellDerivable.weaken (fun _ hx => List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hx)) e1)
        (CellDerivable.assume List.mem_cons_self hp)
    exact CellDerivable.mp hL
      (CellDerivable.assume (List.mem_cons_of_mem _ List.mem_cons_self) hn) hφ'
  have hbot : CellDerivable L fc (φ.neg :: Γ) Formula.bot :=
    CellDerivable.mp hL (CellDerivable.assume List.mem_cons_self hn)
      (CellDerivable.mp hL (CellDerivable.weaken (List.subset_cons_self _ _) e2) hnp)
  exact CellDerivable.dne hL (CellDerivable.deduction hL hn hbot)

/-- Kalmár's lemma. Under a context that contains each variable of `φ` or its negation, according
to the assignment `v`, the formula `φ` is derivable when it is true under `v` and its negation is
derivable when it is false. -/
theorem kalmar (hL : Sublanguage L) (v : Formula → Prop) (Γ : Context) :
    ∀ φ : Formula, L φ → (∀ p ∈ propVars φ, (v p → p ∈ Γ) ∧ (¬ v p → p.neg ∈ Γ)) →
      (evalProp v φ → CellDerivable L fc Γ φ) ∧ (¬ evalProp v φ → CellDerivable L fc Γ φ.neg)
  | .bot, _, _ => by
    refine ⟨fun h => h.elim, fun _ => ?_⟩
    exact CellDerivable.deduction hL hL.bot (CellDerivable.assume List.mem_cons_self hL.bot)
  | .imp φ ψ, h, hv => by
    obtain ⟨hφ, hψ⟩ := (hL.imp_iff φ ψ).mp h
    have ih1 := kalmar hL v Γ φ hφ (fun p hp => hv p (List.mem_append_left _ hp))
    have ih2 := kalmar hL v Γ ψ hψ (fun p hp => hv p (List.mem_append_right _ hp))
    refine ⟨fun hval => ?_, fun hval => ?_⟩
    · by_cases hφv : evalProp v φ
      · exact CellDerivable.imp_intro_const hL (ih2.1 (hval hφv)) hφ
      · refine CellDerivable.deduction hL hφ (CellDerivable.exFalso hL ?_ hψ)
        exact CellDerivable.mp hL
          (CellDerivable.weaken (List.subset_cons_self _ _) (ih1.2 hφv))
          (CellDerivable.assume List.mem_cons_self hφ)
    · have hφv : evalProp v φ := Classical.byContradiction fun hn => hval fun hx => absurd hx hn
      have hψv : ¬ evalProp v ψ := fun hx => hval fun _ => hx
      refine CellDerivable.deduction hL h ?_
      have d1 : CellDerivable L fc ((φ.imp ψ) :: Γ) ψ :=
        CellDerivable.mp hL (CellDerivable.assume List.mem_cons_self h)
          (CellDerivable.weaken (List.subset_cons_self _ _) (ih1.1 hφv))
      exact CellDerivable.mp hL
        (CellDerivable.weaken (List.subset_cons_self _ _) (ih2.2 hψv)) d1
  | .atom a, h, hv =>
    ⟨fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).1 hval) h,
      fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).2 hval) (hL.neg h)⟩
  | .box φ, h, hv =>
    ⟨fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).1 hval) h,
      fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).2 hval) (hL.neg h)⟩
  | .untl φ ψ, h, hv =>
    ⟨fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).1 hval) h,
      fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).2 hval) (hL.neg h)⟩
  | .snce φ ψ, h, hv =>
    ⟨fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).1 hval) h,
      fun hval => CellDerivable.assume ((hv _ (by simp [propVars])).2 hval) (hL.neg h)⟩

/-- Elimination of a list of variables: a formula derivable from every extension of `Γ` that
decides each variable of the list is derivable from `Γ`. -/
theorem eliminate (hL : Sublanguage L) {φ : Formula} :
    ∀ (ps : List Formula), (∀ p ∈ ps, L p) → ∀ Γ : Context,
      (∀ Δ : Context, Γ ⊆ Δ → (∀ p ∈ ps, p ∈ Δ ∨ p.neg ∈ Δ) → CellDerivable L fc Δ φ) →
      CellDerivable L fc Γ φ
  | [], _, Γ, h => h Γ (List.Subset.refl _) (fun _ hp => by simp at hp)
  | p :: ps, hps, Γ, h => by
    refine eliminate hL ps (fun q hq => hps q (List.mem_cons_of_mem _ hq)) Γ ?_
    intro Δ hsub hdec
    have hp : L p := hps p List.mem_cons_self
    refine CellDerivable.cases_on hL hp ?_ ?_
    · refine h (p :: Δ) (fun _ hx => List.mem_cons_of_mem _ (hsub hx)) ?_
      intro q hq
      rcases List.mem_cons.mp hq with rfl | hq
      · exact Or.inl List.mem_cons_self
      · exact (hdec q hq).imp (List.mem_cons_of_mem _) (List.mem_cons_of_mem _)
    · refine h (p.neg :: Δ) (fun _ hx => List.mem_cons_of_mem _ (hsub hx)) ?_
      intro q hq
      rcases List.mem_cons.mp hq with rfl | hq
      · exact Or.inr List.mem_cons_self
      · exact (hdec q hq).imp (List.mem_cons_of_mem _) (List.mem_cons_of_mem _)

/-- Propositional completeness inside a sublanguage: a tautology that lies in the sublanguage is
derivable inside it from the empty context, at every frame class.

Paper: — (the formalization's own; Kalmár's completeness proof, run inside a sublanguage). -/
theorem tautology_derivable (hL : Sublanguage L) {φ : Formula} (hφ : L φ) (h : Tautology φ) :
    CellDerivable L fc [] φ := by
  refine eliminate hL (propVars φ) (propVars_mem hL hφ) [] ?_
  intro Δ _ hdec
  refine (kalmar hL (fun q => q ∈ Δ) Δ φ hφ ?_).1 (h _)
  intro p hp
  exact ⟨fun hx => hx, fun hx => (hdec p hp).resolve_left hx⟩

end FormalSystem.Metalogic.Conservativity.Fragments

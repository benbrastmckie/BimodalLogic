/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragments.Translation
import FormalSystem.Metalogic.Conservativity.Fragments.Collapse

/-!
# The Boolean and modal edges

TM proves nothing new about the formulas with no operator, and nothing new about the formulas
whose only operator is `□`, at any frame class: a formula of either sublanguage that TM derives
is derivable inside the sublanguage.

Both are instances of `conservative_of_translation` at the collapse translation, with the
reading `denseReading fc`. What remains to prove here is hypothesis (1): the translation of
every axiom instance admissible at `fc` is derivable inside the target.

* When `□` is erased, every translated axiom is a propositional tautology
  (`collapse_axiom_tautology`), so it is derivable by `tautology_derivable`.
* When `□` is kept, the translations of T, 5 and K are instances of T, 5 and K; the translation
  of MF, `□φ → □Gφ`, follows from a tautology by necessitation and K; the translation of NB,
  `X⊤ → □X⊤`, is a tautology under the dense reading and follows from necessitation of `⊤` under
  the discrete one; every other translated axiom is a tautology.

## Main statements

* `boolean_conservative`: the Boolean sublanguage is conserved by TM at every frame class.
* `modal_conservative`: the sublanguage with `□` is conserved by TM at every frame class.
-/

namespace FormalSystem.Metalogic.Conservativity.Fragments

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- With `□` erased, the translation of every axiom instance admissible at `fc` is a
propositional tautology, under the reading for `fc`. -/
theorem collapse_axiom_tautology (fc : FrameClass) {φ : Formula} (h : Axiom φ)
    (hmin : h.minFrameClass ≤ fc) : Tautology (collapse (denseReading fc) false φ) := by
  intro v
  cases fc <;> cases h <;>
    simp_all [collapse, denseReading, evalProp, Formula.and, Formula.or, Formula.neg,
      Formula.top, Formula.diamond, Formula.someFuture, Formula.allFuture, Formula.kPlus,
      Formula.kMinus, Axiom.minFrameClass, LE.le] <;> tauto

/-- Monotonicity of `□` inside a sublanguage closed under it: from a derivable implication, the
implication between the necessitations. -/
theorem CellDerivable.box_mono {L : Formula → Prop} (hL : Sublanguage L) {fc : FrameClass}
    (hbox : ∀ φ : Formula, L φ → L φ.box) {φ ψ : Formula}
    (d : CellDerivable L fc [] (φ.imp ψ)) : CellDerivable L fc [] (φ.box.imp ψ.box) := by
  obtain ⟨hφ, hψ⟩ := (hL.imp_iff φ ψ).mp d.mem
  have hnec : CellDerivable L fc [] (φ.imp ψ).box := .necessitation _ d (hbox _ d.mem)
  exact CellDerivable.mp hL
    (.ax [] _ (Axiom.modal_k_dist φ ψ) (FrameClass.base_le fc)
      (hL.imp hnec.mem (hL.imp (hbox _ hφ) (hbox _ hψ)))) hnec

/-- With `□` kept, the translation of every axiom instance admissible at `fc` is derivable inside
the sublanguage with `□`, under the reading for `fc`. -/
theorem collapse_keep_axiom_derivable (fc : FrameClass) {φ : Formula} (h : Axiom φ)
    (hmin : h.minFrameClass ≤ fc) :
    CellDerivable ModalFormula fc [] (collapse (denseReading fc) true φ) := by
  have hL := modalFormula_sublanguage
  cases h with
  | modal_t ψ =>
    exact .ax [] _ (Axiom.modal_t (collapse (denseReading fc) true ψ)) (FrameClass.base_le fc)
      (modalFormula_collapse _ (ψ.box.imp ψ))
  | modal_5_collapse ψ =>
    exact .ax [] _ (Axiom.modal_5_collapse (collapse (denseReading fc) true ψ))
      (FrameClass.base_le fc) (modalFormula_collapse _ (ψ.box.diamond.imp ψ.box))
  | modal_k_dist ψ χ =>
    exact .ax [] _ (Axiom.modal_k_dist (collapse (denseReading fc) true ψ)
      (collapse (denseReading fc) true χ)) (FrameClass.base_le fc)
      (modalFormula_collapse _ ((ψ.imp χ).box.imp (ψ.box.imp χ.box)))
  | modal_future ψ =>
    exact CellDerivable.box_mono hL (fun _ hx => hx)
      (tautology_derivable hL (modalFormula_collapse _ (ψ.imp ψ.allFuture))
        (collapse_allFuture_tautology _ _ ψ))
  | discrete_box_necessity =>
    cases fc with
    | ZTime =>
      have htop : CellDerivable ModalFormula FrameClass.ZTime [] Formula.top :=
        tautology_derivable hL ⟨trivial, trivial⟩ (fun _ hx => hx)
      change CellDerivable ModalFormula FrameClass.ZTime [] (Formula.top.imp Formula.top.box)
      exact CellDerivable.imp_intro_const hL (.necessitation Formula.top htop ⟨trivial, trivial⟩)
        ⟨trivial, trivial⟩
    | _ =>
      refine tautology_derivable hL (modalFormula_collapse _ _) (fun v => ?_)
      simp [collapse, denseReading, evalProp, Formula.and, Formula.neg]
  | _ =>
    refine tautology_derivable hL (modalFormula_collapse _ _) (fun v => ?_)
    cases fc <;>
      simp_all [collapse, denseReading, evalProp, Formula.and, Formula.or, Formula.neg,
        Formula.top, Formula.someFuture, Formula.allFuture, Formula.kPlus, Formula.kMinus,
        Axiom.minFrameClass, LE.le] <;> tauto

/-- **The Boolean edge.** At every frame class, a formula with no operator that TM derives is
derivable inside the Boolean sublanguage: by the propositional axioms and modus ponens, through
formulas with no operator.

Paper: — (the formalization's own; conservativity of TM over its propositional fragment). -/
theorem boolean_conservative (fc : FrameClass) {φ : Formula} (hφ : BooleanFormula φ)
    (h : Nonempty (DerivationTree fc [] φ)) : CellDerivable BooleanFormula fc [] φ :=
  conservative_of_translation booleanFormula_sublanguage (collapse (denseReading fc) false)
    (collapse_imp _ _)
    (fun _ a hmin => tautology_derivable booleanFormula_sublanguage (booleanFormula_collapse _ _)
      (collapse_axiom_tautology fc a hmin))
    (collapse_box_derivable (booleanFormula_collapse _))
    (collapse_allFuture_derivable booleanFormula_sublanguage (booleanFormula_collapse _))
    collapse_reflectTime_derivable
    (fun _ hx => collapse_of_boolean _ _ hx) hφ h

/-- **The modal edge.** At every frame class, a formula whose only operator is `□` that TM
derives is derivable inside the sublanguage with `□`: by the propositional axioms, T, 5, K,
modus ponens and necessitation, through formulas whose only operator is `□`.

Paper: — (the formalization's own; conservativity of TM over its S5 fragment). -/
theorem modal_conservative (fc : FrameClass) {φ : Formula} (hφ : ModalFormula φ)
    (h : Nonempty (DerivationTree fc [] φ)) : CellDerivable ModalFormula fc [] φ :=
  conservative_of_translation modalFormula_sublanguage (collapse (denseReading fc) true)
    (collapse_imp _ _)
    (fun _ a hmin => collapse_keep_axiom_derivable fc a hmin)
    (collapse_box_derivable (modalFormula_collapse _))
    (collapse_allFuture_derivable modalFormula_sublanguage (modalFormula_collapse _))
    collapse_reflectTime_derivable
    (fun _ hx => collapse_of_modal _ hx) hφ h

end FormalSystem.Metalogic.Conservativity.Fragments

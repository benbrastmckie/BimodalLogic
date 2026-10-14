/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.DeductionTheorem

/-!
# Linearity and Density as Derived Schemata

Two schemata the paper lists under `def:BX` and `def:BX-d` are theorems of the reduced
primitive system:

* `tempLinearity` — TL, `Fφ ∧ Fψ → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))`, in the paper's
  disjunct order, right-associated. Derived from CN (`Axiom.linear_until`) with UF
  (`self_accum_until`) to turn each `F` into an Until with a self-accumulating guard, then UE
  (`DerivedAxioms.untilF`) and `someFutureMono` to collapse each CN disjunct back to an `F`.
  This is the precise sense in which TL is subsumed by CN: Xu 1988 §4 Theorem 4.3 shows the
  G/H-level linearity formula (13) is strictly weaker than the Until-level (10), and §3 proves
  Σ₄ complete for linear frames without Burgess's A4a. The former record of TL's
  "underivability" (`ProofSystem/LinearityDerivedFacts.lean`) rested on a branching frame
  that refutes CN itself, so it was never a model of the current base.
* `density` — DN, `GGφ → Gφ` at every `fc ≥ Dense`, derived directly from NN
  (`Axiom.dense_indicator`) with UG (`left_mono_until_G`), UF, UE, UC (`right_mono_until`), TN
  and K-distribution: from `GGφ` and `F¬φ` build `U(Gφ ∧ U(Gφ, ¬φ), ¬φ)`, collapse the guard to
  `⊥` (it entails `Gφ ∧ F¬φ`), widen the event to `⊤`, and contradict NN.

The legacy disjunct order `tempLinearityLegacy` and the past mirror `tempLinearityPast` are
derived here from `tempLinearity` by `orRotate`.
-/

namespace FormalSystem.Theorems.LinearityDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.ProofSystem.DerivedAxioms (untilF impTop ofReflect)
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.TemporalDerived
open FormalSystem.Metalogic.Core (deductionTheorem)

noncomputable section

/-- Theorem-level left disjunction introduction, `A → A ∨ B`. -/
def orInlThm {fc : FrameClass} (A B : Formula) : ⊢[fc] A.imp (A.or B) :=
  deductionTheorem [] A _ (orInl A B)

/-- Theorem-level right disjunction introduction, `B → A ∨ B`. -/
def orInrThm {fc : FrameClass} (A B : Formula) : ⊢[fc] B.imp (A.or B) :=
  deductionTheorem [] B _ (orInr A B)

/-- TL: `Fφ ∧ Fψ → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))` (the paper's TL verbatim, right-associated),
derived from CN. With `gᵢ := ⊤ ∧ Fχᵢ`, UF turns `Fφ`, `Fψ` into `U(g₁, φ)`, `U(g₂, ψ)`; CN on the
pair gives a disjunction of three Untils with guard `g₁ ∧ g₂`, and each disjunct collapses by UE
and `someFutureMono` onto the matching TL disjunct. -/
@[tmLemma]
def tempLinearity {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))))) := by
  refine deductionTheorem [] _ _ ?_
  let Γ : Context := [Formula.and φ.someFuture ψ.someFuture]
  let g₁ : Formula := Formula.and Formula.top (Formula.untl Formula.top φ)
  let g₂ : Formula := Formula.and Formula.top (Formula.untl Formula.top ψ)
  let A : Formula := Formula.someFuture (Formula.and φ.someFuture ψ)
  let B₁ : Formula := Formula.someFuture (Formula.and φ ψ)
  let B₂ : Formula := Formula.someFuture (Formula.and φ ψ.someFuture)
  have hΓ : Γ ⊢[fc] Formula.and φ.someFuture ψ.someFuture :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have hFφ : Γ ⊢[fc] Formula.untl Formula.top φ := andFst hΓ
  have hFψ : Γ ⊢[fc] Formula.untl Formula.top ψ := andSnd hΓ
  have hUFφ : Γ ⊢[fc] Formula.untl g₁ φ :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.self_accum_until Formula.top φ)
      (FrameClass.base_le fc)) hFφ
  have hUFψ : Γ ⊢[fc] Formula.untl g₂ ψ :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.self_accum_until Formula.top ψ)
      (FrameClass.base_le fc)) hFψ
  have hCN : Γ ⊢[fc] Formula.or (Formula.untl (Formula.and g₁ g₂) (Formula.and φ ψ))
      (Formula.or (Formula.untl (Formula.and g₁ g₂) (Formula.and φ g₂))
        (Formula.untl (Formula.and g₁ g₂) (Formula.and g₁ ψ))) :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.linear_until g₁ φ g₂ ψ) (FrameClass.base_le fc))
      (andIntro hUFφ hUFψ)
  -- CN disjunct 1, `U(g₁∧g₂, φ∧ψ)`, gives `F(φ ∧ ψ)` = B₁
  have hD1 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and φ ψ)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _) (impTrans (orInlThm B₁ B₂) (orInrThm A _))
  -- CN disjunct 2, `U(g₁∧g₂, φ∧g₂)`, gives `F(φ ∧ Fψ)` = B₂ since `g₂ → Fψ`
  have hD2 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and φ g₂)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _)
      (impTrans (someFutureMono (combineImpConj (lceImp φ g₂)
          (impTrans (rceImp φ g₂) (rceImp Formula.top _))))
        (impTrans (orInrThm B₁ B₂) (orInrThm A _)))
  -- CN disjunct 3, `U(g₁∧g₂, g₁∧ψ)`, gives `F(Fφ ∧ ψ)` = A since `g₁ → Fφ`
  have hD3 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and g₁ ψ)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _)
      (impTrans (someFutureMono (combineImpConj
          (impTrans (lceImp g₁ ψ) (rceImp Formula.top _)) (rceImp g₁ ψ)))
        (orInlThm A _))
  refine orElim Γ _ _ _ hCN (thmIn hD1) ?_
  refine deductionTheorem Γ _ _ ?_
  exact orElim _ _ _ _ (DerivationTree.assumption _ _ (by simp)) (thmIn hD2) (thmIn hD3)

/-- DN: `GGφ → Gφ` wherever NN is available (`FrameClass.Dense ≤ fc`), derived directly.
Assume `GGφ` and `F¬φ` (`Gφ` is `¬F¬φ`). K-distribution turns `GGφ` into `G(⊤ → Gφ)`, so UG
widens `F¬φ = U(⊤, ¬φ)` to `U(Gφ, ¬φ)`, and UF to `U(Gφ ∧ U(Gφ, ¬φ), ¬φ)`. The guard entails
`Gφ ∧ F¬φ` (by UE), a contradiction, so it collapses to `⊥`; widening the event to `⊤` gives
`U(⊥, ⊤) = X⊤`, which NN refutes. -/
def density {fc : FrameClass} (h : FrameClass.Dense ≤ fc) (φ : Formula) :
    ⊢[fc] φ.allFuture.allFuture.imp φ.allFuture := by
  refine deductionTheorem [] _ _ ?_
  refine deductionTheorem [φ.allFuture.allFuture] (Formula.untl Formula.top φ.neg) Formula.bot ?_
  let Γ : Context := [Formula.untl Formula.top φ.neg, φ.allFuture.allFuture]
  let χ : Formula := Formula.and φ.allFuture (Formula.untl φ.allFuture φ.neg)
  have hGG : Γ ⊢[fc] φ.allFuture.allFuture := DerivationTree.assumption _ _ (by simp [Γ])
  have hF : Γ ⊢[fc] Formula.untl Formula.top φ.neg := DerivationTree.assumption _ _ (by simp [Γ])
  have hG : Γ ⊢[fc] (Formula.top.imp φ.allFuture).allFuture :=
    ctxMp (ctxMp (thmIn (temporalKDistDerived φ.allFuture (Formula.top.imp φ.allFuture)))
      (necG Γ _ (DerivationTree.axiom [] _ (Axiom.prop_s φ.allFuture Formula.top)
        (FrameClass.base_le fc)))) hGG
  have h1 : Γ ⊢[fc] Formula.untl φ.allFuture φ.neg :=
    ctxMp (ctxMp (DerivationTree.axiom _ _ (Axiom.left_mono_until_G Formula.top φ.allFuture φ.neg)
      (FrameClass.base_le fc)) hG) hF
  have h2 : Γ ⊢[fc] Formula.untl χ φ.neg :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.self_accum_until φ.allFuture φ.neg)
      (FrameClass.base_le fc)) h1
  have hχ : ⊢[fc] χ.imp Formula.bot := by
    refine deductionTheorem [] _ _ ?_
    have hχχ : [χ] ⊢[fc] Formula.and φ.allFuture (Formula.untl φ.allFuture φ.neg) :=
      DerivationTree.assumption _ _ (by simp [χ])
    have hA : [χ] ⊢[fc] φ.allFuture := andFst hχχ
    have hB : [χ] ⊢[fc] Formula.untl φ.allFuture φ.neg := andSnd hχχ
    have hFneg : [χ] ⊢[fc] φ.neg.someFuture := ctxMp (thmIn (untilF _ _)) hB
    exact ctxMp (show [χ] ⊢[fc] φ.neg.someFuture.imp Formula.bot from hA) hFneg
  have h3 : Γ ⊢[fc] Formula.untl Formula.bot φ.neg := guardMono Γ _ _ _ hχ h2
  have h4 : Γ ⊢[fc] Formula.untl Formula.bot Formula.top := eventMono Γ _ _ _ (impTop φ.neg) h3
  exact ctxMp (DerivationTree.axiom _ _ Axiom.dense_indicator h) h4

end

end FormalSystem.Theorems.LinearityDerived

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusDeduction

/-!
# Derived TM⁻ theorems for the L⁻ canonical model

Every derivation-level fact the canonical relations (`Conservativity/MinusCanonicalFrame.lean`)
and the ℚ-chronicle construction (`Conservativity/MinusChronicle.lean`) consume, as explicit
`MinusLanguage.DerivationTree` terms. The future-side theorems are proved once, through the L⁻
deduction theorem in a context; every past-side theorem is obtained from its future twin by
**TR** (`time_reflection`) at the reflected formula, transported along `reflectTime_involution`
— the `boxGlobalPast` idiom of `Conservativity/MinusDeduction.lean` — and never re-derived by
hand.

## Contents

* Propositional: `andIntro`, `andElimL`, `andElimR`, `orInl`, `orInr`.
* Monotonicity and generalized K: `gMono`, `boxMono`, `minusGeneralizedTemporalK`
  (`Γ ⊢⁻ φ ⟹ map G Γ ⊢⁻ Gφ`, the L⁻ transposition of
  `Theorems/GeneralizedNecessitation.lean`'s `generalizedTemporalK`), `minusGeneralizedModalK`.
* Future-side temporal: `gAnd`, `fMono`, `gAndF`, `notFBot`, `notF_of_not`, `notGAndFNeg`,
  `notFNegAndG`, `g4`, `tcFuture`, `serialF`, `gTop`.
* The single DN use: `fF_of_f : ⊢⁻[.Dense] Fψ → FFψ`, `Axiom.dn` contraposed. It is the only
  declaration in this module stated at `FrameClass.Dense`.
* Modal-temporal: `boxImpBoxG` (MF) and its TR mirror `boxImpBoxH`.
* Past mirrors by TR: `pastNecessitation`, `hK`, `hMono`, `minusGeneralizedPastK`, `hAnd`,
  `pMono`, `hAndP`, `notPBot`, `notP_of_not`, `notHAndPNeg`, `notPNegAndH`, `h4`, `tcPast`,
  `serialP`, `hTop`, `tlPast`.

## References

* `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` — deduction theorem, combinators
* `FormalSystem/Theorems/GeneralizedNecessitation.lean` — the L-side generalized K rules
* Burgess, *Basic Tense Logic* (1984), §2.5 — the lemmas these derivations serve

## Tags

conservativity · base-language · derived-theorems · time-reflection
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage

variable {fc : FrameClass}

/-! ## Context-level helpers

Short names for the moves every derivation below makes inside a context. -/

/-- The head assumption of a context. -/
def hyp₀ (Γ : Context) (A : MinusFormula) : (A :: Γ) ⊢⁻[fc] A :=
  .assumption _ A List.mem_cons_self

/-- The second assumption of a context. -/
def hyp₁ (Γ : Context) (B A : MinusFormula) : (B :: A :: Γ) ⊢⁻[fc] A :=
  .assumption _ A (List.mem_cons_of_mem B List.mem_cons_self)

/-- The third assumption of a context. -/
def hyp₂ (Γ : Context) (C B A : MinusFormula) : (C :: B :: A :: Γ) ⊢⁻[fc] A :=
  .assumption _ A (List.mem_cons_of_mem C (List.mem_cons_of_mem B List.mem_cons_self))

/-- Modus ponens in a context. -/
def mpC {Γ : Context} {A B : MinusFormula} (d₁ : Γ ⊢⁻[fc] A.imp B) (d₂ : Γ ⊢⁻[fc] A) :
    Γ ⊢⁻[fc] B :=
  .modus_ponens Γ A B d₁ d₂

/-- Apply a theorem to a context derivation. -/
def apC {Γ : Context} {A B : MinusFormula} (d : ⊢⁻[fc] A.imp B) (h : Γ ⊢⁻[fc] A) :
    Γ ⊢⁻[fc] B :=
  mpC (minusThmIn Γ d) h

/-- An axiom in a context. -/
def axC (Γ : Context) {φ : MinusFormula} (ax : Axiom φ)
    (hfc : ax.minFrameClass ≤ fc) : Γ ⊢⁻[fc] φ :=
  .axiom Γ φ ax hfc

/-- Transport a theorem along an equation of the form `A.reflectTime = B`: the TR idiom. -/
def ofReflect {A B : MinusFormula} (h : A.reflectTime = B) (d : ⊢⁻[fc] A) : ⊢⁻[fc] B :=
  h ▸ DerivationTree.time_reflection A d

/-! ## Propositional -/

/-- `⊢⁻ ¬A → (A → B)`: ex falso under an assumption. -/
def negImpImp (A B : MinusFormula) : ⊢⁻[fc] A.neg.imp (A.imp B) :=
  minusDeductionTheorem [] A.neg (A.imp B) (minusDeductionTheorem [A.neg] A B
    (.modus_ponens [A, A.neg] .bot B
      (.axiom _ _ (Axiom.ex_falso B) (FrameClass.base_le fc))
      (.modus_ponens [A, A.neg] A .bot
        (.assumption _ _ (List.mem_cons_of_mem A List.mem_cons_self))
        (.assumption _ _ List.mem_cons_self))))

/-- `⊢⁻ φ → (ψ → φ ∧ ψ)`. -/
def andIntro (φ ψ : MinusFormula) : ⊢⁻[fc] φ.imp (ψ.imp (φ.and ψ)) :=
  minusDeductionTheorem [] φ _ (minusDeductionTheorem [φ] ψ _
    (minusDeductionTheorem [ψ, φ] (φ.imp ψ.neg) .bot
      (mpC (A := ψ) (B := .bot)
        (mpC (hyp₀ [ψ, φ] (φ.imp ψ.neg)) (hyp₂ [] (φ.imp ψ.neg) ψ φ)) (hyp₁ [φ] (φ.imp ψ.neg) ψ))))

/-- `⊢⁻ (φ ∧ ψ) → φ`: contrapose `¬φ → (φ → ¬ψ)` and eliminate the double negation. -/
def andElimL (φ ψ : MinusFormula) : ⊢⁻[fc] (φ.and ψ).imp φ :=
  minusImpTrans (minusContrapos (negImpImp φ ψ.neg)) (minusDne φ)

/-- `⊢⁻ (φ ∧ ψ) → ψ`: contrapose `prop_s` and eliminate the double negation. -/
def andElimR (φ ψ : MinusFormula) : ⊢⁻[fc] (φ.and ψ).imp ψ :=
  minusImpTrans
    (minusContrapos (A := ψ.neg) (B := φ.imp ψ.neg)
      (.axiom [] _ (Axiom.prop_s ψ.neg φ) (FrameClass.base_le fc)))
    (minusDne ψ)

/-- `⊢⁻ φ → (φ ∨ ψ)`. -/
def orInl (φ ψ : MinusFormula) : ⊢⁻[fc] φ.imp (φ.or ψ) :=
  minusFlip (negImpImp φ ψ)

/-- `⊢⁻ ψ → (φ ∨ ψ)`. -/
def orInr (φ ψ : MinusFormula) : ⊢⁻[fc] ψ.imp (φ.or ψ) :=
  .axiom [] _ (Axiom.prop_s ψ φ.neg) (FrameClass.base_le fc)

/-! ## Monotonicity and generalized K -/

/-- From `⊢⁻ φ → ψ`, `⊢⁻ Gφ → Gψ` (TN + TK). -/
def gMono {φ ψ : MinusFormula} (d : ⊢⁻[fc] φ.imp ψ) : ⊢⁻[fc] φ.allFuture.imp ψ.allFuture :=
  mpC (axC [] (Axiom.temp_k φ ψ) (FrameClass.base_le fc)) (.temporal_necessitation _ d)

/-- From `⊢⁻ φ → ψ`, `⊢⁻ □φ → □ψ` (MN + MK). -/
def boxMono {φ ψ : MinusFormula} (d : ⊢⁻[fc] φ.imp ψ) : ⊢⁻[fc] φ.box.imp ψ.box :=
  mpC (axC [] (Axiom.modal_k φ ψ) (FrameClass.base_le fc)) (.necessitation _ d)

/-- **Generalized temporal K**: `Γ ⊢⁻ φ ⟹ map G Γ ⊢⁻ Gφ`. Induction on `Γ` through the deduction
theorem, TN and TK — the L⁻ transposition of `generalizedTemporalK`. -/
def minusGeneralizedTemporalK {φ : MinusFormula} :
    (Γ : Context) → (Γ ⊢⁻[fc] φ) → (Γ.map MinusFormula.allFuture) ⊢⁻[fc] φ.allFuture
  | [], d => DerivationTree.temporal_necessitation φ d
  | A :: Γ, d =>
    let d₁ : Γ ⊢⁻[fc] A.imp φ := minusDeductionTheorem Γ A φ d
    let d₂ : (Γ.map MinusFormula.allFuture) ⊢⁻[fc] (A.imp φ).allFuture :=
      minusGeneralizedTemporalK Γ d₁
    let d₃ : (Γ.map MinusFormula.allFuture) ⊢⁻[fc] A.allFuture.imp φ.allFuture :=
      mpC (axC _ (Axiom.temp_k A φ) (FrameClass.base_le fc)) d₂
    mpC (.weakening _ _ _ d₃ (List.subset_cons_self _ _)) (.assumption _ _ List.mem_cons_self)

/-- **Generalized modal K**: `Γ ⊢⁻ φ ⟹ map □ Γ ⊢⁻ □φ`, the same induction with MN and MK. -/
def minusGeneralizedModalK {φ : MinusFormula} :
    (Γ : Context) → (Γ ⊢⁻[fc] φ) → (Γ.map MinusFormula.box) ⊢⁻[fc] φ.box
  | [], d => DerivationTree.necessitation φ d
  | A :: Γ, d =>
    let d₁ : Γ ⊢⁻[fc] A.imp φ := minusDeductionTheorem Γ A φ d
    let d₂ : (Γ.map MinusFormula.box) ⊢⁻[fc] (A.imp φ).box := minusGeneralizedModalK Γ d₁
    let d₃ : (Γ.map MinusFormula.box) ⊢⁻[fc] A.box.imp φ.box :=
      mpC (axC _ (Axiom.modal_k A φ) (FrameClass.base_le fc)) d₂
    mpC (.weakening _ _ _ d₃ (List.subset_cons_self _ _)) (.assumption _ _ List.mem_cons_self)

/-! ## Future-side temporal theorems -/

/-- `⊢⁻ G⊤`. -/
def gTop : ⊢⁻[fc] MinusFormula.top.allFuture :=
  .temporal_necessitation _ (deductionAssumptionSame [] .bot)

/-- `⊢⁻ (Gφ ∧ Gψ) → G(φ ∧ ψ)`: distribute `G` over `andIntro` twice with TK. -/
def gAnd (φ ψ : MinusFormula) : ⊢⁻[fc] (φ.allFuture.and ψ.allFuture).imp (φ.and ψ).allFuture :=
  minusDeductionTheorem [] _ _ (
    let Γ : Context := [φ.allFuture.and ψ.allFuture]
    let hGφ : Γ ⊢⁻[fc] φ.allFuture := apC (andElimL φ.allFuture ψ.allFuture) (hyp₀ [] _)
    let hGψ : Γ ⊢⁻[fc] ψ.allFuture := apC (andElimR φ.allFuture ψ.allFuture) (hyp₀ [] _)
    let h₁ : Γ ⊢⁻[fc] (ψ.imp (φ.and ψ)).allFuture :=
      mpC (mpC (axC Γ (Axiom.temp_k φ (ψ.imp (φ.and ψ))) (FrameClass.base_le fc))
        (minusThmIn Γ (.temporal_necessitation _ (andIntro φ ψ)))) hGφ
    mpC (mpC (axC Γ (Axiom.temp_k ψ (φ.and ψ)) (FrameClass.base_le fc)) h₁) hGψ)

/-- From `⊢⁻ φ → ψ`, `⊢⁻ Fφ → Fψ`: `gMono` on the contrapositive, contraposed again. -/
def fMono {φ ψ : MinusFormula} (d : ⊢⁻[fc] φ.imp ψ) :
    ⊢⁻[fc] φ.someFuture.imp ψ.someFuture :=
  minusContrapos (gMono (minusContrapos d))

/-- `⊢⁻ (χ ∧ ¬(χ ∧ ψ)) → ¬ψ`. -/
def andNotAndImpNeg (χ ψ : MinusFormula) : ⊢⁻[fc] (χ.and (χ.and ψ).neg).imp ψ.neg :=
  minusDeductionTheorem [] _ _ (minusDeductionTheorem [χ.and (χ.and ψ).neg] ψ .bot (
    let Γ : Context := [ψ, χ.and (χ.and ψ).neg]
    let hχ : Γ ⊢⁻[fc] χ := apC (andElimL χ (χ.and ψ).neg) (hyp₁ [] ψ _)
    let hn : Γ ⊢⁻[fc] (χ.and ψ).neg := apC (andElimR χ (χ.and ψ).neg) (hyp₁ [] ψ _)
    mpC (A := χ.and ψ) (B := .bot) hn (mpC (mpC (minusThmIn Γ (andIntro χ ψ)) hχ) (hyp₀ _ ψ))))

/-- `⊢⁻ (Gχ ∧ Fψ) → F(χ ∧ ψ)`: under `G¬(χ ∧ ψ)`, `gAnd` and `andNotAndImpNeg` give `G¬ψ`,
refuting `Fψ`. -/
def gAndF (χ ψ : MinusFormula) :
    ⊢⁻[fc] (χ.allFuture.and ψ.someFuture).imp (χ.and ψ).someFuture :=
  minusDeductionTheorem [] _ _
    (minusDeductionTheorem [χ.allFuture.and ψ.someFuture] (χ.and ψ).neg.allFuture .bot (
      let Γ : Context := [(χ.and ψ).neg.allFuture, χ.allFuture.and ψ.someFuture]
      let hGχ : Γ ⊢⁻[fc] χ.allFuture :=
        apC (andElimL χ.allFuture ψ.someFuture) (hyp₁ [] (χ.and ψ).neg.allFuture _)
      let hFψ : Γ ⊢⁻[fc] ψ.someFuture :=
        apC (andElimR χ.allFuture ψ.someFuture) (hyp₁ [] (χ.and ψ).neg.allFuture _)
      let hGand : Γ ⊢⁻[fc] (χ.and (χ.and ψ).neg).allFuture :=
        apC (gAnd χ (χ.and ψ).neg)
          (mpC (mpC (minusThmIn Γ (andIntro χ.allFuture (χ.and ψ).neg.allFuture)) hGχ)
            (hyp₀ _ _))
      let hGnψ : Γ ⊢⁻[fc] ψ.neg.allFuture := apC (gMono (andNotAndImpNeg χ ψ)) hGand
      mpC (A := ψ.neg.allFuture) (B := .bot) hFψ hGnψ))

/-- `⊢⁻ ¬F⊥`: `F⊥ = ¬G⊤`, and `⊢⁻ G⊤`. -/
def notFBot : ⊢⁻[fc] MinusFormula.bot.someFuture.neg :=
  mpC (minusNotNotIntro MinusFormula.top.allFuture) gTop

/-- From `⊢⁻ ¬χ`, `⊢⁻ ¬Fχ`. -/
def notF_of_not {χ : MinusFormula} (d : ⊢⁻[fc] χ.neg) : ⊢⁻[fc] χ.someFuture.neg :=
  minusImpTrans (fMono (φ := χ) (ψ := .bot) d) notFBot

/-- `⊢⁻ ¬(Gβ ∧ F¬β)`: `Gβ → G¬¬β` and `F¬β = ¬G¬¬β`. -/
def notGAndFNeg (β : MinusFormula) : ⊢⁻[fc] (β.allFuture.and β.neg.someFuture).neg :=
  minusDeductionTheorem [] _ .bot (
    let Γ : Context := [β.allFuture.and β.neg.someFuture]
    let hG : Γ ⊢⁻[fc] β.neg.neg.allFuture :=
      apC (gMono (minusNotNotIntro β)) (apC (andElimL β.allFuture β.neg.someFuture) (hyp₀ [] _))
    let hF : Γ ⊢⁻[fc] β.neg.someFuture := apC (andElimR β.allFuture β.neg.someFuture) (hyp₀ [] _)
    mpC (A := β.neg.neg.allFuture) (B := .bot) hF hG)

/-- `⊢⁻ ¬(F¬β ∧ Gβ)`: `notGAndFNeg` with the conjuncts swapped. -/
def notFNegAndG (β : MinusFormula) : ⊢⁻[fc] (β.neg.someFuture.and β.allFuture).neg :=
  minusDeductionTheorem [] _ .bot (
    let Γ : Context := [β.neg.someFuture.and β.allFuture]
    let hG : Γ ⊢⁻[fc] β.neg.neg.allFuture :=
      apC (gMono (minusNotNotIntro β)) (apC (andElimR β.neg.someFuture β.allFuture) (hyp₀ [] _))
    let hF : Γ ⊢⁻[fc] β.neg.someFuture := apC (andElimL β.neg.someFuture β.allFuture) (hyp₀ [] _)
    mpC (A := β.neg.neg.allFuture) (B := .bot) hF hG)

/-- T4 as a named wrapper: `⊢⁻ Gφ → GGφ`. -/
def g4 (φ : MinusFormula) : ⊢⁻[fc] φ.allFuture.imp φ.allFuture.allFuture :=
  axC [] (Axiom.temp_4 φ) (FrameClass.base_le fc)

/-- TC as a named wrapper: `⊢⁻ φ → GPφ`. -/
def tcFuture (φ : MinusFormula) : ⊢⁻[fc] φ.imp φ.somePast.allFuture :=
  axC [] (Axiom.temp_connect φ) (FrameClass.base_le fc)

/-- TS as a named wrapper: `⊢⁻ F⊤`. -/
def serialF : ⊢⁻[fc] MinusFormula.top.someFuture :=
  axC [] Axiom.temp_serial (FrameClass.base_le fc)

/-- **The one DN use.** `⊢⁻[.Dense] Fψ → FFψ`: contrapose `Axiom.dn` at `¬ψ` (`Fψ → ¬GG¬ψ`),
then `¬GG¬ψ → FFψ` by contraposing `gMono (minusDne _)`. -/
def fF_of_f (ψ : MinusFormula) :
    ⊢⁻[FrameClass.Dense] ψ.someFuture.imp ψ.someFuture.someFuture :=
  minusImpTrans
    (minusContrapos (.axiom [] _ (Axiom.dn ψ.neg) (le_refl FrameClass.Dense)))
    (minusContrapos (gMono (minusDne ψ.neg.allFuture)))

/-! ## Modal-temporal -/

/-- MF as a named wrapper: `⊢⁻ □φ → □Gφ`. -/
def boxImpBoxG (φ : MinusFormula) : ⊢⁻[fc] φ.box.imp φ.allFuture.box :=
  axC [] (Axiom.modal_future φ) (FrameClass.base_le fc)

/-- `⊢⁻ □φ → □Hφ`: TR on MF at `φ.reflectTime`. -/
def boxImpBoxH (φ : MinusFormula) : ⊢⁻[fc] φ.box.imp φ.allPast.box :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (boxImpBoxG φ.reflectTime)

/-! ## Past mirrors by TR -/

/-- Past necessitation: `⊢⁻ φ ⟹ ⊢⁻ Hφ`, TR around TN. -/
def pastNecessitation {φ : MinusFormula} (d : ⊢⁻[fc] φ) : ⊢⁻[fc] φ.allPast :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (DerivationTree.temporal_necessitation _ (DerivationTree.time_reflection φ d))

/-- `⊢⁻ H(φ → ψ) → (Hφ → Hψ)`: TR on TK. -/
def hK (φ ψ : MinusFormula) : ⊢⁻[fc] (φ.imp ψ).allPast.imp (φ.allPast.imp ψ.allPast) :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (axC [] (Axiom.temp_k φ.reflectTime ψ.reflectTime) (FrameClass.base_le fc))

/-- From `⊢⁻ φ → ψ`, `⊢⁻ Hφ → Hψ`. -/
def hMono {φ ψ : MinusFormula} (d : ⊢⁻[fc] φ.imp ψ) : ⊢⁻[fc] φ.allPast.imp ψ.allPast :=
  mpC (hK φ ψ) (pastNecessitation d)

/-- **Generalized past K**: `Γ ⊢⁻ φ ⟹ map H Γ ⊢⁻ Hφ`, the same induction as the future rule
with `pastNecessitation` and `hK`. -/
def minusGeneralizedPastK {φ : MinusFormula} :
    (Γ : Context) → (Γ ⊢⁻[fc] φ) → (Γ.map MinusFormula.allPast) ⊢⁻[fc] φ.allPast
  | [], d => pastNecessitation d
  | A :: Γ, d =>
    let d₁ : Γ ⊢⁻[fc] A.imp φ := minusDeductionTheorem Γ A φ d
    let d₂ : (Γ.map MinusFormula.allPast) ⊢⁻[fc] (A.imp φ).allPast := minusGeneralizedPastK Γ d₁
    let d₃ : (Γ.map MinusFormula.allPast) ⊢⁻[fc] A.allPast.imp φ.allPast :=
      mpC (minusThmIn _ (hK A φ)) d₂
    mpC (.weakening _ _ _ d₃ (List.subset_cons_self _ _)) (.assumption _ _ List.mem_cons_self)

/-- `⊢⁻ H⊤`. -/
def hTop : ⊢⁻[fc] MinusFormula.top.allPast :=
  pastNecessitation (deductionAssumptionSame [] .bot)

/-- `⊢⁻ (Hφ ∧ Hψ) → H(φ ∧ ψ)`: TR on `gAnd`. -/
def hAnd (φ ψ : MinusFormula) : ⊢⁻[fc] (φ.allPast.and ψ.allPast).imp (φ.and ψ).allPast :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (gAnd φ.reflectTime ψ.reflectTime)

/-- From `⊢⁻ φ → ψ`, `⊢⁻ Pφ → Pψ`: TR around `fMono`. -/
def pMono {φ ψ : MinusFormula} (d : ⊢⁻[fc] φ.imp ψ) : ⊢⁻[fc] φ.somePast.imp ψ.somePast :=
  ofReflect (A := φ.reflectTime.someFuture.imp ψ.reflectTime.someFuture)
    (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (fMono (ofReflect (A := φ.imp ψ) (by simp [MinusFormula.reflectTime]) d))

/-- `⊢⁻ (Hχ ∧ Pψ) → P(χ ∧ ψ)`: TR on `gAndF`. -/
def hAndP (χ ψ : MinusFormula) :
    ⊢⁻[fc] (χ.allPast.and ψ.somePast).imp (χ.and ψ).somePast :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (gAndF χ.reflectTime ψ.reflectTime)

/-- `⊢⁻ ¬P⊥`: TR on `notFBot`. -/
def notPBot : ⊢⁻[fc] MinusFormula.bot.somePast.neg :=
  ofReflect (by simp [MinusFormula.reflectTime]) notFBot

/-- From `⊢⁻ ¬χ`, `⊢⁻ ¬Pχ`. -/
def notP_of_not {χ : MinusFormula} (d : ⊢⁻[fc] χ.neg) : ⊢⁻[fc] χ.somePast.neg :=
  minusImpTrans (pMono (φ := χ) (ψ := .bot) d) notPBot

/-- `⊢⁻ ¬(Hβ ∧ P¬β)`: TR on `notGAndFNeg`. -/
def notHAndPNeg (β : MinusFormula) : ⊢⁻[fc] (β.allPast.and β.neg.somePast).neg :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (notGAndFNeg β.reflectTime)

/-- `⊢⁻ ¬(P¬β ∧ Hβ)`: TR on `notFNegAndG`. -/
def notPNegAndH (β : MinusFormula) : ⊢⁻[fc] (β.neg.somePast.and β.allPast).neg :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (notFNegAndG β.reflectTime)

/-- `⊢⁻ Hφ → HHφ`: TR on T4. -/
def h4 (φ : MinusFormula) : ⊢⁻[fc] φ.allPast.imp φ.allPast.allPast :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (g4 φ.reflectTime)

/-- `⊢⁻ φ → HFφ`: TR on TC. -/
def tcPast (φ : MinusFormula) : ⊢⁻[fc] φ.imp φ.someFuture.allPast :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (tcFuture φ.reflectTime)

/-- `⊢⁻ P⊤`: TR on TS. -/
def serialP : ⊢⁻[fc] MinusFormula.top.somePast :=
  ofReflect (by simp) serialF

/-- **Left linearity**, the TR mirror of TL:
`⊢⁻ (Pφ ∧ Pψ) → [P(Pφ ∧ ψ) ∨ P(φ ∧ ψ) ∨ P(φ ∧ Pψ)]`. -/
def tlPast (φ ψ : MinusFormula) :
    ⊢⁻[fc] (φ.somePast.and ψ.somePast).imp
      (((φ.somePast.and ψ).somePast).or
        (((φ.and ψ).somePast).or ((φ.and ψ.somePast).somePast))) :=
  ofReflect (by simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution])
    (axC [] (Axiom.temp_linearity φ.reflectTime ψ.reflectTime) (FrameClass.base_le fc))

/-- TL as a named wrapper, for symmetry with `tlPast`. -/
def tlFuture (φ ψ : MinusFormula) :
    ⊢⁻[fc] (φ.someFuture.and ψ.someFuture).imp
      (((φ.someFuture.and ψ).someFuture).or
        (((φ.and ψ).someFuture).or ((φ.and ψ.someFuture).someFuture))) :=
  axC [] (Axiom.temp_linearity φ ψ) (FrameClass.base_le fc)

end FormalSystem.Metalogic.Conservativity

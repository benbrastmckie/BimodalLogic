import FormalSystem.Theorems.DedekindDerived
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants

/-! Scratch verification for task 788: every schema the task proposes to demote is derived here
from the remaining primitives only (no `Axiom.until_F`, `F_until_equiv`, `connect_future`,
`discrete_propagate_fwd`, `discrete_symm_fwd`, `discrete_propagate_bwd`, `temp_linearity`,
`density`, `z1` anywhere below). -/

namespace Scratch788

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.TemporalDerived
open FormalSystem.Theorems (pastKDist)
open FormalSystem.Metalogic.Core (deductionTheorem)

noncomputable section

abbrev X : Formula := Formula.untl Formula.bot (Formula.bot.imp Formula.bot)
abbrev Y : Formula := Formula.snce Formula.bot (Formula.bot.imp Formula.bot)

/-- Theorem-level event monotonicity (UC + TN). -/
def eventMonoThm {fc : FrameClass} (e e' g : Formula) (he : ⊢[fc] e.imp e') :
    ⊢[fc] (Formula.untl g e).imp (Formula.untl g e') :=
  mp (DerivationTree.temporal_necessitation _ he)
    (DerivationTree.axiom [] _ (Axiom.right_mono_until e e' g) (FrameClass.base_le fc))

/-- Theorem-level guard monotonicity (UG + TN). -/
def guardMonoThm {fc : FrameClass} (g g' e : Formula) (hg : ⊢[fc] g.imp g') :
    ⊢[fc] (Formula.untl g e).imp (Formula.untl g' e) :=
  mp (DerivationTree.temporal_necessitation _ hg)
    (DerivationTree.axiom [] _ (Axiom.left_mono_until_G g g' e) (FrameClass.base_le fc))

/-- `φ → ⊤`. -/
def impTop {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.imp Formula.top :=
  mp topThm (DerivationTree.axiom [] _ (Axiom.prop_s Formula.top φ) (FrameClass.base_le fc))

/-! ## UT: an identity -/
def fUntilEquiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ) :=
  identity _

/-! ## UE from UG + TN -/
def untilF {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.untl φ ψ).imp ψ.someFuture :=
  guardMonoThm φ Formula.top ψ (impTop φ)

/-! ## NF from NB + MF + MT -/
def discretePropagateFwd {fc : FrameClass} : ⊢[fc] X.imp X.allFuture :=
  impTrans (DerivationTree.axiom [] _ Axiom.discrete_box_necessity (FrameClass.base_le fc))
    (impTrans (DerivationTree.axiom [] _ (Axiom.modal_future X) (FrameClass.base_le fc))
      (DerivationTree.axiom [] _ (Axiom.modal_t X.allFuture) (FrameClass.base_le fc)))

/-! ## TC from US + UC + TN -/
def connectFuture {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp φ.somePast.allFuture := by
  refine deductionTheorem [] φ _ ?_
  refine deductionTheorem [φ] (Formula.untl Formula.top φ.somePast.neg) Formula.bot ?_
  let Γ : Context := [Formula.untl Formula.top φ.somePast.neg, φ]
  have hφ : Γ ⊢[fc] φ := DerivationTree.assumption _ _ (by simp [Γ])
  have hU : Γ ⊢[fc] Formula.untl Formula.top φ.somePast.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have hUS : Γ ⊢[fc] (Formula.and φ (Formula.untl Formula.top φ.somePast.neg)).imp
      (Formula.untl Formula.top (Formula.and φ.somePast.neg (Formula.snce Formula.top φ))) :=
    DerivationTree.axiom _ _ (Axiom.enrichment_until Formula.top φ.somePast.neg φ)
      (FrameClass.base_le fc)
  have h1 : Γ ⊢[fc] Formula.untl Formula.top
      (Formula.and φ.somePast.neg (Formula.snce Formula.top φ)) :=
    ctxMp hUS (andIntro hφ hU)
  have hcontra : ⊢[fc] (Formula.and φ.somePast.neg (Formula.snce Formula.top φ)).imp
      Formula.bot := by
    refine deductionTheorem [] _ _ ?_
    have hAB : [Formula.and φ.somePast.neg (Formula.snce Formula.top φ)] ⊢[fc]
        Formula.and φ.somePast.neg (Formula.snce Formula.top φ) :=
      DerivationTree.assumption _ _ (by simp)
    have hA := andFst hAB
    have hB := andSnd hAB
    exact ctxMp hA hB
  have h2 : Γ ⊢[fc] Formula.untl Formula.top Formula.bot := eventMono Γ _ _ _ hcontra h1
  exact ctxMp (thmIn (untlBotFalse Formula.top)) h2

/-- `F(Hψ) → ψ` from the derived TC (re-proof of `DedekindDerived.someFutureAllPastImp`). -/
def fHImp {fc : FrameClass} (ψ : Formula) : ⊢[fc] ψ.allPast.someFuture.imp ψ :=
  let connect : ⊢[fc] ψ.neg.imp ψ.neg.somePast.allFuture := connectFuture ψ.neg
  let contra : ⊢[fc] ψ.neg.somePast.allFuture.neg.imp ψ.neg.neg :=
    mp connect (contrapositive ψ.neg ψ.neg.somePast.allFuture)
  impTrans (notNotIntro ψ.allPast.someFuture)
    (impTrans (show ⊢[fc] ψ.allPast.someFuture.neg.neg.imp ψ.neg.neg from contra)
      (doubleNegation ψ))

/-! ## NP from US + TR(NF) + TC -/
/-- TR of NF: `Y⊤ → H Y⊤`. -/
def discretePropagateFwdMirror {fc : FrameClass} : ⊢[fc] Y.imp Y.allPast :=
  DerivedAxioms.ofReflect discretePropagateFwd rfl

def discreteSymmFwd {fc : FrameClass} : ⊢[fc] X.imp Y :=
  let hUS : ⊢[fc] (Formula.and Formula.top X).imp
      (Formula.untl Formula.bot (Formula.and Formula.top (Formula.snce Formula.bot Formula.top))) :=
    DerivationTree.axiom [] _ (Axiom.enrichment_until Formula.bot Formula.top Formula.top)
      (FrameClass.base_le fc)
  let hpair : ⊢[fc] X.imp (Formula.and Formula.top X) := mp topThm (pairing Formula.top X)
  let h1 : ⊢[fc] X.imp (Formula.untl Formula.bot Y) :=
    impTrans (impTrans hpair hUS) (eventMonoThm _ _ _ (rceImp Formula.top Y))
  let h2 : ⊢[fc] (Formula.untl Formula.bot Y).imp (Formula.untl Formula.bot Y.allPast) :=
    eventMonoThm _ _ _ discretePropagateFwdMirror
  impTrans h1 (impTrans h2 (impTrans (untilF Formula.bot Y.allPast) (fHImp Y)))

/-! ## NA from NP + TR(NF) + TR(NP) -/
def discretePropagateBwd {fc : FrameClass} : ⊢[fc] X.imp X.allPast :=
  let hHYX : ⊢[fc] (Y.imp X).allPast :=
    DerivedAxioms.ofReflect (DerivationTree.temporal_necessitation _ discreteSymmFwd) rfl
  impTrans discreteSymmFwd (impTrans discretePropagateFwdMirror (mp hHYX (pastKDist Y X)))

/-! ## TL from CN + UF + UE -/
def orInlThm {fc : FrameClass} (A B : Formula) : ⊢[fc] A.imp (A.or B) :=
  deductionTheorem [] A _ (orInl A B)
def orInrThm {fc : FrameClass} (A B : Formula) : ⊢[fc] B.imp (A.or B) :=
  deductionTheorem [] B _ (orInr A B)

def tempLinearity {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and φ.someFuture ψ.someFuture).imp
      (Formula.or (Formula.someFuture (Formula.and φ.someFuture ψ))
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.someFuture (Formula.and φ ψ.someFuture)))) := by
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
    ctxMp (DerivationTree.axiom _ _ (Axiom.self_accum_until Formula.top φ) (FrameClass.base_le fc)) hFφ
  have hUFψ : Γ ⊢[fc] Formula.untl g₂ ψ :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.self_accum_until Formula.top ψ) (FrameClass.base_le fc)) hFψ
  have hCN : Γ ⊢[fc] Formula.or (Formula.untl (Formula.and g₁ g₂) (Formula.and φ ψ))
      (Formula.or (Formula.untl (Formula.and g₁ g₂) (Formula.and φ g₂))
        (Formula.untl (Formula.and g₁ g₂) (Formula.and g₁ ψ))) :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.linear_until g₁ φ g₂ ψ) (FrameClass.base_le fc))
      (andIntro hUFφ hUFψ)
  -- D1 → B₁ → C
  have hD1 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and φ ψ)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _) (impTrans (orInlThm B₁ B₂) (orInrThm A _))
  -- D2 → F(φ ∧ g₂) → B₂ → C
  have hD2 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and φ g₂)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _)
      (impTrans (someFutureMono (combineImpConj (lceImp φ g₂)
          (impTrans (rceImp φ g₂) (rceImp Formula.top _))))
        (impTrans (orInrThm B₁ B₂) (orInrThm A _)))
  -- D3 → F(g₁ ∧ ψ) → A → C
  have hD3 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and g₁ ψ)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _)
      (impTrans (someFutureMono (combineImpConj
          (impTrans (lceImp g₁ ψ) (rceImp Formula.top _)) (rceImp g₁ ψ)))
        (orInlThm A _))
  refine orElim Γ _ _ _ hCN (thmIn hD1) ?_
  refine deductionTheorem Γ _ _ ?_
  exact orElim _ _ _ _ (DerivationTree.assumption _ _ (by simp)) (thmIn hD2) (thmIn hD3)

/-! ## DN from NN + UG + UF + UE + UC + TN (direct) -/
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

/-! ## DN and Z1 through the completeness engines (non-circular: the engines use only NN / UZ) -/
theorem densityDerivable (φ : Formula) :
    Derivable FrameClass.Dense [] (φ.allFuture.allFuture.imp φ.allFuture) :=
  FormalSystem.Metalogic.BXCanonical.derivable_of_validQTime _
    (FormalSystem.Semantics.Validity.validQTime_of_validDense
      (FormalSystem.Metalogic.density_valid φ))

theorem z1Derivable (φ : Formula) :
    Derivable FrameClass.ZTime []
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime _
    (FormalSystem.Metalogic.SoundnessLemmas.z1_valid φ)

end

end Scratch788

#print axioms Scratch788.tempLinearity
#print axioms Scratch788.density
#print axioms Scratch788.discretePropagateBwd
#print axioms Scratch788.z1Derivable
#print axioms Scratch788.densityDerivable
#print axioms Scratch788.untilF
#print axioms Scratch788.fUntilEquiv
#print axioms Scratch788.connectFuture
#print axioms Scratch788.discretePropagateFwd
#print axioms Scratch788.discreteSymmFwd

/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Basic
import FormalSystem.Theorems.ProofMode.PlusDiscrete
import FormalSystem.Theorems.ProofMode.ScopeConversions

/-! # Contextual reflection, Until and Since introduction, and strict persistence -/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators FormalSystem.Theorems.TemporalDerived

variable {fc : FrameClass} {Γ : Context}

/-- Closed time reflection read at its computed statement. -/
def reflectThm {A B : Formula} (h : ⊢[fc] A) (hEq : A.reflectTime = B) : ⊢[fc] B :=
  hEq ▸ DerivationTree.time_reflection _ h

/-! ## Contextual time reflection -/

/-- Reflect a derivation together with its whole context. Structural recursion on the context:
deduction closes the context, closed time reflection acts, and reverse deduction reopens it.
`reflectTime` commutes with implication definitionally. -/
def reflectContext : (Γ : Context) → (A : Formula) → (Γ ⊢[fc] A) →
    Context.map Formula.reflectTime Γ ⊢[fc] A.reflectTime
  | [], A, h => .time_reflection A h
  | B :: Γ, A, h =>
      reverseDeduction (reflectContext Γ (B.imp A) (deductionTheorem Γ B A h))

/-- Reflecting a context twice returns it. -/
theorem reflectContext_involution (Γ : Context) :
    Context.map Formula.reflectTime (Context.map Formula.reflectTime Γ) = Γ := by
  simp [Context.map, Function.comp_def, Formula.reflect_time_involution]

/-- Goal-direction reflection: prove a goal from its reflection over the reflected context. -/
def reflectGoal {A : Formula}
    (h : Context.map Formula.reflectTime Γ ⊢[fc] A.reflectTime) : Γ ⊢[fc] A := by
  have d := reflectContext _ _ h
  rwa [reflectContext_involution, Formula.reflect_time_involution] at d

/-! ## Until/Since introduction -/

/-- `⊢ G φ → G(ψ → φ)`: a persistent fact is a persistent consequence of anything. -/
def gWeaken (φ ψ : Formula) : ⊢[fc] φ.allFuture.imp (ψ.imp φ).allFuture :=
  mp (DerivationTree.temporal_necessitation _
      (DerivationTree.axiom [] _ (Axiom.prop_s φ ψ) (FrameClass.base_le fc)))
    (gDistribution φ (ψ.imp φ))

/-- `G g → (F e → U g e)`: guard monotonicity from the `⊤` guard of `F e`. -/
private def untilIntroRule (guard event : Formula) :
    ⊢[fc] guard.allFuture.imp (event.someFuture.imp (Formula.untl guard event)) :=
  impTrans (gWeaken guard Formula.top) (untilMonoGuard Formula.top guard event)

/-- `H g → (P e → S g e)`, by closed time reflection. -/
private def sinceIntroRule (guard event : Formula) :
    ⊢[fc] guard.allPast.imp (event.somePast.imp (Formula.snce guard event)) :=
  reflectThm (untilIntroRule guard.reflectTime event.reflectTime) (by
    simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution])

/-- Introduce `U g e` from persistent `G g` and eventual `F e`. -/
def untilIntro {guard event : Formula} (hGuard : Γ ⊢[fc] guard.allFuture)
    (hEvent : Γ ⊢[fc] event.someFuture) : Γ ⊢[fc] Formula.untl guard event :=
  ctxMp (ctxMp (thmIn (untilIntroRule guard event)) hGuard) hEvent

/-- Introduce `S g e` from persistent `H g` and past `P e`. -/
def sinceIntro {guard event : Formula} (hGuard : Γ ⊢[fc] guard.allPast)
    (hEvent : Γ ⊢[fc] event.somePast) : Γ ⊢[fc] Formula.snce guard event :=
  ctxMp (ctxMp (thmIn (sinceIntroRule guard event)) hGuard) hEvent

/-! ## Persistence through scope entry -/

/-- Temporal 4: `G P` yields `G(G P)`, so a body entered under `G` (or at an eventuality
witness) still has `G P`. -/
def futureKeep {P : Formula} (h : Γ ⊢[fc] P.allFuture) : Γ ⊢[fc] P.allFuture.allFuture :=
  ctxMp (thmIn (gTransitivity P)) h

/-- The past mirror of `futureKeep`. -/
def pastKeep {P : Formula} (h : Γ ⊢[fc] P.allPast) : Γ ⊢[fc] P.allPast.allPast :=
  ctxMp (thmIn (hTransitivity P)) h

end FormalSystem.Theorems.ProofMode

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

namespace TemporalSchema

/-- A fresh TM atom in a temporal schema. -/
def atom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

/-- Substitute the ordered TM⁺ arguments of a temporal schema. -/
def assign4 (A B C D : PlusFormula) (p : Atom) : PlusFormula :=
  match p.freshIndex with
  | some 0 => A
  | some 1 => B
  | some 2 => C
  | _ => D

/-- Apply a transferred closed binary schema in context. -/
def apply2 {σ : Atom → PlusFormula} {A B C : Formula}
    (rule : DerivationTree fc [] (A.imp (B.imp C)))
    (hA : PlusDerivationTree fc Γ (substPlus σ A)) (hB : PlusDerivationTree fc Γ (substPlus σ B)) :
    PlusDerivationTree fc Γ (substPlus σ C) :=
  ctxMp (ctxMp (thmIn (.ofTMSubst σ rule)) hA) hB

end TemporalSchema

open TemporalSchema

/-! ### Contextual time reflection -/

/-- Reflect a TM⁺ derivation with its whole context, by native `liftContext`. Reflection
commutes with implication definitionally, so its distribution schema is identity. -/
def reflectContext (Γ : PlusContext) (A : PlusFormula) (h : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc (Γ.map PlusFormula.reflectTime) A.reflectTime :=
  liftContext PlusFormula.reflectTime (fun A h => .time_reflection A h)
    (fun A B => identity (A.reflectTime.imp B.reflectTime)) Γ A h

/-- Reflecting a TM⁺ context twice returns it. -/
theorem reflectContext_involution (Γ : PlusContext) :
    (Γ.map PlusFormula.reflectTime).map PlusFormula.reflectTime = Γ := by
  simp [Function.comp_def, PlusFormula.reflect_time_involution]

/-- Goal-direction reflection over the reflected context. -/
def reflectGoal {A : PlusFormula}
    (h : PlusDerivationTree fc (Γ.map PlusFormula.reflectTime) A.reflectTime) :
    PlusDerivationTree fc Γ A := by
  have d := reflectContext _ _ h
  rwa [reflectContext_involution, PlusFormula.reflect_time_involution] at d

/-! ### Introduction and persistence -/

/-- Introduce `U g e` from persistent `G g` and eventual `F e`. -/
def untilIntro {guard event : PlusFormula} (hGuard : PlusDerivationTree fc Γ guard.allFuture)
    (hEvent : PlusDerivationTree fc Γ event.someFuture) :
    PlusDerivationTree fc Γ (.untl guard event) :=
  apply2 (σ := assign4 guard event guard guard)
    (Theorems.ProofMode.untilIntroRule (atom 0) (atom 1)) hGuard hEvent

/-- Introduce `S g e` from persistent `H g` and past `P e`. -/
def sinceIntro {guard event : PlusFormula} (hGuard : PlusDerivationTree fc Γ guard.allPast)
    (hEvent : PlusDerivationTree fc Γ event.somePast) :
    PlusDerivationTree fc Γ (.snce guard event) :=
  apply2 (σ := assign4 guard event guard guard)
    (Theorems.ProofMode.sinceIntroRule (atom 0) (atom 1)) hGuard hEvent

/-- Temporal 4: retain `G P` inside a body entered under `G` or at an eventuality witness. -/
def futureKeep {P : PlusFormula} (h : PlusDerivationTree fc Γ P.allFuture) :
    PlusDerivationTree fc Γ P.allFuture.allFuture :=
  ctxMp (thmIn (futureIteration P)) h

/-- Past temporal 4. -/
def pastKeep {P : PlusFormula} (h : PlusDerivationTree fc Γ P.allPast) :
    PlusDerivationTree fc Γ P.allPast.allPast :=
  ctxMp (thmIn (pastIteration P)) h

end FormalSystem.PlusLanguage.ProofMode

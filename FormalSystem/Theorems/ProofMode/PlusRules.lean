/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.Substitution
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.TemporalDerived

/-!
# Derivation-producing rules for the TM⁺ proof mode

These functions build `PlusDerivationTree` values. Propositional and temporal theorem
schemata are transferred from TM by `ofTMSubst`, which permits arbitrary `PlusFormula`
arguments and handles time reflection with its required shifted substitution.

Deduction and context substitution recurse directly over native TM⁺ derivations. Contextual
modal and temporal introduction uses deduction, the relevant K theorem, and empty-context
necessitation. No semantic validity, completeness, or `Nonempty` extraction is used.

The source rules are the paper's MP, MN, TN and TR, together with its propositional and
Burgess–Xu schemata. Stability uses TM⁺'s checked `stab_k` and derived `stabNecessitation`.
-/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass DerivationTree)
open FormalSystem.PlusLanguage

variable {fc : FrameClass}

/-- Modus ponens in a native TM⁺ context. -/
def ctxMp {Γ : PlusContext} {A B : PlusFormula}
    (hAB : PlusDerivationTree fc Γ (A.imp B)) (hA : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc Γ B :=
  .modus_ponens Γ A B hAB hA

/-- Weaken a native TM⁺ derivation along a proved context inclusion. -/
def weaken {Γ Δ : PlusContext} {A : PlusFormula} (d : PlusDerivationTree fc Γ A)
    (h : Γ ⊆ Δ) : PlusDerivationTree fc Δ A :=
  .weakening Γ Δ A d h

/-- Import a closed TM⁺ derivation into an arbitrary context. -/
def thmIn {Γ : PlusContext} {A : PlusFormula} (d : PlusDerivationTree fc [] A) :
    PlusDerivationTree fc Γ A :=
  weaken d (List.nil_subset Γ)

/-- The empty logical context requires no assumption derivations. -/
def nilContextProofs (Γ : PlusContext) :
    ∀ φ, φ ∈ ([] : PlusContext) → PlusDerivationTree fc Γ φ := by
  intro φ hφ
  exact False.elim (by simp at hφ)

/-- Extend a derivation environment without eliminating a propositional disjunction into Type. -/
def consContextProofs {Γ Δ : PlusContext} {A : PlusFormula}
    (hA : PlusDerivationTree fc Γ A)
    (hs : ∀ φ, φ ∈ Δ → PlusDerivationTree fc Γ φ) :
    ∀ φ, φ ∈ A :: Δ → PlusDerivationTree fc Γ φ := by
  intro φ hφ
  by_cases h : φ = A
  · subst φ
    exact hA
  · exact hs φ ((List.mem_cons.mp hφ).resolve_left h)

private def schemaAtom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assignTwo (A B : PlusFormula) (p : Atom) : PlusFormula :=
  match p.freshIndex with
  | some 0 => A
  | _ => B

/-- The propositional identity schema at any TM⁺ formula. -/
def identity (A : PlusFormula) : PlusDerivationTree fc [] (A.imp A) :=
  .ofTMSubst (fun _ => A)
    (FormalSystem.Theorems.Combinators.identity (schemaAtom 0))

/-- Pairing at arbitrary TM⁺ formulas, transferred from its TM schema. -/
def pairing (A B : PlusFormula) :
    PlusDerivationTree fc [] (A.imp (B.imp (A.and B))) :=
  .ofTMSubst (assignTwo A B)
    (FormalSystem.Theorems.Combinators.pairing (schemaAtom 0) (schemaAtom 1))

/-- Left conjunction elimination, transferred from its TM schema. -/
def lceImp (A B : PlusFormula) : PlusDerivationTree fc [] ((A.and B).imp A) :=
  .ofTMSubst (assignTwo A B)
    (FormalSystem.Theorems.Propositional.lceImp (schemaAtom 0) (schemaAtom 1))

/-- Right conjunction elimination, transferred from its TM schema. -/
def rceImp (A B : PlusFormula) : PlusDerivationTree fc [] ((A.and B).imp B) :=
  .ofTMSubst (assignTwo A B)
    (FormalSystem.Theorems.Propositional.rceImp (schemaAtom 0) (schemaAtom 1))

private def weakenUnderImp {Γ : PlusContext} {A B : PlusFormula}
    (d : PlusDerivationTree fc Γ B) : PlusDerivationTree fc Γ (A.imp B) :=
  ctxMp (.axiom Γ _ (.prop_s B A) (FrameClass.base_le fc)) d

private def mapUnderImp : {Γ : PlusContext} → {φ : PlusFormula} →
    PlusDerivationTree fc Γ φ → (Δ : PlusContext) → (A : PlusFormula) →
    (∀ ψ, ψ ∈ Γ → PlusDerivationTree fc Δ (A.imp ψ)) →
    PlusDerivationTree fc Δ (A.imp φ)
  | _, _, .axiom _ φ ax hfc, Δ, _, _ =>
      weakenUnderImp (.axiom Δ φ ax hfc)
  | _, _, .assumption _ φ hφ, _, _, hs => hs φ hφ
  | _, _, .modus_ponens _ φ ψ d₁ d₂, Δ, A, hs =>
      ctxMp
        (ctxMp (.axiom Δ _ (.prop_k A φ ψ) (FrameClass.base_le fc))
          (mapUnderImp d₁ Δ A hs))
        (mapUnderImp d₂ Δ A hs)
  | _, _, .necessitation φ d, _, _, _ =>
      weakenUnderImp (thmIn (.necessitation φ d))
  | _, _, .temporal_necessitation φ d, _, _, _ =>
      weakenUnderImp (thmIn (.temporal_necessitation φ d))
  | _, _, .time_reflection φ d, _, _, _ =>
      weakenUnderImp (thmIn (.time_reflection φ d))
  | _, _, .weakening _ _ _ d h, Δ, A, hs =>
      mapUnderImp d Δ A (fun ψ hψ => hs ψ (h hψ))

/-- Native TM⁺ deduction, by structural recursion rather than a semantic argument. -/
def deductionTheorem (Γ : PlusContext) (A B : PlusFormula)
    (d : PlusDerivationTree fc (A :: Γ) B) : PlusDerivationTree fc Γ (A.imp B) :=
  mapUnderImp d Γ A fun ψ hψ => by
    by_cases h : ψ = A
    · subst ψ
      exact thmIn (identity A)
    · have hΓ : ψ ∈ Γ := (List.mem_cons.mp hψ).resolve_left h
      exact weakenUnderImp (.assumption Γ ψ hΓ)

/-- Apply an implication under its antecedent as an additional assumption. -/
def reverseDeduction {Γ : PlusContext} {A B : PlusFormula}
    (d : PlusDerivationTree fc Γ (A.imp B)) : PlusDerivationTree fc (A :: Γ) B :=
  ctxMp
    (weaken d (by intro ψ hψ; exact List.mem_cons_of_mem A hψ))
    (.assumption (A :: Γ) A (by simp))

/-- Cut an established assertion into a native TM⁺ derivation. -/
def cut {Γ : PlusContext} {A B : PlusFormula}
    (hA : PlusDerivationTree fc Γ A) (d : PlusDerivationTree fc (A :: Γ) B) :
    PlusDerivationTree fc Γ B :=
  ctxMp (deductionTheorem Γ A B d) hA

/-- Replace each assumption by a derivation in a common target context. -/
def substContext : {Γ : PlusContext} → {φ : PlusFormula} →
    PlusDerivationTree fc Γ φ → {Δ : PlusContext} →
    (∀ ψ, ψ ∈ Γ → PlusDerivationTree fc Δ ψ) → PlusDerivationTree fc Δ φ
  | _, _, .axiom _ φ ax hfc, Δ, _ => .axiom Δ φ ax hfc
  | _, _, .assumption _ φ hφ, _, hs => hs φ hφ
  | _, _, .modus_ponens _ _ _ d₁ d₂, _, hs =>
      ctxMp (substContext d₁ hs) (substContext d₂ hs)
  | _, _, .necessitation φ d, _, _ => thmIn (.necessitation φ d)
  | _, _, .temporal_necessitation φ d, _, _ => thmIn (.temporal_necessitation φ d)
  | _, _, .time_reflection φ d, _, _ => thmIn (.time_reflection φ d)
  | _, _, .weakening _ _ _ d h, _, hs =>
      substContext d (fun ψ hψ => hs ψ (h hψ))

/-- Conjunction introduction in a common context. -/
def andIntro {Γ : PlusContext} {A B : PlusFormula}
    (hA : PlusDerivationTree fc Γ A) (hB : PlusDerivationTree fc Γ B) :
    PlusDerivationTree fc Γ (A.and B) :=
  ctxMp (ctxMp (thmIn (pairing A B)) hA) hB

/-- Left conjunction elimination in a common context. -/
def andFst {Γ : PlusContext} {A B : PlusFormula} (d : PlusDerivationTree fc Γ (A.and B)) :
    PlusDerivationTree fc Γ A :=
  ctxMp (thmIn (lceImp A B)) d

/-- Right conjunction elimination in a common context. -/
def andSnd {Γ : PlusContext} {A B : PlusFormula} (d : PlusDerivationTree fc Γ (A.and B)) :
    PlusDerivationTree fc Γ B :=
  ctxMp (thmIn (rceImp A B)) d

/-- Left disjunction introduction through the transferred propositional schema. -/
def orIntroL (Γ : PlusContext) (A B : PlusFormula) (hA : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc Γ (A.or B) :=
  ctxMp (thmIn (.ofTMSubst (assignTwo A B)
    (FormalSystem.Metalogic.Core.deductionTheorem [] (schemaAtom 0)
      ((schemaAtom 0).or (schemaAtom 1))
      (FormalSystem.Theorems.Propositional.orInl (schemaAtom 0) (schemaAtom 1))))) hA

/-- Right disjunction introduction through the transferred propositional schema. -/
def orIntroR (Γ : PlusContext) (A B : PlusFormula) (hB : PlusDerivationTree fc Γ B) :
    PlusDerivationTree fc Γ (A.or B) :=
  ctxMp (thmIn (.ofTMSubst (assignTwo A B)
    (FormalSystem.Metalogic.Core.deductionTheorem [] (schemaAtom 1)
      ((schemaAtom 0).or (schemaAtom 1))
      (FormalSystem.Theorems.Propositional.orInr (schemaAtom 0) (schemaAtom 1))))) hB

/-- Join two implication branches at their common conclusion. -/
def orElim (Γ : PlusContext) (A B C : PlusFormula)
    (hOr : PlusDerivationTree fc Γ (A.or B))
    (hAC : PlusDerivationTree fc Γ (A.imp C))
    (hBC : PlusDerivationTree fc Γ (B.imp C)) : PlusDerivationTree fc Γ C := by
  have hNotA : PlusDerivationTree fc (C.neg :: Γ) A.neg := by
    refine deductionTheorem (C.neg :: Γ) A .bot ?_
    have hC : PlusDerivationTree fc (A :: C.neg :: Γ) C :=
      ctxMp (weaken hAC (by intro ψ hψ; simp [hψ]))
        (.assumption _ A (by simp))
    exact ctxMp (.assumption _ C.neg (by simp)) hC
  have hC : PlusDerivationTree fc (C.neg :: Γ) C :=
    ctxMp (weaken hBC (by intro ψ hψ; simp [hψ]))
      (ctxMp (weaken hOr (by intro ψ hψ; simp [hψ])) hNotA)
  exact ctxMp (.axiom Γ _ (.peirce C .bot) (FrameClass.base_le fc))
    (deductionTheorem Γ C.neg C hC)

/-- Join complete disjunction branches, discharging each branch assumption. -/
def orCases {Γ : PlusContext} {A B C : PlusFormula}
    (hOr : PlusDerivationTree fc Γ (A.or B))
    (hA : PlusDerivationTree fc (A :: Γ) C)
    (hB : PlusDerivationTree fc (B :: Γ) C) : PlusDerivationTree fc Γ C :=
  orElim Γ A B C hOr (deductionTheorem Γ A C hA) (deductionTheorem Γ B C hB)

/-- Future K distribution, transferred from its proved TM schema. -/
def gDistribution (A B : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allFuture.imp (A.allFuture.imp B.allFuture)) :=
  .ofTMSubst (assignTwo A B)
    (FormalSystem.Theorems.TemporalDerived.gDistribution (schemaAtom 0) (schemaAtom 1))

/-- Past K distribution, transferred from its proved TM schema. -/
def hDistribution (A B : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allPast.imp (A.allPast.imp B.allPast)) :=
  .ofTMSubst (assignTwo A B)
    (FormalSystem.Theorems.TemporalDerived.hDistribution (schemaAtom 0) (schemaAtom 1))

/-- Past necessitation from theorem-level time reflection and future necessitation. -/
def pastNecessitation (A : PlusFormula) (d : PlusDerivationTree fc [] A) :
    PlusDerivationTree fc [] A.allPast := by
  have h := PlusDerivationTree.time_reflection _
    (PlusDerivationTree.temporal_necessitation _ (PlusDerivationTree.time_reflection _ d))
  simpa only [PlusFormula.reflect_time_all_future, PlusFormula.reflect_time_involution] using h

/-- Lift a context using a proved necessitation operation and normal distribution theorem. -/
def liftContext (op : PlusFormula → PlusFormula)
    (nec : ∀ A, PlusDerivationTree fc [] A → PlusDerivationTree fc [] (op A))
    (dist : ∀ A B, PlusDerivationTree fc [] ((op (A.imp B)).imp ((op A).imp (op B)))) :
    (Γ : PlusContext) → (φ : PlusFormula) → PlusDerivationTree fc Γ φ →
      PlusDerivationTree fc (Γ.map op) (op φ)
  | [], φ, d => nec φ d
  | A :: Γ, φ, d =>
      reverseDeduction
        (ctxMp (thmIn (dist A φ))
          (liftContext op nec dist Γ (A.imp φ) (deductionTheorem Γ A φ d)))

/-- Lift exactly a selected body context under modal necessity. -/
def generalizedModalK (Γ : PlusContext) (φ : PlusFormula) (d : PlusDerivationTree fc Γ φ) :
    PlusDerivationTree fc (Γ.map PlusFormula.box) φ.box :=
  liftContext PlusFormula.box (fun A h => .necessitation A h)
    (fun A B => .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)) Γ φ d

/-- Lift exactly a selected body context under strict universal future. -/
def generalizedTemporalK (Γ : PlusContext) (φ : PlusFormula)
    (d : PlusDerivationTree fc Γ φ) :
    PlusDerivationTree fc (Γ.map PlusFormula.allFuture) φ.allFuture :=
  liftContext PlusFormula.allFuture (fun A h => .temporal_necessitation A h)
    gDistribution Γ φ d

/-- Lift exactly a selected body context under strict universal past. -/
def generalizedPastK (Γ : PlusContext) (φ : PlusFormula) (d : PlusDerivationTree fc Γ φ) :
    PlusDerivationTree fc (Γ.map PlusFormula.allPast) φ.allPast :=
  liftContext PlusFormula.allPast pastNecessitation hDistribution Γ φ d

/-- Lift exactly a selected body context under stability, using derived necessitation. -/
def generalizedStabK (Γ : PlusContext) (φ : PlusFormula) (d : PlusDerivationTree fc Γ φ) :
    PlusDerivationTree fc (Γ.map PlusFormula.stab) (PlusFormula.stab φ) :=
  liftContext PlusFormula.stab (fun _ h => stabNecessitation h)
    (fun A B => .axiom [] _ (.stab_k A B) (FrameClass.base_le fc)) Γ φ d

end FormalSystem.PlusLanguage.ProofMode

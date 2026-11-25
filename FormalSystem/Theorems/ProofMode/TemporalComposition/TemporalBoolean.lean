/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.TemporalComposition.Temporal

/-! # Strict leads-to consequence, transitivity and cases -/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators FormalSystem.Theorems.TemporalDerived

variable {fc : FrameClass} {Γ : Context}

/-- Close a uniform binary contextual rule into a theorem schema. -/
private def closed2 {A B C : Formula}
    (f : ∀ {Δ : Context}, DerivationTree fc Δ A → DerivationTree fc Δ B →
      DerivationTree fc Δ C) : ⊢[fc] A.imp (B.imp C) :=
  deductionTheorem [] A _ (deductionTheorem [A] B C
    (f (.assumption _ A (by simp)) (.assumption _ B (by simp))))

/-- Close a uniform ternary contextual rule into a theorem schema. -/
private def closed3 {A B C D : Formula}
    (f : ∀ {Δ : Context}, DerivationTree fc Δ A → DerivationTree fc Δ B →
      DerivationTree fc Δ C → DerivationTree fc Δ D) :
    ⊢[fc] A.imp (B.imp (C.imp D)) :=
  deductionTheorem [] A _ (deductionTheorem [A] B _ (deductionTheorem [B, A] C D
    (f (.assumption _ A (by simp)) (.assumption _ B (by simp)) (.assumption _ C (by simp)))))

/-! ## Strict leads-to: consequence, transitivity and cases

The current form is `φ → Fψ`; the persistent form is `G(φ → Fψ)`. -/

/-- `(φ' → φ) → G(ψ → ψ') → (φ → Fψ) → (φ' → Fψ')`. -/
private def leadsToConsequenceRule (φ' φ ψ ψ' : Formula) :
    ⊢[fc] (φ'.imp φ).imp ((ψ.imp ψ').allFuture.imp
      ((φ.imp ψ.someFuture).imp (φ'.imp ψ'.someFuture))) :=
  closed3 fun hPre hPost h =>
    deductionTheorem _ φ' _
      (futureConsequence (.weakening _ _ _ hPost (List.subset_cons_self _ _))
        (ctxMp (.weakening _ _ _ h (List.subset_cons_self _ _)) (reverseDeduction hPre)))

/-- `(φ → Fψ) → G(ψ → Fχ) → (φ → Fχ)`. -/
private def leadsToTransRule (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ.someFuture).imp ((ψ.imp χ.someFuture).allFuture.imp
      (φ.imp χ.someFuture)) :=
  closed2 fun h hNext =>
    deductionTheorem _ φ _ (futureBind (.weakening _ _ _ hNext (List.subset_cons_self _ _))
      (ctxMp (.weakening _ _ _ h (List.subset_cons_self _ _)) (.assumption _ φ (by simp))))

/-- `(φ₁ → χ) → (φ₂ → χ) → (φ₁ ∨ φ₂ → χ)`. -/
private def casesRule (φ₁ φ₂ χ : Formula) :
    ⊢[fc] (φ₁.imp χ).imp ((φ₂.imp χ).imp ((φ₁.or φ₂).imp χ)) :=
  closed2 fun h₁ h₂ =>
    deductionTheorem _ _ _ (Propositional.orElim _ φ₁ φ₂ χ (.assumption _ _ (by simp))
      (.weakening _ _ _ h₁ (List.subset_cons_self _ _))
      (.weakening _ _ _ h₂ (List.subset_cons_self _ _)))

/-- `(φ' → φ) → H(ψ → ψ') → (φ → Pψ) → (φ' → Pψ')`, by closed time reflection. -/
private def pastLeadsToConsequenceRule (φ' φ ψ ψ' : Formula) :
    ⊢[fc] (φ'.imp φ).imp ((ψ.imp ψ').allPast.imp
      ((φ.imp ψ.somePast).imp (φ'.imp ψ'.somePast))) :=
  reflectThm (leadsToConsequenceRule φ'.reflectTime φ.reflectTime ψ.reflectTime ψ'.reflectTime)
    (by simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution])

/-- `(φ → Pψ) → H(ψ → Pχ) → (φ → Pχ)`, by closed time reflection. -/
private def pastLeadsToTransRule (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ.somePast).imp ((ψ.imp χ.somePast).allPast.imp (φ.imp χ.somePast)) :=
  reflectThm (leadsToTransRule φ.reflectTime ψ.reflectTime χ.reflectTime)
    (by simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution])

/-- Distribute a `G`-scoped implication. -/
private def futureMp {A B : Formula} (hAB : Γ ⊢[fc] (A.imp B).allFuture)
    (hA : Γ ⊢[fc] A.allFuture) : Γ ⊢[fc] B.allFuture :=
  ctxMp (ctxMp (thmIn (gDistribution A B)) hAB) hA

/-- Distribute an `H`-scoped implication. -/
private def pastMp {A B : Formula} (hAB : Γ ⊢[fc] (A.imp B).allPast)
    (hA : Γ ⊢[fc] A.allPast) : Γ ⊢[fc] B.allPast :=
  ctxMp (ctxMp (thmIn (hDistribution A B)) hAB) hA

/-- Current leads-to consequence: strengthen the source now, weaken the target under `G`. -/
def leadsToConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] φ'.imp φ)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allFuture) (h : Γ ⊢[fc] φ.imp ψ.someFuture) :
    Γ ⊢[fc] φ'.imp ψ'.someFuture :=
  ctxMp (ctxMp (ctxMp (thmIn (leadsToConsequenceRule φ' φ ψ ψ')) hPre) hPost) h

/-- A current leads-to followed by a persistent one. -/
def leadsToTrans {φ ψ χ : Formula} (h : Γ ⊢[fc] φ.imp ψ.someFuture)
    (hNext : Γ ⊢[fc] (ψ.imp χ.someFuture).allFuture) : Γ ⊢[fc] φ.imp χ.someFuture :=
  ctxMp (ctxMp (thmIn (leadsToTransRule φ ψ χ)) h) hNext

/-- Persistent leads-to consequence. Both side conditions are `G`-scoped; temporal 4 retains
the target weakening inside the persistent body. -/
def progressConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] (φ'.imp φ).allFuture)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allFuture) (h : Γ ⊢[fc] (φ.imp ψ.someFuture).allFuture) :
    Γ ⊢[fc] (φ'.imp ψ'.someFuture).allFuture :=
  futureMp (futureMp (futureMp
    (thmIn (DerivationTree.temporal_necessitation _ (leadsToConsequenceRule φ' φ ψ ψ'))) hPre)
    (futureKeep hPost)) h

/-- Persistent finite-case composition: two persistent leads-to guarantees with a common
target cover their disjoined source. Iterate for more cases. -/
def progressCases {φ₁ φ₂ ψ : Formula} (h₁ : Γ ⊢[fc] (φ₁.imp ψ.someFuture).allFuture)
    (h₂ : Γ ⊢[fc] (φ₂.imp ψ.someFuture).allFuture) :
    Γ ⊢[fc] ((φ₁.or φ₂).imp ψ.someFuture).allFuture :=
  futureMp (futureMp
    (thmIn (DerivationTree.temporal_necessitation _ (casesRule φ₁ φ₂ ψ.someFuture))) h₁) h₂

/-- Current past leads-to consequence. -/
def pastLeadsToConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] φ'.imp φ)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allPast) (h : Γ ⊢[fc] φ.imp ψ.somePast) :
    Γ ⊢[fc] φ'.imp ψ'.somePast :=
  ctxMp (ctxMp (ctxMp (thmIn (pastLeadsToConsequenceRule φ' φ ψ ψ')) hPre) hPost) h

/-- A current past leads-to followed by a persistent one. -/
def pastLeadsToTrans {φ ψ χ : Formula} (h : Γ ⊢[fc] φ.imp ψ.somePast)
    (hNext : Γ ⊢[fc] (ψ.imp χ.somePast).allPast) : Γ ⊢[fc] φ.imp χ.somePast :=
  ctxMp (ctxMp (thmIn (pastLeadsToTransRule φ ψ χ)) h) hNext

/-- Persistent past leads-to consequence; `hPost` is retained by past temporal 4. -/
def pastProgressConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] (φ'.imp φ).allPast)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allPast) (h : Γ ⊢[fc] (φ.imp ψ.somePast).allPast) :
    Γ ⊢[fc] (φ'.imp ψ'.somePast).allPast :=
  pastMp (pastMp (pastMp
    (thmIn (pastNecessitation _ (pastLeadsToConsequenceRule φ' φ ψ ψ'))) hPre)
    (pastKeep hPost)) h

/-- Persistent past finite-case composition. -/
def pastProgressCases {φ₁ φ₂ ψ : Formula} (h₁ : Γ ⊢[fc] (φ₁.imp ψ.somePast).allPast)
    (h₂ : Γ ⊢[fc] (φ₂.imp ψ.somePast).allPast) :
    Γ ⊢[fc] ((φ₁.or φ₂).imp ψ.somePast).allPast :=
  pastMp (pastMp (thmIn (pastNecessitation _ (casesRule φ₁ φ₂ ψ.somePast))) h₁) h₂

end FormalSystem.Theorems.ProofMode

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

open TemporalSchema

/-- Apply a transferred closed ternary schema in context. -/
private def apply3 {σ : Atom → PlusFormula} {A B C D : Formula}
    (rule : DerivationTree fc [] (A.imp (B.imp (C.imp D))))
    (hA : PlusDerivationTree fc Γ (substPlus σ A)) (hB : PlusDerivationTree fc Γ (substPlus σ B))
    (hC : PlusDerivationTree fc Γ (substPlus σ C)) : PlusDerivationTree fc Γ (substPlus σ D) :=
  ctxMp (ctxMp (ctxMp (thmIn (.ofTMSubst σ rule)) hA) hB) hC

/-! ### Strict leads-to -/

/-- Current leads-to consequence: strengthen the source now, weaken the target under `G`. -/
def leadsToConsequence {φ' φ ψ ψ' : PlusFormula} (hPre : PlusDerivationTree fc Γ (φ'.imp φ))
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allFuture)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.someFuture)) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.someFuture) :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.leadsToConsequenceRule (atom 0) (atom 1)
    (atom 2) (atom 3)) hPre hPost h

/-- A current leads-to followed by a persistent one. -/
def leadsToTrans {φ ψ χ : PlusFormula} (h : PlusDerivationTree fc Γ (φ.imp ψ.someFuture))
    (hNext : PlusDerivationTree fc Γ (ψ.imp χ.someFuture).allFuture) :
    PlusDerivationTree fc Γ (φ.imp χ.someFuture) :=
  apply2 (σ := assign4 φ ψ χ χ)
    (Theorems.ProofMode.leadsToTransRule (atom 0) (atom 1) (atom 2)) h hNext

/-- Persistent leads-to consequence, with both side conditions `G`-scoped. -/
def progressConsequence {φ' φ ψ ψ' : PlusFormula}
    (hPre : PlusDerivationTree fc Γ (φ'.imp φ).allFuture)
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allFuture)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.someFuture).allFuture) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.someFuture).allFuture :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.closed3 fun hPre hPost h =>
    Theorems.ProofMode.progressConsequence (φ' := atom 0) (φ := atom 1) (ψ := atom 2)
      (ψ' := atom 3) hPre hPost h) hPre hPost h

/-- Persistent finite-case composition over a disjoined source. -/
def progressCases {φ₁ φ₂ ψ : PlusFormula}
    (h₁ : PlusDerivationTree fc Γ (φ₁.imp ψ.someFuture).allFuture)
    (h₂ : PlusDerivationTree fc Γ (φ₂.imp ψ.someFuture).allFuture) :
    PlusDerivationTree fc Γ ((φ₁.or φ₂).imp ψ.someFuture).allFuture :=
  apply2 (σ := assign4 φ₁ φ₂ ψ ψ) (Theorems.ProofMode.closed2 fun h₁ h₂ =>
    Theorems.ProofMode.progressCases (φ₁ := atom 0) (φ₂ := atom 1) (ψ := atom 2) h₁ h₂) h₁ h₂

/-- Current past leads-to consequence. -/
def pastLeadsToConsequence {φ' φ ψ ψ' : PlusFormula}
    (hPre : PlusDerivationTree fc Γ (φ'.imp φ))
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allPast)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.somePast)) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.somePast) :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.pastLeadsToConsequenceRule (atom 0) (atom 1)
    (atom 2) (atom 3)) hPre hPost h

/-- A current past leads-to followed by a persistent one. -/
def pastLeadsToTrans {φ ψ χ : PlusFormula} (h : PlusDerivationTree fc Γ (φ.imp ψ.somePast))
    (hNext : PlusDerivationTree fc Γ (ψ.imp χ.somePast).allPast) :
    PlusDerivationTree fc Γ (φ.imp χ.somePast) :=
  apply2 (σ := assign4 φ ψ χ χ)
    (Theorems.ProofMode.pastLeadsToTransRule (atom 0) (atom 1) (atom 2)) h hNext

/-- Persistent past leads-to consequence. -/
def pastProgressConsequence {φ' φ ψ ψ' : PlusFormula}
    (hPre : PlusDerivationTree fc Γ (φ'.imp φ).allPast)
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allPast)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.somePast).allPast) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.somePast).allPast :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.closed3 fun hPre hPost h =>
    Theorems.ProofMode.pastProgressConsequence (φ' := atom 0) (φ := atom 1) (ψ := atom 2)
      (ψ' := atom 3) hPre hPost h) hPre hPost h

/-- Persistent past finite-case composition. -/
def pastProgressCases {φ₁ φ₂ ψ : PlusFormula}
    (h₁ : PlusDerivationTree fc Γ (φ₁.imp ψ.somePast).allPast)
    (h₂ : PlusDerivationTree fc Γ (φ₂.imp ψ.somePast).allPast) :
    PlusDerivationTree fc Γ ((φ₁.or φ₂).imp ψ.somePast).allPast :=
  apply2 (σ := assign4 φ₁ φ₂ ψ ψ) (Theorems.ProofMode.closed2 fun h₁ h₂ =>
    Theorems.ProofMode.pastProgressCases (φ₁ := atom 0) (φ₂ := atom 1) (ψ := atom 2) h₁ h₂)
    h₁ h₂

end FormalSystem.PlusLanguage.ProofMode

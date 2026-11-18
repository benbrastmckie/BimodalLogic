/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Reasoning

/-!
# Context substitution and natural deduction for the TM proof mode

These functions construct native `DerivationTree` data. Context substitution replaces each
source assumption by an opaque derivation in the destination context. Modal and temporal
scope changes can therefore consume exported guarantees without unfolding their proof bodies.

The rules reconstruct the paper's classical reasoning and MP/MN/TN/TR rules. Necessitation
and reflection retain their empty-context premises; no model truth or completeness is used.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

variable {fc : FrameClass}

/-- Context inclusion is reflexive, with the context explicit for metaprogramming. -/
theorem context_refl {α : Type} (Γ : List α) : Γ ⊆ Γ := List.Subset.refl Γ

/-- The empty context is included in any context. -/
theorem context_nil {α : Type} (Γ : List α) : [] ⊆ Γ := List.nil_subset Γ

/-- Extend a checked context inclusion by a proved member. -/
theorem context_cons {α : Type} {A : α} {Γ Δ : List α}
    (hA : A ∈ Δ) (hΓ : Γ ⊆ Δ) : A :: Γ ⊆ Δ := by
  intro ψ hψ
  rcases List.mem_cons.mp hψ with h | h
  · exact h ▸ hA
  · exact hΓ h

/-- Preserve an inclusion when the destination gains an additional assumption. -/
theorem context_weaken_head {α : Type} (A : α) {Γ Δ : List α}
    (h : Γ ⊆ Δ) : Γ ⊆ A :: Δ := by
  intro ψ hψ
  exact List.mem_cons_of_mem A (h hψ)

/-- Substitute derivations for all assumptions of a native TM derivation. -/
def substContext {Γ Δ : Context} {φ : Formula} (d : DerivationTree fc Δ φ) :
    (∀ ψ, ψ ∈ Δ → DerivationTree fc Γ ψ) → DerivationTree fc Γ φ :=
  match d with
  | .axiom _ φ ax hfc => fun _ => .axiom Γ φ ax hfc
  | .assumption _ φ hφ => fun hs => hs φ hφ
  | .modus_ponens _ _ _ d₁ d₂ => fun hs =>
      ctxMp (substContext d₁ hs) (substContext d₂ hs)
  | .necessitation φ d => fun _ => thmIn (.necessitation φ d)
  | .temporal_necessitation φ d => fun _ => thmIn (.temporal_necessitation φ d)
  | .time_reflection φ d => fun _ => thmIn (.time_reflection φ d)
  | .weakening _ _ _ d h => fun hs => substContext d (fun ψ hψ => hs ψ (h hψ))

/-- The derivation environment for an empty source context. -/
def nilContextProofs (Γ : Context) : ∀ ψ, ψ ∈ ([] : Context) → DerivationTree fc Γ ψ :=
  fun _ h => False.elim (List.not_mem_nil h)

/-- Extend a derivation environment by one established assumption. -/
def consContextProofs {Γ Δ : Context} {A : Formula} (hA : DerivationTree fc Γ A)
    (hs : ∀ ψ, ψ ∈ Δ → DerivationTree fc Γ ψ) :
    ∀ ψ, ψ ∈ A :: Δ → DerivationTree fc Γ ψ := fun ψ hψ =>
  if h : ψ = A then h.symm ▸ hA
  else hs ψ ((List.mem_cons.mp hψ).resolve_left h)

/-- Cut an opaque guarantee into a native TM proof. -/
def cut {Γ : Context} {A B : Formula} (hA : Γ ⊢[fc] A) (d : A :: Γ ⊢[fc] B) :
    Γ ⊢[fc] B :=
  ctxMp (FormalSystem.Metalogic.Core.deductionTheorem Γ A B d) hA

/-- Left conjunction elimination in an arbitrary context. -/
def andFst {Γ : Context} {A B : Formula} (d : Γ ⊢[fc] A.and B) : Γ ⊢[fc] A :=
  ctxMp (thmIn (Propositional.lceImp A B)) d

/-- Right conjunction elimination in an arbitrary context. -/
def andSnd {Γ : Context} {A B : Formula} (d : Γ ⊢[fc] A.and B) : Γ ⊢[fc] B :=
  ctxMp (thmIn (Propositional.rceImp A B)) d

/-- A complete disjunction join whose branch assumptions stay local. -/
def orCases {Γ : Context} {A B C : Formula} (h : Γ ⊢[fc] A.or B)
    (hA : A :: Γ ⊢[fc] C) (hB : B :: Γ ⊢[fc] C) : Γ ⊢[fc] C :=
  Propositional.orElim Γ A B C h
    (FormalSystem.Metalogic.Core.deductionTheorem Γ A C hA)
    (FormalSystem.Metalogic.Core.deductionTheorem Γ B C hB)

/-- Possibility introduction from a current assertion, derived from modal T. -/
def diamondIntro {Γ : Context} {A : Formula} (hA : Γ ⊢[fc] A) :
    Γ ⊢[fc] A.diamond := by
  apply FormalSystem.Metalogic.Core.deductionTheorem Γ A.neg.box Formula.bot
  have hA' : A.neg.box :: Γ ⊢[fc] A :=
    .weakening Γ _ _ hA (List.subset_cons_self _ _)
  have hnA : A.neg.box :: Γ ⊢[fc] A.neg :=
    ctxMp (.axiom _ _ (.modal_t A.neg) (FrameClass.base_le fc))
      (.assumption _ _ (by simp))
  exact ctxMp hnA hA'

end FormalSystem.Theorems.ProofMode

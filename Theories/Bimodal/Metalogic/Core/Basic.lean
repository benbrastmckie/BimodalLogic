import Bimodal.ProofSystem
import Bimodal.Semantics.Validity
import Bimodal.Syntax.Context
import Mathlib.Data.List.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finset.Basic

namespace Bimodal.Metalogic.Core

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics

/-- 
Syntactic consistency: A context is consistent if there exists a formula that is not derivable.

This is the standard syntactic notion of consistency: Γ is consistent iff 
there is some formula φ such that Γ ⊬ φ. Equivalently, not all formulas are derivable.
-/
def Consistent (Γ : Context) : Prop :=
  ∃ φ : Formula, ¬Nonempty (DerivationTree Γ φ)

/-- 
Alternative formulation: Γ is consistent iff it does not derive falsum (⊥).

This is equivalent to the standard definition in classical logic with ex-falso.
-/
def Consistent' (Γ : Context) : Prop :=
  ¬Nonempty (DerivationTree Γ .bot)

/-- 
Consistency equivalence: The two definitions of consistency are equivalent.

Note: This requires ex-falso (¬φ → (φ → ψ)) to be available in the proof system.
-/
lemma consistent_iff_consistent' {Γ : Context} :
    Consistent Γ ↔ Consistent' Γ := by
  sorry  -- Proof depends on having ex-falso axiom in TM system

/-- 
Semantic consistency: A context is semantically consistent if it is satisfiable.

This connects syntactic consistency to semantic notions.
-/
def SemanticallyConsistent (Γ : Context) : Prop :=
  satisfiable_abs Γ

/-- 
Logical validity: A formula is valid if it is true in all models.

This is just a reference to the definition in Validity.lean for completeness
of the Core module.
-/
def Valid (φ : Formula) : Prop :=
  Bimodal.Semantics.valid φ

/-- 
Notation for validity: `⊨ φ` means `Valid φ`.
-/
notation:50 "⊨ " φ:50 => Valid φ

/-- 
Maximum consistent set: A consistent set that cannot be extended 
without losing consistency.

This is key notion used in canonical model constructions.
-/
def MaximalConsistent (Γ : Set Formula) : Prop :=
  (∀ φ ∈ Γ, Consistent [φ]) ∧
  ∀ (Δ : Set Formula), Γ ⊂ Δ → ¬(∀ φ ∈ Δ, Consistent [φ])

/-- 
Finite consistency: A set is finitely consistent if every finite subset is consistent.

This is used in completeness proofs with Lindenbaum's lemma.
-/
def FinitelyConsistent (Γ : Set Formula) : Prop :=
  ∀ (Δ : Finset Formula), (∀ φ ∈ Δ, φ ∈ Γ) → Consistent (Finset.toList Δ)

end Bimodal.Metalogic.Core
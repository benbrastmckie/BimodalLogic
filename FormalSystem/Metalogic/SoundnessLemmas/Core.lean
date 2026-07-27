/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Axioms

/-!
# Core Validity Definitions and Swap Infrastructure for Soundness Proofs

Core definitions and lemmas shared across all frame-class variants of the soundness
proof. Contains the local `IsValid` definition and the `truth_at_swap_swap` involution
lemma.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.ProofSystem (Axiom DerivationTree FrameClass)
open FormalSystem.Semantics

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at all model-history-time triples within any shift-closed Omega.

This is a monomorphic definition (fixed to explicit type parameter D) to avoid
universe level mismatch errors.
Per research report Option A: Make D explicit to allow type inference at call sites.

**Note**: Validity quantifies over ALL times,
not just times in the history's domain.

**Omega Parameterization**: Quantifies over all shift-closed Omega sets
and histories in Omega, matching the global `valid` definition in Validity.lean.
-/
def IsValid (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (φ : Formula) :
    Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (_h_mem : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

-- Section variable for theorem signatures
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Auxiliary lemma: If φ is valid, then for any specific tuple (M, Omega, h_sc, τ, h_mem, t),
φ is true at that tuple.

This is just the definition of validity, but stated as a lemma for clarity.
-/
theorem valid_at_triple {φ : Formula} (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (_h_mem : τ ∈ Omega) (t : D) (h_valid : IsValid D φ) :
    TruthAt M Omega τ t φ := h_valid F M Omega _h_sc τ _h_mem t

/--
Helper lemma: TruthAt is invariant under double swap.

This lemma proves that applying swap twice to a formula preserves truth evaluation.
Required because TruthAt is defined by structural recursion, preventing direct use
of the involution property φ.swap.swap = φ via substitution.
-/
theorem truth_at_swap_swap {F : TaskFrame D} (M : TaskModel F)
    (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) (φ : Formula) :
    TruthAt M Omega τ t φ.swapTemporal.swapTemporal ↔ TruthAt M Omega τ t φ := by
  induction φ generalizing τ t with
  | atom p =>
    -- Atom case: swap doesn't change atoms
    simp only [Formula.swapTemporal, TruthAt]
  | bot =>
    -- Bot case: swap doesn't change bot
    simp only [Formula.swapTemporal, TruthAt]
  | imp φ ψ ih_φ ih_ψ =>
    -- Implication case: (φ.swap.swap -> ψ.swap.swap) <-> (φ -> ψ)
    simp only [Formula.swapTemporal, TruthAt]
    constructor <;> intro h <;> intro h_φ
    · exact (ih_ψ τ t).mp (h ((ih_φ τ t).mpr h_φ))
    · exact (ih_ψ τ t).mpr (h ((ih_φ τ t).mp h_φ))
  | box φ ih =>
    -- Box case: box(φ.swap.swap) <-> box φ
    simp only [Formula.swapTemporal, TruthAt]
    constructor <;> intro h σ h_σ_mem
    · exact (ih σ t).mp (h σ h_σ_mem)
    · exact (ih σ t).mpr (h σ h_σ_mem)
  | untl φ ψ ih_φ ih_ψ =>
    -- Until swaps to Since and back (Burgess: untl(event=φ, guard=ψ))
    simp only [Formula.swapTemporal, TruthAt]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mp h_event, fun r hr1 hr2 => (ih_ψ τ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mpr h_event, fun r hr1 hr2 => (ih_ψ τ r).mpr (h_guard r hr1 hr2)⟩
  | snce φ ψ ih_φ ih_ψ =>
    -- Since swaps to Until and back (Burgess: snce(event=φ, guard=ψ))
    simp only [Formula.swapTemporal, TruthAt]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mp h_event, fun r hr1 hr2 => (ih_ψ τ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ τ s).mpr h_event, fun r hr1 hr2 => (ih_ψ τ r).mpr (h_guard r hr1 hr2)⟩


end FormalSystem.Metalogic.SoundnessLemmas

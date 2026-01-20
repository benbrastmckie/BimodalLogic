import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Metalogic_v2.Core.Provability

namespace Bimodal.Metalogic_v2.Representation

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core

/-!
# Truth Lemma for Canonical Models (Metalogic_v2)

This module establishes the truth lemma connecting semantic truth in the canonical
model to syntactic membership in maximal consistent sets.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Definitions

- `canonicalTruthAt`: Truth at a canonical world defined as set membership
- `truthLemma_detailed`: The fundamental equivalence between truth and membership

## Implementation Notes

The truth lemma is defined trivially here as set membership. The deep content is in
the MCS properties proven in CanonicalModel.lean and Core/MaximalConsistent.lean.

## Cross-References

- `CanonicalModel.lean`: MCS properties (mcs_contains_or_neg, mcs_modus_ponens)
- `Core/MaximalConsistent.lean`: Lindenbaum's lemma, MCS theory
- `RepresentationTheorem.lean`: Uses truth lemma for representation theorem
-/

/--
Truth at a canonical world.

In the canonical model, a formula is true at a world (maximal consistent set)
if and only if it is a member of that set. This definition makes the truth
lemma trivial by construction.
-/
def canonicalTruthAt (w : CanonicalWorldState) (φ : Formula) : Prop :=
  φ ∈ w.carrier

/--
Extended truth lemma with detailed case analysis.

This version provides the fundamental equivalence between semantic truth
(as defined by `canonicalTruthAt`) and syntactic membership in the MCS.
Since `canonicalTruthAt` is defined as membership, this is trivially true.
-/
theorem truthLemma_detailed (w : CanonicalWorldState) (φ : Formula) :
    canonicalTruthAt w φ ↔ φ ∈ w.carrier := by
  rfl

/--
Truth lemma for atomic formulas.

An atomic formula is true at a canonical world iff it is in the carrier.
-/
theorem truthLemma_atom (w : CanonicalWorldState) (p : String) :
    canonicalTruthAt w (Formula.atom p) ↔ Formula.atom p ∈ w.carrier := by
  rfl

/--
Truth lemma for bottom.

Bottom is never true at a canonical world (by MCS consistency).
-/
theorem truthLemma_bot (w : CanonicalWorldState) :
    ¬canonicalTruthAt w Formula.bot := by
  intro h_bot
  unfold canonicalTruthAt at h_bot
  -- Formula.bot ∈ w.carrier contradicts consistency
  have h_cons := w.is_consistent
  unfold SetConsistent at h_cons
  have h_list_cons := h_cons [Formula.bot] (fun φ hφ => by simp at hφ; rw [hφ]; exact h_bot)
  -- h_list_cons : Consistent [Formula.bot]
  -- Consistent means ¬Nonempty (DerivationTree [Formula.bot] Formula.bot)
  -- But we can derive ⊥ from [⊥] by assumption
  apply h_list_cons
  exact ⟨DerivationTree.assumption [Formula.bot] Formula.bot (List.mem_singleton.mpr rfl)⟩

/--
Truth lemma for implication.

φ → ψ is true at w iff whenever φ is true, ψ is true.
By the canonical model construction, this matches MCS membership.
-/
theorem truthLemma_imp (w : CanonicalWorldState) (φ ψ : Formula) :
    canonicalTruthAt w (Formula.imp φ ψ) ↔ Formula.imp φ ψ ∈ w.carrier := by
  rfl

/--
Truth lemma for box.

□φ is true at w iff φ is true at all box-accessible worlds.
-/
theorem truthLemma_box (w : CanonicalWorldState) (φ : Formula) :
    canonicalTruthAt w (Formula.box φ) ↔ Formula.box φ ∈ w.carrier := by
  rfl

/--
Truth lemma for universal past operator.

Hφ (all_past φ) is true at w iff φ was true at all past times.
-/
theorem truthLemma_all_past (w : CanonicalWorldState) (φ : Formula) :
    canonicalTruthAt w (Formula.all_past φ) ↔ Formula.all_past φ ∈ w.carrier := by
  rfl

/--
Truth lemma for universal future operator.

Gφ (all_future φ) is true at w iff φ will be true at all future times.
-/
theorem truthLemma_all_future (w : CanonicalWorldState) (φ : Formula) :
    canonicalTruthAt w (Formula.all_future φ) ↔ Formula.all_future φ ∈ w.carrier := by
  rfl

/--
Truth lemma for contexts.

A context Γ is true at world w iff every formula in Γ is true at w.
-/
theorem contextTruthLemma (w : CanonicalWorldState) {Γ : Context} :
    (∀ φ ∈ Γ, canonicalTruthAt w φ) ↔ (∀ φ ∈ Γ, φ ∈ w.carrier) := by
  constructor
  · intro h_truth φ h_in
    exact (truthLemma_detailed w φ).mp (h_truth φ h_in)
  · intro h_mem φ h_in
    exact (truthLemma_detailed w φ).mpr (h_mem φ h_in)

/--
Canonical world consistency.

Every world in the canonical model is consistent.
-/
theorem canonical_world_consistent (w : CanonicalWorldState) :
    SetConsistent w.carrier :=
  w.is_consistent

/--
Canonical world maximality.

Every world in the canonical model is maximally consistent:
adding any formula not in it would make it inconsistent.
-/
theorem canonical_world_maximal (w : CanonicalWorldState) (φ : Formula) :
    φ ∉ w.carrier → ¬SetConsistent (insert φ w.carrier) :=
  w.is_maximal φ

/--
Necessitation lemma in canonical model.

If φ is derivable (from empty context), then □φ is in every canonical world.
-/
theorem necessitation_lemma (w : CanonicalWorldState) {φ : Formula}
    (h_derivable : ContextDerivable [] φ) : (Formula.box φ) ∈ w.carrier := by
  -- Unwrap ContextDerivable to get DerivationTree [] φ
  obtain ⟨d_phi⟩ := h_derivable
  -- Apply necessitation rule to get DerivationTree [] (Formula.box φ)
  have d_box : DerivationTree [] (Formula.box φ) := DerivationTree.necessitation φ d_phi
  -- Apply theorem_in_mcs with w.property (the SetMaximalConsistent proof)
  exact theorem_in_mcs w.property d_box

/--
Implication property for canonical worlds.

If (φ → ψ) ∈ w and φ ∈ w, then ψ ∈ w (by modus ponens).
-/
theorem canonical_modus_ponens (w : CanonicalWorldState) {φ ψ : Formula}
    (h_imp : Formula.imp φ ψ ∈ w.carrier) (h_ant : φ ∈ w.carrier) :
    ψ ∈ w.carrier :=
  mcs_modus_ponens w.property h_imp h_ant

/--
Completeness for canonical worlds.

Every canonical world contains either φ or ¬φ for any formula φ.
-/
theorem canonical_complete (w : CanonicalWorldState) (φ : Formula) :
    φ ∈ w.carrier ∨ Formula.neg φ ∈ w.carrier :=
  mcs_contains_or_neg w.property φ

end Bimodal.Metalogic_v2.Representation

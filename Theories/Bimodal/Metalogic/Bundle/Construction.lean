import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Propositional

/-!
# BFMCS Construction Primitives

This module provides primitive building blocks for BFMCS construction:
- `ContextConsistent`: Consistency predicate for list contexts
- `contextAsSet` / `list_consistent_to_set_consistent`: Bridge from list to set consistency
- `constantBFMCS`: A family assigning the same MCS at every time (T-axiom coherence)
- `lindenbaumMCS` / `lindenbaumMCS_set`: Lindenbaum's lemma helpers

## History

- Task 812: Original single-family construction
- Task 905: Removed FALSE axiom singleFamily_modal_backward_axiom
- Task 912: Removed dead code (`construct_bmcs`, `construct_bmcs_from_set`)
- Task 932: Archived `singleFamilyBFMCS` to Boneyard (sorry-backed, deprecated)

## References

- Modal saturation theory: Bimodal.Metalogic.Bundle.ModalSaturation
- Active completeness chain: Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable {D : Type*} [Preorder D]

/-!
## Stage 1: Extending Context to MCS

Use Lindenbaum's lemma to extend a consistent context to a maximal consistent set.
-/

/--
Convert a list context to a set for use with set-based Lindenbaum.
-/
def contextAsSet (Gamma : List Formula) : Set Formula := {phi | phi ∈ Gamma}

/--
A list context is set-consistent if listing its elements doesn't derive bot.
This follows from list consistency plus finite subset property.
-/
lemma list_consistent_to_set_consistent {Gamma : List Formula}
    (h_cons : Consistent Gamma) :
    SetConsistent (contextAsSet Gamma) := by
  intro L hL
  intro ⟨d⟩
  apply h_cons
  -- L is a list with all elements in Gamma (as a set)
  -- Weaken derivation from L to Gamma
  exact ⟨Bimodal.ProofSystem.DerivationTree.weakening L Gamma Formula.bot d hL⟩

/-!
## Stage 2: Building FMCS from MCS

We create a constant FMCS where the same MCS is used at every time point.
This satisfies all temporal coherence conditions trivially.
-/

/--
Build a constant FMCS from a single MCS.

The family assigns the same MCS to every time point. All temporal coherence
conditions hold trivially because the MCS is the same at all times.

**Key Property**: For this family:
- forward_G: G phi at t and t ≤ t' implies phi at t' - by T-axiom (G phi -> phi)
- backward_H: H phi at t and t' ≤ t implies phi at t' - by T-axiom (H phi -> phi)
-/
noncomputable def constantBFMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    FMCS D where
  mcs := fun _ => M
  is_mcs := fun _ => h_mcs
  forward_G := fun t t' phi _ hG =>
    -- G phi in M and t < t' - need phi in M
    -- Use T-axiom: G phi -> phi
    let h_T := Bimodal.ProofSystem.DerivationTree.axiom []
      (phi.all_future.imp phi) (Bimodal.ProofSystem.Axiom.temp_t_future phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hG
  backward_H := fun t t' phi _ hH =>
    -- H phi in M and t' < t - need phi in M
    -- Use T-axiom: H phi -> phi
    let h_T := Bimodal.ProofSystem.DerivationTree.axiom []
      (phi.all_past.imp phi) (Bimodal.ProofSystem.Axiom.temp_t_past phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hH

/--
The MCS at any time in a constant family is the original MCS.
-/
lemma constantBFMCS_mcs_eq (M : Set Formula) (h_mcs : SetMaximalConsistent M) (t : D) :
    (constantBFMCS M h_mcs (D := D)).mcs t = M := rfl

/-!
## REMOVED: singleFamilyBFMCS (Task 932)

The following were archived to Boneyard/Metalogic_v7/Bundle/SingleFamilyBFMCS.lean:
- singleFamilyBFMCS (sorry in modal_backward)
- singleFamilyBFMCS_eval_family_eq
- singleFamily_modal_backward_axiom (already removed in task 905)

WHY: Single-family modal backward (phi in MCS -> Box phi in MCS) is NOT provable
from first principles and the FALSE axiom was already removed. The sorry-backed
definition was only used by construct_temporal_bfmcs (also archived).

The active completeness chain uses construct_saturated_bfmcs_int from
TemporalCoherentConstruction.lean, which uses multi-family modal saturation.

DO NOT reintroduce single-family BFMCS constructions.
See specs/932_*/reports/ for analysis.
-/

/-!
## Core Definitions

These definitions are used by the active completeness chain.
-/

/--
A context is consistent if no derivation of bot exists.
-/
def ContextConsistent (Gamma : List Formula) : Prop :=
  ¬Nonempty (Bimodal.ProofSystem.DerivationTree Gamma Formula.bot)

/--
Helper: Extract MCS from Lindenbaum result for a list context.

Given a consistent context Gamma, returns the MCS that extends it.
-/
noncomputable def lindenbaumMCS (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    Set Formula :=
  let h_set_cons : SetConsistent (contextAsSet Gamma) := list_consistent_to_set_consistent h_cons
  Classical.choose (set_lindenbaum (contextAsSet Gamma) h_set_cons)

/--
The Lindenbaum MCS contains the original context.
-/
lemma lindenbaumMCS_extends (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    contextAsSet Gamma ⊆ lindenbaumMCS Gamma h_cons :=
  let h_set_cons : SetConsistent (contextAsSet Gamma) := list_consistent_to_set_consistent h_cons
  (Classical.choose_spec (set_lindenbaum (contextAsSet Gamma) h_set_cons)).1

/--
The Lindenbaum MCS is maximal consistent.
-/
lemma lindenbaumMCS_is_mcs (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    SetMaximalConsistent (lindenbaumMCS Gamma h_cons) :=
  let h_set_cons : SetConsistent (contextAsSet Gamma) := list_consistent_to_set_consistent h_cons
  (Classical.choose_spec (set_lindenbaum (contextAsSet Gamma) h_set_cons)).2

/--
Helper: Extract MCS from Lindenbaum result for a set.
-/
noncomputable def lindenbaumMCS_set (S : Set Formula) (h_cons : SetConsistent S) :
    Set Formula :=
  Classical.choose (set_lindenbaum S h_cons)

/--
The Lindenbaum MCS (set version) contains the original set.
-/
lemma lindenbaumMCS_set_extends (S : Set Formula) (h_cons : SetConsistent S) :
    S ⊆ lindenbaumMCS_set S h_cons :=
  (Classical.choose_spec (set_lindenbaum S h_cons)).1

/--
The Lindenbaum MCS (set version) is maximal consistent.
-/
lemma lindenbaumMCS_set_is_mcs (S : Set Formula) (h_cons : SetConsistent S) :
    SetMaximalConsistent (lindenbaumMCS_set S h_cons) :=
  (Classical.choose_spec (set_lindenbaum S h_cons)).2

/-!
## Context Derivability Utilities

These definitions and lemmas support the completeness chain. They were originally
in `Completeness.lean` and relocated here in Task 948 to allow `Representation.lean`
to avoid importing the archived `Completeness.lean`.
-/

/--
Context derivability: there exists a derivation of φ from Γ.
-/
def ContextDerivable (Γ : List Formula) (φ : Formula) : Prop :=
  Nonempty (Bimodal.ProofSystem.DerivationTree Γ φ)

/--
Helper: If `⊬ φ` (not derivable from empty context), then `[φ.neg]` is consistent.

**Proof Strategy**:
Suppose `[φ.neg]` is inconsistent, i.e., `[φ.neg] ⊢ ⊥`.
By deduction theorem, `⊢ φ.neg → ⊥`, i.e., `⊢ ¬¬φ`.
By double negation elimination (classically derivable), `⊢ φ`.
Contradiction with `⊬ φ`.
-/
lemma not_derivable_implies_neg_consistent (φ : Formula)
    (h_not_deriv : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    ContextConsistent [φ.neg] := by
  -- Suppose [φ.neg] is inconsistent
  intro ⟨d_bot⟩
  -- By deduction theorem: ⊢ φ.neg → ⊥ = ⊢ ¬¬φ
  have d_neg_neg : Bimodal.ProofSystem.DerivationTree [] (φ.neg.neg) :=
    Bimodal.Metalogic.Core.deduction_theorem [] φ.neg Formula.bot d_bot
  -- Get double negation elimination: ⊢ ¬¬φ → φ
  have h_dne : Bimodal.ProofSystem.DerivationTree [] (φ.neg.neg.imp φ) :=
    Bimodal.Theorems.Propositional.double_negation φ
  -- Apply modus ponens to get ⊢ φ
  have d_phi : Bimodal.ProofSystem.DerivationTree [] φ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] φ.neg.neg φ h_dne d_neg_neg
  -- Contradiction with h_not_deriv
  exact h_not_deriv ⟨d_phi⟩

/--
Helper: If Γ ⊬ φ, then Γ ∪ {¬φ} (as a list) is consistent.

**Proof Strategy**:
Suppose Γ ++ [φ.neg] ⊢ ⊥.
By deduction theorem repeatedly, we get:
  ⊢ γ₁ → γ₂ → ... → γₙ → ¬φ → ⊥
  = ⊢ γ₁ → ... → ¬¬φ
Combined with Γ ⊢ γᵢ (assumption), we can derive ¬¬φ from Γ.
By DNE, Γ ⊢ φ.
Contradiction.
-/
lemma context_not_derivable_implies_extended_consistent (Γ : List Formula) (φ : Formula)
    (h_not_deriv : ¬ContextDerivable Γ φ) :
    ContextConsistent (Γ ++ [φ.neg]) := by
  -- Suppose Γ ++ [φ.neg] ⊢ ⊥
  intro ⟨d_bot⟩

  -- Step 1: Reorder context using weakening
  -- Γ ++ [φ.neg] and (φ.neg :: Γ) have the same elements, just in different order
  -- Since Γ ++ [φ.neg] ⊆ (φ.neg :: Γ), we can weaken
  have h_subset : Γ ++ [φ.neg] ⊆ φ.neg :: Γ := by
    intro x hx
    simp at hx ⊢
    tauto

  have d_bot_reordered : (φ.neg :: Γ) ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.weakening (Γ ++ [φ.neg]) (φ.neg :: Γ) Formula.bot d_bot h_subset

  -- Step 2: Apply deduction theorem to get Γ ⊢ φ.neg → ⊥ = Γ ⊢ ¬¬φ
  have d_neg_neg : Γ ⊢ φ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem Γ φ.neg Formula.bot d_bot_reordered

  -- Step 3: Get double negation elimination: ⊢ ¬¬φ → φ
  have h_dne : Bimodal.ProofSystem.DerivationTree [] (φ.neg.neg.imp φ) :=
    Bimodal.Theorems.Propositional.double_negation φ

  -- Weaken to Γ
  have h_dne_ctx : Γ ⊢ φ.neg.neg.imp φ :=
    Bimodal.ProofSystem.DerivationTree.weakening [] Γ (φ.neg.neg.imp φ) h_dne (by intro; simp)

  -- Step 4: Apply modus ponens to get Γ ⊢ φ
  have d_phi : Γ ⊢ φ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens Γ φ.neg.neg φ h_dne_ctx d_neg_neg

  -- Contradiction with h_not_deriv
  exact h_not_deriv ⟨d_phi⟩

/-!
## Summary

This module provides:
- `ContextConsistent`: Consistency predicate for list contexts
- `ContextDerivable`: Context derivability predicate (Task 948)
- `not_derivable_implies_neg_consistent`: Non-derivability implies neg consistency (Task 948)
- `context_not_derivable_implies_extended_consistent`: Context extension consistency (Task 948)
- `contextAsSet`, `list_consistent_to_set_consistent`: Set-based consistency bridge
- `constantBFMCS`: Constant-time MCS family (temporal coherence via T-axioms)
- `lindenbaumMCS` / `lindenbaumMCS_set`: Lindenbaum's lemma helpers

**Sorry Status**: ZERO sorries in this module.
(singleFamilyBFMCS with its sorry was archived to Boneyard in task 932.)

**History (tasks 905, 912, 932, 948)**:
- Task 905: Removed FALSE axiom singleFamily_modal_backward_axiom
- Task 912: Removed dead code (construct_bmcs, construct_bmcs_from_set)
- Task 932: Archived singleFamilyBFMCS to Boneyard (sorry-backed, deprecated)
- Task 948: Relocated ContextDerivable and consistency lemmas from Completeness.lean
-/

end Bimodal.Metalogic.Bundle

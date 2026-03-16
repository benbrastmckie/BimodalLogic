import Bimodal.FrameConditions.Validity
import Bimodal.Metalogic.Soundness

/-!
# Parameterized Soundness

This module provides soundness theorems for the TM proof system using
typeclass constraints. It bridges the existing soundness proofs to the
new typeclass-based frame condition architecture.

## Main Definitions

- `soundness_over D`: Soundness theorem for derivations over temporal domain D
- `soundness_linear`: Soundness using LinearTemporalFrame constraint
- `soundness_dense`: Soundness using DenseTemporalFrame constraint
- `soundness_discrete`: Soundness using DiscreteTemporalFrame constraint

## Design Notes

The existing soundness proofs in `Bimodal.Metalogic.Soundness` already
quantify over types with the appropriate constraints. This module provides
wrappers that use the typeclass architecture for cleaner API.

All 21 axioms are covered:
- 18 base axioms: valid on all LinearTemporalFrame
- 1 density axiom (DN): valid on DenseTemporalFrame
- 2 discreteness axioms (DF, seriality): valid on DiscreteTemporalFrame

## References

- Task 978: Typeclass-based frame condition architecture
- `Bimodal.Metalogic.Soundness`: Existing soundness proofs
-/

namespace Bimodal.FrameConditions

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem
open Bimodal.Metalogic

/-! ## Parameterized Soundness -/

/--
Soundness over a specific temporal domain D.

If `Γ ⊢ φ` (φ is derivable from Γ), then for any model over D,
if all formulas in Γ are true, then φ is true.
-/
def soundness_over (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (Γ : Context) (φ : Formula) (d : DerivationTree Γ φ) :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  fun F M Omega h_sc τ h_mem t h_ctx =>
    soundness Γ φ d D F M Omega h_sc τ h_mem t h_ctx

/-! ## Frame-Class Soundness Theorems -/

/--
Soundness for linear temporal frames.

All base axioms (17 axioms) are sound on any linear temporal frame.
This is the strongest soundness theorem, applying to the widest class of frames.
-/
theorem soundness_linear {Γ : Context} {φ : Formula} (d : DerivationTree Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [LinearTemporalFrame D] :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  soundness_over D Γ φ d

/--
Soundness for dense temporal frames.

All base axioms plus the density axiom (DN: Fφ → FFφ) are sound on dense frames.
-/
theorem soundness_dense {Γ : Context} {φ : Formula} (d : DerivationTree Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  soundness_over D Γ φ d

/--
Soundness for discrete temporal frames.

All base axioms plus discrete axioms (DF, seriality) are sound on discrete frames.
-/
theorem soundness_discrete {Γ : Context} {φ : Formula} (d : DerivationTree Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  soundness_over D Γ φ d

/-! ## Axiom Validity by Frame Class -/

/--
Base axioms are valid on all linear temporal frames.
-/
theorem axiom_base_valid_linear {φ : Formula} (ax : Axiom φ) (h_base : ax.isBase)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [LinearTemporalFrame D] :
    valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  exact axiom_base_valid ax h_base D F M Omega h_sc τ h_mem t

/--
Dense-compatible axioms are valid on dense temporal frames.
-/
theorem axiom_valid_dense_fc {φ : Formula} (ax : Axiom φ) (h_dc : ax.isDenseCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] :
    valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  exact axiom_valid_dense ax h_dc D F M Omega h_sc τ h_mem t

/--
Discrete-compatible axioms are valid on discrete temporal frames.
-/
theorem axiom_valid_discrete_fc {φ : Formula} (ax : Axiom φ) (h_dc : ax.isDiscreteCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] :
    valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  -- Use axiom_valid_discrete from Soundness.lean
  have h := axiom_valid_discrete ax h_dc
  exact h D F M Omega h_sc τ h_mem t

/-! ## Soundness over Int -/

/--
Soundness over Int (discrete integer time).

This is the concrete instantiation of soundness for the standard discrete model.
-/
theorem soundness_Int {Γ : Context} {φ : Formula} (d : DerivationTree Γ φ) :
    ∀ (F : TaskFrame Int) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : Int),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  soundness_over Int Γ φ d

/-! ## Axiom Coverage Summary

All 21 axioms are covered by the soundness theorems:

**Base Axioms (18)** - valid on all LinearTemporalFrame:
1. prop_k, prop_s: Propositional axioms
2. ex_falso, peirce: Classical logic
3. modal_t, modal_4, modal_b, modal_5_collapse: S5 modal axioms
4. modal_k_dist: Modal K distribution
5. temp_k_dist, temp_4, temp_t_future, temp_t_past: Temporal axioms
6. temp_a, temp_l: Temporal interaction
7. modal_future, temp_future: Modal-temporal interaction
8. temp_linearity: Linear time axiom

**Dense Axiom (1)** - valid on DenseTemporalFrame:
19. density (DN): Fφ → FFφ

**Discrete Axioms (3)** - valid on DiscreteTemporalFrame:
20. discreteness_forward (DF)
21. seriality_future, seriality_past

Note: Under reflexive semantics, all axioms are trivially valid (witness t = current time),
but the frame class constraints are still meaningful for the structural properties
they impose on the temporal domain.
-/

end Bimodal.FrameConditions

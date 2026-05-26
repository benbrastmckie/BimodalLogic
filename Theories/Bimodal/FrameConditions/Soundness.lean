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

The `DerivationTree` is now parameterized over `FrameClass`, replacing
the previous ad-hoc predicates `isDenseCompatible` and `isDiscreteCompatible`.

All 21 axioms are covered:
- 18 base axioms: valid on all LinearTemporalFrame
- 1 density axiom (DN): valid on DenseTemporalFrame
- 2 discreteness axioms (DF, seriality): valid on DiscreteTemporalFrame

## References

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

If `Γ ⊢ φ` (φ is derivable from Γ at FrameClass.Base), then for any model over D,
if all formulas in Γ are true, then φ is true.
-/
def soundness_over (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] (Γ : Context) (φ : Formula) (d : DerivationTree FrameClass.Base Γ φ) :
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
theorem soundness_linear {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Base Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [LinearTemporalFrame D] :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  soundness_over D Γ φ d

/--
Soundness for dense temporal frames.

All base axioms plus the density axiom (DN: Fφ → FFφ) are sound on dense frames.
-/
theorem soundness_dense {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Dense Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  fun F M Omega h_sc τ h_mem t h_ctx =>
    Metalogic.soundness_dense Γ φ d D F M Omega h_sc τ h_mem t h_ctx

/--
Soundness for discrete temporal frames.

All base axioms plus discrete axioms (DF, seriality) are sound on discrete frames.
-/
theorem soundness_discrete {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Discrete Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D]
    [DiscreteTemporalFrame D] :
    ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  fun F M Omega h_sc τ h_mem t h_ctx =>
    Metalogic.soundness_discrete Γ φ d D F M Omega h_sc τ h_mem t h_ctx

/-! ## Axiom Validity by Frame Class -/

/--
Base axioms are valid on all linear temporal frames.
-/
theorem axiom_base_valid_linear {φ : Formula} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ FrameClass.Base)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [LinearTemporalFrame D] :
    valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  exact axiom_valid ax h_fc D F M Omega h_sc τ h_mem t

/--
Dense-compatible axioms are valid on dense temporal frames.
-/
theorem axiom_dense_valid_fc {φ : Formula} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ FrameClass.Dense)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] :
    valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  exact axiom_dense_valid ax h_fc D F M Omega h_sc τ h_mem t

/--
Discrete-compatible axioms are valid on discrete temporal frames.
-/
theorem axiom_discrete_valid_fc {φ : Formula} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ FrameClass.Discrete)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] :
    valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  -- Use axiom_discrete_valid from Soundness.lean
  have h := axiom_discrete_valid ax h_fc
  exact h D F M Omega h_sc τ h_mem t

/-! ## Soundness over Int -/

/--
Soundness over Int (discrete integer time).

This is the concrete instantiation of soundness for the standard discrete model.
-/
theorem soundness_Int {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Discrete Γ φ) :
    ∀ (F : TaskFrame Int) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : Int),
      (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ :=
  fun F M Omega h_sc τ h_mem t h_ctx =>
    Metalogic.soundness_discrete Γ φ d Int F M Omega h_sc τ h_mem t h_ctx

/-! ## Axiom Coverage Summary

All 21 axioms are covered by the soundness theorems:

**Base Axioms (18)** - valid on all LinearTemporalFrame:
1. prop_k, prop_s: Propositional axioms
2. ex_falso, peirce: Classical logic
3. modal_t, modal_4, modal_b, modal_5_collapse: S5 modal axioms
4. modal_k_dist: Modal K distribution
5. temp_k_dist, temp_4: Temporal axioms
6. temp_a, temp_a_dual, temp_l: Temporal interaction
7. modal_future: Modal-temporal interaction (temp_future now derived from MF + T + Modal 4)
8. temp_linearity: Linear time axiom

**Dense Axiom (1)** - valid on DenseTemporalFrame:
19. density (DN): Fφ → FFφ

**Discrete Axioms (3)** - valid on DiscreteTemporalFrame:
20. discreteness_forward (DF)
21. seriality_future, seriality_past

Note: Under strict semantics (G/H quantify over s > t / s < t), frame class constraints
are essential for axiom validity, not merely structural.
-/

end Bimodal.FrameConditions

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.FrameConditions.Validity
import FormalSystem.Metalogic.Soundness

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

The existing soundness proofs in `FormalSystem.Metalogic.Soundness` already
quantify over types with the appropriate constraints. This module provides
wrappers that use the typeclass architecture for cleaner API.

The `DerivationTree` is now parameterized over `FrameClass`, replacing
the previous ad-hoc predicates `isDenseCompatible` and `isDiscreteCompatible`.

Axiom coverage is by quantification, not enumeration: `axiom_base_valid_linear` and its dense
and discrete siblings take `ax : Axiom φ` and so cover every constructor of the relevant class.
By `Axiom.minFrameClass` that is 37 base + 2 dense + 3 discrete + 3 Dedekind = 45.

## References

- `FormalSystem.Metalogic.Soundness`: Existing soundness proofs
-/

namespace FormalSystem.FrameConditions

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.ProofSystem
open FormalSystem.Metalogic

/-! ## Parameterized Soundness -/

/--
Soundness over a specific temporal domain D.

If `Γ ⊢ φ` (φ is derivable from Γ at FrameClass.Base), then for any model over D,
if all formulas in Γ are true, then φ is true.

**Why `FrameClass.Base` is essential here**: this is a thin `D`-parameterised wrapper around
`Metalogic.soundness`, which is a `Base` theorem — the conclusion holds on *every* `ParamTaskFrame D`
with no order-theoretic side conditions, and that is exactly the class of derivations `Base`
admits. The wider classes have their own wrappers (`soundness_dense`, `soundness_discrete`).
-/
theorem soundness_over (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] (Γ : Context) (φ : Formula) (d : DerivationTree FrameClass.Base Γ φ) :
    ∀ (F : ParamTaskFrame D) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ :=
  fun F M τ h_mem t h_ctx =>
    soundness Γ φ d F M τ h_mem t h_ctx

/-! ## Frame-Class Soundness Theorems -/

/--
Soundness for linear temporal frames.

All base axioms (17 axioms) are sound on any linear temporal frame.
This is the strongest soundness theorem, applying to the widest class of frames.

**Why `FrameClass.Base` is essential here**: "widest class of frames" is the point — a
derivation admitted at a wider `fc` may use an axiom that is unsound on a general linear frame,
so widening the derivation's frame class would falsify the statement.
-/
theorem soundness_linear {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Base Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [LinearTemporalFrame D] :
    ∀ (F : ParamTaskFrame D) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ :=
  soundness_over D Γ φ d

/--
Soundness for dense temporal frames.

All base axioms plus the density axiom (DN: Fφ → FFφ) are sound on dense frames.
-/
theorem soundness_dense {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Dense Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] :
    ∀ (F : ParamTaskFrame D) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ :=
  fun F M τ h_mem t h_ctx =>
    Metalogic.soundness_dense Γ φ d F M τ h_mem t h_ctx

/--
Soundness for discrete temporal frames.

All base axioms plus discrete axioms (DF, seriality) are sound on discrete frames.
-/
theorem soundness_discrete {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Discrete Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D]
    [DiscreteTemporalFrame D] :
    ∀ (F : ParamTaskFrame D) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ :=
  fun F M τ h_mem t h_ctx =>
    Metalogic.soundness_discrete Γ φ d F M τ h_mem t h_ctx

/-! ## Axiom Validity by Frame Class -/

/--
Base axioms are valid on all linear temporal frames.

**Why `FrameClass.Base` is essential here**: `h_fc : ax.minFrameClass ≤ FrameClass.Base` is the
admissibility bound that makes "valid on *all* linear temporal frames" true. A `Dense` or
`Discrete` axiom is not.
-/
theorem axiom_base_valid_linear {φ : Formula} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ FrameClass.Base)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [LinearTemporalFrame D] :
    ValidOver D φ := by
  intro F M τ h_mem t
  exact axiom_valid ax h_fc F M τ h_mem t

/--
Dense-compatible axioms are valid on dense temporal frames.
-/
theorem axiom_dense_valid_fc {φ : Formula} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ FrameClass.Dense)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] :
    ValidOver D φ := by
  intro F M τ h_mem t
  exact axiom_dense_valid ax h_fc F M τ h_mem t

/--
Discrete-compatible axioms are valid on discrete temporal frames.
-/
theorem axiom_discrete_valid_fc {φ : Formula} (ax : Axiom φ)
    (h_fc : ax.minFrameClass ≤ FrameClass.Discrete)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] :
    ValidOver D φ := by
  intro F M τ h_mem t
  -- Use axiom_discrete_valid from Soundness.lean
  have h := axiom_discrete_valid ax h_fc
  exact h F M τ h_mem t

/-! ## Soundness over Int -/

/--
Soundness over Int (discrete integer time).

This is the concrete instantiation of soundness for the standard discrete model.
-/
theorem soundness_Int {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Discrete Γ φ) :
    ∀ (F : ParamTaskFrame Int) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : Int),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ :=
  fun F M τ h_mem t h_ctx =>
    Metalogic.soundness_discrete Γ φ d F M τ h_mem t h_ctx

/-! ## Axiom Coverage Summary

Every axiom of a frame class is covered by that class's soundness theorem, **by
quantification rather than by enumeration**: `axiom_base_valid_linear`, `axiom_dense_valid_fc`
and `axiom_discrete_valid_fc` each take `ax : Axiom φ` and discharge it for the whole class.
There is nothing to keep in step one constructor at a time.

The live counts, per `Axiom.minFrameClass` (`ProofSystem/Axioms.lean`), are 45 constructors in
nine layers:

- **Base (37)** - valid on all LinearTemporalFrame: propositional (4), S5 modal (5),
  Burgess-Xu temporal (18), additional Burgess-Xu temporal (4), modal-temporal interaction (1),
  uniformity (5).
- **Dense (2)** - valid on DenseTemporalFrame: `density`, `dense_indicator`.
- **Discrete (3)** - valid on DiscreteTemporalFrame: `prior_UZ`, `prior_SZ`, `z1`.
- **Dedekind (3)** - Reynolds' definable-gap axioms: `prior_U_gap`, `prior_S_gap`, `sep`.

This section previously carried a hand-maintained list of 21 named axioms, including
`temp_k_dist`, `temp_4`,
`temp_a`, `temp_a_dual`, `temp_l`, `temp_future`, `discreteness_forward`, `seriality_future` and
`seriality_past` -- none of which is a constructor of `Axiom` any more. The enumeration is
deliberately not rebuilt: an enumeration is what went stale, and the theorems above never needed
one.

Note: Under strict semantics (G/H quantify over s > t / s < t), frame class constraints
are essential for axiom validity, not merely structural.
-/

end FormalSystem.FrameConditions

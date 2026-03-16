import Bimodal.FrameConditions.Soundness
import Bimodal.ProofSystem.Axioms

/-!
# Axiom Compatibility Typeclass

This module defines a typeclass for axiom-frame compatibility, providing a
type-safe way to express which axioms are valid on which frame classes.

## Main Definitions

- `AxiomCompatible`: Typeclass relating axioms to frame classes
- Instances for all 21 axioms
- Monotonicity lemmas (base compatibility implies dense/discrete compatibility)

## Design Notes

The `AxiomCompatible` typeclass bundles:
1. A proof that the axiom is valid over the frame class
2. Type-level documentation of the compatibility relationship

This enables:
- Generic reasoning about axiom validity
- Type-safe axiom selection for soundness/completeness proofs
- Clear documentation of frame condition requirements

## Axiom Classification

| Frame Class | Axioms | Count |
|-------------|--------|-------|
| Linear (Base) | prop_k, prop_s, ex_falso, peirce, modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist, temp_k_dist, temp_4, temp_t_future, temp_t_past, temp_a, temp_l, modal_future, temp_future, temp_linearity | 18 |
| Dense | density | 1 |
| Discrete | discreteness_forward, seriality_future, seriality_past | 3 |

Total: 21 axioms

## References

- Task 978: Typeclass-based frame condition architecture
- `Bimodal.ProofSystem.Axioms`: Axiom definitions and frame class enum
-/

namespace Bimodal.FrameConditions

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem

/-! ## Axiom Compatibility Typeclass -/

/--
Typeclass expressing that an axiom is compatible with (valid on) a frame class.

An axiom φ is compatible with a frame class if it is valid over all frames
in that class. This is a Prop-valued class that bundles:
1. The validity proof
2. Type-level documentation of the relationship

**Usage**:
```lean
-- Check if prop_k is compatible with LinearTemporalFrame
example : AxiomLinearCompatible (Axiom.prop_k p q r) := inferInstance

-- Use in generic proofs
theorem foo [AxiomLinearCompatible ax] : ... := ...
```
-/
class AxiomLinearCompatible {φ : Formula} (ax : Axiom φ) : Prop where
  /-- The axiom is valid over all linear temporal frames -/
  valid : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
            [LinearTemporalFrame D], valid_over D φ

/--
Axiom compatible with dense temporal frames.
-/
class AxiomDenseCompatible {φ : Formula} (ax : Axiom φ) : Prop where
  /-- The axiom is valid over all dense temporal frames -/
  valid : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
            [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
            [DenseTemporalFrame D], valid_over D φ

/--
Axiom compatible with discrete temporal frames.
-/
class AxiomDiscreteCompatible {φ : Formula} (ax : Axiom φ) : Prop where
  /-- The axiom is valid over all discrete temporal frames -/
  valid : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
            [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
            [DiscreteTemporalFrame D], valid_over D φ

/-! ## Monotonicity: Linear → Dense/Discrete -/

/--
Linear-compatible axioms are also dense-compatible.

This is the frame class monotonicity: if an axiom is valid on all linear frames,
it is valid on all dense frames (which are a subset).
-/
instance {φ : Formula} (ax : Axiom φ) [h : AxiomLinearCompatible ax] :
    AxiomDenseCompatible ax where
  valid := fun D _ _ _ _ _ _ _ _ =>
    h.valid D

/--
Linear-compatible axioms are also discrete-compatible.

This is the frame class monotonicity: if an axiom is valid on all linear frames,
it is valid on all discrete frames (which are a subset).
-/
instance {φ : Formula} (ax : Axiom φ) [h : AxiomLinearCompatible ax] :
    AxiomDiscreteCompatible ax where
  valid := fun D _ _ _ _ _ _ _ _ _ _ =>
    h.valid D

/-! ## Base Axiom Instances (18 axioms)

All base axioms are compatible with LinearTemporalFrame (and hence with
DenseTemporalFrame and DiscreteTemporalFrame by monotonicity).
-/

instance (φ ψ χ : Formula) : AxiomLinearCompatible (Axiom.prop_k φ ψ χ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.prop_k φ ψ χ) (by simp [Axiom.isBase]) D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.prop_s φ ψ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.prop_s φ ψ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_t φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.modal_t φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_4 φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.modal_4 φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_b φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.modal_b φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_5_collapse φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.modal_5_collapse φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.ex_falso φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.ex_falso φ) (by simp [Axiom.isBase]) D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.peirce φ ψ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.peirce φ ψ) (by simp [Axiom.isBase]) D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.modal_k_dist φ ψ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.modal_k_dist φ ψ) (by simp [Axiom.isBase]) D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.temp_k_dist φ ψ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_k_dist φ ψ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.temp_4 φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_4 φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.temp_t_future φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_t_future φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.temp_t_past φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_t_past φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.temp_a φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_a φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.temp_l φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_l φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_future φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.modal_future φ) (by simp [Axiom.isBase]) D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.temp_future φ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_future φ) (by simp [Axiom.isBase]) D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.temp_linearity φ ψ) where
  valid := fun D _ _ _ _ => axiom_base_valid_linear (Axiom.temp_linearity φ ψ) (by simp [Axiom.isBase]) D

/-! ## Dense Axiom Instance (1 axiom)

The density axiom is compatible with DenseTemporalFrame.
-/

instance (φ : Formula) : AxiomDenseCompatible (Axiom.density φ) where
  valid := fun D _ _ _ _ _ _ _ _ => axiom_valid_dense_fc (Axiom.density φ) (by simp [Axiom.isDenseCompatible]) D

/-! ## Discrete Axiom Instances (3 axioms)

The discrete axioms are compatible with DiscreteTemporalFrame.
-/

instance (φ : Formula) : AxiomDiscreteCompatible (Axiom.discreteness_forward φ) where
  valid := fun D _ _ _ _ _ _ _ _ _ _ =>
    axiom_valid_discrete_fc (Axiom.discreteness_forward φ) (by simp [Axiom.isDiscreteCompatible]) D

instance : AxiomDiscreteCompatible Axiom.seriality_future where
  valid := fun D _ _ _ _ _ _ _ _ _ _ =>
    axiom_valid_discrete_fc Axiom.seriality_future (by simp [Axiom.isDiscreteCompatible]) D

instance : AxiomDiscreteCompatible Axiom.seriality_past where
  valid := fun D _ _ _ _ _ _ _ _ _ _ =>
    axiom_valid_discrete_fc Axiom.seriality_past (by simp [Axiom.isDiscreteCompatible]) D

/-! ## Compatibility Theorems -/

/--
If an axiom is base (neither density nor discreteness specific),
then it is linear-compatible.
-/
theorem axiom_base_implies_linear_compatible {φ : Formula} (ax : Axiom φ) (h : ax.isBase) :
    AxiomLinearCompatible ax := by
  constructor
  intro D _ _ _ _
  exact axiom_base_valid_linear ax h D

/--
Consistency check: discreteness_forward is NOT dense-compatible.
-/
theorem discreteness_forward_not_dense_compatible (φ : Formula) :
    (Axiom.discreteness_forward φ).isDenseCompatible = False := rfl

/--
Consistency check: density is NOT discrete-compatible.
-/
theorem density_not_discrete_compatible (φ : Formula) :
    (Axiom.density φ).isDiscreteCompatible = False := rfl

end Bimodal.FrameConditions

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.FrameConditions.Soundness
import FormalSystem.ProofSystem.Axioms

/-!
# Axiom Compatibility Typeclass

This module defines a typeclass for axiom-frame compatibility, providing a
type-safe way to express which axioms are valid on which frame classes.

## Main Definitions

- `AxiomCompatible`: Typeclass relating axioms to frame classes
- Twelve explicit `AxiomLinearCompatible` instances (`prop_k`, `prop_s`, `modal_t`, `modal_4`,
  `modal_b`, `modal_5_collapse`, `ex_falso`, `peirce`, `modal_k_dist`, `serial_future`,
  `serial_past`, `modal_future`) -- **not** one per axiom. The general route for the remaining
  base axioms is `axiom_base_implies_linear_compatible`, which quantifies over `ax : Axiom φ`
  and so covers all 37 base constructors without enumerating them.
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

By frame class, per `Axiom.minFrameClass` (`ProofSystem/Axioms.lean`), out of 45 constructors
in nine layers:

- Base, 37 axioms: layers 1-5 (propositional 4, S5 modal 5, BX temporal 18, additional BX
  temporal 4, modal-temporal interaction 1, uniformity 5)
- Dense, 2 axioms: `density`, `dense_indicator`
- Discrete, 3 axioms: `prior_UZ`, `prior_SZ`, `z1`
- Dedekind, 3 axioms: `prior_U_gap`, `prior_S_gap`, `sep`

The enumeration this section used to carry named `temp_k_dist`, `temp_4`, `temp_a`, `temp_a_dual`,
`temp_l`, `temp_future`, `discreteness_forward`, `seriality_future` and `seriality_past` -- none of
which is a constructor of `Axiom` any more. It is replaced by the class counts above rather than
re-enumerated, because an enumeration is what went stale.

Total: 19 axioms (2 T-axioms removed under strict semantics)

## References

- `FormalSystem.ProofSystem.Axioms`: Axiom definitions and frame class enum
-/

namespace FormalSystem.FrameConditions

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.ProofSystem

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
            [Nontrivial D] [LinearTemporalFrame D] (F : FrameOver (TemporalOrder.of D)), F.toTaskFrame.ValidOn φ

/--
Axiom compatible with dense temporal frames.
-/
class AxiomDenseCompatible {φ : Formula} (ax : Axiom φ) : Prop where
  /-- The axiom is valid over all dense temporal frames -/
  valid : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
            [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
            [DenseTemporalFrame D] (F : FrameOver (TemporalOrder.of D)), F.toTaskFrame.ValidOn φ

/--
Axiom compatible with discrete temporal frames.
-/
class AxiomDiscreteCompatible {φ : Formula} (ax : Axiom φ) : Prop where
  /-- The axiom is valid over all discrete temporal frames -/
  valid : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
            [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D]
              [IsSuccArchimedean D]
            [DiscreteTemporalFrame D] (F : FrameOver (TemporalOrder.of D)), F.toTaskFrame.ValidOn φ

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
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.prop_k φ ψ χ) trivial D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.prop_s φ ψ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.prop_s φ ψ) trivial D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_t φ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.modal_t φ) trivial D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_4 φ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.modal_4 φ) trivial D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_b φ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.modal_b φ) trivial D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_5_collapse φ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.modal_5_collapse φ) trivial D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.ex_falso φ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.ex_falso φ) trivial D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.peirce φ ψ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.peirce φ ψ) trivial D

instance (φ ψ : Formula) : AxiomLinearCompatible (Axiom.modal_k_dist φ ψ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.modal_k_dist φ ψ) trivial D

instance : AxiomLinearCompatible (Axiom.serial_future) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.serial_future) trivial D

instance : AxiomLinearCompatible (Axiom.serial_past) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.serial_past) trivial D

instance (φ : Formula) : AxiomLinearCompatible (Axiom.modal_future φ) where
  valid := fun D _ _ _ _ _ => axiom_base_valid_linear (Axiom.modal_future φ) trivial D

-- Note: AxiomLinearCompatible instance for Axiom.temp_future removed -- TF is now derived.

/-! ## Discrete Axiom Instances

Under BX, discrete axioms are separate extension points (not in base system).
-/

/-! ## Compatibility Theorems -/

/--
If an axiom is base, then it is linear-compatible.
Under BX, all axioms are base.

**Why `FrameClass.Base` is essential here**: linear-compatibility means validity over every
linear temporal frame, which is precisely the `Base` admissibility condition. The hypothesis is
the definition of the class being characterised, not an incidental pin.
-/
theorem axiom_base_implies_linear_compatible {φ : Formula} (ax : Axiom φ)
    (h : ax.minFrameClass ≤ FrameClass.Base) :
    AxiomLinearCompatible ax := by
  constructor
  intro D _ _ _ _ _
  exact axiom_base_valid_linear ax h D

end FormalSystem.FrameConditions

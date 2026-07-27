/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred
import Mathlib.Order.SuccPred.LinearLocallyFinite
import Mathlib.Algebra.Order.Ring.Rat

/-!
# Frame Condition Typeclasses

This module defines typeclasses for temporal frame conditions, providing a clean
interface for the TM proof system's validity, soundness, and completeness theorems.

## Main Definitions

- `LinearTemporalFrame`: Bundle typeclass for types with the required temporal frame structure
- `SerialFrame`: Marker class for frames with no maximum or minimum elements
- `DenseTemporalFrame`: Marker class for densely ordered frames
- `DiscreteTemporalFrame`: Marker class for discrete frames with successors/predecessors

## Design Approach

These are **marker typeclasses** that serve as convenient bundles for the underlying
Mathlib typeclasses required by temporal logic semantics. They do NOT extend the
underlying typeclasses (which would cause diamond inheritance issues), but rather
require them as instance parameters.

The pattern is:
```
class DenseTemporalFrame (D : Type) ... : Prop
```

This allows:
1. Easy instantiation: `instance : DenseTemporalFrame MyType := ⟨⟩`
2. Automatic constraint propagation via instance parameters
3. Clean API for validity/soundness/completeness theorems

## Typeclass Hierarchy

```
LinearTemporalFrame (AddCommGroup + LinearOrder + IsOrderedAddMonoid)
        |
   SerialFrame (+ Nontrivial + NoMaxOrder + NoMinOrder)
      /    \
DenseTemporalFrame       DiscreteTemporalFrame
(+ DenselyOrdered)        (+ SuccOrder + PredOrder + IsSuccArchimedean)
```

## Standard Instances

- `Int` is a `DiscreteTemporalFrame` (with its standard instances)
- Custom quotient types can be made `DenseTemporalFrame` when they satisfy `DenselyOrdered`

## Note on Rat

Mathlib's `Rat` does not have a direct `DenselyOrdered` instance available through
the standard imports. For dense completeness proofs, the dense property comes from
the canonical quotient construction (`TimelineQuot`) which has its own `DenselyOrdered`
instance built into the construction.

## References

- Mathlib: `DenselyOrdered`, `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`
-/

namespace FormalSystem.FrameConditions

/-! ## Base Typeclass: LinearTemporalFrame -/

/--
Base typeclass for linear temporal frames.

A linear temporal frame is a type with:
- `AddCommGroup D`: Additive abelian group structure (for time shifts)
- `LinearOrder D`: Total order on times
- `IsOrderedAddMonoid D`: Order compatibility with addition

This corresponds to the temporal domain D in the JPL paper's task semantics.

**Usage**: This is a marker typeclass. To declare that a type is a linear temporal frame,
ensure the required instances exist and declare: `instance : LinearTemporalFrame MyType := ⟨⟩`
-/
class LinearTemporalFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : Prop

/-! ## Serial Frame -/

/--
Serial temporal frame: a linear temporal frame with no maximum or minimum elements.

This captures the frame condition for the seriality axioms:
- `seriality_future`: F(neg bot) (there exists a future time)
- `seriality_past`: P(neg bot) (there exists a past time)

Under strict semantics (G/H quantify over s > t / s < t), the `NoMaxOrder` and
`NoMinOrder` conditions are essential: they ensure witnesses exist for the
seriality axioms F(neg bot) and P(neg bot).
-/
class SerialFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] : Prop where
  toLinearTemporalFrame : LinearTemporalFrame D := {}

instance (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SerialFrame D] : LinearTemporalFrame D :=
  SerialFrame.toLinearTemporalFrame

/-! ## Dense Temporal Frame -/

/--
Dense temporal frame: a serial frame with densely ordered times.

This captures the frame condition for the density axiom DN: `Fφ → FFφ`.

**Frame Condition**: For all s < t, there exists u with s < u < t.

**Note**: The `DenselyOrdered D` constraint must be provided by the caller.
For the canonical quotient construction used in completeness proofs, this
is built into the quotient definition.
-/
class DenseTemporalFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D] : Prop where
  toSerialFrame : SerialFrame D := {}
  toSerialFrame' : LinearTemporalFrame D := {}

instance (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] : SerialFrame D :=
  DenseTemporalFrame.toSerialFrame

/-! ## Discrete Temporal Frame -/

/--
Discrete temporal frame: a serial frame with successor and predecessor structure.

This captures the frame conditions for the discreteness axioms:
- `discreteness_forward` (DF): (Ftop and phi and Hphi) -> F(Hphi)
- `discreteness_backward` (DP): derivable via temporal duality

**Frame Conditions**:
- `SuccOrder D`: Every element has an immediate successor
- `PredOrder D`: Every element has an immediate predecessor
- `IsSuccArchimedean D`: Successor iteration reaches all greater elements
-/
class DiscreteTemporalFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] :
      Prop where
  toSerialFrame : SerialFrame D := {}
  toSerialFrame' : LinearTemporalFrame D := {}

instance (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] : SerialFrame D :=
  DiscreteTemporalFrame.toSerialFrame

/-! ## Dedekind Temporal Frame -/

/--
Dedekind temporal frame: a serial frame whose temporal order has the least-upper-bound
property.

**READ THIS FIRST — this class is a side-car, not the load-bearing layer.** Neither
`FormalSystem/Metalogic/Soundness.lean` nor `FormalSystem/Metalogic/BXCanonical/Completeness.lean`
consumes `DedekindTemporalFrame`, exactly as neither consumes `DenseTemporalFrame` or
`DiscreteTemporalFrame`. Those theorems consume the raw instance-binder validity predicates in
`FormalSystem/Semantics/Validity.lean` (`ValidDedekind`, `ValidDedekindDense`). This class
exists for parity with the four markers above and for callers that want a named bundle; adding
a field here changes nothing about what is provable.

**Frame Condition**: every nonempty bounded-above subset of `D` has a least upper bound.

Unlike `DenseTemporalFrame`, `DenselyOrdered D` is **not** required — matching the binder set
of `ValidDedekind`. `ℤ` satisfies this condition (Mathlib gives it a
`ConditionallyCompleteLinearOrder` instance). For the real-flow class, add `[DenselyOrdered D]`
to the binders, which corresponds to `ValidDedekindDense`.

**Source**: Reynolds 1992 (printed p.168-169), the axiomatization US/R for real flow.
-/
class DedekindTemporalFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] : Prop where
  /-- Every nonempty bounded-above subset has a least upper bound. -/
  lub_exists : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x
  toSerialFrame : SerialFrame D := {}
  toSerialFrame' : LinearTemporalFrame D := {}

instance (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D]
    [DedekindTemporalFrame D] : SerialFrame D :=
  DedekindTemporalFrame.toSerialFrame

/-! ## Instance Relationships -/

/--
Every `DenseTemporalFrame` is a `SerialFrame`.
This is automatic via the instance above.
-/
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] : SerialFrame D := inferInstance

/--
Every `DiscreteTemporalFrame` is a `SerialFrame`.
This is automatic via the instance above.
-/
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] : SerialFrame D := inferInstance

/--
Every `SerialFrame` is a `LinearTemporalFrame`.
This is automatic via the instance above.
-/
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D]
    [SerialFrame D] : LinearTemporalFrame D := inferInstance

/-! ## Standard Instances for Int

The integers form a discrete temporal frame with all required instances from Mathlib.
-/

/--
`Int` forms a `LinearTemporalFrame`.
-/
instance : LinearTemporalFrame Int := ⟨⟩

/--
`Int` forms a `SerialFrame`.
-/
instance : SerialFrame Int := {}

/--
`Int` forms a `DiscreteTemporalFrame`.
-/
instance : DiscreteTemporalFrame Int := {}

/-! ## Helper for Dense Frames

For dense frames, the caller must provide `DenselyOrdered D`. This is typically
done for canonical quotient constructions that build in density.
-/

/--
Given a type D with all the required structures including `DenselyOrdered`,
this constructs a `DenseTemporalFrame` instance.
-/
theorem DenseTemporalFrame.mk' (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D] :
    DenseTemporalFrame D := {}

/--
Given a type D with all the required structures for a discrete frame,
this constructs a `DiscreteTemporalFrame` instance.
-/
theorem DiscreteTemporalFrame.mk' (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] :
    DiscreteTemporalFrame D := {}

/--
Given a type `D` with the required structures and an explicit least-upper-bound witness,
this constructs a `DedekindTemporalFrame` instance.

Unlike `DenseTemporalFrame.mk'` and `DiscreteTemporalFrame.mk'`, this cannot be `{}`: the
`lub_exists` field carries real content and has no default, which is the whole point of the
class.
-/
theorem DedekindTemporalFrame.mk' (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] [NoMaxOrder D] [NoMinOrder D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) :
    DedekindTemporalFrame D :=
  { lub_exists := h_lub }

/--
Any type carrying Mathlib's `ConditionallyCompleteLinearOrder` is a `DedekindTemporalFrame`:
`sSup` supplies the least upper bound directly.

The `ConditionallyCompleteLinearOrder D` binder replaces `LinearOrder D` here rather than
sitting beside it, so there is exactly one `LinearOrder` path and no instance diamond. This is
stated as a `theorem` rather than an `instance` for the same reason the tree does not register
`ConditionallyCompleteLinearOrder ℤ` eagerly: it is noncomputable, and forcing it into instance
search would change elaboration for every `[LinearOrder D]`-indexed lemma downstream.
-/
theorem DedekindTemporalFrame.of_conditionallyComplete (D : Type) [AddCommGroup D]
    [ConditionallyCompleteLinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] [NoMaxOrder D]
    [NoMinOrder D] :
    DedekindTemporalFrame D :=
  { lub_exists := fun _ hne hbdd => ⟨_, isLUB_csSup hne hbdd⟩ }

end FormalSystem.FrameConditions

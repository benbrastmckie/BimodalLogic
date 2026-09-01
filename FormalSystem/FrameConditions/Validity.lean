/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.FrameConditions.FrameClass
import FormalSystem.Semantics.Validity

/-!
# Parameterized Validity

This module defines parameterized validity for TM formulas, unified across
different frame classes using the typeclass architecture.

## Main Definitions

- `ValidLinear`: Alias for validity over any LinearTemporalFrame
- `ValidDenseFc`: Validity over DenseTemporalFrame (fc = frame condition)
- `ValidDiscreteFc`: Validity over DiscreteTemporalFrame

## Equivalence Lemmas

This module proves equivalence between the new parameterized validity
and the existing definitions in `FormalSystem.Semantics.Validity`:
- `valid_dense_fc_iff_valid_dense`: Connection to existing `ValidDense`
- `valid_discrete_fc_iff_valid_discrete`: Connection to existing `ValidDiscrete`

## Design Notes

The key insight is that validity over a specific type D is equivalent to
the universal validity definition when D is polymorphic. The parameterized
version allows:
1. Specific instantiation for proofs about concrete types (Int, Rat)
2. Generic reasoning via typeclass constraints
3. Clean integration with soundness and completeness theorems

## References

- `FormalSystem.Semantics.Validity`: Original validity definitions
-/

namespace FormalSystem.FrameConditions

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## Parameterized Validity

**This module no longer declares its own fixed-carrier validity predicate.** Validity at a
fixed temporal order is
`∀ (F : FrameOver D), F.toTaskFrame.ValidOn φ` — the fibre quantifier composed with the frame-
relative validity of record (`TaskFrame.ValidOn`, `Semantics/Validity.lean`). Before the
fibration existed, "the frames over a fixed duration type" could not be said, so this module
carried its own predicate to say it; now the fibre says it, and a second predicate would be a
competing validity notion rather than an abbreviation. The frame-class predicates below are
therefore stated directly over `ValidOn`.
-/

/-! ## Frame-Class Specific Validity -/

/--
A formula is valid over linear temporal frames if it is valid over all
types D satisfying `LinearTemporalFrame D`.

This is essentially the same as `valid` since `valid` already quantifies
over all suitable D.
-/
def ValidLinear (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [LinearTemporalFrame D] (F : FrameOver (TemporalOrder.of D)), F.toTaskFrame.ValidOn φ

/--
A formula is valid over dense temporal frames if it is valid over all
types D satisfying `DenseTemporalFrame D`.

This corresponds to `ValidDense` but uses the typeclass constraint.
-/
def ValidDenseFc (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D] (F : FrameOver (TemporalOrder.of D)), F.toTaskFrame.ValidOn φ

/--
A formula is valid over discrete temporal frames if it is valid over all
types D satisfying `DiscreteTemporalFrame D`.

This corresponds to `ValidDiscrete` but uses the typeclass constraint.
-/
def ValidDiscreteFc (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] (F : FrameOver (TemporalOrder.of D)), F.toTaskFrame.ValidOn φ

/-! ## Equivalence with Existing Definitions -/

/--
Validity over any single type implies universal validity:
if every frame over every temporal order validates `φ`, then `valid φ`.

This is immediate since `valid` quantifies over all D.
-/
theorem valid_of_forall_valid_over {φ : Formula}
    (h : ∀ (D : TemporalOrder) (F : FrameOver D), F.toTaskFrame.ValidOn φ) :
    valid φ := by
  intro F M τ hτ t
  exact h F.Duration F.toFibre M ⟨τ, hτ⟩ t

/--
Universal validity implies validity over any specific type.
-/
theorem valid_over_of_valid {D : TemporalOrder} {φ : Formula} (h : valid φ)
    (F : FrameOver D) : F.toTaskFrame.ValidOn φ := by
  intro M τ t
  exact h F M τ.val τ.property t

/--
Dense validity (typeclass version) implies existing `ValidDense`.
-/
theorem valid_dense_of_valid_dense_fc {φ : Formula} (h : ValidDenseFc φ) : ValidDense φ := by
  intro F _ M τ hτ t
  -- We need DenseTemporalFrame F.Duration, but it is constructible from the frame's own instances
  haveI : DenseTemporalFrame F.Duration := {}
  exact h F.Duration F.toFibre M ⟨τ, hτ⟩ t

/--
Existing `ValidDense` implies dense validity (typeclass version).
-/
theorem valid_dense_fc_of_valid_dense {φ : Formula} (h : ValidDense φ) : ValidDenseFc φ := by
  intro D _ _ _ _ _ _ _ _ F M τ t
  exact h F M τ.val τ.property t

/--
Dense validity equivalence: `ValidDenseFc φ ↔ ValidDense φ`.
-/
theorem valid_dense_fc_iff_valid_dense {φ : Formula} :
    ValidDenseFc φ ↔ ValidDense φ :=
  ⟨valid_dense_of_valid_dense_fc, valid_dense_fc_of_valid_dense⟩

/--
Existing `ValidDiscrete` implies discrete validity (typeclass version).

Note: `ValidDiscrete` has fewer constraints than `DiscreteTemporalFrame`.
Since `ValidDiscrete` quantifies over a strictly larger class of types
(it only requires SuccOrder, PredOrder, Nontrivial), we have:
- `ValidDiscrete → ValidDiscreteFc` (more types → fewer types)
- but NOT `ValidDiscreteFc → ValidDiscrete` in general

This is the correct direction for soundness: proving validity over the
typeclass-constrained types is sufficient for the weaker `ValidDiscrete`.
-/
theorem valid_discrete_fc_of_valid_discrete {φ : Formula} (h : ValidDiscrete φ) :
    ValidDiscreteFc φ := by
  intro D _ _ _ _ _ _ _ _ _ _ F M τ t
  exact h F M τ.val τ.property t

/-! ## Relationship Between Frame Classes -/

/--
Universal validity implies linear validity.
-/
theorem valid_linear_of_valid {φ : Formula} (h : valid φ) : ValidLinear φ := by
  intro D _ _ _ _ _ F M τ t
  exact h F M τ.val τ.property t

/--
Linear validity implies dense validity (base axioms are valid on dense frames).
-/
theorem valid_dense_fc_of_valid_linear {φ : Formula} (h : ValidLinear φ) : ValidDenseFc φ := by
  intro D _ _ _ _ _ _ _ _ F M τ t
  -- DenseTemporalFrame extends SerialFrame which extends LinearTemporalFrame
  haveI : LinearTemporalFrame D := {}
  exact h D F M τ t

/--
Linear validity implies discrete validity (base axioms are valid on discrete frames).
-/
theorem valid_discrete_fc_of_valid_linear {φ : Formula} (h : ValidLinear φ) :
    ValidDiscreteFc φ := by
  intro D _ _ _ _ _ _ _ _ _ _ F M τ t
  haveI : LinearTemporalFrame D := {}
  exact h D F M τ t

/-! ## Validity at the `ℤ` fibre -/

/--
A formula is valid at the `ℤ` fibre (discrete integer time): true on every frame over `intOrder`.

Renamed as a forced consequence of deleting this module's fixed-carrier validity predicate:
the old name referred to a definition that no longer exists.
-/
abbrev ValidOnInt (φ : Formula) : Prop :=
  ∀ (F : FrameOver intOrder), F.toTaskFrame.ValidOn φ

/--
If a formula is discretely valid, it is valid at the `ℤ` fibre.
-/
theorem valid_on_Int_of_valid_discrete {φ : Formula} (h : ValidDiscrete φ) :
    ValidOnInt φ := by
  intro F M τ t
  exact h F M τ.val τ.property t

end FormalSystem.FrameConditions

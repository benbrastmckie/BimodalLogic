import Bimodal.Semantics.TaskFrame
import Mathlib.Algebra.Group.TransferInstance
import Mathlib.Order.SuccPred.LinearLocallyFinite
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Algebra.Order.Ring.Rat

/-!
# Duration Transfer: Group Structure from Order Isomorphism

This module provides the key construction for building the duration type D from syntax:
given an order isomorphism `T ≃o ℤ` (or `T ≃o ℚ`), transfer the `AddCommGroup` and
`IsOrderedAddMonoid` structure to T.

## Overview

The D-from-syntax construction follows a pipeline:
1. Build canonical timeline T from MCSs (BidirectionalQuotient)
2. Prove T has the right order properties (LinearOrder, Countable, etc.)
3. Apply characterization theorem to get `T ≃o ℤ` or `T ≃o ℚ`
4. **This module**: Transfer algebraic structure along the isomorphism

## Key Results

- `DurationTransfer.addCommGroup`: AddCommGroup on T from `T ≃o ℤ` (or `T ≃o ℚ`)
- `DurationTransfer.isOrderedAddMonoid`: Order-compatible addition on T
- `DurationTransfer.taskFrame`: Complete TaskFrame with D = T

## References

- Task 960: Duration Group Construction from Pure Syntax
- Mathlib.Algebra.Group.TransferInstance: `Equiv.addCommGroup`
- Mathlib.Order.SuccPred.LinearLocallyFinite: `orderIsoIntOfLinearSuccPredArch`
- Mathlib.Order.CountableDenseLinearOrder: `Order.iso_of_countable_dense`
-/

namespace Bimodal.Metalogic.Domain

open Bimodal.Semantics

/-!
## Section 1: Generic Transfer Infrastructure

Given a type T with LinearOrder and an OrderIso to a known group (ℤ or ℚ),
we transfer AddCommGroup and prove IsOrderedAddMonoid.
-/

/--
Transfer `AddCommGroup` from the codomain of an order isomorphism.

Given `e : T ≃o G` where G has `AddCommGroup`, this defines `AddCommGroup T`
via `Equiv.addCommGroup e.toEquiv`.

The addition on T is: `a + b := e.symm (e a + e b)`
The zero is: `0 := e.symm 0`
The negation is: `-a := e.symm (-(e a))`
-/
noncomputable def transferAddCommGroup
    {T : Type*} {G : Type*} [LinearOrder T] [AddCommGroup G] [LinearOrder G]
    (e : T ≃o G) : AddCommGroup T :=
  Equiv.addCommGroup e.toEquiv

/--
The transferred addition respects the linear order, giving `IsOrderedAddMonoid`.

Proof sketch: For `a ≤ b` in T, need `a + c ≤ b + c`.
- `a ≤ b` → `e a ≤ e b` (e is order-preserving)
- `e a ≤ e b` → `e a + e c ≤ e b + e c` (G has IsOrderedAddMonoid)
- `e a + e c ≤ e b + e c` → `e.symm(e a + e c) ≤ e.symm(e b + e c)` (e.symm is order-preserving)
- `e.symm(e a + e c) = a + c` and `e.symm(e b + e c) = b + c` by definition of transferred +
-/
theorem transferIsOrderedAddMonoid
    {T : Type*} {G : Type*} [LinearOrder T] [inst_G_acg : AddCommGroup G] [inst_G_lo : LinearOrder G]
    [inst_G_oam : IsOrderedAddMonoid G]
    (e : T ≃o G) :
    @IsOrderedAddMonoid T (transferAddCommGroup e).toAddCommMonoid.toAddZeroClass.toAdd
      (inferInstance : Preorder T) := by
  letI : AddCommGroup T := transferAddCommGroup e
  constructor
  intro a b hab c
  -- Need: a + c ≤ b + c
  -- The transferred + is: x + y = e.symm (e x + e y)
  -- So a + c = e.symm (e a + e c) and b + c = e.symm (e b + e c)
  -- Since e is an OrderIso, e preserves ≤
  have h1 : e a ≤ e b := e.monotone hab
  -- G has IsOrderedAddMonoid
  have h2 : e a + e c ≤ e b + e c := add_le_add_right h1 (e c)
  -- e.symm preserves ≤
  have h3 : e.symm (e a + e c) ≤ e.symm (e b + e c) := e.symm.monotone h2
  -- Now show the transferred additions match
  -- By definition of Equiv.addCommGroup:
  -- @HAdd.hAdd T T T ... a c = e.symm (e a + e c)
  -- This should hold definitionally
  convert h3 using 1 <;> rfl

/-!
## Section 2: ℤ Transfer (Discrete Case)

For the discrete case, we get `T ≃o ℤ` from `orderIsoIntOfLinearSuccPredArch`
and transfer all required structure.
-/

/--
Given a type T with the properties that characterize ℤ, produce the OrderIso.
-/
noncomputable def intOrderIso
    (T : Type*) [LinearOrder T] [SuccOrder T] [PredOrder T]
    [IsSuccArchimedean T] [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    T ≃o ℤ :=
  orderIsoIntOfLinearSuccPredArch

/--
AddCommGroup on T from ℤ characterization.
-/
noncomputable def intAddCommGroup
    (T : Type*) [LinearOrder T] [SuccOrder T] [PredOrder T]
    [IsSuccArchimedean T] [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    AddCommGroup T :=
  transferAddCommGroup (intOrderIso T)

/--
IsOrderedAddMonoid on T from ℤ characterization.
-/
theorem intIsOrderedAddMonoid
    (T : Type*) [LinearOrder T] [SuccOrder T] [PredOrder T]
    [IsSuccArchimedean T] [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    @IsOrderedAddMonoid T (intAddCommGroup T).toAddCommMonoid.toAddZeroClass.toAdd
      (inferInstance : Preorder T) :=
  transferIsOrderedAddMonoid (intOrderIso T)

/-!
## Section 3: ℚ Transfer (Dense Case)

For the dense case, we get `T ≃o ℚ` from `Order.iso_of_countable_dense`
and transfer all required structure.
-/

/--
Given a type T with the properties that characterize ℚ (Cantor's theorem), produce the OrderIso.
-/
noncomputable def ratOrderIso
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    T ≃o ℚ := by
  exact (Order.iso_of_countable_dense T ℚ).some

/--
AddCommGroup on T from Cantor characterization.
-/
noncomputable def ratAddCommGroup
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    AddCommGroup T :=
  transferAddCommGroup (ratOrderIso T)

/--
IsOrderedAddMonoid on T from Cantor characterization.
-/
theorem ratIsOrderedAddMonoid
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    @IsOrderedAddMonoid T (ratAddCommGroup T).toAddCommMonoid.toAddZeroClass.toAdd
      (inferInstance : Preorder T) :=
  transferIsOrderedAddMonoid (ratOrderIso T)

/-!
## Section 4: TaskFrame Construction

Given the transferred structure on T, build a TaskFrame.
The task relation is the deterministic translation: `task_rel w d w'` iff `w + d = w'`.
-/

/--
The canonical task relation: duration d takes world w to world w + d.
-/
def canonicalTaskRel {T : Type*} [Add T] (w : T) (d : T) (w' : T) : Prop :=
  w + d = w'

/--
Build a TaskFrame from a type with AddCommGroup + LinearOrder + IsOrderedAddMonoid.

The WorldState type IS the duration type T (worlds = times in the canonical timeline).
The task relation is deterministic: `task_rel w d w'` iff `w + d = w'`.
-/
noncomputable def canonicalTaskFrame
    (T : Type*) [acg : AddCommGroup T] [lo : LinearOrder T] [oam : IsOrderedAddMonoid T] :
    TaskFrame T where
  WorldState := T
  task_rel := canonicalTaskRel
  nullity := fun w => by
    show w + 0 = w
    exact add_zero w
  compositionality := fun w u v x y h1 h2 => by
    show w + (x + y) = v
    -- h1 : w + x = u
    -- h2 : u + y = v
    rw [← h2, ← h1]
    rw [add_assoc]

/-!
## Section 5: Convenience Wrappers

Complete constructions for the two main cases.
-/

/--
Complete TaskFrame construction for the discrete case.
Given T with SuccOrder + PredOrder + IsSuccArchimedean + NoMaxOrder + NoMinOrder + Nonempty,
produce TaskFrame T.
-/
noncomputable def discreteTaskFrame
    (T : Type*) [LinearOrder T] [SuccOrder T] [PredOrder T]
    [IsSuccArchimedean T] [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    @TaskFrame T (intAddCommGroup T) (inferInstance) (intIsOrderedAddMonoid T) :=
  @canonicalTaskFrame T (intAddCommGroup T) (inferInstance) (intIsOrderedAddMonoid T)

/--
Complete TaskFrame construction for the dense case.
Given T with Countable + DenselyOrdered + NoMaxOrder + NoMinOrder + Nonempty,
produce TaskFrame T.
-/
noncomputable def denseTaskFrame
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    @TaskFrame T (ratAddCommGroup T) (inferInstance) (ratIsOrderedAddMonoid T) :=
  @canonicalTaskFrame T (ratAddCommGroup T) (inferInstance) (ratIsOrderedAddMonoid T)

end Bimodal.Metalogic.Domain

/-
Probe 07 (plan v02, Phase 0, concerns (a) and (c)):

  (a) STOP GATE — do numerals elaborate at `↑intOrder`, i.e. through the `CoeSort`
      projection of a reified temporal order?
  (c) do the four `attribute [instance]` projections of `TemporalOrder` resolve without a
      diamond or a loop, at `↑intOrder`, at an abstract `↑D`, and at `↑(TemporalOrder.of D)`
      under ambient binders?

Run with:  lake env lean specs/512_bundle_duration_into_taskframe/probes/07_temporal-order-shape.lean
-/
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Order.Interval.Set.Defs
import Mathlib.Algebra.Order.Archimedean.Basic

namespace TOProbe

/-- `def:temporal-order`: a nontrivial totally ordered abelian group, reified. -/
structure TemporalOrder where
  carrier : Type
  [addCommGroup       : AddCommGroup carrier]
  [linearOrder        : LinearOrder carrier]
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier]
  [nontrivial         : Nontrivial carrier]

instance : CoeSort TemporalOrder Type := ⟨TemporalOrder.carrier⟩

attribute [instance] TemporalOrder.addCommGroup TemporalOrder.linearOrder
  TemporalOrder.isOrderedAddMonoid TemporalOrder.nontrivial

/-- The transitional constructor. -/
@[reducible] def TemporalOrder.of (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] : TemporalOrder := ⟨D⟩

/-- Literal-field spelling (research R1/R3: this is the form numerals need). -/
@[reducible] def intOrder : TemporalOrder := ⟨ℤ⟩

/-- The `TemporalOrder.of` spelling, for comparison. -/
@[reducible] def intOrder' : TemporalOrder := TemporalOrder.of ℤ

/-! ## (a) Numerals at `↑intOrder` — STOP GATE -/

-- literal-field spelling
example : (↑intOrder : Type) = ℤ := rfl
example (x : ↑intOrder) : ↑intOrder := x + 1
example (x : ↑intOrder) : ↑intOrder := x + 0
example : (1 : ↑intOrder) = 1 := rfl
example (x : ↑intOrder) : Prop := 0 < x
example (x y : ↑intOrder) : Prop := x + 1 ≤ y - 2

-- `TemporalOrder.of ℤ` spelling
example (x : ↑intOrder') : ↑intOrder' := x + 1
example : (1 : ↑intOrder') = 1 := rfl

-- inline anonymous constructor spelling
example (x : ↑(⟨ℤ⟩ : TemporalOrder)) : ↑(⟨ℤ⟩ : TemporalOrder) := x + 1

-- numerals in a `TaskRel`-shaped application
example (R : Nat → ↑intOrder → Nat → Prop) (w u : Nat) : Prop := R w 1 u
example (R : Nat → ↑intOrder → Nat → Prop) (w u : Nat) : Prop := R w (-1) u

/-! ## (c) Instance resolution through the projections -/

section Concrete
-- At `↑intOrder`, where the projection instance and `Int`'s own instances both apply.
example (x y : ↑intOrder) : x + y = y + x := add_comm x y
example (x y : ↑intOrder) : x ≤ y ∨ y ≤ x := le_total x y
example (x y z : ↑intOrder) (h : x ≤ y) : z + x ≤ z + y := add_le_add_right h z
example : ∃ x y : ↑intOrder, x ≠ y := exists_pair_ne _
example (x : ↑intOrder) : x - x = 0 := sub_self x

-- The two paths to `AddCommGroup ℤ` agree definitionally at reducible transparency.
example : intOrder.addCommGroup = (inferInstance : AddCommGroup ℤ) := rfl
example : intOrder.linearOrder = (inferInstance : LinearOrder ℤ) := rfl
example : (inferInstance : AddCommGroup ↑intOrder) = (inferInstance : AddCommGroup ℤ) := rfl

-- Mixing an `↑intOrder`-typed and an `ℤ`-typed term: do they unify?
example (x : ↑intOrder) (y : ℤ) : ↑intOrder := x + y
example (x : ↑intOrder) : ℤ := x
end Concrete

section Abstract
variable (D : TemporalOrder)

example (x y : ↑D) : x + y = y + x := add_comm x y
example (x y : ↑D) : x ≤ y ∨ y ≤ x := le_total x y
example (x y z : ↑D) (h : x ≤ y) : z + x ≤ z + y := add_le_add_right h z
example : ∃ x y : ↑D, x ≠ y := exists_pair_ne _
example (x : ↑D) : x - x = 0 := sub_self x
example (x : ↑D) : |x| = |(-x)| := (abs_neg x).symm
example (x : ↑D) : (0 : ↑D) ≤ |x| := abs_nonneg x

-- a frame-class side condition as a statement-level instance binder
example [DenselyOrdered ↑D] (x y : ↑D) (h : x < y) : ∃ z, x < z ∧ z < y := exists_between h
example [Archimedean ↑D] (x y : ↑D) (hx : 0 < x) : ∃ n : ℕ, y ≤ n • x := Archimedean.arch y hx

-- `↑D` without the arrow, in binder position, is the same type
example (x : D.carrier) : ↑D := x
end Abstract

section AmbientBinders
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

-- Two paths reach `AddCommGroup D`: the ambient binder and the projection of `TemporalOrder.of D`.
example : (TemporalOrder.of D).addCommGroup = (inferInstance : AddCommGroup D) := rfl
example : (inferInstance : AddCommGroup ↑(TemporalOrder.of D)) = (inferInstance : AddCommGroup D) :=
  rfl
example : (↑(TemporalOrder.of D) : Type) = D := rfl
example (x y : ↑(TemporalOrder.of D)) : x + y = y + x := add_comm x y
example (x : ↑(TemporalOrder.of D)) (y : D) : D := x + y
example : ∃ x y : ↑(TemporalOrder.of D), x ≠ y := exists_pair_ne _

-- synthesis is not blowing up: a tight heartbeat budget still succeeds
set_option synthInstance.maxHeartbeats 2000 in
example (x y : ↑(TemporalOrder.of D)) : x + y = y + x := add_comm x y

set_option synthInstance.maxHeartbeats 2000 in
example (x y : ↑intOrder) : x + y = y + x := add_comm x y
end AmbientBinders

end TOProbe

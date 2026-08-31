/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Algebra.Order.Ring.Int

/-!
# TemporalOrder — the paper's `def:temporal-order`, reified

`def:temporal-order` reads, verbatim: "A *temporal order* is a nontrivial totally ordered abelian
group `𝔇 = ⟨D, +, 0, ≤⟩` with *positive cone* `D⁺ ≔ {x ∈ D : x ≥ 0}`."

That is an **object**. Until this module existed the library had no name for it: it was
transcribed as an unnamed four-binder list

```lean
{D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
```

hand-copied at every declaration that mentions a duration. Two consequences followed from that
single omission, and this module removes both:

1. **Binder noise.** The four-binder list occurs in the low hundreds of places across the tree, in
   dozens of slightly different shapes (varying order, varying additional side conditions,
   varying implicit/explicit marking). A `TemporalOrder` is one binder.
2. **The fibre was inexpressible.** "The task frames over a fixed temporal order" cannot be said
   when a temporal order is not a thing: `(F : TaskFrame) (h : F.Duration = ℤ)` does not work,
   because `h` is a `Prop` and `OfNat F.Duration 1` is data, so no numeral elaborates under it.
   With the object reified, the fibre is `FrameOver D` for `(D : TemporalOrder)` and numerals at
   `↑intOrder` elaborate exactly as they do at `ℤ` — see the `example`s at the end of this module.

`Semantics/TaskFrame.lean` builds on this: `FrameOver D` is the fibre over a temporal order and
the sole declaration site of the frame axioms, and `TaskFrame` is the total space of the
projection `TaskFrame → TemporalOrder`, definitionally `Σ (D : TemporalOrder), FrameOver D`.

## The positive cone

`def:temporal-order`'s positive cone `D⁺` is not carried as separate data. It is definable from
the order (`{x : ↑D | 0 ≤ x}`) and is used only as a domain restriction on the primitive task
relation, which `Semantics/TaskFrame.lean` expresses by the `0 ≤ x` hypotheses on the
*Compositionality* field. Nothing is lost by leaving it implicit.

## Universes

`carrier : Type`, not `Type u`. The whole development is monomorphic at `Type`, and the frame
structures that index over a `TemporalOrder` are `Type 1`. Introducing universe polymorphism here
would propagate through every downstream binder for no present gain.

## Instance fields, not instance binders

The four algebraic structures are instance-implicit *fields* rather than binders on the structure:
a binder must be supplied at every mention of the type, whereas a field is discharged once per
temporal order at its construction site. The `attribute [instance]` block below re-exports the
projections so that `add_comm`, `le_total`, `exists_pair_ne` and the rest are available at `↑D`
for an abstract `(D : TemporalOrder)` with no further ceremony.

The projections are safe as instances: `⟨ℤ⟩.addCommGroup` and `ℤ`'s own `AddCommGroup` instance
unify by `rfl` at reducible transparency, so a concretely-carried temporal order does not fork
the instance graph.
-/

namespace FormalSystem.Semantics

/--
**A temporal order** (`def:temporal-order`): a nontrivial totally ordered abelian group.

The four algebraic components are instance-implicit fields, re-exported as instances by the
`attribute [instance]` block below, so that `↑D` carries them for an abstract
`(D : TemporalOrder)`.
-/
structure TemporalOrder where
  /-- The underlying set of durations — the paper's `D`. -/
  carrier : Type
  /-- `D` is an additive abelian group: the paper's `⟨D, +, 0⟩`. -/
  [addCommGroup : AddCommGroup carrier]
  /-- `D` is *totally* ordered: the paper's `≤`. -/
  [linearOrder : LinearOrder carrier]
  /-- The order is compatible with addition — what makes `⟨D, +, 0, ≤⟩` an *ordered* group. -/
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier]
  /-- The paper's *nontrivial*: `D` has at least two elements. -/
  [nontrivial : Nontrivial carrier]

/-- A temporal order is used as its carrier, so `(x : ↑D)` is a duration. -/
instance : CoeSort TemporalOrder Type := ⟨TemporalOrder.carrier⟩

attribute [instance] TemporalOrder.addCommGroup TemporalOrder.linearOrder
  TemporalOrder.isOrderedAddMonoid TemporalOrder.nontrivial

namespace TemporalOrder

/--
**Bundle a carrier plus its four ambient instances into a temporal order.**

`@[reducible]` is load-bearing: typeclass synthesis runs at reducible transparency, so a plain
`def` here would stall synthesis at `↑(TemporalOrder.of D)` and the projection instance would
fail to unify with the ambient `[AddCommGroup D]` binder even though the two are defeq at default
transparency.

This is the constructor the transitional `ParamTaskFrame` alias is written against while the
migration to `FrameOver` is in flight. Whether it also earns a permanent place — some
construction sites may read better with it than with a literal `⟨D⟩` — is settled at the end of
the migration, when the transitional layer is deleted.
-/
@[reducible] def of (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] : TemporalOrder := ⟨D⟩

end TemporalOrder

/--
**The integers as a temporal order.**

Written with a **literal field** and marked `@[reducible]`: that combination is what makes
numerals elaborate at `↑intOrder`. A temporal order reached through a non-reducible definition,
or built by an opaque construction, does not support `(1 : ↑intOrder)`, and the whole ℤ layer of
the development — the normal form, the finite model property, the BiLasso decision procedure —
is written with numeral durations.

`(↑intOrder : Type)` is `ℤ` by `rfl`, so an `ℤ`-typed term and an `↑intOrder`-typed term are
interchangeable. Note the one place where the distinction is visible: `omega` inspects the
*syntactic* type of a hypothesis and does not see through the coercion, so arithmetic-carrying
binders should be written `(d : ℤ)` rather than `(d : ↑intOrder)`. Both elaborate against a
frame's task relation; only the former lets `omega` work.
-/
@[reducible] def intOrder : TemporalOrder := ⟨ℤ⟩

section Examples

/-! ### Regression guards for the design premise

These `example`s pin the two facts the whole fibration rests on, established empirically before
the migration began. If one of them ever stops closing, the migration's premise has been broken
and the failure should be diagnosed here rather than at the several hundred downstream sites that
depend on it.
-/

/-- Numerals elaborate at a concretely-carried temporal order. -/
example : (↑intOrder : Type) = ℤ := rfl
example (x : ↑intOrder) : ↑intOrder := x + 1
example : (1 : ↑intOrder) = 1 := rfl
example (x : ↑intOrder) : Prop := 0 < x

/-- `↑intOrder` and `ℤ` are interchangeable in term position. -/
example (x : ↑intOrder) (y : ℤ) : ↑intOrder := x + y

/-- The projection instance and the carrier's own instance are the same instance. -/
example : intOrder.addCommGroup = (inferInstance : AddCommGroup ℤ) := rfl
example : intOrder.linearOrder = (inferInstance : LinearOrder ℤ) := rfl

/-- The algebra is recovered at `↑D` for an *abstract* temporal order. -/
example (D : TemporalOrder) (x y : ↑D) : x + y = y + x := add_comm x y
example (D : TemporalOrder) (x y : ↑D) : x ≤ y ∨ y ≤ x := le_total x y
example (D : TemporalOrder) (x y z : ↑D) (h : x ≤ y) : z + x ≤ z + y := add_le_add_right h z
example (D : TemporalOrder) : ∃ x y : ↑D, x ≠ y := exists_pair_ne _
example (D : TemporalOrder) (x : ↑D) : x - x = 0 := sub_self x
example (D : TemporalOrder) (x : ↑D) : (0 : ↑D) ≤ |x| := abs_nonneg x

/-- Frame-class side conditions on the carrier are ordinary statement-level instance binders. -/
example (D : TemporalOrder) [DenselyOrdered ↑D] (x y : ↑D) (h : x < y) : ∃ z, x < z ∧ z < y :=
  exists_between h

/-- Bundling an ambient carrier and projecting back is the identity, definitionally. -/
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    (↑(TemporalOrder.of D) : Type) = D := rfl
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    (TemporalOrder.of D).addCommGroup = (inferInstance : AddCommGroup D) := rfl
example : TemporalOrder.of ℤ = intOrder := rfl

-- Instance synthesis through the projections is cheap, not merely successful.
set_option synthInstance.maxHeartbeats 2000 in
example (D : TemporalOrder) (x y : ↑D) : x + y = y + x := add_comm x y

set_option synthInstance.maxHeartbeats 2000 in
example (x y : ↑intOrder) : x + y = y + x := add_comm x y

end Examples

end FormalSystem.Semantics

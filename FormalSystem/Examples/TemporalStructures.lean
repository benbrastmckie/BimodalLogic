/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.WorldHistory

/-!
# Temporal Structures - Example Frame Instantiations

This module provides examples demonstrating the use of different temporal types
with ProofChecker's generalized semantics. The polymorphic `TaskFrame T` and
`WorldHistory F` structures can be instantiated with various temporal types.

## Paper Alignment

The JPL paper "The Perpetuity Calculus of Agency" specifies the temporal structure in
`def:temporal-order` (verbatim): "A \textit{temporal order} is a nontrivial totally ordered
abelian group $\D = \tuple{D, +, 0, \leq}$ with \textit{positive cone}
$D^+ \coloneq \set{x \in D : x \geq 0}$." ProofChecker implements the ordered abelian group
via the unbundled typeclasses `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`; the
paper's nontriviality requirement is supplied at the sites that need it rather than by the
`TaskFrame` structure (see TaskFrame.lean's known-gaps list).

## Example Temporal Types

### Integer Time (`Int`)
- **Use case**: Discrete temporal logic, countable time steps
- **Instance**: Uses unbundled instances for AddCommGroup, LinearOrder, IsOrderedAddMonoid
- **Advantages**: Simple, decidable, standard temporal logic interpretation

### Polymorphic Examples
The examples below demonstrate how ProofChecker's polymorphic types work with
any type `D` that has `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid` instances. This
includes:
- `Int`: Discrete integer time
- `Rat`: Dense rational time (requires additional Mathlib imports)
- `Real`: Continuous real time (requires additional Mathlib imports)

## Main Definitions

- `intTimeFrame`: Example task frame using `Int` as temporal type
- `intTimeHistory`: Example world history using `Int`
- `genericTimeFrame`: Polymorphic task frame (works with any `D`)
- `genericTimeHistory`: Polymorphic world history (works with any `D`)

## Implementation Notes

- All examples use `trivial` task relations for simplicity
- Convexity proofs use the full domain (`fun _ => True`) for simplicity
- These examples are for demonstration and testing purposes

## References

* [TaskFrame.lean](../ProofChecker/Semantics/TaskFrame.lean) - TaskFrame definition
* [WorldHistory.lean](../ProofChecker/Semantics/WorldHistory.lean) - WorldHistory definition
* JPL Paper anchors `def:temporal-order` (temporal structure, quoted verbatim above) and
  `def:frame` (frame definition; see TaskFrame.lean's module docstring for the verbatim
  four-axiom statement) — cited by `\label` anchor, never by raw line number
-/

namespace FormalSystem.Examples.TemporalStructures

open FormalSystem.Semantics

/-! ## Integer Time Examples (Standard) -/

/--
Standard integer time task frame.

This is the default temporal structure used in most temporal logic applications.
Discrete time steps with integer arithmetic. WorldState is Unit (trivial).
-/
def intTimeFrame : TaskFrame Int where
  WorldState := Unit
  TaskRel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  comp := TaskFrame.comp_of (TaskFrame.interpolates_of_total fun _ _ _ => trivial)
    fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩
  serial := TaskFrame.serial_of_total fun _ _ _ => trivial
  limit := TaskFrame.limit_of_subsingleton
  spherical := TaskFrame.spherical_of_subsingleton

/-! ### `intTimeFrame` discharges `def:frame`'s four axioms (total class) -/

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `intTimeFrame`: its relation is total. -/
theorem intTimeFrame_serial : TaskFrame.Serial intTimeFrame.TaskRel :=
  TaskFrame.serial_of_total fun _ _ _ => trivial

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `intTimeFrame`: its relation is total. -/
theorem intTimeFrame_interpolates : TaskFrame.Interpolates intTimeFrame.TaskRel :=
  TaskFrame.interpolates_of_total fun _ _ _ => trivial

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`intTimeFrame`, in the literal transcribed shape: its carrier is `Unit`. -/
theorem intTimeFrame_limit :
    ∀ w u, (∀ x : Int, 0 < x → ∃ y, |y| < x ∧ intTimeFrame.TaskRel w y u) → u = w := by
  haveI : Subsingleton intTimeFrame.WorldState := inferInstanceAs (Subsingleton Unit)
  exact TaskFrame.limit_of_subsingleton

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `intTimeFrame`: its carrier
is `Unit`, so every nonempty subset is the whole carrier. -/
theorem intTimeFrame_spherical : TaskFrame.Spherical intTimeFrame.TaskRel := by
  haveI : Subsingleton intTimeFrame.WorldState := inferInstanceAs (Subsingleton Unit)
  exact TaskFrame.spherical_of_subsingleton

/--
Integer time task frame with natural number world states.

A slightly more complex frame with `Nat` world states. Task relation is `d ≠ 0 ∨ w = u`
to satisfy nullity_identity while remaining permissive for non-zero durations.
-/
def intNatFrame : TaskFrame Int where
  WorldState := Nat
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  comp := TaskFrame.comp_of (TaskFrame.interpolates_of_permissive fun _ _ _ => Iff.rfl)
    fun w u v x y hx hy h1 h2 => by
      cases h1 with
      | inl hxne =>
        left
        intro heq
        have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
        have h1 : 0 ≤ -x := hy_eq ▸ hy
        have h2 : x ≤ 0 := neg_nonneg.mp h1
        have h3 : x = 0 := le_antisymm h2 hx
        exact hxne h3
      | inr hw =>
        cases h2 with
        | inl hyne =>
          left
          intro heq
          have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
          have h1 : 0 ≤ -y := hx_eq ▸ hx
          have h2 : y ≤ 0 := neg_nonneg.mp h1
          have h3 : y = 0 := le_antisymm h2 hy
          exact hyne h3
        | inr hu => right; exact hw.trans hu
  serial := TaskFrame.serial_of_permissive fun _ _ _ => Iff.rfl
  limit := TaskFrame.limit_of_permissive fun _ _ _ => Iff.rfl
  spherical := TaskFrame.spherical_of_permissive fun _ _ _ => Iff.rfl
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp only [ne_eq, neg_eq_zero] at hnd; exact hnd
      | inr heq => right; exact heq.symm

/-! ### `intNatFrame` discharges `def:frame`'s four axioms (permissive class) -/

/-- `intNatFrame`'s relation is the permissive class `d ≠ 0 ∨ w = u`. -/
theorem intNatFrame_rel_iff :
    ∀ w d u, intNatFrame.TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := fun _ _ _ => Iff.rfl

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `intNatFrame`, via the `w = u` disjunct. -/
theorem intNatFrame_serial : TaskFrame.Serial intNatFrame.TaskRel :=
  TaskFrame.serial_of_permissive intNatFrame_rel_iff

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `intNatFrame`. -/
theorem intNatFrame_interpolates : TaskFrame.Interpolates intNatFrame.TaskRel :=
  TaskFrame.interpolates_of_permissive intNatFrame_rel_iff

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`intNatFrame`, in the literal transcribed shape. The duration type is `Int`, whose `SuccOrder`
and `NoMaxOrder` instances the permissive class needs and which are available without any binder
change. -/
theorem intNatFrame_limit :
    ∀ w u, (∀ x : Int, 0 < x → ∃ y, |y| < x ∧ intNatFrame.TaskRel w y u) → u = w :=
  TaskFrame.limit_of_permissive intNatFrame_rel_iff

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `intNatFrame`: every nonempty
fiber and segment is the whole carrier or a singleton. -/
theorem intNatFrame_spherical : TaskFrame.Spherical intNatFrame.TaskRel :=
  TaskFrame.spherical_of_permissive intNatFrame_rel_iff

/--
Integer time world history with universal domain.

All integer times are in the domain. This is the simplest possible history.
-/
def intTimeHistory : WorldHistory intTimeFrame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => ()
  respects_task := fun _ _ _ _ => trivial

/-! ## Polymorphic Examples -/

section Polymorphic

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Generic polymorphic task frame.

Works with any temporal type `D` that has ordered additive group instances.
This demonstrates ProofChecker's polymorphic design. WorldState is Unit (trivial).
-/
def genericTimeFrame : TaskFrame D where
  WorldState := Unit
  TaskRel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  comp := TaskFrame.comp_of (TaskFrame.interpolates_of_total fun _ _ _ => trivial)
    fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩
  serial := TaskFrame.serial_of_total fun _ _ _ => trivial
  limit := TaskFrame.limit_of_subsingleton
  spherical := TaskFrame.spherical_of_subsingleton

/-! ### `genericTimeFrame` discharges `def:frame`'s four axioms (total class) -/

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `genericTimeFrame`: its relation is total, at every `D`. -/
theorem genericTimeFrame_serial : TaskFrame.Serial (genericTimeFrame D).TaskRel :=
  TaskFrame.serial_of_total fun _ _ _ => trivial

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `genericTimeFrame`: its relation is total, at every `D`. -/
theorem genericTimeFrame_interpolates : TaskFrame.Interpolates (genericTimeFrame D).TaskRel :=
  TaskFrame.interpolates_of_total fun _ _ _ => trivial

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`genericTimeFrame`, in the literal transcribed shape. Its carrier is `Unit`, so the axiom holds
over **any** duration type, dense included — no restriction on `D` is needed. -/
theorem genericTimeFrame_limit :
    ∀ w u, (∀ x : D, 0 < x → ∃ y, |y| < x ∧ (genericTimeFrame D).TaskRel w y u) → u = w := by
  haveI : Subsingleton (genericTimeFrame D).WorldState := inferInstanceAs (Subsingleton Unit)
  exact TaskFrame.limit_of_subsingleton

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `genericTimeFrame`: its
carrier is `Unit`, so every nonempty subset is the whole carrier. -/
theorem genericTimeFrame_spherical : TaskFrame.Spherical (genericTimeFrame D).TaskRel := by
  haveI : Subsingleton (genericTimeFrame D).WorldState := inferInstanceAs (Subsingleton Unit)
  exact TaskFrame.spherical_of_subsingleton

/--
Generic polymorphic task frame with natural number world states.

Task relation is `d ≠ 0 ∨ w = u` to satisfy nullity_identity.

The `[SuccOrder D] [NoMaxOrder D]` binders are carried because `genericNatFrame_limit` requires
them: over a dense `D` the permissive relation puts every state in every cone of every other
state and *Limit* (`def:frame#Limit`) fails outright.
-/
def genericNatFrame [SuccOrder D] [NoMaxOrder D] : TaskFrame D where
  WorldState := Nat
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  comp := TaskFrame.comp_of (TaskFrame.interpolates_of_permissive fun _ _ _ => Iff.rfl)
    fun w u v x y hx hy h1 h2 => by
      cases h1 with
      | inl hxne =>
        left
        intro heq
        have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
        have h1 : 0 ≤ -x := hy_eq ▸ hy
        have h2 : x ≤ 0 := neg_nonneg.mp h1
        have h3 : x = 0 := le_antisymm h2 hx
        exact hxne h3
      | inr hw =>
        cases h2 with
        | inl hyne =>
          left
          intro heq
          have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
          have h1 : 0 ≤ -y := hx_eq ▸ hx
          have h2 : y ≤ 0 := neg_nonneg.mp h1
          have h3 : y = 0 := le_antisymm h2 hy
          exact hyne h3
        | inr hu => right; exact hw.trans hu
  serial := TaskFrame.serial_of_permissive fun _ _ _ => Iff.rfl
  limit := TaskFrame.limit_of_permissive fun _ _ _ => Iff.rfl
  spherical := TaskFrame.spherical_of_permissive fun _ _ _ => Iff.rfl
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp only [ne_eq, neg_eq_zero] at hnd; exact hnd
      | inr heq => right; exact heq.symm

/-! ### `genericNatFrame` discharges `def:frame`'s four axioms (permissive class) -/

/-- `genericNatFrame`'s relation is the permissive class `d ≠ 0 ∨ w = u`. -/
theorem genericNatFrame_rel_iff [SuccOrder D] [NoMaxOrder D] :
    ∀ w d u, (genericNatFrame D).TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := fun _ _ _ => Iff.rfl

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `genericNatFrame`, via the `w = u` disjunct. Holds at every `D`. -/
theorem genericNatFrame_serial [SuccOrder D] [NoMaxOrder D] :
    TaskFrame.Serial (genericNatFrame D).TaskRel :=
  TaskFrame.serial_of_permissive (genericNatFrame_rel_iff D)

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `genericNatFrame`. Holds at every `D`. -/
theorem genericNatFrame_interpolates [SuccOrder D] [NoMaxOrder D] :
    TaskFrame.Interpolates (genericNatFrame D).TaskRel :=
  TaskFrame.interpolates_of_permissive (genericNatFrame_rel_iff D)

/--
*Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`genericNatFrame`, in the literal transcribed shape — **over a discrete duration type only**.

`[SuccOrder D] [NoMaxOrder D]` is now carried by `genericNatFrame` itself as well, so that this
lemma discharges the frame's *Limit* field. The restriction is not removable: over a dense `D`
the permissive relation puts every state in every cone of every other state (pick any `y ≠ 0`
with `|y| < x`), and *Limit* fails outright. The frame has no consumers anywhere in
`FormalSystem/` or `Tests/`, so acquiring the binders was free.
-/
theorem genericNatFrame_limit [SuccOrder D] [NoMaxOrder D] :
    ∀ w u, (∀ x : D, 0 < x → ∃ y, |y| < x ∧ (genericNatFrame D).TaskRel w y u) → u = w :=
  TaskFrame.limit_of_permissive (genericNatFrame_rel_iff D)

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `genericNatFrame`: every
nonempty fiber and segment is the whole carrier or a singleton, and a directed family cannot
contain two distinct singletons. No restriction on `D` is needed. -/
theorem genericNatFrame_spherical [SuccOrder D] [NoMaxOrder D] :
    TaskFrame.Spherical (genericNatFrame D).TaskRel :=
  TaskFrame.spherical_of_permissive (genericNatFrame_rel_iff D)

/--
Generic polymorphic world history with universal domain.

Works with the genericTimeFrame, demonstrating polymorphism over the temporal type.
-/
def genericTimeHistory : WorldHistory (genericTimeFrame D) where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => ()
  respects_task := fun _ _ _ _ => trivial

end Polymorphic

/-! ## Comparison Examples -/

/--
Demonstrates that the same frame definition works with explicit Int.
-/
example : (genericTimeFrame Int).WorldState = Unit := rfl

/--
Demonstrates that generic and specific Int frames have the same task relation behavior.
-/
example : (genericTimeFrame Int).TaskRel = intTimeFrame.TaskRel := rfl

/-! ## Properties -/

/--
Integer time satisfies the nullity constraint (derived from nullity_identity).
-/
theorem int_nullity_example : intTimeFrame.TaskRel () 0 () :=
  TaskFrame.nullity intTimeFrame ()

/--
Generic time satisfies the nullity constraint (polymorphic proof, derived from nullity_identity).
-/
theorem generic_nullity_example (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] :
    (genericTimeFrame D).TaskRel () 0 () :=
  TaskFrame.nullity (genericTimeFrame D) ()

/--
Integer time forward compositionality example: 1 + 2 = 3 duration composition.
-/
theorem int_compositionality_example :
    intTimeFrame.TaskRel () 3 () := by
  change intTimeFrame.TaskRel () (1 + 2) ()
  exact intTimeFrame.forward_comp () () () 1 2
    (by omega : 0 ≤ (1 : Int))
    (by omega : 0 ≤ (2 : Int))
    (TaskFrame.nullity intTimeFrame ())
    (TaskFrame.nullity intTimeFrame ())

/--
Generic forward compositionality theorem (polymorphic).

For any temporal type `D` and non-negative durations `x` and `y`, tasks compose
to a task of duration `x + y`.
-/
theorem generic_compositionality (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (x y : D) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    (genericTimeFrame D).TaskRel () (x + y) () :=
  (genericTimeFrame D).forward_comp () () () x y hx hy
    (TaskFrame.nullity (genericTimeFrame D) ())
    (TaskFrame.nullity (genericTimeFrame D) ())

/-! ## History Domain Examples -/

/--
All integer times are in the universal domain.
-/
theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial

/--
Generic histories have universal domains (polymorphic).
-/
theorem generic_domain_universal (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (t : D) :
    (genericTimeHistory D).domain t := trivial

end FormalSystem.Examples.TemporalStructures

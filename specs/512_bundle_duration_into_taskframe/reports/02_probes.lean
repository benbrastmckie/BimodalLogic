/-
Second probe file: mitigations for the reducibility/instance-diamond finding from
`01_probes.lean`, and the `TemporalOrder` mixin variant.

Run with:
  lake env lean specs/512_bundle_duration_into_taskframe/reports/02_probes.lean
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.WorldHistory
import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.PartialHistory
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Hom.Monoid

namespace Probe2

open FormalSystem.Semantics

structure BFrame where
  Duration : Type
  [addCommGroup : AddCommGroup Duration]
  [linearOrder : LinearOrder Duration]
  [orderedAddMonoid : IsOrderedAddMonoid Duration]
  [nontrivial : Nontrivial Duration]
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState → Duration → WorldState → Prop
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  comp : TaskFrame.Compositional TaskRel
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w
  serial : TaskFrame.Serial TaskRel
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  spherical : TaskFrame.Spherical TaskRel

attribute [instance] BFrame.addCommGroup BFrame.linearOrder BFrame.orderedAddMonoid
  BFrame.nontrivial BFrame.worldNonempty

def BFrame.ofParam {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] (F : TaskFrame D) : BFrame where
  Duration := D
  WorldState := F.WorldState
  worldNonempty := F.nonempty
  TaskRel := F.TaskRel
  nullity_identity := F.nullity_identity
  comp := F.comp
  converse := F.converse
  serial := F.serial
  limit := F.limit
  spherical := F.spherical

/-! ## M1. `def` carrier — the failure mode recorded in 01_probes -/

def defStatic : BFrame := BFrame.ofParam (TaskFrame.staticFrame (D := Int) Bool)

-- Defeq at DEFAULT transparency: both of these succeed.
example : defStatic.Duration = Int := rfl
example : defStatic.addCommGroup = Int.instAddCommGroup := rfl

-- But typeclass SYNTHESIS runs at REDUCIBLE transparency, and fails. Uncommenting
-- reproduces `failed to synthesize instance of type class OfNat defStatic.Duration 1`.
-- example (x : defStatic.Duration) : x + 1 = 1 + x := add_comm x 1

/-! ## M2. Mitigation A — make the carrier frame `abbrev` (reducible) -/

abbrev abbrevStatic : BFrame := BFrame.ofParam (TaskFrame.staticFrame (D := Int) Bool)

-- NEGATIVE RESULT: `abbrev` is NOT sufficient here, because `abbrevStatic` unfolds to
-- `BFrame.ofParam (...)` and `ofParam` is itself a plain (non-reducible) `def`, so the
-- chain still does not reach a `BFrame.mk` application at reducible transparency.
-- See 03_probes.lean R1: an `abbrev` built with LITERAL field syntax does work.
-- example (x : abbrevStatic.Duration) : x + 1 = 1 + x := add_comm x 1

/-! ## M3. Mitigation B — `@[reducible]` on an existing `def` -/

@[reducible] def redStatic : BFrame := BFrame.ofParam (TaskFrame.staticFrame (D := Int) Bool)

-- Same negative, same cause (`ofParam` is the opaque link in the chain).
-- example (x y : redStatic.Duration) (h : x < y) : x + 1 ≤ y := by omega

/-! ## M4. Mitigation C — carrier equation + `show`, for an irreducible frame -/

theorem defStatic_Duration : defStatic.Duration = Int := rfl

-- An ascription-`show` inserts NO cast (the types are already defeq), so it does not
-- help either. The working route is a helper lemma stated at `Int`; see 03_probes R9.
theorem defStatic_int_lemma (x y : Int) (h : x < y) : x + 1 ≤ y := by omega

/-! ## M5. Mitigation D — abstract hypothesis form (no concrete carrier at all)

The shape metatheory should actually be written in: never name a concrete `Duration`,
carry the constraint as a hypothesis on the frame. -/

def BFrame.IsDiscreteInt (F : BFrame) : Prop := Nonempty (F.Duration ≃+o Int)

example (F : BFrame) (h : F.IsDiscreteInt) : Nonempty (F.Duration ≃+o Int) := h

/-! ## M6. The `TemporalOrder` mixin — `def:temporal-order` as a named Prop class

Collapses the four-binder list to two data binders plus one Prop mixin, WITHOUT
creating a Mathlib diamond (Prop-valued, so proof-irrelevant). -/

/-- `def:temporal-order`: a nontrivial totally ordered abelian group. -/
class TemporalOrder (D : Type*) [AddCommGroup D] [LinearOrder D] : Prop
    extends IsOrderedAddMonoid D, Nontrivial D

instance : TemporalOrder Int := {}
instance : TemporalOrder ℚ := {}

-- M6a. Does the mixin recover the component instances?
example (D : Type) [AddCommGroup D] [LinearOrder D] [TemporalOrder D] : IsOrderedAddMonoid D :=
  inferInstance
example (D : Type) [AddCommGroup D] [LinearOrder D] [TemporalOrder D] : Nontrivial D :=
  inferInstance

-- M6b. Does an existing 4-binder declaration accept the 3-binder form?
example (D : Type) [AddCommGroup D] [LinearOrder D] [TemporalOrder D] (F : TaskFrame D) :
    TaskFrame.Serial F.TaskRel := F.serial

-- M6c. Is the Mathlib path still the one found for Int (no diamond)?
example : (inferInstance : IsOrderedAddMonoid Int) = Int.instIsOrderedAddMonoid := rfl

/-- The bundled structure using the mixin: 3 instance fields instead of 4. -/
structure MFrame where
  Duration : Type
  [addCommGroup : AddCommGroup Duration]
  [linearOrder : LinearOrder Duration]
  [temporalOrder : TemporalOrder Duration]
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState → Duration → WorldState → Prop
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  comp : TaskFrame.Compositional TaskRel
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w
  serial : TaskFrame.Serial TaskRel
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  spherical : TaskFrame.Spherical TaskRel

attribute [instance] MFrame.addCommGroup MFrame.linearOrder MFrame.temporalOrder
  MFrame.worldNonempty

example (F : MFrame) (x y : F.Duration) : x + y = y + x := add_comm x y
example (F : MFrame) : Nontrivial F.Duration := inferInstance
example (F : MFrame) : IsOrderedAddMonoid F.Duration := inferInstance

/-! ## M7. Downstream layers restated NATIVELY over a bundled frame

Not via the bridge: does `PartialHistory`/`WorldHistory` re-parameterise cleanly? -/

structure BPartialHistory (F : BFrame) where
  domain : F.Duration → Prop
  states : ∀ t : F.Duration, domain t → F.WorldState
  nonempty : ∃ t, domain t
  respects_task : ∀ s t (hs : domain s) (ht : domain t),
    F.TaskRel (states s hs) (t - s) (states t ht)

structure BWorldHistory (F : BFrame) extends BPartialHistory F where
  convex : ∀ x z : F.Duration, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y

structure BTaskModel (F : BFrame) where
  valuation : F.WorldState → FormalSystem.Syntax.Atom → Prop

-- M7a. No `{D}` binder anywhere. Universe?
#check (BWorldHistory : BFrame → Type)
#check (BTaskModel : BFrame → Type)

/-! ## M8. `FiniteTaskFrame` as an extension of the bundled frame -/

structure BFiniteFrame extends BFrame where
  finite_world : Finite toBFrame.WorldState

example (F : BFiniteFrame) : Finite F.WorldState := F.finite_world
example (F : BFiniteFrame) (x y : F.Duration) : x + y = y + x := add_comm x y

/-! ## M9. Frame-class predicates as genuine per-frame properties, ordered -/

def BFrame.Dense (F : BFrame) : Prop := DenselyOrdered F.Duration
def BFrame.Complete (F : BFrame) : Prop :=
  ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x

inductive FClass | base | dense | discrete | complete

def FClass.Sat : FClass → BFrame → Prop
  | .base, _ => True
  | .dense, F => DenselyOrdered F.Duration
  | .discrete, F => Nonempty (SuccOrder F.Duration) ∧ Nonempty (PredOrder F.Duration)
  | .complete, F => ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x

/-- The single indexed validity the whole front wants — one definition, not fifteen. -/
def ValidIn (fc : FClass) (φ : FormalSystem.Syntax.Formula) : Prop :=
  ∀ F : BFrame, fc.Sat F → ∀ (M : BTaskModel F) (τ : BWorldHistory F),
    True → ∀ _t : F.Duration, ∃ _ : Prop, True  -- shape probe only; TruthAt needs porting

#check @ValidIn

end Probe2

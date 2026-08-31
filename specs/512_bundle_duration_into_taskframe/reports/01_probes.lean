/-
Probe file for research on bundling the duration type into `TaskFrame`.

Run with:
  lake env lean specs/512_bundle_duration_into_taskframe/reports/01_probes.lean

Nothing here is imported by the library. Every probe is self-contained: the bundled
structure is declared in a private namespace `Probe`, so it never collides with the
real `FormalSystem.Semantics.TaskFrame`.
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.WorldHistory
import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.IntNormalForm
import Mathlib.Algebra.Order.Group.Int

namespace Probe

open FormalSystem.Semantics

/-! ## P1. Does the target shape elaborate at all? -/

/-- The target shape from the task description, verbatim modulo field renaming. -/
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

-- P1a. What universe does it land in?
#check (BFrame : Type 1)

-- P1b. Do the axiom-field types elaborate BEFORE the instances are exported?
--      (i.e. are the instance-implicit fields in scope for later fields' types?)
#check @BFrame.comp
#check @BFrame.limit

/-! ## P2. Instance projections -/

attribute [instance] BFrame.addCommGroup BFrame.linearOrder BFrame.orderedAddMonoid
  BFrame.nontrivial BFrame.worldNonempty

-- P2a. Does `F.Duration` carry its algebra at a use site?
example (F : BFrame) (x y : F.Duration) : x + y = y + x := add_comm x y
example (F : BFrame) (x y : F.Duration) : x ≤ y ∨ y ≤ x := le_total x y
example (F : BFrame) (x y z : F.Duration) (h : x ≤ y) : z + x ≤ z + y := by
  exact add_le_add_right h z

example (F : BFrame) : ∃ x y : F.Duration, x ≠ y := exists_pair_ne F.Duration
example (F : BFrame) : Nonempty F.WorldState := inferInstance

-- P2b. Do the TaskFrame bare-relation predicates apply?
example (F : BFrame) : TaskFrame.Serial F.TaskRel := F.serial
example (F : BFrame) : TaskFrame.Interpolates F.TaskRel :=
  TaskFrame.interpolates_of_comp F.comp

-- P2c. Derived results that currently live on the parameterized structure
example (F : BFrame) (w : F.WorldState) : F.TaskRel w 0 w :=
  F.nullity_identity w w |>.mpr rfl

/-! ## P3. The bridge to the existing parameterized structure -/

/-- Bundled → parameterized. -/
def BFrame.toParam (F : BFrame) : TaskFrame F.Duration where
  WorldState := F.WorldState
  nonempty := F.worldNonempty
  TaskRel := F.TaskRel
  nullity_identity := F.nullity_identity
  comp := F.comp
  converse := F.converse
  serial := F.serial
  limit := F.limit
  spherical := F.spherical

/-- Parameterized → bundled. -/
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

-- P3a. Is the round trip definitional (structure eta)?
example (F : BFrame) : BFrame.ofParam F.toParam = F := rfl

example {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) : (BFrame.ofParam F).toParam = F := rfl

-- P3b. Is `(BFrame.ofParam F).Duration` reducibly `D`?
example {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) : (BFrame.ofParam F).Duration = D := rfl

/-! ## P4. THE INSTANCE DIAMOND — the load-bearing risk

At a concrete frame over `Int`, is the exported `AddCommGroup F.Duration` instance
*syntactically* Mathlib's, or a projection that blocks `simp`/`omega`/`decide`? -/

def intStatic : BFrame := BFrame.ofParam (TaskFrame.staticFrame (D := Int) Bool)

-- P4a. Does the carrier reduce?
example : intStatic.Duration = Int := rfl

-- P4b. `0` comes from the EXPORTED `AddCommGroup` field, so this works:
example (x : intStatic.Duration) : x + 0 = x := by simp

-- P4c. `1` does NOT: it needs `OfNat Int 1`, which only `Int`'s own instances supply,
-- and typeclass synthesis will not unfold the plain `def intStatic` to find them.
-- Uncommenting reproduces:
--   failed to synthesize instance of type class OfNat intStatic.Duration 1
-- example (x y : intStatic.Duration) (h : x < y) : x + 1 ≤ y := by omega

-- P4d. Is the exported instance defeq to Mathlib's, at DEFAULT transparency?  YES.
example : intStatic.addCommGroup = Int.instAddCommGroup := rfl

/-! ## P5. Downstream re-parameterisation shape

Can `WorldHistory` / `TaskModel` / `TruthAt` be restated over a bundled frame with
no `{D}` binder at all? Probe via the bridge. -/

abbrev BFrame.History (F : BFrame) := WorldHistory F.toParam
abbrev BFrame.Model (F : BFrame) := TaskModel F.toParam

def BValidOn (F : BFrame) (φ : FormalSystem.Syntax.Formula) : Prop :=
  ∀ (M : F.Model) (τ : F.History), τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ

-- P5a. A frame-class predicate that is now a genuine property OF A FRAME.
def BFrame.IsDense (F : BFrame) : Prop := DenselyOrdered F.Duration
def BFrame.IsDiscrete (F : BFrame) : Prop :=
  Nonempty (SuccOrder F.Duration) ∧ Nonempty (PredOrder F.Duration)
def BFrame.IsComplete (F : BFrame) : Prop :=
  ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x

-- P5b. The textbook per-frame validity shape the whole front wants.
def BValidOnClass (C : BFrame → Prop) (φ : FormalSystem.Syntax.Formula) : Prop :=
  ∀ F : BFrame, C F → BValidOn F φ

/-! ## P6. Quantifying over frames with DIFFERENT durations in one statement

This is the capability that motivates bundling over the cheap alternative. -/

example : ∀ F G : BFrame, F.Duration = Int → G.Duration = Rat → True := by
  intro _ _ _ _; trivial

/-- A frame morphism — inexpressible without bundling. -/
structure BHom (F G : BFrame) where
  onDuration : F.Duration → G.Duration
  onState : F.WorldState → G.WorldState
  map_add : ∀ x y, onDuration (x + y) = onDuration x + onDuration y
  map_rel : ∀ w x u, F.TaskRel w x u → G.TaskRel (onState w) (onDuration x) (onState u)

/-! ## P7. Universe question

Does `Duration : Type*` / `WorldState : Type*` still work, and at what cost? -/

structure BFrameU where
  Duration : Type u
  [addCommGroup : AddCommGroup Duration]
  [linearOrder : LinearOrder Duration]
  [orderedAddMonoid : IsOrderedAddMonoid Duration]
  [nontrivial : Nontrivial Duration]
  WorldState : Type v
  TaskRel : WorldState → Duration → WorldState → Prop

#check @BFrameU

end Probe

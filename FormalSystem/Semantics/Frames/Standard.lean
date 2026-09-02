/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Tactic.Abel
import FormalSystem.Semantics.TaskFrame

/-!
# The standard frames

The index of the frame constants the development builds countermodels and correspondence
witnesses out of. Two of them live here; the rest are *linked*, not re-exported, so that reading
this file tells you where every standard frame is without dragging its module into every
importer's closure.

## Why this file sits where it does, and not where it looks like it should

The obvious placement is wrong. A `Standard.lean` that *imported* `Correspondence/DurationFrames`
in order to re-export `translationFrame` and `permissiveFrame` would sit **downstream** of
`Correspondence/` — an index below the modules it indexes, and unusable by anything upstream of
them. So the two frames **moved up** into this file instead, and `DurationFrames.lean` imports
it. Neither needed anything from `Indicator` or `DurationClassification` to begin with:
`translationFrame` is `W = D` with `w ⇒_x u ↔ u = w + x`, and `permissiveFrame` is `W = Bool`
with `w ⇒_d u ↔ (d ≠ 0 ∨ w = u)`. This module's import list is `TaskFrame` and nothing else.

## The frames defined here

* `translationFrame D` — the deterministic translation flow on `D` itself. Its reference history
  is the identity `t ↦ t`, which is what lets an arbitrary `A ⊆ D` be realized as an atom's truth
  set; that is the (⇒) direction of the `app:discrete` and `app:complete` correspondences.
* `permissiveFrame D so nm` — the two-state frame in which every state assignment is a legal
  history. It realizes the one-off "blip" that refutes the density schema over a non-dense
  carrier.

## The rest of the census, linked

* `FrameOver.trivialFrame`, `FrameOver.staticFrame`, `FrameOver.natFrame`
  (`Semantics/TaskFrame.lean`) — the three constants over an ambient bare carrier. That module
  also records why they keep a bare-`Type` carrier rather than a `(D : TemporalOrder)` binder.
* `genericTimeFrame`, `genericNatFrame` (`Examples/TemporalStructures.lean`) — `abbrev`s for
  `trivialFrame` and `natFrame` at a `(D : TemporalOrder)` binder, not second copies.
* `clockFrame` (`Metalogic/Independence/ClockFrame.lean`) — `ℚ ⧸ ℤ` under translation.
* `regionFrame` (`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`) — the region clock.
* `zTaskFrameV2`, `multiFamTaskFrame`
  (`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`) and `multiFamTaskFrameGen`
  (`Metalogic/Algebraic/FlowFrame.lean`) — the deterministic `ℤ`-shift family.
* `ShiftSet.fibre` (`Semantics/ShiftSet.lean`) — the frame induced by a shift set.
* `FiniteFilteredTaskFrame` (`Metalogic/Decidability/FMP/FiniteModel.lean`) — the filtration.
-/

namespace FormalSystem.Semantics

/-! ## The translation frame -/

/-- Every fibre of the translation relation is a singleton: the flow is deterministic. -/
theorem translationRel_fib_subsingleton {D : TemporalOrder} (w x : ↑D) :
    (TaskFrame.Fib (fun (w : ↑D) (x : ↑D) (u : ↑D) => u = w + x) w x).Subsingleton := by
  rintro u (rfl : u = _) u' (rfl : u' = _)
  rfl

/--
**The translation frame over `D`**: world states are durations, and `w ⇒_x u` exactly when
`u = w + x`.

The seven `FrameOver` obligations: *Nullity* and *Converse* are group arithmetic;
*Compositionality* interpolates through `w + x`; *Seriality* has `w + x` and `w - x` as the two
witnesses; *Limit* is `TaskFrame.limit_of_shift` at the identity position function; and
*Saturation* is Helper D (`TaskFrame.saturation_of_fib_subsingleton`) applied to
`translationRel_fib_subsingleton`, the translation relation being deterministic.
-/
def translationFrame (D : TemporalOrder) : FrameOver D where
  WorldState := ↑D
  worldNonempty := ⟨0⟩
  TaskRel := fun w x u => u = w + x
  nullity_identity := by
    intro w u
    constructor
    · intro h; rw [h, add_zero]
    · intro h; rw [← h, add_zero]
  comp := TaskFrame.comp_of
    (by
      intro w v x y _ _ h
      refine ⟨w + x, rfl, ?_⟩
      show v = w + x + y
      rw [show v = w + (x + y) from h]
      abel)
    (by
      intro w u v x y _ _ h1 h2
      show v = w + (x + y)
      rw [show v = u + y from h2, show u = w + x from h1]
      abel)
  converse := by
    intro w d u
    constructor
    · intro h; show w = u + -d; rw [show u = w + d from h]; abel
    · intro h; show u = w + d; rw [show w = u + -d from h]; abel
  serial := by
    intro w x _
    refine ⟨⟨w + x, rfl⟩, ⟨w - x, ?_⟩⟩
    show w = w - x + x
    abel
  limit := TaskFrame.limit_of_shift (D := ↑D) (fun w => w) (fun _ _ _ h => h)
    (by intro w u h; rw [show u = w + 0 from h, add_zero])
  saturation := TaskFrame.saturation_of_fib_subsingleton translationRel_fib_subsingleton

@[simp] theorem translationFrame_taskRel {D : TemporalOrder} (w x u : ↑D) :
    (translationFrame D).TaskRel w x u ↔ u = w + x := Iff.rfl

/-! ## The permissive frame -/

/--
**The two-state permissive frame over `D`**: `W = Bool`, and `w ⇒_d u` at every nonzero `d`.

Every state assignment is a legal history, so this frame realizes arbitrary time-valuations —
including the one-off "blip" that refutes the density schema over a non-dense carrier. It is
`03_probes.lean`'s `freeFrame` at `W = Bool`, ported to the bundled shape.

The `SuccOrder`/`NoMaxOrder` arguments are explicit rather than instance-implicit, and are
supplied at the use site from the failure of density; see the module docstring.
-/
def permissiveFrame (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    FrameOver D :=
  letI := so
  letI := nm
  { WorldState := Bool
    worldNonempty := inferInstance
    TaskRel := fun w d u => d ≠ 0 ∨ w = u
    -- All six axiom fields are one-line citations of Helper B (`*_of_permissive`).
    nullity_identity := TaskFrame.nullity_identity_of_permissive fun _ _ _ => Iff.rfl
    comp := TaskFrame.comp_of_permissive fun _ _ _ => Iff.rfl
    converse := TaskFrame.converse_of_permissive fun _ _ _ => Iff.rfl
    serial := TaskFrame.serial_of_permissive fun _ _ _ => Iff.rfl
    limit := TaskFrame.limit_of_permissive fun _ _ _ => Iff.rfl
    saturation := TaskFrame.saturation_of_permissive fun _ _ _ => Iff.rfl }

@[simp] theorem permissiveFrame_taskRel {D : TemporalOrder} (so : SuccOrder ↑D)
    (nm : NoMaxOrder ↑D) (w : Bool) (d : ↑D) (u : Bool) :
    (permissiveFrame D so nm).TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := Iff.rfl

end FormalSystem.Semantics

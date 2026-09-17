/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.PlusLanguage.PlusDeterminism
import Mathlib.Data.Real.Basic

/-!
# F¹ — the deterministic translation flow over `ℝ`

The first half of the **indistinguishable pair** behind `cor:no-characterization`. `F¹` has
`W = D = ℝ` and the functional task relation `w ⇒_x u :⟺ u = w + x`: a single translation flow,
deterministic in the sense of `def:deterministic`. Its partner `F°` — the *drift* frame of
`app:drift`, non-deterministic, with the same `ℝ` carrier — is in `Independence/DriftFrame.lean`.

## Main Definitions

- `realTemporalOrder` — `ℝ` as a `TemporalOrder`
- `oneShift` — the shift set `(ℝ, +)` acting on itself
- `F1` — the induced task frame, `oneShift.frame`

## Main Results

- `f1_taskRel_iff` — the task relation is `u = w + x`, on the nose
- `f1_deterministic` — `F1` satisfies `TaskFrame.Deterministic`
- `f1_total_eq_orbit`, `f1_states_eq`, `f1_states_eq_of_states_eq` — the **world-set
  characterization**: the world histories of `F¹` are exactly the translations `τ(t) = τ(0) + t`
- `f1_determined` — *Determined* is valid on `F¹`, by Phase 1's collapse

## Why `ShiftSet` and not `translationFrame`

`Semantics/Frames/Standard.lean` already carries `translationFrame D`, which is this frame at
`D = realTemporalOrder`. It is nevertheless **not** the route taken here, and the reason is a
reducibility barrier that bites late rather than early.

`translationFrame` is a plain `def`, not `@[reducible]`, so
`(translationFrame realTemporalOrder).WorldState` does not reduce to `ℝ` at the transparency instance
synthesis and unification work at. There are two distinct symptoms:

1. **At the frame level**, `example (w x u : ℝ) : F1.TaskRel w x u ↔ u = w + x := Iff.rfl` fails
   with "`w` has type `ℝ` but is expected to have type `F1.WorldState`" and a failed
   `HAdd ℝ ℝ ?m` synthesis. This one *is* repairable: type the variables at `↑realTemporalOrder` instead
   of at `ℝ`, since `realTemporalOrder` is `@[reducible]` and `↑realTemporalOrder` does reduce.
2. **At the history level**, the world-set characterization
   `τ.state r = τ.state 0 + r` fails with a failed
   `HAdd (translationFrame realTemporalOrder).toTaskFrame.WorldState realTemporalOrder.carrier ?m` synthesis,
   because `τ.state` *returns* a value in the unreduced `WorldState`. This one is **not**
   repairable by a type ascription or by a `@[reducible]` alias: the barrier sits inside
   `translationFrame`'s own body, and neither reaches it.

`cor:no-characterization`'s `F¹` half is entirely about histories, so symptom 2 is fatal to that
route. `ShiftSet.fibre` and `ShiftSet.frame` are both `@[reducible]`, so the carrier stays
transparent all the way through — and the route additionally hands over `total_eq_orbit`, which
*is* the world-set characterization, already proved generically.

A bespoke `FrameOver realTemporalOrder` with a hand-written `foneRel` and six hand-discharged axiom
fields was also built during research and is **deliberately not promoted**: it duplicates
`ShiftSet.fibre` for no gain. It should not be restored.

## `realTemporalOrder` is defined here rather than imported

`Metalogic/DedekindNonCompactness.lean` already defines a `realTemporalOrder`, with `@[reducible]` and
`noncomputable` both load-bearing for exactly the reasons recorded at that declaration; this is a
second copy of that two-line definition rather than an import, and the duplication is deliberate:

- **Not imported from `DedekindNonCompactness`**, because that module imports
  `Metalogic.StrongCompleteness` — the entire completeness development — which is far too heavy a
  dependency for a frame-construction module.
- **Not lifted into `Semantics/`**, because that would pull `Mathlib.Data.Real.Basic` into the
  most upstream layer of the tree, where nothing else needs it.

## On `ShiftSet`'s valuation field

`ShiftSet` bundles a valuation `A` alongside the action, and `ShiftSet.model` reads it off. That
model is **not used anywhere in this development**: L⁺ frame validity quantifies over *all*
`TaskModel`s over the frame, so routing anything through `S.model` would prove a strictly weaker
statement. Only `oneShift.frame` is consumed. The valuation field is discharged with the constant
`False` purely to satisfy the structure.

## References

* JPL paper `def:deterministic`, `app:deterministic`, `cor:no-characterization`
* `FormalSystem/Semantics/ShiftSet.lean` — `ShiftSet.fibre`, `ShiftSet.frame`, `total_eq_orbit`
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — the collapse this frame instantiates
* `FormalSystem/Semantics/Frames/Standard.lean` — `translationFrame`, the route not taken
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/-- The temporal order `ℝ`. Both annotations are load-bearing, exactly as at
`Metalogic/DedekindNonCompactness.lean`'s copy: without `@[reducible]`, `(0 : F1.WorldState)`
fails to elaborate and order instances on `F1.Duration` fail to synthesize. -/
@[reducible] noncomputable def realTemporalOrder : TemporalOrder := ⟨ℝ⟩

/--
`(ℝ, +)` acting on itself by translation, as a `ShiftSet`.

`sep` is the only field with content — it is the paper's *Limit* clause. Given that `u` lies
within every positive distance of `w`, instantiate the hypothesis at `x := |u - w|`; the
witness `y` is forced to be `u - w`, giving `|u - w| < |u - w|`. The same three lines as
`rShift`'s `sep`.
-/
@[reducible] noncomputable def oneShift : ShiftSet realTemporalOrder where
  Carrier := ℝ
  carrier_nonempty := ⟨0⟩
  sh := fun w d => w + d
  sh_zero := by intro w; simp
  sh_add := by intro w a b; exact add_assoc w a b
  sep := by
    intro w u h
    by_contra hne
    have hpos : (0 : ℝ) < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hu⟩ := h (|u - w|) hpos
    have hy' : y = u - w := by rw [hu]; ring
    rw [hy'] at hy
    exact lt_irrefl _ hy
  A := fun _ _ => False

/--
**F¹**: the deterministic translation flow over `ℝ`.

All `FrameOver` obligations come from `ShiftSet.fibre`; not one is discharged here. That is
the point of the route — see the module docstring.
-/
@[reducible] noncomputable def F1 : TaskFrame := oneShift.frame

/-- `F¹`'s task relation is translation (`ShiftSet.fibre_taskRel`). -/
theorem f1_taskRel_iff (w x u : ↑realTemporalOrder) : F1.TaskRel w x u ↔ u = w + x :=
  oneShift.fibre_taskRel w x u

/-- **F¹ is deterministic** (`def:deterministic`): the relation is functional, so every fibre is
a subsingleton. -/
theorem f1_deterministic : F1.Deterministic :=
  TaskFrame.fib_subsingleton_of_functional (f := fun w d => w + d) f1_taskRel_iff

/--
**The world-set characterization of F¹**, from `ShiftSet.total_eq_orbit`: every world history of
`F¹` *is* the translation orbit through its own state at time `0`.

This is the statement that `cor:no-characterization`'s `F¹` half consumes, and it is exactly the
statement that fails to elaborate on the `translationFrame` route (module docstring, symptom 2).
-/
theorem f1_total_eq_orbit (τ : WorldHistory F1) :
    τ = oneShift.hist (τ.state 0) :=
  oneShift.total_eq_orbit τ

/-- The pointwise form: a world history of `F¹` is `t ↦ τ(0) + t`. -/
theorem f1_states_eq (τ : WorldHistory F1) (r : ↑realTemporalOrder) :
    τ.state r = τ.state 0 + r := by
  have h := (f1_taskRel_iff _ _ _).mp (τ.val.respects_task 0 r (τ.property 0) (τ.property r))
  rw [sub_zero] at h
  exact h

/-- The two-point form: a world history of `F¹` moves by exactly the elapsed duration. -/
theorem f1_states_sub (τ : WorldHistory F1) (s r : ↑realTemporalOrder) :
    τ.state r = τ.state s + (r - s) := by
  exact (f1_taskRel_iff _ _ _).mp (τ.val.respects_task s r (τ.property s) (τ.property r))

/--
Two world histories of `F¹` agreeing at one time are **equal** — the `⟨τ⟩_x = {τ}` form of
`lem:deterministic-singleton` at this frame, obtained from the pointwise bridge plus
`WorldHistory.ext_state`.
-/
theorem f1_eq_of_states_eq {τ σ : WorldHistory F1}
    {t : ↑realTemporalOrder} (h : τ.state t = σ.state t) : τ = σ :=
  WorldHistory.ext_state fun r => states_eq_of_deterministic f1_deterministic h r

/--
**Deliverable (a) at F¹**, as a smoke test of Phase 1 against a concrete frame: *Determined*
`φ → ⊡φ` is valid on `F¹` for every `PlusFormula φ`, with no bespoke frame construction and no
new axiom obligation.
-/
theorem f1_determined (φ : PlusFormula) : F1.PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_deterministic f1_deterministic φ

/-- The full collapse at `F¹`: `⊡φ ↔ φ` is valid, both directions. -/
theorem f1_stab_biconditional (φ : PlusFormula) :
    F1.PlusValidOn (.imp (.stab φ) φ) ∧ F1.PlusValidOn (.imp φ (.stab φ)) :=
  stab_biconditional_plusValidOn_of_deterministic f1_deterministic φ

end FormalSystem.Metalogic.Independence

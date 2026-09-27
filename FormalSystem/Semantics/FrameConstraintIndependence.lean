/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Data.Int.SuccPred

/-!
# Pairwise independence of `def:frame`'s four constraints, over `ℤ`

`def:frame` lists four constraints on a task relation — *Compositionality*, *Seriality*, *Limit*
and *Saturation*. This module establishes that **none of the four is a consequence of the other
three** by exhibiting, for each one, a relation that satisfies the other three and refutes it,
and states the conjunction of the four as one citable theorem,
`constraints_pairwise_independent`.

## What this establishes

| Witness | Carrier | Satisfies | Refutes |
|---------|---------|-----------|---------|
| `emptyRel` | `Bool` | *Compositionality*, *Limit*, *Saturation* | *Seriality* |
| `totalRel` | `Bool` | *Compositionality*, *Seriality*, *Saturation* | *Limit* |
| `rayRel` | `ℤ` | *Compositionality*, *Seriality*, *Limit* | *Saturation* |
| `driftRel` | `ℤ` | *Seriality*, *Limit*, *Saturation* | *Compositionality* |

The consequence for the transcription audit is that the four-clause frame-condition row is
**provably incompressible**: a reader auditing the Lean transcription against the paper's four
clauses cannot be told that three of them would do.

## This is not the tree's first independence matrix — read this before citing it as one

`FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` already carries a complete
independence matrix, and says so in its own header:

- *Seriality* fails at the **void frame** — `StateTopology.voidRel` (`Bool → ℤ → Bool → Prop`,
  the empty relation) with `voidFrame_compositional`, `voidFrame_limit`, `voidFrame_saturation`,
  `voidFrame_not_serial`. `emptyRel` below is that relation restated at a bare `ℤ` duration.
- *Compositionality* fails at the **bump frame** — `StateTopology.bumpRel` with
  `bumpFrame_serial`, `bumpFrame_limit`, `bumpFrame_saturation`,
  `bumpFrame_not_compositional`. `driftRel` below is a different witness for the same row.
- *Saturation* fails at the **separating frame** — `StateTopology.SeparatingFrame.srel`
  (`ℚ → ℤ → ℚ → Prop`, unit-speed drift on a rational carrier over ℤ-time) with `srel_serial`,
  `srel_compositional`, `srel_limit`, `not_srel_saturation`; and, over dense time, at
  `StateTopology.RationalTwoOrigins`.
- *Limit* fails at the **four-state funnel** — `StateTopology.funnel_not_limit`. That one carries
  a `[DenselyOrdered ↑D]` binder, so it does **not** apply over `ℤ`.

So what this module adds is narrower than a first matrix, and should be cited as exactly that:

1. **The aggregate statement.** `constraints_pairwise_independent` is the tree's first single
   theorem saying the four constraints are pairwise independent. Before it, the fact was four
   scattered groups of theorems plus a claim in a module header.
2. **A *Limit* refutation that holds over `ℤ`.** `totalRel_not_limit` is genuinely new: the
   funnel's needs dense time, so nothing in the tree previously refuted *Limit* over the discrete
   duration order the certificate actually uses.
3. **Uniformity over one time structure, at no import weight.** The existing witnesses are spread
   over `ℤ`-time and dense time and over `Bool`, `ℚ` and `ℝ` carriers, and they live in
   topology-carrying leaves that are deliberately kept out of `FormalSystem/Semantics.lean` — see
   that aggregator's own note on why `Mathlib.Topology.*` instances must not reach it. This module
   imports `TaskFrame` and `Mathlib.Data.Int.SuccPred` and nothing else, so the aggregate result is
   reachable from the aggregator.

The cost of (3) is that three of the four rows below re-prove, at a different witness, something
the tree already knew. That is a real duplication and is recorded as such in
`docs/reference/transcription-audit-surface.md` rather than glossed over here.

## Why `D := ℤ` and not `↑intOrder`

The four constraint predicates are `D`-typed — `TaskFrame.Serial`, `Compositional`, `Limit` and
`Saturation` all take `{W : Type} (R : W → D → W → Prop)` against the section bundle
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` — so they apply at a bare
`ℤ` as readily as at a temporal order's carrier. And `intOrder := ⟨ℤ⟩` is `@[reducible]` with
`(↑intOrder : Type) = ℤ` by `rfl`, so **every statement below is already a statement about the
certificate's own time structure**; nothing is lost by writing `ℤ`.

What is gained is that `omega` works. `omega` inspects the *syntactic* type of a hypothesis and
does not see through the `TemporalOrder` coercion, so an `↑intOrder`-typed arithmetic binder is
opaque to it — the finding `FormalSystem/Semantics/TemporalOrder.lean`'s own header records.
Stating the witnesses at `ℤ` removes that obstacle at the level of the statement rather than by
patching tactics, and a later editor must not "tidy" these signatures back to `↑intOrder`.

## What this does *not* establish

Nothing about the **definitional** audit surface. This module bounds how far the *clause count* of
`def:frame` can fall; it says nothing about how many Lean *definitions* a human must read against
the paper's text, which is a different and larger surface. The two are kept apart deliberately —
see `docs/reference/transcription-audit-surface.md`, which states the definitional residue as a
count and names every row.

## Not in `Metalogic/Independence/`

That directory means **proof-system axiom** independence: a formula not derivable from a given
axiom set. This module is about *semantic frame constraints* being mutually irredundant, an
unrelated notion, and siting it there would collide with an established meaning.

## Tags

frame-constraints · independence · transcription-audit · def:frame
-/

namespace FormalSystem.Semantics

namespace FrameConstraintIndependence

/-! ### The *Seriality* witness -/

/--
The **empty relation** on a two-point carrier: nothing is related to anything.

*Seriality* fails outright — no state has any successor — while *Compositionality*, *Limit* and
*Saturation* hold vacuously. Paper: `def:frame#Seriality`.

This is `StateTopology.voidRel` restated at a bare `ℤ` duration, so that the aggregate theorem
below needs no topology import; see this module's header for why a second statement exists.
-/
def emptyRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False

/-- *Compositionality* holds vacuously for `emptyRel`: both sides of the biconditional are
`False`. Paper: `def:frame#Compositionality`. -/
theorem emptyRel_compositional : TaskFrame.Compositional emptyRel := by
  intro w v x y _ _
  simp [emptyRel]

/-- *Limit* holds vacuously for `emptyRel`: the hypothesis at a positive duration already
supplies a related pair, and there are none. Paper: `def:frame#Limit`. -/
theorem emptyRel_limit : TaskFrame.Limit emptyRel := by
  intro w u h
  obtain ⟨y, _, hy⟩ := h 1 (by norm_num)
  exact absurd hy (by simp [emptyRel])

/-- *Saturation* holds for `emptyRel`: every fibre is empty, hence a subsingleton, so
`TaskFrame.saturation_of_fib_subsingleton` applies. Paper: `def:frame#Saturation`. -/
theorem emptyRel_saturation : TaskFrame.Saturation emptyRel :=
  TaskFrame.saturation_of_fib_subsingleton fun _ _ u hu =>
    absurd hu (by simp [emptyRel, TaskFrame.Fib])

/-- **`emptyRel` refutes *Seriality*.** Paper: `def:frame#Seriality`. -/
theorem emptyRel_not_serial : ¬ TaskFrame.Serial emptyRel := by
  intro h
  obtain ⟨⟨_, hu⟩, -⟩ := h true 0 le_rfl
  exact hu

/-! ### The *Limit* witness -/

/--
The **total relation** on a two-point carrier: everything is related to everything at every
duration.

*Limit* fails — `false` lies in every positive cone of `true` — while the other three hold.
Paper: `def:frame#Limit`.

**This row is the one the tree did not already have.** The existing *Limit* refutation, the
four-state funnel's `StateTopology.funnel_not_limit`, carries a `[DenselyOrdered ↑D]` binder, so
it says nothing over the discrete duration order the certificate uses. This witness is over `ℤ`.

**Why `Bool` and not `Unit`.** `FrameOver.trivialFrame` already carries the total relation on a
one-point carrier, and there *Limit* holds, by `TaskFrame.limit_of_subsingleton`: over a
subsingleton there is nothing for the cone intersection to contain besides the point itself. A
carrier with two distinct points is exactly what makes the refutation possible, so the trivial
frame is not this witness and cannot be made into one.
-/
def totalRel : Bool → ℤ → Bool → Prop := fun _ _ _ => True

/-- *Compositionality* holds for `totalRel`: both sides of the biconditional are `True`.
Paper: `def:frame#Compositionality`. -/
theorem totalRel_compositional : TaskFrame.Compositional totalRel := by
  intro w v x y _ _
  simp [totalRel]

/-- *Seriality* holds for `totalRel`, by `TaskFrame.serial_of_total`.
Paper: `def:frame#Seriality`. -/
theorem totalRel_serial : TaskFrame.Serial totalRel :=
  TaskFrame.serial_of_total fun _ _ _ => trivial

/-- *Saturation* holds for `totalRel`: every fibre and every segment is the whole carrier, so any
directed family of them has the whole carrier as its intersection.
Paper: `def:frame#Saturation`. -/
theorem totalRel_saturation : TaskFrame.Saturation totalRel := by
  intro S _ hmem
  refine ⟨true, Set.mem_sInter.mpr ?_⟩
  intro s hs
  rcases (hmem s hs).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · trivial
  · exact ⟨trivial, trivial⟩

/-- **`totalRel` refutes *Limit*.** `false` lies in every positive cone of `true` — the witness
duration `0` serves at every radius — so *Limit* would force `false = true`.
Paper: `def:frame#Limit`. -/
theorem totalRel_not_limit : ¬ TaskFrame.Limit totalRel := by
  intro h
  have hbad := h false true fun x hx => ⟨0, by simpa using hx, trivial⟩
  simp at hbad

end FrameConstraintIndependence

end FormalSystem.Semantics

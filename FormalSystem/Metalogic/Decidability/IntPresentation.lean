/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.TaskModel
import FormalSystem.Metalogic.Decidability.FMP.Periodicity

/-!
# `IntPresentation` — a Computational Presentation of a Finite ℤ-Time Frame

A `FiniteFrameOver`'s `finite_world` field is `Finite`, which is a *non-constructive* statement:
it asserts a bijection with some `Fin n` exists without producing one, so it yields no enumeration
and cannot drive `decide`. Every computation on a finite frame therefore needs a separate,
constructive presentation. This module supplies it.

An `IntPresentation` is a finite directed graph on `Fin card` together with a `Bool`-valued
valuation, and it maps into the semantics through the ℤ-frame normal form: `FrameOver.ofStep`
(`Semantics/IntNormalForm.lean`) turns the bi-serial step relation into a `ParamTaskFrame ℤ` with all
seven fields discharged, so nothing is re-discharged by hand here.

## Main Definitions

- `IntPresentation` — the structure: `card`, `card_pos`, `step`, `val`, `fwd`, `bwd`
- `IntPresentation.toFiniteFibre` — the `FiniteFrameOver intOrder` it presents, built through `ofStep`
- `IntPresentation.toModel` — that frame equipped with the presentation's valuation

## Main Results

- `IntPresentation.step_iff` — the presented frame's one-step relation is the presentation's `step`
- `IntPresentation.isStepPath_iff` — its bi-infinite step-paths are the `step`-walks
- `IntPresentation.card_worldState` — the presented carrier has exactly `card` states, so the
  `Nat.card`-shaped bounds from `FMP/Periodicity.lean` are literally `card`

## `Fin card`, never `Finite`

`Fin card` is carried throughout, and no computation is ever routed through `Finite`. The
`Finite`-valued `finite_world` field is filled *from* `Fin card`, never read back out to drive a
decision; that direction is the whole point of the presentation.

## `card_pos` is not optional

The structure carries `card_pos : 0 < card` in addition to the fields the design sketch names.
It cannot be dropped. `ParamTaskFrame` has a mandatory `nonempty : Nonempty WorldState` field
(`def:task-relation` reads `W` as a *nonempty* set of world states), and `Fin 0` is empty, so
`toFiniteFibre` would not elaborate without it. `fwd`/`bwd` do not rescue the situation: at
`card = 0` both are vacuously true, so the empty presentation would otherwise be legal and
unusable.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/--
A **computational presentation** of a finite-`WorldState` frame over ℤ-time: a finite directed
graph, bi-serial, with a decidable valuation.

`step` and `val` are `Bool`-valued rather than `Prop`-valued precisely so that the presentation is
data a computation can consume, in contrast with the `Finite`-valued `FiniteFrameOver.finite_world`
this exists to replace.

**A presentation is not a finite object, and cannot be enumerated at a cardinality bound.** The
`step` field is finite data — `Fin card → Fin card → Bool` is a `Fintype` with `DecidableEq`, so
the step relations of a given `card` *can* be listed. `val` is not: it is a function on `Atom`,
which carries an `Infinite` instance (`Syntax/Atom.lean`). So there is no finite list of the
presentations of a given `card`, and any plan of the form "bound `card` by some
`presentationBound φ`, then enumerate the presentations up to that bound" does not typecheck as
stated. Closing that gap would need a valuation-restriction lemma — that only the atoms of `φ`
matter — which is not in this tree.

The shape that works instead, and that avoids the problem rather than solving it, is a
**formula-indexed candidate list**: `cands : Formula → List IntPresentation`, whose states are
subsets of `subformulaClosure φ` satisfying the local Hintikka conditions, whose `step` comes from
the `untl`/`snce` unfolding clauses (which relate a label at `t` to the label at `t ± 1`, i.e. they
*are* an adjacency relation), and whose valuation is read off the state — `val p X := decide
(atom p ∈ X)` — rather than quantified over. The list is then finite because the closure is, with
no bound on `card` and no enumeration over `Atom` anywhere. Note that this list still requires an
iterated pruning to a maximal serial subgraph, since a Hintikka type need not have a locally
coherent successor and `fwd`/`bwd` below are not free.
-/
structure IntPresentation where
  /-- Number of world states. -/
  card : ℕ
  /-- The carrier is nonempty — forced by `ParamTaskFrame`'s `nonempty` field; see the module
  docstring. -/
  card_pos : 0 < card
  /-- The one-step relation, as a decidable adjacency matrix. -/
  step : Fin card → Fin card → Bool
  /-- The valuation: which atoms hold at which state. -/
  val : Atom → Fin card → Bool
  /-- Forward seriality: every state has a successor. Not derivable — *Seriality* is free from
  *Occurrence*, never from ℤ (see `FrameOver.ofStep`). -/
  fwd : ∀ w, ∃ u, step w u = true
  /-- Backward seriality: every state has a predecessor. -/
  bwd : ∀ w, ∃ v, step v w = true

namespace IntPresentation

variable (P : IntPresentation)

/-- `NeZero card` is what makes numerals usable at `Fin P.card` — without it,
`(0 : Fin P.card)` does not elaborate for a general `P`, because instance search will not unfold
`P.card` to see that it is positive. -/
instance instNeZeroCard : NeZero P.card := ⟨by have := P.card_pos; omega⟩

instance instNonemptyFin : Nonempty (Fin P.card) := ⟨⟨0, P.card_pos⟩⟩

/-- The `Prop`-valued reading of the adjacency matrix. -/
def stepRel (w u : Fin P.card) : Prop := P.step w u = true

instance : DecidablePred fun p : Fin P.card × Fin P.card => P.stepRel p.1 p.2 :=
  fun p => decEq (P.step p.1 p.2) true

/--
The `ParamTaskFrame ℤ` the presentation presents, built through the normal form's `ofStep`.

All seven `ParamTaskFrame` fields come from `ofStep`; none is re-discharged here. In particular
*Spherical* goes through `ParamTaskFrame.spherical_of_finite`, the only route applicable to a relation
of arbitrary shape, and *Limit* through `ParamTaskFrame.limit_of_succOrder`.

**So bi-seriality is the sole frame obligation a presentation ever pays** — `fwd` and `bwd`,
already fields of the structure. The definition below is literally
`FrameOver.ofStep P.stepRel P.fwd P.bwd` and adds nothing: the four `def:frame` axioms cost one
obligation here, not four, however non-permissive the relation's shape. That pricing is specific to
ℤ (`ofStep` is stated at `ParamTaskFrame ℤ`, and `limit_of_succOrder` needs the successor structure); a
frame left polymorphic in its duration type pays each axiom by hand. See
`Semantics/IntNormalForm.lean` for the seven-field source table and the ℤ-versus-polymorphic
contrast.
-/
@[reducible] def toFibre : FrameOver intOrder :=
  FrameOver.ofStep P.stepRel P.fwd P.bwd

/--
The presented frame as a **total-space** value — the fibre, included by the constructor.

The naming split is deliberate and is the decision this migration had to make before touching the
BiLasso layer. `toFibre` is the value in `FrameOver intOrder`, which is what the ℤ-fibre API
(`step`, `ofStep_step`, `IsStepPath`, `mem_HF_iff_adjacent`) is stated over; `toTaskFrame` is its
image in the total space, which is what `WorldHistory`, `TaskModel` and `PartialHistory` take. Of
the 40 `P.toTaskFrame` occurrences across the 13 BiLasso files, **38 sit in total-space positions**
and keep their exact spelling — and now reach it through the constructor rather than through the
transitional `CoeOut`, which is what lets Phase 20 delete that coercion without touching BiLasso.
The two fibre-level uses (`step_iff` here, and `Orbit.lean`'s `hstep`) say `toFibre`.

`@[reducible]` on both is load bearing, for the reason `ShiftSet.frame` already records: the
BiLasso layer writes `(t : ℤ)` binders against histories over this frame, so
`↑P.toTaskFrame.Duration` has to reduce to `ℤ` at *reducible* transparency — that is where
instance synthesis and `rw` matching run. As a plain `def` it stays stuck, and `TruthLemma.lean`
fails with `HSub P.toTaskFrame.Duration.carrier ℤ ?m` and a `rw` that cannot find its pattern.
-/
@[reducible] def toTaskFrame : TaskFrame := P.toFibre.toTaskFrame

/-- The presented frame, bundled with its finiteness. `finite_world` is filled *from* `Fin card`;
it is never read back out to drive a computation. -/
@[reducible] def toFiniteFibre : FiniteFrameOver intOrder where
  toFrameOver := P.toFibre
  finite_world := inferInstanceAs (Finite (Fin P.card))

/-- The presented finite frame as a total-space value. -/
@[reducible] def toFiniteFrame : FiniteTaskFrame := P.toFiniteFibre.toFiniteTaskFrame

/-- The presented frame's world states are `Fin card`, definitionally. -/
theorem worldState_eq : P.toTaskFrame.WorldState = Fin P.card := rfl

/-- The presented carrier has exactly `card` states, so `FMP/Periodicity.lean`'s
`Nat.card`-shaped bounds read literally as `card` on a presentation. -/
theorem card_worldState : Nat.card P.toTaskFrame.WorldState = P.card := by
  simp [toTaskFrame, toFibre, FrameOver.ofStep, FrameOver.toTaskFrame, TaskFrame.WorldState]

/-- The presented frame's one-step relation is the presentation's `step`. -/
theorem step_iff (w u : Fin P.card) : P.toFibre.step w u ↔ P.step w u = true :=
  FrameOver.ofStep_step P.stepRel P.fwd P.bwd w u

/-- The presented frame's bi-infinite step-paths are exactly the walks in the adjacency matrix.
Combined with `mem_HF_iff_adjacent`, this identifies `H_F` over a presentation with the
`Bool`-decidable walks of a finite graph. -/
theorem isStepPath_iff (f : ℤ → Fin P.card) :
    IsStepPath P.toFibre f ↔ ∀ n : ℤ, P.step (f n) (f (n + 1)) = true := by
  constructor
  · intro h n; exact (P.step_iff (f n) (f (n + 1))).mp (h n)
  · intro h n; exact (P.step_iff (f n) (f (n + 1))).mpr (h n)

/-- The presented model: the presented frame together with the presentation's valuation. -/
def toModel : TaskModel P.toTaskFrame where
  valuation := fun w p => P.val p w = true

@[simp]
theorem toModel_valuation (w : Fin P.card) (p : Atom) :
    P.toModel.valuation w p ↔ P.val p w = true := Iff.rfl

end IntPresentation

/-!
## Worked instance

The two-state cycle, expressed as an `IntPresentation`. This is the same frame as
`Semantics.flipFrame`, now in computable form: `#eval`-able adjacency, `#eval`-able valuation.
-/

section WorkedInstance

/-- The two-state cycle as a presentation: `0 ⇄ 1`, with the atom `p` true only at state `0`. -/
def flipPresentation : IntPresentation where
  card := 2
  card_pos := by omega
  step := fun w u => w != u
  val := fun _ w => w == 0
  fwd := fun w => ⟨if w = 0 then 1 else 0, by revert w; decide⟩
  bwd := fun w => ⟨if w = 0 then 1 else 0, by revert w; decide⟩

example : flipPresentation.step (0 : Fin 2) (1 : Fin 2) = true := by decide
example : flipPresentation.step (0 : Fin 2) (0 : Fin 2) = false := by decide
example : Nat.card flipPresentation.toTaskFrame.WorldState = 2 :=
  flipPresentation.card_worldState

/-- The presentation's frame elaborates as a `ParamFiniteTaskFrame ℤ`. -/
example : FiniteFrameOver intOrder := flipPresentation.toFiniteFibre

end WorkedInstance

end FormalSystem.Metalogic.Decidability

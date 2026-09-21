/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Data.Int.SuccPred
import FormalSystem.Semantics.FrameClassValidity
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Semantics.TaskModel

/-!
# History-lifting morphisms and recurrence-freeness

The language-independent layer beneath the two expressive extensions
`FormalSystem/HybridLanguage/` and `FormalSystem/QuantLanguage/`: the morphisms along which truth
is transported, and the frame property those languages are measured against.

## History-lifting morphisms

A `HistMap F' F` is a function on world states that carries the task relation forward (`forth`)
and along which every world history of `F` through an image state lifts to a world history of
`F'` through the given state, at the same time (`lift`). A `HistMorphism` is in addition onto
histories (`onto`). Such a morphism preserves:

* **pulled-back valuations** — `HistMap.pullM` interprets a sentence letter at a state of `F'` by
  its interpretation at the image state;
* **the history and time structure** — `HistMap.mapH` sends a history of `F'` to a history of `F`
  over the same times, and by `onto` every history of `F` arises so;
* **the same-state relation** — two (history, time) pairs of `F'` at one state are sent to two
  pairs of `F` at one state, and `lift`, applied at an arbitrary time, returns a pair of `F'` at
  the given state for every pair of `F` at its image.

It does **not** preserve state identity: `toFun` need not be injective, so two times at which a
history of `F` occupies one state may be the images of two times at which the lifted history of
`F'` occupies two. Every truth clause that consults a state only through the three items above is
therefore invariant along a history-lifting morphism, and a clause that compares the states at two
times of one history is not. That is the distinction the two extension languages are built to
exhibit.

The intended instance is the projection of a translation product onto its base frame, which
unwinds every recurrence of the base. It lives with the translation product, not here; this module
states the abstract notion only.

## Recurrence-freeness

`TaskFrame.RecurrenceFree G` says that no world history of `G` visits a world state twice. It is
the frame property that the distinction above is about: a history-lifting morphism from a
recurrence-free frame onto a frame with recurrence identifies states that the source keeps apart.
No frame class excludes recurrence — the one-state frame over any temporal order has it
(`trivialFrame_not_recurrenceFree`), and one such frame lies in each class
(`exists_sat_not_recurrenceFree`).

## Main Definitions

- `HistMap`, `HistMorphism` — history-lifting maps and morphisms over one temporal order
- `HistMap.mapH` — the image of a world history
- `HistMap.pullM` — the pulled-back model
- `TaskFrame.RecurrenceFree` — no world history visits a world state twice

## Main Results

- `HistMap.mapH_state` — the image history's state is the image of the state (`rfl`)
- `trivialFrame_not_recurrenceFree` — the one-state frame has recurrence
- `exists_sat_not_recurrenceFree` — every frame class contains a frame with recurrence

## Paper correspondence

The manuscript defines no morphism of task frames and names no recurrence property; both are
formalization-native. World histories are `def:world-history`'s possible worlds, and recurrence
is the phenomenon the manuscript's construction section (`sec:Construction`) describes in the
passage "nothing prevents a world state from occurring at many times in a single history".
-/

namespace FormalSystem.Semantics

open FormalSystem.ProofSystem

/-! ## History-lifting morphisms -/

/-- A history-lifting map between two task frames over one temporal order: a function on world
states that carries the task relation forward and along which histories lift through any chosen
preimage of the state they occupy at any chosen time.

Paper: — (formalization-native; the paper defines no morphism of task frames) -/
structure HistMap {D : TemporalOrder} (F' F : FrameOver D) where
  /-- The underlying function on world states. -/
  toFun : F'.WorldState → F.WorldState
  /-- The task relation is carried forward. -/
  forth : ∀ a x b, F'.TaskRel a x b → F.TaskRel (toFun a) x (toFun b)
  /-- Every history of `F` through `toFun a` at `t` lifts to a history of `F'` through `a` at
  `t`. -/
  lift : ∀ (τ : WorldHistory F.toTaskFrame) (a : F'.WorldState) (t : ↑D),
    toFun a = τ.state t →
      ∃ τ' : WorldHistory F'.toTaskFrame, τ'.state t = a ∧ ∀ s, toFun (τ'.state s) = τ.state s

/-- A history-lifting morphism: a history-lifting map that is onto histories.

`onto` is not a consequence of `lift`, which lifts only through a state already known to have a
preimage.

Paper: — (formalization-native; the paper defines no morphism of task frames) -/
structure HistMorphism {D : TemporalOrder} (F' F : FrameOver D) extends HistMap F' F where
  /-- Every history of `F` is the image of a history of `F'`. -/
  onto : ∀ τ : WorldHistory F.toTaskFrame,
    ∃ τ' : WorldHistory F'.toTaskFrame, ∀ s, toFun (τ'.state s) = τ.state s

/-- The image of a world history under a history-lifting map: the same times, the image states.
It respects the task relation by `forth`. -/
def HistMap.mapH {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F)
    (τ' : WorldHistory F'.toTaskFrame) : WorldHistory F.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => g.toFun (τ'.state t))
    (fun s t => g.forth _ _ _ (τ'.respects_task s t))

/-- The image history occupies the image state. -/
@[simp] theorem HistMap.mapH_state {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F)
    (τ' : WorldHistory F'.toTaskFrame) (t : ↑D) :
    (g.mapH τ').state t = g.toFun (τ'.state t) := rfl

/-- The pulled-back model: a sentence letter holds at a state of `F'` iff it holds at the image
state. Its propositions are exactly the ones that cannot tell two preimages of one state apart. -/
def HistMap.pullM {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F)
    (M : TaskModel F.toTaskFrame) : TaskModel F'.toTaskFrame :=
  ⟨fun a p => M.valuation (g.toFun a) p⟩

/-! ## Recurrence-freeness -/

/-- No world history visits a world state twice.

Paper: — (formalization-native; the paper names no recurrence property of frames) -/
def TaskFrame.RecurrenceFree (G : TaskFrame) : Prop :=
  ∀ (τ : WorldHistory G) (s t : G.Duration), τ.state s = τ.state t → s = t

/-- The constant history of the one-state frame. -/
private def trivialConstHist {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] : WorldHistory (FrameOver.trivialFrame (D := D)).toTaskFrame :=
  WorldHistory.ofTotal _ (fun _ => ()) fun _ _ => FrameOver.trivialFrame_taskRel.mpr trivial

/-- The one-state frame over any temporal order has recurrence: its constant history occupies its
one state at `0` and at any positive time.

Paper: — (formalization-native; the paper names no recurrence property of frames) -/
theorem trivialFrame_not_recurrenceFree {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    ¬ (FrameOver.trivialFrame (D := D)).toTaskFrame.RecurrenceFree := by
  intro h
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  haveI : Subsingleton (FrameOver.trivialFrame (D := D)).WorldState :=
    inferInstanceAs (Subsingleton Unit)
  exact hx.ne (h trivialConstHist 0 x (Subsingleton.elim _ _))

/-- **Every frame class contains a frame with recurrence**: the one-state frame over `ℤ`, `ℚ` or
`ℝ`. No frame class can therefore validate a formula that defines recurrence-freeness.

The discrete instances are passed explicitly because instance search does not see through the
carrier of a `TemporalOrder` built from bundled instances.

Paper: — (formalization-native; the paper names no recurrence property of frames) -/
theorem exists_sat_not_recurrenceFree (fc : FrameClass) :
    ∃ G : TaskFrame, fc.Sat G ∧ ¬ G.RecurrenceFree := by
  cases fc with
  | Base => exact ⟨(FrameOver.trivialFrame (D := ℤ)).toTaskFrame, trivial,
      trivialFrame_not_recurrenceFree⟩
  | Dense => exact ⟨(FrameOver.trivialFrame (D := ℚ)).toTaskFrame,
      inferInstanceAs (DenselyOrdered ℚ), trivialFrame_not_recurrenceFree⟩
  | ZTime => exact ⟨(FrameOver.trivialFrame (D := ℤ)).toTaskFrame,
      @TaskFrame.isZTime_of_instances _ (inferInstanceAs (SuccOrder ℤ))
        (inferInstanceAs (PredOrder ℤ)) (inferInstanceAs (IsSuccArchimedean ℤ))
        (inferInstanceAs (IsPredArchimedean ℤ)), trivialFrame_not_recurrenceFree⟩
  | RTime => exact ⟨(FrameOver.trivialFrame (D := ℝ)).toTaskFrame,
      ⟨inferInstanceAs (DenselyOrdered ℝ), fun s hne hbdd => ⟨sSup s, isLUB_csSup hne hbdd⟩⟩,
      trivialFrame_not_recurrenceFree⟩

end FormalSystem.Semantics

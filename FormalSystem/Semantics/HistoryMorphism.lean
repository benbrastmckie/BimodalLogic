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
import FormalSystem.PlusLanguage.PlusValidity

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

`HistMorphism.plus_invariance` records the consequence for the stability language L⁺: truth of
every L⁺ formula is invariant along a history-lifting morphism, and so L⁺ frame validity passes
from the source to the image (`HistMorphism.plusValidOn`). It is the L⁺ counterpart of the
`HybridFormula` version (`HybridLanguage/HybridInvariance.lean`'s `regFree_invariance`) and the
abstract form of the translation-product-specific `plus_invariance`, whose
`FrameOver.translationProductProj` is its intended instance.

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
- `TwoWayBounded` — two-way bounded morphisms of task frames over one temporal order
- `TaskFrame.RecurrenceFree` — no world history visits a world state twice

## Main Results

- `HistMap.mapH_state` — the image history's state is the image of the state (`rfl`)
- `HistMorphism.plus_invariance` — L⁺ truth is invariant along a history-lifting morphism
- `HistMorphism.plusValidOn` — L⁺ frame validity travels from the source to the image
- `TwoWayBounded.exists_preimage_step`, `.exists_preimage_step_neg` — the successor- and
  predecessor-lifting forms, the second derived from the first by reflection
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

/-! ### L⁺ truth invariance along a morphism

The language-level payoff of the three preservation items listed in the module header. Every
clause of the L⁺ recursion consults a world state only through the pulled-back valuation, the
history-and-time structure, or the same-state relation, so L⁺ truth is carried along any
history-lifting morphism, and frame validity travels from the source to the image.

This is the L⁺ counterpart of `HybridLanguage/HybridInvariance.lean`'s `regFree_invariance`,
stated directly at `PlusTruthAt` rather than through the hybrid embedding, and the abstract
form of `Frames/TranslationProduct.lean`'s `plus_invariance`, whose
`FrameOver.translationProductProj` is the intended instance.
-/

section PlusInvariance

open FormalSystem.PlusLanguage

/--
**L⁺ truth is invariant along any history-lifting morphism**: a formula holds at the pulled-back
model and a history of the source exactly when it holds at the given model and the image history.

By induction on `φ`. The `box` case uses `onto` and `WorldHistory.ext_state`: every history of
the image frame is the image of one of the source, so the two unrestricted history quantifiers
range over matching sets. The `stab` case uses `lift` at the present time: a history of the image
frame through the image of the present state lifts to a history of the source frame through the
present state itself. The `atom` case is `rfl` through `HistMap.pullM` and `HistMap.mapH_state`,
and the three remaining cases are congruences.

State identity across two times is never consulted, which is why no recurrence-freeness
hypothesis appears: that is exactly the distinction the two extension languages are built to
exhibit (`HybridLanguage/HybridRecurrence.lean`).

Paper: — (formalization-native; the paper defines no morphism of task frames)
-/
theorem HistMorphism.plus_invariance {D : TemporalOrder} {F' F : FrameOver D}
    (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
      PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro _ _; exact Iff.rfl
  | bot => intro _ _; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro hb ρ
      obtain ⟨ρ', hρ'⟩ := g.onto ρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih ρ' t).1 (hb _)
      rwa [hm] at this
    · intro hb σ'; exact (ih σ' t).2 (hb _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' u)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' u)
  | stab a ih =>
    intro τ' t
    constructor
    · intro hs ρ hρ
      obtain ⟨ρ', hρ't, hρ'⟩ := g.lift ρ (τ'.state t) t hρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih ρ' t).1 (hs _ hρ't.symm)
      rwa [hm] at this
    · intro hs σ' he
      exact (ih σ' t).2 (hs _ (congrArg g.toFun he))

/--
**L⁺ frame validity travels from the source of a morphism to its image.**

Given a model, a history and a time of the image frame, `onto` produces a history of the source
whose image it is; validity on the source at the pulled-back model then transports along
`HistMorphism.plus_invariance`.

The direction is the one `Frames/TranslationProduct.lean`'s `plusValidOn_of_prod` records, and
only this one holds: validity is **not** reflected back from the image to the source, since the
source carries valuations that are not pulled back from anywhere
(`frame_validity_not_reflected`).

Paper: — (formalization-native; the paper defines no morphism of task frames)
-/
theorem HistMorphism.plusValidOn {D : TemporalOrder} {F' F : FrameOver D}
    (g : HistMorphism F' F) (φ : PlusFormula)
    (h : F'.toTaskFrame.PlusValidOn φ) : F.toTaskFrame.PlusValidOn φ := by
  intro M τ t
  obtain ⟨τ', hτ'⟩ := g.onto τ
  have hm : g.mapH τ' = τ := WorldHistory.ext_state hτ'
  have := (g.plus_invariance M φ τ' t).1 (h (g.pullM M) τ' t)
  rwa [hm] at this

end PlusInvariance

/-! ## Two-way bounded morphisms

A two-way bounded morphism is the modal-logician's p-morphism, read at a task frame rather than
at a digraph: the relation is carried forward, and every relational step out of an image state is
in the image of a step out of the state itself.

**Why one condition where a digraph needs two.** On a digraph a two-way bounded morphism carries
three fields: a homomorphism condition, a *forth* condition lifting successors, and a *back*
condition lifting predecessors. A task relation is already two-sided — `FrameOver.TaskRel` is the
reflective extension of the primitive positive-cone relation, so `F.TaskRel w d u ↔
F.TaskRel u (-d) w` holds outright (`FrameOver.reflection`) — and the backward condition is
therefore the forward one at a negative duration. `TwoWayBounded` accordingly has two fields, and
`TwoWayBounded.exists_preimage_step_neg` derives the predecessor-lifting form from the
successor-lifting one rather than postulating it.

The intended instance is `Prod.fst` on a translation product, the underlying function of
`FrameOver.translationProductProj`; it is landed as
`FrameOver.translationProduct_twoWayBounded` beside the product itself
(`Frames/TranslationProduct.lean`), since this module is below it in the import order.
-/

section TwoWay

/--
**A two-way bounded morphism of task frames over one temporal order**: a function on world states
that carries the task relation forward, and along which every task out of an image state lifts to
a task out of the given state.

`forth` is `HistMap.forth` verbatim. `step` is strictly weaker than `HistMap.lift`: it lifts one
task, where `lift` lifts a whole history. Over discrete time the two are equivalent, which is
`TwoWayBounded.exists_histMorphism_of_isZTime`.

Paper: — (formalization-native; the paper defines no morphism of task frames)
-/
structure TwoWayBounded {D : TemporalOrder} {F' F : FrameOver D}
    (f : F'.WorldState → F.WorldState) : Prop where
  /-- The task relation is carried forward, exactly as `HistMap.forth` asks. -/
  forth : ∀ a x b, F'.TaskRel a x b → F.TaskRel (f a) x (f b)
  /-- Every task out of an image state lifts to a task out of the given state. -/
  step : ∀ a x v, F.TaskRel (f a) x v → ∃ b, F'.TaskRel a x b ∧ f b = v

namespace TwoWayBounded

variable {D : TemporalOrder} {F' F : FrameOver D} {f : F'.WorldState → F.WorldState}

/-- **The named, reusable form of the `step` field**: an `x`-successor of an image state is the
image of an `x`-successor of the state. -/
theorem exists_preimage_step (h : TwoWayBounded f)
    (a : F'.WorldState) (x : ↑D) (v : F.WorldState) (hv : F.TaskRel (f a) x v) :
    ∃ b : F'.WorldState, F'.TaskRel a x b ∧ f b = v :=
  h.step a x v hv

/-- **The predecessor-lifting form, derived rather than postulated**: an `x`-predecessor of an
image state is the image of an `x`-predecessor of the state.

This is the field a digraph two-way bounded morphism has to carry separately. Here it is `step`
at `-x`, read through `FrameOver.reflection` on each side. -/
theorem exists_preimage_step_neg [F'.IsRegular] [F.IsRegular] (h : TwoWayBounded f)
    (a : F'.WorldState) (x : ↑D) (u : F.WorldState) (hu : F.TaskRel u x (f a)) :
    ∃ c : F'.WorldState, F'.TaskRel c x a ∧ f c = u := by
  obtain ⟨c, hc, hfc⟩ := h.step a (-x) u ((F.reflection u x (f a)).1 hu)
  exact ⟨c, (F'.reflection c x a).2 hc, hfc⟩

end TwoWayBounded

end TwoWay

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
  | Base => exact ⟨(FrameOver.trivialFrame (D := ℤ)).toTaskFrame, inferInstance,
      trivialFrame_not_recurrenceFree⟩
  | Dense => exact ⟨(FrameOver.trivialFrame (D := ℚ)).toTaskFrame,
      ⟨inferInstance, inferInstanceAs (DenselyOrdered ℚ)⟩, trivialFrame_not_recurrenceFree⟩
  | ZTime => exact ⟨(FrameOver.trivialFrame (D := ℤ)).toTaskFrame,
      ⟨inferInstance, @TaskFrame.isZTime_of_instances _ (inferInstanceAs (SuccOrder ℤ))
        (inferInstanceAs (PredOrder ℤ)) (inferInstanceAs (IsSuccArchimedean ℤ))
        (inferInstanceAs (IsPredArchimedean ℤ))⟩, trivialFrame_not_recurrenceFree⟩
  | RTime => exact ⟨(FrameOver.trivialFrame (D := ℝ)).toTaskFrame,
      ⟨inferInstance,
        ⟨inferInstanceAs (DenselyOrdered ℝ), fun s hne hbdd => ⟨sSup s, isLUB_csSup hne hbdd⟩⟩⟩,
      trivialFrame_not_recurrenceFree⟩

end FormalSystem.Semantics

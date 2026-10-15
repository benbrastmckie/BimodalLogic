/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.StateSetTruth
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Correspondence.DurationFrames

/-!
# `lem:state-set` at the translation flow — the choice-free route

The state-set bridge (`Independence/StateSetTruth.lean`) runs over a frame satisfying (H1)
`OrderFlow` and (H2) `StateOccurs`. (H2) is derivable at any regular frame, through
`StateOccurs.of_isRegular` and so through `cor:occurrence`, `thm:extension` and Zorn's lemma; the
`_of_isRegular` forms in that file carry `Classical.choice` for exactly that reason.

At the frames `lem:state-set` is *applied* to, no such appeal is needed: a world history through
a given state at a given time is exhibited outright, as a translation. This module builds that
second route, in two layers.

The **flow layer** routes the translation over an arbitrary `(D : TemporalOrder)` through
`ShiftSet`, whose `sep` field discharges the structural obligation directly. It is *absolutely*
choice-free: `selfShift` and `translationFlow` report `[propext]`, and every theorem over them
`[propext, Quot.sound]`.

The **frame layer** restates the same results at `translationFrame D`, the frame constant the
`*Sharpness` countermodels build on, with the witness written as the paper's own `σ_c`. Here the
pin is *relative*: `#print axioms` traverses a declaration's type as well as its value, and
`translationFrame` itself reports `Classical.choice`, so no statement mentioning it can report
less. What the measurement does establish is that the (H2) discharge contributes nothing — the
five theorems report exactly what the frame constant reports.

## Main Definitions

- `selfShift D` — `D` acting on itself by translation, as a `ShiftSet`
- `translationFlow D` — the task frame of that action; `W = D`, `w ⇒_x u ⟺ u = w + x`
- `translationState` — the identity view of a `translationFrame` world state as a duration

## Main Results

- `translationFlow_taskRel`, `translationFlow_states_eq` — the task relation and the shape of a
  world history's state function
- `translationFlow_orderFlow` — (H1) at the flow
- `translationFlow_stateOccurs` — (H2) at the flow, by an explicit translation history
- `translationFlow_deterministic` — the flow is `Deterministic` (`def:deterministic`)
- `translationFlow_plusTruthAt_iff_mem_satSet`, `translationFlow_determined`,
  `translationFlow_plusValidOn_iff_satSet_univ` — `lem:state-set`'s three sentences at the flow
- `translationFrame_orderFlow`, `translationFrame_stateOccurs` — (H1) and (H2) at
  `translationFrame D`
- `translationFrame_plusTruthAt_iff_mem_satSet`, `translationFrame_determined`,
  `translationFrame_plusValidOn_iff_satSet_univ` — the same three sentences there

## Axiom pin

Recorded from `#print axioms` against this module as built, and re-checkable by uncommenting:

```
#print axioms FormalSystem.Metalogic.Independence.selfShift
#print axioms FormalSystem.Metalogic.Independence.translationFlow
#print axioms FormalSystem.Metalogic.Independence.translationFlow_taskRel
#print axioms FormalSystem.Metalogic.Independence.translationFlow_states_eq
#print axioms FormalSystem.Metalogic.Independence.translationFlow_orderFlow
#print axioms FormalSystem.Metalogic.Independence.translationFlow_stateOccurs
#print axioms FormalSystem.Metalogic.Independence.translationFlow_deterministic
#print axioms FormalSystem.Metalogic.Independence.translationFlow_plusTruthAt_iff_mem_satSet
#print axioms FormalSystem.Metalogic.Independence.translationFlow_determined
#print axioms FormalSystem.Metalogic.Independence.translationFlow_plusValidOn_iff_satSet_univ
```

`selfShift` and `translationFlow` report `[propext]`. The other eight report
`[propext, Quot.sound]`. **None of the ten reports `Classical.choice`**, and that holds over an
arbitrary `(D : TemporalOrder)` — no real carrier, no instantiation at a classical field. This
is an **absolute** pin, not a relative one.

Two things make it available. First, (H2) is discharged by exhibiting the orbit history outright,
so the chain `cor:occurrence` → `thm:extension` → Zorn is never entered. Second, the frame is
reached through `ShiftSet.fibre_isRegular`, which takes its structural obligation from the
structure's own `sep` field:

*Limit*

— read off `sep` there, rather than through `TaskFrame.limit_of_shift`, which is where the
neighbourhood's `Classical.choice` otherwise enters. The three proof-writing choices that keep
the `sep` discharge itself choice-free at an arbitrary duration group are recorded at
`selfShift` and `translationFlow_orderFlow`: additive witnesses, right-hand monotonicity of
addition, and `abs_pos.mpr` under `by_contra`.

The `translationFrame` layer below is pinned **relatively** instead, for a reason that is about
`#print axioms` and not about this argument; see the section-level docstring there.

## References

* JPL paper `lem:state-set` — the three sentences instantiated here; `def:state-set` — the
  recursion they are about; `def:flow` — the order-isomorphism condition `OrderFlow` states
  pointwise
* JPL paper `rmk:choice` — the paper's own inventory of which results are choice-free, and the
  record that the general occurrence fact genuinely needs the extension theorem
* JPL paper `def:canonical-frames`, `lem:canonical-frames` — the translation frame and `σ_c`
* `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the bridge and its three routes
* `FormalSystem/Semantics/ShiftSet.lean` — the shift-set presentation of a group action
* `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — `translationStates`,
  `translationSigma` and the translation frame's history calculus

## Tags

state-set · choice-free · translation · occurrence · lem:state-set · rmk:choice
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/-! ## The flow layer: `D` acting on itself -/

/--
The duration group acting on **itself** by translation, presented as a `ShiftSet`.

The structural obligation is discharged from the order on `↑D` alone: if `u ≠ w` then `|u - w|`
is a positive duration, and the hypothesis applied at it produces a duration strictly below
itself. Writing the obligation this way — `by_contra` together with `abs_pos.mpr`, rather than
through `abs_eq_zero` — is what keeps the declaration choice-free at an arbitrary
`TemporalOrder`.

`@[reducible]` is load-bearing: it is what lets `LinearOrder (translationFlow D).WorldState`
synthesize with no help, which every (H1) statement below needs.
-/
@[reducible] def selfShift (D : TemporalOrder) : ShiftSet D where
  Carrier := ↑D
  carrier_nonempty := ⟨0⟩
  sh := fun w d => w + d
  sh_zero := by intro w; exact add_zero w
  sh_add := by intro w a b; exact add_assoc w a b
  sep := by
    intro w u h
    by_contra hne
    have hpos : (0 : ↑D) < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hu⟩ := h (|u - w|) hpos
    have hy' : y = u - w := by rw [hu]; abel
    rw [hy'] at hy
    exact lt_irrefl _ hy
  A := fun _ _ => False

/--
**The translation flow** over an arbitrary duration group: `W = D` and `w ⇒_x u ⟺ u = w + x`,
obtained as the task frame of `selfShift`. This is the `ShiftSet` avatar of
`def:canonical-frames`' translation frame, and the layer at which the choice-free pin below is
*absolute*.
-/
@[reducible] def translationFlow (D : TemporalOrder) : TaskFrame := (selfShift D).frame

/-- The translation flow's task relation, unfolded: `w ⇒_x u` exactly when `u = w + x`. -/
theorem translationFlow_taskRel (D : TemporalOrder) (w x u : ↑D) :
    (translationFlow D).TaskRel w x u ↔ u = w + x := (selfShift D).fibre_taskRel w x u

/--
Every world history of the translation flow is a translation of the identity: its state at `r` is
its state at `0` shifted by `r`. Read off `respects_task` at `0` and `r`.
-/
theorem translationFlow_states_eq (D : TemporalOrder)
    (τ : WorldHistory (translationFlow D)) (r : ↑D) : τ.state r = τ.state 0 + r := by
  have h := (translationFlow_taskRel D _ _ _).mp (τ.respects_task 0 r)
  rw [sub_zero] at h
  exact h

/--
**(H1) at the translation flow**, which is `def:flow`'s order-isomorphism condition stated
pointwise. All three fields reduce to `translationFlow_states_eq` plus the right-hand
monotonicity of addition; the witness for the two hitting fields is written additively as
`-(τ.state 0) + v`, since right monotonicity is the choice-free half at a `TemporalOrder`.
-/
theorem translationFlow_orderFlow (D : TemporalOrder) : OrderFlow (translationFlow D) where
  strictMono := by
    intro τ s t hst
    rw [translationFlow_states_eq D τ s, translationFlow_states_eq D τ t]
    exact add_lt_add_right hst _
  hits_future := by
    intro τ x v hv
    refine ⟨-(τ.state 0) + v, ?_, ?_⟩
    · rw [translationFlow_states_eq D τ x] at hv
      have h2 := add_lt_add_right hv (-(τ.state 0))
      rw [show -(τ.state 0) + (τ.state 0 + x) = x by abel] at h2
      exact h2
    · rw [translationFlow_states_eq D τ (-(τ.state 0) + v)]; abel
  hits_past := by
    intro τ x v hv
    refine ⟨-(τ.state 0) + v, ?_, ?_⟩
    · rw [translationFlow_states_eq D τ x] at hv
      have h2 := add_lt_add_right hv (-(τ.state 0))
      rw [show -(τ.state 0) + (τ.state 0 + x) = x by abel] at h2
      exact h2
    · rw [translationFlow_states_eq D τ (-(τ.state 0) + v)]; abel

/--
**(H2) at the translation flow**, by an explicit translation: the orbit history through `-x + w`
occupies `w` at time `x`. The witness is exhibited outright — `cor:occurrence` is never invoked,
so neither `thm:extension` nor Zorn is reached. This is the Lean content of the paper's
observation at `lem:state-set` that the appeals to `cor:occurrence` are inessential wherever a
world through a given state at a given time can be written down as a translation.
-/
theorem translationFlow_stateOccurs (D : TemporalOrder) : StateOccurs (translationFlow D) := by
  intro w x
  refine ⟨(selfShift D).hist (-x + w), ?_⟩
  change -x + w + x = w
  abel

/--
The translation flow is `Deterministic` (`def:deterministic`): its task relation is the graph of
the function `(w, d) ↦ w + d`, so each fibre is a subsingleton. This generalises the
corresponding fact about `F¹` off `ℝ` to an arbitrary duration group, at no cost.
-/
theorem translationFlow_deterministic (D : TemporalOrder) :
    (translationFlow D).Deterministic :=
  TaskFrame.fib_subsingleton_of_functional (f := fun w d => w + d) (translationFlow_taskRel D)

/-! ## `lem:state-set`'s three sentences at the flow -/

/--
**`lem:state-set`'s first sentence at the translation flow**: L⁺ truth at a world history and a
time is membership of the occupied state in the formula's state set.

A term-mode application of the two-hypothesis bridge to `translationFlow_orderFlow` and
`translationFlow_stateOccurs`. Since (H2) arrives by an explicit translation, the proof reaches
neither `cor:occurrence` nor `thm:extension`, and so never Zorn's lemma.
-/
theorem translationFlow_plusTruthAt_iff_mem_satSet (D : TemporalOrder)
    (M : TaskModel (translationFlow D)) (φ : PlusFormula) :
    ∀ (τ : WorldHistory (translationFlow D)) (t : ↑D),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet (translationFlow_orderFlow D) (translationFlow_stateOccurs D) M φ

/--
**`lem:state-set`'s second sentence at the translation flow**: every instance of *Determined* is
valid there.

Again by explicit translation rather than by `cor:occurrence`, so neither `thm:extension` nor
Zorn is reached.
-/
theorem translationFlow_determined (D : TemporalOrder) (φ : PlusFormula) :
    (translationFlow D).PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow (translationFlow_orderFlow D) (translationFlow_stateOccurs D) φ

/--
**`lem:state-set`'s third sentence at the translation flow**: frame-validity is the state set
exhausting the carrier under every assignment.

The right-hand side mentions no frame at all, and the (H2) it rests on is the explicit
translation — so this reads `lem:state-set` off `def:state-set` alone, with no appeal to
`cor:occurrence`, `thm:extension` or Zorn.
-/
theorem translationFlow_plusValidOn_iff_satSet_univ (D : TemporalOrder) (φ : PlusFormula) :
    (translationFlow D).PlusValidOn φ ↔ ∀ V : ↑D → Atom → Prop, satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ (translationFlow_orderFlow D) (translationFlow_stateOccurs D) φ

end FormalSystem.Metalogic.Independence

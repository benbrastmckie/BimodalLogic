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
- `translationFrameWorldLinearOrder` — the frame's world-state order, which every (H1)
  statement at that frame needs

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

### The relative pin at `translationFrame`

The frame layer below is pinned **relatively** instead, for a reason about `#print axioms` and
not about this argument:

```
#print axioms FormalSystem.Semantics.translationFrame
#print axioms FormalSystem.Metalogic.Independence.translationState
#print axioms FormalSystem.Metalogic.Independence.translationFrameWorldLinearOrder
#print axioms FormalSystem.Metalogic.Independence.translationFrame_orderFlow
#print axioms FormalSystem.Metalogic.Independence.translationFrame_stateOccurs
#print axioms FormalSystem.Metalogic.Independence.translationFrame_plusTruthAt_iff_mem_satSet
#print axioms FormalSystem.Metalogic.Independence.translationFrame_determined
#print axioms FormalSystem.Metalogic.Independence.translationFrame_plusValidOn_iff_satSet_univ
```

All eight report `[propext, Classical.choice, Quot.sound]` — the frame constant's own profile and
the seven declarations over it, the same string. `#print axioms` traverses a declaration's *type*
as well as its value, and every statement in that section mentions `translationFrame D`, so none
of them can report less however its proof runs.

The residual source is named: `TaskFrame.limit_of_shift`, which `translationFrame` calls to
discharge one structural obligation at the identity position function. It is left exactly as it
stands; a choice-free rewrite of it would shrink axiom sets that are pinned by exact string
equality across the tree, and that is a decision about a repository-wide invariant.

What the equality of the eight strings does establish is that the (H2) discharge contributes
nothing: no `cor:occurrence`, no `thm:extension`, no Zorn. The choice is frame-constant-borne,
not argument-borne. For the same three sentences with *no* `Classical.choice` at all, read the
flow layer.

As a cross-check that the generic argument itself is choice-free, and that only instantiation can
add choice: `plusTruthAt_iff_mem_satSet` reports `[propext]` alone and `determined_of_orderFlow`
`[propext, Quot.sound]`.

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

section TranslationFrame

/-!
## The same results at `translationFrame D`

`def:canonical-frames`' translation frame is the frame constant the `*Sharpness` countermodels
build on, so the three sentences must be available there too, and (H2) must be discharged there
by the paper's own `σ_c` rather than by `cor:occurrence`. Both happen below.

**Why this half needs glue the flow layer does not.** `ShiftSet.fibre` and `ShiftSet.frame` are
`@[reducible]`, so instance search sees straight through them to the carrier and
`LinearOrder (translationFlow D).WorldState` synthesizes unaided. `translationFrame` is a plain
`def`, so it does not: hence the `translationFrameWorldLinearOrder` instance, and hence the
`translationState` view, which is what lets the additive witnesses elaborate on a world-state
operand. The same reducibility gap is why `translationStates` exists at all in
`Semantics/Correspondence/DurationFrames.lean`.

**Why the pin here is relative.** `#print axioms` traverses a declaration's *type* as well as its
value. Every statement below mentions `translationFrame D`, and `translationFrame` itself reports
`[propext, Classical.choice, Quot.sound]` — the `Classical.choice` arriving through
`TaskFrame.limit_of_shift`, the structural obligation it discharges at the identity position
function. So no statement mentioning the frame constant can report less, whatever its proof does.
What the measurement establishes is the other half: the five theorem-shaped declarations report
*exactly* `translationFrame`'s own profile, so the (H2) discharge contributes nothing —
no `cor:occurrence`, no `thm:extension`, no Zorn. The choice is frame-constant-borne, not
argument-borne, which is the same distinction `Independence/DeterminismUndefinable.lean`'s pin
draws for `ℝ`.

The absolutely choice-free statement of the same three sentences is the flow layer above.
-/

/--
The identity view of a `translationFrame` world state as a duration. The frame's world-state type
*is* `↑D`, but not reducibly so, and this view is what lets `-x + w` elaborate on a world-state
operand.
-/
def translationState {D : TemporalOrder}
    (w : (translationFrame D).toTaskFrame.WorldState) : ↑D := w

/--
The linear order on `translationFrame D`'s world states, which every (H1) statement needs.
Definitionally the carrier's own order; keyed on a head symbol no existing instance mentions, so
no diamond arises.
-/
instance translationFrameWorldLinearOrder (D : TemporalOrder) :
    LinearOrder ((translationFrame D).toTaskFrame.WorldState) := inferInstanceAs (LinearOrder ↑D)

/--
**(H1) at the translation frame.** All three fields go through `translationStates_eq`, the
paper's pointwise law for the frame (`lem:canonical-frames`), plus right-hand monotonicity of
addition; the witnesses are written additively, as at the flow.
-/
theorem translationFrame_orderFlow (D : TemporalOrder) :
    OrderFlow (translationFrame D).toTaskFrame where
  strictMono := by
    intro τ s t hst
    show (τ.state s : ↑D) < (τ.state t : ↑D)
    rw [show (τ.state s : ↑D) = translationStates τ 0 + s from translationStates_eq τ s,
        show (τ.state t : ↑D) = translationStates τ 0 + t from translationStates_eq τ t]
    exact add_lt_add_right hst _
  hits_future := by
    intro τ x v hv
    refine ⟨-(translationStates τ 0) + translationState v, ?_, ?_⟩
    · have h : translationStates τ 0 + x < translationState v := by
        rw [← translationStates_eq τ x]; exact hv
      have h2 := add_lt_add_right h (-(translationStates τ 0))
      rw [show -(translationStates τ 0) + (translationStates τ 0 + x) = x by abel] at h2
      exact h2
    · change translationStates τ (-(translationStates τ 0) + translationState v)
        = translationState v
      rw [translationStates_eq τ (-(translationStates τ 0) + translationState v)]
      abel
  hits_past := by
    intro τ x v hv
    refine ⟨-(translationStates τ 0) + translationState v, ?_, ?_⟩
    · have h : translationState v < translationStates τ 0 + x := by
        rw [← translationStates_eq τ x]; exact hv
      have h2 := add_lt_add_right h (-(translationStates τ 0))
      rw [show -(translationStates τ 0) + (translationStates τ 0 + x) = x by abel] at h2
      exact h2
    · change translationStates τ (-(translationStates τ 0) + translationState v)
        = translationState v
      rw [translationStates_eq τ (-(translationStates τ 0) + translationState v)]
      abel

/--
**(H2) at the translation frame**, by the paper's own `σ_c` (`def:canonical-frames`) at
`c = -x + w`: the translation by that duration occupies `w` at time `x`.

The witness is written down, not extended into existence — `PartialHistory.extension` and
`cor:occurrence` are both unreached. This is the frame-constant form of the paper's observation
at `lem:state-set` that its appeals to `cor:occurrence` are inessential to the applications,
where a world through a given state at a given time is exhibited explicitly as a translation.
-/
theorem translationFrame_stateOccurs (D : TemporalOrder) :
    StateOccurs (translationFrame D).toTaskFrame := by
  intro w x
  refine ⟨translationSigma D (-x + translationState w), ?_⟩
  change translationStates (translationSigma D (-x + translationState w)) x = translationState w
  rw [translationSigma_states]
  abel

/-- **`lem:state-set`'s first sentence at the translation frame**: the state-set bridge, with
(H2) discharged by `σ_c` rather than by `cor:occurrence`. -/
theorem translationFrame_plusTruthAt_iff_mem_satSet (D : TemporalOrder)
    (M : TaskModel (translationFrame D).toTaskFrame) (φ : PlusFormula) :
    ∀ (τ : WorldHistory (translationFrame D).toTaskFrame) (t : ↑D),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet (translationFrame_orderFlow D) (translationFrame_stateOccurs D) M φ

/-- **`lem:state-set`'s second sentence at the translation frame**: every instance of *Determined*
is valid there. -/
theorem translationFrame_determined (D : TemporalOrder) (φ : PlusFormula) :
    (translationFrame D).toTaskFrame.PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow (translationFrame_orderFlow D) (translationFrame_stateOccurs D) φ

/-- **`lem:state-set`'s third sentence at the translation frame**: frame-validity is the state set
exhausting the carrier under every assignment. -/
theorem translationFrame_plusValidOn_iff_satSet_univ (D : TemporalOrder) (φ : PlusFormula) :
    (translationFrame D).toTaskFrame.PlusValidOn φ
      ↔ ∀ V : (translationFrame D).toTaskFrame.WorldState → Atom → Prop,
          satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ (translationFrame_orderFlow D) (translationFrame_stateOccurs D) φ

end TranslationFrame

end FormalSystem.Metalogic.Independence

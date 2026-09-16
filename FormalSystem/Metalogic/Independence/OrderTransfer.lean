/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusValidity

/-!
# Order transfer under (H1) and (H2) — the frame-independent layer

The temporal cases of the state-set recursion (`Independence/StateSetTruth.lean`) turn on one
fact about a frame and nothing else: **its total histories are order-isomorphisms of the duration
order onto the state order.** That fact is isolated here as two hypotheses, and everything the
recursion needs from it is proved once, against the hypotheses alone.

## The two hypotheses

- `OrderFlow F` — **(H1)**: every total history's state function is strictly monotone, reaches
  every strictly greater state at some strictly later time, and every strictly lesser state at
  some strictly earlier time. Equivalently: each total history is an order-isomorphism of
  `F.Duration` onto `F.WorldState`.
- `StateOccurs F` — **(H2)**: every world state lies on some total history at every time. This is
  the hypothesis the `□` case consumes, and stating it as a hypothesis rather than deriving it
  is what keeps the development constructive: the general "every state occurs" fact
  (`cor:occurrence`) goes through `thm:extension` and hence Zorn, whereas each frame this is
  instantiated at supplies an *explicit* witness.

## Main Results

- `OrderFlow.lt_iff` — a total history's state function is order-*reflecting* as well as
  order-preserving
- `OrderFlow.future_image` / `OrderFlow.past_image` — the image of a strict future (past) of `x`
  under a total history is exactly the strict upper (lower) set of the state at `x`
- `OrderFlow.between` / `OrderFlow.between_past` — the **change of variables**: `x < c < y`
  matches `τ(x) < τ(c) < τ(y)` in both directions, which is exactly what the `untl` and `snce`
  cases need
- `StateOccurs.state_image` — under (H2) the states occupied at a fixed time by the totality of
  total histories are all of `F.WorldState`

## Why one generic layer and not two parallel developments

The recursion these lemmas serve mentions **only the order on `W`** and neither frame's task
relation. That is the crux clause of `cor:no-characterization`: two frames whose histories are
order-isomorphisms of the same order onto the same state order satisfy the same recursion, so
they validate exactly the same L⁺ formulas — even when one is deterministic and the other is
not. Written as two parallel inductions the point would be invisible; written once against (H1)
and (H2) it is the statement of this module.

## Terminology of record: an *indistinguishable* pair, not a "separating" one

The two frames this is instantiated at (`Independence/DriftFrame.lean` and
`Independence/RealTranslationFrame.lean`) **agree** on every store-free, recall-free sentence
while differing in determinism. The argument is *elimination by indistinguishability*: no L⁺
sentence can tell them apart, so no set of L⁺ sentences defines determinism. Calling them a
"separating pair" inverts the mechanism, and has already misled one reader into expecting the
non-deterministic member to *refute* *Determined* — which it in fact validates.

## References

* JPL paper `cor:no-characterization`, `app:drift`, `cor:occurrence`
* `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the recursion these serve
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics

variable {F : TaskFrame}

/-!
## (H1) — total histories are order-isomorphisms
-/

/--
**(H1)**: every total history of `F` is an order-isomorphism of the duration order onto the
world-state order.

The three fields are strict monotonicity and the two surjectivity halves. Nothing here mentions
the task relation; a frame satisfies (H1) or not purely in virtue of what its total histories
look like as functions.
-/
structure OrderFlow (F : TaskFrame) [LinearOrder F.WorldState] : Prop where
  /-- A total history's state function is strictly monotone. -/
  strictMono : ∀ (τ : ConvexHistory F) (hτ : τ.IsTotal) {s t : F.Duration}, s < t →
    τ.states s (hτ s) < τ.states t (hτ t)
  /-- Every state strictly above the state at `x` is occupied at some strictly later time. -/
  hits_future : ∀ (τ : ConvexHistory F) (hτ : τ.IsTotal) {x : F.Duration} {v : F.WorldState},
    τ.states x (hτ x) < v → ∃ c, x < c ∧ τ.states c (hτ c) = v
  /-- Every state strictly below the state at `x` is occupied at some strictly earlier time. -/
  hits_past : ∀ (τ : ConvexHistory F) (hτ : τ.IsTotal) {x : F.Duration} {v : F.WorldState},
    v < τ.states x (hτ x) → ∃ c, c < x ∧ τ.states c (hτ c) = v

namespace OrderFlow

variable [LinearOrder F.WorldState]

/-- Strict monotonicity **reflects** the order as well as preserving it: on a linear order a
strictly monotone map is an order embedding. -/
theorem lt_iff (h : OrderFlow F) (τ : ConvexHistory F) (hτ : τ.IsTotal) {s t : F.Duration} :
    τ.states s (hτ s) < τ.states t (hτ t) ↔ s < t := by
  constructor
  · intro hlt
    rcases lt_trichotomy s t with hst | rfl | hst
    · exact hst
    · exact absurd hlt (lt_irrefl _)
    · exact absurd (h.strictMono τ hτ hst) (asymm hlt)
  · exact h.strictMono τ hτ

/-- The state function of a total history is injective. -/
theorem states_injective (h : OrderFlow F) (τ : ConvexHistory F) (hτ : τ.IsTotal)
    {s t : F.Duration} (hst : τ.states s (hτ s) = τ.states t (hτ t)) : s = t := by
  rcases lt_trichotomy s t with hlt | heq | hlt
  · exact absurd hst (ne_of_lt (h.strictMono τ hτ hlt))
  · exact heq
  · exact absurd hst.symm (ne_of_lt (h.strictMono τ hτ hlt))

/--
**The future-image lemma.** The states a total history takes strictly after `x` are exactly the
states strictly above its state at `x`.
-/
theorem future_image (h : OrderFlow F) (τ : ConvexHistory F) (hτ : τ.IsTotal) (x : F.Duration) :
    {v | ∃ y, x < y ∧ τ.states y (hτ y) = v} = {v | τ.states x (hτ x) < v} := by
  ext v
  constructor
  · rintro ⟨y, hxy, rfl⟩
    exact h.strictMono τ hτ hxy
  · intro hv
    obtain ⟨c, hc, hcv⟩ := h.hits_future τ hτ hv
    exact ⟨c, hc, hcv⟩

/-- The past mirror of `future_image`. -/
theorem past_image (h : OrderFlow F) (τ : ConvexHistory F) (hτ : τ.IsTotal) (x : F.Duration) :
    {v | ∃ y, y < x ∧ τ.states y (hτ y) = v} = {v | v < τ.states x (hτ x)} := by
  ext v
  constructor
  · rintro ⟨y, hyx, rfl⟩
    exact h.strictMono τ hτ hyx
  · intro hv
    obtain ⟨c, hc, hcv⟩ := h.hits_past τ hτ hv
    exact ⟨c, hc, hcv⟩

/--
**Change of variables, future form.** A state strictly between `τ(x)` and `τ(y)` is `τ(c)` for a
time `c` strictly between `x` and `y`.

This is the `untl` case's whole content: the recursion's interval condition ranges over states
between two states, the truth recursion's over times between two times, and this lemma is the
translation in one direction (the other being `strictMono`).
-/
theorem between (h : OrderFlow F) (τ : ConvexHistory F) (hτ : τ.IsTotal) {x y : F.Duration}
    {u : F.WorldState} (h1 : τ.states x (hτ x) < u) (h2 : u < τ.states y (hτ y)) :
    ∃ c, x < c ∧ c < y ∧ τ.states c (hτ c) = u := by
  obtain ⟨c, hxc, hcu⟩ := h.hits_future τ hτ h1
  refine ⟨c, hxc, ?_, hcu⟩
  rw [← h.lt_iff τ hτ, hcu]
  exact h2

/-- **Change of variables, past form.** The `snce` case's mirror of `between`. -/
theorem between_past (h : OrderFlow F) (τ : ConvexHistory F) (hτ : τ.IsTotal)
    {x y : F.Duration} {u : F.WorldState} (h1 : τ.states y (hτ y) < u)
    (h2 : u < τ.states x (hτ x)) :
    ∃ c, y < c ∧ c < x ∧ τ.states c (hτ c) = u := by
  obtain ⟨c, hcx, hcu⟩ := h.hits_past τ hτ h2
  refine ⟨c, ?_, hcx, hcu⟩
  rw [← h.lt_iff τ hτ, hcu]
  exact h1

end OrderFlow

/-!
## (H2) — every state is occupied at every time
-/

/--
**(H2)**: for every world state `w` and every time `x`, some total history has state `w` at
time `x`.

Stated as a hypothesis rather than proved: the general fact (`cor:occurrence`) needs
`thm:extension` and hence Zorn, while each frame this is instantiated at supplies a witness
explicitly. That is what keeps the non-definability result choice-free.
-/
def StateOccurs (F : TaskFrame) : Prop :=
  ∀ (w : F.WorldState) (x : F.Duration),
    ∃ (τ : ConvexHistory F) (hτ : τ.IsTotal), τ.states x (hτ x) = w

/--
**The `□` transfer.** Under (H2), the states occupied at a fixed time, as the history ranges over
all total histories, exhaust `F.WorldState`.
-/
theorem StateOccurs.state_image (h : StateOccurs F) (t : F.Duration) :
    {w | ∃ (σ : ConvexHistory F) (hσ : σ.IsTotal), σ.states t (hσ t) = w} = Set.univ := by
  ext w
  simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
  exact h w t

end FormalSystem.Metalogic.Independence

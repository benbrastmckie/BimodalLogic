/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.ForMathlib.Topology.Sierpinski

/-!
# Over `ℝ`, a countable carrier already forces a static frame

`Semantics/Correspondence/Rigidity.lean` shows that over a **dense Archimedean** duration group
a task frame with **finitely many** world states is static. This module shows that over `ℝ` the
finiteness can be weakened all the way to countability, and that neither density nor the
Archimedean property is needed to do it: what replaces them is Dedekind completeness, entering
through Baire's theorem.

> `FrameOver.static_of_countable`: if `F : FrameOver realOrder` has countably many world states
> then `w ⇒_x u` holds iff `w = u`, at every real duration `x`.

The sharp form is `FrameOver.constant_of_countable_range`: it is the *range* of a world history,
not the carrier of the frame, that has to be countable.

## The proof, and what each axiom pays for

Suppose `w ⇒_x u` with `x ≠ 0`. The two-point partial history `{⟨0, w⟩, ⟨x, u⟩}` respects the
task relation, so `thm:extension` extends it to a **total** history `σ` with `σ 0 = w` and
`σ x = u`. Each level set `{t | σ t = a}` is closed: by `def:frame#Limit` there is, for each
`a ≠ σ t`, a radius below which no task leads from `σ t` to `a`, and `def:world-history`'s
`respects_task` turns that radius into a punctured neighbourhood of `t` missing the `a`-level
set. So `σ` is a map `ℝ → F.WorldState` with countable range and closed level sets, and
`Sierpinski.const_of_countable_range` makes it constant. Hence `w = u`.

The axiom division of labour is therefore:

* ***Saturation*** (`def:frame-properties`) supplies the total history, through `thm:extension`.
  This is where Zorn's lemma — and hence `Classical.choice` — enters; nothing else in the
  argument is nonconstructive.
* ***Limit*** (`def:frame#Limit`) makes the level sets closed. This is the only use of *Limit*.
* ***Seriality*** (`def:frame-properties`) plus the reflection law supply the *positive* half of
  `Static`, that `w ⇒_x w` for every `x`: seriality produces some `u` with `w ⇒_x u`, and the
  collapse identifies it with `w`.
* ***Compositionality*** contributes only what `thm:extension` itself consumes; the argument
  above never chops a duration, which is exactly the difference from `Rigidity.lean`.

Density and the Archimedean property of the duration order are **not** used. They are what
`Rigidity.lean` spends to run its chop; here Dedekind completeness of `ℝ` does the work instead,
by way of the Baire argument inside `Sierpinski.const_of_isClosed_levelSet`.

## Why this module is not inside `Rigidity.lean`

`Rigidity.lean`'s `## Import discipline` section promises that it imports only
`Semantics.TaskFrame` and `Mathlib.Algebra.Order.Archimedean.Defs`, defines no frame and **takes
no topology**. The argument here is topological and consumes `thm:extension`, so it lives beside
that module rather than inside it.

## Cardinality sharpness, and Q3

The countability hypothesis of `static_of_countable` cannot be dropped:
`Rigidity.realClock_not_static` is the translation frame on `ℝ` itself — states `ℝ`, with
`w ⇒_x u ↔ u = w + x` — which satisfies all four frame axioms and is not static, and
`Rigidity.paddedClock` is the corresponding
uncountable witness over an *arbitrary* duration order. The escape is exactly a state space that
carries a clock reading.

In the other direction, `FrameOver.exists_local_clock` records how far the converse goes: a
non-constant history over `ℝ` has a time at which *every* window, however short, already carries
uncountably many world states. The stronger reading — that some history is *injective* on an
interval — is **UNVERIFIED**; see `exists_local_clock`'s own docstring.
-/

namespace FormalSystem.Semantics

open TaskFrame

/-- The real line as a duration order. -/
noncomputable abbrev realOrder : TemporalOrder := TemporalOrder.of ℝ

namespace FrameOver

variable (F : FrameOver realOrder)

/--
**Level sets of a world history are closed — from *Limit* alone.**

`def:frame#Limit` gives, for each pair `a ≠ b`, a radius `r > 0` with no task of duration
`|y| < r` from `b` to `a`. `def:world-history`'s `respects_task` then keeps every time within
`r` of a `b`-time out of the `a`-level set.
-/
theorem levels_closed (τ : WorldHistory F.toTaskFrame) (a : F.WorldState) :
    IsClosed {t : ℝ | τ.state t = a} := by
  rw [← isOpen_compl_iff, Metric.isOpen_iff]
  intro t ht
  have hne : a ≠ τ.state t := fun hh => ht hh.symm
  have hnot : ¬ (∀ x : ℝ, 0 < x → ∃ y, |y| < x ∧ F.TaskRel (τ.state t) y a) :=
    fun hh => hne (F.limit _ _ hh)
  push Not at hnot
  obtain ⟨r, hr, hrad⟩ := hnot
  refine ⟨r, hr, ?_⟩
  intro s hs
  simp only [Metric.mem_ball, Real.dist_eq] at hs
  intro hsa
  have hrel : F.TaskRel (τ.state t) (s - t) (τ.state s) := τ.respects_task t s
  rw [(hsa : τ.state s = a)] at hrel
  exact (hrad (s - t) hs) hrel

/--
**`thm:extension` at the two-point partial history `{⟨0, w⟩, ⟨x, u⟩}`** (`x ≠ 0`): every task is
realized by a total history.

The domain `{0, x}` is **not convex**, so this is `thm:extension` and not `cor:occurrence`; the
construction is the one already used by `Semantics/DeterministicBridge.lean`'s
`deterministic_of_singletonClasses`. This is the sole consumer of *Saturation* in this module,
and hence the sole source of `Classical.choice`.
-/
theorem exists_history_of_taskRel (w u : F.WorldState) (x : ℝ) (hx : x ≠ 0)
    (hR : F.TaskRel w x u) :
    ∃ σ : WorldHistory F.toTaskFrame, σ.state 0 = w ∧ σ.state x = u := by
  have hne0 : ¬ ((0 : ℝ) = x) := fun h0 => hx h0.symm
  have h0x : (if (0 : ℝ) = x then u else w) = w := if_neg hne0
  have hxx : (if x = x then u else w) = u := if_pos rfl
  have hresp : ∀ (s t : ℝ), (s = 0 ∨ s = x) → (t = 0 ∨ t = x) →
      F.TaskRel (if s = x then u else w) (t - s) (if t = x then u else w) := by
    intro s t hs ht
    rcases hs with hs | hs <;> rcases ht with ht | ht <;> rw [hs, ht]
    · rw [h0x, sub_zero]; exact (F.nullity_identity w w).mpr rfl
    · rw [h0x, hxx, sub_zero]; exact hR
    · rw [h0x, hxx, zero_sub]; exact (F.reflection w x u).mp hR
    · rw [hxx, sub_self]; exact (F.nullity_identity u u).mpr rfl
  obtain ⟨σ, hext⟩ := PartialHistory.extension F.toTaskFrame
    { domain := fun t => t = 0 ∨ t = x
      nonempty_domain := ⟨0, Or.inl rfl⟩
      states := fun t _ => if t = x then u else w
      respects_task := fun s t hs ht => hresp s t hs ht }
  exact ⟨σ, (hext.agree 0 (Or.inl rfl)).trans h0x, (hext.agree x (Or.inr rfl)).trans hxx⟩

/-- **Every world history over `ℝ` whose range is countable is constant.** The sharp form of
the rigidity below: it is the range, not the carrier, that has to be countable. *Limit* makes
the level sets closed, and Sierpiński collapses them. -/
theorem constant_of_countable_range (τ : WorldHistory F.toTaskFrame)
    (hcount : (Set.range τ.state).Countable) : ∀ s t : ℝ, τ.state s = τ.state t :=
  Sierpinski.const_of_countable_range τ.state hcount (levels_closed F τ)

/--
**Over `ℝ`, a countable carrier forces a static frame.**

No finiteness and no uniform dwell time, and — unlike `FrameOver.static_of_finite` — no density
and no Archimedean hypothesis either: Dedekind completeness replaces them, through the Baire
argument in `Sierpinski.const_of_isClosed_levelSet`.

The axioms consumed: *Saturation* (through `thm:extension`, which is where Zorn enters), *Limit*
(for closed level sets), *Seriality* plus the reflection law (for the positive half of `Static`),
and from *Compositionality* only what `thm:extension` itself needs.

The hypothesis is sharp in cardinality: `Rigidity.realClock_not_static` and
`Rigidity.paddedClock_not_static` are non-static frames whose carriers are uncountable, and
`Rigidity.ratClock_not_static` shows that over `ℚ` — dense and Archimedean — a countable carrier
does not suffice.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem static_of_countable [Countable F.WorldState] : Static F.TaskRel := by
  have fwd : ∀ w x u, F.TaskRel w x u → w = u := by
    intro w x u hR
    by_cases hx : x = 0
    · subst hx; exact (F.nullity_identity w u).mp hR
    · obtain ⟨σ, h0, hxu⟩ := exists_history_of_taskRel F w u x hx hR
      have hcst := constant_of_countable_range F σ (Set.to_countable _) 0 x
      rw [h0, hxu] at hcst; exact hcst
  intro w x u
  refine ⟨fwd w x u, ?_⟩
  rintro rfl
  rcases le_total (0 : ℝ) x with hx | hx
  · obtain ⟨⟨v, hv⟩, _⟩ := F.serial w x hx
    have hh := fwd w x v hv
    subst hh; exact hv
  · obtain ⟨⟨v, hv⟩, _⟩ := F.serial w (-x) (neg_nonneg.mpr hx)
    have hh := fwd w (-x) v hv
    subst hh
    exact (F.reflection w x w).mpr hv

end FrameOver
end FormalSystem.Semantics

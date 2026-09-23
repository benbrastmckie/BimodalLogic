/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.ForMathlib.Topology.Sierpinski
import Mathlib.Analysis.Real.Cardinality

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

/-! ## Q3: what a non-static frame over `ℝ` must contain -/

/-- **A non-constant history over `ℝ` has uncountable range.** The contrapositive of
`constant_of_countable_range`, recorded separately because it is the form the cardinality
census uses. -/
theorem range_uncountable_of_nonconstant (τ : WorldHistory F.toTaskFrame) {s t : ℝ}
    (h : τ.state s ≠ τ.state t) : ¬ (Set.range τ.state).Countable :=
  fun hc => h (constant_of_countable_range F τ hc s t)

/--
**The local-clock theorem.** At a time where a history is not locally constant, *every*
time-window already carries uncountably many world states.

The window is reached without leaving `ℝ`: compose the history with the continuous retraction
of `ℝ` onto `[t-r, t+r]`. Its level sets are still closed and its range is the window's image,
so if that image were countable the Sierpiński collapse would make the history constant on the
window — that is, locally constant at `t`.
-/
theorem uncountable_image_of_not_localConst (τ : WorldHistory F.toTaskFrame) {t : ℝ}
    (ht : t ∉ Sierpinski.locallyConstantLocus τ.state) {r : ℝ} (hr : 0 < r) :
    ¬ (τ.state '' Set.Icc (t - r) (t + r)).Countable := by
  intro hcount
  set p : ℝ → ℝ := fun s => max (t - r) (min (t + r) s) with hp
  have hpcont : Continuous p := continuous_const.max (continuous_const.min continuous_id)
  have hpmem : ∀ s, p s ∈ Set.Icc (t - r) (t + r) :=
    fun s => ⟨le_max_left _ _, max_le (by linarith) (min_le_left _ _)⟩
  have hrange : (Set.range (τ.state ∘ p)).Countable := by
    refine Set.Countable.mono ?_ hcount
    rintro _ ⟨s, rfl⟩
    exact ⟨p s, hpmem s, rfl⟩
  have hclosed : ∀ a, IsClosed (Sierpinski.levelSet (τ.state ∘ p) a) :=
    fun a => (levels_closed F τ a).preimage hpcont
  have hconst := Sierpinski.const_of_countable_range (τ.state ∘ p) hrange hclosed
  refine ht (Sierpinski.mem_locallyConstantLocus_iff.mpr (mem_interior.mpr
    ⟨Set.Ioo (t - r) (t + r), ?_, isOpen_Ioo, ⟨by linarith, by linarith⟩⟩))
  intro y hy
  have h1 : p y = y := by
    rw [hp]
    simp only
    rw [min_eq_right (le_of_lt hy.2), max_eq_right (le_of_lt hy.1)]
  have h2 : p t = t := by
    rw [hp]
    simp only
    rw [min_eq_right (by linarith), max_eq_right (by linarith)]
  have hyt := hconst y t
  simp only [Function.comp_apply, h1, h2] at hyt
  exact hyt

/--
**A non-constant history over `ℝ` reads a clock somewhere.** There is a time `t` such that every
window `[t-r, t+r]`, however short, carries uncountably many world states.

This is the exact sense — and the *only* sense established here — in which a non-static frame
over `ℝ` must "contain a clock". The stronger reading, that some history is **injective on an
interval**, is **UNVERIFIED**: the obstruction is whether a history that is injective on no
interval can still satisfy the composition half of `def:frame#Compositionality`, and nothing in
this module settles it. See this task's research report for the full statement of the
obstruction; `static_of_countable` does not depend on it.
-/
theorem exists_local_clock (τ : WorldHistory F.toTaskFrame) {s₀ t₀ : ℝ}
    (hne : τ.state s₀ ≠ τ.state t₀) :
    ∃ t : ℝ, ∀ r : ℝ, 0 < r → ¬ (τ.state '' Set.Icc (t - r) (t + r)).Countable := by
  have hB : ((Sierpinski.locallyConstantLocus τ.state)ᶜ : Set ℝ).Nonempty := by
    rcases Set.eq_empty_or_nonempty ((Sierpinski.locallyConstantLocus τ.state)ᶜ) with he | hne'
    · exact absurd (Sierpinski.const_of_isPreconnected (h := τ.state) isPreconnected_univ
        (by rw [Set.compl_empty_iff.mp he]) (Set.mem_univ t₀) s₀ (Set.mem_univ s₀)) hne
    · exact hne'
  obtain ⟨t, ht⟩ := hB
  exact ⟨t, fun r hr => uncountable_image_of_not_localConst F τ ht hr⟩

end FrameOver
end FormalSystem.Semantics

/-!
## The cardinality-sharpness witnesses

`static_of_countable` is sharp in cardinality, and the two witnesses below say so. Both are
clocks: their state space carries a clock reading, which is exactly the escape the theorem
leaves open, and which the manuscript's standing caveat rules out of the intended reading of a
world state.

`paddedClock` fills the whole *uncountable* row of the cardinality census at once — at `ℤ`, `ℚ`,
`ℚ ×ₗ ℚ` and `ℝ` alike — since it is defined over an arbitrary `(D : TemporalOrder)`. Its first
coordinate is a clock and its second is inert `ℝ`-ballast; the presenting relation is functional,
so *Saturation* is `TaskFrame.saturation_of_fib_subsingleton` and *Limit* is
`TaskFrame.limit_of_shift` at the first projection.

These live here rather than in `RigiditySharpness.lean` because they are the sharpness of *this*
module's theorem and need `Mathlib.Analysis.Real.Cardinality`, which that module does not
otherwise import.
-/

namespace FormalSystem.Semantics.Rigidity

open FormalSystem.Semantics TaskFrame

/-- **The real clock is not static.** The translation frame on `ℝ` — states `ℝ`, with
`w ⇒_x u ↔ u = w + x` — satisfies all four frame axioms and moves `0` to `1` in duration `1`.
Its carrier is uncountable, so it does not contradict `FrameOver.static_of_countable`; it is
what shows that theorem's countability hypothesis cannot simply be dropped. -/
theorem realClock_not_static : ¬ Static (translationFrame realOrder).TaskRel := by
  intro h
  have h1 : (0 : ℝ) = 1 := (h (0 : ℝ) (1 : ℝ) (1 : ℝ)).mp (by simp [translationFrame_taskRel])
  exact absurd h1 (by norm_num)

/-- The presenting relation of `paddedClock`: the first coordinate translates by the duration
and the second is inert. -/
def padRel (D : TemporalOrder) : (↑D × ℝ) → ↑D → (↑D × ℝ) → Prop :=
  fun w d u => u.1 = w.1 + d ∧ u.2 = w.2

/-- **The padded clock over an arbitrary duration order**: the translation flow on `↑D` paired
with inert `ℝ`-ballast. The ballast is there only to make the carrier uncountable whatever `D`
is, so that one frame fills the uncountable row of the census at every duration order at once. -/
noncomputable def paddedClock (D : TemporalOrder) : FrameOver D :=
  haveI : Nonempty (↑D × ℝ) := ⟨(0, 0)⟩
  FrameOver.ofReflectiveRegular (↑D × ℝ) (padRel D)
    (by
      intro w d u
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨by rw [h1]; simp, h2.symm⟩
      · rintro ⟨h1, h2⟩; exact ⟨by rw [h1]; simp, h2.symm⟩)
    (TaskFrame.comp_of
      (by
        rintro w v x y _ _ ⟨h1, h2⟩
        exact ⟨(w.1 + x, w.2), ⟨rfl, rfl⟩, h1.trans (add_assoc _ _ _).symm, h2⟩)
      (by
        rintro w u v x y _ _ ⟨h1, h2⟩ ⟨h3, h4⟩
        exact ⟨by rw [h3, h1, add_assoc], by rw [h4, h2]⟩))
    (by
      intro w x _
      exact ⟨⟨(w.1 + x, w.2), rfl, rfl⟩, ⟨(w.1 - x, w.2), by simp, rfl⟩⟩)
    (TaskFrame.limit_of_shift (D := ↑D) Prod.fst (fun _ _ _ h => h.1)
      (by rintro w u ⟨h1, h2⟩; rw [add_zero] at h1; exact Prod.ext h1 h2))
    (TaskFrame.saturation_of_fib_subsingleton (by
      rintro w x u ⟨h1, h2⟩ u' ⟨h3, h4⟩
      exact Prod.ext (h1.trans h3.symm) (h2.trans h4.symm)))

/-- The task relation of `paddedClock`, read off `FrameOver.ofReflectiveRegular_taskRel` rather
than by unfolding the frame. -/
@[simp] theorem paddedClock_taskRel {D : TemporalOrder} (w : ↑D × ℝ) (x : ↑D) (u : ↑D × ℝ) :
    (paddedClock D).TaskRel w x u ↔ (u.1 = w.1 + x ∧ u.2 = w.2) :=
  FrameOver.ofReflectiveRegular_taskRel

/-- **The padded clock has uncountably many world states**, whatever `D` is: the ballast embeds
`ℝ` into the carrier. -/
theorem paddedClock_uncountable (D : TemporalOrder) :
    ¬ Countable (paddedClock D).WorldState := by
  intro h
  haveI : Countable (↑D × ℝ) := h
  have hc : Countable ℝ := Function.Injective.countable
    (f := fun r : ℝ => ((0 : ↑D), r)) (fun a b hab => congrArg Prod.snd hab)
  exact Cardinal.not_countable_real (Set.countable_univ_iff.mpr hc)

/-- **The padded clock is not static**, whatever `D` is: any positive duration moves the clock
coordinate. Together with `paddedClock_uncountable` this fills the uncountable row of the
cardinality census at `ℤ`, `ℚ`, `ℚ ×ₗ ℚ` and `ℝ` in one declaration. -/
theorem paddedClock_not_static (D : TemporalOrder) :
    ¬ Static (paddedClock D).TaskRel := by
  intro h
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  have h1 : ((0 : ↑D), (0 : ℝ)) = ((0 : ↑D) + x, (0 : ℝ)) :=
    (h _ x _).mp ((paddedClock_taskRel _ _ _).mpr ⟨rfl, rfl⟩)
  have h2 := congrArg Prod.fst h1
  simp only [zero_add] at h2
  exact absurd h2.symm (ne_of_gt hx)

end FormalSystem.Semantics.Rigidity

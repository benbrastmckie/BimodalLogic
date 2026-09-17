/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DriftFrame
import FormalSystem.Metalogic.Independence.OrderTransfer

/-!
# F°'s world histories are order-isomorphisms of `(ℝ, <)`

`app:drift`'s key lemma, and the reason `F°` is indistinguishable from the deterministic `F¹`
despite not being deterministic: although the drift relation is a *band*, any single world
history through it is a strictly increasing bi-Lipschitz bijection of `ℝ` onto `ℝ`. So each
history, taken on its own, sees exactly the order structure a translation history sees.

The content is proved first on a bare state function `f : ℝ → ℝ` satisfying
`∀ s t, fzeroRel (f s) (t - s) (f t)` — which a world history's `state` function satisfies,
`hf` being exactly `respects_task` — and then lifted to `WorldHistory F0`, in the shape
`Independence/OrderTransfer.lean`'s hypotheses (H1) and (H2) demand.

## Main Results

- `fzero_bounds` — the drift inequality `t - s ≤ f t - f s ≤ 2 (t - s)` for `s ≤ t`
- `fzero_lipschitz`, `fzero_continuous` — `2`-Lipschitz, hence continuous
- `fzero_strictMono` — strictly increasing, from the lower drift bound alone
- `fzero_hits_future`, `fzero_hits_past` — **surjectivity**, the expensive half
- `fzero_orderFlow : OrderFlow F0` — (H1) discharged
- `fzero_stateOccurs : StateOccurs F0` — (H2) discharged, by an **explicit** witness

## The crux, and why it is where the work is

`fzero_hits_future` is `app:drift`'s key lemma and its expensive part. Given `f x < v`, put
`a := x + (v - f x)/2` and `b := x + (v - f x)`. The upper drift bound at `a` gives `f a ≤ v` and
the lower bound at `b` gives `v ≤ f b`, so `v` lies between two attained values; the function is
Lipschitz, hence continuous, so `intermediate_value_Icc` produces the witness. The bracket
`[d, 2d]` is exactly what makes both endpoint estimates come out — a narrower or wider band would
break one of them. This derivation was independently corroborated by a second derivation before
being promoted.

## Choice-freeness of (H2)

`StateOccurs` says every state is occupied at every time. The general theorem to that effect
(`cor:occurrence`) runs through `thm:extension` and hence Zorn. Nothing of the sort is needed
here: the translation `δ(t) := t + w - x` is *itself* a world history of `F°` — its increments
are `t - s`, which lies in the band `[t - s, 2(t - s)]` at its own left endpoint — and it has
state `w` at time `x`. That explicit witness is what keeps `cor:no-characterization` choice-free.

## References

* JPL paper `app:drift`, `cor:occurrence`, `cor:no-characterization`
* `FormalSystem/Metalogic/Independence/OrderTransfer.lean` — the (H1)/(H2) hypotheses discharged
  here
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics
open Set

/-! ## On a bare state function -/

section BareFunction

variable (f : ℝ → ℝ) (hf : ∀ s t : ℝ, fzeroRel (f s) (t - s) (f t))

include hf

/-- **The drift inequality.** Over a nonnegative elapsed time the state advances by at least the
elapsed time and at most twice it. -/
theorem fzero_bounds {s t : ℝ} (hst : s ≤ t) : t - s ≤ f t - f s ∧ f t - f s ≤ 2 * (t - s) := by
  have := (fzeroRel_iff (f s) (t - s) (f t)).mp (hf s t)
  rcases this with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> constructor <;> linarith

/-- The upper drift bound is a Lipschitz estimate with constant `2`. -/
theorem fzero_lipschitz : LipschitzWith 2 f := by
  refine LipschitzWith.of_dist_le_mul fun s t => ?_
  rcases le_total s t with h | h
  · obtain ⟨h1, h2⟩ := fzero_bounds f hf h
    rw [Real.dist_eq, Real.dist_eq, abs_sub_comm (f s), abs_sub_comm s]
    rw [abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
    push_cast; linarith
  · obtain ⟨h1, h2⟩ := fzero_bounds f hf h
    rw [Real.dist_eq, Real.dist_eq]
    rw [abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
    push_cast; linarith

theorem fzero_continuous : Continuous f := (fzero_lipschitz f hf).continuous

/-- **Forward surjectivity** — the crux (module docstring). Every state strictly above `f x` is
`f c` for some `c > x`. -/
theorem fzero_hits_future {x v : ℝ} (hv : f x < v) : ∃ c, x < c ∧ f c = v := by
  set a := x + (v - f x) / 2 with ha
  set b := x + (v - f x) with hb
  have hab : a ≤ b := by simp only [ha, hb]; linarith
  have hfa : f a ≤ v := by
    obtain ⟨_, h2⟩ := fzero_bounds f hf (show x ≤ a by simp only [ha]; linarith)
    simp only [ha] at h2; linarith
  have hfb : v ≤ f b := by
    obtain ⟨h1, _⟩ := fzero_bounds f hf (show x ≤ b by simp only [hb]; linarith)
    simp only [hb] at h1; linarith
  obtain ⟨c, hc, hcv⟩ := intermediate_value_Icc hab (fzero_continuous f hf).continuousOn
    (Set.mem_Icc.mpr ⟨hfa, hfb⟩)
  exact ⟨c, by have := hc.1; simp only [ha] at this; linarith, hcv⟩

/-- **Backward surjectivity.** Every state strictly below `f x` is `f c` for some `c < x`. -/
theorem fzero_hits_past {x v : ℝ} (hv : v < f x) : ∃ c, c < x ∧ f c = v := by
  set a := x - (f x - v) with ha
  set b := x - (f x - v) / 2 with hb
  have hab : a ≤ b := by simp only [ha, hb]; linarith
  have hfa : f a ≤ v := by
    obtain ⟨h1, _⟩ := fzero_bounds f hf (show a ≤ x by simp only [ha]; linarith)
    simp only [ha] at h1; linarith
  have hfb : v ≤ f b := by
    obtain ⟨_, h2⟩ := fzero_bounds f hf (show b ≤ x by simp only [hb]; linarith)
    simp only [hb] at h2; linarith
  obtain ⟨c, hc, hcv⟩ := intermediate_value_Icc hab (fzero_continuous f hf).continuousOn
    (Set.mem_Icc.mpr ⟨hfa, hfb⟩)
  exact ⟨c, by have := hc.2; simp only [hb] at this; linarith, hcv⟩

/-- **Strict monotonicity**, the other half of the order-isomorphism claim; the lower drift bound
alone gives it. -/
theorem fzero_strictMono : StrictMono f := by
  intro s t hst
  obtain ⟨h1, _⟩ := fzero_bounds f hf hst.le
  linarith

end BareFunction

/-! ## Lifted to `F°`'s world histories -/

/-- A world history of `F°` satisfies the bare hypothesis `hf`: `respects_task`, read at the pair
`(s, t)`, *is* the drift condition on the state function (through `f0_taskRel_iff`). -/
theorem fzero_hist_rel (τ : WorldHistory F0) :
    ∀ s t : ℝ, fzeroRel (τ.state s) (t - s) (τ.state t) :=
  fun s t => (f0_taskRel_iff _ _ _).mp (τ.val.respects_task s t (τ.property s) (τ.property t))

/-- **(H1) for `F°`**: every world history is an order-isomorphism of `(ℝ, <)` onto `(ℝ, <)`. -/
theorem fzero_orderFlow : OrderFlow F0 where
  strictMono := by
    intro τ s t hst
    exact fzero_strictMono (fun r => τ.state r) (fzero_hist_rel τ) hst
  hits_future := by
    intro τ x v hv
    exact fzero_hits_future (fun r => τ.state r) (fzero_hist_rel τ) hv
  hits_past := by
    intro τ x v hv
    exact fzero_hits_past (fun r => τ.state r) (fzero_hist_rel τ) hv

/-- The translation `t ↦ t + c` is a world history of `F°`: its increment over `[s, t]` is
`t - s`, the left endpoint of the band `[t - s, 2 (t - s)]` (and its right endpoint when the
duration is negative). -/
noncomputable def driftTranslation (c : ℝ) : WorldHistory F0 :=
  WorldHistory.ofTotal F0 (fun t => t + c) <| by
    intro s t
    refine (f0_taskRel_iff _ _ _).mpr ?_
    show fzeroRel (s + c) (t - s) (t + c)
    rw [fzeroRel_iff]
    rcases le_total 0 (t - s) with h | h
    · left; constructor <;> linarith
    · right; constructor <;> linarith

/--
**(H2) for `F°`**, with an explicit witness: given a state `w` and a time `x`, the translation
`δ(t) = t + (w - x)` is a world history of `F°` with `δ(x) = w`.

No appeal to `thm:extension` or `cor:occurrence`, and hence no Zorn — see the module docstring.
-/
theorem fzero_stateOccurs : StateOccurs F0 := by
  intro w x
  refine ⟨driftTranslation (w - x), ?_⟩
  show x + (w - x) = w
  ring

end FormalSystem.Metalogic.Independence

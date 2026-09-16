/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.RealTranslationFrame
import Mathlib.Topology.Order.Compact
import Mathlib.Topology.Compactness.Compact
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-!
# F° — the drift frame over `ℝ`

The second half of the **indistinguishable pair** behind `cor:no-characterization`, and the
frame of `app:drift`. Like `F¹` (`Independence/RealTranslationFrame.lean`) it has `W = D = ℝ`,
but its task relation is a *band* rather than a translation:

`w ⇒_x u  :⟺  u - w` lies in the (unordered) interval between `x` and `2x`.

For `x ≥ 0` this is the paper's `x ≤ u - w ≤ 2x`: a process that drifts forward at a rate
somewhere between `1` and `2`. Being a band rather than a graph, the relation is **not**
functional, so `F°` is **not** deterministic (`fzero_not_deterministic`) — and yet, by
`Independence/DeterminismUndefinable.lean`, it validates *Determined*.

## Main Definitions

- `fzeroRel` — the drift relation
- `fzeroFrame : FrameOver realTemporalOrder` — `F°` as a fibre, all five axiom fields discharged
- `F0 : TaskFrame` — its inclusion into the total space

## Main Results

- `fib_eq_Icc` / `fib_eq_Icc'`, `isCompact_fib`, `isClosed_fib` — the fibres are closed bounded
  intervals, which is what makes *Saturation* a compactness argument
- `fzero_reflection`, `fzero_serial`, `fzero_comp`, `fzero_limit`, `fzero_saturation` — the
  five `FrameOver` obligations (the zero-duration law is the derived `FrameOver.nullity_identity`)
- `fzero_not_deterministic` — `0 ⇒_1 1` and `0 ⇒_1 2`, so `F°` fails `def:deterministic`

## The `uIcc` encoding

`app:drift` states the relation only for `x ≥ 0`. `FrameOver.reflection` is a structure field, so
the relation must be defined at negative durations too, and it must satisfy
`w ⇒_x u ↔ u ⇒_{-x} w` **on the nose**. The unordered interval `Set.uIcc x (2 * x)` is exactly
the two-sided extension that makes this hold definitionally: for `x < 0` it is `[2x, x]`, which
is the reflected band, so `converse` is a `linarith` case split and nothing more.

## The `comp` scope note — why F° is a frame at all

The tree's *Compositionality* predicate (`TaskFrame.Compositional`, `Semantics/TaskFrame.lean`)
is confined to `0 ≤ x` and `0 ≤ y`. `F°` genuinely **fails** mixed-sign composition — a forward
drift followed by a backward drift need not land where a single drift of the summed duration
could — so had the axiom been stated two-sidedly, `F°` would not be a task frame and this entire
independence result would be unavailable. The narrow scope is not a convenience here; it is
load-bearing, and worth knowing before anyone "strengthens" that predicate.

## Two deliberate deviations from `app:drift`'s proof

1. **Interpolation without division.** `app:drift` interpolates with `λ := (v - w)/(x + y)`,
   which needs `x + y ≠ 0` and hence a separate degenerate case. The proof here splits on
   `le_total (w + x) (v - 2 * y)` and takes whichever endpoint of the overlap is available: no
   division, no degenerate case, and `linarith` closes every branch.
2. **Saturation via Mathlib's Cantor lemma.** `app:drift` argues by the finite intersection
   property directly; here the fibres and segments are compact and closed
   (`isCompact_fib`, `isClosed_fib`) and
   `IsCompact.nonempty_sInter_of_directed_nonempty_isCompact_isClosed` finishes it. Note that
   `TaskFrame.limit_of_shift` does **not** apply: that helper wants a functional relation, and
   this one is not functional. A topology-free `csSup` route exists as a fallback if the topology
   imports ever become unwelcome.

## Why F° survives density where `natFrame` does not

`natFrame` — the frame carrying the `⊡` non-validities in `Semantics/PlusLanguage/PlusNonValidities.lean` —
relates every state to every state at every nonzero duration, so its cone at a state is the whole
carrier and its *Limit* field needs a discrete carrier to hold at all. `F°`'s fibres are the
bounded intervals `[w + d, w + 2d]`, whose width `d` shrinks linearly to `0`, so the cone shrinks
in any order whatever and *Limit* holds over `ℝ`. The two frames are not interchangeable, and no
result about one transfers to the other.

## A `ℤ` carrier does not work

Taking `W = D = ℤ` with the same band relation gives a legal frame but a **useless** one for the
purpose here: over `ℤ` a history's state function is not surjective onto the states, so the
`untl` case of `Independence/StateSetTruth.lean`'s recursion — which needs every state strictly
above the present one to be *reached* — fails. The choice of `ℝ` is essential, and the `[d, 2d]`
bracket is precisely what forces surjectivity, via the intermediate value theorem on a Lipschitz
state function (`Independence/DriftHistories.lean`). Recorded so that nobody "simplifies" the
carrier.

## References

* JPL paper `app:drift`, `def:deterministic`, `cor:no-characterization`
* `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean` — `realTemporalOrder`, and `F°`'s
  indistinguishable partner
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics
open Set

/-- The drift relation: `u - w` lies in the unordered interval between `d` and `2d`. For `d ≥ 0`
this is `app:drift`'s `d ≤ u - w ≤ 2d`; for `d < 0` it is the reflection, which is what
`FrameOver.reflection` demands. -/
def fzeroRel (w : ℝ) (d : ℝ) (u : ℝ) : Prop := u - w ∈ Set.uIcc d (2 * d)

/-- The sign-split form of `fzeroRel`, and the form every proof below consumes. -/
theorem fzeroRel_iff (w d u : ℝ) :
    fzeroRel w d u ↔ (d ≤ u - w ∧ u - w ≤ 2 * d) ∨ (2 * d ≤ u - w ∧ u - w ≤ d) := by
  simp [fzeroRel, Set.mem_uIcc]

/-! ### Fibres are closed bounded intervals -/

theorem mem_fib_iff (w d u : ℝ) :
    u ∈ TaskFrame.Fib (D := realTemporalOrder) fzeroRel w d ↔ fzeroRel w d u := Iff.rfl

/-- At a nonnegative duration the fibre is `[w + d, w + 2d]`. -/
theorem fib_eq_Icc (w d : ℝ) (h : 0 ≤ d) :
    TaskFrame.Fib (D := realTemporalOrder) fzeroRel w d = Set.Icc (w + d) (w + 2 * d) := by
  ext u
  rw [mem_fib_iff, fzeroRel_iff, Set.mem_Icc]
  constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩) <;> exact ⟨by linarith, by linarith⟩
  · rintro ⟨h1, h2⟩; left; exact ⟨by linarith, by linarith⟩

/-- At a nonpositive duration the fibre is the reflected interval `[w + 2d, w + d]`. -/
theorem fib_eq_Icc' (w d : ℝ) (h : d ≤ 0) :
    TaskFrame.Fib (D := realTemporalOrder) fzeroRel w d = Set.Icc (w + 2 * d) (w + d) := by
  ext u
  rw [mem_fib_iff, fzeroRel_iff, Set.mem_Icc]
  constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩) <;> exact ⟨by linarith, by linarith⟩
  · rintro ⟨h1, h2⟩; right; exact ⟨by linarith, by linarith⟩

theorem isCompact_fib (w d : ℝ) : IsCompact (TaskFrame.Fib (D := realTemporalOrder) fzeroRel w d) := by
  rcases le_total 0 d with h | h
  · rw [fib_eq_Icc w d h]; exact isCompact_Icc
  · rw [fib_eq_Icc' w d h]; exact isCompact_Icc

theorem isClosed_fib (w d : ℝ) : IsClosed (TaskFrame.Fib (D := realTemporalOrder) fzeroRel w d) := by
  rcases le_total 0 d with h | h
  · rw [fib_eq_Icc w d h]; exact isClosed_Icc
  · rw [fib_eq_Icc' w d h]; exact isClosed_Icc

/-! ### The five `FrameOver` obligations -/

/-- *Converse*: the `uIcc` encoding makes this hold on the nose. -/
theorem fzero_reflection (w d u : ℝ) : fzeroRel w d u ↔ fzeroRel u (-d) w := by
  rw [fzeroRel_iff, fzeroRel_iff]; constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · right; constructor <;> linarith
    · left; constructor <;> linarith
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · right; constructor <;> linarith
    · left; constructor <;> linarith

/-- *Seriality*: `w + x` and `w - x` are the two witnesses. -/
theorem fzero_serial : TaskFrame.Serial (D := realTemporalOrder) fzeroRel := by
  intro w x _
  refine ⟨⟨w + x, ?_⟩, ⟨w - x, ?_⟩⟩ <;> rw [fzeroRel_iff]
  · rcases le_total 0 x with h | h
    · left; constructor <;> linarith
    · right; constructor <;> linarith
  · rcases le_total 0 x with h | h
    · left; constructor <;> linarith
    · right; constructor <;> linarith

/-- *Compositionality*, on the axiom's own `0 ≤ x, 0 ≤ y` scope. Interpolation splits on
`le_total (w + x) (v - 2 * y)` — see the module docstring's deviation 1. -/
theorem fzero_comp : TaskFrame.Compositional (D := realTemporalOrder) fzeroRel := by
  intro w v x y hx hy
  constructor
  · intro h
    rw [fzeroRel_iff] at h
    rcases le_total (w + x) (v - 2 * y) with hm | hm
    · refine ⟨v - 2 * y, ?_, ?_⟩ <;> rw [fzeroRel_iff] <;> left <;>
        rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> exact ⟨by linarith, by linarith⟩
    · refine ⟨w + x, ?_, ?_⟩ <;> rw [fzeroRel_iff] <;> left <;>
        rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> exact ⟨by linarith, by linarith⟩
  · rintro ⟨u, h1, h2⟩
    rw [fzeroRel_iff] at h1 h2 ⊢
    left
    rcases h1 with ⟨a1, a2⟩ | ⟨a1, a2⟩ <;> rcases h2 with ⟨b1, b2⟩ | ⟨b1, b2⟩ <;>
      exact ⟨by linarith, by linarith⟩

/-- *Limit*: the band of width `d` shrinks to `{w}` as `d → 0`, so a state in every arbitrarily
small cone is `w`. This is where `F°` beats `natFrame` over a dense carrier. -/
theorem fzero_limit (w u : ℝ)
    (h : ∀ x : ℝ, 0 < x → ∃ y : ℝ, |y| < x ∧ fzeroRel w y u) : u = w := by
  by_contra hne
  have hpos : 0 < |u - w| := by
    simpa [sub_eq_zero] using abs_pos.mpr (sub_ne_zero.mpr hne)
  obtain ⟨y, hy, hr⟩ := h (|u - w| / 2) (by linarith)
  rw [fzeroRel_iff] at hr
  have hya : |y| < |u - w| / 2 := hy
  rcases abs_lt.mp hya with ⟨hy1, hy2⟩
  rcases hr with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rcases abs_cases (u - w) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] at hy1 hy2 <;> linarith
  · rcases abs_cases (u - w) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] at hy1 hy2 <;> linarith

/-- *Saturation*, by compactness — see the module docstring's deviation 2. -/
theorem fzero_saturation : TaskFrame.Saturation (D := realTemporalOrder) fzeroRel := by
  intro S hdir hmem
  have hne : Nonempty S := ⟨⟨hdir.1.choose, hdir.1.choose_spec⟩⟩
  refine IsCompact.nonempty_sInter_of_directed_nonempty_isCompact_isClosed
    (fun S₁ h₁ S₂ h₂ => ?_) (fun U hU => (hmem U hU).2) (fun U hU => ?_) (fun U hU => ?_)
  · obtain ⟨S', hS', hsub⟩ := hdir.2 S₁ h₁ S₂ h₂
    exact ⟨S', hS', hsub.trans inter_subset_left, hsub.trans inter_subset_right⟩
  · rcases (hmem U hU).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
    · exact isCompact_fib w x
    · exact (isCompact_fib w x).inter_right (isClosed_fib v (-y))
  · rcases (hmem U hU).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
    · exact isClosed_fib w x
    · exact (isClosed_fib w x).inter (isClosed_fib v (-y))

/-- **F° is a task frame.** All five axiom fields above; `@[reducible]` is load-bearing for exactly the
reason recorded at `realTemporalOrder` — without it `F0.WorldState` does not reduce to `ℝ` and neither
the order instances nor the state-set recursion can be stated. -/
@[reducible] noncomputable def fzeroFrame : FrameOver realTemporalOrder where
  WorldState := ℝ
  PosRel w x u := fzeroRel w x u
  comp := TaskFrame.compositional_reflect_of_reflective fzero_reflection fzero_comp
  serial := TaskFrame.serial_reflect_of_reflective fzero_reflection fzero_serial
  limit := TaskFrame.limit_reflect_of_reflective fzero_reflection fzero_limit
  saturation := TaskFrame.saturation_reflect_of_reflective fzero_reflection fzero_saturation

/-- `F°` as a `TaskFrame`, the shape validity and truth are stated over. -/
@[reducible] noncomputable def F0 : TaskFrame := fzeroFrame.toTaskFrame

/-- `F°`'s task relation, definitionally. -/
theorem f0_taskRel_iff (w x u : ↑realTemporalOrder) : F0.TaskRel w x u ↔ fzeroRel w x u :=
  TaskFrame.reflect_restrict_iff (R := fzeroRel) fzero_reflection

/-! ### F° is not deterministic -/

/-- **`F°` fails `def:deterministic`**: `0 ⇒_1 1` and `0 ⇒_1 2`, since both `1` and `2` lie in
`[1, 2]`. Stated against `TaskFrame.Deterministic` (`Semantics/FrameProperty.lean`), the same
predicate `determined_of_deterministic` consumes. -/
theorem fzero_not_deterministic : ¬ F0.Deterministic := by
  rw [TaskFrame.deterministic_iff]
  intro h
  have h1 : fzeroRel 0 1 1 := by rw [fzeroRel_iff]; left; norm_num
  have h2 : fzeroRel 0 1 2 := by rw [fzeroRel_iff]; left; norm_num
  have := h 0 1 2 1 ((f0_taskRel_iff _ _ _).mpr h1) ((f0_taskRel_iff _ _ _).mpr h2)
  norm_num at this

end FormalSystem.Metalogic.Independence

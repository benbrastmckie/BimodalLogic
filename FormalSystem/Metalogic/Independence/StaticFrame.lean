/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.LoopingDuration

/-!
# The static frame at an arbitrary duration group, and its constant-truth calculus

`FrameOver.staticFrame W` relates a world state only to itself, at *every* duration. Every
nonzero duration is therefore a `LoopingDuration`, and `LoopingDuration.truthAt_add_period` —
which carries no positivity hypothesis on the period — instantiates at `π := s - t` to give full
**time-invariance**: on a static frame, every formula has a single truth value for all of time
(`static_time_invariant`).

That one fact turns the `untl` and `snce` clauses into a small *calculus*. Writing `b(φ)` for the
constant truth value of `φ`:

| carrier | `b(U(ψ, φ))` |
|---|---|
| arbitrary `D` | `b(φ) ∧ (b(ψ) ∨ `t` has an immediate successor)` |
| densely ordered | `b(φ) ∧ b(ψ)` |
| every point has an immediate successor | `b(φ)` |

together with `b(Gφ) = b(Fφ) = b(Hφ) = b(Pφ) = b(φ)` at arbitrary `D`, and
`b(K⁺φ) = b(K⁻φ) = b(φ)` on a dense carrier. The `snce` mirrors are the same skeleton with the
order reversed.

With these in hand, checking that a static frame validates an axiom is *rewriting* rather than a
per-axiom semantic argument. `Metalogic/Independence/RationalWitness.lean` and
`Metalogic/Independence/LexIntWitness.lean` use nothing else for the `Dense`/`Dedekind`-side and
`Discrete`-side axiom lists respectively.

## Scoping finding: the periodicity apparatus is not needed here

`specs/511_research_frame_correspondence_infrastructure/reports/03_probes.lean` carries a
~400-line `Walk`/`MinCyc`/`periodic` apparatus culminating in `truthAt_add_hist_period`, which
exists to handle frames whose *histories have different periods*. The static frame needs none of
it: its period is uniform across every history, so `truthAt_add_period` applies directly. The
right pattern to follow here is `02_probes.lean`'s Probe F (`density_of_loopingDuration`, three
lines over `truthAt_add_period`), not `03_probes.lean`'s `density_of_hist_periodic`. That heavier
apparatus is needed only for the schema half of the `FwdRec` correspondence at `ℤ`.

## Main results

* `staticFrame_looping` — every nonzero duration loops on a static frame
* `static_time_invariant` — truth does not vary with time
* `static_allFuture_iff`, `static_someFuture_iff`, `static_allPast_iff`, `static_somePast_iff` —
  the four tense operators are transparent, at arbitrary `D`
* `static_untl_iff`, `static_untl_iff_dense`, `static_untl_iff_disc` — the `untl` calculus
* `static_snce_iff`, `static_snce_iff_dense`, `static_snce_iff_disc` — the `snce` mirrors
* `static_kPlus_iff_dense`, `static_kMinus_iff_dense` — Reynolds' `K⁺`/`K⁻` on a dense carrier
* `static_validates_z1` — `Axiom.z1` holds on every static frame, from time-invariance alone
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-! ## Looping and time-invariance -/

/--
**Every nonzero duration is a looping duration of the static frame.**

`LoopingDuration F π` asks for `π ≠ 0` together with `F.TaskRel w π u ↔ u = w`; the static
relation is `w = u` at every duration, so the second conjunct is `Eq.symm` in both directions and
`π` is otherwise unconstrained.
-/
theorem staticFrame_looping (W : Type) [Nonempty W] {π : D} (hπ : π ≠ 0) :
    LoopingDuration (FrameOver.staticFrame W (D := D)) π :=
  ⟨hπ, fun _ _ => ⟨Eq.symm, Eq.symm⟩⟩

/--
**Truth on a static frame does not depend on the time.**

`LoopingDuration.truthAt_add_period` carries no positivity hypothesis on the period, so
instantiating `staticFrame_looping` at `π := s - t` reaches `s` from `t` in a single step, in
either direction and regardless of the order of `t` and `s`. The degenerate case `s = t` is
`Iff.rfl`.

This is the whole of the static frame's semantic content; everything below is a corollary of it.
-/
theorem static_time_invariant (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D))) (φ : Formula)
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal) (t s : D) :
    TruthAt M τ t φ ↔ TruthAt M τ s φ := by
  rcases eq_or_ne (s - t) 0 with h | h
  · rw [sub_eq_zero] at h
    subst h
    exact Iff.rfl
  · have hper := truthAt_add_period M (staticFrame_looping W h) φ τ hτ t
    have ht : t + (s - t) = s := by abel
    rwa [ht] at hper

/-! ## The four tense operators are transparent

At an arbitrary duration group. Each is one application of `static_time_invariant` in each
direction, over the corresponding `Truth.*_iff` unfolding lemma; the only extra ingredient is
`TaskFrame.exists_pos_of_nontrivial`, which supplies a time strictly after (or before) the
current one so that the universal readings are not vacuous. -/

/-- `b(Gφ) = b(φ)`. -/
theorem static_allFuture_iff (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (χ : Formula) (t : D) :
    TruthAt M τ t χ.allFuture ↔ TruthAt M τ t χ := by
  rw [Truth.future_iff]
  refine ⟨fun h => ?_, fun h s _ => (static_time_invariant W M χ τ hτ t s).mp h⟩
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  exact (static_time_invariant W M χ τ hτ (t + p) t).mp (h _ (lt_add_of_pos_right t hp))

/-- `b(Fφ) = b(φ)`. -/
theorem static_someFuture_iff (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (χ : Formula) (t : D) :
    TruthAt M τ t χ.someFuture ↔ TruthAt M τ t χ := by
  rw [Truth.some_future_iff]
  refine ⟨fun ⟨s, _, hs⟩ => (static_time_invariant W M χ τ hτ s t).mp hs, fun h => ?_⟩
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  exact ⟨t + p, lt_add_of_pos_right t hp, (static_time_invariant W M χ τ hτ t (t + p)).mp h⟩

/-- `b(Hφ) = b(φ)`. -/
theorem static_allPast_iff (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (χ : Formula) (t : D) :
    TruthAt M τ t χ.allPast ↔ TruthAt M τ t χ := by
  rw [Truth.past_iff]
  refine ⟨fun h => ?_, fun h s _ => (static_time_invariant W M χ τ hτ t s).mp h⟩
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  exact (static_time_invariant W M χ τ hτ (t - p) t).mp (h _ (sub_lt_self t hp))

/-- `b(Pφ) = b(φ)`. -/
theorem static_somePast_iff (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (χ : Formula) (t : D) :
    TruthAt M τ t χ.somePast ↔ TruthAt M τ t χ := by
  rw [Truth.some_past_iff]
  refine ⟨fun ⟨s, _, hs⟩ => (static_time_invariant W M χ τ hτ s t).mp hs, fun h => ?_⟩
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  exact ⟨t - p, sub_lt_self t hp, (static_time_invariant W M χ τ hτ t (t - p)).mp h⟩

/-! ## The `untl` calculus -/

/--
**The `untl` clause on a static frame, at an arbitrary duration group.**

`U(ψ, φ)` holds at `t` exactly when `φ` holds (anywhere, hence everywhere) and *either* `ψ` holds
too — in which case any point above `t` serves as witness and the guard is satisfied throughout —
*or* `t` has an immediate successor, which makes the guard interval empty and so lets `ψ` fail.

The second disjunct is exactly what separates the dense and discrete specializations below: it is
unavailable on a densely ordered carrier and always available on a discrete one.
-/
theorem static_untl_iff (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.untl ψ φ) ↔
      (TruthAt M τ t φ ∧ (TruthAt M τ t ψ ∨ ∃ y, IsLeast {z : D | t < z} y)) := by
  constructor
  · rintro ⟨s, hts, hev, hg⟩
    refine ⟨(static_time_invariant W M φ τ hτ s t).mp hev, ?_⟩
    by_cases hmid : ∃ r : D, t < r ∧ r < s
    · obtain ⟨r, hr1, hr2⟩ := hmid
      exact Or.inl ((static_time_invariant W M ψ τ hτ r t).mp (hg r hr1 hr2))
    · refine Or.inr ⟨s, hts, fun z hz => ?_⟩
      by_contra hlt
      exact hmid ⟨z, hz, not_le.mp hlt⟩
  · rintro ⟨hφ, hor⟩
    rcases hor with hψ | ⟨y, hy1, hy2⟩
    · obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
      exact ⟨t + p, lt_add_of_pos_right t hp,
        (static_time_invariant W M φ τ hτ t (t + p)).mp hφ,
        fun r _ _ => (static_time_invariant W M ψ τ hτ t r).mp hψ⟩
    · refine ⟨y, hy1, (static_time_invariant W M φ τ hτ t y).mp hφ, fun r hr1 hr2 => ?_⟩
      exact absurd (hy2 hr1) (not_le.mpr hr2)

/-- A densely ordered carrier has no immediate successors, so the right disjunct of
`static_untl_iff` is unavailable and `U(ψ, φ)` reduces to the conjunction `b(φ) ∧ b(ψ)`. -/
theorem static_untl_iff_dense [DenselyOrdered D] (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.untl ψ φ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ) := by
  rw [static_untl_iff W M τ hτ ψ φ t]
  refine and_congr_right fun _ => ⟨fun h => ?_, Or.inl⟩
  rcases h with hψ | ⟨y, hy1, hy2⟩
  · exact hψ
  · obtain ⟨c, hc1, hc2⟩ := exists_between hy1
    exact absurd (hy2 hc1) (not_le.mpr hc2)

/-- On a carrier where every point has an immediate successor the right disjunct of
`static_untl_iff` is always available, so `U(ψ, φ)` reduces to the event `b(φ)` alone — the guard
is never consulted. -/
theorem static_untl_iff_disc (hdisc : ∀ x : D, ∃ y, IsLeast {z : D | x < z} y)
    (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.untl ψ φ) ↔ TruthAt M τ t φ := by
  rw [static_untl_iff W M τ hτ ψ φ t]
  exact ⟨And.left, fun h => ⟨h, Or.inr (hdisc t)⟩⟩

/-! ## The `snce` mirrors

The same skeleton with the order reversed: `IsLeast {z | t < z}` becomes
`IsGreatest {z | z < t}`, `lt_add_of_pos_right` becomes `sub_lt_self`, and the three statements
otherwise transcribe unchanged. -/

/-- The `snce` mirror of `static_untl_iff`. -/
theorem static_snce_iff (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.snce ψ φ) ↔
      (TruthAt M τ t φ ∧ (TruthAt M τ t ψ ∨ ∃ y, IsGreatest {z : D | z < t} y)) := by
  constructor
  · rintro ⟨s, hst, hev, hg⟩
    refine ⟨(static_time_invariant W M φ τ hτ s t).mp hev, ?_⟩
    by_cases hmid : ∃ r : D, s < r ∧ r < t
    · obtain ⟨r, hr1, hr2⟩ := hmid
      exact Or.inl ((static_time_invariant W M ψ τ hτ r t).mp (hg r hr1 hr2))
    · refine Or.inr ⟨s, hst, fun z hz => ?_⟩
      by_contra hlt
      exact hmid ⟨z, not_le.mp hlt, hz⟩
  · rintro ⟨hφ, hor⟩
    rcases hor with hψ | ⟨y, hy1, hy2⟩
    · obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
      exact ⟨t - p, sub_lt_self t hp,
        (static_time_invariant W M φ τ hτ t (t - p)).mp hφ,
        fun r _ _ => (static_time_invariant W M ψ τ hτ t r).mp hψ⟩
    · refine ⟨y, hy1, (static_time_invariant W M φ τ hτ t y).mp hφ, fun r hr1 hr2 => ?_⟩
      exact absurd (hy2 hr2) (not_le.mpr hr1)

/-- The `snce` mirror of `static_untl_iff_dense`. -/
theorem static_snce_iff_dense [DenselyOrdered D] (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.snce ψ φ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ) := by
  rw [static_snce_iff W M τ hτ ψ φ t]
  refine and_congr_right fun _ => ⟨fun h => ?_, Or.inl⟩
  rcases h with hψ | ⟨y, hy1, hy2⟩
  · exact hψ
  · obtain ⟨c, hc1, hc2⟩ := exists_between hy1
    exact absurd (hy2 hc2) (not_le.mpr hc1)

/-- The `snce` mirror of `static_untl_iff_disc`. -/
theorem static_snce_iff_disc (hdisc : ∀ x : D, ∃ y, IsGreatest {z : D | z < x} y)
    (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (ψ φ : Formula) (t : D) :
    TruthAt M τ t (Formula.snce ψ φ) ↔ TruthAt M τ t φ := by
  rw [static_snce_iff W M τ hτ ψ φ t]
  exact ⟨And.left, fun h => ⟨h, Or.inr (hdisc t)⟩⟩

/-! ## Reynolds' `K⁺` and `K⁻` on a dense carrier -/

/-- `b(K⁺φ) = b(φ)` on a dense carrier. `K⁺φ = ¬U(¬φ, ⊤)`, and the dense `untl` calculus
evaluates the inner `untl` to `⊤ ∧ ¬φ`, so `K⁺φ` is `¬¬φ`. -/
theorem static_kPlus_iff_dense [DenselyOrdered D] (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (χ : Formula) (t : D) :
    TruthAt M τ t (Formula.kPlus χ) ↔ TruthAt M τ t χ := by
  have hu := static_untl_iff_dense W M τ hτ χ.neg Formula.top t
  have htop : TruthAt M τ t Formula.top := fun h => h
  constructor
  · intro h
    by_contra hn
    exact h (hu.mpr ⟨htop, hn⟩)
  · intro h hc
    exact (hu.mp hc).2 h

/-- `b(K⁻φ) = b(φ)` on a dense carrier; the `snce` mirror of `static_kPlus_iff_dense`. -/
theorem static_kMinus_iff_dense [DenselyOrdered D] (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (χ : Formula) (t : D) :
    TruthAt M τ t (Formula.kMinus χ) ↔ TruthAt M τ t χ := by
  have hs := static_snce_iff_dense W M τ hτ χ.neg Formula.top t
  have htop : TruthAt M τ t Formula.top := fun h => h
  constructor
  · intro h
    by_contra hn
    exact h (hs.mpr ⟨htop, hn⟩)
  · intro h hc
    exact (hs.mp hc).2 h

/-! ## `Axiom.z1` -/

/--
**Every static frame validates `Axiom.z1`**, `G(Gφ → φ) → (F(Gφ) → Gφ)`.

This needs only `static_time_invariant`, not the `untl` calculus: `F(Gφ)` hands over a time `s`
at which `Gφ` holds, and time-invariance moves that to `t`. The induction-step antecedent
`G(Gφ → φ)` is not consumed at all.

Stated at the level of `TruthAt` at an arbitrary total history and time, which is the shape
`TaskFrame.ValidOn` consumes.
-/
theorem static_validates_z1 (W : Type) [Nonempty W]
    (M : TaskModel (FrameOver.staticFrame W (D := D)))
    (τ : WorldHistory (FrameOver.staticFrame W (D := D))) (hτ : τ.IsTotal)
    (φ : Formula) (t : D) :
    TruthAt M τ t ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  intro _hstep hbase
  rw [Truth.some_future_iff] at hbase
  obtain ⟨s, _, hev⟩ := hbase
  exact (static_time_invariant W M φ.allFuture τ hτ s t).mp hev

end FormalSystem.Metalogic.Independence

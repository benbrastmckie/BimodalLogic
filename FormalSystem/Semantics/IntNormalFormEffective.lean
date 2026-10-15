/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.IntNormalForm

/-!
# The ℤ Membership Chain, Choice-Free

`IntNormalForm.lean` proves that `H_F` over ℤ is exactly the set of bi-infinite step-paths. That
chain is correct and is left exactly as it is. It is also **choice-carrying**, and for a single
measured reason: `FrameOver.reflection` routes through `FrameOver.reflection_of_limit`, whose
proof opens with `rcases eq_or_ne d 0`, and `eq_or_ne` is the classical disjunction. Everything
else on the route — `iter_of_isStepPath`, `taskRel_natCast_iff_iter`, `WorldHistory.isStepPath` —
is already free of it.

This module is that one substitution, carried the length of the chain. At `D = intOrder` the
duration type is `ℤ`, which has `DecidableEq`, so `Decidable.eq_or_ne` discharges the same case
split constructively and the whole chain measures `[propext]` or `[propext, Quot.sound]`.

## Why the substitution is unavailable upstream

`FrameOver.reflection` is stated at an arbitrary `D : TemporalOrder` — a nontrivial totally
ordered abelian group with no decidability assumption anywhere in its bundle. There is no
`DecidableEq ↑D` to appeal to, so `Decidable.eq_or_ne` simply does not typecheck there, and the
general law cannot be scrubbed without adding a hypothesis to every one of its callers. The
specialization is the whole content of this module: `intOrder` is where the substitution becomes
available, and nowhere above it.

## What is not attempted

No existing declaration is re-routed. `reflection`, `taskRel_eq_iter`, `respects_of_isStepPath`,
`worldHistoryOfStepPath` and `mem_HF_iff_adjacent` keep their current axiom profiles, which
pinned guard tests elsewhere in the tree may already depend on; the five declarations below sit
beside them, each naming its counterpart.

## Main Definitions

- `FrameOver.worldHistoryOfStepPathInt` — the possible world determined by a bi-infinite
  step-path, choice-free

## Main Results

- `FrameOver.reflection_int` — the reflection law at `intOrder`, choice-free
- `FrameOver.taskRel_eq_iter_int` — the decomposition theorem, choice-free
- `FrameOver.respects_of_isStepPath_int` — all-pairs task-respect from adjacency, choice-free
- `FrameOver.mem_HF_iff_adjacent_int` — `H_F` over ℤ is exactly the bi-infinite step-paths,
  choice-free

## Tags

ztime · normal-form · choice-free · effective
-/

namespace FormalSystem.Semantics

namespace FrameOver

open TaskFrame

/--
**The reflection law at `intOrder`, choice-free**: `w ⇒_d u ↔ u ⇒_{-d} w` at every integer
duration.

The general law is `FrameOver.reflection`, which is this statement at an arbitrary temporal
order. The sole difference between the two proofs is the case split: the general one uses
`eq_or_ne`, which is classical, and this one uses `Decidable.eq_or_ne`, which is available
because the duration type at `intOrder` is `ℤ`. Off zero the law is definitional content of
`TaskFrame.reflect` (`reflect_reflection_of_ne`); at zero `eq_of_taskRel_zero_of_limit` (*Limit*)
collapses each side to an identity and the hypothesis is its own reflected instance.

Constraints consumed: Limit

Paper: `def:task-relation`
-/
theorem reflection_int (F : FrameOver intOrder) [F.IsRegular] (w : F.WorldState) (d : ℤ)
    (u : F.WorldState) : F.TaskRel w d u ↔ F.TaskRel u (-d) w := by
  rcases Decidable.eq_or_ne d 0 with rfl | hd
  · rw [neg_zero]
    constructor
    · intro h
      obtain rfl := F.eq_of_taskRel_zero_of_limit F.limit h
      exact h
    · intro h
      obtain rfl := F.eq_of_taskRel_zero_of_limit F.limit h
      exact h
  · exact TaskFrame.reflect_reflection_of_ne hd

/--
**The decomposition theorem, choice-free.** The counterpart of `FrameOver.taskRel_eq_iter`, which
is the general statement; this is the same statement with both of its reflection uses routed
through `reflection_int` rather than through `reflection`.

Nothing else changes: the nonnegative core is `taskRel_natCast_iff_iter`, already choice-free,
and the sign analysis is `omega` arithmetic on `Int.natAbs`.
-/
theorem taskRel_eq_iter_int (F : FrameOver intOrder) [F.IsRegular] (w u : F.WorldState) (d : ℤ) :
    F.TaskRel w d u ↔
      (0 ≤ d → iter F.step d.natAbs w u) ∧ (d ≤ 0 → iter F.step d.natAbs u w) := by
  constructor
  · intro h
    refine ⟨fun hd => ?_, fun hd => ?_⟩
    · have hnat : ((d.natAbs : ℤ)) = d := Int.natAbs_of_nonneg hd
      exact (F.taskRel_natCast_iff_iter d.natAbs w u).mp (by rwa [hnat])
    · have hconv : F.TaskRel u (-d) w := (F.reflection_int w d u).mp h
      have hnat : (((-d).natAbs : ℤ)) = -d := Int.natAbs_of_nonneg (by omega)
      have hiter := (F.taskRel_natCast_iff_iter (-d).natAbs u w).mp (by rwa [hnat])
      rwa [Int.natAbs_neg] at hiter
  · rintro ⟨hpos, hneg⟩
    rcases le_or_gt 0 d with hd | hd
    · have hnat : ((d.natAbs : ℤ)) = d := Int.natAbs_of_nonneg hd
      exact hnat ▸ (F.taskRel_natCast_iff_iter d.natAbs w u).mpr (hpos hd)
    · have hd' : d ≤ 0 := le_of_lt hd
      have hnat : (((-d).natAbs : ℤ)) = -d := Int.natAbs_of_nonneg (by omega)
      have hiter : iter F.step (-d).natAbs u w := by
        rw [Int.natAbs_neg]; exact hneg hd'
      have hrel : F.TaskRel u (-d) w :=
        hnat ▸ (F.taskRel_natCast_iff_iter (-d).natAbs u w).mpr hiter
      exact (F.reflection_int w d u).mpr hrel

/--
**All-pairs task-respect from adjacency, choice-free.** The counterpart of
`FrameOver.respects_of_isStepPath`, built on `taskRel_eq_iter_int`; the induction it consumes,
`iter_of_isStepPath`, is shared with the general version and is already choice-free.
-/
theorem respects_of_isStepPath_int {F : FrameOver intOrder} [F.IsRegular]
    {f : ℤ → F.WorldState} (h : IsStepPath F f) (s t : ℤ) :
    F.TaskRel (f s) (t - s) (f t) := by
  refine (F.taskRel_eq_iter_int (f s) (f t) (t - s)).mpr ⟨fun hd => ?_, fun hd => ?_⟩
  · have hst : t = s + ((t - s).natAbs : ℤ) := by omega
    have hgo := iter_of_isStepPath h (t - s).natAbs s
    rwa [← hst] at hgo
  · have hst : s = t + ((t - s).natAbs : ℤ) := by omega
    have hgo := iter_of_isStepPath h (t - s).natAbs t
    rwa [← hst] at hgo

/--
The possible world determined by a bi-infinite step-path, choice-free. The counterpart of
`FrameOver.worldHistoryOfStepPath`, with `respects_of_isStepPath_int` discharging the all-pairs
obligation.
-/
def worldHistoryOfStepPathInt (F : FrameOver intOrder) [F.IsRegular]
    (f : ℤ → F.WorldState) (h : IsStepPath F f) :
    WorldHistory F :=
  WorldHistory.ofTotal F.toTaskFrame f (respects_of_isStepPath_int h)

@[simp]
theorem worldHistoryOfStepPathInt.path (F : FrameOver intOrder) [F.IsRegular]
    (f : ℤ → F.WorldState) (h : IsStepPath F f) :
    (worldHistoryOfStepPathInt F f h).path = f := rfl

/--
**`H_F` over ℤ is exactly the set of bi-infinite step-paths, choice-free.** The counterpart of
`FrameOver.mem_HF_iff_adjacent`, which is the general-reflection version of the same
biconditional.

The forward direction is `WorldHistory.isStepPath`, shared with the general version and already
choice-free; the converse is `worldHistoryOfStepPathInt`.
-/
theorem mem_HF_iff_adjacent_int (F : FrameOver intOrder) [F.IsRegular] (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ IsStepPath F f := by
  constructor
  · rintro ⟨τ, rfl⟩; exact τ.isStepPath
  · intro h; exact ⟨worldHistoryOfStepPathInt F f h, rfl⟩

end FrameOver

end FormalSystem.Semantics

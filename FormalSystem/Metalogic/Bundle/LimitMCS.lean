/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.FMCSDef
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# LimitMCS: the limit set of a rational MCS family at a real point

This module defines the *limit set* of a family of maximal consistent sets indexed by `Rat`,
taken at an arbitrary real point, and proves that it is consistent.

The construction is the first half of the seam that carries the dense canonical model from
`Rat` to `ℝ`. The back-and-forth (Cantor) chronicle layer that produces the rational family
stays at `Rat` — Cantor's theorem needs a *countable* dense order without endpoints — and only
the carrier-generic layer beneath it moves to `ℝ`. See `Bundle/FMCSDef.lean` for the family
structure and `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` for the rational
chronicle whose families this module consumes.

## Main definitions

- `limitSetBelow m r`: the formulas that are *eventually* in `m q` as the rational `q`
  approaches the real `r` from below.
- `limitSetAbove m r`: the past-side dual, approaching `r` from above.

## Main results

- `limitSetBelow_mono_directed` / `limitSetAbove_mono_directed`: the defining family of
  witness intervals is directed, so any finite list of members shares one witness interval.
- `limitSetBelow_consistent` / `limitSetAbove_consistent`: the limit set is `SetConsistent`
  whenever every `m q` is maximal consistent. Every finite subset is contained in a single
  `m q`, and consistency is a property of finite subsets by definition
  (`Core/MaximalConsistent.lean`, `SetConsistent`).
- `limitSetBelow_of_rat` / `limitSetAbove_of_rat`: what the rational family's own temporal
  coherence transfers into the limit set at a rational point.

## Scope of the limit construction

Reynolds (1992), §1, printed p.169, is explicit that the Prior axioms enforce a *definably*
Dedekind complete model: there may be gaps in the order, but they are not visible to temporal
formulas. Accordingly nothing here claims an order-theoretic completion; the limit set is a
purely syntactic "eventually true approaching `r`" set, and its maximality is a separate
question argued from the no-definable-gaps lemma rather than from any property of `ℝ`.

## What `limitSetBelow_of_rat` does and does not say

At a rational point `q`, the *left limit* `limitSetBelow m (q : ℝ)` is **not** equal to `m q`,
and no strengthening of the rational family's coherence conditions makes it so. Both inclusions
fail:

- `limitSetBelow m (q : ℝ) ⊆ m q` fails: an atom `P` may lie in `m p` for every rational
  `p < q` and yet not lie in `m q`. The family's coherence conditions are `forward_G` and
  `backward_H` (`Bundle/FMCSDef.lean`), both stated with *strict* inequalities, so neither
  constrains membership at `q` from membership strictly below `q`. There is no axiom of the
  shape `H φ → φ` to appeal to: `allPast` is the strict past operator.
- `m q ⊆ limitSetBelow m (q : ℝ)` fails symmetrically: membership at `q` says nothing about
  membership strictly below `q`.

What coherence *does* transfer is the whole-past and whole-future content, and that is what is
proved below: `allPast A ∈ m q` puts `A` into the set approached from below, and
`allFuture A ∈ m q` puts `A` into the set approached from above. Consumers that need genuine
agreement at rational points must select `m q` directly at rational arguments rather than
taking a one-sided limit there.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## The limit sets -/

/--
The **limit set from below** of a rational family `m` at a real point `r`: the formulas that
are eventually in `m q` as the rational `q` increases to `r`.

"Eventually" is witnessed by a real threshold `z < r`: every rational strictly between `z` and
`r` already carries the formula.
-/
def limitSetBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → A ∈ m q}

/--
The **limit set from above** of a rational family `m` at a real point `r`: the past-side dual
of `limitSetBelow`, with the witness threshold `z` now above `r`.
-/
def limitSetAbove (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | ∃ z : ℝ, r < z ∧ ∀ q : Rat, (q : ℝ) < z → r < (q : ℝ) → A ∈ m q}

/-! ## Directedness of the witness intervals -/

/--
The witness intervals of `limitSetBelow` are **directed**: any finite list of members of
`limitSetBelow m r` shares a single threshold `z < r` that works for all of them
simultaneously.

Proved by list induction, taking the maximum of the two thresholds at each cons step. The
empty list is witnessed by `r - 1`.
-/
theorem limitSetBelow_mono_directed (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetBelow m r) :
    ∃ z : ℝ, z < r ∧ ∀ A ∈ L, ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → A ∈ m q := by
  induction L with
  | nil =>
    refine ⟨r - 1, by linarith, ?_⟩
    intro A hA
    exact absurd hA (List.not_mem_nil)
  | cons A L ih =>
    obtain ⟨zA, hzA, hAmem⟩ := hL A (by simp)
    obtain ⟨zL, hzL, hLmem⟩ := ih (fun B hB => hL B (List.mem_cons_of_mem _ hB))
    refine ⟨max zA zL, max_lt hzA hzL, ?_⟩
    intro B hB q hq1 hq2
    rcases List.mem_cons.mp hB with rfl | hB'
    · exact hAmem q (lt_of_le_of_lt (le_max_left _ _) hq1) hq2
    · exact hLmem B hB' q (lt_of_le_of_lt (le_max_right _ _) hq1) hq2

/--
The witness intervals of `limitSetAbove` are directed. Dual of `limitSetBelow_mono_directed`,
with `min` in place of `max` and `r + 1` witnessing the empty list.
-/
theorem limitSetAbove_mono_directed (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetAbove m r) :
    ∃ z : ℝ, r < z ∧ ∀ A ∈ L, ∀ q : Rat, (q : ℝ) < z → r < (q : ℝ) → A ∈ m q := by
  induction L with
  | nil =>
    refine ⟨r + 1, by linarith, ?_⟩
    intro A hA
    exact absurd hA (List.not_mem_nil)
  | cons A L ih =>
    obtain ⟨zA, hzA, hAmem⟩ := hL A (by simp)
    obtain ⟨zL, hzL, hLmem⟩ := ih (fun B hB => hL B (List.mem_cons_of_mem _ hB))
    refine ⟨min zA zL, lt_min hzA hzL, ?_⟩
    intro B hB q hq1 hq2
    rcases List.mem_cons.mp hB with rfl | hB'
    · exact hAmem q (lt_of_lt_of_le hq1 (min_le_left _ _)) hq2
    · exact hLmem B hB' q (lt_of_lt_of_le hq1 (min_le_right _ _)) hq2

/-! ## Consistency of the limit sets -/

/--
Every finite list drawn from `limitSetBelow m r` is contained in a **single** `m q`.

This is the content that makes the limit set consistent: directedness supplies one threshold
`z < r`, and the density of `ℚ` in `ℝ` (`exists_rat_btwn`) supplies a rational strictly between
`z` and `r`.
-/
theorem limitSetBelow_finite_subset_mem (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetBelow m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q := by
  obtain ⟨z, hz, hzL⟩ := limitSetBelow_mono_directed m r L hL
  obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
  exact ⟨q, fun A hA => hzL A hA q hq1 hq2⟩

/-- Dual of `limitSetBelow_finite_subset_mem` for the past side. -/
theorem limitSetAbove_finite_subset_mem (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetAbove m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q := by
  obtain ⟨z, hz, hzL⟩ := limitSetAbove_mono_directed m r L hL
  obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
  exact ⟨q, fun A hA => hzL A hA q hq2 hq1⟩

/--
**The limit set from below is consistent.**

`SetConsistent` (`Core/MaximalConsistent.lean`) is a property of finite subsets, and every
finite subset of `limitSetBelow m r` sits inside a single `m q`, which is consistent by
hypothesis.
-/
theorem limitSetBelow_consistent {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSetBelow m r) := by
  intro L hL
  obtain ⟨q, hq⟩ := limitSetBelow_finite_subset_mem m r L hL
  exact (hm q).1 L hq

/-- **The limit set from above is consistent.** Dual of `limitSetBelow_consistent`. -/
theorem limitSetAbove_consistent {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSetAbove m r) := by
  intro L hL
  obtain ⟨q, hq⟩ := limitSetAbove_finite_subset_mem m r L hL
  exact (hm q).1 L hq

/-! ## Behaviour at rational points

See the module docstring for why equality with `m q` is unavailable here, and what is available
instead.
-/

/--
What the rational family's `backward_H` coherence transfers into the limit set from below at a
rational point: if the whole strict past of `q` is asserted at `q`, the asserted formula is in
the left limit at `q`.

The hypothesis `hH` is exactly the `backward_H` field of `FMCS` (`Bundle/FMCSDef.lean`),
specialised to `D := Rat`, and is taken as an argument so that this lemma is usable before the
real-carrier family is assembled.
-/
theorem limitSetBelow_of_rat (m : Rat → Set Formula)
    (hH : ∀ (s t : Rat) (φ : Formula), t < s → Formula.allPast φ ∈ m s → φ ∈ m t)
    (q : Rat) (A : Formula) (hA : Formula.allPast A ∈ m q) :
    A ∈ limitSetBelow m (q : ℝ) := by
  refine ⟨(q : ℝ) - 1, by linarith, ?_⟩
  intro p _ hp2
  exact hH q p A (by exact_mod_cast hp2) hA

/--
Dual of `limitSetBelow_of_rat`: `forward_G` coherence transfers the whole strict future of `q`
into the limit set from above at `q`.
-/
theorem limitSetAbove_of_rat (m : Rat → Set Formula)
    (hG : ∀ (s t : Rat) (φ : Formula), s < t → Formula.allFuture φ ∈ m s → φ ∈ m t)
    (q : Rat) (A : Formula) (hA : Formula.allFuture A ∈ m q) :
    A ∈ limitSetAbove m (q : ℝ) := by
  refine ⟨(q : ℝ) + 1, by linarith, ?_⟩
  intro p _ hp2
  exact hG q p A (by exact_mod_cast hp2) hA

end FormalSystem.Metalogic.Bundle

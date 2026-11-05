/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax

/-!
# GHR Lemma 10.2.1 — the four Boolean distributivities

[GHR][gabbay1994] vol. 1, Lemma 10.2.1: `U` distributes over a disjunction in its **event**
argument and over a conjunction in its **guard** argument, and `S` does the same in mirror
image. Each is stated here with *arbitrary* `USForm` arguments rather than atoms: GHR's
atomicity hypothesis exists only to license their substitution step and plays no part in the
semantic argument.

**Argument order.** In guard-first order GHR's `U(A ∨ B, C)` is `untl C (A.or B)` and GHR's
`U(A, B ∧ C)` is `untl (B.and C) A`.

## Linearity only

All four proofs consume only **linearity** of the flow — the event-argument cases distribute an
existential over a disjunction, and the guard-argument cases take the smaller (resp. larger) of
two witnesses. None consumes discreteness, and in particular none mentions
`Int.exists_least_of_bdd`, `SuccOrder` or `PredOrder`. GHR's 10.2.1 is valid over every linear
flow and this module records that fact mechanically.

## The duality idiom

`usTruth_swap_congr` is this subtree's duality combinator: a universally quantified `usTruth`
equivalence transfers to the two formulas' time reflections. Every `snce` statement below is
derived from its `untl` counterpart through it, rather than by repeating the argument. Later
phases reuse the same idiom.

## Main Results

- `usTruth_swap_congr` — the duality combinator
- `usTruth_untl_or_event`, `usTruth_snce_or_event` — distribution over a disjoined event
- `usTruth_untl_and_guard`, `usTruth_snce_and_guard` — distribution over a conjoined guard

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.1
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## The duality combinator -/

/--
**The duality combinator.** A `usTruth` equivalence holding at every leaf valuation and every
time transfers to the two formulas' time reflections. This is the `USForm`-level counterpart of
`FormalSystem.PlusLanguage.plusValidIn_reflectTime_iff`, and it is what halves every `snce`
case in this subtree.
-/
theorem usTruth_swap_congr {φ ψ : USForm}
    (h : ∀ (v : ℕ → ℤ → Prop) (t : ℤ), usTruth v t φ ↔ usTruth v t ψ)
    (v : ℕ → ℤ → Prop) (t : ℤ) : usTruth v t φ.swap ↔ usTruth v t ψ.swap := by
  rw [usTruth_swap, usTruth_swap]
  exact h _ _

/-! ## Distribution over a disjoined event argument -/

/--
**GHR 10.2.1, first distributivity**: `U(A ∨ B, C) ↔ U(A, C) ∨ U(B, C)`, in guard-first order
`untl C (A ∨ B) ↔ untl C A ∨ untl C B`. An existential distributing over a disjunction;
linearity only.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_untl_or_event (A B C : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.untl C (A.or B)) ↔
      usTruth v t ((USForm.untl C A).or (USForm.untl C B)) := by
  simp only [usTruth_or_iff, usTruth_untl_iff]
  constructor
  · rintro ⟨s, hts, (hA | hB), hg⟩
    · exact Or.inl ⟨s, hts, hA, hg⟩
    · exact Or.inr ⟨s, hts, hB, hg⟩
  · rintro (⟨s, hts, hA, hg⟩ | ⟨s, hts, hB, hg⟩)
    · exact ⟨s, hts, Or.inl hA, hg⟩
    · exact ⟨s, hts, Or.inr hB, hg⟩

/--
**GHR 10.2.1, second distributivity**: the `S` mirror of `usTruth_untl_or_event`, derived
through `usTruth_swap_congr` rather than by repeating the argument.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_snce_or_event (A B C : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce C (A.or B)) ↔
      usTruth v t ((USForm.snce C A).or (USForm.snce C B)) := by
  have h := usTruth_swap_congr (usTruth_untl_or_event A.swap B.swap C.swap) v t
  simpa using h

/-! ## Distribution over a conjoined guard argument -/

/--
**GHR 10.2.1, third distributivity**: `U(A, B ∧ C) ↔ U(A, B) ∧ U(A, C)`, in guard-first order
`untl (B ∧ C) A ↔ untl B A ∧ untl C A`.

The `←` half takes the **smaller** of the two event witnesses: the event argument holds at both,
hence at the smaller, and the open interval below the smaller is contained in both guarded
intervals. This is linearity (`le_total`), not discreteness.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_untl_and_guard (A B C : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.untl (B.and C) A) ↔
      usTruth v t ((USForm.untl B A).and (USForm.untl C A)) := by
  simp only [usTruth_and_iff, usTruth_untl_iff]
  constructor
  · rintro ⟨s, hts, hA, hg⟩
    exact ⟨⟨s, hts, hA, fun r h1 h2 => (hg r h1 h2).1⟩,
      ⟨s, hts, hA, fun r h1 h2 => (hg r h1 h2).2⟩⟩
  · rintro ⟨⟨s₁, h1, hA1, hB⟩, ⟨s₂, h2, hA2, hC⟩⟩
    rcases le_total s₁ s₂ with hle | hle
    · exact ⟨s₁, h1, hA1, fun r hr1 hr2 => ⟨hB r hr1 hr2, hC r hr1 (lt_of_lt_of_le hr2 hle)⟩⟩
    · exact ⟨s₂, h2, hA2, fun r hr1 hr2 => ⟨hB r hr1 (lt_of_lt_of_le hr2 hle), hC r hr1 hr2⟩⟩

/--
**GHR 10.2.1, fourth distributivity**: the `S` mirror of `usTruth_untl_and_guard`, derived
through `usTruth_swap_congr`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_snce_and_guard (A B C : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce (B.and C) A) ↔
      usTruth v t ((USForm.snce B A).and (USForm.snce C A)) := by
  have h := usTruth_swap_congr (usTruth_untl_and_guard A.swap B.swap C.swap) v t
  simpa using h

end FormalSystem.Metalogic.Expressiveness.SeparationZ

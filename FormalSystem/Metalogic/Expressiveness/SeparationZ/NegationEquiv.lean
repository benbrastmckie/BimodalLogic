/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Distributivity

/-!
# GHR Lemma 10.2.2 — the negation equivalences over `ℤ`

[GHR][gabbay1994] vol. 1, Lemma 10.2.2: the negation of an until (resp. since) is a disjunction
of a universal temporal claim with another until (resp. since). This is the **first
discreteness-dependent** step of the development: the forward direction needs a *least* witness
above the evaluation point, which `Int.exists_least_of_bdd` supplies over `ℤ` and which has no
counterpart over a dense flow.

In GHR's event-first notation the four statements are

* `¬U(A, B) ↔ G¬A ∨ U(¬A ∧ ¬B, ¬A)` — the printed form;
* `¬U(A, B) ↔ G¬A ∨ U(¬A ∧ ¬B, B ∧ ¬A)` — the variant whose guard additionally carries `B`,
  which is what the least-`¬B` witness actually delivers;
* and the two `S`/`H` mirrors, each derived by the `usTruth_swap_congr` duality of
  `Distributivity.lean`.

In this repository's guard-first order, GHR's `U(A, B)` is `untl B A` and GHR's
`U(¬A ∧ ¬B, ¬A)` is `untl A.neg (A.neg.and B.neg)`.

## The vacuous-guard orientation on `ℤ`

On the integer flow the open interval `(t, t + 1)` is **empty**, so an `untl` whose event
witness is the adjacent point `t + 1` has a *vacuously satisfied* guard. The degeneracy
therefore makes `untl` and `snce` **easier** to satisfy at adjacent points, never harder. The
archived Boneyard note on this file's predecessor states the orientation backwards, and the
mistake is cheap to re-inherit: a reader who assumes the guard is hard to satisfy at adjacent
points will look for a nonexistent side condition in every proof below.

## Main Results

- `exists_least_above` — the least-witness device over `ℤ`
- `usTruth_neg_untl`, `usTruth_neg_snce` — GHR 10.2.2's printed forms
- `usTruth_neg_untl_strong`, `usTruth_neg_snce_strong` — the variants carrying `B` in the guard

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.2
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## The least-witness device -/

/--
**The least witness strictly above `t`.** The discreteness of `ℤ` in the exact form the
negation equivalences consume: a predicate holding somewhere above `t` holds at a least such
point, below which it fails throughout the open interval.
-/
theorem exists_least_above {P : ℤ → Prop} {t : ℤ} (h : ∃ s : ℤ, t < s ∧ P s) :
    ∃ m : ℤ, t < m ∧ P m ∧ ∀ r : ℤ, t < r → r < m → ¬ P r := by
  obtain ⟨lb, ⟨hlb1, hlb2⟩, hmin⟩ :=
    Int.exists_least_of_bdd (P := fun z => t < z ∧ P z) ⟨t + 1, fun z hz => by omega⟩ h
  exact ⟨lb, hlb1, hlb2, fun r hr1 hr2 hPr => absurd (hmin r ⟨hr1, hPr⟩) (by omega)⟩

/-! ## The future-side equivalences -/

/--
**GHR 10.2.2, the variant with `B` in the guard**: in GHR's notation
`¬U(A, B) ↔ G¬A ∨ U(¬A ∧ ¬B, B ∧ ¬A)`.

The `→` half takes `u` := the least `A`-point above `t` and then `m` := the least `¬B`-point
above `t`; `m < u` because otherwise `B` would hold throughout `(t, u)` and `U(A, B)` would
hold. At `m` both `¬A` and `¬B` hold, and on `(t, m)` both `B` (by leastness of `m`) and `¬A`
(by leastness of `u`) hold. The `←` half is a trichotomy on the two witnesses and needs no
discreteness.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.2
-/
theorem usTruth_neg_untl_strong (A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.untl B A).neg ↔
      usTruth v t ((USForm.allFuture A.neg).or
        (USForm.untl (B.and A.neg) (A.neg.and B.neg))) := by
  simp only [usTruth_neg_iff, usTruth_or_iff, usTruth_allFuture_iff, usTruth_untl_iff,
    usTruth_and_iff]
  constructor
  · intro hnotU
    by_cases hG : ∀ s : ℤ, t < s → ¬ usTruth v s A
    · exact Or.inl hG
    · right
      push Not at hG
      obtain ⟨u, htu, hAu, hminA⟩ := exists_least_above hG
      have hexB : ∃ r : ℤ, t < r ∧ ¬ usTruth v r B := by
        by_contra hc
        push Not at hc
        exact hnotU ⟨u, htu, hAu, fun r h1 _ => hc r h1⟩
      obtain ⟨m, htm, hnBm, hminB⟩ := exists_least_above hexB
      have hmu : m < u := by
        by_contra hc
        exact hnotU ⟨u, htu, hAu, fun r h1 h2 => not_not.mp (hminB r h1 (by omega))⟩
      exact ⟨m, htm, ⟨hminA m htm hmu, hnBm⟩,
        fun r h1 h2 => ⟨not_not.mp (hminB r h1 h2), hminA r h1 (by omega)⟩⟩
  · rintro (hG | ⟨m, htm, ⟨hnAm, hnBm⟩, hg⟩) ⟨u, htu, hAu, hBg⟩
    · exact hG u htu hAu
    · rcases lt_trichotomy m u with h | h | h
      · exact hnBm (hBg m htm h)
      · exact hnAm (h ▸ hAu)
      · exact (hg u htu h).2 hAu

/--
**GHR 10.2.2, printed form**: in GHR's notation `¬U(A, B) ↔ G¬A ∨ U(¬A ∧ ¬B, ¬A)`.

The `→` half weakens the guard of `usTruth_neg_untl_strong`'s right-hand side; the `←` half is
the same trichotomy, now reading `¬A` off the guard directly.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.2
-/
theorem usTruth_neg_untl (A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.untl B A).neg ↔
      usTruth v t ((USForm.allFuture A.neg).or (USForm.untl A.neg (A.neg.and B.neg))) := by
  rw [usTruth_or_iff]
  constructor
  · intro h
    rcases (usTruth_or_iff v t _ _).mp ((usTruth_neg_untl_strong A B v t).mp h) with hG | hU
    · exact Or.inl hG
    · rw [usTruth_untl_iff] at hU
      obtain ⟨m, htm, hev, hg⟩ := hU
      exact Or.inr ((usTruth_untl_iff v t _ _).mpr
        ⟨m, htm, hev, fun r h1 h2 => ((usTruth_and_iff v r B A.neg).mp (hg r h1 h2)).2⟩)
  · intro h
    simp only [usTruth_neg_iff, usTruth_allFuture_iff, usTruth_untl_iff, usTruth_and_iff] at h ⊢
    rintro ⟨u, htu, hAu, hBg⟩
    rcases h with hG | ⟨m, htm, ⟨hnAm, hnBm⟩, hg⟩
    · exact hG u htu hAu
    · rcases lt_trichotomy m u with hc | hc | hc
      · exact hnBm (hBg m htm hc)
      · exact hnAm (hc ▸ hAu)
      · exact (hg u htu hc) hAu

/-! ## The past-side equivalences, by duality -/

/--
**GHR 10.2.2's `S`/`H` mirror of the variant form**, derived from
`usTruth_neg_untl_strong` through `usTruth_swap_congr`.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.2
-/
theorem usTruth_neg_snce_strong (A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce B A).neg ↔
      usTruth v t ((USForm.allPast A.neg).or
        (USForm.snce (B.and A.neg) (A.neg.and B.neg))) := by
  have h := usTruth_swap_congr (usTruth_neg_untl_strong A.swap B.swap) v t
  simpa using h

/--
**GHR 10.2.2's `S`/`H` mirror of the printed form**, derived from `usTruth_neg_untl` through
`usTruth_swap_congr`.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.2
-/
theorem usTruth_neg_snce (A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce B A).neg ↔
      usTruth v t ((USForm.allPast A.neg).or (USForm.snce A.neg (A.neg.and B.neg))) := by
  have h := usTruth_swap_congr (usTruth_neg_untl A.swap B.swap) v t
  simpa using h

end FormalSystem.Metalogic.Expressiveness.SeparationZ

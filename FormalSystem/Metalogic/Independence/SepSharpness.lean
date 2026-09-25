/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import Mathlib.Data.Finsupp.Lex

/-!
# Sharpness of the `sep` row of `Axiom.minFrameClass`

`Independence/DenseRTimeSharpness.lean` closes three of the four non-`.Base` rows of
`Axiom.minFrameClass` and records, for the fourth, a *proved obstruction* rather than a
refutation: `not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` show `Axiom.sep` is
vacuously valid on every frame whose durations have a least positive element, so by
`Semantics.duration_dense_or_least_pos` no discrete witness for it can exist. This module closes
that row, over a densely ordered duration group.

## Tags

independence · sharpness · minimality · sep · dense · hahn group · finsupp lex
-/

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem Finsupp

namespace FormalSystem.Metalogic.Independence

/-! ## The Hahn carrier

`Lex (ℚ →₀ ℚ)` is the Hahn group of finitely supported functions `ℚ → ℚ` ordered
lexicographically — a direct sum of `ℚ`-many archimedean classes indexed by `ℚ` itself. Both
features of the index order are load-bearing and neither can be dropped: it must be **dense**
(over `ℕ →₀ ℚ` each generator would have an immediate generator-successor, killing the axiom's
second antecedent conjunct) and it must be **unbounded above** (that is what makes the generators
accumulate at `0`).

Every instance `TemporalOrder.of` needs is supplied by Mathlib — `AddCommGroup` and `Nontrivial`
by `Lex`-synonym transfer, `LinearOrder` by `Finsupp.Lex.linearOrder`, and `IsOrderedAddMonoid`
by `Finsupp.Lex.isOrderedCancelAddMonoid` — except `DenselyOrdered`, written below.
-/

/-- The Hahn group `⊕_{γ ∈ ℚ} ℚ`: finitely supported `ℚ → ℚ`, ordered lexicographically.

Every helper in this module is stated at this bare abbreviation and *not* at
`(sepSharpOrder : Type)`. That is forced rather than stylistic: at `TemporalOrder.carrier` the
application `ofLex r j` fails to elaborate ("function expected at `ofLex r`"), and reducibility
bridges the two only at the frame-level theorem, where no such application appears. -/
abbrev LexHahn := Lex (ℚ →₀ ℚ)

/-- `Lex (ℚ →₀ ℚ)` is densely ordered: between `x < y` differing first at index `i` sits `x`
shifted at `i` by half the gap. The explicit `rw` chain is required — a bare `simp` over-simplifies
the strict-inequality goals to `False`.

This is the one instance Mathlib does not already supply for the carrier. The argument
generalises: for `[LinearOrder α] [AddCommGroup N] [LinearOrder N] [DenselyOrdered N]` one gets
`DenselyOrdered (Lex (α →₀ N))` by replacing the midpoint `(y i - x i) / 2` with `exists_between`
in `N`, which also drops the need for division. That generalisation is a genuine upstreaming
candidate for `FormalSystem/ForMathlib/Order/`; it is kept local here because a new `ForMathlib/`
file is a recorded exception requiring coordinated edits to the init-import checker, churn out of
proportion to a fourteen-line instance at one closed type. -/
instance : DenselyOrdered LexHahn where
  dense := by
    intro x y h
    obtain ⟨i, hlt, hi⟩ := Finsupp.Lex.lt_iff.mp h
    refine ⟨toLex (ofLex x + Finsupp.single i ((ofLex y i - ofLex x i) / 2)), ?_, ?_⟩
    · refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
      · intro j hj
        rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg (ne_of_gt hj), add_zero]
      · rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_pos rfl]; linarith
    · refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
      · intro j hj
        rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg (ne_of_gt hj), add_zero]
        exact hlt j hj
      · rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_pos rfl]; linarith

/-- The Hahn duration order, carrier for the `sep`-row refutation. `AddCommGroup (Lex (ℚ →₀ ℚ))`
is noncomputable, so this is a `noncomputable abbrev`, matching `denseSharpOrder`. -/
noncomputable abbrev sepSharpOrder : TemporalOrder := TemporalOrder.of LexHahn

/-- The single-support generator at index `γ`: the Hahn vector with value `1` at `γ` and `0`
elsewhere. Index `γ` is the archimedean scale; `γ ↦ sepGen γ` is order-*reversing*, so larger
indices give smaller durations. -/
noncomputable def sepGen (γ : ℚ) : LexHahn := toLex (Finsupp.single γ (1 : ℚ))

/-- The φ-region: the positive-index single-support generators. Order-anti-isomorphic to the
positive rationals, so it is dense in itself, yet its elements are mutually infinitely separated
in the ambient order — the tension the `sep` axiom is about. -/
def sepRegion : Set LexHahn := {x | ∃ γ : ℚ, 0 < γ ∧ x = sepGen γ}

/-! ## Order machinery for the generators -/

/-- Componentwise normal form of a generator. -/
@[simp] theorem sepGen_apply (γ j : ℚ) : ofLex (sepGen γ) j = if γ = j then 1 else 0 := by
  simp [sepGen, Finsupp.single_apply]

/-- Every generator is a positive duration. -/
theorem sepGen_pos (γ : ℚ) : (0 : LexHahn) < sepGen γ := by
  refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
  · intro j hj; simp [ne_of_gt hj]
  · simp

/-- A generator sits strictly below any positive vector whose leading index is strictly smaller:
a coarser archimedean scale dominates every finer one. -/
theorem sepGen_lt_of_index_lt {r : LexHahn} {i γ : ℚ} (h0 : ∀ j, j < i → ofLex r j = 0)
    (hi : 0 < ofLex r i) (hγ : i < γ) : sepGen γ < r := by
  refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
  · intro j hj; rw [h0 j hj]; simp [ne_of_gt (hj.trans hγ)]
  · simpa [ne_of_gt hγ] using hi

/-- Even doubled, a vector whose leading index is strictly larger than `γ` stays below the
generator at `γ`: the separation between archimedean scales is infinite, so no finite multiple
bridges it. This is what makes the generators mutually non-accumulating. -/
theorem lt_sepGen_of_lt_index {r : LexHahn} {i γ : ℚ} (h0 : ∀ j, j < i → ofLex r j = 0)
    (hγ : γ < i) : r + r < sepGen γ := by
  refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
  · intro j hj
    have hz : ofLex r j = 0 := h0 j (hj.trans hγ)
    simp [hz, ne_of_gt hj]
  · have hz : ofLex r γ = 0 := h0 γ hγ
    simp [hz]

/-- Leading-index extraction: a positive vector has an index below which it vanishes and at which
it is strictly positive. -/
theorem pos_index {r : LexHahn} (h : 0 < r) :
    ∃ i, (∀ j, j < i → ofLex r j = 0) ∧ 0 < ofLex r i := by
  obtain ⟨i, h1, h2⟩ := Finsupp.Lex.lt_iff.mp h
  exact ⟨i, fun j hj => (h1 j hj).symm, h2⟩

/-- The generators are order-reversing in their index. Mathlib's `Finsupp.Lex.single_lt_iff` and
`Finsupp.Lex.single_strictAnti` look applicable but are specialised away from a general value type
in the pinned snapshot and do not apply at value type `ℚ`; this is the replacement, proved
directly from `Finsupp.Lex.lt_iff`. -/
theorem sepGen_lt_sepGen {γ δ : ℚ} : sepGen δ < sepGen γ ↔ γ < δ := by
  constructor
  · intro h
    obtain ⟨i, h1, h2⟩ := Finsupp.Lex.lt_iff.mp h
    rw [sepGen_apply, sepGen_apply] at h2
    have hγi : γ = i := by
      by_contra hne
      rw [if_neg hne] at h2
      split at h2 <;> linarith
    subst hγi
    rcases lt_trichotomy γ δ with h' | h' | h'
    · exact h'
    · subst h'; simp at h2
    · have h3 := h1 δ h'
      rw [sepGen_apply, sepGen_apply, if_pos rfl, if_neg (ne_of_gt h')] at h3
      exact absurd h3 (by norm_num)
  · intro h
    refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
    · intro j hj
      rw [sepGen_apply, sepGen_apply, if_neg (ne_of_gt hj),
        if_neg (by intro hh; exact absurd (hh ▸ hj) (by linarith))]
    · simp [ne_of_gt h]

end FormalSystem.Metalogic.Independence

/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Semantics.LexCarrier
import Mathlib.Data.Int.SuccPred

/-!
# Sharpness of the rigidity hypotheses

`Semantics/Correspondence/Rigidity.lean` proves that over a **dense Archimedean** duration group
a task frame is static iff it has a uniform dwell time, and hence that every finite-carrier frame
over such an order is static. This module makes the remark "both hypotheses are needed" a pair
of compiled witnesses, each a two-state frame with a uniform dwell time that is not static.

* **Density cannot be dropped.** Over any successor order without a maximum — `ℤ` in
  particular, which is Archimedean — the permissive frame `permissiveFrame` on `Bool`
  (`w ⇒_d u ↔ d ≠ 0 ∨ w = u`) has a uniform dwell time (`uniformDwell_of_finite`, the carrier
  is finite) but any nonzero duration moves `true` to `false`. This is
  `permissiveFrame_not_static`, with the `ℤ` instance spelled out as
  `intPermissiveFrame_not_static`.
* **The Archimedean property cannot be dropped.** `ℚ ×ₗ ℚ` is densely ordered but not
  Archimedean (`lexRat_not_archimedean`: the multiples of `(0, 1)` never reach `(1, 0)`). The
  two-state frame `lexRatFrame` whose relation is `(ofLex d).1 ≠ 0 ∨ w = u` — a task changes
  the state iff its duration has a nonzero *first* coordinate — has the uniform dwell radius
  `(0, 1)`, below which every duration has first coordinate `0`, yet the duration `(1, 0)` moves
  `true` to `false`. This is `lexRatFrame_not_static`.

`LexCarrier.lean`'s `not_archimedean` covers `α ×ₗ ℤ` only, and its second coordinate is what
carries the discreteness the ℤ-time witnesses need there; the fresh lemma here is for `ℚ ×ₗ ℚ`,
whose second coordinate is dense so that `DenselyOrdered` holds.

Both frames are built through `FrameOver.ofReflective` from a presenting relation, so their task
relations are read off with `FrameOver.ofReflective_taskRel` (or the `@[simp]` bridge
`permissiveFrame_taskRel`), never by unfolding. `Mathlib.Data.Int.SuccPred` is imported for the
`SuccOrder ℤ` instance that `intPermissiveFrame_not_static` recovers on the carrier of
`TemporalOrder.of ℤ`.
-/

namespace FormalSystem.Semantics.Rigidity

open TaskFrame

/-! ## Density cannot be dropped -/

/--
**The permissive frame is not static**, over any successor order without a maximum. Its relation
is `d ≠ 0 ∨ w = u`, so any nonzero duration relates `true` to `false`. Its carrier `Bool` is
finite, so `FrameOver.uniformDwell_of_finite` gives it a uniform dwell time regardless; what
fails is density, and with it the rigidity theorem.
-/
theorem permissiveFrame_not_static {D : TemporalOrder} (so : SuccOrder ↑D)
    (nm : NoMaxOrder ↑D) : ¬ Static (permissiveFrame D so nm).TaskRel := by
  intro h
  obtain ⟨d, hd⟩ := exists_ne (0 : ↑D)
  have := (h true d false).mp ((permissiveFrame_taskRel so nm _ _ _).mpr (Or.inl hd))
  exact Bool.noConfusion this

/--
**At `ℤ`**, which is Archimedean: the permissive frame over `TemporalOrder.of ℤ` is not static.
The `SuccOrder` and `NoMaxOrder` instances on the carrier are recovered from `ℤ`'s by
`inferInstanceAs`, since `TemporalOrder.of ℤ` presents its carrier as a projection.
-/
theorem intPermissiveFrame_not_static :
    ¬ Static (permissiveFrame (TemporalOrder.of ℤ) (inferInstanceAs (SuccOrder ℤ))
      (inferInstanceAs (NoMaxOrder ℤ))).TaskRel :=
  permissiveFrame_not_static _ _

/-! ## The Archimedean property cannot be dropped -/

/-- The lexicographic product `ℚ ×ₗ ℚ`: densely ordered, not Archimedean. -/
abbrev LexRat : Type := ℚ ×ₗ ℚ

/-- The presenting relation of `lexRatFrame`: a task changes the state iff its duration has a
nonzero first coordinate. -/
def lexRatRel (w : Bool) (d : LexRat) (u : Bool) : Prop := (ofLex d).1 ≠ 0 ∨ w = u

/-- A nonnegative element of `ℚ ×ₗ ℚ` has nonnegative first coordinate. -/
theorem lexRat_fst_nonneg {x : LexRat} (hx : 0 ≤ x) : 0 ≤ (ofLex x).1 := by
  rcases (Prod.Lex.le_iff (x := (0 : LexRat)) (y := x)).mp hx with h | h
  · exact le_of_lt h
  · exact le_of_eq h.1

/-- `lexRatRel` satisfies the reflection law: negation preserves "first coordinate nonzero". -/
theorem lexRatRel_refl : ∀ w d u, lexRatRel w d u ↔ lexRatRel u (-d) w := by
  intro w d u
  simp only [lexRatRel, ofLex_neg, Prod.fst_neg, ne_eq, neg_eq_zero]
  exact ⟨fun h => h.imp id Eq.symm, fun h => h.imp id Eq.symm⟩

/-- `lexRatRel` is compositional: the first coordinate of a sum of nonnegative durations is
nonzero iff one of the summands' is. -/
theorem lexRatRel_comp : Compositional lexRatRel := by
  intro w v x y hx hy
  have h1 := lexRat_fst_nonneg hx
  have h2 := lexRat_fst_nonneg hy
  simp only [lexRatRel, ofLex_add, Prod.fst_add]
  constructor
  · rintro (h | rfl)
    · by_cases hx0 : (ofLex x).1 = 0
      · refine ⟨w, Or.inr rfl, Or.inl ?_⟩
        rwa [hx0, zero_add] at h
      · exact ⟨v, Or.inl hx0, Or.inr rfl⟩
    · exact ⟨w, Or.inr rfl, Or.inr rfl⟩
  · rintro ⟨u, (h | rfl), (h' | rfl)⟩
    · left; exact ne_of_gt (add_pos_of_pos_of_nonneg (lt_of_le_of_ne h1 (Ne.symm h)) h2)
    · left; exact ne_of_gt (add_pos_of_pos_of_nonneg (lt_of_le_of_ne h1 (Ne.symm h)) h2)
    · left; exact ne_of_gt (add_pos_of_nonneg_of_pos h1 (lt_of_le_of_ne h2 (Ne.symm h')))
    · right; rfl

/-- `lexRatRel` is serial: every state loops at every duration. -/
theorem lexRatRel_serial : Serial lexRatRel :=
  fun w _ _ => ⟨⟨w, Or.inr rfl⟩, ⟨w, Or.inr rfl⟩⟩

/-- `lexRatRel` satisfies *Limit*: below the radius `(0, 1)` every duration has first coordinate
`0`, so only the loop survives. -/
theorem lexRatRel_limit :
    ∀ w u, (∀ x : LexRat, 0 < x → ∃ y, |y| < x ∧ lexRatRel w y u) → u = w := by
  intro w u h
  have hpos : (0 : LexRat) < toLex ((0 : ℚ), (1 : ℚ)) := by
    rw [Prod.Lex.lt_iff]; right; exact ⟨rfl, by norm_num⟩
  obtain ⟨y, hy, hR | hR⟩ := h _ hpos
  · exfalso
    apply hR
    have hy1 := (abs_lt.mp hy).1
    have hy2 := (abs_lt.mp hy).2
    rw [Prod.Lex.lt_iff] at hy1 hy2
    simp only [ofLex_neg, ofLex_toLex, Prod.fst_neg, neg_zero] at hy1 hy2
    rcases hy1 with a | a <;> rcases hy2 with b | b
    · exact absurd (lt_trans a b) (lt_irrefl _)
    · exact b.1
    · exact a.1.symm
    · exact b.1
  · exact hR.symm

/-- The two-state task frame over `ℚ ×ₗ ℚ` presented by `lexRatRel`; saturation is free on a
finite carrier. -/
noncomputable def lexRatFrame : FrameOver (TemporalOrder.of LexRat) :=
  FrameOver.ofReflective Bool lexRatRel lexRatRel_refl lexRatRel_comp lexRatRel_serial
    lexRatRel_limit (saturation_of_finite lexRatRel)

/--
**`lexRatFrame` is not static**: the duration `(1, 0)` relates `true` to `false`. Its carrier is
finite, so it has a uniform dwell time; its duration group is densely ordered
(`lexRat_denselyOrdered`); what fails is the Archimedean property (`lexRat_not_archimedean`).
-/
theorem lexRatFrame_not_static : ¬ Static lexRatFrame.TaskRel := by
  intro h
  have : lexRatRel true (toLex ((1 : ℚ), (0 : ℚ))) false := Or.inl (by simp)
  exact Bool.noConfusion ((h true _ false).mp (FrameOver.ofReflective_taskRel.mpr this))

/-- The first coordinate of an `ℕ`-multiple in `ℚ ×ₗ ℚ` is the multiple of the first coordinate. -/
theorem lexRat_fst_nsmul (n : ℕ) (x : LexRat) : (ofLex (n • x)).1 = n • (ofLex x).1 := by
  induction n with
  | zero => simp
  | succ n ih => rw [succ_nsmul, succ_nsmul, ofLex_add, Prod.fst_add, ih]

/--
**`ℚ ×ₗ ℚ` is not Archimedean**: every multiple of the positive element `(0, 1)` has first
coordinate `0`, so none dominates `(1, 0)`. `LexCarrier.lean`'s `not_archimedean` is the
analogous fact for `α ×ₗ ℤ`; it does not cover this carrier.
-/
theorem lexRat_not_archimedean : ¬ Archimedean LexRat := by
  intro h
  have hpos : (0 : LexRat) < toLex ((0 : ℚ), (1 : ℚ)) := by
    rw [Prod.Lex.lt_iff]; right; exact ⟨rfl, by norm_num⟩
  obtain ⟨n, hn⟩ := h.arch (toLex ((1 : ℚ), (0 : ℚ))) hpos
  have hfst : (ofLex (n • (toLex ((0 : ℚ), (1 : ℚ)) : LexRat))).1 = 0 := by
    rw [lexRat_fst_nsmul]; simp
  rcases (Prod.Lex.le_iff).mp hn with a | a
  · rw [hfst] at a; simp at a; linarith
  · rw [hfst] at a; simp at a

/-- **`ℚ ×ₗ ℚ` is densely ordered**, by Mathlib's instance for lexicographic products; recorded
so the witness's two hypotheses are both visible as theorems. -/
theorem lexRat_denselyOrdered : DenselyOrdered LexRat := inferInstance

end FormalSystem.Semantics.Rigidity

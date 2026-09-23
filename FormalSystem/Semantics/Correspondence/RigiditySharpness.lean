/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Semantics.LexCarrier
import Mathlib.Data.Int.SuccPred
import Mathlib.Data.Rat.Denumerable

/-!
# Sharpness of the rigidity hypotheses

`Semantics/Correspondence/Rigidity.lean` proves that over a **dense Archimedean** duration group
a task frame is static iff it has a uniform dwell time, and hence that every finite-carrier frame
over such an order is static. This module makes the remark "every hypothesis is needed" a set of
compiled witnesses. The first two are two-state frames with a uniform dwell time that are not
static; the third weakens finiteness to countability and loses staticity with it.

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
* **Finiteness cannot be weakened to countability.** `FrameOver.static_of_finite` asks for a
  *finite* carrier, and over a dense Archimedean order that cannot be relaxed to a countable
  one: the rational clock — states `ℚ`, `w ⇒_x u ↔ u = w + x`, over the dense Archimedean order
  `ℚ` — is countable and not static. This is `ratClock_not_static`. (Over `ℝ` the same
  weakening *is* available, because Dedekind completeness replaces density and the Archimedean
  property: `Semantics/Correspondence/RigidityReal.lean`'s `FrameOver.static_of_countable`.)

`LexCarrier.lean`'s `not_archimedean` covers `α ×ₗ ℤ` only, and its second coordinate is what
carries the discreteness the ℤ-time witnesses need there; the fresh lemma here is for `ℚ ×ₗ ℚ`,
whose second coordinate is dense so that `DenselyOrdered` holds.

Both frames are built through `FrameOver.ofReflectiveRegular` from a presenting relation, so
their task
relations are read off with `FrameOver.ofReflectiveRegular_taskRel` (or the `@[simp]` bridge
`permissiveFrame_taskRel`), never by unfolding. `Mathlib.Data.Int.SuccPred` is imported for the
`SuccOrder ℤ` instance that `intPermissiveFrame_not_static` recovers on the carrier of
`TemporalOrder.of ℤ`, and `Mathlib.Data.Rat.Denumerable` for the `Countable ℚ` instance
`ratClock_not_static` records.
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
  FrameOver.ofReflectiveRegular Bool lexRatRel lexRatRel_refl lexRatRel_comp lexRatRel_serial
    lexRatRel_limit (saturation_of_finite lexRatRel)

/--
**`lexRatFrame` is not static**: the duration `(1, 0)` relates `true` to `false`. Its carrier is
finite, so it has a uniform dwell time; its duration group is densely ordered
(`lexRat_denselyOrdered`); what fails is the Archimedean property (`lexRat_not_archimedean`).
-/
theorem lexRatFrame_not_static : ¬ Static lexRatFrame.TaskRel := by
  intro h
  have : lexRatRel true (toLex ((1 : ℚ), (0 : ℚ))) false := Or.inl (by simp)
  exact Bool.noConfusion ((h true _ false).mp (FrameOver.ofReflectiveRegular_taskRel.mpr this))

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

/-! ## Finiteness cannot be weakened to countability -/

/-- The rationals as a duration order: dense and Archimedean, and countable. -/
abbrev ratOrder : TemporalOrder := TemporalOrder.of ℚ

/--
**The rational clock is not static**, so the *finiteness* hypothesis of
`FrameOver.static_of_finite` cannot be weakened to countability.

The carrier here is `ℚ`, and it is countable — the instance is `inferInstanceAs (Countable ℚ)`,
which is why this module imports `Mathlib.Data.Rat.Denumerable`. The duration order is likewise
`ℚ`, which is both densely ordered and Archimedean — so every hypothesis of the rigidity theorem
other than finiteness holds — and the frame is nevertheless not static, since the duration `1`
moves the state `0` to the state `1`. Countable plus dense plus Archimedean is therefore not
enough for rigidity, and the escape is exactly a state space that carries a clock reading.

Over `ℝ` the weakening *is* available: `FrameOver.static_of_countable`
(`Semantics/Correspondence/RigidityReal.lean`) needs neither finiteness nor density nor the
Archimedean property, because Dedekind completeness replaces them. `ℚ` is precisely where the
two boundaries disagree.
-/
theorem ratClock_not_static : ¬ Static (translationFrame ratOrder).TaskRel := by
  intro h
  have h1 : (0 : ℚ) = 1 := (h (0 : ℚ) (1 : ℚ) (1 : ℚ)).mp (by simp [translationFrame_taskRel])
  exact absurd h1 (by norm_num)

end FormalSystem.Semantics.Rigidity

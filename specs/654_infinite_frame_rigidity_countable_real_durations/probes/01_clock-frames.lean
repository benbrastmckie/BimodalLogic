-- PROBE (scratch, not a library module). Compiled green via `lean_run_code` against this tree
-- (Lean v4.33.0-rc1, Mathlib tag v4.33.0-rc1). Evidence for Q1 and Q3 of the research report.
--
-- Q1: the rational clock — states ℚ, `w ⇒_x u ↔ u = w + x` — is a COUNTABLE, NON-STATIC task
--     frame over the dense Archimedean order ℚ. It is not a new construction: it is
--     `FormalSystem.Semantics.translationFrame` (Semantics/Frames/Standard.lean) at `ℚ`.
-- Q3: the real clock is the same construction at `ℝ`; its carrier is uncountable.
--
-- Every field of the live `FrameOver` structure is exhibited below by projection, so the
-- "check every field against it" obligation is discharged by the frame value itself rather
-- than by a re-proof.
import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.Semantics.Frames.Standard
import Mathlib.Analysis.Real.Cardinality
import Mathlib.Data.Rat.Denumerable
import Mathlib.Algebra.Order.Archimedean.Basic

namespace Probe
open FormalSystem.Semantics TaskFrame

abbrev ratOrder : TemporalOrder := TemporalOrder.of ℚ
noncomputable abbrev realOrder : TemporalOrder := TemporalOrder.of ℝ

noncomputable abbrev ratClock : FrameOver ratOrder := translationFrame ratOrder
noncomputable abbrev realClock : FrameOver realOrder := translationFrame realOrder

/-! ## Carrier cardinality -/

example : Countable ratClock.WorldState := inferInstanceAs (Countable ℚ)
example : ¬ Countable realClock.WorldState := fun h => Cardinal.not_countable_real
  (Set.countable_univ_iff.mpr h)

/-! ## The duration orders are dense and Archimedean -/

example : DenselyOrdered ↑ratOrder := inferInstanceAs (DenselyOrdered ℚ)
example : Archimedean ↑ratOrder := inferInstanceAs (Archimedean ℚ)
example : DenselyOrdered ↑realOrder := inferInstanceAs (DenselyOrdered ℝ)
example : Archimedean ↑realOrder := inferInstanceAs (Archimedean ℝ)

/-! ## Every field of the live `FrameOver` structure, at the rational clock -/

example : TaskFrame.Compositional (TaskFrame.reflect ratClock.PosRel) := ratClock.comp
example : TaskFrame.Serial (TaskFrame.reflect ratClock.PosRel) := ratClock.serial
example : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskFrame.reflect ratClock.PosRel w y u) → u = w :=
  ratClock.limit
example : TaskFrame.Saturation (TaskFrame.reflect ratClock.PosRel) := ratClock.saturation
example : Nonempty ratClock.WorldState := ratClock.worldNonempty

/-- Both halves of *Compositionality*, projected out separately. -/
example : TaskFrame.Interpolates ratClock.TaskRel := ratClock.interpolates
example : ∀ w u v x y, 0 ≤ x → 0 ≤ y → ratClock.TaskRel w x u → ratClock.TaskRel u y v →
    ratClock.TaskRel w (x + y) v := ratClock.forward_comp

/-! ## Non-staticity -/

theorem ratClock_not_static : ¬ Static ratClock.TaskRel := by
  intro h
  have h1 : (0 : ℚ) = 1 := (h (0 : ℚ) (1 : ℚ) (1 : ℚ)).mp (by simp [translationFrame_taskRel])
  exact absurd h1 (by norm_num)

theorem realClock_not_static : ¬ Static realClock.TaskRel := by
  intro h
  have h1 : (0 : ℝ) = 1 := (h (0 : ℝ) (1 : ℝ) (1 : ℝ)).mp (by simp [translationFrame_taskRel])
  exact absurd h1 (by norm_num)

/-! ## The padded clock: an uncountable non-static frame over *every* temporal order

Fills the "uncountable carrier" row of the report's table at `ℤ`, `ℚ` and `ℚ ×ₗ ℚ` as well as
`ℝ`. The first coordinate is a clock, the second is inert ballast; the relation is functional,
so *Saturation* is `TaskFrame.saturation_of_fib_subsingleton` and *Limit* is
`TaskFrame.limit_of_shift` at the first projection.
-/

/-- The presenting relation of the padded clock. -/
def padRel (D : TemporalOrder) : (↑D × ℝ) → ↑D → (↑D × ℝ) → Prop :=
  fun w d u => u.1 = w.1 + d ∧ u.2 = w.2

noncomputable def paddedClock (D : TemporalOrder) : FrameOver D :=
  haveI : Nonempty (↑D × ℝ) := ⟨(0, 0)⟩
  FrameOver.ofReflective (↑D × ℝ) (padRel D)
    (by
      intro w d u
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨by rw [h1]; simp, h2.symm⟩
      · rintro ⟨h1, h2⟩; exact ⟨by rw [h1]; simp, h2.symm⟩)
    (TaskFrame.comp_of
      (by
        rintro w v x y _ _ ⟨h1, h2⟩
        exact ⟨(w.1 + x, w.2), ⟨rfl, rfl⟩, h1.trans (add_assoc _ _ _).symm, h2⟩)
      (by
        rintro w u v x y _ _ ⟨h1, h2⟩ ⟨h3, h4⟩
        exact ⟨by rw [h3, h1, add_assoc], by rw [h4, h2]⟩))
    (by
      intro w x _
      exact ⟨⟨(w.1 + x, w.2), rfl, rfl⟩, ⟨(w.1 - x, w.2), by simp, rfl⟩⟩)
    (TaskFrame.limit_of_shift (D := ↑D) Prod.fst (fun _ _ _ h => h.1)
      (by rintro w u ⟨h1, h2⟩; rw [add_zero] at h1; exact Prod.ext h1 h2))
    (TaskFrame.saturation_of_fib_subsingleton (by
      rintro w x u ⟨h1, h2⟩ u' ⟨h3, h4⟩
      exact Prod.ext (h1.trans h3.symm) (h2.trans h4.symm)))

@[simp] theorem paddedClock_taskRel {D : TemporalOrder} (w : ↑D × ℝ) (x : ↑D) (u : ↑D × ℝ) :
    (paddedClock D).TaskRel w x u ↔ (u.1 = w.1 + x ∧ u.2 = w.2) := FrameOver.ofReflective_taskRel

theorem paddedClock_uncountable (D : TemporalOrder) : ¬ Countable (paddedClock D).WorldState := by
  intro h
  haveI : Countable (↑D × ℝ) := h
  have hc : Countable ℝ := Function.Injective.countable
    (f := fun r : ℝ => ((0 : ↑D), r)) (fun a b hab => congrArg Prod.snd hab)
  exact Cardinal.not_countable_real (Set.countable_univ_iff.mpr hc)

theorem paddedClock_not_static (D : TemporalOrder) : ¬ Static (paddedClock D).TaskRel := by
  intro h
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  have h1 : ((0 : ↑D), (0 : ℝ)) = ((0 : ↑D) + x, (0 : ℝ)) :=
    (h _ x _).mp ((paddedClock_taskRel _ _ _).mpr ⟨rfl, rfl⟩)
  have h2 := congrArg Prod.fst h1
  simp only [zero_add] at h2
  exact absurd h2.symm (ne_of_gt hx)

end Probe

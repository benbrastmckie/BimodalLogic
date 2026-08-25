import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Mathlib.Algebra.Order.Monoid.Prod
import Mathlib.Order.Interval.Set.OrdConnected

open Set

abbrev QZ := ℚ ×ₗ ℤ

def S : Set QZ := {x | (ofLex x).1 < 0}

theorem S_ordConnected : S.OrdConnected := by
  constructor
  intro _ _ b hb c hc
  simp only [S, Set.mem_setOf_eq] at hb ⊢
  rcases Prod.Lex.le_iff.mp hc.2 with h | h
  · exact lt_trans h hb
  · exact h.1 ▸ hb

/-- `S` has no greatest element: bump the ℤ-coordinate. -/
theorem S_no_max : ∀ a ∈ S, ∃ b ∈ S, a < b := by
  intro a ha
  refine ⟨toLex ((ofLex a).1, (ofLex a).2 + 1), ha, ?_⟩
  have : a = toLex ((ofLex a).1, (ofLex a).2) := rfl
  rw [this]
  exact Prod.Lex.right _ (by simp)

/-- `Sᶜ` has no least element: drop the ℤ-coordinate. -/
theorem Scompl_no_min : ∀ a ∈ Sᶜ, ∃ b ∈ Sᶜ, b < a := by
  intro a ha
  refine ⟨toLex ((ofLex a).1, (ofLex a).2 - 1), ha, ?_⟩
  have : a = toLex ((ofLex a).1, (ofLex a).2) := rfl
  rw [this]
  exact Prod.Lex.right _ (by simp)

#print axioms S_ordConnected
#print axioms S_no_max
#print axioms Scompl_no_min

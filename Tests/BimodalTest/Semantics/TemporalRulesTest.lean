/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.Semantics.RankProgress
import FormalSystem.Semantics.TemporalIntervals
import FormalSystem.Semantics.TemporalRules

/-! Tests for the endpoints and persistence of the temporal truth clauses. -/

namespace BimodalTest.Semantics

open FormalSystem.Semantics FormalSystem.Semantics.TruthClauses
open FormalSystem.Semantics.TemporalRules FormalSystem.Semantics.TemporalIntervals
open FormalSystem.Syntax FormalSystem.PlusLanguage

variable {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t s : F.Duration}

example (A : Formula) (h : TruthAt M τ t A.next) (cover : t ⋖ s) : TruthAt M τ s A :=
  next_at (L := Formula) (e := PUnit.unit) cover h

example (A : PlusFormula) (h : PlusTruthAt M τ t A.prev) (cover : s ⋖ t) :
    PlusTruthAt M τ s A :=
  prev_at (L := PlusFormula) (e := PUnit.unit) cover h

example (A B P : Formula) (hA : TruthAt M τ t A.someFuture) (hP : TruthAt M τ t P.allFuture)
    (step : ∀ s, t < s → TruthAt M τ s A → TruthAt M τ s P.allFuture →
      TruthAt M τ s B.someFuture) : TruthAt M τ t B.someFuture :=
  someFuture_bind (L := Formula) (e := PUnit.unit) hA fun s hs h =>
    step s hs h (allFuture_persist (L := Formula) (e := PUnit.unit) (P := P) hP hs)

example (A B P : PlusFormula) (hA : PlusTruthAt M τ t A.somePast)
    (hP : PlusTruthAt M τ t P.allPast)
    (step : ∀ s, s < t → PlusTruthAt M τ s A → PlusTruthAt M τ s P.allPast →
      PlusTruthAt M τ s B.somePast) : PlusTruthAt M τ t B.somePast :=
  somePast_bind (L := PlusFormula) (e := PUnit.unit) hA fun s hs h =>
    step s hs h (allPast_persist (L := PlusFormula) (e := PUnit.unit) (P := P) hP hs)

-- A current witness needs no guard, even when the guard is bottom.
example (A : Formula) (hA : TruthAt M τ t A) :
    TruthAt M τ t (A.or (Formula.bot.and (Formula.untl Formula.bot A))) :=
  (inclusiveUntil_iff (L := Formula) M τ t PUnit.unit Formula.bot A).mpr
    ⟨t, le_rfl, hA, fun _ ht hs => absurd hs (not_lt.mpr ht)⟩

example (A G : PlusFormula) (hG : PlusTruthAt M τ t G.allPast) :
    PlusTruthAt M τ t ((PlusFormula.snce G A).or G.allPast) :=
  (weakSince_iff (L := PlusFormula) M τ t PUnit.unit A G).mpr
    (Or.inr ((allPast_iff M τ t PUnit.unit G).mp hG))

-- The strict form reaches a later point, with the occurrence premise supplying the step.
example : ∃ u : ℕ, 0 < u ∧ u = 2 := by
  apply RankProgress.rank_progress_strict Nat.lt_wfRel.wf (fun t : ℕ => t ≤ 2)
    (fun t => t = 2) (fun t => 2 - t)
  · intro s hs hQ
    refine ⟨s + 1, by omega, by omega, ?_⟩
    by_cases h : s + 1 = 2
    · exact Or.inl h
    · exact Or.inr (show 2 - (s + 1) < 2 - s by omega)
  · decide
  · decide

end BimodalTest.Semantics

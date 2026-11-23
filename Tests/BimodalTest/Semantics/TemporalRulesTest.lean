/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.StarLanguage.StarTruth
import FormalSystem.Semantics.RankProgress
import FormalSystem.Semantics.TemporalIntervals
import FormalSystem.Semantics.TemporalRules

/-! Tests for the endpoints and persistence of the temporal truth clauses. -/

namespace BimodalTest.Semantics

open FormalSystem.Semantics FormalSystem.Semantics.TruthClauses
open FormalSystem.Semantics.TemporalRules FormalSystem.Semantics.TemporalIntervals
open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.StarLanguage

variable {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t s : F.Duration}

example (A : Formula) (h : TruthAt M τ t A.next) (cover : t ⋖ s) : TruthAt M τ s A :=
  next_at (L := Formula) (e := PUnit.unit) cover h

example (A : PlusFormula) (h : PlusTruthAt M τ t A.prev) (cover : s ⋖ t) :
    PlusTruthAt M τ s A :=
  prev_at (L := PlusFormula) (e := PUnit.unit) cover h

-- The cover clauses retain the stored-time vector at the adjacent point in L⋆.
example (A : StarFormula) (regs : ℕ → F.Duration) (cover : t ⋖ s)
    (h : StarTruthAt M τ s regs A) : StarTruthAt M τ t regs A.next :=
  (next_iff (L := StarFormula) M τ t regs A).mpr ⟨s, cover, h⟩

example (A : Formula) (h : TruthAt M τ t A.prev) :
    ∃ u : F.Duration, u ⋖ t ∧ TruthAt M τ u A :=
  (prev_iff (L := Formula) M τ t PUnit.unit A).mp h

example (A B P : Formula) (hA : TruthAt M τ t A.someFuture) (hP : TruthAt M τ t P.allFuture)
    (step : ∀ s, t < s → TruthAt M τ s A → TruthAt M τ s P.allFuture →
      TruthAt M τ s B.someFuture) : TruthAt M τ t B.someFuture := by
  refine someFuture_bind_keeping (L := Formula) (e := PUnit.unit) [P] ?_ hA ?_
  · intro Q hQ
    obtain rfl : Q = P := by simpa using hQ
    exact hP
  · intro s hs kept h
    exact step s hs h (kept P (by simp))

example (A B P : PlusFormula) (hA : PlusTruthAt M τ t A.somePast)
    (hP : PlusTruthAt M τ t P.allPast)
    (step : ∀ s, s < t → PlusTruthAt M τ s A → PlusTruthAt M τ s P.allPast →
      PlusTruthAt M τ s B.somePast) : PlusTruthAt M τ t B.somePast := by
  refine somePast_bind_keeping (L := PlusFormula) (e := PUnit.unit) [P] ?_ hA ?_
  · intro Q hQ
    obtain rfl : Q = P := by simpa using hQ
    exact hP
  · intro s hs kept h
    exact step s hs h (kept P (by simp))

-- A current witness needs no guard, even when the guard is bottom.
example (A : Formula) (hA : TruthAt M τ t A) :
    TruthAt M τ t (A.or (Formula.bot.and (Formula.untl Formula.bot A))) :=
  (inclusiveUntil_iff (L := Formula) M τ t PUnit.unit Formula.bot A).mpr
    ⟨t, le_rfl, hA, fun _ ht hs => absurd hs (not_lt.mpr ht)⟩

example (A G : PlusFormula) (hG : PlusTruthAt M τ t G.allPast) :
    PlusTruthAt M τ t ((PlusFormula.snce G A).or G.allPast) :=
  (weakSince_iff (L := PlusFormula) M τ t PUnit.unit A G).mpr
    (Or.inr ((allPast_iff M τ t PUnit.unit G).mp hG))

example (A : Formula) (hA : TruthAt M τ t A) :
    TruthAt M τ t (A.or (Formula.bot.and (Formula.snce Formula.bot A))) :=
  (inclusiveSince_iff (L := Formula) M τ t PUnit.unit Formula.bot A).mpr
    ⟨t, le_rfl, hA, fun _ htr hrt => absurd hrt (not_le.mpr htr)⟩

example (event guard : Formula) (h : ∀ s, t < s → TruthAt M τ s event) :
    TruthAt M τ t (Formula.release event guard) :=
  (release_iff (L := Formula) M τ t PUnit.unit event guard).mpr
    (fun ⟨s, hts, hn, _⟩ => hn (h s hts))

example (event guard : Formula) (h : ∀ s, s < t → TruthAt M τ s event) :
    TruthAt M τ t (Formula.trigger event guard) :=
  (trigger_iff (L := Formula) M τ t PUnit.unit event guard).mpr
    (fun ⟨s, hst, hn, _⟩ => hn (h s hst))

example (event guard : Formula) (h : ∀ s, t < s → TruthAt M τ s guard) :
    TruthAt M τ t (Formula.weakUntil event guard) :=
  (weakUntil_iff (L := Formula) M τ t PUnit.unit event guard).mpr (Or.inr h)

example : (2 : ℕ) = 2 ∨ ∃ u : ℕ, 2 < u ∧ u = 2 :=
  RankProgress.rank_progress Nat.lt_wfRel.wf (fun u : ℕ => u = 2) (fun u => u = 2)
    (fun _ => 0) (fun _ h hn => (hn h).elim) rfl

example (A : PlusFormula) (rank : F.Duration → ℕ) (invariant : F.Duration → Prop)
    (step : ∀ s, invariant s → ¬ PlusTruthAt M τ s A →
      ∃ u, s < u ∧ invariant u ∧ (PlusTruthAt M τ u A ∨ rank u < rank s))
    (h : invariant t) :
    PlusTruthAt M τ t A ∨ PlusTruthAt M τ t A.someFuture :=
  RankProgress.rank_progress_truth (L := PlusFormula) M τ PUnit.unit A
    Nat.lt_wfRel.wf invariant rank step h

example (A : StarFormula) (regs : ℕ → F.Duration) (rank : F.Duration → ℕ)
    (invariant : F.Duration → Prop)
    (step : ∀ s, invariant s → ¬ StarTruthAt M τ s regs A →
      ∃ u, s < u ∧ invariant u ∧ (StarTruthAt M τ u regs A ∨ rank u < rank s))
    (h : invariant t) (hn : ¬ StarTruthAt M τ t regs A) :
    StarTruthAt M τ t regs A.someFuture :=
  RankProgress.rank_progress_truth_strict (L := StarFormula) M τ regs A
    Nat.lt_wfRel.wf invariant rank step h hn

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

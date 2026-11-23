/- Scratch: does `At` (an abbrev) let the per-language clause lemmas fire by `rw`? -/
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.Semantics.PointTransport

namespace Scratch2

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula FormalSystem.PlusLanguage.PlusTruth
open FormalSystem.Semantics.PointTransport

variable {F : TaskFrame} {M : TaskModel F} {p : Point PlusFormula F}

-- Probe 1: rw with the per-language clause lemma, directly on an `At` goal.
example (A : PlusFormula) (h : ∀ s, p.time < s → PlusTruthAt M p.history s A) :
    At M p (allFuture A) := by
  rw [allFuture_iff]
  exact h

-- Probe 2: rw with the per-language clause lemma on an `At` hypothesis.
example (A : PlusFormula) (h : At M p (allFuture A)) :
    ∀ s, p.time < s → PlusTruthAt M p.history s A := by
  rw [allFuture_iff] at h
  exact h

-- Probe 3: the generic TruthClauses clause lemma on an `At` goal.
example (A : PlusFormula) (h : ∀ s, p.time < s → PlusTruthAt M p.history s A) :
    At M p (allFuture A) := by
  rw [TruthClauses.allFuture_iff]
  exact h

end Scratch2

/- Scratch: which idioms recover clause-lemma rewriting through `At`? -/
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.Semantics.PointTransport

namespace Scratch3

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula FormalSystem.PlusLanguage.PlusTruth
open FormalSystem.Semantics.PointTransport

variable {F : TaskFrame} {M : TaskModel F} {p : Point PlusFormula F}

-- Remedy A: `show`.
example (A : PlusFormula) (h : ∀ s, p.time < s → PlusTruthAt M p.history s A) :
    At M p (allFuture A) := by
  show PlusTruthAt M p.history p.time (allFuture A)
  rw [allFuture_iff]; exact h

-- Remedy B: `simp only [At]`.
example (A : PlusFormula) (h : ∀ s, p.time < s → PlusTruthAt M p.history s A) :
    At M p (allFuture A) := by
  simp only [At]
  rw [allFuture_iff]; exact h

-- Remedy C: `unfold At`.
example (A : PlusFormula) (h : ∀ s, p.time < s → PlusTruthAt M p.history s A) :
    At M p (allFuture A) := by
  unfold At
  rw [allFuture_iff]; exact h

-- Remedy D: `exact` still works (elaboration is up to reducible defeq).
example (A : PlusFormula) (h : PlusTruthAt M p.history p.time (allFuture A)) :
    At M p (allFuture A) := h

end Scratch3

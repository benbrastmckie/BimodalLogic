import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.PointTransport

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Semantics FormalSystem.Semantics.PointTransport

section
variable {L : Type} [TruthEnv L] {F : TaskFrame} (M : TaskModel F)
/-- An At-level statement of the G clause: the point must be rebuilt at the new time. -/
theorem allFuture_at [BotClause L] [ImpClause L] [UntlClause L] (q : Point L F) (φ : L) :
    At M q (TruthClauses.allFuture φ) ↔ ∀ s, q.time < s → At M ⟨q.history, s, q.env⟩ φ :=
  TruthClauses.allFuture_iff M q.history q.time q.env φ
theorem stab_at [StabClause L] (q : Point L F) (φ : L) :
    At M q (StabClause.stab φ) ↔
      ∀ σ : WorldHistory F, q.history.state q.time = σ.state q.time → At M ⟨σ, q.time, q.env⟩ φ :=
  StabClause.stab_clause M q.history q.time q.env φ
end

variable (p : Atom)
-- At-level clauses, formula written with the generic formers so that rw can fire
example : At natModel (⟨natHist fun _ => 0, (0:ℤ), PUnit.unit⟩ : Point PlusFormula NF)
    (StabClause.stab (TruthClauses.allFuture (StabClause.stab (PlusFormula.atom p)))) := by
  rw [stab_at]; intro σ hs
  rw [allFuture_at]; intro y hy
  rw [stab_at]; intro ρ hr
  trace_state
  exact hr.symm.trans (by rfl) |>.symm ▸ (sorry)

-- negation goal: generic apply still works on ¬ TruthEnv.T by mt
example : ¬ TruthEnv.T natModel (natHist fun _ => 0) (0:ℤ) PUnit.unit
    (PlusFormula.stab (PlusFormula.allFuture (.atom p))) := by
  refine mt (StabClause.stab_clause _ _ _ _ _).mp ?_
  trace_state
  sorry

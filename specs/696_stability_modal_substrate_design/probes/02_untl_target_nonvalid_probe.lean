import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.ProofSystem
open PlusTruth

/-- `Fp → (p ∨ ⊡Fp)`, i.e. `(¬p ∧ Fp) → ⊡Fp`. -/
def stabUntlTarget (p : Atom) : PlusFormula :=
  .imp (PlusFormula.untl PlusFormula.top (.atom p))
    (.imp (.imp (.atom p) .bot) (.stab (PlusFormula.untl PlusFormula.top (.atom p))))

theorem not_plusValidZTime_stabUntl (p : Atom) : ¬ PlusValidZTime (stabUntlTarget p) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  -- h1: state 1 at times ≤ 0, state 0 from time 1 on.  Fp holds at 0, p fails at 0.
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel
    (natHist fun s => if s ≤ 0 then 1 else 0) 0
  have hA : PlusTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) 0
      (someFuture (PlusFormula.atom p)) := by
    rw [someFuture_iff]
    refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_⟩
    change (if (1 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0
    simp
  have hnp : PlusTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) 0
      (PlusFormula.imp (.atom p) .bot) := by
    intro hp
    change (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0 at hp
    simp at hp
  have hB := hv hA hnp (natHist fun _ => 1)
    (by change (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 1; simp)
  rw [show PlusFormula.untl PlusFormula.top (PlusFormula.atom p)
      = someFuture (PlusFormula.atom p) from rfl, someFuture_iff] at hB
  obtain ⟨s, _, hat⟩ := hB
  change (1 : ℕ) = 0 at hat
  exact one_ne_zero hat

end FormalSystem.Metalogic.Decidability

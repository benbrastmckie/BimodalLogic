import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.PointTransport

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics FormalSystem.Semantics.PointTransport

variable (p : Atom)

-- (a) per-language head
example : PlusTruthAt natModel (natHist fun _ => 0) 0 (allFuture (.stab (.atom p))) := by
  rw [PlusTruth.allFuture_iff]
  intro y _ ρ hs
  exact hs.symm

-- (b1) generic head, per-language lemma by rw
example : TruthEnv.T natModel (natHist fun _ => 0) (0:ℤ) PUnit.unit (allFuture (PlusFormula.stab (.atom p))) := by
  rw [PlusTruth.allFuture_iff]
  intro y _ ρ hs
  exact hs.symm

-- (b2) generic head, generic lemma by rw
example : TruthEnv.T natModel (natHist fun _ => 0) (0:ℤ) PUnit.unit (allFuture (PlusFormula.stab (.atom p))) := by
  rw [TruthClauses.allFuture_iff]
  intro y _ ρ hs
  exact hs.symm

-- (b3) generic head, generic lemma by apply
example : TruthEnv.T natModel (natHist fun _ => 0) (0:ℤ) PUnit.unit (allFuture (PlusFormula.stab (.atom p))) := by
  apply (TruthClauses.allFuture_iff _ _ _ _ _).mpr
  intro y _
  trace_state
  apply (StabClause.stab_clause _ _ _ _ _).mpr
  intro ρ hs
  trace_state
  apply (AtomClause.atom_clause _ _ _ _ _).mpr
  exact hs.symm

-- (b4) generic head, per-language lemma by apply
example : TruthEnv.T natModel (natHist fun _ => 0) (0:ℤ) PUnit.unit (allFuture (PlusFormula.stab (.atom p))) := by
  apply (PlusTruth.allFuture_iff _ _ _ _).mpr
  intro y _ ρ hs
  exact hs.symm

-- (c1) At head, generic lemma by rw
example : At natModel (⟨natHist fun _ => 0, (0:ℤ), PUnit.unit⟩ : Point PlusFormula NF) (allFuture (PlusFormula.stab (.atom p))) := by
  rw [TruthClauses.allFuture_iff]
  intro y _ ρ hs
  exact hs.symm

-- (c2) At head, generic lemma by apply
example : At natModel (⟨natHist fun _ => 0, (0:ℤ), PUnit.unit⟩ : Point PlusFormula NF) (allFuture (PlusFormula.stab (.atom p))) := by
  apply (TruthClauses.allFuture_iff _ _ _ _ _).mpr
  intro y _
  trace_state
  apply (StabClause.stab_clause _ _ _ _ _).mpr
  intro ρ hs
  exact hs.symm

-- (c3) At head, simp only three-lemma idiom
example : At natModel (⟨natHist fun _ => 0, (0:ℤ), PUnit.unit⟩ : Point PlusFormula NF) (allFuture (PlusFormula.stab (.atom p))) := by
  simp only [at_def, TruthEnv.T, PlusTruth.allFuture_iff]
  trace_state
  intro y _ ρ hs
  exact hs.symm

-- (c4) At head, simp only with generic clause
example : At natModel (⟨natHist fun _ => 0, (0:ℤ), PUnit.unit⟩ : Point PlusFormula NF) (allFuture (PlusFormula.stab (.atom p))) := by
  simp only [at_def, TruthClauses.allFuture_iff]
  trace_state
  intro y _ ρ hs
  exact hs.symm

-- (a2) per-language head, generic lemma by apply
example : PlusTruthAt natModel (natHist fun _ => 0) 0 (allFuture (.stab (.atom p))) := by
  apply (TruthClauses.allFuture_iff (L := PlusFormula) _ _ _ PUnit.unit _).mpr
  intro y _
  trace_state
  intro ρ hs
  exact hs.symm

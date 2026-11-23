import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.StarLanguage.StarNonValidities
import FormalSystem.Semantics.PointTransport

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.StarLanguage
open FormalSystem.Semantics

namespace Dir
variable {L : Type} [TruthEnv L] {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
  {t : F.Duration} {e : TruthEnv.Env L F}

theorem atom_true [AtomClause L] {p : Atom} (h : M.valuation (τ.state t) p) :
    TruthEnv.T M τ t e (AtomClause.atom p : L) := (AtomClause.atom_clause M τ t e p).mpr h
theorem atom_false [AtomClause L] {p : Atom} (h : ¬ M.valuation (τ.state t) p) :
    ¬ TruthEnv.T M τ t e (AtomClause.atom p : L) :=
  fun h' => h ((AtomClause.atom_clause M τ t e p).mp h')
theorem imp_true [ImpClause L] {φ ψ : L} (h : TruthEnv.T M τ t e φ → TruthEnv.T M τ t e ψ) :
    TruthEnv.T M τ t e (ImpClause.imp φ ψ) := (ImpClause.imp_clause M τ t e φ ψ).mpr h
theorem imp_false [ImpClause L] {φ ψ : L} (h₁ : TruthEnv.T M τ t e φ)
    (h₂ : ¬ TruthEnv.T M τ t e ψ) : ¬ TruthEnv.T M τ t e (ImpClause.imp φ ψ) :=
  fun h => h₂ ((ImpClause.imp_clause M τ t e φ ψ).mp h h₁)
theorem box_true [BoxClause L] {φ : L} (h : ∀ σ : WorldHistory F, TruthEnv.T M σ t e φ) :
    TruthEnv.T M τ t e (BoxClause.box φ) := (BoxClause.box_clause M τ t e φ).mpr h
theorem box_false [BoxClause L] {φ : L} (σ : WorldHistory F) (h : ¬ TruthEnv.T M σ t e φ) :
    ¬ TruthEnv.T M τ t e (BoxClause.box φ) :=
  fun h' => h ((BoxClause.box_clause M τ t e φ).mp h' σ)
theorem stab_true [StabClause L] {φ : L}
    (h : ∀ σ : WorldHistory F, τ.state t = σ.state t → TruthEnv.T M σ t e φ) :
    TruthEnv.T M τ t e (StabClause.stab φ) := (StabClause.stab_clause M τ t e φ).mpr h
theorem stab_false [StabClause L] {φ : L} (σ : WorldHistory F) (hs : τ.state t = σ.state t)
    (h : ¬ TruthEnv.T M σ t e φ) : ¬ TruthEnv.T M τ t e (StabClause.stab φ) :=
  fun h' => h ((StabClause.stab_clause M τ t e φ).mp h' σ hs)
section
variable [BotClause L] [ImpClause L]
theorem allFuture_true [UntlClause L] {φ : L} (h : ∀ s, t < s → TruthEnv.T M τ s e φ) :
    TruthEnv.T M τ t e (TruthClauses.allFuture φ) := (TruthClauses.allFuture_iff M τ t e φ).mpr h
theorem allFuture_false [UntlClause L] {φ : L} (s : F.Duration) (hts : t < s)
    (h : ¬ TruthEnv.T M τ s e φ) : ¬ TruthEnv.T M τ t e (TruthClauses.allFuture φ) :=
  fun h' => h ((TruthClauses.allFuture_iff M τ t e φ).mp h' s hts)
theorem somePast_true [SnceClause L] {φ : L} (s : F.Duration) (hst : s < t)
    (h : TruthEnv.T M τ s e φ) : TruthEnv.T M τ t e (TruthClauses.somePast φ) :=
  (TruthClauses.somePast_iff M τ t e φ).mpr ⟨s, hst, h⟩
theorem somePast_false [SnceClause L] {φ : L} (h : ∀ s, s < t → ¬ TruthEnv.T M τ s e φ) :
    ¬ TruthEnv.T M τ t e (TruthClauses.somePast φ) :=
  fun h' => let ⟨s, hst, hs⟩ := (TruthClauses.somePast_iff M τ t e φ).mp h'; h s hst hs
end
theorem recall_true {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    {v : ℕ → F.Duration} {φ : StarFormula} (i : ℕ) (h : TruthEnv.T M τ (v i) v φ) :
    TruthEnv.T M τ t v (StarFormula.timeRecall i φ) := h
end Dir

open Dir

/-! Client 1: lemmas-only, directional, term mode. -/
theorem r1 (p : Atom) :
    ¬ PlusValid (.imp (PlusFormula.allFuture (.stab (.atom p)))
      (.stab (PlusFormula.allFuture (.atom p)))) := fun h =>
  stab_false (L := PlusFormula) (e := PUnit.unit)
    (natHist fun s => if s = 1 then 1 else 0)
    (by show (0 : ℕ) = (if (0 : ℤ) = 1 then 1 else 0); simp)
    (allFuture_false (1 : ℤ) (one_pos : (0 : ℤ) < 1)
      (atom_false (by show ¬ (if (1 : ℤ) = 1 then (1 : ℕ) else 0) = 0; simp)))
    (h.apply NF natModel (natHist fun _ => 0) 0
      (allFuture_true (L := PlusFormula) (e := PUnit.unit)
        fun _ _ => stab_true fun _ hs => atom_true hs.symm))

/-! Client 3: three clause layers. -/
theorem r3 (p : Atom) :
    ¬ PlusValid (.imp (.stab (PlusFormula.allFuture (PlusFormula.somePast (.atom p))))
        (PlusFormula.allFuture (.stab (PlusFormula.somePast (.atom p))))) := fun h =>
  allFuture_false (L := PlusFormula) (e := PUnit.unit) (1 : ℤ) (one_pos : (0 : ℤ) < 1)
    (stab_false (natHist fun s => if s = 1 then 0 else 1)
      (by show (0 : ℕ) = (if (1 : ℤ) = 1 then 0 else 1); simp)
      (somePast_false fun s hs1 => atom_false (by
        show ¬ (if (s : ℤ) = 1 then (0 : ℕ) else 1) = 0
        rw [if_neg (ne_of_lt hs1)]; exact one_ne_zero)))
    (h.apply NF natModel (natHist fun _ => 0) 0
      (stab_true (L := PlusFormula) (e := PUnit.unit) fun _ hs =>
        allFuture_true fun _ hy => somePast_true 0 hy (atom_true hs.symm)))

/-! Client 2: L⋆, recall has no generic clause class. -/
theorem r2 (p : Atom) :
    ¬ NF.StarValidOn
      ((StarFormula.box (mfWitness p)).imp
        (StarFormula.box (StarFormula.allFuture (mfWitness p)))) := fun h =>
  box_false (L := StarFormula) (e := fun _ => (0 : ℤ))
    (natHist fun s => if s ≤ 0 then 0 else 1)
    (allFuture_false (1 : ℤ) (one_pos : (0 : ℤ) < 1)
      (imp_false
        (recall_true 1
          (atom_true (by show (if (0 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0; simp)))
        (atom_false (by show ¬ (if (1 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0; simp))))
    (h natModel (natHist fun _ => 0) (0 : ℤ) (fun _ => (0 : ℤ))
      (box_true (L := StarFormula) fun _ => imp_true fun hrec => hrec))

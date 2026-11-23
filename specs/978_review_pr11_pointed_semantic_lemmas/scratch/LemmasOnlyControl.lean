/-
Scratch: the "lemmas-only control" probe records/proof-mode-architecture.md asks for, run on
`FormalSystem.PlusLanguage.refute_allFuture_stab` (`G⊡p → ⊡Gp`) with PR #11's lemmas available.
Not part of the library.
-/
import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.PointTransport
import FormalSystem.Semantics.TemporalRules

namespace Scratch

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula FormalSystem.PlusLanguage.PlusTruth
open FormalSystem.Semantics.PointTransport

/-! ## A. Baseline: the proof in the tree, restated verbatim (12 tactic lines). -/

theorem baseline (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (allFuture (.stab (.atom p))) := by
    rw [allFuture_iff]
    intro y _ ρ hs
    exact hs.symm
  have hB := hv hA (natHist fun s => if s = 1 then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) = 1 then 1 else 0); simp)
  rw [allFuture_iff] at hB
  have hat := hB (1 : ℤ) (one_pos : (0 : ℤ) < 1)
  rw [atom_iff] at hat
  have v' : (if (1 : ℤ) = 1 then (1 : ℕ) else 0) = 0 := hat
  simp at v'

/-! ## B. Probe: is `At`/`Point` usable as the statement vehicle here? -/

/-- The source point and the alternative point of the refutation, as `Point`s. -/
def p0 : Point PlusFormula NF := ⟨natHist fun _ => 0, 0, PUnit.unit⟩
def p1 : Point PlusFormula NF := ⟨natHist fun s => if s = 1 then 1 else 0, 0, PUnit.unit⟩

/-- The two points do satisfy `SameStateNow`, so the certificate relation is available. -/
theorem p0_p1_sameStateNow : SameStateNow p0 p1 := by
  refine ⟨rfl, ?_⟩
  change (0 : ℕ) = (if (0 : ℤ) = 1 then 1 else 0)
  simp

/-- `At` restates `PlusTruthAt` with no `show`: the vehicle is free. -/
theorem at_is_plusTruthAt (φ : PlusFormula) :
    At natModel p0 φ = PlusTruthAt natModel (natHist fun _ => 0) 0 φ := rfl

/-! ## C. The same refutation written with `At` and the strongest applicable certificate. -/

theorem with_pr11_lemmas (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel p0.history p0.time
  have hA : At natModel p0 (allFuture (.stab (.atom p))) := by
    rw [show At natModel p0 (allFuture (.stab (.atom p)))
        = PlusTruthAt natModel p0.history p0.time (allFuture (.stab (.atom p))) from rfl,
      allFuture_iff]
    intro y _ ρ hs
    exact hs.symm
  -- `plus_iffTransport_stab` moves `⊡Gp` from `p0` to `p1` along `SameState`, but the
  -- refutation needs the `⊡` ELIMINATED at `p1`, which no certificate in the PR supplies.
  have hStab : At natModel p1 (.stab (allFuture (.atom p))) :=
    (plus_iffTransport_stab natModel (allFuture (.atom p))).apply
      (show SameState p0 p1 from p0_p1_sameStateNow.2) |>.mp (hv hA)
  -- Elimination is still by hand, exactly as in the baseline.
  have hB := hStab p1.history (rfl : p1.history.state p1.time = p1.history.state p1.time)
  rw [allFuture_iff] at hB
  have hat := hB (1 : ℤ) (one_pos : (0 : ℤ) < 1)
  rw [atom_iff] at hat
  have v' : (if (1 : ℤ) = 1 then (1 : ℕ) else 0) = 0 := hat
  simp at v'

end Scratch

namespace Tight
open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula FormalSystem.PlusLanguage.PlusTruth
open FormalSystem.Semantics.PointTransport

/-! ## D. Tightest version I could reach using PR #11's lemmas. -/

theorem tightest (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  intro h
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (allFuture (.stab (.atom p))) := by
    rw [allFuture_iff]; intro y _ ρ hs; exact hs.symm
  have hStab : At natModel Scratch.p1 (.stab (allFuture (.atom p))) :=
    ((plus_iffTransport_stab natModel (allFuture (.atom p))).apply
      (show SameState Scratch.p0 Scratch.p1 from Scratch.p0_p1_sameStateNow.2)).mp
      (h.apply NF natModel (natHist fun _ => 0) 0 hA)
  have hB := hStab Scratch.p1.history rfl
  rw [allFuture_iff] at hB
  have v' : (if (1 : ℤ) = 1 then (1 : ℕ) else 0) = 0 :=
    (atom_iff (M := natModel) (τ := Scratch.p1.history) (t := (1 : ℤ)) p).mp
      (hB (1 : ℤ) (one_pos : (0 : ℤ) < 1))
  simp at v'

end Tight

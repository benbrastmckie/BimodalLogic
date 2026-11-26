/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve, Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PointTransport

/-! Tests for composing distinct pointed truth judgments through explicit relations. -/

namespace BimodalTest.Semantics

open FormalSystem.Semantics FormalSystem.Semantics.PointTransport
open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.StarLanguage

variable {F : TaskFrame} {M : TaskModel F}

example {p q : Point Formula F} (A : Formula) :
    At M q (A.box.box) → At M p (A.box.box) := by
  intro hq
  exact ((iffTransport_box M A.box).goal).reduce trivial hq

example {p q r : Point Formula F} (A : Formula) (h : At M p A.box) :
    At M r A.box :=
  ((iffTransport_box M A).fact.trans (iffTransport_box M A).fact).apply
    ⟨q, trivial, trivial⟩ h

-- Use a clause lemma after exposing the evaluation point, without spelling out its fields.
example (p : Point PlusFormula F) (A : PlusFormula)
    (h : ∀ s, p.time < s → PlusTruthAt M p.history s A) : At M p A.allFuture := by
  simp only [at_def, TruthEnv.T, PlusTruth.allFuture_iff]
  exact h

example {F' : TaskFrame} {M' : TaskModel F'} (I : TruthCorr M M') (A : Formula)
    (p : Point Formula F) (q : Point Formula F') (h : CorrRel I p q) :
    At M p A ↔ At M' q A :=
  (iffTransport_truthCorr I A).apply h

example (Δ : F.Duration) (A : Formula) (p q : Point Formula F) (h : Shifted Δ p q)
    (hA : At M p A) : At M q A :=
  (iffTransport_timeShift M Δ A).fact.apply h hA

example (A : Formula) (p : Point Formula F) (q : Point Formula F.rev)
    (h : Reflected p q) : At M p A ↔ At M.rev q A.reflectTime :=
  (iffTransport_rev M A).apply h

example (A : PlusFormula) (p q : Point PlusFormula F) (h : SameState p q) :
    At M p A.stab ↔ At M q A.stab :=
  (plus_iffTransport_stab M A).apply h

example (A : PlusFormula) (hA : A.StateLocal) (p q : Point PlusFormula F)
    (h : SameStateNow p q) : At M p A ↔ At M q A :=
  (plus_iffTransport_stateLocal hA M).apply h

-- The L⋆ environment carries the stored-time vector, so the time-shift certificate is indexed by
-- the env-aware `ShiftedEnv`. Both the `(L := StarFormula)` ascription and the explicit vector
-- type on the shift are load-bearing at this call site.
example (σ : WorldHistory F) (t Δ : F.Duration) (regs : ℕ → F.Duration) (A : StarFormula)
    (hA : At M (⟨σ.timeShift Δ, t, regs⟩ : Point StarFormula F) A) :
    At M (⟨σ, t + Δ, fun i => regs i + Δ⟩ : Point StarFormula F) A :=
  (star_iffTransport_timeShift M Δ A).fact.apply
    (ShiftedEnv.intro (L := StarFormula) σ t Δ (fun (v : ℕ → F.Duration) i => v i + Δ) regs) hA

-- State locality at L⋆ needs the vector to agree as well as the state, hence `SameStateNowEnv`.
example (τ σ : WorldHistory F) (t : F.Duration) (regs : ℕ → F.Duration) (A : StarFormula)
    (hA : A.StateLocal) (h : τ.state t = σ.state t) :
    At M (⟨τ, t, regs⟩ : Point StarFormula F) A ↔ At M (⟨σ, t, regs⟩ : Point StarFormula F) A :=
  (star_iffTransport_stateLocal hA M).apply (SameStateNowEnv.intro (L := StarFormula) τ σ t h)

example {D : TemporalOrder} {F' F : FrameOver D} (g : HistMorphism F' F)
    (M : TaskModel F.toTaskFrame) (A : PlusFormula) (p : Point PlusFormula F'.toTaskFrame)
    (q : Point PlusFormula F.toTaskFrame) (h : MorphRel g p q) :
    At (g.pullM M) p A ↔ At M q A :=
  (plus_iffTransport_histMorphism g M A).apply h

end BimodalTest.Semantics

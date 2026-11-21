/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.TruthClauses
import FormalSystem.Semantics.TruthTransport
import FormalSystem.Semantics.Reversal
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.PlusLanguage.PlusReversal
import FormalSystem.PlusLanguage.PlusStateLocal

/-!
# Transport between pointed truth judgments

A point binds a history, time and evaluation environment at a frame. A fact certificate transfers
truth forward along its stated relation, and a goal certificate transfers it backward. Theorem
factories retain the hypotheses of the corresponding semantic transfer results for state locality,
shifts, reflection and history morphisms.
-/

assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.Derivable
  FormalSystem.PlusLanguage.PlusDerivationTree

namespace FormalSystem.Semantics.PointTransport

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/-- A point of evaluation: a typed world history, a time and the inert environment. -/
structure Point (L : Type) [TruthEnv L] (F : TaskFrame) where
  /-- The world history. -/
  history : WorldHistory F
  /-- The evaluation time. -/
  time : F.Duration
  /-- The inert environment (`PUnit.unit` for TM/TM⁺). -/
  env : TruthEnv.Env L F

section Pointed
variable {L : Type} [TruthEnv L] {F : TaskFrame}

/-- The existing truth relation at a point. -/
abbrev At (M : TaskModel F) (p : Point L F) (A : L) : Prop :=
  TruthEnv.T M p.history p.time p.env A

end Pointed

section Transport
variable {L L' L'' : Type} [TruthEnv L] [TruthEnv L'] [TruthEnv L'']
  {F F' F'' : TaskFrame}

/-- `R p q → At M p A → At M' q B`. -/
def FactTransport (R : Point L F → Point L' F' → Prop) (M : TaskModel F) (M' : TaskModel F')
    (A : L) (B : L') : Prop :=
  ∀ p q, R p q → At M p A → At M' q B

/-- `R p q → At M' q B → At M p A`: proving the target at `q` proves the source goal at `p`. -/
def GoalTransport (R : Point L F → Point L' F' → Prop) (M : TaskModel F) (M' : TaskModel F')
    (A : L) (B : L') : Prop :=
  ∀ p q, R p q → At M' q B → At M p A

variable {R : Point L F → Point L' F' → Prop} {M : TaskModel F} {M' : TaskModel F'}
  {A : L} {B : L'}

/-- Move a fact along a fact certificate. -/
theorem FactTransport.apply (h : FactTransport R M M' A B) {p : Point L F} {q : Point L' F'}
    (hR : R p q) (hA : At M p A) : At M' q B :=
  h p q hR hA

/-- Reduce a goal along a goal certificate. -/
theorem GoalTransport.reduce (h : GoalTransport R M M' A B) {p : Point L F} {q : Point L' F'}
    (hR : R p q) (hB : At M' q B) : At M p A :=
  h p q hR hB

/-- A pointwise `Iff` certificate supplies both directions. -/
theorem FactTransport.ofIff (h : ∀ p q, R p q → (At M p A ↔ At M' q B)) :
    FactTransport R M M' A B :=
  fun p q hR => (h p q hR).mp

/-- A pointwise `Iff` certificate supplies both directions. -/
theorem GoalTransport.ofIff (h : ∀ p q, R p q → (At M p A ↔ At M' q B)) :
    GoalTransport R M M' A B :=
  fun p q hR => (h p q hR).mpr

/-- Chain fact certificates through an intermediate judgment. -/
theorem FactTransport.trans {R' : Point L' F' → Point L'' F'' → Prop} {M'' : TaskModel F''}
    {C : L''} (h₁ : FactTransport R M M' A B) (h₂ : FactTransport R' M' M'' B C) :
    FactTransport (fun p r => ∃ q, R p q ∧ R' q r) M M'' A C :=
  fun p r ⟨q, hpq, hqr⟩ hA => h₂ q r hqr (h₁ p q hpq hA)

/-- Chain goal certificates through an intermediate judgment. -/
theorem GoalTransport.trans {R' : Point L' F' → Point L'' F'' → Prop} {M'' : TaskModel F''}
    {C : L''} (h₁ : GoalTransport R M M' A B) (h₂ : GoalTransport R' M' M'' B C) :
    GoalTransport (fun p r => ∃ q, R p q ∧ R' q r) M M'' A C :=
  fun p r ⟨q, hpq, hqr⟩ hC => h₁ p q hpq (h₂ q r hqr hC)

end Transport

/-! ## Two-way certificates -/

section Iff
variable {L L' : Type} [TruthEnv L] [TruthEnv L'] {F F' : TaskFrame}

/-- `R p q → (At M p A ↔ At M' q B)`: a certificate valid in both directions. -/
def IffTransport (R : Point L F → Point L' F' → Prop) (M : TaskModel F) (M' : TaskModel F')
    (A : L) (B : L') : Prop :=
  ∀ p q, R p q → (At M p A ↔ At M' q B)

variable {R : Point L F → Point L' F' → Prop} {M : TaskModel F} {M' : TaskModel F'}
  {A : L} {B : L'}

/-- The equivalence at one related pair of points. -/
theorem IffTransport.apply (h : IffTransport R M M' A B) {p : Point L F} {q : Point L' F'}
    (hR : R p q) : At M p A ↔ At M' q B :=
  h p q hR

/-- The fact direction of an equivalence certificate. -/
theorem IffTransport.fact (h : IffTransport R M M' A B) : FactTransport R M M' A B :=
  FactTransport.ofIff h

/-- The goal direction of an equivalence certificate. -/
theorem IffTransport.goal (h : IffTransport R M M' A B) : GoalTransport R M M' A B :=
  GoalTransport.ofIff h

/-- The converse certificate, along the converse relation. -/
theorem IffTransport.symm (h : IffTransport R M M' A B) :
    IffTransport (fun q p => R p q) M' M B A :=
  fun q p hR => (h p q hR).symm

end Iff

/-! ## Point relations -/

section Relations
variable {L L' : Type} [TruthEnv L] [TruthEnv L'] {F : TaskFrame}

/-- Same time and same current world state. -/
def SameStateNow (p q : Point L F) : Prop :=
  p.time = q.time ∧ p.history.state p.time = q.history.state q.time

/-- `SameStateNow` at explicit points. -/
theorem SameStateNow.intro (τ σ : WorldHistory F) (t : F.Duration) {e e' : TruthEnv.Env L F}
    (h : τ.state t = σ.state t) : SameStateNow (⟨τ, t, e⟩ : Point L F) ⟨σ, t, e'⟩ :=
  ⟨rfl, h⟩

/-- Same world state, possibly at different times. -/
def SameState (p q : Point L F) : Prop :=
  p.history.state p.time = q.history.state q.time

/-- `SameState` at explicit points. -/
theorem SameState.intro (τ σ : WorldHistory F) (t s : F.Duration) {e e' : TruthEnv.Env L F}
    (h : τ.state t = σ.state s) : SameState (⟨τ, t, e⟩ : Point L F) ⟨σ, s, e'⟩ :=
  h

/-- Any two points of the frame. -/
def AnyPoint (_p _q : Point L F) : Prop := True

/-- `AnyPoint` at explicit points. -/
theorem AnyPoint.intro (τ σ : WorldHistory F) (t s : F.Duration) {e e' : TruthEnv.Env L F} :
    AnyPoint (⟨τ, t, e⟩ : Point L F) ⟨σ, s, e'⟩ :=
  trivial

/-- `p` is the `Δ`-shift of `q`: `p = (q.history.timeShift Δ, t)` and `q.time = t + Δ`. -/
def Shifted (Δ : F.Duration) (p q : Point L F) : Prop :=
  p.history = q.history.timeShift Δ ∧ q.time = p.time + Δ

/-- `Shifted` at explicit points. -/
theorem Shifted.intro (σ : WorldHistory F) (t Δ : F.Duration) {e e' : TruthEnv.Env L F} :
    Shifted Δ (⟨σ.timeShift Δ, t, e⟩ : Point L F) ⟨σ, t + Δ, e'⟩ :=
  ⟨rfl, rfl⟩

/-- `q` is the reflected point of the converse frame: reflected history, negated time. -/
def Reflected (p : Point L F) (q : Point L' F.rev) : Prop :=
  q.history = p.history.rev ∧ q.time = -p.time

/-- `Reflected` at explicit points. -/
theorem Reflected.intro (τ : WorldHistory F) (t : F.Duration) {e : TruthEnv.Env L F}
    {e' : TruthEnv.Env L' F.rev} :
    Reflected (⟨τ, t, e⟩ : Point L F) (⟨τ.rev, -t, e'⟩ : Point L' F.rev) :=
  ⟨rfl, rfl⟩

end Relations

section TMRelations
variable {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}

/-- Points related by a TM `TruthCorr`: related histories, reindexed time. -/
def CorrRel (I : TruthCorr M M') (p : Point Formula F) (q : Point Formula F') : Prop :=
  I.Rel p.history q.history ∧ q.time = I.dur p.time

/-- `CorrRel` at explicit points. -/
theorem CorrRel.intro (I : TruthCorr M M') {σ : WorldHistory F} {σ' : WorldHistory F'}
    (h : I.Rel σ σ') (t : F.Duration) {e e'} :
    CorrRel I (⟨σ, t, e⟩ : Point Formula F) ⟨σ', I.dur t, e'⟩ :=
  ⟨h, rfl⟩

/-- Points related by a TM `TruthIso`. -/
def IsoRel (I : TruthIso M M') (p : Point Formula F) (q : Point Formula F') : Prop :=
  q.history = I.hist p.history ∧ q.time = I.dur p.time

/-- `IsoRel` at explicit points. -/
theorem IsoRel.intro (I : TruthIso M M') (σ : WorldHistory F) (t : F.Duration) {e e'} :
    IsoRel I (⟨σ, t, e⟩ : Point Formula F) ⟨I.hist σ, I.dur t, e'⟩ :=
  ⟨rfl, rfl⟩

/-- Points related by a TM `TruthAntiIso`. -/
def AntiIsoRel (I : TruthAntiIso M M') (p : Point Formula F) (q : Point Formula F') : Prop :=
  q.history = I.hist p.history ∧ q.time = I.dur p.time

/-- `AntiIsoRel` at explicit points. -/
theorem AntiIsoRel.intro (I : TruthAntiIso M M') (σ : WorldHistory F) (t : F.Duration) {e e'} :
    AntiIsoRel I (⟨σ, t, e⟩ : Point Formula F) ⟨I.hist σ, I.dur t, e'⟩ :=
  ⟨rfl, rfl⟩

end TMRelations

section MorphRelation
variable {D : TemporalOrder} {F' F : FrameOver D}

/-- Points related by a history-lifting map: the image history at the same time. -/
def MorphRel (g : HistMorphism F' F) (p : Point PlusFormula F'.toTaskFrame)
    (q : Point PlusFormula F.toTaskFrame) : Prop :=
  q.history = g.mapH p.history ∧ q.time = p.time

/-- `MorphRel` at explicit points. -/
theorem MorphRel.intro (g : HistMorphism F' F) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D)
    {e e'} : MorphRel g (⟨τ', t, e⟩ : Point PlusFormula F'.toTaskFrame) ⟨g.mapH τ', t, e'⟩ :=
  ⟨rfl, rfl⟩

end MorphRelation

/-! ## TM factories -/

section TM
variable {F F' : TaskFrame}

/-- `Truth.truthAt_of_truthCorr` as a certificate. -/
theorem iffTransport_truthCorr {M : TaskModel F} {M' : TaskModel F'} (I : TruthCorr M M')
    (φ : Formula) : IffTransport (CorrRel I) M M' φ φ := by
  rintro ⟨σ, t, _⟩ ⟨σ', s, _⟩ ⟨h, hs⟩
  dsimp only at h hs
  subst hs
  exact Truth.truthAt_of_truthCorr I φ σ σ' h t

/-- `Truth.truthAt_of_truthIso` as a certificate. -/
theorem iffTransport_truthIso {M : TaskModel F} {M' : TaskModel F'} (I : TruthIso M M')
    (φ : Formula) : IffTransport (IsoRel I) M M' φ φ := by
  rintro ⟨σ, t, _⟩ ⟨σ', s, _⟩ ⟨hσ, hs⟩
  dsimp only at hσ hs
  subst hσ hs
  exact Truth.truthAt_of_truthIso I φ σ t

/-- `Truth.truthAt_of_truthAntiIso` as a certificate; the target formula is reflected. -/
theorem iffTransport_truthAntiIso {M : TaskModel F} {M' : TaskModel F'} (I : TruthAntiIso M M')
    (φ : Formula) : IffTransport (AntiIsoRel I) M M' φ φ.reflectTime := by
  rintro ⟨σ, t, _⟩ ⟨σ', s, _⟩ ⟨hσ, hs⟩
  dsimp only at hσ hs
  subst hσ hs
  exact Truth.truthAt_of_truthAntiIso I φ σ t

/-- TM time shift, from `TimeShift.shiftCorr`: truth at `(σ.timeShift Δ, t)` is truth at
`(σ, t + Δ)`. History and time move together. -/
theorem iffTransport_timeShift (M : TaskModel F) (Δ : F.Duration) (φ : Formula) :
    IffTransport (Shifted Δ) M M φ φ := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ ⟨hτ, hs⟩
  dsimp only at hτ hs
  subst hτ hs
  exact Truth.truthAt_of_truthCorr (TimeShift.shiftCorr M Δ) φ (σ.timeShift Δ) σ
    (TimeShift.shiftRel_timeShift Δ σ) t

/-- `truthAt_rev` as a certificate: converse frame, reflected model, history, time and formula. -/
theorem iffTransport_rev (M : TaskModel F) (φ : Formula) :
    IffTransport (Reflected (L := Formula) (L' := Formula)) M M.rev φ φ.reflectTime := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ ⟨hσ, hs⟩
  dsimp only at hσ hs
  subst hσ hs
  exact truthAt_rev M τ t φ

/-- `Truth.box_const`: a boxed TM formula has one truth value in the model. -/
theorem iffTransport_box (M : TaskModel F) (φ : Formula) :
    IffTransport (AnyPoint (L := Formula)) M M φ.box φ.box := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ _
  exact Truth.box_const M τ σ t s φ

end TM

/-! ## TM⁺ factories -/

section Plus
variable {F : TaskFrame}

/-- `plusTruthAt_timeShift` as a certificate. -/
theorem plus_iffTransport_timeShift (M : TaskModel F) (Δ : F.Duration) (φ : PlusFormula) :
    IffTransport (Shifted Δ) M M φ φ := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ ⟨hτ, hs⟩
  dsimp only at hτ hs
  subst hτ hs
  exact plusTruthAt_timeShift M φ σ t Δ

/-- `plusTruthAt_rev` as a certificate: converse frame, reflected model, history, time and
formula. -/
theorem plus_iffTransport_rev (M : TaskModel F) (φ : PlusFormula) :
    IffTransport (Reflected (L := PlusFormula) (L' := PlusFormula)) M M.rev φ φ.reflectTime := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ ⟨hσ, hs⟩
  dsimp only at hσ hs
  subst hσ hs
  exact plusTruthAt_rev M τ t φ

/-- `box_global`: a boxed TM⁺ formula has one truth value in the model. -/
theorem plus_iffTransport_box (M : TaskModel F) (φ : PlusFormula) :
    IffTransport (AnyPoint (L := PlusFormula)) M M (.box φ) (.box φ) := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ _
  exact box_global M τ σ t s φ

/-- `stab_state_only`: `⊡φ` depends on the world state alone, at any two times. -/
theorem plus_iffTransport_stab (M : TaskModel F) (φ : PlusFormula) :
    IffTransport (SameState (L := PlusFormula)) M M (.stab φ) (.stab φ) := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ h
  exact stab_state_only M τ σ t s h φ

/-- A formula in the syntactic state-local fragment transports between points with the same
time and current state (`isPlusStateLocal_of_stateLocal`). The fragment excludes `U`/`S`, so a
bare `F p` or `G p` is not covered. -/
theorem plus_iffTransport_stateLocal {φ : PlusFormula} (hφ : φ.StateLocal) (M : TaskModel F) :
    IffTransport (SameStateNow (L := PlusFormula)) M M φ φ := by
  rintro ⟨τ, t, _⟩ ⟨σ, s, _⟩ ⟨hs, h⟩
  dsimp only at hs h
  subst hs
  exact isPlusStateLocal_of_stateLocal hφ F M τ σ t h

/-- `plusStateLocal_stab_iff`: a state-local `φ` and `⊡φ` agree at the same point. -/
theorem plus_iffTransport_stateLocalStab {φ : PlusFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) : IffTransport (@Eq (Point PlusFormula F)) M M φ (.stab φ) := by
  rintro ⟨τ, t, _⟩ _ rfl
  exact plusStateLocal_stab_iff hφ M τ t

end Plus

section Morphism
variable {D : TemporalOrder} {F' F : FrameOver D}

/-- `HistMorphism.plus_invariance` as a certificate. The source model is exactly the pulled-back
model `g.pullM M`; the morphism carries its forth, lifting and onto conditions. -/
theorem plus_iffTransport_histMorphism (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame)
    (φ : PlusFormula) : IffTransport (MorphRel g) (g.pullM M) M φ φ := by
  rintro ⟨τ', t, _⟩ ⟨σ, s, _⟩ ⟨hσ, hs⟩
  dsimp only at hσ hs
  subst hσ hs
  exact g.plus_invariance M φ τ' _

end Morphism

end FormalSystem.Semantics.PointTransport

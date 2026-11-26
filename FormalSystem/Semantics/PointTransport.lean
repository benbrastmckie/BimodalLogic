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
import FormalSystem.StarLanguage.StarTruth
import FormalSystem.StarLanguage.StarStateLocal

/-!
# Transport between pointed truth judgments

A point binds a history, time and evaluation environment at a frame. A fact certificate transfers
truth forward along its stated relation, and a goal certificate transfers it backward. Theorem
factories retain the hypotheses of the corresponding semantic transfer results for state locality,
shifts, reflection and history morphisms.

## Main Results

- `FactTransport`, `GoalTransport`, `IffTransport` — the three certificate shapes, with `apply`,
  `reduce`, `ofIff`, `trans` and `symm`
- `SameStateNow`, `SameState`, `AnyPoint`, `Shifted`, `Reflected` — the point relations the
  certificates are indexed by, each with an `.intro` at explicit points
- `SameStateNowEnv`, `ShiftedEnv` — the env-aware strengthenings of `SameStateNow` and `Shifted`,
  also with `.intro`, needed wherever the evaluation environment carries information
- `CorrRel`, `IsoRel`, `AntiIsoRel`, `MorphRel` — the relations cut by a truth correspondence,
  isomorphism, anti-isomorphism and history morphism
- `iffTransport_truthCorr`, `iffTransport_truthIso`, `iffTransport_truthAntiIso`,
  `iffTransport_timeShift`, `iffTransport_rev`, `iffTransport_box` — the TM factories
- `plus_iffTransport_timeShift`, `plus_iffTransport_rev`, `plus_iffTransport_box`,
  `plus_iffTransport_stab`, `plus_iffTransport_stateLocal`, `plus_iffTransport_stateLocalStab`,
  `plus_iffTransport_histMorphism` — the TM⁺ factories
- `star_iffTransport_timeShift`, `star_iffTransport_stateLocal` — the TM⋆ factories, over the
  env-aware relations

## Why this module's lock is not the directory form

The locks across `FormalSystem/Semantics/` are rooted at `FormalSystem.ProofSystem.Axiom`. This
module cannot take that form: its own import closure already puts `Axiom` and `FrameClass` into
the environment, by the chain `FormalSystem.Semantics.HistoryMorphism →
FormalSystem.PlusLanguage.PlusValidity → FormalSystem.Semantics.Validity →
FormalSystem.Semantics.ValidityLayer → FormalSystem.Semantics.FrameClassValidity →
FormalSystem.ProofSystem.Axioms`. Naming `Axiom` in the lock here is therefore a compile error,
not a tightening. The lock is rooted at `FormalSystem.ProofSystem.DerivationTree` instead — the
strongest claim this module's closure actually admits — and names the per-language derivation
trees beside it — `FormalSystem.PlusLanguage.PlusDerivationTree` and, with the L⋆ imports the TM⋆
factories need, `FormalSystem.StarLanguage.StarDerivationTree`.
`FormalSystem.ProofSystem.Derivable` is implied and so not named:
`ProofSystem/Derivable.lean` imports `ProofSystem/Derivation.lean`, which declares
`DerivationTree`.

## References

* `FormalSystem/Semantics/TruthTransport.lean` — the semantic transfer results the TM factories
  wrap
* `FormalSystem/PlusLanguage/PlusStateLocal.lean` — `isPlusStateLocal_of_stateLocal`
* `FormalSystem/StarLanguage/StarTruth.lean` — `starTruthAt_timeShift`
* `FormalSystem/StarLanguage/StarStateLocal.lean` — `isStateLocal_of_stateLocal`
* `FormalSystem/Semantics/HistoryMorphism.lean` — `HistMorphism` and `pullM`
* `Tests/BimodalTest/Semantics/PointTransportTest.lean` — the per-relation test rows

## Tags

pointed-truth · transport · certificate · point-relation · state-locality · time-shift ·
reflection · history-morphism
-/

assert_not_exists FormalSystem.ProofSystem.DerivationTree
  FormalSystem.PlusLanguage.PlusDerivationTree FormalSystem.StarLanguage.StarDerivationTree

namespace FormalSystem.Semantics.PointTransport

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage

/-- A point of evaluation: a typed world history, a time and the evaluation environment. -/
structure Point (L : Type) [TruthEnv L] (F : TaskFrame) where
  /-- The world history. -/
  history : WorldHistory F
  /-- The evaluation time. -/
  time : F.Duration
  /-- The evaluation environment (`PUnit.unit` for TM/TM⁺). -/
  env : TruthEnv.Env L F

section Pointed
variable {L : Type} [TruthEnv L] {F : TaskFrame}

/-- The existing truth relation at a point. -/
abbrev At (M : TaskModel F) (p : Point L F) (A : L) : Prop :=
  TruthEnv.T M p.history p.time p.env A

/-- Expose the truth judgment behind a point. To use a concrete language clause, include
`TruthEnv.T` in the simp set to reduce the instance projection. -/
@[simp] theorem at_def (M : TaskModel F) (p : Point L F) (A : L) :
    At M p A ↔ TruthEnv.T M p.history p.time p.env A := Iff.rfl

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

/-- `SameStateNow` **together with equality of the evaluation environments.** `SameStateNow`
leaves `Point.env` unconstrained, which is harmless where the environment is `PUnit` (L, L⁺) and
wrong at a language whose environment carries information, such as L⋆'s stored-time vector. This
relation is added beside `SameStateNow` rather than replacing it: the weaker relation is what
`plus_iffTransport_stateLocal` consumes, and the strengthening is recovered from this one by
`.1`. -/
def SameStateNowEnv (p q : Point L F) : Prop :=
  SameStateNow p q ∧ p.env = q.env

/-- `SameStateNowEnv` at explicit points, sharing one environment. -/
theorem SameStateNowEnv.intro (τ σ : WorldHistory F) (t : F.Duration)
    {e : TruthEnv.Env L F} (h : τ.state t = σ.state t) :
    SameStateNowEnv (⟨τ, t, e⟩ : Point L F) ⟨σ, t, e⟩ :=
  ⟨⟨rfl, h⟩, rfl⟩

/-- `Shifted` **together with the matching shift of the evaluation environment**, given as an
explicit `shift`. As with `SameStateNowEnv`, this is added beside `Shifted` rather than replacing
it, so `plus_iffTransport_timeShift`'s two-environment signature is untouched; at L⋆ the shift is
`fun v i => v i + Δ` on the stored-time vector. -/
def ShiftedEnv (Δ : F.Duration) (shift : TruthEnv.Env L F → TruthEnv.Env L F)
    (p q : Point L F) : Prop :=
  Shifted Δ p q ∧ q.env = shift p.env

/-- `ShiftedEnv` at explicit points. -/
theorem ShiftedEnv.intro (σ : WorldHistory F) (t Δ : F.Duration)
    (shift : TruthEnv.Env L F → TruthEnv.Env L F) (e : TruthEnv.Env L F) :
    ShiftedEnv Δ shift (⟨σ.timeShift Δ, t, e⟩ : Point L F) ⟨σ, t + Δ, shift e⟩ :=
  ⟨⟨rfl, rfl⟩, rfl⟩

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

/-! ## TM⋆ factories -/

section Star
variable {F : TaskFrame}

/-- `starTruthAt_timeShift` as a certificate. The stored-time vector shifts with the time, so the
relation is the env-aware `ShiftedEnv` rather than `Shifted`: at L⋆ the environment carries
information, and leaving it unconstrained would make the statement false.

The `(L := StarFormula)` ascription on the relation is load-bearing. Without it the shift function
`fun v i => v i + Δ` has nothing to fix `v`'s type against, and elaboration fails with
`Function expected at v but this term has type TruthEnv.Env ?m F`. -/
theorem star_iffTransport_timeShift (M : TaskModel F) (Δ : F.Duration) (φ : StarFormula) :
    IffTransport (ShiftedEnv (L := StarFormula) Δ (fun v i => v i + Δ)) M M φ φ := by
  rintro ⟨τ, t, v⟩ ⟨σ, s, w⟩ ⟨⟨hτ, hs⟩, hw⟩
  dsimp only at hτ hs hw
  subst hτ hs hw
  exact starTruthAt_timeShift M φ σ t Δ v

/-- A formula in the syntactic state-local fragment transports between points with the same time,
the same current state and the same stored-time vector (`isStateLocal_of_stateLocal`). The
fragment excludes `U`/`S` and the register operators, so a bare `F p` or `G p` is not covered. -/
theorem star_iffTransport_stateLocal {φ : StarFormula} (hφ : φ.StateLocal) (M : TaskModel F) :
    IffTransport (SameStateNowEnv (L := StarFormula)) M M φ φ := by
  rintro ⟨τ, t, v⟩ ⟨σ, s, w⟩ ⟨⟨hs, h⟩, hw⟩
  dsimp only at hs h hw
  subst hs hw
  exact isStateLocal_of_stateLocal hφ F M τ σ t v h

end Star

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

/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Simplification
import FormalSystem.Automation.ProofMode.Discrete
import FormalSystem.Automation.ProofMode.Semantic
import FormalSystem.Semantics.ProofModeIntervals
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.LinearityDerived
import FormalSystem.Metalogic.Soundness

/-!
# Compositional proof-mode extension examples

One shared, mechanism-driven acceptance suite for the three implementation branches.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.LinearityDerived
open FormalSystem.Semantics

register_lrewrite FormalSystem.Theorems.ProofMode.doubleNegationIff

namespace BimodalTest.Automation.ProofModeExtensionsTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- The same opaque scoped statement supports fact rewriting and backward goal reconstruction.
example (mapping : Γ ⊢[fc] (A.imp B).allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).allFuture.box) :
    Γ ⊢[fc] ((B.or C).allFuture.box).and ((B.or C).allFuture.box) := by
  lsplit
  · lrewrite mapping at provider as mapped
    lexact mapped
  · fail_if_success lrewrite mapping
    lrewrite ← mapping
    lexact provider

-- Negative positions reverse implication direction. Explicit paths disambiguate repeated leaves.
example (mapping : Γ ⊢[fc] B.imp A) (provider : Γ ⊢[fc] A.imp C) : Γ ⊢[fc] B.imp C := by
  lrewrite ← mapping (path := [impLeft]) at provider as mapped
  lexact mapped

-- Current-point equivalence cannot enter a fresh world/time scope.
example (_localEq : Γ ⊢[fc] (A.imp B).and (B.imp A))
    (provider : Γ ⊢[fc] A.allFuture.box) : Γ ⊢[fc] A.allFuture.box := by
  fail_if_success lrewrite _localEq at provider as leaked
  lexact provider

-- Closed logical equivalences rewrite through conditional Next at Base without an existence gate.
example (provider : Γ ⊢ A.box.next.allFuture) : Γ ⊢ A.box.diamond.next.allFuture := by
  lrewrite (FormalSystem.Theorems.ModalS5.s5DiamondBox A)
  lexact provider

-- Scope replacement needs a real native proof and drops unused implicit premises of the old map.
example (_localMap : ∀ {_unavailable : False}, Γ ⊢[fc] A.imp B)
    (hScoped : Γ ⊢[fc] (A.imp B).box)
    (provider : Γ ⊢[fc] A.box) : Γ ⊢[fc] B.box := by
  lrewrite _localMap at provider as mapped (obligations := expose)
  · guard_target =ₛ Γ ⊢[fc] (A.imp B).box
    lexact hScoped
  · guard_hyp mapped :ₛ Γ ⊢[fc] B.box
    lexact mapped

-- Formula data equality casts only the conclusion, retaining the exact object context.
example (equality : A = B) (provider : Γ ⊢[fc] A.and A) : Γ ⊢[fc] B.and A := by
  fail_if_success lrewrite equality at provider as ambiguous
  lrewrite equality (path := [andLeft]) at provider as mapped
  lexact mapped

-- The exact same planner composes TM transfers and native stability at arbitrary Plus arguments.
example (Δ : FormalSystem.PlusLanguage.PlusContext)
    (P Q R : FormalSystem.PlusLanguage.PlusFormula)
    (mapping : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ
      ((P.imp Q).allFuture.stab.box))
    (provider : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ
      ((P.or R).allFuture.stab.box)) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc Δ ((Q.or R).allFuture.stab.box) := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- Simp reduces closed modal equivalences, skips growing orientations, and restores on exhaustion.
example (provider : Γ ⊢ A.box.next.allFuture) (boxes : Γ ⊢ (A.and B).box) :
    Γ ⊢ (A.box.and B.box).and A.box.diamond.next.allFuture := by
  lsplit
  · fail_if_success lsimp only [← FormalSystem.Theorems.ModalS5.boxConjIff]
    lsimp only [FormalSystem.Theorems.ModalS5.boxConjIff]
    lexact boxes
  · fail_if_success lsimp only [FormalSystem.Theorems.ModalS5.s5DiamondBox] (maxSteps := 0)
    lsimp only [FormalSystem.Theorems.ModalS5.s5DiamondBox]
    fail_if_success lsimp only [← FormalSystem.Theorems.ModalS5.s5DiamondBox]
    lexact provider

-- Concrete frame gates are checked, not exposed as impossible obligations or silently assumed.
example (base : Γ ⊢ A.allFuture.allFuture)
    (dense : Γ ⊢[FrameClass.Dense] A.allFuture.allFuture) :
    (Γ ⊢ A.allFuture.allFuture) × (Γ ⊢[FrameClass.Dense] A.allFuture) := by
  constructor
  · fail_if_success lrewrite density at base as collapsed (obligations := expose)
    lexact base
  · lrewrite density at dense as collapsed
    lexact collapsed

-- P0's explicit soundness seam retains an abstract Γ and every pointed semantic index.
example (F : TaskFrame) (hFrame : fc.Sat F) (M : TaskModel F)
    (history : WorldHistory F) (time : F.Duration) (proof : Γ ⊢[fc] A)
    (environment : ∀ P ∈ Γ, TruthAt M history time P) : TruthAt M history time A :=
  FormalSystem.Metalogic.soundness_in Γ A proof F hFrame M history time environment

-- P0's Base Since converse is genuinely derived by closed time reflection, without completeness.
def baseSinceFoldPrototype (g e : Formula) :
    ⊢ (e.prev.or (g.and (.snce g e)).prev).imp (.snce g e) := by
  have reflected := DerivationTree.time_reflection _
    (FormalSystem.Theorems.DiscreteUnfolding.unfoldBackward e.reflectTime g.reflectTime)
  simpa only [Formula.next, Formula.prev, Formula.or, Formula.and, Formula.neg,
    Formula.reflectTime, Formula.reflect_time_involution] using reflected

private def weakeningSchema (X Y : Formula) : ⊢[fc] X.imp (Y.imp X) :=
  .axiom [] _ (.prop_s X Y) (FrameClass.base_le fc)

private def implicitDensityRule {gate : FrameClass.Dense ≤ fc} (P : Formula) :
    ⊢[fc] P.allFuture.allFuture.imp P.allFuture :=
  density gate P

-- An unmatched data parameter is never guessed from the first Formula local in scope.
example (provider : Γ ⊢[fc] A) : Γ ⊢[fc] A := by
  fail_if_success lrewrite weakeningSchema at provider as guessed
  fail_if_success lrewrite weakeningSchema at provider as guessed (obligations := expose)
  lexact provider

-- Leading implicit premises inserted by term elaboration are genuine, atomic obligations.
example (frameProvider : True → FrameClass.Dense ≤ fc)
    (provider : Γ ⊢[fc] A.allFuture.allFuture) : Γ ⊢[fc] A.allFuture := by
  fail_if_success lrewrite implicitDensityRule at provider as untracked
  fail_if_success lsimp only [implicitDensityRule] at provider as untracked
  lrewrite implicitDensityRule at provider as mapped (obligations := expose)
  · exact frameProvider True.intro
  · lexact mapped

-- Run the fragile scope adapters and exact conditional Next in one compact product fixture.
example (boxMap : Γ ⊢ (A.imp B).box) (futureMap : Γ ⊢ (A.imp B).allFuture)
    (nextMap : Γ ⊢ (A.imp B).next) (future : Γ ⊢ A.allFuture)
    (futureFuture : Γ ⊢ A.allFuture.allFuture) (adjacent : Γ ⊢ A.next) :
    (Γ ⊢ B.allFuture) × (Γ ⊢ B.allFuture.allFuture) × (Γ ⊢ B.next) := by
  constructor
  · lrewrite boxMap at future as mapped
    lexact mapped
  constructor
  · lrewrite futureMap at futureFuture as mapped
    lexact mapped
  · lrewrite nextMap at adjacent as mapped
    lexact mapped

-- Boolean reduction and strict FFA→FA are independent, genuinely one-way proof steps.
example (provider : Γ ⊢ A.neg.neg.someFuture.someFuture) : Γ ⊢ A.someFuture := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff,
    FormalSystem.Theorems.ProofMode.futureCollapse] at provider as reduced
  lexact reduced

-- Occurrence selection precedes scope discharge: an inaccessible match is still ambiguous.
example (mapping : Γ ⊢ (A.imp B).allFuture) (provider : Γ ⊢ A.and A.allFuture) :
    Γ ⊢ A.and B.allFuture := by
  fail_if_success lrewrite mapping at provider as implicitChoice
  lrewrite mapping (path := [andRight, futureBody]) at provider as mapped
  lexact mapped

-- Fold is Base-valid; forward unfolding retains the explicit integer-time gate and both joins.
example (g e : Formula) (hZ : FrameClass.ZTime ≤ fc) :
    [Formula.untl g e] ⊢[fc] Formula.untl g e := by
  lstart h
  luntil unfold h as hEvent hContinue
  · luntil fold; lleft; lexact hEvent
  · luntil fold; lright; lexact hContinue

-- A false gate rejects atomically; a supplied fact remains usable after refusal.
example (provider : Γ ⊢[FrameClass.Dense] A.allFuture) :
    Γ ⊢[FrameClass.Dense] A.allFuture := by
  fail_if_success linduction using FormalSystem.Theorems.ProofMode.futureBackwardInduction
  lexact provider

-- Repeated advances compose opaque providers while retaining the second guarantee's scope.
example (pAB : [A.someFuture] ⊢ (A.imp B.someFuture).allFuture)
    (pBC : [A.someFuture] ⊢ (B.imp C.someFuture).allFuture) :
    [A.someFuture] ⊢ C.someFuture := by
  lstart hA
  ladvance hA using [pAB] keeping [pBC] as hA hAB hBC
  lhave hB : B.someFuture
  · lapply hAB; lexact hA
  ladvance hB using [hBC] as hB hBC
  lapply hBC
  lexact hB

-- Past cases retain H-scoped facts; bare current facts cannot be carried by keeping.
example : [A, A.allPast, B.somePast] ⊢ (B.and A.allPast).somePast := by
  lstart hNow hPast hEvent
  fail_if_success ltemporal_cases hEvent using [] keeping [hNow] as x y
  ltemporal_cases hEvent using [] keeping [hPast] as hEvent hPast
  lsplit
  · lexact hEvent
  · lexact hPast

-- The generic rule route retains its explicit frame premise and reuses the local certificate.
example (hZ : FrameClass.ZTime ≤ fc) :
    [A, A.imp A.next, (A.imp A.next).allFuture] ⊢[fc] A.allFuture := by
  lstart hInit hNow hFuture
  linvariant using FormalSystem.Theorems.ProofMode.forwardInvariant
  · lexact hInit
  · lexact hNow
  · lexact hFuture

-- Reflection maps the whole context, including arbitrary Plus stability arguments.
example (P : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc [P.stab.allFuture] P.stab.allFuture := by
  ltime_reflect as h
  lexact h

-- Exact derived views preserve the guard/event order, and can use the ordinary equality route.
example : [B] ⊢ Formula.inclusiveUntil A B := by
  lstart h
  ltemporal_dual using FormalSystem.Theorems.ProofMode.inclusiveUntilIff A B
  lleft
  lexact h

-- Undetermined formula parameters remain inferable when a supplied premise determines them.
example : [(A.imp B).allFuture, A.someFuture] ⊢ B.someFuture := by
  lstart hMap hEvent
  lapply FormalSystem.Theorems.ProofMode.futureConsequence
  · lexact hMap
  · lexact hEvent

-- Both new frame and whole-context-reflection refusal paths are exercised without extra suites.
example : [Formula.untl A B] ⊢[FrameClass.Dense] Formula.untl A B := by
  lstart h
  fail_if_success luntil unfold h as he hc
  lexact h

example (p q : Atom)
    (_d : [(Formula.atom p).allFuture] ⊢ (Formula.atom q).someFuture)
    (provider : [(Formula.atom p).allFuture] ⊢ (Formula.atom q).somePast) :
    [(Formula.atom p).allFuture] ⊢ (Formula.atom q).somePast := by
  fail_if_success ltime_reflect using _d
  lexact provider

-- Positive control: the reflected context, as well as the conclusion, matches.
example (p q : Atom)
    (d : [(Formula.atom p).allFuture] ⊢ (Formula.atom q).someFuture) :
    [(Formula.atom p).allPast] ⊢ (Formula.atom q).somePast := by
  ltime_reflect using d

-- Consequence and finite cases compose persistent leads-to guarantees.
example : [(A.imp C.someFuture).allFuture, (B.imp C.someFuture).allFuture] ⊢
    ((A.or B).imp C.someFuture).allFuture := by
  lstart hA hB
  lprogress cases
  · lexact hA
  · lexact hB

namespace SemanticExamples

open FormalSystem.PlusLanguage
open FormalSystem.Semantics.ProofModeRules FormalSystem.Semantics.ProofModeTransport

variable {F : TaskFrame} (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)

-- Clause scopes expose actual alternatives, and the same propositional interface composes bodies.
example (P Q : PlusFormula) (hp : PlusTruthAt M τ t P.stab)
    (hq : PlusTruthAt M τ t Q.box) : PlusTruthAt M τ t (P.and Q).stab := by
  lmodal_intro settled using [hp, hq] as ρ hState p q
  lsplit
  · lexact p
  · lexact q

-- The semantic twin of the native opaque-provider S2 example, using the actual keeping syntax.
example (_now : TruthAt M τ t A) (hFA : TruthAt M τ t A.someFuture)
    (hAB : TruthAt M τ t (A.imp B.someFuture).allFuture)
    (hBC : TruthAt M τ t (B.imp C.someFuture).allFuture) : TruthAt M τ t C.someFuture := by
  fail_if_success ladvance _now using [hAB] as u hu a ab
  fail_if_success ladvance hFA using [] keeping [hFA] as u hu a kept
  ladvance hFA using [hAB] keeping [hBC] as u hu a ab bc
  lhave fb : B.someFuture
  · lapply ab; lexact a
  ladvance fb using [bc] as v hv b bcv
  lapply bcv
  lexact b

-- Mixed world/state/time rewrite demands are composed; local evidence cannot replace them.
example (P Q R : PlusFormula)
    (_local : PlusTruthAt M τ t P ↔ PlusTruthAt M τ t Q)
    (mapping : PlusTruthAt M τ t (P.imp Q).allFuture.stab.box)
    (provider : PlusTruthAt M τ t (P.or R).allFuture.stab.box) :
    PlusTruthAt M τ t (Q.or R).allFuture.stab.box := by
  fail_if_success lrewrite _local at provider as leaked
  lrewrite mapping at provider as mapped
  lexact mapped

-- Semantic simplification reuses the shared budgets and a model-wide clause-proved seed.
example (provider : TruthAt M τ t A.neg.neg.allFuture.box) :
    TruthAt M τ t A.allFuture.box := by
  fail_if_success lsimp only [ProofModeRules.doubleNegation_iff (L := Formula)]
    (maxSteps := 0) at provider as exhausted
  lsimp only [ProofModeRules.doubleNegation_iff (L := Formula)] at provider as reduced
  lexact reduced

-- Model-wide contracts using typed points instantiate at each demanded world/time.
example (mapping : ∀ p : Point Formula F, At M p A ↔ At M p B)
    (provider : TruthAt M τ t A.allFuture.box) : TruthAt M τ t B.allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- Semantic equality side conditions retain points beneath negation and existential binders.
example (_eqNot : ∀ {_gate : ¬ TruthAt M τ t Formula.bot}, A = B)
    (_wrongNot : ¬ TruthAt M σ t Formula.bot)
    (_eqExists : ∀ {_gate : ∃ _n : ℕ, TruthAt M τ t Formula.top}, A = B)
    (_wrongExists : ∃ _n : ℕ, TruthAt M σ t Formula.top)
    (provider : TruthAt M τ t A) : TruthAt M τ t A := by
  fail_if_success lrewrite _eqNot at provider as mismatch
  fail_if_success lrewrite _eqExists at provider as mismatch
  have _okNot : ¬ TruthAt M τ t Formula.bot := fun h => h
  lrewrite _eqNot at provider as rewritten
  guard_hyp rewritten :ₛ TruthAt M τ t B
  lexact provider

-- A temporal witness retains the strict open interval and leaves the goal at the original point.
example (h : TruthAt M τ t (Formula.untl A B)) : TruthAt M τ t (Formula.untl (A.or B) B) := by
  luntil cases h as u hu event guard
  guard_hyp guard :ₛ ∀ r, t < r → r < u → TruthAt M τ r A
  luntil witness u
  · exact hu
  · lexact event
  · intro r htr hru
    lleft
    lexact guard r htr hru

-- Existing Next facts supply covers over an arbitrary duration carrier, without a ZTime gate.
example (ha : TruthAt M τ t A.next) (hb : TruthAt M τ t B.next) :
    TruthAt M τ t (A.and B).next := by
  lstep future using [ha, hb] as u hCover a b
  guard_hyp hCover :ₛ t ⋖ u
  lsplit
  · lexact a
  · lexact b

-- Soundness is the sole native adapter, and it accepts the complete abstract object context.
example (Δ : Context) (d : DerivationTree fc Δ A) (hF : fc.Sat F)
    (hΔ : ∀ P ∈ Δ, TruthAt M τ t P) : TruthAt M τ t A := by
  fail_if_success lexact d
  fail_if_success lapply d
  luse_derivation d using hF, hΔ

-- A strict progress rule retains occurrence, invariant, rank and endpoint evidence.
example (I : F.Duration → Prop) (rank : F.Duration → ℕ)
    (step : ∀ s, I s → ¬ TruthAt M τ s A →
      ∃ u, s < u ∧ I u ∧ (TruthAt M τ u A ∨ rank u < rank s))
    (ht : I t) (hNow : ¬ TruthAt M τ t A) : TruthAt M τ t A.someFuture := by
  lprogress using (rank_progress_truth_strict M τ () A
    (r := (· < ·)) wellFounded_lt I rank)
  · exact step
  · exact ht
  · exact hNow

-- Locality and explicit state equality justify transport; bare temporal formulas are refused.
example (s : F.Duration) (p : Atom) (hState : τ.state t = σ.state s)
    (_hNow : τ.state t = σ.state t)
    (provider : PlusTruthAt M τ t (PlusFormula.atom p).someFuture.stab)
    (_temporal : PlusTruthAt M τ t (PlusFormula.atom p).someFuture) :
    PlusTruthAt M σ s (PlusFormula.atom p).someFuture.stab := by
  have hR := SameState.intro (L := PlusFormula) τ σ t s hState
    (e := PUnit.unit) (e' := PUnit.unit)
  fail_if_success
    ltransport _temporal using plus_iffTransport_stateLocal _ M
      with SameStateNow.intro τ σ t _hNow as leaked
  ltransport provider using plus_iffTransport_stab M _ with hR as moved
  lexact moved

-- Satisfaction may erase history, while the proof-mode interface still compares its indices.
example (_wrong : TruthAt M σ t Formula.top) : TruthAt M τ t Formula.top := by
  fail_if_success lexact _wrong
  exact _wrong

-- A forward fact certificate cannot be inverted into a goal transport certificate.
example (provider : TruthAt M τ t A) : TruthAt M τ t A := by
  have hR : (⟨τ, t, PUnit.unit⟩ : Point Formula F) = ⟨τ, t, PUnit.unit⟩ := rfl
  fail_if_success ltransport using orIntroLeft_fact M A B with hR
  ltransport provider using orIntroLeft_fact M A B with hR as alternative
  guard_hyp alternative : TruthAt M τ t (TruthClauses.or A B)
  lexact provider

-- Reflection changes model/history/time; a same-model result needs its own certificate.
example (provider : TruthAt M.rev τ.rev (-t) A.reflectTime)
    (_same : TruthAt M τ t A) : TruthAt M τ t A := by
  fail_if_success ltime_reflect using _same
  ltime_reflect
  lexact provider

end SemanticExamples

end BimodalTest.Automation.ProofModeExtensionsTest

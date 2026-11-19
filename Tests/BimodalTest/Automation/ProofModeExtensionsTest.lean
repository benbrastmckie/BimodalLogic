/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Simplification
import FormalSystem.Automation.ProofMode.Discrete
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

end BimodalTest.Automation.ProofModeExtensionsTest

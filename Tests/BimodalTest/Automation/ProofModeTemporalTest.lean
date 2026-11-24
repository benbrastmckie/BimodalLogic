/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-! # Contextual temporal proof examples -/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeTemporalTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

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

-- Reflection maps the whole context, including arbitrary Plus stability arguments.
example (P : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc [P.stab.allFuture] P.stab.allFuture := by
  ltime_reflect as h
  lexact h

-- The named view preserves guard/event order in both directions.
example : [B] ⊢ Formula.inclusiveUntil A B := by
  lstart h
  lunfold inclusiveUntil
  lfold inclusiveUntil
  guard_target =ₛ [B] ⊢ Formula.inclusiveUntil A B
  lunfold inclusiveUntil
  lleft
  lexact h

-- Undetermined formula parameters remain inferable when a supplied premise determines them.
example : [(A.imp B).allFuture, A.someFuture] ⊢ B.someFuture := by
  lstart hMap hEvent
  lapply FormalSystem.Theorems.ProofMode.futureConsequence
  · lexact hMap
  · lexact hEvent

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

example : [A.allFuture, B.someFuture] ⊢ Formula.untl A B := by
  lstart hGuard hEvent
  luntil intro
  · lexact hGuard
  · lexact hEvent

example : [A.allPast, B.somePast] ⊢ Formula.snce A B := by
  lstart hGuard hEvent
  lsince intro
  · lexact hGuard
  · lexact hEvent

class ReviewInstance : Prop where
  marker : True

private def requiresInstance [ReviewInstance] : ⊢ A.imp A := by
  lintro h
  lexact h

/--
error: failed to synthesize instance of type class
  ReviewInstance
lapply could not synthesize the required instance ReviewInstance

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command.
-/
#guard_msgs in
example : ⊢ A.imp A := by
  lapply @requiresInstance A

/-- error: ltime_reflect using expects a native derivation -/
#guard_msgs in
example : Γ ⊢[fc] A := by
  ltime_reflect using True.intro

-- Reprove ConnectDerived.connectPast by reflecting its future counterpart.
example : ⊢[fc] A.imp A.someFuture.allPast := by
  ltime_reflect
  lexact (FormalSystem.Theorems.ConnectDerived.connectFuture A.reflectTime)

-- The same reflection applies to TemporalDerived.connectPastH inside two H scopes.
example : ⊢[fc] A.allPast.imp A.someFuture.allPast.allPast := by
  ltime_reflect
  lexact (FormalSystem.Theorems.TemporalDerived.connectFutureG A.reflectTime)

/-- error: selected guarantee must have the matching G scope -/
#guard_msgs in
example (h : [A.allPast] ⊢ A.allPast) : [A.allPast] ⊢ A.allFuture := by
  ltemporal_intro future using [h]

end BimodalTest.Automation.ProofModeTemporalTest

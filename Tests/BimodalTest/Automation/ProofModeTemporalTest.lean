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

/-- A class whose type mentions the rule's own `FrameClass` parameter. That parameter is the one
metavariable the implication-chain match never assigns -- only the conclusion unification against
the goal does -- so this is the shape the instance-synthesis ordering in `applyDerivationProof`
turns on. `ReviewInstance` above is parameterless and does not reach this path. -/
class FrameTag (fc : FrameClass) : Prop where
  marker : True

instance : FrameTag FrameClass.ZTime := ⟨trivial⟩

private def requiresFrameTag (φ : Formula) {fc : FrameClass} [FrameTag fc] :
    ⊢[fc] φ.imp φ := by
  lintro h
  lexact h

-- Regression guard for the instance-synthesis ordering in `applyDerivationProof`: the synthesis
-- loop must run AFTER the conclusion has been unified against the goal, because that unification
-- is what assigns the rule's `fc`. Against the pre-fix ordering (the loop sitting before
-- `adaptProof` and before the conclusion `isDefEq`) this example fails with
-- "lapply could not synthesize the required instance FrameTag ?fc" (measured by reinstating the
-- pre-fix ordering and rebuilding this module). It is written as a positive example rather than
-- a `#guard_msgs` pin because that message names an unassigned metavariable whose printed form
-- is not stable across unrelated edits.
example : ⊢[FrameClass.ZTime] A.imp A := by
  lapply @requiresFrameTag A

-- `Basic.lean`'s "the applied rule produced an incompatible judgment" arm is a defensive
-- invariant check with no constructible trigger from user syntax, so it carries an in-source
-- note there instead of a `#guard_msgs` pin here. Measured: a rule whose conclusion formula
-- matches the goal but whose frame class does not (`⊢[FrameClass.ZTime] φ.imp φ` applied at
-- `⊢[FrameClass.Base] A.imp A`) is rejected one step earlier, by `adaptProof`, with
-- "different frame classes; supply an explicitly lifted derivation". Once the implication-chain
-- match has succeeded on the formula and `adaptProof` has aligned frame, language and context,
-- the proof's type and the goal's type agree by construction.

/-! ## Negative tests: the added diagnostics in `Temporal.lean`

One `#guard_msgs` block per reachable `throwError` outside the integer-time gate, whose own two
messages are pinned in `ProofModeTemporalZTimeTest.lean`. Three arms of this module are
unreachable from user syntax and carry their reasons in-source instead of a pin here:
`unregistered temporal composition rule`, `missing reflected formula view` and
`reflected view does not match the native reflection rule`. -/

-- The name count must be one event name plus one per selected or kept guarantee. The context
-- fixes the guarantee count at one, so the interpolated figure in the message is stable.
/-- error: expected an event name and 1 scoped assumption names (using, then keeping) -/
#guard_msgs in
example (pAB : [A.someFuture] ⊢ (A.imp B.someFuture).allFuture) :
    [A.someFuture] ⊢ C.someFuture := by
  lstart hA
  ladvance hA using [pAB] as hA

/-- error: intro expects an Until formula -/
#guard_msgs in
example : [A.allFuture, B.someFuture] ⊢ A := by
  lstart hGuard hEvent
  luntil intro

/-- error: intro expects a Since formula -/
#guard_msgs in
example : [A.allPast, B.somePast] ⊢ A := by
  lstart hGuard hEvent
  lsince intro

-- A reflected fact must be fully applied: an unapplied formula parameter leaves a metavariable
-- in the fact's own judgment, which no reflection can resolve.
/-- error: reflected fact has unresolved parameters; supply its arguments explicitly -/
#guard_msgs in
example (d : ∀ φ : Formula, [φ] ⊢ φ) : Γ ⊢[fc] A := by
  ltime_reflect using d _ as h

/-- error: different object languages; supply an explicit derivation embedding -/
#guard_msgs in
example (P : FormalSystem.PlusLanguage.PlusFormula)
    (d : FormalSystem.PlusLanguage.PlusDerivationTree fc [P.stab] P.stab) :
    [A] ⊢[fc] A := by
  ltime_reflect using d

-- Without `as`, the reflected derivation must close the goal outright. Here the context reflects
-- to the goal's but the conclusion does not: `F q` reflects to `P q`, not back to `F q`.
/-- error: the reflected derivation does not prove the current conclusion -/
#guard_msgs in
example (p q : Atom)
    (d : [(Formula.atom p).allFuture] ⊢ (Formula.atom q).someFuture) :
    [(Formula.atom p).allPast] ⊢ (Formula.atom q).someFuture := by
  ltime_reflect using d

-- `luntil`/`lsince` take their operand position as an `ident`, not as a `&"guard"`/`&"event"`
-- keyword, so the parser admits any identifier and the fallback arm is reachable.
/-- error: expected `guard` or `event` -/
#guard_msgs in
example : [A.allFuture, Formula.untl A C] ⊢ Formula.untl B C := by
  lstart hMap hUntil
  luntil banana using hMap

-- Likewise `ltemporal_intro`'s direction is an `ident`, not a `&"future"`/`&"past"` keyword.
/-- error: expected `future` or `past` -/
#guard_msgs in
example (h : [A.allPast] ⊢ A.allPast) : [A.allPast] ⊢ A.allFuture := by
  ltemporal_intro sideways keeping [h]

end BimodalTest.Automation.ProofModeTemporalTest

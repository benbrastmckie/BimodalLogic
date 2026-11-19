/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Automation.ProofMode.Temporal
import FormalSystem.Theorems.ProofMode.Discrete
import FormalSystem.Theorems.ProofMode.PlusDiscrete

/-!
# Checked discrete steps and invariance

Next/Previous introduction shifts exactly the selected assumptions. Invariance leaves current
initialization, the current one-step implication, and its strict G/H persistence as obligations.
Both operations require an explicit or generated `FrameClass.ZTime ≤ fc` certificate.

* `lstep future/past using [..] keeping [..] as h.. k..` additionally carries strict `G P`
  (future) or `H P` (past) facts to the adjacent point. Temporal 4 gives `G(G P)`; the successor
  indicator `X ⊤` (`succIndicatorAt`, from the same ZTime gate) moves it under `X` by
  `nextOfAllFuture`; the shifted body therefore holds `G P` again. Bare current facts are
  rejected. Names list `using` guarantees first, then kept facts.
* `linvariant future/past` is unchanged; `linvariant using rule` applies a supplied invariance
  rule through `lapply`.
* `linduction future/past` applies the discrete backward-induction schema Z1, leaving
  `G(G φ → φ)` and `F(G φ)` (past mirror with H/P). `linduction using rule` applies a supplied
  rule. Strict G omits the present; no rule here adds temporal T.

The original `lstep`/`linvariant` gate keeps its behaviour: a concrete `ZTime` goal is closed by
`le_refl`, another tag is left as an explicit goal, and a decided-false concrete tag is now
rejected immediately. Explicit integer-time rules added here use `integerTimeGate`, which also
reuses an exact local certificate.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

/-- The original `lstep`/`linvariant` gate, now rejecting a decided-false concrete tag. -/
private def discreteFrame (judgment : Judgment) :
    TacticM (Expr × List MVarId) := do
  let discrete := mkConst ``FormalSystem.ProofSystem.FrameClass.ZTime
  let expected ← mkAppM ``LE.le #[discrete, judgment.frame]
  if ← isDefEq judgment.frame discrete then
    return (← mkAppM ``le_refl #[discrete], [])
  let instantiated ← instantiateMVars expected
  if !instantiated.hasFVar && !instantiated.hasExprMVar then
    let decision ← try some <$> whnf (← mkDecide instantiated) catch _ => pure none
    if decision.any (·.isConstOf ``Bool.false) then
      throwError "integer-time step needs FrameClass.ZTime ≤ {judgment.frame}, which is false \
        for this concrete frame class"
  let proof ← mkFreshExprSyntheticOpaqueMVar expected
  return (proof, [proof.mvarId!])

private def adjacent (past : Bool) (terms : Option (Array Syntax))
    (keptTerms : Option (Array Syntax)) (names : Array Syntax) : TacticM Unit :=
    withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let (frame, sideGoals) ← discreteFrame judgment
  let operator := if past then `prev else `next
  let rule := if past then judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.generalizedPrevK
      ``FormalSystem.PlusLanguage.ProofMode.generalizedPrevK
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.generalizedNextK
      ``FormalSystem.PlusLanguage.ProofMode.generalizedNextK
  match keptTerms with
  | none => introduceMappedScope operator rule #[frame] terms names
  | some kept =>
    let selected ← scopedGuarantees judgment operator terms
    let keepRule := if past then judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.prevKeep ``FormalSystem.PlusLanguage.ProofMode.prevKeep
      else judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.nextKeep ``FormalSystem.PlusLanguage.ProofMode.nextKeep
    let shifted ← (← keptFacts judgment past kept).mapM fun proof =>
      mkAppM keepRule #[frame, proof]
    introduceScopeFromProofs operator rule #[frame] (selected ++ shifted) names
  setGoals (sideGoals ++ (← getGoals))

private def invariant (past : Bool) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (frame, sideGoals) ← discreteFrame judgment
  let rule := if past then judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.pastInvariant
      ``FormalSystem.PlusLanguage.ProofMode.pastInvariant
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.forwardInvariant
      ``FormalSystem.PlusLanguage.ProofMode.forwardInvariant
  let operator := if past then `allPast else `allFuture
  let some args ← operatorArgs? judgment.language operator 1 judgment.formula
    | throwError "invariance requires the matching universal temporal goal"
  let rule ← mkAppOptM rule
    #[some judgment.frame, some judgment.context, some args[0]!, some frame]
  let goals ← goal.apply rule
  replaceMainGoal (sideGoals ++ goals)

/-- Discrete backward induction (Z1): `G(G φ → φ)` and `F(G φ)` give `G φ` on integer time. -/
private def induction (past : Bool) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (universal, existential) := if past then (`allPast, `somePast)
    else (`allFuture, `someFuture)
  let some args ← operatorArgs? judgment.language universal 1 judgment.formula
    | throwError "induction requires the matching universal temporal goal"
  let (frame, sideGoals) ← integerTimeGate judgment
  let whole ← formulaApp judgment.language universal #[args[0]!]
  let step ← formulaApp judgment.language universal
    #[← formulaApp judgment.language `imp #[whole, args[0]!]]
  let eventually ← formulaApp judgment.language existential #[whole]
  let hStep ← mkFreshExprSyntheticOpaqueMVar (← derivationType judgment judgment.context step)
  let hEventually ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment judgment.context eventually)
  let rule := if past then judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.pastBackwardInduction
      ``FormalSystem.PlusLanguage.ProofMode.pastBackwardInduction
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.futureBackwardInduction
      ``FormalSystem.PlusLanguage.ProofMode.futureBackwardInduction
  let proof ← mkAppM rule #[frame, hStep, hEventually]
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "backward induction does not prove the current conclusion"
  goal.assign proof
  replaceMainGoal (sideGoals ++ [hStep.mvarId!, hEventually.mvarId!])

/-- Check a universal G/H goal, then apply the supplied rule through `lapply`. -/
private def universalRule (term : Syntax) : TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let future ← operatorArgs? judgment.language `allFuture 1 judgment.formula
  let past ← operatorArgs? judgment.language `allPast 1 judgment.formula
  if future.isNone && past.isNone then
    throwError "this rule route requires a universal G/H goal"
  applyTemporalRule term

/-- Shift selected Next/Previous guarantees to a checked adjacent-point body. `keeping [k]`
also carries strict G/H facts. Names: `using` guarantees, then kept facts. -/
syntax (name := lstep) "lstep" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace "keeping" ppSpace "[" term,* "]")?
  (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Apply integer-time invariance, leaving initialization and both step obligations. -/
syntax (name := linvariant) "linvariant" ppSpace colGt ident : tactic

/-- Apply a supplied invariance rule to a universal G/H goal through `lapply`. -/
syntax (name := linvariantRule) "linvariant" ppSpace "using" ppSpace colGt term : tactic

/-- Apply discrete backward induction (Z1), leaving the persistent step and the eventual base. -/
syntax (name := linduction) "linduction" ppSpace colGt ident : tactic

/-- Apply a supplied induction rule to a universal G/H goal through `lapply`. -/
syntax (name := linductionRule) "linduction" ppSpace "using" ppSpace colGt term : tactic

private def pastDirection (kind : Syntax) : TacticM Bool :=
  match kind.getId with
  | `future => pure false
  | `past => pure true
  | _ => throwError "expected `future` or `past`"

elab_rules : tactic
  | `(tactic|
      lstep $kind:ident $[using [$terms:term,*]]? $[keeping [$kept:term,*]]?
        $[as $names:ident*]?) => do
    adjacent (← pastDirection kind) (terms.map (·.getElems.map (·.raw)))
      (kept.map (·.getElems.map (·.raw))) (names.map (·.map (·.raw)) |>.getD #[])
  | `(tactic| linvariant $kind:ident) => do invariant (← pastDirection kind)
  | `(tactic| linvariant using $rule:term) => universalRule rule
  | `(tactic| linduction $kind:ident) => do induction (← pastDirection kind)
  | `(tactic| linduction using $rule:term) => universalRule rule

end FormalSystem.Automation.ProofMode

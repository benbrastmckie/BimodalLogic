/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Automation.ProofMode.TemporalZTime
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
* `linduction future/past` applies the discrete backward-induction schema Z1, leaving
  `G(G φ → φ)` and `F(G φ)` (past mirror with H/P). Strict G omits the present.

The integer-time gate reuses an exact local certificate or decides a concrete tag. An abstract
gate remains an explicit proof obligation.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

private def adjacent (past : Bool) (terms : Option (Array Syntax))
    (keptTerms : Option (Array Syntax)) (names : Array Syntax) : TacticM Unit :=
    withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let (frame, sideGoals) ← integerTimeGate judgment
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
    let shifted ← carriedFacts judgment operator kept (some frame)
    introduceScopeFromProofs operator rule #[frame] (selected ++ shifted) names
  setGoals (sideGoals ++ (← getGoals))

private def invariant (past : Bool) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (frame, sideGoals) ← integerTimeGate judgment
  let rule := if past then judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.pastInvariant
      ``FormalSystem.PlusLanguage.ProofMode.pastInvariant
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.forwardInvariant
      ``FormalSystem.PlusLanguage.ProofMode.forwardInvariant
  let operator := if past then `allPast else `allFuture
  let some args ← operatorArgs? judgment.language.formulaType operator 1 judgment.formula
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
  let some args ← operatorArgs? judgment.language.formulaType universal 1 judgment.formula
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

/-- Shift selected Next/Previous guarantees to a checked adjacent-point body. `keeping [k]`
also carries strict G/H facts. Names: `using` guarantees, then kept facts. -/
syntax (name := lstep) "lstep" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace &"keeping" ppSpace "[" term,* "]")?
  (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Apply integer-time invariance, leaving initialization and both step obligations. -/
syntax (name := linvariant) "linvariant" ppSpace colGt ident : tactic

/-- Apply discrete backward induction (Z1), leaving the persistent step and the eventual base. -/
syntax (name := linduction) "linduction" ppSpace colGt ident : tactic

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
  | `(tactic| linduction $kind:ident) => do induction (← pastDirection kind)

end FormalSystem.Automation.ProofMode

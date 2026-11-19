/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.SemanticRewriting

/-!
# Bounded semantic normalization

The native and semantic frontends share occurrence order, primitive size and explicit budgets.
Only listed semantic evidence is considered. Every accepted reduction has an indexed semantic
certificate, strictly decreases the concrete formula, and introduces no speculative obligation.
-/

namespace FormalSystem.Automation.ProofMode.Semantic

open Lean Meta Elab Tactic

/-- Normalize a pointed semantic goal or a named copy of a fact, transactionally. -/
def semanticSimp (rules : Array (Syntax × Bool)) (budget : SimpBudget)
    (fact : Option (Syntax × Name)) : TacticM Unit := withMainContext do
  let saved ← saveState
  try
    let originalGoal ← getMainGoal
    let original ← requireTruth originalGoal
    let mut goal := originalGoal
    let mut current := original
    let mut factValue : Option (Expr × Name) := none
    if let some (term, name) := fact then
      let proof ← elaborateProof term
      let some source ← truthJudgment? (← inferType proof)
        | throwError "expected an indexed semantic fact"
      current := source
      factValue := some (proof, name)
    let mut steps := 0
    let mut attempts := 0
    let mut visits := 0
    let mut scopes := 0
    let mut seen : Array Expr := #[← instantiateMVars current.formula]
    repeat
      let occurrences ← formulaOccurrences current.language current.formula
        budget.nodes budget.depth
      visits := visits + occurrences.size
      if visits > budget.visits then
        throwError "semantic lsimp visit budget exhausted ({visits}/{budget.visits})"
      let size ← primitiveSize current.language current.formula
      let mut change : Option (Expr × Expr) := none
      for occurrence in occurrences do
        for (term, reverse) in rules do
          attempts := attempts + 1
          scopes := scopes + occurrence.path.size
          if attempts > budget.attempts || scopes > budget.scopes then
            throwError "semantic lsimp budget exhausted: matches {attempts}/{budget.attempts}, \
              scope positions {scopes}/{budget.scopes}"
          let trial ← saveState
          try
            let raw ← elaborateProof term
            let reverse := reverse != (← registeredRewriteOrientation raw)
            let equality ← withoutModifyingState do
              let (_, _, type) ← forallMetaTelescopeReducing (← inferType raw)
              return type.isAppOf ``Eq
            let (certificate, replacement, pending) ← if equality then
                semanticEqualityCertificate current raw reverse factValue.isNone false
                  (some (occurrence.path.map (·.name)))
              else do
                let e ← readEvidence raw
                semanticCertificate current e occurrence factValue.isNone reverse false
            unless pending.isEmpty do throwError "semantic simplification requires side conditions"
            checkRewriteHoles certificate []
            unless (← primitiveSize current.language replacement) < size do
              throwError "semantic rule does not decrease instantiated primitive size"
            change := some (certificate, replacement)
            break
          catch error =>
            trace[proofMode.simp] "semantic skip {term} at {occurrence.path.map (·.name)}: \
              {error.toMessageData}"
            trial.restore
        if change.isSome then break
      let some (certificate, replacement) := change | break
      if steps >= budget.steps then
        throwError "semantic lsimp step budget exhausted ({steps}/{budget.steps}); rolling back"
      if seen.any (· == replacement) then throwError "semantic lsimp repeated state; rolling back"
      seen := seen.push replacement
      if let some (source, name) := factValue then
        let result := mkApp certificate source
        let expected ← truthType current replacement
        unless ← isDefEq (← inferType result) expected do
          throwError "semantic normalization proves a different indexed fact"
        factValue := some (← mkExpectedTypeHint result expected, name)
      else
        let next ← mkFreshExprSyntheticOpaqueMVar (← truthType current replacement)
        goal.assign (mkApp certificate next)
        goal := next.mvarId!
      current := { current with formula := replacement }
      steps := steps + 1
    if steps == 0 then throwError "semantic lsimp made no decreasing change"
    trace[proofMode.simp] "semantic: {steps} reductions, {attempts} matches, {visits} node visits, \
      {scopes} scope positions"
    match factValue with
    | some (proof, name) =>
      replaceMainGoal [← noteTruth originalGoal name current current.formula proof]
    | none => replaceMainGoal [goal]
  catch error => saved.restore; throw error

@[no_fallback] elab_rules : tactic
  | `(tactic| lsimp only [$rules:lproofRule,*] $[(maxSteps := $fuel:num)]?
      $[at $fact:term as $name:ident]?) => do
    unless (← truthJudgment? (← (← getMainGoal).getType)).isSome do
      throwUnsupportedSyntax
    let rules := rules.getElems.map fun rule => (rule.raw[1], !rule.raw[0].isNone)
    semanticSimp rules { steps := fuel.map (·.getNat) |>.getD 64 }
      (fact.map fun fact => (fact, name.get!.getId))

end FormalSystem.Automation.ProofMode.Semantic

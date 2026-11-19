/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.RuleRegistry
import FormalSystem.Theorems.ProofMode.Simplification

/-!
# Bounded, proof-producing native simplification

Only explicitly supplied rules are considered. The traversal and rule order are fixed; a
strict decrease in instantiated primitive formula size guards every logical reduction. Frame
premises must already be available. Exhaustion restores the complete original tactic state.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic
open FormalSystem.Theorems.ProofMode

register_lrewrite FormalSystem.Theorems.ProofMode.doubleNegationIff
register_lrewrite FormalSystem.Theorems.ProofMode.conjunctionSelfIff
register_lrewrite FormalSystem.Theorems.ModalS5.boxConjIff reverse
register_lrewrite FormalSystem.Theorems.ModalS5.diamondDisjIff reverse
register_lrewrite FormalSystem.Theorems.ModalS5.s5DiamondBox
register_lrewrite FormalSystem.PlusLanguage.ProofMode.doubleNegationIff
register_lrewrite FormalSystem.PlusLanguage.ProofMode.conjunctionSelfIff
register_lrewrite FormalSystem.PlusLanguage.ProofMode.boxConjIff reverse
register_lrewrite FormalSystem.PlusLanguage.ProofMode.diamondDisjIff reverse
register_lrewrite FormalSystem.PlusLanguage.ProofMode.s5DiamondBox

initialize registerTraceClass `proofMode.simp

/-- Explicit limits for a single simplification invocation, independent of provider size. -/
structure SimpBudget where
  /-- Maximum successful logical reductions. -/
  steps : Nat := 64
  /-- Maximum rule/occurrence matches, including failed attempts. -/
  attempts : Nat := 1024
  /-- Maximum formula nodes visited across all passes. -/
  visits : Nat := 4096
  /-- Maximum traversed formula nodes per pass. -/
  nodes : Nat := 512
  /-- Maximum selected path depth. -/
  depth : Nat := 64
  /-- Maximum accumulated scope positions considered during discharge. -/
  scopes : Nat := 4096

/-- Deterministic normalization of a goal or a newly named fact; no contextual state is cached. -/
def nativeSimp (rules : Array (Syntax × Bool)) (budget : SimpBudget)
    (fact : Option (Syntax × Name)) : TacticM Unit := withMainContext do
  let saved ← saveState
  try
    let originalGoal ← getMainGoal
    let original ← requireJudgment originalGoal
    let mut goal := originalGoal
    let mut current := original
    let mut factValue : Option (Expr × Name) := none
    if let some (term, name) := fact then
      let proof ← adaptProof (← elaborateProof term) original
      let some source ← judgment? (← inferType proof) | throwError "expected a native fact"
      current := { original with formula := source.formula }
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
        throwError "lsimp visit budget exhausted ({visits}/{budget.visits})"
      let size ← primitiveSize current.language current.formula
      let mut change : Option (Expr × Expr) := none
      for occurrence in occurrences do
        for (term, reverse) in rules do
          attempts := attempts + 1
          scopes := scopes + occurrence.path.size
          if attempts > budget.attempts || scopes > budget.scopes then
            throwError "lsimp budget exhausted: matches {attempts}/{budget.attempts}, \
              scope positions {scopes}/{budget.scopes}"
          let attemptState ← saveState
          try
            let explicit ← elaborateProof term
            let reverse := reverse != (← registeredRewriteOrientation explicit)
            let equality ← withoutModifyingState do
              let (_, _, type) ← forallMetaTelescopeReducing (← inferType explicit)
              return type.isAppOf ``Eq
            let (certificate, replacement, sideGoals, pending) ← if equality then do
                let (replacement, equality, sideGoals) ← formulaEqualityRewriteProof current
                  explicit reverse (some (occurrence.path.map (·.name)))
                let equality ← if factValue.isNone then mkAppM ``Eq.symm #[equality]
                  else pure equality
                let kit ← mkAppM (current.language.ruleName
                  ``Congruence.tmKit ``Congruence.plusKit) #[current.frame]
                let certificate ← adaptProof (← mkAppM ``Congruence.Kit.ofEquality
                  #[kit, equality]) current
                pure (certificate, replacement, sideGoals, [])
              else do
                let (evidence, parameters) ← prepareRewriteRule explicit current
                let (certificate, replacement, sideGoals) ← rewriteCertificate current evidence
                  occurrence factValue.isNone reverse
                pure (certificate, replacement, sideGoals, ← resolveRuleParameters parameters)
            unless sideGoals.isEmpty && pending.isEmpty do
              throwError "rule requires unavailable side conditions"
            checkRewriteHoles certificate []
            let replacement ← instantiateMVars replacement
            if replacement.hasExprMVar then throwError "rule leaves an undetermined formula"
            unless (← primitiveSize current.language replacement) < size do
              throwError "rule does not decrease instantiated primitive constructor count"
            change := some (certificate, replacement)
            break
          catch error =>
            trace[proofMode.simp] "skip {term} at {occurrence.path.map (·.name)}: \
              {error.toMessageData}"
            attemptState.restore
        if change.isSome then break
      let some (certificate, replacement) := change | break
      if steps >= budget.steps then
        throwError "lsimp step budget exhausted ({steps}/{budget.steps}); rolling back"
      if seen.any (· == replacement) then throwError "lsimp repeated a state; rolling back"
      seen := seen.push replacement
      if let some (source, name) := factValue then
        let result ← modusPonens current certificate source
        let expected ← derivationType current current.context replacement
        unless ← isDefEq (← inferType result) expected do
          throwError "simp certificate does not prove the planned fact"
        factValue := some (← mkExpectedTypeHint result expected, name)
      else
        let next ← mkFreshExprSyntheticOpaqueMVar
          (← derivationType current current.context replacement)
        let result ← modusPonens current certificate next
        unless ← isDefEq (← inferType result) (← goal.getType) do
          throwError "simp certificate does not reconstruct the original goal"
        goal.assign result
        goal := next.mvarId!
      current := { current with formula := replacement }
      steps := steps + 1
    if steps == 0 then throwError "lsimp made no decreasing change with the supplied rules"
    trace[proofMode.simp] "{steps} reductions, {attempts} matches, {visits} node visits, \
      {scopes} scope positions"
    match factValue with
    | some (proof, name) => replaceMainGoal [← nameProof originalGoal name proof]
    | none => replaceMainGoal [goal]
  catch error =>
    saved.restore
    throw error

/-- One explicit logical simplification rule with a fixed orientation. -/
declare_syntax_cat lproofRule
/-- One selected proof term, with an optional reversal of its registered orientation. -/
syntax ("←")? term : lproofRule

/-- Simplify using only the selected implications/equivalences, with an explicit step bound. -/
syntax (name := lsimp) "lsimp" ppSpace "only" ppSpace "[" lproofRule,* "]"
  (ppSpace "(" &"maxSteps" " := " num ")")?
  (ppSpace "at" ppSpace colGt term ppSpace "as" ppSpace colGt ident)? : tactic

elab_rules : tactic
  | `(tactic| lsimp only [$rules:lproofRule,*] $[(maxSteps := $fuel:num)]?
      $[at $fact:term as $name:ident]?) => do
    let rules := rules.getElems.map fun rule => (rule.raw[1], !rule.raw[0].isNone)
    nativeSimp rules { steps := fuel.map (·.getNat) |>.getD 64 }
      (fact.map fun fact => (fact, name.get!.getId))

end FormalSystem.Automation.ProofMode

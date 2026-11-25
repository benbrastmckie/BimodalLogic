/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Meta
import FormalSystem.Theorems.ProofMode.TemporalComposition

/-!
# Carrying scoped facts into a new scope

Entering a scope with `using` removes one operator from each selected fact. `keeping` instead
carries a fact into the scope intact. A carrying rule is therefore determined by two operators:
the `source` heading the fact and the `target` scope being entered. One source may be carried into
several targets, and one target may accept several sources.

A row with source `S` and target `T` names a rule proving `Γ ⊢ T (S P)` from `Γ ⊢ S P`, in each
language. The scope rule for `T` then removes `T`, so the body holds `S P` again. A `framed` row's
rule takes the `FrameClass.ZTime ≤ fc` certificate before the fact.

| Source | Target | Rule | Frame |
| --- | --- | --- | --- |
| `G` | `G` | `futureKeep`, temporal 4 | every class |
| `G` | `X` | `nextKeep`, temporal 4 at the successor | ZTime |
| `H` | `H` | `pastKeep`, past temporal 4 | every class |
| `H` | `Y` | `prevKeep`, past temporal 4 at the predecessor | ZTime |

Eventuality cases and advance enter the matching universal scope, so they use its target.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

/-- A rule carrying a `source`-headed fact intact into a `target` scope. -/
structure CarryRule where
  /-- Operator heading the carried fact. -/
  source : Name
  /-- Universal operator of the scope being entered. -/
  target : Name
  /-- The TM and TM⁺ rules, from `Γ ⊢ source P` to `Γ ⊢ target (source P)`. -/
  rule : Name × Name
  /-- Whether the rule takes the `FrameClass.ZTime ≤ fc` certificate before the fact. -/
  framed : Bool

/-- The carrying rules, at most one for each source and target. -/
def carryRules : Array CarryRule := #[
  { source := `allFuture, target := `allFuture, framed := false
    rule := (``FormalSystem.Theorems.ProofMode.futureKeep,
      ``FormalSystem.PlusLanguage.ProofMode.futureKeep) },
  { source := `allFuture, target := `next, framed := true
    rule := (``FormalSystem.Theorems.ProofMode.nextKeep,
      ``FormalSystem.PlusLanguage.ProofMode.nextKeep) },
  { source := `allPast, target := `allPast, framed := false
    rule := (``FormalSystem.Theorems.ProofMode.pastKeep,
      ``FormalSystem.PlusLanguage.ProofMode.pastKeep) },
  { source := `allPast, target := `prev, framed := true
    rule := (``FormalSystem.Theorems.ProofMode.prevKeep,
      ``FormalSystem.PlusLanguage.ProofMode.prevKeep) }]

/-- The carrying rule for a fact's formula at a target scope. -/
def carryRule? (judgment : Judgment) (target : Name) (formula : Expr) :
    MetaM (Option CarryRule) :=
  carryRules.findM? fun row => do
    if row.target != target then return false
    return (← operatorArgs? judgment.language row.source 1 formula).isSome

/-- Elaborate the `keeping` facts and apply the carrying rule of each at the target scope. Framed
rules use the caller's integer-time certificate. -/
def carriedFacts (judgment : Judgment) (target : Name) (terms : Array Syntax)
    (certificate : Option Expr := none) : TacticM (Array Expr) :=
  terms.mapM fun term => do
    let proof ← adaptProof (← elaborateProof term) judgment
    let source ← proofJudgment proof
    if (← instantiateMVars source.formula).hasExprMVar then
      throwError "`keeping` needs a determined formula; supply its arguments explicitly"
    let some row ← carryRule? judgment target source.formula
      | let sources := carryRules.filter (·.target == target) |>.map (operatorSymbol ·.source)
        if sources.isEmpty then
          throwError "no carrying rule enters the {operatorSymbol target} scope"
        throwError "`keeping` carries only {", ".intercalate sources.toList}-scoped facts into the \
          {operatorSymbol target} scope; {source.formula} needs its own preservation rule"
    let rule := judgment.language.ruleName row.rule.1 row.rule.2
    unless row.framed do return ← mkAppM rule #[proof]
    let some certificate := certificate
      | throwError "carrying {operatorSymbol row.source} facts into the {operatorSymbol target} \
          scope requires FrameClass.ZTime ≤ {judgment.frame}"
    mkAppM rule #[certificate, proof]

end FormalSystem.Automation.ProofMode

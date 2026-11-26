/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Tactic.FormulaSyntax

/-!
# Formula positions shared by proof-mode backends

Positions identify actual constructor arguments or fixed, unambiguous derived views. They do
not use the pretty-printer's folding heuristics. A derived view that repeats an argument needs
its own congruence theorem; it is not silently treated as a single primitive occurrence.
-/

namespace FormalSystem.Tactic.FormulaPositions

open Lean Meta FormulaSyntax

/-- One selected argument, with its original siblings retained for reconstruction. -/
structure FormulaPosition where
  /-- Public path component. -/
  name : Name
  /-- Checked formula operator key. -/
  operator : Name
  /-- Arguments of the operator at this point. -/
  arguments : Array Expr
  /-- Selected argument index. -/
  index : Nat
  deriving Inhabited

/-- A formula subtree and the path from the whole formula to it. -/
structure Occurrence where
  /-- Outermost-first argument positions. -/
  path : Array FormulaPosition
  /-- Formula at that path. -/
  formula : Expr
  deriving Inhabited

/-- Names and selected arguments for the supported unambiguous formula views. -/
def positionNames (operator : Name) : Array Name :=
  match operator with
  | `imp => #[`impLeft, `impRight]
  | `and => #[`andLeft, `andRight]
  | `or => #[`orLeft, `orRight]
  | `neg => #[`negBody]
  | `box => #[`boxBody]
  | `stab => #[`stabilityBody]
  | `diamond => #[`possibilityBody]
  | `dstab => #[`settledPossibilityBody]
  | `allFuture => #[`futureBody]
  | `allPast => #[`pastBody]
  | `someFuture => #[`futureEvent]
  | `somePast => #[`pastEvent]
  | `next => #[`nextBody]
  | `prev => #[`prevBody]
  | `untl => #[`untilGuard, `untilEvent]
  | `snce => #[`sinceGuard, `sinceEvent]
  | _ => #[]

private def viewOperators : Array Name :=
  #[`and, `or, `neg, `box, `diamond, `allFuture, `allPast, `someFuture, `somePast,
    `next, `prev, `untl, `snce, `imp]

/-- The actual operator views whose arguments have registered positional transfers. -/
def formulaViewOperators (language : Language) : Array Name :=
  if language == .plus then viewOperators ++ #[`stab, `dstab] else viewOperators

/-- Read a registered syntactic view; other wrappers require explicit unfolding. -/
def positionChildren (language : Language) (formula : Expr) : MetaM (Array FormulaPosition) := do
  let operators := formulaViewOperators language
  let formula ← instantiateMVars formula
  let read (formula : Expr) : MetaM (Array FormulaPosition) := do
    for operator in operators do
      if formula.getAppFn.constName? == some (← operatorConst language.formulaType operator) then
        let arguments := formula.getAppArgs
        let names := positionNames operator
        if arguments.size == names.size then
          return names.mapIdx fun index name => ⟨name, operator, arguments, index⟩
    return #[]
  -- An unregistered wrapper may repeat its arguments. Require explicit unfolding rather
  -- than expose an invisible primitive tree, even when a delta reduction would be possible.
  read formula

/-- Rebuild the original operator with exactly its selected argument replaced. -/
def FormulaPosition.replace (position : FormulaPosition) (language : Language)
    (formula : Expr) : MetaM Expr :=
  formulaApp language position.operator (position.arguments.set! position.index formula)

/-- Substitute one selected occurrence while preserving its enclosing formula. -/
def Occurrence.replace (occurrence : Occurrence) (language : Language)
    (replacement : Expr) : MetaM Expr := do
  let mut result := replacement
  for position in occurrence.path.reverse do
    result ← position.replace language result
  return result

/-- Follow an explicit path, rejecting unsupported or ambiguous derived views. -/
def selectOccurrence (language : Language) (formula : Expr)
    (path : Array Name) : MetaM Occurrence := do
  let mut current := formula
  let mut positions := #[]
  for name in path do
    let children ← positionChildren language current
    if children.isEmpty then
      throwError "cannot follow path component {name}; no registered positions at {current}"
    let some position := children.find? (·.name == name)
      | throwError "path component {name} is unavailable; \
          available components: {children.map (·.name)}"
    positions := positions.push position
    current := position.arguments[position.index]!
  return ⟨positions, current⟩

/-- Bounded preorder worker, keeping the visited-node count across siblings. -/
private partial def visitOccurrences (language : Language) (maxNodes maxDepth : Nat)
    (current : Expr) (path : Array FormulaPosition) (result : Array Occurrence) :
    MetaM (Array Occurrence) := do
  if result.size >= maxNodes then throwError "formula traversal exceeded {maxNodes} nodes"
  if path.size > maxDepth then throwError "formula traversal exceeded depth {maxDepth}"
  let mut result := result.push ⟨path, current⟩
  for child in ← positionChildren language current do
    result ← visitOccurrences language maxNodes maxDepth child.arguments[child.index]!
      (path.push child) result
  return result

/-- Enumerate occurrences in deterministic preorder, with explicit node and depth limits. -/
def formulaOccurrences (language : Language) (formula : Expr)
    (maxNodes : Nat := 512) (maxDepth : Nat := 64) : MetaM (Array Occurrence) :=
  visitOccurrences language maxNodes maxDepth formula #[] #[]

/-- Applied formula heads the planner cannot traverse. Atoms take a data argument. -/
def stoppedWrappers (language : Language) (formula : Expr) : MetaM (Array Name) := do
  let atom ← operatorConst language.formulaType `atom
  let mut result := #[]
  for occurrence in ← formulaOccurrences language formula do
    let term := occurrence.formula
    if term.getAppNumArgs == 0 || !(← positionChildren language term).isEmpty then continue
    if let some head := term.getAppFn.constName? then
      if head != atom && !result.contains head then result := result.push head
  return result

/-- Count primitive constructors after definitional view expansion, under a finite bound. -/
partial def primitiveSize (language : Language) (formula : Expr)
    (fuel : Nat := 4096) : MetaM Nat := do
  if fuel == 0 then throwError "formula size calculation exhausted its node/depth bound"
  let formula ← whnf (← instantiateMVars formula)
  let name := formula.getAppFn.constName?
  for (operator, arity) in #[(`imp, 2), (`box, 1), (`untl, 2), (`snce, 2)] do
    if name == some (← operatorConst language.formulaType operator) then
      let mut size := 1
      for argument in formula.getAppArgs[:arity] do
        size := size + (← primitiveSize language argument (fuel - 1))
        if size > fuel then throwError "formula size calculation exceeded {fuel} constructors"
      return size
  if language == .plus then
    if name == some (← operatorConst language.formulaType `stab) then
      return 1 + (← primitiveSize language formula.getAppArgs[0]! (fuel - 1))
  return 1

/-- The requirements of a path, expressed entirely in formula-syntax metadata. -/
structure PathPlan where
  /-- The positions and whether they use an exact adjacent-time scope. -/
  positions : Array (FormulaPosition × Bool)
  /-- Outermost-first nonidentity scope demands. -/
  word : Array Name
  /-- Whether the path reverses implication direction. -/
  flips : Bool

private def positionDemand (p : FormulaPosition) (suggestion : Option Name) : Option Name :=
  match p.name with
  | `boxBody | `possibilityBody => some `box
  | `stabilityBody | `settledPossibilityBody => some `stab
  | `futureBody | `untilGuard | `untilEvent | `futureEvent => some `allFuture
  | `pastBody | `sinceGuard | `sinceEvent | `pastEvent => some `allPast
  | `nextBody => some (if suggestion == some `next then `next else `allFuture)
  | `prevBody => some (if suggestion == some `prev then `prev else `allPast)
  | _ => none

/-- Plan the scope and polarity of a path without elaborating a derivation. -/
def planPath (path : Array FormulaPosition) (evidenceWord : Array Name) : PathPlan := Id.run do
  let mut positions := #[]
  let mut word := #[]
  let mut flips := false
  for p in path do
    let demand := positionDemand p (evidenceWord[word.size]?)
    positions := positions.push (p, demand == some `next || demand == some `prev)
    if let some demand := demand then word := word.push demand
    if p.name == `impLeft || p.name == `negBody then flips := !flips
  return ⟨positions, word, flips⟩

end FormalSystem.Tactic.FormulaPositions

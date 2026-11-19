/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.SemanticMeta
import FormalSystem.Semantics.ProofModeTemporalRules
import FormalSystem.Automation.ProofMode.Temporal
import FormalSystem.Automation.ProofMode.Discrete
import FormalSystem.Metalogic.ProofModeSoundness

/-!
# Pointed semantic proof mode (P4)

The proof-mode commands also act on pointed truth goals `TruthAt M τ t A`, `PlusTruthAt M τ t A`
and `TruthEnv.T M τ t e A`. They produce ordinary Lean proofs from the shared clauses of
`Semantics/TruthClauses.lean` and the pure rules of `Semantics/ProofModeRules.lean`.

## Dispatch

Each semantic elaborator is attached to the existing command syntax and tagged `[no_fallback]`.

* When the main goal is not a supported truth head, it throws `unsupportedSyntax` before changing
  anything, so the native derivation handler of the same command runs.
* Otherwise it owns the command. A failure restores the proof state and reports the semantic
  error. It never falls back to a native rule.

No native derivation is ever built from a semantic proof. The single native-to-semantic route is
`luse_derivation`, which applies the soundness theorems through `Metalogic/ProofModeSoundness.lean`.

## Indices

Every fact's model, history, time, environment, frame and truth dictionary are compared one by one
before its formula is compared and before truth is unfolded. Two atom-free truths at different
points can be definitionally equal after unfolding. They are still different judgments.

A fact at another point is rejected unless the command's own clause moves it:

* `□` instantiation, at any history and the same time;
* `⊡` instantiation, with same-state evidence;
* `G`/`H` instantiation, at a strictly later/earlier time;
* `X`/`Y` instantiation, at a covering time.

Other moves need an explicit transport theorem. Facts are never changed. A witness introduced by a
cases command is placed at its own point, and the goal stays at its original point.

## Commands on truth goals

| Command | Semantic step |
| --- | --- |
| `lexact h` | closes the goal with a fact at the same point and formula |
| `lapply rule` | indexed theorem application with explicit premises |
| `lintro h`, `lsplit`, `lleft`, `lright` | `→`, `∧`, `∨` clauses |
| `lcases h as a b` | `∧` facts at their own point; `∨` facts split the goal |
| `lhave h : A [:= p]` | a new fact at the goal's point |
| `lmodal_intro necessity/settled …` | arbitrary history; ⊡ adds state equality |
| `lmodal_intro possibility/settled_possibility` | exposes the clause's existential |
| `lmodal_witness σ` | supplies the `◇`/`⟐` witness |
| `lmodal_use h [as n]` | `□`/`⊡` instantiated at the goal's history |
| `lmodal_cases h [using [..]] as σ (hstate) a h..` | opens a `◇`/`⟐` witness |
| `ltemporal_intro future/past [using [..]] [as s hs h..]` | arbitrary strictly later/earlier time |
| `ltemporal_witness s` | supplies an `F`/`P`/`X`/`Y` witness |
| `ltemporal_use h` | `G(A → B)` maps `G`/`F` goals (`H`/`P` for the past) |
| `ltemporal_use h at s [as n]` | `G`/`H`/`X`/`Y` instantiated at `s`, leaving its order |
| `ltemporal_cases h [using [..]] as s hs a h..` | opens an `F`/`P`/`X`/`Y` witness |
| `ladvance h [using [..]] as s hs a h..` | `someFuture_bind`/`somePast_bind` |
| `luntil/lsince guard/event using h` | operand monotonicity under `G`/`H` |
| `luntil/lsince witness s` | order, event, then open-interval guard |
| `luntil/lsince cases h as s ord ev guard` | opens the witness, interval and guard |
| `lstep future/past [using [..]] [as s hcov h..]` | covering-time `X`/`Y` step |
| `lprogress using [rule]` | applies a supplied progress theorem |
| `luse_derivation d using hFrame, hContext` | soundness at the goal's exact point |

`keeping [..]` on the temporal commands carries `G P` (or `H P`) to the new later (earlier) time by
`allFuture_persist` (`allPast_persist`); the fact is not unwrapped.

Body names list the new history or time, then its evidence (state equality, order or cover), then
the event (for cases commands), then the `using` captures, then the kept facts. Omitting `using`
captures nothing. Strict `G`/`H` never reaches the current point; there is no temporal T.

The native and semantic interfaces share syntax: `keeping` is read from the raw
syntax of `ltemporal_cases`, `ladvance`, `lstep` and `ltemporal_intro`. Supplied-rule routes
serve `linvariant using`, `linduction using`,
`luntil using`, `lsince using` and `lprogress using rule`.
-/

assert_not_exists FormalSystem.Metalogic.completeness_base
  FormalSystem.Metalogic.completeness_dense FormalSystem.Metalogic.completeness_ztime
  FormalSystem.Metalogic.completeness_rtime

namespace FormalSystem.Automation.ProofMode.Semantic

open Lean Meta Elab Tactic
open FormalSystem.Semantics

/-! ## Dispatch, transactions and elaboration -/

/-- The main goal and its semantic judgment. Any other main goal declines the syntax, so the
native handler of the same command remains available. -/
def semanticMain : TacticM (MVarId × TruthJudgment) := do
  let goal ← try getMainGoal catch _ => throwUnsupportedSyntax
  let some judgment ← goal.withContext do truthJudgment? (← instantiateMVars (← goal.getType))
    | throwUnsupportedSyntax
  return (goal, judgment)

/-- Run a semantic step on a semantic main goal, transactionally, in the goal's context. -/
def runSemantic (k : MVarId → TruthJudgment → TacticM Unit) : TacticM Unit := do
  let (goal, judgment) ← semanticMain
  transactional <| goal.withContext <| k goal judgment

/-- Run a semantic-only command; a non-truth goal is an error rather than a native fallback. -/
def runSemanticOnly (command : String) (k : MVarId → TruthJudgment → TacticM Unit) :
    TacticM Unit := do
  let goal ← getMainGoal
  let some judgment ← goal.withContext do truthJudgment? (← instantiateMVars (← goal.getType))
    | throwError "{command} expects a TM/TM⁺ pointed truth goal with explicit model, history \
        and time"
  transactional <| goal.withContext <| k goal judgment

/-- Assign a goal only after checking the proof's statement. -/
def assignChecked (goal : MVarId) (proof : Expr) : MetaM Unit := do
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "the semantic rule proves a different indexed judgment"
  goal.assign proof

/-- The indexed judgment proved by a semantic fact. Native derivations are rejected. -/
def factJudgment (proof : Expr) : MetaM TruthJudgment := do
  let type ← instantiateMVars (← inferType proof)
  if let some judgment ← truthJudgment? type then return judgment
  if (← judgment? type).isSome then
    throwError "a native derivation is not a semantic truth fact; use \
      `luse_derivation d using hFrame, hContext`"
  throwError "expected an indexed TM/TM⁺ truth fact, but the term has type{indentExpr type}"

/-- Elaborate a semantic fact with no unresolved arguments. -/
def elabFact (stx : Syntax) : TacticM (Expr × TruthJudgment) := do
  let proof ← instantiateMVars (← elabTerm stx none (mayPostpone := false))
  let judgment ← factJudgment proof
  unless (← getMVarsNoDelayed proof).isEmpty do
    throwError "the fact has unresolved arguments; supply them, or use `lapply` to generate \
      its premises"
  return (proof, judgment)

/-- Elaborate an explicit witness or certificate. `?_` holes become goals; any other unresolved
hole is an error, never silently filled. -/
def elabExplicit (stx : Syntax) (expected : Expr) : TacticM (Expr × List MVarId) := do
  let value ← instantiateMVars (← elabTermEnsuringType stx (some expected) (mayPostpone := false))
  let mut goals := #[]
  for mvarId in ← getMVarsNoDelayed value do
    if (← mvarId.getKind).isSyntheticOpaque then goals := goals.push mvarId
    else throwError "the supplied term has unresolved arguments; write `?_` to request a goal"
  return (value, goals.toList)

/-! ## Nominal indices and presentation -/

/-- Present `TruthEnv.T` subterms over `j`'s dictionary through `TruthAt`/`PlusTruthAt`, when that
is the judgment's source surface. The presentation is checked definitionally equal. -/
def present (j : TruthJudgment) (e : Expr) : MetaM Expr := do
  let e := (← instantiateMVars e).headBeta
  unless j.direct do return e
  let head ← mkConstWithFreshMVarLevels (j.language.ruleName ``FormalSystem.Semantics.TruthAt
    ``FormalSystem.PlusLanguage.PlusTruthAt)
  let presented := e.replace fun sub =>
    if sub.isAppOfArity ``TruthEnv.T 8 && sub.getArg! 1 == j.truthEnvironment then
      some (mkAppN head #[sub.getArg! 2, sub.getArg! 3, sub.getArg! 4, sub.getArg! 5,
        sub.getArg! 7])
    else none
  unless ← isDefEq presented e do throwError "internal: truth presentation changed a clause"
  return presented

/-- The checked clause equivalence at `k`'s own point and its presented right-hand side. -/
def clause (k : TruthJudgment) (operator : Name) (arguments : Array Expr) :
    MetaM (Expr × Expr) := do
  let equivalence ← clauseIff k operator arguments
  let type := (← instantiateMVars (← inferType equivalence)).headBeta
  unless type.isAppOfArity ``Iff 2 do throwError "internal: a clause is not an equivalence"
  return (equivalence, ← present k type.appArg!)

/-- Replace a truth goal by its presented clause right-hand side. -/
def introClause (goal : MVarId) (j : TruthJudgment) (operator : Name) (arguments : Array Expr) :
    MetaM MVarId := do
  let (equivalence, rhs) ← clause j operator arguments
  let body ← mkFreshExprSyntheticOpaqueMVar rhs (← goal.getTag)
  assignChecked goal (← mkAppM ``Iff.mpr #[equivalence, body])
  return body.mvarId!

/-- Unfold a fact by its clause at the fact's own point; returns the proof and its statement. -/
def elimClause (k : TruthJudgment) (operator : Name) (arguments : Array Expr) (fact : Expr) :
    MetaM (Expr × Expr) := do
  let (equivalence, rhs) ← clause k operator arguments
  let proof ← mkAppM ``Iff.mp #[equivalence, fact]
  return (← mkExpectedTypeHint proof rhs, rhs)

/-- Build nested conjunction proofs from fresh goals, in conjunct order. -/
partial def splitGoals (type : Expr) (tag : Name) : MetaM (Expr × Array MVarId) := do
  let type := (← instantiateMVars type).headBeta
  if type.isAppOfArity ``And 2 then
    let (left, leftGoals) ← splitGoals type.appFn!.appArg! tag
    let (right, rightGoals) ← splitGoals type.appArg! tag
    return (← mkAppM ``And.intro #[left, right], leftGoals ++ rightGoals)
  let goal ← mkFreshExprSyntheticOpaqueMVar type tag
  return (goal, #[goal.mvarId!])

/-- Supply the witness of an existential clause; its conjuncts become goals in clause order. -/
def introWitness (goal : MVarId) (j : TruthJudgment) (operator : Name) (arguments : Array Expr)
    (witness : Syntax) : TacticM (List MVarId) := do
  let (equivalence, rhs) ← clause j operator arguments
  unless rhs.isAppOfArity ``Exists 2 do throwError "internal: expected an existential clause"
  let domain := rhs.appFn!.appArg!
  let body := rhs.appArg!
  let (value, holes) ← elabExplicit witness domain
  let (proof, goals) ← splitGoals (body.beta #[value]) (← goal.getTag)
  let packed ← mkAppOptM ``Exists.intro #[domain, body, value, proof]
  assignChecked goal (← mkAppM ``Iff.mpr #[equivalence, packed])
  return holes ++ goals.toList

/-- Destructure `∃`/`∧` evidence into named hypotheses; the goal itself is unchanged. The last
name receives the remaining evidence. Returns the hypotheses in order. -/
partial def destruct (goal : MVarId) (proof : Expr) (names : List Name) :
    MetaM (MVarId × Array FVarId) := goal.withContext do
  let type := (← instantiateMVars (← inferType proof)).headBeta
  match names with
  | [] => throwError "internal: no hypothesis names"
  | [name] =>
    let (fvar, goal) ← goal.note name proof
    return (goal, #[fvar])
  | name :: rest =>
    if type.isAppOfArity ``Exists 2 then
      let domain := type.appFn!.appArg!
      let body := type.appArg!
      let target ← goal.getType
      let motive ← withLocalDeclD name domain fun x => do
        mkForallFVars #[x] (← mkArrow (body.beta #[x]).headBeta target)
      let next ← mkFreshExprSyntheticOpaqueMVar motive (← goal.getTag)
      goal.assign (← mkAppOptM ``Exists.elim #[domain, body, target, proof, next])
      let (fvars, inner) ← next.mvarId!.introN 2 [name, `evidence]
      let (inner, named) ← destruct inner (mkFVar fvars[1]!) rest
      let inner ← (try inner.clear fvars[1]! catch _ => pure inner)
      return (inner, #[fvars[0]!] ++ named)
    else if type.isAppOfArity ``And 2 then
      let (fvar, goal) ← goal.note name (← mkAppM ``And.left #[proof])
      let (goal, named) ← destruct goal (← mkAppM ``And.right #[proof]) rest
      return (goal, #[fvar] ++ named)
    else throwError "too many names for this evidence"

/-- Name a derived fact at a stated point, presented through `j`'s surface. -/
def noteAt (goal : MVarId) (name : Name) (j : TruthJudgment) (formula proof history time : Expr) :
    MetaM MVarId := goal.withContext do
  let expected ← truthType j formula (some history) (some time)
  unless ← isDefEq (← inferType proof) expected do
    throwError "internal: a derived fact is not at its stated point"
  let (_, goal) ← goal.note name (← mkExpectedTypeHint proof expected)
  return goal

/-- Read a unary operator of a known language without asking TM for TM⁺ stability. -/
def unary? (language : Language) (operator : Name) (formula : Expr) :
    MetaM (Option Expr) := do
  if (operator == `stab || operator == `dstab) && language != .plus then return none
  return (← operatorArgs? language operator 1 formula).map (·[0]!)

/-! ## Captured guarantees -/

/-- `□P` (at any history) or `⊡P` (at the base history, with same-state evidence), at the base
time, instantiated at the new history `σ`. -/
def modalInstance (base : TruthJudgment) (σ : Expr) (stateEq : Option Expr) (guarantee : Expr) :
    MetaM (Expr × Expr) := do
  let k ← factJudgment guarantee
  sameIndex base k "a modal guarantee" (history := false)
  if let some body ← unary? k.language `box k.formula then
    return (body, mkApp (← elimClause k `box #[body] guarantee).1 σ)
  if let some body ← unary? k.language `stab k.formula then
    let some stateEq := stateEq
      | throwError "a ⊡ guarantee needs same-state evidence; use `lmodal_intro settled`"
    unless ← isDefEq k.history base.history do
      throwError "the ⊡ guarantee is at another history than the same-state evidence"
    return (body, mkApp2 (← elimClause k `stab #[body] guarantee).1 σ stateEq)
  throwError "a modal guarantee must be □P, or ⊡P under settledness, at the scope's time"

/-- `G P`/`H P` (or `X P`/`Y P` at a covering time) at the base point, instantiated at `s`. -/
def temporalInstance (base : TruthJudgment) (past cover : Bool) (s order : Expr)
    (guarantee : Expr) : MetaM (Expr × Expr) := do
  let k ← factJudgment guarantee
  sameIndex base k "a temporal guarantee"
  let universal := if past then `allPast else `allFuture
  if let some body ← unary? k.language universal k.formula then
    let strict ← if cover then mkAppM ``CovBy.lt #[order] else pure order
    return (body, mkApp2 (← elimClause k universal #[body] guarantee).1 s strict)
  if cover then
    let adjacent := if past then `prev else `next
    if let some body ← unary? k.language adjacent k.formula then
      let rule := if past then ``ProofModeTemporalRules.prev_at'
        else ``ProofModeTemporalRules.next_at'
      return (body, ← semanticApp k rule
        #[k.model, k.history, k.time, s, k.environment, body, order, guarantee])
  throwError "a temporal guarantee must be {if past then "H" else "G"}P{if cover then
    (if past then " or YP" else " or XP") else ""} at the scope's point"

/-- Keep `G P` (`H P`) at a strictly later (earlier) time, by persistence. -/
def keptInstance (base : TruthJudgment) (past : Bool) (s strict : Expr) (fact : Expr) :
    MetaM (Expr × Expr) := do
  let k ← factJudgment fact
  sameIndex base k "a kept fact"
  let universal := if past then `allPast else `allFuture
  let some body ← unary? k.language universal k.formula
    | throwError "`keeping` accepts only {if past then "H" else "G"}P facts; a point-local fact \
        stays at its original point"
  let rule := if past then ``ProofModeTemporalRules.past_persist
    else ``ProofModeTemporalRules.future_persist
  return (k.formula, ← semanticApp k rule
    #[k.model, k.history, k.time, s, k.environment, body, fact, strict])

/-- Note `using` captures and kept facts at `(base.history, s)`. -/
def captureTemporal (goal : MVarId) (base : TruthJudgment) (past cover : Bool) (s order : Expr)
    (guarantees kept : Array Expr) (names : Array Name) : MetaM MVarId := do
  let mut goal := goal
  for guarantee in guarantees, name in names do
    goal ← goal.withContext do
      let (formula, proof) ← temporalInstance base past cover s order guarantee
      noteAt goal name base formula proof base.history s
  for fact in kept, name in names.extract guarantees.size names.size do
    goal ← goal.withContext do
      let strict ← if cover then mkAppM ``CovBy.lt #[order] else pure order
      let (formula, proof) ← keptInstance base past s strict fact
      noteAt goal name base formula proof base.history s
  return goal

/-- User-supplied names or defaults, with a checked count. -/
def resolveNames (given defaults : Array Name) (command : String) : MetaM (Array Name) := do
  if given.isEmpty then return defaults
  unless given.size == defaults.size do
    throwError "{command} expects {defaults.size} names, in the order {defaults.toList}"
  return given

/-- Default names `prefix1, prefix2, …`. -/
def numbered (pfx : String) (count : Nat) : Array Name :=
  (List.range count).toArray.map fun i => Name.mkSimple s!"{pfx}{i + 1}"

/-! ## Raw command syntax

The optional `using`/`keeping`/`as` groups are located by keyword, so each handler serves both
the current command shapes and the branch-2 shapes that add `keeping`. -/

/-- The siblings following keyword `keyword` in a command's optional groups. -/
partial def afterKeyword? (stx : Syntax) (keyword : String) : Option (Array Syntax) :=
  go stx.getArgs
where
  /-- Search one level of arguments, descending only into grouping nodes. -/
  go (args : Array Syntax) : Option (Array Syntax) := Id.run do
    for i in [:args.size] do
      let arg := args[i]!
      if arg.isAtom && arg.getAtomVal == keyword then return some (args.extract (i + 1) args.size)
      if arg.getKind == nullKind then
        if let some found := go arg.getArgs then return some found
    return none

/-- The bracketed term list after `keyword`, if the group is present. -/
def termsAfter? (stx : Syntax) (keyword : String) : Option (Array Syntax) :=
  (afterKeyword? stx keyword).map fun rest => rest[1]!.getSepArgs

/-- The identifiers after `as`. -/
def namesAfterAs (stx : Syntax) : Array Name :=
  match afterKeyword? stx "as" with
  | some rest =>
    if rest[0]!.isIdent then #[rest[0]!.getId] else rest[0]!.getArgs.map (·.getId)
  | none => #[]

/-- Elaborate a list of facts. -/
def elabFacts (terms : Array Syntax) : TacticM (Array Expr) :=
  terms.mapM fun term => return (← elabFact term).1

/-! ## Basic commands -/

/-- `lexact`: a semantic fact at the goal's exact point and formula. -/
def semanticExact (goal : MVarId) (j : TruthJudgment) (term : Syntax) : TacticM Unit := do
  let proof ← instantiateMVars (← elabTerm term none (mayPostpone := false))
  let k ← factJudgment proof
  sameIndex j k "the supplied fact"
  unless ← isDefEq k.formula j.formula do
    throwError "the fact proves a different formula{indentExpr k.formula}\nexpected\
      {indentExpr j.formula}"
  let proof ← instantiateMVars proof
  unless (← getMVarsNoDelayed proof).isEmpty do
    throwError "the fact has unresolved arguments; use `lapply` to generate them as goals"
  assignChecked goal proof
  replaceMainGoal []

/-- Synthesize the pending instance parameters of a rule telescope. -/
private def synthPending (params : Array Expr) (binders : Array BinderInfo) (strict : Bool) :
    MetaM Unit := do
  for param in params, binder in binders do
    if binder.isInstImplicit && !(← param.mvarId!.isAssigned) then
      let type ← instantiateMVars (← inferType param)
      if type.hasExprMVar && !strict then continue
      match ← trySynthInstance type with
      | .some value =>
        unless ← isDefEq param value do throwError "instance mismatch{indentExpr type}"
      | _ => if strict then throwError "failed to synthesize{indentExpr type}"

/-- Apply an elaborated Lean rule whose conclusion is an indexed truth judgment.

The conclusion's indices are validated nominally before its formula. Object implications in the
conclusion are peeled into truth premises at the goal's point. Every unassigned metavariable
becomes a goal: elaborator holes (including leading implicit obligations), unassigned rule
proof parameters and peeled premises, then inferable data. Only this invocation owns new
goals. Prop goals are made synthetic-opaque, so later
unification cannot fill them silently. Hypotheses are never searched. -/
def applyRule (goal : MVarId) (j : TruthJudgment) (proof : Expr) (command : String)
    (firstNewIndex : Nat) : TacticM Unit := do
  let proof ← instantiateMVars proof
  let holes ← getMVarsNoDelayed proof
  let type ← instantiateMVars (← inferType proof)
  let (params, binders, conclusion) ← forallMetaTelescope type
  let conclusion ← instantiateMVars conclusion
  if (← judgment? conclusion).isSome then
    throwError "{command} received native derivation data; use `luse_derivation`"
  if conclusion.isAppOfArity ``TruthEnv.T 8 then
    unless ← isDefEq (conclusion.getArg! 0) (mkConst j.language.formulaNamespace) do
      throwError "the rule concludes truth in another object language"
    unless ← isDefEq (conclusion.getArg! 1) j.truthEnvironment do
      throwError "the rule concludes truth over another truth dictionary"
  synthPending params binders false
  let some k ← truthJudgment? (← instantiateMVars conclusion)
    | throwError "{command} expects a theorem concluding an indexed TM/TM⁺ truth judgment, \
        not{indentExpr conclusion}"
  sameIndex j k "the rule's conclusion"
  let mut formula ← instantiateMVars k.formula
  let mut steps : Array (Expr × Expr) := #[]
  let mut matched := false
  for _ in [:64] do
    if ← isDefEq formula j.formula then
      matched := true
      break
    let some args ← operatorArgs? j.language `imp 2 formula
      | throwError "the rule's conclusion{indentExpr formula}\ndoes not match the goal formula\
          {indentExpr j.formula}"
    steps := steps.push (args[0]!, args[1]!)
    formula := args[1]!
  unless matched do throwError "{command} exceeded the implication-chain limit"
  synthPending params binders true
  let mut result := mkAppN proof params
  let mut premises : Array MVarId := #[]
  for (antecedent, consequent) in steps do
    let equivalence ← clauseIff j `imp #[antecedent, consequent]
    let premise ← mkFreshExprSyntheticOpaqueMVar (← truthType j antecedent) (← goal.getTag)
    result ← mkAppM' (← mkAppM ``Iff.mp #[equivalence, result]) #[premise]
    premises := premises.push premise.mvarId!
  assignChecked goal result
  let mut proofGoals : Array MVarId := #[]
  let mut dataGoals : Array MVarId := #[]
  for mvarId in holes ++ params.map (·.mvarId!) ++
      (← getMVarsNoDelayed (← instantiateMVars result)) do
    if (← mvarId.isAssigned) || (← mvarId.getDecl).index < firstNewIndex then continue
    if premises.contains mvarId || proofGoals.contains mvarId || dataGoals.contains mvarId then
      continue
    if ← isProp (← mvarId.getType) then
      mvarId.setKind .syntheticOpaque
      proofGoals := proofGoals.push mvarId
    else
      mvarId.setKind .natural
      dataGoals := dataGoals.push mvarId
  replaceMainGoal (proofGoals ++ premises ++ dataGoals).toList

/-- `lapply`: generic application of a Lean rule ending in an indexed truth. -/
def semanticApply (goal : MVarId) (j : TruthJudgment) (term : Syntax)
    (command : String := "lapply") : TacticM Unit := do
  let firstNewIndex := (← getMCtx).mvarCounter
  let proof ← elabTerm term none (mayPostpone := false)
  if (← judgment? (← instantiateMVars (← inferType proof))).isSome then
    throwError "{command} received native derivation data; use `luse_derivation`"
  applyRule goal j proof command firstNewIndex

/-- `lintro`: the implication clause, then a named premise at the goal's point. -/
def semanticIntro (goal : MVarId) (j : TruthJudgment) (name : Name) : TacticM Unit := do
  let some args ← operatorArgs? j.language `imp 2 j.formula
    | throwError "lintro expected an object implication"
  let (_, body) ← (← introClause goal j `imp args).intro name
  replaceMainGoal [body]

/-- `lsplit`: the conjunction clause, one goal per conjunct. -/
def semanticSplit (goal : MVarId) (j : TruthJudgment) : TacticM Unit := do
  let some args ← operatorArgs? j.language `and 2 j.formula
    | throwError "lsplit expected an object conjunction"
  let (equivalence, rhs) ← clause j `and args
  let (proof, goals) ← splitGoals rhs (← goal.getTag)
  assignChecked goal (← mkAppM ``Iff.mpr #[equivalence, proof])
  replaceMainGoal goals.toList

/-- `lleft`/`lright`: the disjunction clause. -/
def semanticOr (goal : MVarId) (j : TruthJudgment) (left : Bool) : TacticM Unit := do
  let some args ← operatorArgs? j.language `or 2 j.formula
    | throwError "expected an object disjunction"
  let (equivalence, rhs) ← clause j `or args
  let leftType := rhs.appFn!.appArg!
  let rightType := rhs.appArg!
  let branch ← mkFreshExprSyntheticOpaqueMVar (if left then leftType else rightType)
    (← goal.getTag)
  let proof ← mkAppOptM (if left then ``Or.inl else ``Or.inr)
    #[leftType, rightType, branch]
  assignChecked goal (← mkAppM ``Iff.mpr #[equivalence, proof])
  replaceMainGoal [branch.mvarId!]

/-- `lcases`: a conjunction fact at its own point, or a disjunction fact splitting the goal. -/
def semanticCases (goal : MVarId) (_j : TruthJudgment) (term : Syntax) (left right : Name) :
    TacticM Unit := do
  let (fact, k) ← elabFact term
  if let some args ← operatorArgs? k.language `and 2 k.formula then
    let (proof, _) ← elimClause k `and args fact
    let (goal, _) ← destruct goal proof [left, right]
    replaceMainGoal [goal]
  else if let some args ← operatorArgs? k.language `or 2 k.formula then
    let (proof, rhs) ← elimClause k `or args fact
    let target ← goal.getType
    let leftType := rhs.appFn!.appArg!
    let rightType := rhs.appArg!
    let onLeft ← mkFreshExprSyntheticOpaqueMVar (← mkArrow leftType target) (← goal.getTag)
    let onRight ← mkFreshExprSyntheticOpaqueMVar (← mkArrow rightType target) (← goal.getTag)
    goal.assign (← mkAppOptM ``Or.elim #[leftType, rightType, target, proof, onLeft, onRight])
    let (_, leftGoal) ← onLeft.mvarId!.intro left
    let (_, rightGoal) ← onRight.mvarId!.intro right
    replaceMainGoal [leftGoal, rightGoal]
  else
    throwError "lcases expected an object conjunction or disjunction fact"

/-- `lhave`: a named fact at the goal's point, proved now or as the first goal. -/
def semanticHave (goal : MVarId) (j : TruthJudgment) (name : Name) (formulaTerm : Syntax)
    (proofTerm : Option Syntax) : TacticM Unit := do
  let (formula, holes) ← elabExplicit formulaTerm (mkConst j.language.formulaNamespace)
  unless holes.isEmpty do throwError "the asserted formula must be fully specified"
  match proofTerm with
  | none =>
    let proof ← mkFreshExprSyntheticOpaqueMVar (← truthType j formula) (← goal.getTag)
    let (_, continuation) ← goal.note name proof
    replaceMainGoal [proof.mvarId!, continuation]
  | some term =>
    let (fact, k) ← elabFact term
    sameIndex j k "the supplied fact"
    unless ← isDefEq k.formula formula do
      throwError "the supplied fact proves a different formula"
    replaceMainGoal [← noteAt goal name j formula fact j.history j.time]

/-! ## Modal commands -/

/-- `lmodal_intro`: `□`/`⊡` choose an arbitrary history at the same time; the possibilities expose
their existential clause for an explicit witness. -/
def modalIntro (goal : MVarId) (j : TruthJudgment) (kind : Name) (terms : Option (Array Syntax))
    (names : Array Name) : TacticM Unit := do
  match kind with
  | `possibility | `settled_possibility =>
    unless terms.isNone && names.isEmpty do
      throwError "possibility introduction takes no `using`/`as`; supply the witness with \
        `lmodal_witness`"
    let operator := if kind == `possibility then `diamond else `dstab
    let some body ← unary? j.language operator j.formula
      | throwError "the goal is not {if kind == `possibility then "◇" else "⟐"}A in this language"
    replaceMainGoal [← introClause goal j operator #[body]]
  | `necessity | `settled =>
    let settled := kind == `settled
    if settled && j.language != .plus then throwError "settledness requires TM⁺"
    let operator := if settled then `stab else `box
    let some body ← unary? j.language operator j.formula
      | throwError "the goal is not {if settled then "⊡" else "□"}A"
    let guarantees ← elabFacts (terms.getD #[])
    let prefixNames := if settled then #[`σ, `hstate] else #[`σ]
    let names ← resolveNames names (prefixNames ++ numbered "h" guarantees.size) "lmodal_intro"
    let scope ← introClause goal j operator #[body]
    let (fvars, scope) ← scope.introN prefixNames.size (names.extract 0 prefixNames.size).toList
    let σ := mkFVar fvars[0]!
    let stateEq := if settled then some (mkFVar fvars[1]!) else none
    let mut scope := scope
    for guarantee in guarantees, name in names.extract prefixNames.size names.size do
      scope ← scope.withContext do
        let (formula, proof) ← modalInstance j σ stateEq guarantee
        noteAt scope name j formula proof σ j.time
    replaceMainGoal [scope]
  | _ => throwError "expected `necessity`, `settled`, `possibility` or `settled_possibility`"

/-- `lmodal_witness σ`: the `◇`/`⟐` witness; `⟐` also leaves its state equality first. -/
def modalWitness (goal : MVarId) (j : TruthJudgment) (witness : Syntax) : TacticM Unit := do
  for operator in [`diamond, `dstab] do
    if let some body ← unary? j.language operator j.formula then
      replaceMainGoal (← introWitness goal j operator #[body] witness)
      return
  throwError "lmodal_witness expects a ◇ or ⟐ goal"

/-- `lmodal_use`: instantiate `□A` (any history) or `⊡A` (with a state equality) at the goal's
history and time. -/
def modalUse (goal : MVarId) (j : TruthJudgment) (term : Syntax) (name : Option Name) :
    TacticM Unit := do
  let (fact, k) ← elabFact term
  sameIndex j k "the modal fact" (history := false)
  let mut sideGoals : List MVarId := []
  let (body, proof) ← do
    if let some body ← unary? k.language `box k.formula then
      pure (body, mkApp (← elimClause k `box #[body] fact).1 j.history)
    else if let some body ← unary? k.language `stab k.formula then
      let instantiated := mkApp (← elimClause k `stab #[body] fact).1 j.history
      let equality := (← whnfR (← inferType instantiated)).bindingDomain!
      let lhs := equality.appFn!.appArg!
      let rhs := equality.appArg!
      if ← isDefEq lhs rhs then
        pure (body, mkApp instantiated (← mkEqRefl lhs))
      else
        let premise ← mkFreshExprSyntheticOpaqueMVar equality (← goal.getTag)
        sideGoals := [premise.mvarId!]
        pure (body, mkApp instantiated premise)
    else throwError "lmodal_use expected a □ or ⊡ fact"
  match name with
  | none =>
    unless ← isDefEq body j.formula do
      throwError "the modal body does not match the goal; use `as name` to retain it"
    assignChecked goal proof
    replaceMainGoal sideGoals
  | some name =>
    replaceMainGoal (sideGoals ++ [← noteAt goal name j body proof j.history j.time])

/-- `lmodal_cases`: open a `◇`/`⟐` witness at the fact's time. Names: history, (state equality),
event, then `□`/`⊡` captures instantiated at the witness. The goal is unchanged. -/
def modalCases (goal : MVarId) (_j : TruthJudgment) (term : Syntax)
    (terms : Option (Array Syntax)) (names : Array Name) : TacticM Unit := do
  let (fact, k) ← elabFact term
  let (operator, body) ← do
    if let some body ← unary? k.language `diamond k.formula then pure (`diamond, body)
    else if let some body ← unary? k.language `dstab k.formula then pure (`dstab, body)
    else throwError "lmodal_cases expected a ◇ or ⟐ fact"
  let settled := operator == `dstab
  let guarantees ← elabFacts (terms.getD #[])
  let prefixCount := if settled then 3 else 2
  unless names.size == prefixCount + guarantees.size do
    throwError "expected {prefixCount} witness names (history, {if settled then
      "state equality, " else ""}event) and {guarantees.size} capture names"
  let (proof, _) ← elimClause k operator #[body] fact
  let (scope, fvars) ← destruct goal proof (names.extract 0 prefixCount).toList
  let σ := mkFVar fvars[0]!
  let stateEq := if settled then some (mkFVar fvars[1]!) else none
  let mut scope := scope
  for guarantee in guarantees, name in names.extract prefixCount names.size do
    scope ← scope.withContext do
      let (formula, proof) ← modalInstance k σ stateEq guarantee
      noteAt scope name k formula proof σ k.time
  replaceMainGoal [scope]

/-! ## Temporal commands -/

/-- `ltemporal_intro future/past`: an arbitrary strictly later (earlier) time. -/
def temporalIntro (goal : MVarId) (j : TruthJudgment) (past : Bool)
    (terms : Option (Array Syntax)) (kept : Array Syntax) (names : Array Name) :
    TacticM Unit := do
  let operator := if past then `allPast else `allFuture
  let some body ← unary? j.language operator j.formula
    | throwError "the goal is not {if past then "H" else "G"}A"
  let guarantees ← elabFacts (terms.getD #[])
  let keptFacts ← elabFacts kept
  let names ← resolveNames names (#[`s, `hs] ++ numbered "h" guarantees.size ++
    numbered "k" keptFacts.size) "ltemporal_intro"
  let scope ← introClause goal j operator #[body]
  let (fvars, scope) ← scope.introN 2 (names.extract 0 2).toList
  let scope ← captureTemporal scope j past false (mkFVar fvars[0]!) (mkFVar fvars[1]!)
    guarantees keptFacts (names.extract 2 names.size)
  replaceMainGoal [scope]

/-- The eventuality or adjacency operator of a formula: `(operator, past, cover, body)`. -/
def eventOperator? (language : Language) (formula : Expr) :
    MetaM (Option (Name × Bool × Bool × Expr)) := do
  for (operator, past, cover) in [(`someFuture, false, false), (`somePast, true, false),
      (`next, false, true), (`prev, true, true)] do
    if let some body ← unary? language operator formula then
      return some (operator, past, cover, body)
  return none

/-- `ltemporal_witness s`: the `F`/`P`/`X`/`Y` witness, leaving its order then the body. -/
def temporalWitness (goal : MVarId) (j : TruthJudgment) (witness : Syntax) : TacticM Unit := do
  let some (operator, _, _, body) ← eventOperator? j.language j.formula
    | throwError "ltemporal_witness expects an F, P, X or Y goal"
  replaceMainGoal (← introWitness goal j operator #[body] witness)

/-- `ltemporal_cases`: open an `F`/`P`/`X`/`Y` witness at the fact's own point. Names: time,
order (or cover), event, captures, kept. The goal is unchanged. -/
def temporalCases (goal : MVarId) (_j : TruthJudgment) (term : Syntax)
    (terms : Option (Array Syntax)) (kept : Array Syntax) (names : Array Name) :
    TacticM Unit := do
  let (fact, k) ← elabFact term
  let some (operator, past, cover, body) ← eventOperator? k.language k.formula
    | throwError "ltemporal_cases expects an F, P, X or Y fact"
  let guarantees ← elabFacts (terms.getD #[])
  let keptFacts ← elabFacts kept
  unless names.size == 3 + guarantees.size + keptFacts.size do
    throwError "expected time, order and event names, then {guarantees.size} capture and \
      {keptFacts.size} kept names"
  let (proof, _) ← elimClause k operator #[body] fact
  let (scope, fvars) ← destruct goal proof (names.extract 0 3).toList
  let scope ← captureTemporal scope k past cover (mkFVar fvars[0]!) (mkFVar fvars[1]!)
    guarantees keptFacts (names.extract 3 names.size)
  replaceMainGoal [scope]

/-- `ladvance`: the pure eventuality bind. The body at the witness keeps the eventual conclusion;
the original goal is rebuilt by `someFuture_bind` (`somePast_bind`). -/
def advance (goal : MVarId) (j : TruthJudgment) (term : Syntax) (terms : Option (Array Syntax))
    (kept : Array Syntax) (names : Array Name) : TacticM Unit := do
  let (past, conclusion) ← do
    if let some body ← unary? j.language `someFuture j.formula then pure (false, body)
    else if let some body ← unary? j.language `somePast j.formula then pure (true, body)
    else throwError "ladvance expects an F or P goal"
  let operator := if past then `somePast else `someFuture
  let (fact, k) ← elabFact term
  sameIndex j k "the eventuality"
  let some event ← unary? k.language operator k.formula
    | throwError "the eventuality must have the goal's time direction"
  let guarantees ← elabFacts (terms.getD #[])
  let keptFacts ← elabFacts kept
  unless names.size == 3 + guarantees.size + keptFacts.size do
    throwError "expected time, order and event names, then {guarantees.size} capture and \
      {keptFacts.size} kept names"
  let bodyType ← withLocalDeclD names[0]! (← inferType j.time) fun s => do
    let order ← if past then mkAppM ``LT.lt #[s, j.time] else mkAppM ``LT.lt #[j.time, s]
    let eventType ← truthType j event (time := some s)
    let resultType ← truthType j j.formula (time := some s)
    mkForallFVars #[s] (← mkArrow order (← mkArrow eventType resultType))
  let body ← mkFreshExprSyntheticOpaqueMVar bodyType (← goal.getTag)
  let rule := if past then ``ProofModeTemporalRules.past_bind
    else ``ProofModeTemporalRules.future_bind
  assignChecked goal (← semanticApp j rule
    #[j.model, j.history, j.time, j.environment, event, conclusion, fact, body])
  let (fvars, scope) ← body.mvarId!.introN 3 (names.extract 0 3).toList
  let scope ← captureTemporal scope j past false (mkFVar fvars[0]!) (mkFVar fvars[1]!)
    guarantees keptFacts (names.extract 3 names.size)
  replaceMainGoal [scope]

/-- `ltemporal_use h`: a same-point `G(A → B)` maps a `G B`/`F B` goal to `G A`/`F A`
(`H`/`P` for the past). -/
def temporalMap (goal : MVarId) (j : TruthJudgment) (term : Syntax) : TacticM Unit := do
  let (fact, k) ← elabFact term
  sameIndex j k "the scoped implication"
  let (past, inner) ← do
    if let some body ← unary? k.language `allFuture k.formula then pure (false, body)
    else if let some body ← unary? k.language `allPast k.formula then pure (true, body)
    else throwError "ltemporal_use requires G(A → B) or H(A → B); use `ltemporal_use h at s` \
      to instantiate a G/H/X/Y fact"
  let some implication ← operatorArgs? k.language `imp 2 inner
    | throwError "ltemporal_use requires an implication inside its time scope"
  let (universal, eventual) := if past then (`allPast, `somePast) else (`allFuture, `someFuture)
  let (operator, rule) ← do
    if let some body ← unary? j.language universal j.formula then
      unless ← isDefEq body implication[1]! do
        throwError "the scoped implication's conclusion does not match the goal"
      pure (universal, if past then ``ProofModeTemporalRules.past_map
        else ``ProofModeTemporalRules.future_map)
    else if let some body ← unary? j.language eventual j.formula then
      unless ← isDefEq body implication[1]! do
        throwError "the scoped implication's conclusion does not match the goal"
      pure (eventual, if past then ``ProofModeTemporalRules.somePast_map
        else ``ProofModeTemporalRules.someFuture_map)
    else throwError "the goal must have the implication's time direction (G/F or H/P)"
  let premiseFormula ← formulaApp j.language operator #[implication[0]!]
  let premise ← mkFreshExprSyntheticOpaqueMVar (← truthType j premiseFormula) (← goal.getTag)
  assignChecked goal (← semanticApp j rule #[j.model, j.history, j.time, j.environment,
    implication[0]!, implication[1]!, fact, premise])
  replaceMainGoal [premise.mvarId!]

/-- `ltemporal_use h at s`: instantiate `G A`/`H A`/`X A`/`Y A` at time `s` on the fact's
history. The order (or cover) premise comes first. Without `as`, the result must close the goal;
`G` never reaches the fact's own time. -/
def temporalUseAt (goal : MVarId) (j : TruthJudgment) (term time : Syntax) (name : Option Name) :
    TacticM Unit := do
  let (fact, k) ← elabFact term
  let (operator, past, cover, body) ← do
    if let some body ← unary? k.language `allFuture k.formula then
      pure (`allFuture, false, false, body)
    else if let some body ← unary? k.language `allPast k.formula then
      pure (`allPast, true, false, body)
    else if let some body ← unary? k.language `next k.formula then pure (`next, false, true, body)
    else if let some body ← unary? k.language `prev k.formula then pure (`prev, true, true, body)
    else throwError "ltemporal_use … at expects a G, H, X or Y fact"
  let (s, holes) ← elabExplicit time (← inferType k.time)
  let (earlier, later) := if past then (s, k.time) else (k.time, s)
  let orderType ← mkAppM (if cover then ``CovBy else ``LT.lt) #[earlier, later]
  let order ← mkFreshExprSyntheticOpaqueMVar orderType (← goal.getTag)
  let proof ← if cover then
      semanticApp k
        (if past then ``ProofModeTemporalRules.prev_at' else ``ProofModeTemporalRules.next_at')
        #[k.model, k.history, k.time, s, k.environment, body, order, fact]
    else pure (mkApp2 (← elimClause k operator #[body] fact).1 s order)
  match name with
  | none =>
    sameIndex j { k with time := s, formula := body } "the instantiated fact"
    unless ← isDefEq body j.formula do
      throwError "the instantiated body does not match the goal; use `as name` to retain it"
    assignChecked goal proof
    replaceMainGoal (holes ++ [order.mvarId!])
  | some name =>
    replaceMainGoal (holes ++ [order.mvarId!, ← noteAt goal name k body proof k.history s])

/-- `lstep future/past`. Without guarantees, the `X`/`Y` goal becomes the existence of a covering
time with the body there. With guarantees, the first must be `X P`/`Y P` at the goal's point and
supplies the covering time; later `X`/`Y`/`G`/`H` captures and kept `G`/`H` facts move to it. No
discreteness or existence is assumed. -/
def step (goal : MVarId) (j : TruthJudgment) (past : Bool) (terms : Option (Array Syntax))
    (kept : Array Syntax) (names : Array Name) : TacticM Unit := do
  let operator := if past then `prev else `next
  let some body ← unary? j.language operator j.formula
    | throwError "lstep {if past then "past" else "future"} expects a \
        {if past then "Y" else "X"} goal"
  let guarantees ← elabFacts (terms.getD #[])
  let keptFacts ← elabFacts kept
  if guarantees.isEmpty then
    unless keptFacts.isEmpty && names.isEmpty do
      throwError "lstep needs an X/Y fact in `using` to supply the covering time before it can \
        name or keep facts"
    replaceMainGoal [← introClause goal j operator #[body]]
    return
  let names ← resolveNames names (#[`s, `hcov] ++ numbered "h" guarantees.size ++
    numbered "k" keptFacts.size) "lstep"
  let first := guarantees[0]!
  let k ← factJudgment first
  sameIndex j k "the covering fact"
  let some firstBody ← unary? k.language operator k.formula
    | throwError "the first `using` fact must be {if past then "Y" else "X"}P at the goal's \
        point; it supplies the covering time"
  let (proof, _) ← elimClause k operator #[firstBody] first
  let (scope, fvars) ← destruct goal proof (names.extract 0 3).toList
  let s := mkFVar fvars[0]!
  let cover := mkFVar fvars[1]!
  let scope ← scope.withContext do
    let (equivalence, rhs) ← clause j operator #[body]
    let domain := rhs.appFn!.appArg!
    let predicate := rhs.appArg!
    let bodyGoal ← mkFreshExprSyntheticOpaqueMVar (← truthType j body (time := some s))
      (← scope.getTag)
    let packed ← mkAppOptM ``Exists.intro
      #[domain, predicate, s, ← mkAppM ``And.intro #[cover, bodyGoal]]
    assignChecked scope (← mkAppM ``Iff.mpr #[equivalence, packed])
    pure bodyGoal.mvarId!
  let scope ← captureTemporal scope j past true s cover (guarantees.extract 1 guarantees.size)
    keptFacts (names.extract 3 names.size)
  replaceMainGoal [scope]

/-! ## Until and Since -/

/-- `luntil/lsince guard/event using h`: operand monotonicity under a same-point `G`/`H`
implication. The new goal keeps the other operand. -/
def binaryMap (goal : MVarId) (j : TruthJudgment) (past guard : Bool) (term : Syntax) :
    TacticM Unit := do
  let operator := if past then `snce else `untl
  let some operands ← operatorArgs? j.language operator 2 j.formula
    | throwError "expected the corresponding {if past then "Since" else "Until"} goal"
  let (fact, k) ← elabFact term
  sameIndex j k "the scoped implication"
  let some inner ← unary? k.language (if past then `allPast else `allFuture) k.formula
    | throwError "monotonicity requires {if past then "H" else "G"}(A → operand)"
  let some implication ← operatorArgs? k.language `imp 2 inner
    | throwError "monotonicity requires a scoped implication"
  let target := if guard then operands[0]! else operands[1]!
  unless ← isDefEq implication[1]! target do
    throwError "the implication's conclusion does not match the selected operand"
  let source := implication[0]!
  let sourceOperands := if guard then #[source, operands[1]!] else #[operands[0]!, source]
  let premiseFormula ← formulaApp j.language operator sourceOperands
  let premise ← mkFreshExprSyntheticOpaqueMVar (← truthType j premiseFormula) (← goal.getTag)
  let rule := match past, guard with
    | false, true => ``ProofModeTemporalRules.until_guard_map
    | false, false => ``ProofModeTemporalRules.until_event_map
    | true, true => ``ProofModeTemporalRules.since_guard_map
    | true, false => ``ProofModeTemporalRules.since_event_map
  let explicit := if guard then #[source, operands[0]!, operands[1]!]
    else #[operands[0]!, source, operands[1]!]
  assignChecked goal (← semanticApp j rule
    (#[j.model, j.history, j.time, j.environment] ++ explicit ++ #[fact, premise]))
  replaceMainGoal [premise.mvarId!]

/-- `luntil/lsince witness s`: strict order, event at `s`, then the open-interval guard. -/
def binaryWitness (goal : MVarId) (j : TruthJudgment) (past : Bool) (witness : Syntax) :
    TacticM Unit := do
  let operator := if past then `snce else `untl
  let some operands ← operatorArgs? j.language operator 2 j.formula
    | throwError "expected the corresponding {if past then "Since" else "Until"} goal"
  replaceMainGoal (← introWitness goal j operator operands witness)

/-- `luntil/lsince cases h as s order event guard`: the witness, its strict order, the event and
the open-interval guard, all at the fact's own history. The goal is unchanged. -/
def binaryCases (goal : MVarId) (_j : TruthJudgment) (past : Bool) (term : Syntax)
    (names : Array Name) : TacticM Unit := do
  let operator := if past then `snce else `untl
  let (fact, k) ← elabFact term
  let some operands ← operatorArgs? k.language operator 2 k.formula
    | throwError "expected {if past then "a Since" else "an Until"} fact"
  let (proof, _) ← elimClause k operator operands fact
  let (goal, _) ← destruct goal proof names.toList
  replaceMainGoal [goal]

/-! ## Rule routes and the soundness seam -/

/-- Generic rule application after a goal-shape check. -/
def ruleRoute (goal : MVarId) (j : TruthJudgment) (term : Syntax) (command : String)
    (operators : List (Name × Nat)) : TacticM Unit := do
  let mut shaped := false
  for (operator, arity) in operators do
    if (operator == `stab || operator == `dstab) && j.language != .plus then continue
    if (← operatorArgs? j.language operator arity j.formula).isSome then shaped := true
  unless shaped do
    throwError "{command} expects a goal headed by one of {operators.map (·.1)}"
  semanticApply goal j term command

/-- Semantic `linvariant using rule` / `linduction using rule`: a supplied theorem for a `G`/`H`
goal. Frame-polymorphic durations get no built-in induction. -/
def semanticUniversalRule (term : Syntax) (command : String := "linvariant using") :
    TacticM Unit :=
  runSemantic fun goal j => ruleRoute goal j term command [(`allFuture, 1), (`allPast, 1)]

/-- Semantic `luntil using rule` / `lsince using rule`. -/
def semanticBinaryRule (past : Bool) (term : Syntax) : TacticM Unit :=
  runSemantic fun goal j => ruleRoute goal j term (if past then "lsince using" else "luntil using")
    [(if past then `snce else `untl, 2)]

/-- Semantic `lprogress using rule`: a supplied progress theorem (e.g. a `rank_progress_truth`
instance, with its rank, well-foundedness and occurrence premises) for an `F`/`P`/`G`/`H` goal. -/
def semanticProgressRule (term : Syntax) : TacticM Unit :=
  runSemantic fun goal j => ruleRoute goal j term "lprogress using"
    [(`someFuture, 1), (`somePast, 1), (`allFuture, 1), (`allPast, 1)]

/-- `luse_derivation d using hFrame, hContext`: the one-way soundness seam at the goal's exact
model, history and time. The abstract object context is accepted through `hContext` without
enumeration; `hFrame : fc.Sat F` includes regularity at `.Base`. -/
def useDerivation (goal : MVarId) (j : TruthJudgment) (derivation frame context : Syntax) :
    TacticM Unit := do
  let tree ← instantiateMVars (← elabTerm derivation none (mayPostpone := false))
  unless (← getMVarsNoDelayed tree).isEmpty do
    throwError "the derivation has unresolved arguments"
  let some native ← judgment? (← inferType tree)
    | throwError "luse_derivation expects a native TM/TM⁺ derivation tree; use `lexact` or \
        `lapply` for semantic facts"
  unless native.language == j.language do
    throwError "the derivation is in another object language; translate it explicitly first"
  let canonical := mkConst (j.language.ruleName ``FormalSystem.Semantics.instTruthEnvFormula
    ``FormalSystem.PlusLanguage.instTruthEnvPlusFormula)
  unless ← isDefEq j.truthEnvironment canonical do
    throwError "the goal uses a non-canonical TruthEnv dictionary; interpret it into the \
      canonical TM/TM⁺ truth relation explicitly before applying soundness"
  unless ← isDefEq native.formula j.formula do
    throwError "the derivation proves{indentExpr native.formula}\nbut the goal is\
      {indentExpr j.formula}"
  let rule := match j.language, j.direct with
    | .tm, true => ``FormalSystem.Metalogic.ProofModeSoundness.truthAt_of_derivation
    | .tm, false => ``FormalSystem.Metalogic.ProofModeSoundness.truthEnv_of_derivation
    | .plus, true => ``FormalSystem.Metalogic.ProofModeSoundness.plusTruthAt_of_derivation
    | .plus, false => ``FormalSystem.Metalogic.ProofModeSoundness.plusTruthEnv_of_derivation
  let partialProof ← mkAppM rule #[tree, j.frame]
  let frameType := (← whnfR (← inferType partialProof)).bindingDomain!
  let (frameProof, frameGoals) ← elabExplicit frame frameType
  let point := #[frameProof, j.model, j.history, j.time] ++
    (if j.direct then #[] else #[j.environment])
  let partialProof ← mkAppM' partialProof point
  let contextType ← present j (← whnfR (← inferType partialProof)).bindingDomain!
  let (contextProof, contextGoals) ← elabExplicit context contextType
  assignChecked goal (← mkAppM' partialProof #[contextProof])
  replaceMainGoal (frameGoals ++ contextGoals)

/-! ## New command syntax -/

/-- Supply the witness history of a `◇`/`⟐` truth goal. -/
syntax (name := lmodalWitness) "lmodal_witness" ppSpace colGt term : tactic

/-- Supply the witness time of an `F`/`P`/`X`/`Y` truth goal. -/
syntax (name := ltemporalWitness) "ltemporal_witness" ppSpace colGt term : tactic

/-- Instantiate a `G`/`H`/`X`/`Y` truth fact at a time, leaving its order or cover premise. -/
syntax (name := ltemporalUseAt) "ltemporal_use" ppSpace colGt term ppSpace "at" ppSpace colGt term
  (ppSpace "as" ppSpace colGt ident)? : tactic

/-- Supply the witness time of an Until truth goal. -/
syntax (name := luntilWitness) "luntil" ppSpace &"witness" ppSpace colGt term : tactic

/-- Supply the witness time of a Since truth goal. -/
syntax (name := lsinceWitness) "lsince" ppSpace &"witness" ppSpace colGt term : tactic

/-- Open an Until truth fact: witness time, strict order, event and open-interval guard. -/
syntax (name := luntilCases) "luntil" ppSpace &"cases" ppSpace colGt term ppSpace "as"
  ppSpace colGt ident ppSpace colGt ident ppSpace colGt ident ppSpace colGt ident : tactic

/-- Open a Since truth fact: witness time, strict order, event and open-interval guard. -/
syntax (name := lsinceCases) "lsince" ppSpace &"cases" ppSpace colGt term ppSpace "as"
  ppSpace colGt ident ppSpace colGt ident ppSpace colGt ident ppSpace colGt ident : tactic

/-- Apply native soundness at the goal's point: `d`, then `fc.Sat F`, then truth of the context. -/
syntax (name := luseDerivation) "luse_derivation" ppSpace colGt term ppSpace "using"
  ppSpace colGt term "," ppSpace colGt term : tactic

/-! ## Elaborators -/

private def futureOrPast (kind : Syntax) : MetaM Bool :=
  match kind.getId with
  | `future => pure false
  | `past => pure true
  | _ => throwError "expected `future` or `past`"

private def guardOrEvent (kind : Syntax) : MetaM Bool :=
  match kind.getId with
  | `guard => pure true
  | `event => pure false
  | _ => throwError "expected `guard` or `event`"

/-- Semantic `lexact`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lexact]
def evalLexact : Tactic := fun stx =>
  runSemantic fun goal j => semanticExact goal j stx[1]

/-- Semantic `lapply`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lapply]
def evalLapply : Tactic := fun stx =>
  runSemantic fun goal j => semanticApply goal j stx[1]

/-- Semantic `lintro`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lintro]
def evalLintro : Tactic := fun stx =>
  runSemantic fun goal j => semanticIntro goal j stx[1].getId

/-- Semantic `lsplit`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lsplit]
def evalLsplit : Tactic := fun _ =>
  runSemantic fun goal j => semanticSplit goal j

/-- Semantic `lleft`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lleft]
def evalLleft : Tactic := fun _ =>
  runSemantic fun goal j => semanticOr goal j true

/-- Semantic `lright`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lright]
def evalLright : Tactic := fun _ =>
  runSemantic fun goal j => semanticOr goal j false

/-- Semantic `lcases`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lcases]
def evalLcases : Tactic := fun stx =>
  runSemantic fun goal j => semanticCases goal j stx[1] stx[3].getId stx[4].getId

/-- Semantic `lhave`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lhave]
def evalLhave : Tactic := fun stx =>
  runSemantic fun goal j => do
    let proof := (afterKeyword? stx ":=").map (·[0]!)
    semanticHave goal j stx[1].getId stx[3] proof

/-- Semantic `lmodal_intro`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lmodalIntro]
def evalLmodalIntro : Tactic := fun stx =>
  runSemantic fun goal j =>
    modalIntro goal j stx[1].getId (termsAfter? stx "using") (namesAfterAs stx)

/-- Semantic `lmodal_use`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lmodalUse]
def evalLmodalUse : Tactic := fun stx =>
  runSemantic fun goal j => modalUse goal j stx[1] (namesAfterAs stx)[0]?

/-- Semantic `lmodal_cases`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lmodalCases]
def evalLmodalCases : Tactic := fun stx =>
  runSemantic fun goal j =>
    modalCases goal j stx[1] (termsAfter? stx "using") (namesAfterAs stx)

/-- `lmodal_witness`. -/
@[no_fallback, tactic lmodalWitness]
def evalLmodalWitness : Tactic := fun stx =>
  runSemanticOnly "lmodal_witness" fun goal j => modalWitness goal j stx[1]

/-- Semantic `ltemporal_intro`; also serves the branch-2 `keeping` shape. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.ltemporalIntro,
  tactic FormalSystem.Automation.ProofMode.ltemporalIntroKeeping]
def evalLtemporalIntro : Tactic := fun stx =>
  runSemantic fun goal j => do
    temporalIntro goal j (← futureOrPast stx[1]) (termsAfter? stx "using")
      ((termsAfter? stx "keeping").getD #[]) (namesAfterAs stx)

/-- `ltemporal_witness`. -/
@[no_fallback, tactic ltemporalWitness]
def evalLtemporalWitness : Tactic := fun stx =>
  runSemanticOnly "ltemporal_witness" fun goal j => temporalWitness goal j stx[1]

/-- Semantic `ltemporal_cases`; also serves the branch-2 `keeping` shape. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.ltemporalCases]
def evalLtemporalCases : Tactic := fun stx =>
  runSemantic fun goal j =>
    temporalCases goal j stx[1] (termsAfter? stx "using") ((termsAfter? stx "keeping").getD #[])
      (namesAfterAs stx)

/-- Semantic `ladvance`; also serves the branch-2 `keeping` shape. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.ladvance]
def evalLadvance : Tactic := fun stx =>
  runSemantic fun goal j =>
    advance goal j stx[1] (termsAfter? stx "using") ((termsAfter? stx "keeping").getD #[])
      (namesAfterAs stx)

/-- Semantic `ltemporal_use h`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.ltemporalUse]
def evalLtemporalUse : Tactic := fun stx =>
  runSemantic fun goal j => temporalMap goal j stx[1]

/-- `ltemporal_use h at s [as n]`. -/
@[no_fallback, tactic ltemporalUseAt]
def evalLtemporalUseAt : Tactic := fun stx =>
  runSemanticOnly "ltemporal_use … at" fun goal j =>
    temporalUseAt goal j stx[1] stx[3] (namesAfterAs stx)[0]?

/-- Semantic `lprogress using [rule]`: exactly one supplied progress theorem. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lprogress]
def evalLprogress : Tactic := fun stx =>
  runSemantic fun goal j => do
    let terms := (termsAfter? stx "using").getD #[]
    unless terms.size == 1 do
      throwError "semantic lprogress applies exactly one supplied progress theorem"
    ruleRoute goal j terms[0]! "lprogress using"
      [(`someFuture, 1), (`somePast, 1), (`allFuture, 1), (`allPast, 1)]

/-- Semantic `luntil guard/event using h`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.luntil]
def evalLuntil : Tactic := fun stx =>
  runSemantic fun goal j => do binaryMap goal j false (← guardOrEvent stx[1]) stx[3]

/-- Semantic `lsince guard/event using h`. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lsince]
def evalLsince : Tactic := fun stx =>
  runSemantic fun goal j => do binaryMap goal j true (← guardOrEvent stx[1]) stx[3]

/-- `luntil witness s`. -/
@[no_fallback, tactic luntilWitness]
def evalLuntilWitness : Tactic := fun stx =>
  runSemanticOnly "luntil witness" fun goal j => binaryWitness goal j false stx[2]

/-- `lsince witness s`. -/
@[no_fallback, tactic lsinceWitness]
def evalLsinceWitness : Tactic := fun stx =>
  runSemanticOnly "lsince witness" fun goal j => binaryWitness goal j true stx[2]

/-- `luntil cases h as s order event guard`. -/
@[no_fallback, tactic luntilCases]
def evalLuntilCases : Tactic := fun stx =>
  runSemanticOnly "luntil cases" fun goal j =>
    binaryCases goal j false stx[2] #[stx[4].getId, stx[5].getId, stx[6].getId, stx[7].getId]

/-- `lsince cases h as s order event guard`. -/
@[no_fallback, tactic lsinceCases]
def evalLsinceCases : Tactic := fun stx =>
  runSemanticOnly "lsince cases" fun goal j =>
    binaryCases goal j true stx[2] #[stx[4].getId, stx[5].getId, stx[6].getId, stx[7].getId]

/-- Semantic `lstep future/past`; also serves the branch-2 `keeping` shape. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lstep]
def evalLstep : Tactic := fun stx =>
  runSemantic fun goal j => do
    step goal j (← futureOrPast stx[1]) (termsAfter? stx "using")
      ((termsAfter? stx "keeping").getD #[]) (namesAfterAs stx)

/-- Semantic `linvariant future/past`: there is no frame-polymorphic semantic invariance rule. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.linvariant]
def evalLinvariant : Tactic := fun _ =>
  runSemantic fun _ _ =>
    throwError "semantic invariance needs an explicit rule for this duration carrier: use \
      `linvariant using rule` (or `lapply rule`) with its premises"

/-- Apply a supplied semantic invariance/induction rule for the actual duration carrier. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.linvariantRule,
  tactic FormalSystem.Automation.ProofMode.linductionRule]
def evalSemanticUniversalRule : Tactic := fun stx => semanticUniversalRule stx[2]

/-- Apply a supplied semantic Until rule. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.luntilRule]
def evalSemanticUntilRule : Tactic := fun stx => semanticBinaryRule false stx[2]

/-- Apply a supplied semantic Since rule. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lsinceRule]
def evalSemanticSinceRule : Tactic := fun stx => semanticBinaryRule true stx[2]

/-- Apply a supplied semantic progress rule, retaining rank and occurrence premises. -/
@[no_fallback, tactic FormalSystem.Automation.ProofMode.lprogressRule]
def evalSemanticProgressRule : Tactic := fun stx => semanticProgressRule stx[2]

/-- `luse_derivation d using hFrame, hContext`. -/
@[no_fallback, tactic luseDerivation]
def evalLuseDerivation : Tactic := fun stx =>
  runSemanticOnly "luse_derivation" fun goal j => useDerivation goal j stx[1] stx[3] stx[5]

end FormalSystem.Automation.ProofMode.Semantic

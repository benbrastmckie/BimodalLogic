/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.SemanticMeta
import FormalSystem.Automation.ProofMode.Temporal
import FormalSystem.Semantics.ProofModeTransport

/-!
# Certified fact/goal transport and time reflection for pointed truth

Moves a semantic fact or goal between fully indexed truth judgments along an explicit
certificate. The source judgment is compared with the certificate index by index (language,
frame, truth dictionary, model, history, time, environment, then formula) through
`samePoint`; truth is never unfolded to decide whether two points agree, so a boxed formula at
one history is not accepted at another. The target point is read from the certificate, never
chosen by the tactic.

## Grammar

```text
ltransport [←] h using c [with hR] as h'   -- fact: h : At p A  ⊢  h' : At q B
ltransport [←] using c [with hR]           -- goal: At p A  ↝  At q B
ltime_reflect                              -- semantic goal: converse model/history/time
ltime_reflect using c [as h']              -- reflect a fact, or apply a reflection certificate
```

`c` is one of

| Type of `c` | Fact (`ltransport h`) | Goal (`ltransport`) |
| --- | --- | --- |
| `FactTransport R M M' A B`, with `hR : R p q` | `At p A ⟹ At q B` | refused |
| `GoalTransport R M M' A B`, with `hR : R p q` | refused | `At p A ↝ At q B` |
| `IffTransport R M M' A B`, with `hR : R p q` | `At p A ⟹ At q B` | `At p A ↝ At q B` |
| Lean function `X → Y` between truth judgments | `X ⟹ Y` | goal `Y ↝ X` |
| Lean `X ↔ Y` between truth judgments | `X ⟹ Y` | goal `X ↝ Y` |

`←` uses an `Iff` or `IffTransport` right to left; it is refused for one-way certificates.
`with hR` is required for the three kernel certificates and refused otherwise: its type
determines both points. The point relations of `Semantics/ProofModeTransport.lean` have `.intro`
lemmas at explicit points (`Shifted.intro σ t Δ`, `SameStateNow.intro τ σ t h`, …).

After matching, every remaining hole of `c` must be determined: an inert singleton environment
(`PUnit`) is filled with its unique value, a `PlusFormula.StateLocal φ` premise is discharged by
the syntactic recognizer below (Until/Since are refused), another `Prop` hole becomes a side
goal, and any other hole is an error. No point, model, history, time or formula is guessed.

## Time reflection

`ltime_reflect` on a semantic goal applies `truthAt_rev`/`plusTruthAt_rev` backwards: the new goal
is at `M.rev`, `τ.rev`, `-t` with `A.reflectTime`, on the converse frame. `ltime_reflect using h`
with a semantic fact gives the reflected fact (named with `as`, otherwise it must close the goal
at exactly the reflected point). A reflection that stays in the same model needs an explicit
certificate: `ltime_reflect using c` with `c` a function/`Iff` between truth judgments whose
formula on the new side is the `reflectTime` of the current goal's. Only the canonical TM/TM⁺
truth dictionary is reflected.

On a native goal, `ltime_reflect` and `ltime_reflect using d` (with `d` not a semantic fact)
defer to the native elaborator. Once a semantic goal or fact is recognized, a failure is
reported here and does not fall back (`no_fallback`). Every command is transactional.
-/

namespace FormalSystem.Automation.ProofMode.Semantic

open Lean Meta Elab Tactic
open FormalSystem.Semantics

/-! ## Certificates -/

/-- The direction a kernel certificate supports. -/
private inductive KernelKind where
  | fact
  | goal
  | both

/-- A certificate after instantiation at its relation evidence: a function or an equivalence
between two pointed truth judgments, with the proof and its kernel kind (if any). -/
private structure Certificate where
  proof : Expr
  left : TruthJudgment
  right : TruthJudgment
  equivalence : Bool
  kernel : Option KernelKind

private def kernelKind? (type : Expr) : Option KernelKind :=
  match type.getAppFn.constName? with
  | some ``FormalSystem.Semantics.ProofModeRules.FactTransport => some .fact
  | some ``FormalSystem.Semantics.ProofModeRules.GoalTransport => some .goal
  | some ``FormalSystem.Semantics.ProofModeTransport.IffTransport => some .both
  | _ => none

private def requireJudgment' (type : Expr) (role : String) : MetaM TruthJudgment := do
  let some j ← truthJudgment? type
    | throwError "{role} is not a TM/TM⁺ pointed truth judgment:{indentExpr type}"
  return j

/-- Read a function or equivalence between truth judgments; nothing else is a certificate. -/
private def readShape? (proof : Expr) (kernel : Option KernelKind) :
    MetaM (Option Certificate) := do
  let type ← whnfR (← instantiateMVars (← inferType proof))
  if type.isAppOfArity ``Iff 2 then
    let some a ← truthJudgment? type.getAppArgs[0]! | return none
    let some b ← truthJudgment? type.getAppArgs[1]! | return none
    return some ⟨proof, a, b, true, kernel⟩
  if let .forallE _ domain body _ := type then
    unless body.hasLooseBVars do
      let some a ← truthJudgment? domain | return none
      let some b ← truthJudgment? body | return none
      return some ⟨proof, a, b, false, kernel⟩
  return none

/-- Elaborate a certificate, instantiating a kernel certificate at its relation evidence. -/
private def elaborateCertificate (term : Syntax) (evidence : Option Syntax) :
    TacticM Certificate := do
  let raw ← Term.withSynthesize <| Term.elabTerm term none
  let rawType ← whnfR (← instantiateMVars (← inferType raw))
  match kernelKind? rawType, evidence with
  | some kind, some evidence =>
    let rule := match kind with
      | .fact => ``FormalSystem.Semantics.ProofModeRules.FactTransport.apply
      | .goal => ``FormalSystem.Semantics.ProofModeRules.GoalTransport.reduce
      | .both => ``FormalSystem.Semantics.ProofModeTransport.IffTransport.apply
    -- `rule raw : ∀ {p q}, R p q → …`: the evidence is elaborated against `R ?p ?q`, so its
    -- type determines both points.
    let mut fn ← mkAppM rule #[raw]
    let mut type ← whnf (← inferType fn)
    for _ in [:2] do
      let .forallE _ domain body .implicit := type
        | throwError "internal: transport rule changed shape"
      let point ← mkFreshExprMVar domain
      fn := mkApp fn point
      type ← whnf (body.instantiate1 point)
    let .forallE _ relation _ _ := type | throwError "internal: transport rule changed shape"
    let hR ← Term.withSynthesize <| Term.elabTermEnsuringType evidence relation
    let applied := mkApp fn hR
    let some certificate ← readShape? applied (some kind)
      | throwError "kernel certificate did not instantiate to pointed truth judgments"
    return certificate
  | some _, none =>
    throwError "a transport certificate needs its relation evidence `with hR : R p q`; the \
      target point is never chosen by the tactic"
  | none, some _ => throwError "`with` is only for FactTransport/GoalTransport/IffTransport"
  | none, none =>
    let some certificate ← readShape? raw none
      | throwError "expected a transport certificate, or a fully applied function/`Iff` between \
          pointed truth judgments; got{indentExpr rawType}"
    return certificate

/-- Name the first index at which two judgments differ (diagnostics only). -/
private def mismatch (expected actual : TruthJudgment) : MetaM MessageData := do
  if expected.language != actual.language then return m!"object language"
  for (label, a, b) in #[("frame", expected.frame, actual.frame),
      ("truth dictionary", expected.truthEnvironment, actual.truthEnvironment),
      ("model", expected.model, actual.model), ("history", expected.history, actual.history),
      ("time", expected.time, actual.time),
      ("environment", expected.environment, actual.environment),
      ("formula", expected.formula, actual.formula)] do
    unless ← withoutModifyingState (isDefEq a b) do
      return m!"{label}: expected{indentExpr (← whnfCore a)}\nbut the certificate has\
        {indentExpr (← whnfCore b)}"
  return m!"unknown index"

/-- Exact indexed comparison: `samePoint` for every point index, then the formula. -/
private def requireSame (expected actual : TruthJudgment) (role : String) : MetaM Unit := do
  unless (← samePoint expected actual) && (← isDefEq expected.formula actual.formula) do
    throwError "{role} is stated at a different judgment; {← mismatch expected actual}"

/-! ## Discharging the remaining holes -/

open FormalSystem.PlusLanguage in
/-- Prove `φ.StateLocal` by the syntactic fragment's own lemmas. Until/Since (hence F, G, P, H,
X, Y) are refused: present-state equality does not transport them. -/
partial def stateLocalProof (φ : Expr) : MetaM Expr := do
  let φ ← instantiateMVars φ
  let reduced ← whnf φ
  let proof ← match reduced.getAppFn.constName?, reduced.getAppArgs with
    | some ``PlusFormula.atom, #[p] => mkAppM ``stateLocal_atom #[p]
    | some ``PlusFormula.bot, #[] => pure (mkConst ``stateLocal_bot)
    | some ``PlusFormula.imp, #[a, b] =>
      mkAppM ``Iff.mpr #[← mkAppM ``stateLocal_imp_iff #[a, b],
        ← mkAppM ``And.intro #[← stateLocalProof a, ← stateLocalProof b]]
    | some ``PlusFormula.box, #[a] => mkAppM ``stateLocal_box #[a]
    | some ``PlusFormula.stab, #[a] => mkAppM ``stateLocal_stab #[a]
    | some ``PlusFormula.untl, _ | some ``PlusFormula.snce, _ =>
      throwError "not state-local: {φ} is an Until/Since formula outside □/⊡; present-state \
        equality does not transport it"
    | _, _ => throwError "cannot classify{indentExpr φ}\nfor state-locality; supply the \
        `StateLocal` evidence explicitly"
  mkExpectedTypeHint proof (← mkAppM ``PlusFormula.StateLocal #[φ])

/-- Fill singleton environments, discharge state-locality, turn other propositions into side
goals, and refuse any undetermined data. -/
private def settleHoles (proof : Expr) : MetaM (List MVarId) := do
  let mut side := #[]
  for mvarId in ← getMVarsNoDelayed (← instantiateMVars proof) do
    if ← mvarId.isAssigned then continue
    let type ← instantiateMVars (← mvarId.getType)
    let reduced ← whnf type
    if reduced.isConstOf ``PUnit then
      mvarId.assign (mkConst ``PUnit.unit reduced.constLevels!)
    else if type.isAppOf ``FormalSystem.PlusLanguage.PlusFormula.StateLocal then
      mvarId.assign (← stateLocalProof type.appArg!)
    else if ← isProp type then
      side := side.push mvarId
    else
      throwError "the certificate leaves{indentExpr type}\nundetermined; points, models, \
        histories, times and formulas are never guessed"
  return side.toList

/-- The judgment with reduced point projections, shown as `TruthAt`/`PlusTruthAt` when the truth
dictionary is the canonical one. -/
private def presentedJudgment (j : TruthJudgment) : MetaM TruthJudgment := do
  let canonical := mkConst (j.language.ruleName ``FormalSystem.Semantics.instTruthEnvFormula
    ``FormalSystem.PlusLanguage.instTruthEnvPlusFormula)
  let direct ← withoutModifyingState (isDefEq j.truthEnvironment canonical)
  return { j with
    model := ← instantiateMVars j.model
    history := ← presentPointIndex j.history
    time := ← presentPointIndex j.time
    environment := ← presentPointIndex j.environment
    formula := (← instantiateMVars j.formula).headBeta
    truthEnvironment := if direct then canonical else j.truthEnvironment
    direct := j.direct || direct }

private def presentedType (j : TruthJudgment) : MetaM Expr := do
  let j ← presentedJudgment j
  truthType j j.formula

/-! ## Fact and goal transport -/

/-- Close the goal or add a fact, checking the presented type against the proof. -/
private def noteFact (goal : MVarId) (name : Name) (proof : Expr) (j : TruthJudgment)
    (side : List MVarId) : TacticM Unit := do
  let type ← presentedType j
  unless ← isDefEq (← inferType proof) type do
    throwError "internal: transported fact does not have its presented type"
  let goal ← nameProof goal name (← mkExpectedTypeHint proof type)
  replaceMainGoal (goal :: side)

private def transportFact (fact certificate : Syntax) (evidence : Option Syntax) (reverse : Bool)
    (name : Name) : TacticM Unit := transactional <| withMainContext do
  let goal ← getMainGoal
  let source ← elaborateProof fact
  let j ← requireJudgment' (← inferType source) "the transported fact"
  let c ← elaborateCertificate certificate evidence
  if let some .goal := c.kernel then
    throwError "a GoalTransport reduces goals only; it cannot move a fact"
  if reverse && !c.equivalence then
    throwError "`←` needs an equivalence; a one-way certificate is not inverted"
  let (from_, to_) := if reverse then (c.right, c.left) else (c.left, c.right)
  requireSame j from_ "the certificate's source"
  let proof ← if !c.equivalence then pure (mkApp c.proof source)
    else mkAppM (if reverse then ``Iff.mpr else ``Iff.mp) #[c.proof, source]
  let side ← settleHoles proof
  let proof ← instantiateMVars proof
  if proof.hasExprMVar && side.isEmpty then
    throwError "the transported fact still has undetermined indices"
  noteFact goal name proof to_ side

private def transportGoal (certificate : Syntax) (evidence : Option Syntax) (reverse : Bool) :
    TacticM Unit := transactional <| withMainContext do
  let goal ← getMainGoal
  let j ← requireTruth goal
  let c ← elaborateCertificate certificate evidence
  if let some .fact := c.kernel then
    throwError "a one-way FactTransport cannot move a goal; supply a GoalTransport, an \
      IffTransport or an `Iff`"
  if reverse && !c.equivalence then
    throwError "`←` needs an equivalence; a one-way certificate is not inverted"
  -- A function `X → Y` reduces the goal `Y` to `X`; an equivalence reduces `X` to `Y`.
  let (current, next) :=
    if !c.equivalence then (c.right, c.left)
    else if reverse then (c.right, c.left) else (c.left, c.right)
  requireSame j current "the certificate's goal side"
  let side ← settleHoles c.proof
  let nextType ← presentedType next
  let nextGoal ← mkFreshExprSyntheticOpaqueMVar nextType (← goal.getTag)
  let proof ← if !c.equivalence then pure (mkApp c.proof nextGoal)
    else mkAppM (if reverse then ``Iff.mp else ``Iff.mpr) #[c.proof, nextGoal]
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "internal: transported goal does not reconstruct the original judgment"
  goal.assign proof
  replaceMainGoal (nextGoal.mvarId! :: side)

/-! ## Time reflection -/

private def reflectionIff (j : TruthJudgment) : MetaM Expr := do
  let canonical := mkConst (j.language.ruleName ``FormalSystem.Semantics.instTruthEnvFormula
    ``FormalSystem.PlusLanguage.instTruthEnvPlusFormula)
  unless ← isDefEq j.truthEnvironment canonical do
    throwError "time reflection is proved for the canonical TM/TM⁺ truth relation; this \
      judgment uses another truth dictionary"
  mkAppM (j.language.ruleName ``FormalSystem.Semantics.truthAt_rev
    ``FormalSystem.PlusLanguage.plusTruthAt_rev) #[j.model, j.history, j.time, j.formula]

private def reflectedFormula (j : TruthJudgment) : MetaM Expr :=
  mkAppM (j.language.ruleName ``FormalSystem.Syntax.Formula.reflectTime
    ``FormalSystem.PlusLanguage.PlusFormula.reflectTime) #[j.formula]

private def reflectGoal : TacticM Unit := transactional <| withMainContext do
  let goal ← getMainGoal
  let j ← requireTruth goal
  let iff ← reflectionIff j
  let some c ← readShape? iff none | throwError "internal: reflection theorem changed shape"
  let next ← mkFreshExprSyntheticOpaqueMVar (← truthType c.right c.right.formula)
    (← goal.getTag)
  let proof ← mkAppM ``Iff.mpr #[iff, next]
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "internal: reflection does not reconstruct the goal"
  goal.assign proof
  replaceMainGoal [next.mvarId!]

/-- Reflect a semantic fact to the converse point; name it or close the goal exactly. -/
private def reflectFact (source : Expr) (j : TruthJudgment) (name : Option Name) :
    TacticM Unit := do
  let goal ← getMainGoal
  let iff ← reflectionIff j
  let some c ← readShape? iff none | throwError "internal: reflection theorem changed shape"
  let proof ← mkAppM ``Iff.mp #[iff, source]
  match name with
  | some name => noteFact goal name proof c.right []
  | none =>
    let some target ← truthJudgment? (← goal.getType)
      | throwError "a reflected semantic fact cannot close a non-semantic goal"
    unless (← samePoint target c.right) && (← isDefEq target.formula c.right.formula) do
      throwError "the reflected fact holds on the converse frame at (M.rev, τ.rev, -t); it does \
        not close this goal ({← mismatch target c.right}). A same-model reflection needs an \
        explicit certificate"
    goal.assign proof
    replaceMainGoal []

/-- Apply an explicit same-model reflection certificate to the goal. -/
private def reflectWithCertificate (raw : Expr) : TacticM Unit := do
  let goal ← getMainGoal
  let j ← requireTruth goal
  let some c ← readShape? raw none
    | throwError "expected a semantic fact, or a function/`Iff` between pointed truth judgments"
  let (current, next) := if c.equivalence then (c.left, c.right) else (c.right, c.left)
  requireSame j current "the reflection certificate's goal side"
  unless ← isDefEq next.formula (← reflectedFormula j) do
    throwError "the certificate's new goal is not the time reflection of the current formula"
  let side ← settleHoles c.proof
  let nextGoal ← mkFreshExprSyntheticOpaqueMVar (← presentedType next) (← goal.getTag)
  let proof ← if c.equivalence then mkAppM ``Iff.mpr #[c.proof, nextGoal]
    else pure (mkApp c.proof nextGoal)
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "internal: reflection certificate does not reconstruct the goal"
  goal.assign proof
  replaceMainGoal (nextGoal.mvarId! :: side)

/-- Semantic `ltime_reflect using`. Declines (for the native elaborator) only when neither the
goal nor the supplied term is semantic. -/
private def reflectUsing (term : Syntax) (name : Option Name) : TacticM Unit :=
    withMainContext do
  let goalSemantic := (← truthJudgment? (← getMainTarget)).isSome
  let elaborated ← if goalSemantic then
      some <$> Term.withSynthesize (Term.elabTerm term none)
    else
      try some <$> Term.withSynthesize (Term.elabTerm term none) catch _ => pure none
  let some raw := elaborated | throwUnsupportedSyntax
  let fact? ← truthJudgment? (← instantiateMVars (← inferType raw))
  match fact?, goalSemantic with
  | some j, _ => transactional (reflectFact raw j name)
  | none, true =>
    if name.isSome then throwError "`as` names a reflected fact, not a certificate application"
    transactional (reflectWithCertificate raw)
  | none, false => throwUnsupportedSyntax

/-! ## Syntax -/

/-- Move a semantic fact along a certificate: `ltransport [←] h using c [with hR] as h'`.
The certificate's source must match `h` index by index; `h'` is at the certificate's target. -/
syntax (name := ltransportFact) "ltransport" (ppSpace "←")? ppSpace colGt term ppSpace "using"
  ppSpace colGt term (ppSpace "with" ppSpace colGt term)? ppSpace "as" ppSpace colGt ident :
  tactic

/-- Reduce a semantic goal along a goal-direction certificate:
`ltransport [←] using c [with hR]`. A one-way fact certificate is refused. -/
syntax (name := ltransportGoal) "ltransport" (ppSpace "←")? ppSpace "using" ppSpace colGt term
  (ppSpace "with" ppSpace colGt term)? : tactic

@[no_fallback] elab_rules : tactic
  | `(tactic| ltransport $[←%$reverse]? $fact:term using $c:term $[with $hR:term]?
      as $name:ident) =>
    transportFact fact c (hR.map (·.raw)) reverse.isSome name.getId
  | `(tactic| ltransport $[←%$reverse]? using $c:term $[with $hR:term]?) =>
    transportGoal c (hR.map (·.raw)) reverse.isSome

/-- Semantic overloads of the native `ltime_reflect` forms. -/
@[no_fallback] elab_rules : tactic
  | `(tactic| ltime_reflect $[as $names:ident*]?) => do
    unless (← truthJudgment? (← getMainTarget)).isSome do throwUnsupportedSyntax
    if names.isSome then
      throwError "a semantic goal has no object context to name; use `ltime_reflect`"
    reflectGoal
  | `(tactic| ltime_reflect using $term:term $[as $name:ident]?) =>
    reflectUsing term (name.map (·.getId))

end FormalSystem.Automation.ProofMode.Semantic

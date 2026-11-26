/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Connectives
import Lean.Elab.SyntheticMVars
import Lean.Meta.Transform

/-!
# Body Generator for the Connective Signature

The term elaborator `sig%`, which turns a signature operator applied at a concrete formula type
into the body a per-language definition stores.

A per-language operator such as `Formula.and` keeps its own name, for dot notation, notation
declarations and docstrings, and takes its body from the signature:

```lean
def Formula.and (φ ψ : Formula) : Formula := sig% Sig.and φ ψ
```

The stored body is `(φ.imp ψ.neg).neg`: the signature operator unfolded **one layer**, with each
operator it mentions replaced by the per-language name and each class projection reduced to the
constructor the instance supplies. It mentions no signature constant, so nothing downstream
that inspects the body of a per-language definition sees the signature.

## Main definitions

- `Sig.survivor?`: the first signature constant an expression mentions, if any
- `Sig.oneLayer`: the generator
- `sig% t`: the term syntax that runs it

## Implementation notes

- **A per-language name must exist before a definition that mentions it.** `sig% Sig.and φ ψ`
  needs `T.neg`; when it is missing, `Sig.neg` survives in the result and the elaborator raises
  an error naming it. Operators are therefore defined in dependency order.
- **A per-language name is used only when it agrees with the signature.** A constant `T.op`
  replaces `Sig.op` only when the two are definitionally equal on the arguments at hand, so a
  language whose `T.op` is something else (a primitive tense, say) is rejected by name and not
  silently given a different encoding.
-/

namespace FormalSystem.Syntax.Sig

open Lean Meta Elab Term

/-- The primitive-operator classes of the signature. -/
def classNames : List Name :=
  [``HasBot, ``HasImp, ``HasBox, ``HasUntl, ``HasSnce, ``HasStab, ``HasAllFuture, ``HasAllPast]

/-- Whether `n` is a signature constant: an operator in `Sig`, or a primitive-operator class or
one of its projections. Instances of the classes are not counted; they occur only as arguments
of the constants that are. -/
def isSigConst (n : Name) : Bool :=
  (`FormalSystem.Syntax.Sig).isPrefixOf n || classNames.any (·.isPrefixOf n)

/-- The first signature constant `e` mentions, if any. -/
def survivor? (e : Expr) : Option Name :=
  (e.find? fun s => s.isConst && isSigConst s.constName!).map (·.constName!)

/-- Generate the body of the per-language operator at the formula type named `T` from the
signature application `e`.

The head operator is delta-unfolded once. In the result, each application of a class projection
is reduced to the constructor the instance supplies, and each application of a signature
operator `Sig.op` is replaced by `T.op`. An error is raised if a signature constant remains,
naming it. -/
def oneLayer (T : Name) (e : Expr) : MetaM Expr := do
  let sigNs := `FormalSystem.Syntax.Sig
  unless e.getAppFn.isConst && sigNs.isPrefixOf e.getAppFn.constName! do
    throwError "sig%: not an application of a signature operator:{indentExpr e}"
  let some e ← delta? e
    | throwError "sig%: not an application of a signature operator:{indentExpr e}"
  let body ← Meta.transform e.headBeta (pre := fun e => do
    let .const n _ := e.getAppFn | return .continue
    unless isSigConst n do return .continue
    if (← getProjectionFnInfo? n).isSome then
      let e' ← withReducibleAndInstances (whnf e)
      return if e' == e then .continue else .visit e'
    let target := n.replacePrefix sigNs T
    let some info := (← getEnv).find? target | return .continue
    let arity := info.type.getForallBinderNames.length
    let args := e.getAppArgs
    unless arity ≤ args.size do return .continue
    let e' := mkAppN (mkConst target) (args.extract (args.size - arity) args.size)
    unless ← isDefEq e e' do
      throwError "sig%: `{target}` exists but does not agree with `{n}` on{indentExpr e}"
    return .visit e')
  if let some n := survivor? body then
    throwError "sig%: `{n}` survives in the generated body{indentExpr body}\n\
      Define `{n.replacePrefix sigNs T}` before this definition."
  return body

/-- `sig% t` elaborates `t`, an application of a signature operator `Sig.op` at a concrete
formula type `T`, and returns the body the definition `T.op` stores: `Sig.op` unfolded one
layer, stated with the constructors and per-language operators of `T`. -/
syntax (name := sigBody) "sig% " term : term

@[term_elab sigBody, inherit_doc sigBody]
def elabSigBody : TermElab := fun stx expectedType? => do
  let e ← elabTermEnsuringType stx[1] expectedType?
  synthesizeSyntheticMVarsNoPostponing
  let e ← instantiateMVars e
  let .const T _ := (← whnfR (← inferType e)).getAppFn
    | throwError "sig%: the type of{indentExpr e}\nis not a concrete formula type"
  oneLayer T e

end FormalSystem.Syntax.Sig

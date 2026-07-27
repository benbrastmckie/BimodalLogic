/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Propositional.Kalmar
import FormalSystem.Automation.Tactics.Helpers

/-!
# PropDecide - Reflective Propositional Tautology Tactic

`prop_decide` closes derivability goals (`⊢ φ`, `⊢[fc] φ`, `|-! φ`, `|-![fc] φ`) whose
implication/bot skeleton is a propositional tautology, treating every maximal non-imp/bot
subterm (an atom, or an opaque `box`/`untl`/`snce`/free-variable subformula) as a reified
`PropForm` variable. Because the underlying soundness theorem
(`FormalSystem.Metalogic.Decidability.Propositional.tautologyDerivableFc'`) is schematic in the
environment `env : Nat → Formula`, this closes goals like `⊢ (□A).imp (□A)` for a free
formula variable `A`, not just goals built from atoms.

## Algorithm (mirrors `Mathlib.Tactic.Ring`'s reflect-check-apply pattern)

1. **Reify**: recurse through the goal formula's `Formula.imp`/`Formula.bot` skeleton;
   assign each maximal non-imp/bot subterm a fresh `PropForm.var` index, deduplicated by
   structural `Expr` equality after `whnf` (NOT `isDefEq`, to avoid metavariable loops).
2. **Check**: assert `f.isTaut = true` and close it with the kernel `decide` tactic — `f` is
   a closed `PropForm` term, so this always reduces. `native_decide` is NEVER emitted (would
   add the `Lean.ofReduceBool` axiom, violating the zero-new-axiom policy).
3. **Apply**: apply `tautologyDerivableFc'`/`tautology_derivable_fc` with the reified `f`,
   the `decide` proof, and the built environment; weaken from the empty context to the
   goal's actual context if needed.

## Dispatch Ordering Guidance

For dispatch tactics (e.g. a future `tm_prove`), route propositional-skeleton goals to
`prop_decide` first (cheap, complete for the propositional fragment), then fall back to
`modal_search`/the tableau decision procedure for goals with real modal/temporal structure.
-/

namespace FormalSystem.Metalogic.Decidability.Propositional.PropForm

open FormalSystem.Syntax

/-- Build a schematic environment from a literal list of formulas, defaulting to `⊥` beyond
the list. Used by `prop_decide` to reify accumulated opaque subterms into a closed
`Nat → Formula` environment. -/
def envOfList (l : List Formula) : Nat → Formula := fun n => l.getD n Formula.bot

end FormalSystem.Metalogic.Decidability.Propositional.PropForm

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability.Propositional
open Lean Elab Tactic Meta

/--
Reify a `Formula` expression into a `PropForm` expression, accumulating maximal
non-`imp`/`bot` subterms (atoms, opaque `box`/`untl`/`snce` subformulas, or free variables)
into `envRef` as fresh `PropForm.var` leaves, deduplicated by structural `Expr` equality
after `whnf`.
-/
partial def PropDecide.reify (e : Expr) (envRef : IO.Ref (Array Expr)) : MetaM Expr := do
  let e ← whnf e
  let fn := e.getAppFn
  if fn.isConstOf ``Formula.imp && e.getAppNumArgs == 2 then
    let args := e.getAppArgs
    let pf ← PropDecide.reify args[0]! envRef
    let pg ← PropDecide.reify args[1]! envRef
    mkAppM ``PropForm.imp #[pf, pg]
  else if fn.isConstOf ``Formula.bot && e.getAppNumArgs == 0 then
    return mkConst ``PropForm.fls
  else
    let arr ← envRef.get
    match arr.findIdx? (· == e) with
    | some idx => mkAppM ``PropForm.var #[mkNatLit idx]
    | none =>
      let idx := arr.size
      envRef.modify (·.push e)
      mkAppM ``PropForm.var #[mkNatLit idx]

/-- Build the proof of `f.isTaut = true` via the kernel-only `decide` tactic — `f` is
always a closed `PropForm` term (reification never places original-goal subterms inside
`f` itself, only inside the accumulated environment list), so `decide` always reduces.
Never emits `native_decide`. -/
def PropDecide.mkIsTautProof (fExpr : Expr) : TermElabM Expr := do
  let isTautApp ← mkAppM ``PropForm.isTaut #[fExpr]
  let expectedTy ← mkEq isTautApp (mkConst ``Bool.true)
  Elab.Term.elabTermEnsuringType (← `(term| by decide)) expectedTy

/-- Build the schematic environment expression `PropForm.envOfList [e₀, e₁, ..., eₖ]` from
the accumulated leaf list. -/
def PropDecide.mkEnvExpr (leaves : Array Expr) : MetaM Expr := do
  let formulaType := mkConst ``Formula
  let listExpr ← mkListLit formulaType leaves.toList
  mkAppM ``PropForm.envOfList #[listExpr]

/-- Extract `(fc, Γ, φ)` from a `Derivable fc Γ φ` (Prop-valued, `|-!`/`|-![fc]`) goal. -/
def PropDecide.extractDerivableGoal (goalType : Expr) : MetaM (Option (Expr × Expr × Expr)) := do
  let fn := goalType.getAppFn
  if fn.isConstOf ``Derivable && goalType.getAppNumArgs == 3 then
    let args := goalType.getAppArgs
    return some (args[0]!, args[1]!, args[2]!)
  else
    return none

/--
`prop_decide` - Reflective propositional tautology tactic.

Closes `⊢ φ`, `⊢[fc] φ`, `|-! φ`, and `|-![fc] φ` goals whose implication/bot skeleton is a
propositional tautology. Modal/temporal subterms (and free formula variables) are treated
as opaque reified variables, so this also closes fully schematic goals such as
`∀ A B : Formula, ⊢ A.imp (B.imp A)` or `⊢ (□A).imp (□A)`.

**Example**:
```lean
example (p q : Formula) : ⊢ p.imp (q.imp p) := by prop_decide
example (A : Formula) : ⊢ A.box.imp A.box := by prop_decide
example (p q : Formula) : |-! ((p.imp q).imp p).imp p := by prop_decide  -- Peirce
```
-/
elab "prop_decide" : tactic => do
  let goal ← getMainGoal
  goal.withContext do
    let goalType ← instantiateMVars (← goal.getType)
    if let some (fc, ctx, formula) ← extractDerivationGoal goalType then
      let envRef ← IO.mkRef (#[] : Array Expr)
      let fExpr ← PropDecide.reify formula envRef
      let envExpr ← PropDecide.mkEnvExpr (← envRef.get)
      let isTautProof ← PropDecide.mkIsTautProof fExpr
      let derivProof ← mkAppM ``tautologyDerivableFc' #[fExpr, isTautProof, envExpr, fc]
      let finalProof ←
        if isNilContext ctx then
          pure derivProof
        else
          let nilCtx ← mkListLit (mkConst ``Formula) []
          let subProof ← mkAppM ``List.nil_subset #[ctx]
          mkAppM ``DerivationTree.weakening #[nilCtx, ctx, formula, derivProof, subProof]
      goal.assign finalProof
    else if let some (fc, ctx, formula) ← PropDecide.extractDerivableGoal goalType then
      let envRef ← IO.mkRef (#[] : Array Expr)
      let fExpr ← PropDecide.reify formula envRef
      let envExpr ← PropDecide.mkEnvExpr (← envRef.get)
      let isTautProof ← PropDecide.mkIsTautProof fExpr
      let derivProof ← mkAppM ``tautology_derivable_fc #[fExpr, isTautProof, envExpr, fc]
      let finalProof ←
        if isNilContext ctx then
          pure derivProof
        else
          let subProof ← mkAppM ``List.nil_subset #[ctx]
          mkAppM ``Derivable.weaken #[derivProof, subProof]
      goal.assign finalProof
    else
      throwError "prop_decide: goal must be a derivability relation `⊢ φ`, `⊢[fc] φ`, \
        `|-! φ`, or `|-![fc] φ`, got {goalType}"

end FormalSystem.Automation

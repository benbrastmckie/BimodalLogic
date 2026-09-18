/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.Meta
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Reasoning
import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Automation.LemmaDB
import Lean

/-!
# The bounded proof-search engine

`searchProof` and the five strategies it tries: axiom matching, tagged-lemma matching,
assumption lookup, modus-ponens decomposition, and the modal and temporal K rules. This is what
the `modal_search` tactic in [`Commands.lean`](Commands.lean) runs.

It works at the meta level in `TacticM`, constructing proof terms with `mkAppM` rather than
returning proof witnesses. That is not a stylistic choice: `Axiom` is `Prop`-valued while
`DerivationTree` is `Type`-valued, so a `find_axiom_witness : Formula → Option (Axiom φ)`
cannot be written, and the same mismatch is why Aesop's proof reconstruction does not work over
these goals.

This is the third of the three files that replaced the 1,210-line `Tactics/Helpers.lean`,
alongside [`UserTactics.lean`](UserTactics.lean) and [`Meta.lean`](Meta.lean). It imports
`Meta.lean` and nothing else from the trio.

**Open question, recorded rather than acted on.** `FormalSystem/Automation/ProofSearch/` is a
second, larger search engine with its own strategies, its own weights (which it actually reads)
and its own configuration. Whether these two should be one engine is a real question that this
split does not answer, and merging them is out of scope here: the engines have different
interfaces, and only this one is reachable from a tactic.

## Main declarations

- `searchProof` — the entry point: bounded depth-first search under a visit counter
- `tryAxiomMatch`, `tryLemmaMatch`, `tryAssumptionMatch`, `tryModusPonens`, `tryModalK`,
  `tryTemporalK` — the strategies, tried in that order

## Tags

proof-search · tactics · meta · modal-k · temporal-k
-/

open FormalSystem.Syntax FormalSystem.ProofSystem
open Lean Elab Tactic Meta

namespace FormalSystem.Automation

/-!
### Helper: Check axiom matching at meta-level
-/

/--
Try to prove the goal by matching against axiom schemata.

For each axiom pattern, attempts to construct `DerivationTree.axiom (Axiom.X ...)`
and assign it to the goal. Returns true if successful.

**Implementation**: Uses `mkAppM` to construct proof terms at the meta-level,
which handles the Prop vs Type issue by working with expressions directly.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.
-/
def tryAxiomMatch (goal : MVarId) (_ctx _formula : Expr) : TacticM Bool := do
  -- Use observing? to try application without corrupting mvar state on failure
  let result ← observing? do
    setGoals [goal]
    -- Apply DerivationTree.axiom to the goal
    let axiomExpr := mkConst ``DerivationTree.axiom
    let newGoals ← goal.apply axiomExpr
    if newGoals.isEmpty then
      return ()  -- Already solved (unlikely for axiom)

    -- With FrameClass parameterization, newGoals contains goals for:
    -- (1) Axiom φ and (2) h.minFrameClass ≤ fc
    -- The ordering may vary. We identify the axiom goal by type.
    let mut axiomGoal? : Option MVarId := none
    let mut fcGoals : List MVarId := []
    for g in newGoals do
      let gType ← g.getType
      match gType with
      | .app (.const ``Axiom _) _ => axiomGoal? := some g
      | _ => fcGoals := g :: fcGoals

    let axiomGoal ← match axiomGoal? with
      | some g => pure g
      | none => throwError "no axiom goal found"

    -- Try each axiom constructor this list carries (all primitive schemata except the
    -- RTime axioms prior_U_gap/sep). The derived schemata (time-reflection mirrors, modal 4
    -- and B) are `@[tmLemma]` theorems reached by `tryLemmaMatch`; the frame-class-gated
    -- mirror `prior_SZ` is tried by `tryGatedDerivedMatch`.
    let axiomCtors : List Name := [
      -- Layer 1: Propositional (4)
      ``Axiom.prop_k,       -- (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
      ``Axiom.prop_s,       -- φ → (ψ → φ)
      ``Axiom.ex_falso,     -- ⊥ → φ
      ``Axiom.peirce,       -- ((φ → ψ) → φ) → φ
      -- Layer 2: S5 Modal (3)
      ``Axiom.modal_t,      -- □φ → φ
      ``Axiom.modal_5_collapse, -- ◇□φ → □φ
      ``Axiom.modal_k_dist, -- □(φ → ψ) → (□φ → □ψ)
      -- Layer 3: BX Temporal — seriality (1)
      ``Axiom.serial_future,  -- ⊤ → F(⊤)
      -- Layer 3: BX Temporal — monotonicity (4)
      ``Axiom.left_mono_until_G,  -- G(φ→χ) → (U(ψ,φ) → U(ψ,χ))
      ``Axiom.right_mono_until,   -- G(φ→ψ) → (U(φ,χ) → U(ψ,χ))
      -- Layer 3: BX Temporal — connectedness (2)
      ``Axiom.connect_future, -- φ → G(P(φ))
      -- Layer 3: BX Temporal — enrichment (2)
      ``Axiom.enrichment_until, -- p ∧ U(ψ,φ) → U(ψ ∧ S(p,φ), φ)
      -- Layer 3: BX Temporal — accumulation & absorption (4)
      ``Axiom.self_accum_until,  -- U(ψ,φ) → U(ψ, φ ∧ U(ψ,φ))
      ``Axiom.absorb_until,      -- U(φ ∧ U(ψ,φ), φ) → U(ψ,φ)
      -- Layer 3: BX Temporal — linearity (2)
      ``Axiom.linear_until,  -- U(ψ,φ) ∧ U(θ,χ) → disjunction
      -- Layer 3: BX Temporal — eventuality (2)
      ``Axiom.until_F,   -- U(ψ,φ) → F(ψ)
      -- Layer 3b: BX Temporal — additional (4)
      ``Axiom.temp_linearity,      -- F(φ) ∧ F(ψ) → disjunction
      ``Axiom.F_until_equiv,       -- F(φ) → U(φ, ⊤)
      -- Layer 4: Modal-Temporal Interaction (1)
      ``Axiom.modal_future,  -- □φ → □(Gφ)
      -- Layer 5: Uniformity — discrete structure (5)
      ``Axiom.discrete_symm_fwd,       -- U(⊤,⊥) → S(⊤,⊥)
      ``Axiom.discrete_propagate_fwd,   -- U(⊤,⊥) → G(U(⊤,⊥))
      ``Axiom.discrete_propagate_bwd,   -- U(⊤,⊥) → H(U(⊤,⊥))
      ``Axiom.discrete_box_necessity,   -- U(⊤,⊥) → □(U(⊤,⊥))
      -- Layer 6: Prior axioms — discrete (3)
      ``Axiom.prior_UZ,  -- F(φ) → U(φ, ¬φ)
      ``Axiom.z1,         -- G(Gφ→φ) → (FGφ→Gφ)
      -- Layer 8: Density (2)
      ``Axiom.density,         -- GGφ → Gφ
      ``Axiom.dense_indicator  -- ¬U(⊤,⊥)
    ]

    for ctorName in axiomCtors do
      try
        let ctorExpr := mkConst ctorName
        let remainingGoals ← axiomGoal.apply ctorExpr
        if remainingGoals.isEmpty then
          -- Axiom matched; now close frame class compatibility goals
          -- Non-base axioms (Discrete, Dense) need `decide`; base axioms use `trivial`
          for fcGoal in fcGoals do
            setGoals [fcGoal]
            evalTactic (← `(tactic| first | trivial | decide))
          setGoals []
          return ()  -- Found matching axiom
      catch _ =>
        continue

    throwError "no axiom matched"

  return result.isSome

/--
Try to close the goal with a frame-class-gated derived theorem (`DerivedAxioms.prior_SZ`, the
time-reflection mirror of the ZTime axiom UZ, or `DerivedAxioms.prior_S_gap`, the mirror of the
RTime axiom PU). The gate hypothesis (`ZTime ≤ fc` / `RTime ≤ fc`) is discharged by `decide`,
so the match fails at frame classes where the mirror is not a theorem.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.
-/
def tryGatedDerivedMatch (goal : MVarId) : TacticM Bool := do
  for lemmaName in [``DerivedAxioms.prior_SZ, ``DerivedAxioms.prior_S_gap] do
    let result ← observing? do
      setGoals [goal]
      let newGoals ← goal.apply (← mkConstWithFreshMVarLevels lemmaName)
      for g in newGoals do
        if ← g.isAssigned then continue
        setGoals [g]
        evalTactic (← `(tactic| first | trivial | decide))
        unless (← getGoals).isEmpty do throwError "gate not discharged"
      setGoals []
    if result.isSome then return true
  return false

/--
Try to prove the goal by applying derived-theorem lemmas from an explicit
name list, recursing into derivability premises via `searchFn` (backward
chaining).

This is the parameterized core behind `tryLemmaMatch`. Callers supply the
lemma name array explicitly, which lets alternative databases or wrappers
(e.g. weakening-aware / context-specific matching) reuse the
application and recursion machinery without going through the `@[tmLemma]`
attribute.

For each candidate lemma passing the head-symbol pre-filter, inside
`observing?` (so a failed attempt leaves the metavariable state untouched):
1. `apply` the lemma constant to the goal.
2. If no subgoals remain, the lemma closed the goal directly (works at any
   depth — subsumes the old static-list fast path).
3. Otherwise, only when `depth > 1`: for each subgoal, instantiate
   metavariables in its type; if it is itself a `DerivationTree` goal,
   recurse via `searchFn` at `depth - 1`; otherwise discharge it as a side
   goal (frame-class `≤` or `Formula ∈ Γ` membership) via
   `first | trivial | decide | simp`.
4. The attempt fails (and is rolled back) unless every subgoal is closed.

If no lemma matches and the context is non-empty, a weakening fallback
reduces `Γ ⊢[fc] φ` to `[] ⊢[fc] φ` and recurses.
-/
def tryLemmaMatchCore (lemmas : Array Name) (goal : MVarId) (fc _ctx formula : Expr)
    (searchFn : MVarId → Nat → TacticM Bool) (depth : Nat) : TacticM Bool := do
  -- Head-symbol pre-filter: only try lemmas whose conclusion head matches the
  -- goal formula's head (or is a variable/wildcard). Recomputed per call.
  let goalHead := formulaHead formula
  for lemmaName in lemmas do
    -- Skip lemmas whose conclusion head cannot unify with the goal head
    match goalHead, ← lemmaConclusionHead lemmaName with
    | some g, some l => if g != l then continue
    | _, _ => pure ()
    let success ← observing? do
      setGoals [goal]
      let lemmaExpr ← mkConstWithFreshMVarLevels lemmaName
      let newGoals ← goal.apply lemmaExpr
      if newGoals.isEmpty then
        setGoals []
        return ()
      -- Premises remain: recursing into them needs at least 2 depth levels
      if depth ≤ 1 then
        throwError "lemma has premises but depth is exhausted"
      -- Split subgoals: derivability premises (recurse) vs. everything else
      -- (frame-class `≤`, context membership, or undetermined value mvars like
      -- an inference rule's middle `Formula`). Recurse the derivability
      -- premises FIRST so unification determines any value metavariables; then
      -- discharge Prop side goals and require value mvars to be assigned.
      let mut derivGoals : List MVarId := []
      let mut otherGoals : List MVarId := []
      for sub in newGoals do
        let subType ← instantiateMVars (← sub.getType)
        if (← extractDerivationGoal subType).isSome then
          derivGoals := derivGoals ++ [sub]
        else
          otherGoals := otherGoals ++ [sub]
      for sub in derivGoals do
        if ← sub.isAssigned then
          continue
        let ok ← searchFn sub (depth - 1)
        if !ok then
          throwError "could not prove lemma premise"
      for sub in otherGoals do
        if ← sub.isAssigned then
          continue
        let subType ← instantiateMVars (← sub.getType)
        if ← Meta.isProp subType then
          -- Side goal from `apply`: frame-class `≤` or context membership
          setGoals [sub]
          evalTactic (← `(tactic| first | trivial | decide | simp))
          let remaining ← getGoals
          if !remaining.isEmpty then
            throwError "could not discharge side goal"
        else
          -- A value metavariable (e.g. inference-rule middle) left undetermined
          throwError "undetermined metavariable premise"
      setGoals []
      return ()
    if success.isSome then
      return true
  -- Weakening fallback: a closed lemma `⊢[fc] φ` still applies under a
  -- non-empty context `Γ ⊢[fc] φ` via `DerivationTree.weakening`. Reduce to
  -- the empty-context goal and recurse.
  -- Skipped for a literal empty context to guarantee termination.
  unless isNilContext _ctx do
    let wkSuccess ← observing? do
      setGoals [goal]
      let emptyCtx ← mkAppOptM ``List.nil #[some (mkConst ``Formula)]
      let subType ← mkAppM ``DerivationTree #[fc, emptyCtx, formula]
      let subMVar ← mkFreshExprMVar subType
      let hsub ← mkAppM ``List.nil_subset #[_ctx]
      let proof ← mkAppM ``DerivationTree.weakening #[emptyCtx, _ctx, formula, subMVar, hsub]
      goal.assign proof
      let ok ← searchFn subMVar.mvarId! depth
      if !ok then
        throwError "weakening fallback: could not prove empty-context premise"
      setGoals []
      return ()
    if wkSuccess.isSome then
      return true
  return false

/--
Try to prove the goal by matching against the `@[tmLemma]` attribute
database (see `FormalSystem.Automation.LemmaDB`), with backward chaining through
lemma premises.

Replaces the former `tryDerivedMatch` static 26-name list: the database is
now populated by tagging theorems `@[tmLemma]` at their definition sites.
Unlike `tryAxiomMatch`, which applies axiom constructors via
`DerivationTree.axiom`, this applies derived theorem constants directly via
`apply` and recurses into any remaining `DerivationTree` premises — so
inference-rule lemmas (e.g. `impTrans`-style composition) participate in
the search, not just directly-matching statements.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.
-/
def tryLemmaMatch (goal : MVarId) (fc ctx formula : Expr)
    (searchFn : MVarId → Nat → TacticM Bool) (depth : Nat) : TacticM Bool := do
  let lemmas ← Lean.labelled `tmLemma
  tryLemmaMatchCore lemmas goal fc ctx formula searchFn depth

/--
Try to prove the goal by finding a matching assumption in the context.

Constructs `DerivationTree.assumption Γ φ h` where `h : φ ∈ Γ`.

Uses `apply DerivationTree.assumption` followed by `simp` to prove list membership.
`simp` can prove `p ∈ [p]`, `p ∈ [q, p]`, etc. even with free variables.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.
-/
def tryAssumptionMatch (goal : MVarId) (_ctx _formula : Expr) : TacticM Bool := do
  let result ← observing? do
    setGoals [goal]
    -- Apply DerivationTree.assumption, which creates goal `φ ∈ Γ`
    let assumptionExpr := mkConst ``DerivationTree.assumption
    let newGoals ← goal.apply assumptionExpr
    if newGoals.isEmpty then
      return ()  -- Already solved

    -- Should have exactly one goal: prove `φ ∈ Γ`
    let [memGoal] := newGoals | throwError "expected single membership goal"

    setGoals [memGoal]
    -- Try to prove membership using simp (handles free variables)
    evalTactic (← `(tactic| simp))
    -- Check if simp closed the goal
    let remainingGoals ← getGoals
    if remainingGoals.isEmpty then
      return ()
    else
      throwError "simp did not close membership goal"

  return result.isSome

/-!
### Modus Ponens Decomposition
-/

/--
Check if a formula expression is an implication with the given consequent.
Given formula `φ → ψ` and target `ψ`, returns `some φ`.
-/
def matchImplicationConsequent (formula target : Expr) : MetaM (Option Expr) := do
  match formula with
  | .app (.app (.const ``Formula.imp _) antecedent) consequent =>
    if ← isDefEq consequent target then
      return some antecedent
    else
      return none
  | _ => return none

/--
Extract all formulas from a context expression (List Formula).
List.cons has signature: List.cons {α} (a : α) (as : List α) : List α
So the structure is: app (app (app (const List.cons) typeArg) elem) tail
-/
partial def extractContextFormulas (ctx : Expr) : MetaM (List Expr) := do
  match ctx with
  | .app (.app (.app (.const ``List.cons _) _typeArg) elem) tail =>
    let rest ← extractContextFormulas tail
    return elem :: rest
  | .app (.const ``List.nil _) _ => return []
  | .const ``List.nil _ => return []
  | _ => return []  -- Unknown structure, return empty

/--
Try to prove the goal using modus ponens by searching for usable implications.

Given a goal `Γ ⊢ ψ`, searches for any formula `φ → ψ` in the context,
then tries to prove `φ` recursively.

**Strategy**: Forward search - find implications with matching consequent,
then recursively prove the antecedent.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.
-/
def tryModusPonens (goal : MVarId) (fc ctx formula : Expr) (searchFn : MVarId → Nat → TacticM Bool)
    (depth : Nat) : TacticM Bool := do
  -- Collect candidate antecedents from context implications `φ → formula`
  let ctxFormulas ← extractContextFormulas ctx
  let mut candidates : List Expr := []
  for elem in ctxFormulas do
    if let some ant ← matchImplicationConsequent elem formula then
      candidates := ant :: candidates

  -- Try each candidate antecedent
  for antecedent in candidates do
    let success ← observing? do
      setGoals [goal]
      -- Create metavariables for the two proofs
      let impType ← mkAppM ``DerivationTree
          #[fc, ctx, ← mkAppM ``Formula.imp #[antecedent, formula]]
      let antType ← mkAppM ``DerivationTree #[fc, ctx, antecedent]
      let impMVar ← mkFreshExprMVar impType
      let antMVar ← mkFreshExprMVar antType

      -- Build the modus ponens application
      let mpProof ← mkAppM ``DerivationTree.modus_ponens
          #[ctx, antecedent, formula, impMVar, antMVar]
      goal.assign mpProof

      -- Get the MVarIds for the subgoals
      let impGoal := impMVar.mvarId!
      let antGoal := antMVar.mvarId!

      -- Try to prove antecedent first (often in context)
      let antSuccess ← searchFn antGoal (depth - 1)
      if !antSuccess then
        throwError "could not prove antecedent"

      -- Then prove implication (often in context too)
      let impSuccess ← searchFn impGoal (depth - 1)
      if !impSuccess then
        throwError "could not prove implication"

      return ()

    if success.isSome then
      return true

  return false

/-!
### Modal K and Temporal K Integration (Phase 1.5)

These functions detect when the goal and context have matching modal/temporal
structure and apply the generalized K rules to reduce to simpler goals.
-/

/--
Check if the context consists entirely of boxed formulas (□φ₁, □φ₂, ...).
Returns `some [φ₁, φ₂, ...]` if so, `none` otherwise.
-/
def extractUnboxedContext (ctx : Expr) : MetaM (Option (List Expr)) := do
  let ctxFormulas ← extractContextFormulas ctx
  let mut unboxed : List Expr := []
  for f in ctxFormulas do
    match f with
    | .app (.const ``Formula.box _) inner =>
      unboxed := inner :: unboxed
    | _ => return none  -- Not all formulas are boxed
  return some unboxed.reverse

/--
Check if the context consists entirely of future formulas (Fφ₁, Fφ₂, ...).
Returns `some [φ₁, φ₂, ...]` if so, `none` otherwise.
-/
def extractUnfuturedContext (ctx : Expr) : MetaM (Option (List Expr)) := do
  let ctxFormulas ← extractContextFormulas ctx
  let mut unfutured : List Expr := []
  for f in ctxFormulas do
    match f with
    | .app (.const ``Formula.allFuture _) inner =>
      unfutured := inner :: unfutured
    | _ => return none  -- Not all formulas are future
  return some unfutured.reverse

/--
Try to prove the goal using generalized modal K rule.

Given a goal `□Γ ⊢ □φ` (where Γ = [□ψ₁, □ψ₂, ...] and formula = □χ),
applies `generalizedModalK` to reduce to `[ψ₁, ψ₂, ...] ⊢ χ`.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.

**Why `FrameClass.Base` is hard-coded here** (and a known capability gap): the subgoal type is
built with `mkConst ``FrameClass.Base` rather than from the `_fc` argument, so this tactic
cannot fire at a non-`Base` frame class even though `Theorems.generalizedModalK` is itself
`{fc}`-polymorphic. This is a metaprogramming limitation, not a mathematical one; the fix is to
elaborate `_fc` into the subgoal type instead of the constant. `tryTemporalK` below has the same
gap. Deliberately deferred: it is elaborator work orthogonal to the frame-class parameterisation
of the theorem libraries.
-/
def tryModalK (goal : MVarId) (_fc ctx formula : Expr) (searchFn : MVarId → Nat → TacticM Bool)
    (depth : Nat) : TacticM Bool := do
  -- Check if formula is □χ
  let innerFormula ← match formula with
    | .app (.const ``Formula.box _) inner => pure inner
    | _ => return false  -- Goal formula is not boxed

  -- Check if context is all boxed formulas
  let some unboxedCtx ← extractUnboxedContext ctx
    | return false  -- Context not all boxed

  -- Build the unboxed context expression
  let unboxedCtxExpr ← buildContextExpr unboxedCtx

  let success ← observing? do
    setGoals [goal]
    -- Apply generalizedModalK
    -- generalizedModalK : (Γ : Context) → (φ : Formula) →
    --     (h : Γ ⊢ φ) → ((Context.map Formula.box Γ) ⊢ Formula.box φ)
    -- We need to prove (Context.map Formula.box unboxedCtx) ⊢ Formula.box innerFormula
    -- The goal should match this pattern

    -- Create metavariable for the subgoal: unboxedCtx ⊢ innerFormula
    -- generalizedModalK is at FrameClass.Base
    let baseFC := mkConst ``FrameClass.Base
    let subgoalType ← mkAppM ``DerivationTree #[baseFC, unboxedCtxExpr, innerFormula]
    let subgoalMVar ← mkFreshExprMVar subgoalType

    -- Build the proof: generalizedModalK unboxedCtx innerFormula subgoalMVar
    let proof ← mkAppM ``Theorems.generalizedModalK #[unboxedCtxExpr, innerFormula, subgoalMVar]

    -- Check that proof type matches goal type
    -- The result type is: (Context.map Formula.box unboxedCtx) ⊢ Formula.box innerFormula
    -- This should match ctx ⊢ formula
    goal.assign proof

    -- Now we need to prove the subgoal
    let subgoal := subgoalMVar.mvarId!
    let subSuccess ← searchFn subgoal (depth - 1)
    if !subSuccess then
      throwError "could not prove subgoal for modal K"

    return ()

  return success.isSome

/--
Try to prove the goal using generalized temporal K rule.

Given a goal `FΓ ⊢ Fφ` (where Γ = [Fψ₁, Fψ₂, ...] and formula = Fχ),
applies `generalizedTemporalK` to reduce to `[ψ₁, ψ₂, ...] ⊢ χ`.

**Note**: Uses `observing?` to avoid corrupting metavariable state on failure.

**Why `FrameClass.Base` is hard-coded here**: the same capability gap documented on
`tryModalK` — the subgoal type is built from `mkConst ``FrameClass.Base` rather than from the
`_fc` argument, so this tactic cannot fire at a non-`Base` frame class. Deliberately deferred.
-/
def tryTemporalK (goal : MVarId) (_fc ctx formula : Expr) (searchFn : MVarId → Nat → TacticM Bool)
    (depth : Nat) : TacticM Bool := do
  -- Check if formula is Fχ
  let innerFormula ← match formula with
    | .app (.const ``Formula.allFuture _) inner => pure inner
    | _ => return false  -- Goal formula is not a future formula

  -- Check if context is all future formulas
  let some unfuturedCtx ← extractUnfuturedContext ctx
    | return false  -- Context not all future

  -- Build the unfutured context expression
  let unfuturedCtxExpr ← buildContextExpr unfuturedCtx

  let success ← observing? do
    setGoals [goal]
    -- Apply generalizedTemporalK
    -- generalizedTemporalK : (Γ : Context) → (φ : Formula) →
    --     (h : Γ ⊢ φ) → ((Context.map Formula.allFuture Γ) ⊢ Formula.allFuture φ)

    -- Create metavariable for the subgoal: unfuturedCtx ⊢ innerFormula
    -- generalizedTemporalK is at FrameClass.Base
    let baseFC := mkConst ``FrameClass.Base
    let subgoalType ← mkAppM ``DerivationTree #[baseFC, unfuturedCtxExpr, innerFormula]
    let subgoalMVar ← mkFreshExprMVar subgoalType

    -- Build the proof: generalizedTemporalK unfuturedCtx innerFormula subgoalMVar
    let proof ← mkAppM ``Theorems.generalizedTemporalK
        #[unfuturedCtxExpr, innerFormula, subgoalMVar]

    -- Check that proof type matches goal type
    goal.assign proof

    -- Now we need to prove the subgoal
    let subgoal := subgoalMVar.mvarId!
    let subSuccess ← searchFn subgoal (depth - 1)
    if !subSuccess then
      throwError "could not prove subgoal for temporal K"

    return ()

  return success.isSome

/-!
### Core Search Tactic Implementation
-/

/--
Recursive proof search implementation.

**Algorithm**:
1. Check if goal matches any axiom schema `tryAxiomMatch` carries -- 42 of the
   tree's 45
1b. Check if goal matches any `@[tmLemma]` database lemma (with backward
    chaining through derivability premises)
2. Check if goal is in assumptions
3. Try modus ponens decomposition (backward chaining)
4. Try modal K rule (reduce □Γ ⊢ □φ to Γ ⊢ φ)
5. Try temporal K rule (reduce FΓ ⊢ Fφ to Γ ⊢ φ)

**Parameters**:
- `counter`: `IO.Ref Nat` node-visit budget (`SearchConfig.visitLimit`), created
  per `modal_search` invocation. Decremented on entry; search aborts (returns
  `false`) once it reaches 0, bounding total search cost independently of `depth`.
- `goal`: Current proof goal
- `depth`: Remaining search depth

**Returns**: True if proof found, false otherwise.

**Note**: `counter` is the first (curried) parameter so that `searchProof counter`
has the `MVarId → Nat → TacticM Bool` shape expected by the `try*` helpers'
`searchFn`, with no change to their signatures.
-/
partial def searchProof (counter : IO.Ref Nat) (goal : MVarId) (depth : Nat) : TacticM Bool := do
  if depth = 0 then
    return false

  -- visitLimit abort: consume one node from the budget; stop if exhausted.
  let remaining ← counter.get
  if remaining == 0 then
    return false
  counter.set (remaining - 1)

  let goalType ← goal.getType
  let some (fc, ctx, formula) ← extractDerivationGoal goalType
    | return false  -- Not a DerivationTree goal

  -- Strategy 1: Try axiom matching (cheapest)
  if ← tryAxiomMatch goal ctx formula then
    return true

  -- Strategy 1a: frame-class-gated derived theorems (`prior_SZ`, `prior_S_gap`)
  if ← tryGatedDerivedMatch goal then
    return true

  -- Strategy 1b: Try lemma database matching (backward chaining through premises)
  if ← tryLemmaMatch goal fc ctx formula (searchProof counter) depth then
    return true

  -- Strategy 2: Try assumption matching
  if ← tryAssumptionMatch goal ctx formula then
    return true

  -- Strategy 3: Try modus ponens decomposition (expensive)
  if depth > 1 then  -- Need at least 2 levels for modus ponens
    if ← tryModusPonens goal fc ctx formula (searchProof counter) depth then
      return true

  -- Strategy 4: Try modal K rule (reduce □Γ ⊢ □φ to Γ ⊢ φ)
  if depth > 1 then
    if ← tryModalK goal fc ctx formula (searchProof counter) depth then
      return true

  -- Strategy 5: Try temporal K rule (reduce FΓ ⊢ Fφ to Γ ⊢ φ)
  if depth > 1 then
    if ← tryTemporalK goal fc ctx formula (searchProof counter) depth then
      return true

  return false

end FormalSystem.Automation

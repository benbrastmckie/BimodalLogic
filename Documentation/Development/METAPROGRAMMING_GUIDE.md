# LEAN 4 Metaprogramming Guide for Logos

## 1. Introduction

### Purpose

This guide provides systematic coverage of LEAN 4 metaprogramming fundamentals for
implementing custom tactics in Logos's automation package. It focuses on the
`Lean.Elab.Tactic` API, expression manipulation, goal management, and proof term
construction required for Task 7 (Implement Core Automation, 40-60 hours).

### Audience

This guide targets developers implementing custom tactics for Logos,
particularly those working on:

- `apply_axiom` - Apply specific TM axiom to goal (8-10 hours)
- `modal_t` - Apply modal axiom MT (`□φ → φ`) (4-6 hours)
- `tm_auto` - Comprehensive TM automation with Aesop (15-20 hours)
- `assumption_search` - Search context for matching assumptions (8-12 hours)

### Prerequisites

Before reading this guide, you should have:

1. **Basic LEAN 4 Syntax**: Functions, types, inductive types, pattern matching
2. **Logos Architecture**: Understanding of `Formula`, `Derivable`, `Axiom`
   types (see `Documentation/UserGuide/ARCHITECTURE.md`)
3. **Proof System Knowledge**: Familiarity with TM axioms (MT, M4, MB, T4, TA, TL,
   MF, TF) and inference rules (MP, MK, TK, TD)

### Quick Reference

| Concept | Module | Purpose |
|---------|--------|---------|
| Goal management | `Lean.MVarId` | Get, inspect, assign goals |
| Expression manipulation | `Lean.Expr` | Pattern match formula structure |
| Proof construction | `Lean.Meta.Basic` | Build proof terms |
| Tactic monad | `Lean.Elab.Tactic` | High-level tactic operations |

## 2. Core Modules and Imports

### Essential Imports

Every tactic file requires these core imports:

```lean
import Lean.Elab.Tactic       -- Tactic elaboration and TacticM monad
import Lean.Meta.Basic        -- Meta-level operations (mkAppM, mkConst)
import Lean.Expr              -- Expression representation
import Lean.MVarId            -- Goal identifier and operations

open Lean Elab Tactic Meta
```

### Logos-Specific Imports

Import Logos modules for TM logic types and operations:

```lean
import Logos.Syntax.Formula         -- Formula inductive type
import Logos.ProofSystem.Axioms     -- TM axiom schemata
import Logos.ProofSystem.Derivation -- Derivable relation, inference rules
```

### Complete Working Example

Full import block for a tactic file:

```lean
-- File: Logos/Automation/Tactics.lean
import Lean.Elab.Tactic
import Lean.Meta.Basic
import Lean.Expr
import Lean.MVarId

import Logos.Syntax.Formula
import Logos.ProofSystem.Axioms
import Logos.ProofSystem.Derivation

namespace Logos.Automation

open Lean Elab Tactic Meta
open Logos.Syntax (Formula)
open Logos.ProofSystem (Axiom Derivable)

-- Tactic implementations here...

end Logos.Automation
```

## 3. Goal Management

Goals are the fundamental unit of tactic execution. Every tactic operates on one or
more goals to produce a proof.

### Getting the Main Goal

Use `getMainGoal` to retrieve the current goal:

```lean
elab "my_tactic" : tactic => do
  let goal ← getMainGoal  -- goal : MVarId
  -- ... work with goal
```

### Inspecting Goal Type

Get the goal's type (what needs to be proven):

```lean
elab "inspect_goal" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType  -- goalType : Expr

  -- Log goal type for debugging
  logInfo m!"Goal type: {goalType}"
```

**Example Goal Type**: `Derivable [] (Formula.box P).imp P`
- Outer structure: `Derivable` (derivability relation)
- Context: `[]` (empty premise list)
- Formula: `(Formula.box P).imp P` (the formula `□P → P`)

### Assigning Proof Terms

Close a goal by assigning a proof term:

```lean
elab "close_with_axiom" : tactic => do
  let goal ← getMainGoal

  -- Build proof term (see Section 5)
  let proof ← mkAppM ``Derivable.axiom #[← mkAppM ``Axiom.modal_t #[φ]]

  -- Assign proof to goal (closes goal)
  goal.assign proof
```

**Important**: `goal.assign` closes the goal. If the proof term doesn't match the
goal type, LEAN will raise a type error.

### Creating Subgoals: Modus Ponens Example

Some tactics create subgoals instead of closing the goal directly:

```lean
/-- Apply modus ponens, creating subgoals for `φ → ψ` and `φ` -/
elab "apply_mp" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- Pattern match: goal should be `Derivable Γ ψ`
  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>
    -- Create metavariables for subgoals
    let φMVar ← mkFreshExprMVar (some $ mkApp (.const ``Formula []) context)
    let impMVar ← mkFreshExprMVar (some $ mkApp2 (.const ``Derivable []) context
      (mkApp2 (.const ``Formula.imp []) φMVar formula))

    -- Build modus ponens proof
    let proof ← mkAppM ``Derivable.modus_ponens #[impMVar, φMVar]
    goal.assign proof

    -- Return subgoals to prove
    let subgoals := [impMVar.mvarId!, φMVar.mvarId!]
    replaceMainGoal subgoals
  | _ =>
    throwError "apply_mp: goal must be derivability relation"
```

**Result**: Proving `Γ ⊢ ψ` creates two new subgoals:
1. `Γ ⊢ φ → ψ` (implication)
2. `Γ ⊢ φ` (antecedent)

## 4. Expression Pattern Matching

Expressions (`Expr`) represent terms in LEAN's type theory. Tactics pattern match on
expressions to recognize formula structure.

### Basic Expression Constructors

```lean
inductive Expr where
  | const (name : Name) (levels : List Level) : Expr  -- Constant reference
  | app (f : Expr) (x : Expr) : Expr                  -- Function application
  | lam (name : Name) (type : Expr) (body : Expr) : Expr  -- Lambda abstraction
  | forallE (name : Name) (type : Expr) (body : Expr) : Expr  -- Forall
  | mvar (id : MVarId) : Expr                         -- Metavariable (goal)
  -- ... other constructors
```

### Destructuring Applications

Pattern match function applications with `.app`:

```lean
match expr with
| .app f x =>  -- expr = f(x)
  -- f : Expr (function)
  -- x : Expr (argument)
  ...
```

**Example**: Destructure `Formula.box P`:

```lean
match expr with
| .app (.const ``Formula.box _) innerFormula =>
  -- expr is `Formula.box innerFormula`
  -- innerFormula : Expr (the inner formula P)
  ...
```

### Matching Constants

Match constant references with `.const`:

```lean
match expr with
| .const name levels =>
  if name == ``Formula.box then
    -- expr is the constant Formula.box
    ...
```

### Formula-Specific Patterns

Pattern match TM formula structure:

```lean
-- Match implication: φ → ψ
match formula with
| .app (.app (.const ``Formula.imp _) lhs) rhs =>
  -- lhs : Expr (left side of implication)
  -- rhs : Expr (right side of implication)
  ...

-- Match box: `□φ`
| .app (.const ``Formula.box _) innerFormula =>
  -- innerFormula : Expr (formula inside box)
  ...

-- Match all_past: `Hφ`
| .app (.const ``Formula.all_past _) innerFormula =>
  -- innerFormula : Expr (formula inside all_past operator)
  ...
```

### Complete Example: Pattern Matching `□φ → φ`

Recognize the modal axiom MT pattern:

```lean
elab "match_modal_t" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- STEP 1: Match Derivable relation
  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>

    -- STEP 2: Match implication
    match formula with
    | .app (.app (.const ``Formula.imp _) lhs) rhs =>

      -- STEP 3: Match box on left side
      match lhs with
      | .app (.const ``Formula.box _) innerFormula =>

        -- STEP 4: Check innerFormula == rhs
        if ← isDefEq innerFormula rhs then
          logInfo m!"Matched MT pattern: `□{innerFormula} → {rhs}`"
        else
          throwError "Not MT: left and right formulas differ"

      | _ => throwError "Left side not a box"
    | _ => throwError "Formula not an implication"
  | _ => throwError "Goal not a derivability relation"
```

## 5. Proof Term Construction

Tactics construct proof terms that close goals. This section covers building
`Derivable` proofs using axioms and inference rules.

### mkAppM: Function Application with Inference

`mkAppM` applies a function to arguments, inferring implicit parameters:

```lean
mkAppM (name : Name) (args : Array Expr) : MetaM Expr
```

**Example**: Build `Axiom.modal_t φ`:

```lean
let axiomProof ← mkAppM ``Axiom.modal_t #[φ]
-- axiomProof : Expr = Axiom.modal_t φ
```

**Why use `mkAppM`?** It automatically infers universe levels and implicit
parameters. Manual construction requires explicit universe level arguments:

```lean
-- Manual (error-prone):
let axiomProof := mkApp (.const ``Axiom.modal_t [.zero]) φ

-- With mkAppM (automatic):
let axiomProof ← mkAppM ``Axiom.modal_t #[φ]
```

### mkConst: Constant References

Create constant references with `mkConst`:

```lean
mkConst (name : Name) (levels : List Level := []) : Expr
```

**Example**: Reference `Derivable.axiom`:

```lean
let derivableAxiom := mkConst ``Derivable.axiom
```

**When to use**: Use `mkConst` when you need the constant itself (not applied to
arguments). Use `mkAppM` when applying the constant to arguments.

### Building Derivable Proofs

Construct `Derivable Γ φ` proofs using axioms:

```lean
-- STEP 1: Build axiom proof (e.g., Axiom.modal_t φ)
let axiomProof ← mkAppM ``Axiom.modal_t #[φ]

-- STEP 2: Wrap in Derivable.axiom
let proof ← mkAppM ``Derivable.axiom #[axiomProof]

-- STEP 3: Assign to goal
goal.assign proof
```

**Type of `proof`**: `Derivable [] (Formula.box φ).imp φ`
- Proves that `□φ → φ` is derivable in empty context

### Building Axiom Proofs

Construct specific axiom instances:

```lean
-- Modal axiom MT: `□φ → φ`
let mt_proof ← mkAppM ``Axiom.modal_t #[φ]

-- Modal axiom M4: `□φ → □□φ`
let m4_proof ← mkAppM ``Axiom.modal_4 #[φ]

-- Modal axiom MB: `φ → □◇φ`
let mb_proof ← mkAppM ``Axiom.modal_b #[φ]

-- Temporal axiom T4: `Fφ → FFφ`
let t4_proof ← mkAppM ``Axiom.temporal_4 #[φ]
```

### Complete Example: modal_t Tactic

Full proof term construction for `modal_t`:

```lean
elab_rules : tactic
  | `(tactic| modal_t) => do
    let goal ← getMainGoal
    let goalType ← goal.getType

    -- Pattern match to extract φ from `□φ → φ`
    match goalType with
    | .app (.app (.const ``Derivable _) _)
      (.app (.app (.const ``Formula.imp _)
        (.app (.const ``Formula.box _) φ)) ψ) =>

      if ← isDefEq φ ψ then
        -- STEP 1: Build Axiom.modal_t φ
        let axiomProof ← mkAppM ``Axiom.modal_t #[φ]

        -- STEP 2: Wrap in Derivable.axiom
        let proof ← mkAppM ``Derivable.axiom #[axiomProof]

        -- STEP 3: Assign proof (closes goal)
        goal.assign proof
      else
        throwError "modal_t: left and right formulas must match"
    | _ =>
      throwError "modal_t: expected `Γ ⊢ □φ → φ`"
```

## 6. Error Handling

Tactics should fail gracefully with informative error messages.

### throwError: Tactic Failure

Use `throwError` to fail with a descriptive message:

```lean
throwError "modal_t: expected goal of form `□φ → φ`, got {goalType}"
```

**Result**: Tactic stops, error message displayed to user, goal unchanged.

### try...catch in TacticM

Handle recoverable errors with `try...catch`:

```lean
elab "try_modal_t" : tactic => do
  let goal ← getMainGoal

  try
    -- Attempt modal_t
    let proof ← buildModalTProof goal
    goal.assign proof
  catch e =>
    -- If modal_t fails, try alternative
    logWarning m!"modal_t failed: {e.toMessageData}, trying alternative"
    let proof ← buildAlternativeProof goal
    goal.assign proof
```

### Informative Error Messages

**Good Error Messages**:

```lean
throwError "modal_t: expected goal of form `□φ → φ`, got {goalType}"
throwError "tm_auto: could not find proof within depth limit {depth}"
throwError "assumption_search: no matching assumption in context {context}"
```

**Bad Error Messages**:

```lean
throwError "tactic failed"  -- Too vague
throwError "error"          -- Useless
throwError ""               -- Empty (confusing)
```

### Example: Error Handling in modal_t

```lean
elab_rules : tactic
  | `(tactic| modal_t) => do
    let goal ← getMainGoal
    let goalType ← goal.getType

    match goalType with
    | .app (.app (.const ``Derivable _) context) formula =>

      match formula with
      | .app (.app (.const ``Formula.imp _) lhs) rhs =>

        match lhs with
        | .app (.const ``Formula.box _) innerFormula =>

          if ← isDefEq innerFormula rhs then
            -- Success case: build and assign proof
            let axiomProof ← mkAppM ``Axiom.modal_t #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]
            goal.assign proof
          else
            -- ERROR: Formulas don't match
            throwError "modal_t: expected `□φ → φ` pattern, but got `□{innerFormula}
              → {rhs}`"

        | _ =>
          -- ERROR: Left side not a box
          throwError "modal_t: expected implication with `□_` on left, got `{lhs}
            → {rhs}`"

      | _ =>
        -- ERROR: Formula not an implication
        throwError "modal_t: expected implication, got `{formula}`"

    | _ =>
      -- ERROR: Goal not derivability relation
      throwError "modal_t: goal must be derivability relation `Γ ⊢ φ`, got
        `{goalType}`"
```

**Benefits**:
- Each error case has specific message
- Shows expected vs actual patterns
- Helps user understand what went wrong

## 7. Three Tactic Development Approaches

LEAN 4 offers three approaches for implementing tactics, each with different
complexity and flexibility tradeoffs.

### Approach 1: Macro-Based (Simplest)

**Use case**: Simple tactics that expand to existing tactics.

**Pros**: Minimal code, no metaprogramming knowledge required.

**Cons**: Limited flexibility, no runtime inspection of goals.

**Example: apply_axiom macro**:

```lean
/-- Apply specific axiom by name -/
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)

-- Usage:
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  apply_axiom Axiom.modal_t
  -- Expands to: apply Derivable.axiom; apply Axiom.modal_t
```

**When to use**: For simple tactic sequences that don't need goal inspection.

### Approach 2: elab_rules (Recommended)

**Use case**: Pattern-matched tactics with goal inspection and proof construction.

**Pros**: Good balance of power and simplicity, pattern matching built-in.

**Cons**: Limited to single tactic invocation per pattern.

**Example: modal_t with elab_rules**:

```lean
elab_rules : tactic
  | `(tactic| modal_t) => do
    let goal ← getMainGoal
    let goalType ← goal.getType

    -- Pattern match on goal type (see Section 4)
    match goalType with
    | .app (.app (.const ``Derivable _) _)
      (.app (.app (.const ``Formula.imp _)
        (.app (.const ``Formula.box _) φ)) ψ) =>

      if ← isDefEq φ ψ then
        let proof ← mkAppM ``Derivable.axiom #[← mkAppM ``Axiom.modal_t #[φ]]
        goal.assign proof
      else
        throwError "modal_t: formulas must match"
    | _ =>
      throwError "modal_t: expected `□φ → φ`"
```

**When to use**: Most tactics should use this approach. Recommended for
`modal_t`, `temporal_t`, `apply_perpetuity`.

### Approach 3: Direct TacticM (Advanced)

**Use case**: Complex tactics with iteration, backtracking, or proof search.

**Pros**: Full control, can iterate over context, implement search algorithms.

**Cons**: More verbose, requires understanding of `TacticM` monad.

**Example: assumption_search with TacticM**:

```lean
/-- Search context for assumption matching goal -/
def assumption_search (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType

  -- Get local context (available assumptions)
  let localContext ← getLCtx

  -- Iterate over assumptions
  for decl in localContext do
    let assumptionType ← instantiateMVars decl.type

    -- Check if assumption type matches goal type
    if ← isDefEq assumptionType goalType then
      -- Found match! Use this assumption
      let proof := decl.toExpr
      goal.assign proof
      return  -- Success, exit early

  -- No match found
  throwError "assumption_search: no matching assumption in context"

elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  assumption_search goal
```

**When to use**: For tactics with iteration (`assumption_search`, `modal_search`),
backtracking, or complex control flow.

### Decision Matrix

| Tactic | Approach | Justification |
|--------|----------|---------------|
| `apply_axiom` | Macro | Simple expansion to `apply` |
| `modal_t` | elab_rules | Pattern-matched goal inspection |
| `temporal_t` | elab_rules | Pattern-matched goal inspection |
| `tm_auto` | Macro | Expands to `aesop (rule_sets [TMLogic])` |
| `assumption_search` | TacticM | Iterates over context |
| `modal_search` | TacticM | Bounded depth search with backtracking |

## 8. Complete Working Examples

### Example 1: apply_axiom (Macro-Based)

```lean
/-- Apply specific TM axiom by name

**Usage:**
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  apply_axiom Axiom.modal_t

example (P : Formula) : [] ⊢ (Formula.box P).imp (Formula.box (Formula.box P)) := by
  apply_axiom Axiom.modal_4
```
-/
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)
```

**Explanation**:
- Expands to two tactics: `apply Derivable.axiom` then `apply $ax`
- First `apply` matches goal `Γ ⊢ φ` with `Derivable.axiom : Axiom φ → Derivable Γ φ`
- Creates subgoal: prove `Axiom φ`
- Second `apply` matches subgoal with provided axiom constructor (e.g.,
  `Axiom.modal_t`)
- Completes proof

### Example 2: modal_t (elab_rules)

See Section 2.5 of `TACTIC_DEVELOPMENT.md` for complete annotated implementation.

**Summary**:
- Uses `elab_rules` for pattern matching
- Destructures goal type to extract `φ` from `□φ → φ`
- Builds proof with `mkAppM``Axiom.modal_t` and `Derivable.axiom`
- Assigns proof to close goal

### Example 3: assumption_search (TacticM with Iteration)

```lean
/-- Search local context for assumption matching goal type

**Usage:**
```lean
example (P : Formula) (h : [] ⊢ P) : [] ⊢ P := by
  assumption_search  -- Finds h and uses it
```
-/
def assumption_search_impl (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType

  -- Get local context (assumptions in scope)
  let localContext ← getLCtx

  -- Iterate through all local declarations
  for decl in localContext do
    -- Skip auxiliary declarations (internal LEAN names)
    if decl.isAuxDecl then continue

    -- Get assumption type
    let assumptionType ← instantiateMVars decl.type

    -- Check definitional equality with goal type
    if ← isDefEq assumptionType goalType then
      logInfo m!"Found matching assumption: {decl.userName}"

      -- Use this assumption as proof
      let proof := decl.toExpr
      goal.assign proof
      return  -- Success, exit early

  -- No match found after checking all assumptions
  throwError "assumption_search: no matching assumption found in context"

elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  assumption_search_impl goal
```

**Explanation**:
- Retrieves local context with `getLCtx`
- Iterates over all assumptions (`for decl in localContext`)
- Uses `isDefEq` to check if assumption type matches goal
- When match found, assigns assumption expression to goal
- Throws error if no match after full iteration

**Extension Ideas**:
- Add depth parameter for recursive search
- Support unification (match with instantiation)
- Search for implications that conclude with goal

## References

### Official LEAN 4 Documentation

- [Metaprogramming in Lean 4 - Overview]
  (https://leanprover-community.github.io/lean4-metaprogramming-book/main/
  02_overview.html)
- [Metaprogramming in Lean 4 - Tactics Chapter]
  (https://leanprover-community.github.io/lean4-metaprogramming-book/main/
  09_tactics.html)
- [LEAN 4 API Documentation](https://leanprover-community.github.io/mathlib4_docs/)

### Logos Documentation

- [TACTIC_DEVELOPMENT.md](TACTIC_DEVELOPMENT.md) - Tactic patterns and Aesop
  integration
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - TM logic specification
- [TESTING_STANDARDS.md](TESTING_STANDARDS.md) - Tactic testing requirements

### Research Reports

- Report 021: LEAN 4 Modal Logic Implementation Best Practices, lines 254-299
  (Metaprogramming Architecture)
- Report 021, lines 384-451 (Proof Search Strategies)

### External Resources

- [Aesop Documentation](https://github.com/leanprover-community/aesop)
- [Mathlib4 Tactics](https://leanprover-community.github.io/mathlib4_docs/
  Mathlib/Tactic/)

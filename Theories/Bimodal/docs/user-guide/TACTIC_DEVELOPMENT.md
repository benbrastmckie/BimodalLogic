# Tactic Development Guide

This guide provides comprehensive instructions for developing custom tactics for the Logos proof automation system. For a complete registry of all tactics and their implementation status, see [TACTIC_REGISTRY.md](../project-info/TACTIC_REGISTRY.md).

## Table of Contents

1. [LEAN 4 Metaprogramming Overview](#1-lean-4-metaprogramming-overview)
2. [Tactic Implementation Patterns](#2-tactic-implementation-patterns)
3. [Aesop Integration](#3-aesop-integration)
4. [Simp Lemma Design](#4-simp-lemma-design)
5. [Syntax Macros](#5-syntax-macros)
6. [Testing Tactics](#6-testing-tactics)
7. [Documentation Requirements](#7-documentation-requirements)
8. [Best Practices](#8-best-practices)

## 1. LEAN 4 Metaprogramming Overview

### Tactic Architecture

LEAN 4 tactics are defined using the `Lean.Elab.Tactic` module:

```lean
import Lean.Elab.Tactic

open Lean Elab Tactic Meta

/-- A simple custom tactic that applies a specific lemma -/
elab "my_tactic" : tactic => do
  -- Get the current goal
  let goal ← getMainGoal
  -- Get the goal's type
  let goalType ← goal.getType

  -- Perform some action
  -- ...

  -- Close the goal or create subgoals
  goal.assign proof
```

### Key Modules

```lean
import Lean.Elab.Tactic      -- Tactic elaboration
import Lean.Meta.Basic       -- Meta-level operations
import Lean.Meta.Tactic.Simp -- Simplification
import Lean.Meta.Tactic.Rewrite -- Rewriting
```

### Metaprogramming Concepts

| Concept | Description |
|---------|-------------|
| `MVarId` | Goal identifier (metavariable) |
| `Expr` | Expression/term representation |
| `TacticM` | Monad for tactic execution |
| `MetaM` | Monad for meta-level operations |
| `getMainGoal` | Get current goal |
| `MVarId.assign` | Assign proof term to goal |
| `mkAppM` | Create function application |
| `mkConst` | Create constant reference |

## 2. Tactic Implementation Patterns

### Pattern 1: Apply Axiom

Apply a specific axiom to the current goal:

```lean
/-- Apply modal axiom MT: □φ → φ -/
elab "modal_t" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- Check if goal matches pattern: □_ → _
  match goalType with
  | .app (.app (.const ``Formula.imp _) (.app (.const ``Formula.box _) φ)) ψ =>
    if φ == ψ then
      -- Goal is □φ → φ, apply axiom
      let proof ← mkAppM ``Derivable.axiom #[← mkAppM ``Axiom.modal_t #[φ]]
      goal.assign proof
    else
      throwError "modal_t: goal is not □φ → φ"
  | _ =>
    throwError "modal_t: goal must be an implication □φ → φ"
```

### Pattern 1a: Complete Modal_t Tactic Example

This section provides a complete working implementation of the `modal_t` tactic using
`elab_rules`, demonstrating goal pattern matching, proof term construction, and error
handling for the modal axiom MT (`□φ → φ`).

```lean
import Lean.Elab.Tactic
import Logos.ProofSystem.Axioms
import Logos.ProofSystem.Derivation

open Lean Elab Tactic Meta

/-- Apply modal axiom MT: `□φ → φ` (reflexivity of necessity)

This tactic succeeds when the goal has form `Γ ⊢ □φ → φ` for some formula φ.
It constructs a proof using `Derivable.axiom` and `Axiom.modal_t`.

**Usage:**
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  modal_t
```

**Errors:**
- "modal_t: goal must be derivability relation" - Goal not of form `Derivable Γ φ`
- "modal_t: expected implication" - Formula not an implication
- "modal_t: expected `□φ → φ` pattern" - Implication not of form `□φ → φ`
-/
elab_rules : tactic
  | `(tactic| modal_t) => do
    -- STEP 1: Get the main goal and its type
    let goal ← getMainGoal
    let goalType ← goal.getType

    -- STEP 2: Pattern match on Derivable Γ φ
    -- goalType should have form: Derivable context formula
    match goalType with
    | .app (.app (.const ``Derivable _) context) formula =>

      -- STEP 3: Destructure formula to check for □φ → φ pattern
      match formula with
      | .app (.app (.const ``Formula.imp _) lhs) rhs =>

        -- STEP 4: Check lhs is Formula.box
        match lhs with
        | .app (.const ``Formula.box _) innerFormula =>

          -- STEP 5: Verify innerFormula == rhs (must be same formula)
          if ← isDefEq innerFormula rhs then
            -- STEP 6: Construct proof term
            -- Build: Derivable.axiom (Axiom.modal_t innerFormula)
            let axiomProof ← mkAppM ``Axiom.modal_t #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]

            -- STEP 7: Assign proof to goal (closes goal)
            goal.assign proof
          else
            throwError "modal_t: expected `□φ → φ` pattern, but got `□{innerFormula} →
              {rhs}`"

        | _ =>
          throwError "modal_t: expected implication with `□_` on left, got `{lhs} →
            {rhs}`"

      | _ =>
        throwError "modal_t: expected implication, got `{formula}`"

    | _ =>
      throwError "modal_t: goal must be derivability relation `Γ ⊢ φ`, got `{goalType}`"

```

**Implementation Notes:**

1. **Goal Pattern Matching**: Uses nested pattern matching on `Expr` to destructure
   goal type from `Derivable Γ (Formula.box φ).imp φ` down to inner formula `φ`.

2. **Expression Destructuring**:
   - `.app f x` matches function applications
   - `.const name levels` matches constant references
   - Use `` ``Name `` (double backtick) for fully qualified names

3. **Proof Term Construction**:
   - `mkAppM` applies function to arguments with implicit inference
   - Build axiom proof first: `Axiom.modal_t φ`
   - Wrap in derivability: `Derivable.axiom axiomProof`

4. **Definitional Equality**: `isDefEq` checks if `innerFormula` and `rhs` are
   definitionally equal (handles α-equivalence, β-reduction, etc.).

5. **Error Handling**: Provide specific error messages showing expected vs actual
   patterns for easier debugging.

**Reference**: See [METAPROGRAMMING_GUIDE.md](../../Development/METAPROGRAMMING_GUIDE.md) for detailed
explanation of `Lean.Elab.Tactic` API, expression manipulation, and proof term
construction.

### Pattern 1b: Complete Working modal_4_tactic Example

This section provides the actual working implementation from Tactics.lean:

```lean
/--
`modal_4_tactic` applies the modal 4 axiom `□φ → □□φ`.

Automatically applies the axiom when the goal matches the pattern.

**Example**:
```lean
example (p : Formula) : Derivable [] (p.box.imp p.box.box) := by
  modal_4_tactic
```
-/
elab "modal_4_tactic" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>

    match formula with
    | .app (.app (.const ``Formula.imp _) lhs) rhs =>

      match lhs with
      | .app (.const ``Formula.box _) innerFormula =>

        match rhs with
        | .app (.const ``Formula.box _) (.app (.const ``Formula.box _) innerFormula2) =>

          if ← isDefEq innerFormula innerFormula2 then
            let axiomProof ← mkAppM ``Axiom.modal_4 #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]
            goal.assign proof
          else
            throwError "modal_4_tactic: expected □φ → □□φ pattern with same φ"

        | _ =>
          throwError "modal_4_tactic: expected □□φ on right side, got {rhs}"

      | _ =>
        throwError "modal_4_tactic: expected □φ on left side, got {lhs}"

    | _ =>
      throwError "modal_4_tactic: expected implication, got {formula}"

  | _ =>
    throwError "modal_4_tactic: goal must be derivability relation, got {goalType}"
```

**Key Implementation Points:**

1. **Nested Pattern Matching**: Uses 4 levels of pattern matching to destructure
   `Derivable Γ (□φ → □□φ)` into its components.

2. **Definitional Equality Check**: `isDefEq innerFormula innerFormula2` ensures both
   `φ` instances are the same formula.

3. **Proof Term Construction**: Builds `Derivable.axiom (Axiom.modal_4 φ)` to close goal.

4. **Error Messages**: Each pattern match level provides specific error message for debugging.

### Pattern 2: Apply Inference Rule

Apply an inference rule that creates subgoals:

```lean
/-- Apply modus ponens, creating subgoals for φ → ψ and φ -/
elab "mp" h1:ident h2:ident : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- Get hypothesis expressions
  let h1Expr ← elabTerm h1 none
  let h2Expr ← elabTerm h2 none

  -- Apply modus ponens
  let proof ← mkAppM ``Derivable.modus_ponens #[h1Expr, h2Expr]
  goal.assign proof
```

### Pattern 3: Simplification Tactic

Simplify formulas using simp lemmas:

```lean
/-- Simplify modal formulas -/
elab "modal_simp" : tactic => do
  let goal ← getMainGoal

  -- Add modal simplification lemmas
  let simpLemmas := #[
    ``diamond_neg_box_neg,      -- ◇φ ≡ ¬□¬φ
    ``box_box_eq_box,           -- □□φ ≡ □φ (in S5)
    ``diamond_diamond_eq_diamond -- ◇◇φ ≡ ◇φ (in S5)
  ]

  -- Apply simplification
  let (_, newGoal) ← simpGoal goal (simpLemmas := simpLemmas)

  match newGoal with
  | some g => replaceMainGoal [g]
  | none => pure ()  -- Goal solved
```

### Pattern 4: Proof Search

Bounded proof search:

```lean
/-- Bounded proof search for modal formulas -/
partial def modalSearch (goal : MVarId) (depth : Nat) : TacticM Unit := do
  if depth == 0 then
    throwError "modal_search: depth limit reached"

  let goalType ← goal.getType

  -- Try each strategy in order
  try
    -- Try assumption
    goal.assumption
  catch _ =>
    try
      -- Try applying axiom MT
      let proof ← mkAppM ``Derivable.axiom #[← mkAppM ``Axiom.modal_t #[← inferType goalType]]
      goal.assign proof
    catch _ =>
      try
        -- Try applying axiom M4
        let proof ← mkAppM ``Derivable.axiom #[← mkAppM ``Axiom.modal_4 #[← inferType goalType]]
        goal.assign proof
      catch _ =>
        -- Try modus ponens (creates subgoals)
        let (subgoal1, subgoal2) ← applyMP goal
        modalSearch subgoal1 (depth - 1)
        modalSearch subgoal2 (depth - 1)

elab "modal_search" depth:num : tactic => do
  let goal ← getMainGoal
  modalSearch goal depth.getNat
```

## 3. Aesop Integration

Aesop is LEAN 4's general-purpose proof search automation tool. This section explains
how to integrate Logos's TM logic axioms and lemmas with Aesop for automated
proof construction.

### Aesop Rule Attribution

Aesop uses attributes to mark theorems and lemmas as automation rules:

- `@[aesop safe]` - Safe rules that preserve correctness (always apply)
- `@[aesop norm simp]` - Normalization rules for simplification
- `@[aesop unsafe]` - Unsafe rules that may diverge (apply with caution)

**Example: Marking modal_t axiom as safe:**

```lean
/-- Modal axiom MT is always valid, safe to apply -/
@[aesop safe [TMLogic]]
theorem modal_t_valid (φ : Formula) : valid (Formula.box φ).imp φ := by
  intro M h t
  exact Semantics.modal_t_sound M h t φ
```

### Custom Rule Sets

Create a TM-specific rule set to group modal/temporal automation:

```lean
-- Declare custom rule set for TM logic
declare_aesop_rule_sets [TMLogic]

-- Mark perpetuity principles for TM rule set
@[aesop safe [TMLogic]]
theorem perpetuity_1 (φ : Formula) : Derivable [] (Formula.box φ).imp (always φ) := by
  sorry  -- P1 implementation

@[aesop safe [TMLogic]]
theorem perpetuity_2 (φ : Formula) : Derivable [] (eventually φ).imp (diamond φ) := by
  sorry  -- P2 implementation

-- Mark axioms as safe rules
@[aesop safe [TMLogic]]
theorem modal_4_derivable (φ : Formula) : Derivable [] (Formula.box φ).imp
  (Formula.box (Formula.box φ)) := by
  apply Derivable.axiom
  exact Axiom.modal_4 φ

@[aesop safe [TMLogic]]
theorem modal_b_derivable (φ : Formula) : Derivable [] φ.imp (Formula.box (diamond φ)) :=
  by
  apply Derivable.axiom
  exact Axiom.modal_b φ
```

### Implementing tm_auto Tactic

The `tm_auto` tactic invokes Aesop with the TMLogic rule set:

```lean
/-- Comprehensive TM automation using Aesop

Attempts to prove goal using all TM axioms, perpetuity principles, and modal/temporal
simplifications registered in the TMLogic rule set.

**Usage:**
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  tm_auto

example (P Q : Formula) : [Formula.box P, P.imp Q] ⊢ Formula.box Q := by
  tm_auto
```

**Limitations:**
- May not find proof if requires deep search
- Does not handle counterfactual or epistemic operators (Layer 1+)
- Performance degrades on deeply nested formulas (>10 operators)
-/
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))

-- Alternative: tm_auto with custom simp set
macro "tm_auto_simp" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]) (simp_options := {decide := true}))
```

### Normalization Rules

Mark simplifications as normalization rules for preprocessing:

```lean
-- Modal simplifications (require S5 frame properties)
@[aesop norm simp [TMLogic]]
theorem box_box_eq_box (φ : Formula) : Formula.box (Formula.box φ) = Formula.box φ := by
  sorry  -- Requires proving M4 gives syntactic equality via normalization

@[aesop norm simp [TMLogic]]
theorem diamond_diamond_eq_diamond (φ : Formula) :
  diamond (diamond φ) = diamond φ := by
  sorry  -- Requires proving S5 axiom B gives syntactic equality

-- Temporal simplifications (linear time structure)
@[aesop norm simp [TMLogic]]
theorem future_future_eq_future (φ : Formula) :
  Formula.all_future (Formula.all_future φ) = Formula.all_future φ := by
  sorry  -- Requires proving T4 temporal axiom

-- Bimodal interactions (MF/TF axioms)
@[aesop norm simp [TMLogic]]
theorem box_future_comm (φ : Formula) :
  Formula.box (Formula.all_future φ) = Formula.all_future (Formula.box φ) := by
  sorry  -- Requires proving MF/TF axioms establish commutativity
```

**IMPORTANT**: These simplification lemmas must be proven as theorems in TM, not
merely asserted as axioms, to maintain soundness. They reduce formulas toward normal
form (fewer nested operators).

### Forward Reasoning

Mark safe implications for forward chaining:

```lean
@[aesop safe forward [TMLogic]]
theorem modal_k_forward (φ ψ : Formula) (h1 : Derivable Γ (Formula.box (φ.imp ψ)))
    (h2 : Derivable Γ (Formula.box φ)) : Derivable Γ (Formula.box ψ) := by
  exact Derivable.modal_k h1 h2

@[aesop safe forward [TMLogic]]
theorem temporal_k_forward (φ ψ : Formula) (h1 : Derivable Γ (Formula.all_future (φ.imp ψ)))
    (h2 : Derivable Γ (Formula.all_future φ)) : Derivable Γ (Formula.all_future ψ) := by
  exact Derivable.temporal_k h1 h2
```

### References

- [Aesop Documentation](https://github.com/leanprover-community/aesop)
- [Aesop Rule Sets](https://github.com/leanprover-community/aesop#rule-sets)
- [LEAN 4 Metaprogramming - Aesop Chapter]
  (https://leanprover-community.github.io/lean4-metaprogramming-book/main/
  11_aesop.html)

## 4. Simp Lemma Design

The `simp` tactic performs formula simplification using rewrite lemmas. This section
explains convergence requirements and key simplifications for TM logic.

### Convergence Requirements

Simp lemmas must reduce formulas toward a normal form to guarantee termination:

1. **Directionality**: Rewrite from complex to simple (never increase operator count)
2. **Termination**: No cycles (A → B, B → A would loop)
3. **Confluence**: Order-independent (different rewrite orders reach same normal form)

**Example of BAD simp lemma (non-terminating):**

```lean
-- DON'T DO THIS: Creates rewrite cycle
@[simp] theorem bad_box_equiv (φ : Formula) : Formula.box φ = diamond (neg φ) := ...
@[simp] theorem bad_diamond_equiv (φ : Formula) : diamond φ = neg (Formula.box (neg φ))
  := ...
-- These create cycle: `□φ` → `◇¬φ` → `¬□¬¬φ` → ...
```

### Modal Simplifications

**S5 Modal Simplifications** (require M4, MB axioms proven):

```lean
-- Idempotence: `□□φ = □φ` (from M4: `□φ → □□φ`)
@[simp] theorem box_box_eq_box (φ : Formula) : Formula.box (Formula.box φ) =
  Formula.box φ := by
  sorry  -- Prove using M4 axiom bidirectionality

-- Idempotence: `◇◇φ = ◇φ` (from S5 axiom system)
@[simp] theorem diamond_diamond_eq_diamond (φ : Formula) :
  diamond (diamond φ) = diamond φ := by
  sorry  -- Prove using diamond definition and M4

-- Duality: Define `◇φ` as `¬□¬φ`
@[simp] theorem diamond_def (φ : Formula) :
  diamond φ = neg (Formula.box (neg φ)) := rfl
```

### Temporal Simplifications

**Linear Temporal Logic Simplifications** (require T4 axiom proven):

```lean
-- Idempotence: `GGφ = Gφ` (all-future collapse)
@[simp] theorem future_future_eq_future (φ : Formula) :
  Formula.all_future (Formula.all_future φ) = Formula.all_future φ := by
  sorry  -- Prove using T4 temporal axiom

-- Idempotence: `HHφ = Hφ` (all-past collapse)
@[simp] theorem past_past_eq_past (φ : Formula) :
  Formula.all_past (Formula.all_past φ) = Formula.all_past φ := by
  sorry  -- Prove using temporal duality and T4
```

### Bimodal Interaction Simplifications

**Modal-Temporal Commutativity** (require MF, TF axioms proven):

```lean
-- Commutativity: `□Gφ = G□φ` (necessity distributes over all-future)
@[simp] theorem box_future_eq_future_box (φ : Formula) :
  Formula.box (Formula.all_future φ) = Formula.all_future (Formula.box φ) := by
  sorry  -- Prove using MF/TF axioms

-- Commutativity: `□Hφ = H□φ` (necessity distributes over all-past)
@[simp] theorem box_past_eq_past_box (φ : Formula) :
  Formula.box (Formula.all_past φ) = Formula.all_past (Formula.box φ) := by
  sorry  -- Prove using temporal duality of MF/TF
```

### Propositional Simplifications

Standard propositional simplifications (always safe):

```lean
-- Double negation elimination
@[simp] theorem neg_neg (φ : Formula) : neg (neg φ) = φ := by
  sorry

-- Implication to disjunction
@[simp] theorem imp_eq_or (φ ψ : Formula) : φ.imp ψ = (neg φ).or ψ := by
  sorry

-- Conjunction commutativity
@[simp] theorem and_comm (φ ψ : Formula) : φ.and ψ = ψ.and φ := by
  sorry
```

### Important Notes

1. **Prove as Theorems**: All simp lemmas must be proven as theorems in TM, not
   asserted as axioms. Unproven simp lemmas compromise soundness.

2. **S5 Requirements**: Modal simplifications like `box_box_eq_box` require S5 frame
   properties (reflexivity, transitivity, symmetry). Verify frame constraints before
   using.

3. **Performance**: Excessive simp lemmas slow proof search. Mark only essential
   simplifications.

### References

- [How does Lean simp tactic work?]
  (https://proofassistants.stackexchange.com/questions/2455/
  how-does-lean-simp-tactic-work)
- [Mathlib4 Simp Lemmas]
  (https://leanprover-community.github.io/mathlib4_docs/Mathlib/Tactic/Simp/)

## 5. Syntax Macros

### Defining Custom Syntax

```lean
/-- DSL syntax for modal necessity -/
syntax "□" term : term
macro_rules
  | `(□ $φ) => `(Formula.box $φ)

/-- DSL syntax for possibility -/
syntax "◇" term : term
macro_rules
  | `(◇ $φ) => `(diamond $φ)

/-- DSL syntax for derivability -/
syntax term " ⊢ " term : term
macro_rules
  | `($Γ ⊢ $φ) => `(Derivable $Γ $φ)
```

### Tactic Syntax Macros

```lean
/-- Shorthand for applying axiom and specific axiom constructor -/
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)

/-- Combined modal tactic -/
macro "modal_reasoning" : tactic =>
  `(tactic|
    repeat (first
      | apply_axiom Axiom.modal_t
      | apply_axiom Axiom.modal_4
      | apply_axiom Axiom.modal_b
      | apply Derivable.modus_ponens <;> assumption))
```

## 6. Testing Tactics

### Unit Tests for Tactics

```lean
-- Tests/Unit/Automation/TacticsTests.lean

/-- Test modal_t applies correctly -/
example (P : Formula) : ⊢ (P.box.imp P) := by
  modal_t

/-- Test modal_t fails on wrong formula -/
example (P Q : Formula) : ⊢ (P.imp Q) := by
  fail_if_success modal_t  -- Should fail
  sorry

/-- Test modal_reasoning solves simple goal -/
example (P : Formula) : [P.box] ⊢ P := by
  modal_reasoning

/-- Test proof search with depth limit -/
example (P : Formula) : ⊢ (P.box.imp P) := by
  modal_search 3
```

### Performance Tests

```lean
/-- Test tactic performance on complex formula -/
example (P Q R : Formula) :
  ⊢ ((P.box.and Q.box).and R.box).imp (P.and (Q.and R)).box := by
  -- Should complete in reasonable time
  tm_auto

/-- Benchmark: deeply nested modal formula -/
def deeply_nested (n : Nat) : Formula :=
  match n with
  | 0 => Formula.atom "p"
  | n + 1 => Formula.box (deeply_nested n)

-- Test on nested formula (should complete quickly)
#guard (deeply_nested 10).complexity = 11
```

## 7. Documentation Requirements

### Tactic Documentation Format

```lean
/-!
# Modal Reasoning Tactics

This module provides tactics for automated modal reasoning in TM logic.

## Main Tactics

* `modal_t` - Apply axiom MT (□φ → φ)
* `modal_k` - Apply modal K rule
* `modal_simp` - Simplify modal formulas
* `modal_auto` - Comprehensive modal automation

## Usage

```lean
example (P : Formula) : ⊢ (P.box.imp P) := by
  modal_t

example (P Q : Formula) : [P.box, P.imp Q] ⊢ Q.box := by
  modal_auto
```

## Implementation Notes

Tactics use LEAN 4 metaprogramming to analyze goal structure and apply
appropriate axioms and inference rules.
-/

/-- Apply modal axiom MT: □φ → φ

This tactic succeeds when the goal has the form `⊢ □φ → φ` for some formula φ.
It applies the reflexivity axiom of S5 modal logic.

## Example

```lean
example (P : Formula) : ⊢ (P.box.imp P) := by
  modal_t
```

## Errors

* "goal must be an implication □φ → φ" - Goal doesn't match required pattern
-/
elab "modal_t" : tactic => do
  -- implementation
  sorry
```

### Limitations Documentation

Document what the tactic cannot handle:

```lean
/-- Modal proof search with bounded depth.

**Limitations:**
- Does not handle temporal operators (use `temporal_search`)
- May not find proof within depth limit
- Does not backtrack on suboptimal choices

**Completeness:**
Complete for propositional S5 within the depth limit.
-/
elab "modal_search" depth:num : tactic => ...
```

## 8. Best Practices

### Do

- Write tests before implementing tactics
- Document expected goal patterns
- Provide clear error messages
- Use type-safe pattern matching
- Integrate with existing LEAN tactics when possible
- Profile performance on representative examples

### Don't

- Leave tactics partially implemented without `sorry`
- Create tactics that loop infinitely
- Ignore edge cases (empty contexts, atomic formulas)
- Hardcode proof terms (use `mkAppM`)
- Skip documentation

### Error Messages

Provide helpful error messages:

```lean
-- Good
throwError "modal_t: expected goal of form □φ → φ, got {goalType}"

-- Bad
throwError "tactic failed"
```

### Performance Considerations

- Avoid unnecessary recursion
- Use memoization for repeated computations
- Set reasonable depth limits for search
- Profile tactics on large formulas

## References

- [LEAN 4 Metaprogramming Book](https://leanprover-community.github.io/lean4-metaprogramming-book/)
- [Aesop Documentation](https://github.com/leanprover-community/aesop)
- [Mathlib4 Tactics](https://leanprover-community.github.io/mathlib4_docs/)
- [Logos Architecture](ARCHITECTURE.md)
- [METAPROGRAMMING_GUIDE.md](../Development/METAPROGRAMMING_GUIDE.md)
- [TESTING_STANDARDS.md](../Development/TESTING_STANDARDS.md)
- [TACTIC_REGISTRY.md](../project-info/TACTIC_REGISTRY.md)

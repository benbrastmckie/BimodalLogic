# Tactic Library

This document serves as a dynamic library of successful tactic patterns and reusable proof snippets for the Logos Lean 4 Proof Checker project. It is maintained and updated by the `lean-expert` and referenced by the `logic-theorist`.

## Structure
Each entry in the tactic library should include:
- **Name**: A descriptive name for the tactic pattern.
- **Goal Type**: The type of Lean goal this pattern addresses.
- **Tactics**: The sequence of tactics used.
- **Example**: A minimal Lean code snippet demonstrating its usage.
- **Context**: Any specific context (e.g., required imports, assumptions) for the pattern.
- **Complexity**: Estimated complexity (Simple, Medium, Complex).

## Common Patterns

### 1. `modal_t` Axiom Application
- **Name**: Apply Modal T Axiom
- **Goal Type**: `⊢ □φ → φ`
- **Tactics**: `apply Derivable.axiom; apply Axiom.modal_t`
- **Example**:
```lean
theorem my_modal_t (p : Formula) : ⊢ (p.box.imp p) := by
  apply Derivable.axiom
  apply Axiom.modal_t
```
- **Context**: Requires `Derivable` and `Axiom` definitions.
- **Complexity**: Simple

### 2. Implication Introduction
- **Name**: Introduce Implication
- **Goal Type**: `⊢ A → B`
- **Tactics**: `intro h`
- **Example**:
```lean
theorem my_implication (A B : Prop) : ⊢ A → B := by
  intro hA
  -- ... prove B from hA
```
- **Context**: Standard Lean `Prop` or `Formula` implication.
- **Complexity**: Simple

### 3. Rewriting with Commutativity
- **Name**: Rewrite with Commutativity
- **Goal Type**: `A = B` where `A` and `B` differ by a commutative operation.
- **Tactics**: `rw [Nat.add_comm]` or `rw [my_comm_lemma]`
- **Example**:
```lean
theorem add_comm_example (a b : Nat) : a + b = b + a := by
  rw [Nat.add_comm]
```
- **Context**: Requires a known commutativity lemma.
- **Complexity**: Simple

### 4. Induction on Natural Numbers
- **Name**: Natural Number Induction
- **Goal Type**: `∀ n : Nat, P n`
- **Tactics**: `induction n with | zero => ... | succ n ih => ...`
- **Example**:
```lean
theorem sum_n_formula (n : Nat) : (∑ i in Finset.range (n + 1), i) = n * (n + 1) / 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
    simp [Finset.sum_range_succ, ih]
    ring
```
- **Context**: Proofs over natural numbers.
- **Complexity**: Medium

## Usage
- The `lean-expert` should consult this library during the "Search" phase of its workflow to find applicable patterns.
- The `logic-theorist` can suggest patterns from this library when outlining proof strategies.


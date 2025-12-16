# Proof and Tactic Conventions

This document outlines the specific conventions for proof construction and tactic development in the Logos project.

## 1. Tactic Naming

- **Axiom Application:** Tactics that apply a specific axiom should be named `modal_x` or `temp_x` where x is the axiom name.
  - `modal_t`: Applies □φ → φ
  - `modal_4_tactic`: Applies □φ → □□φ
  - `modal_b_tactic`: Applies φ → □◇φ
- **Automation:**
  - `tm_auto`: General purpose Aesop-based automation.
  - `modal_reasoning`: High-level tactic combining basic modal axioms.

## 2. Proof Patterns

### Applying Axioms
When applying axioms manually, prefer the `apply_axiom` macro if available, or the pattern:
```lean
apply Derivable.axiom
apply Axiom.modal_t
```

### Metaprogramming
- **Monads:** Use `TacticM` for tactics and `MetaM` for core operations.
- **Pattern Matching:** Use deep pattern matching on `Expr` to identify formulas.
  - Check for `Formula.box`, `Formula.imp`, etc.
  - Use `isDefEq` to ensure formulas match exactly.
- **Error Handling:** Throw specific errors when the goal does not match the expected pattern.
  - Good: "modal_t: expected goal of form □φ → φ"
  - Bad: "tactic failed"

## 3. Aesop Integration
- Use the `[TMLogic]` rule set for all project-specific automation.
- Mark axioms as `@[aesop safe]` if they are always valid and productive.
- Mark simplifications as `@[aesop norm simp]` if they reduce formula complexity.

## 4. Testing Tactics
- Always write unit tests in `LogosTest/` or inline `example` blocks.
- Use `fail_if_success` to verify that tactics fail gracefully on invalid goals.

## 5. Unicode
- Use standard unicode symbols in documentation and comments (`□`, `◇`, `△`, `▽`, `⊢`, `⊨`).
- The code itself uses named constructors (`Formula.box`) or defined notation.

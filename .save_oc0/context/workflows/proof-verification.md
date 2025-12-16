# Proof Verification Workflow

This workflow describes the standard process for verifying a logical statement in the Logos system.

## 1. Definition
**Logic Theorist**: Define the formula and the theorem statement.
- Identify the context `Γ` (usually empty `[]` or a set of assumptions).
- Identify the formula `φ`.
- State the goal: `Γ ⊢ φ`.

## 2. Strategy
**Logic Theorist**: Propose a proof strategy.
- Is it a direct consequence of an axiom?
- Does it require induction?
- Can `tm_auto` handle it?

## 3. Implementation
**Lean Expert**: Write the code in a `.lean` file.
```lean
theorem my_theorem (p : Formula) : [] ⊢ (p.box.imp p) := by
  -- Proof script here
  modal_t
```

## 4. Verification
**Lake Builder**: Run the build/test cycle.
- Run `lake build` to ensure no syntax errors.
- If it's a test file, run `lake test` (or the specific test binary).

## 5. Debugging (if failed)
- **Lean Expert**: Analyze the error message (e.g., "tactic 'modal_t' failed").
- **Logic Theorist**: Re-evaluate if the theorem is actually valid or if the strategy was wrong.

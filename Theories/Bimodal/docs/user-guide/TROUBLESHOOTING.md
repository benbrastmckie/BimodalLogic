# Bimodal Troubleshooting Guide

Common errors and solutions when working with the Bimodal TM logic library.

## Table of Contents

1. [Import and Setup Errors](#1-import-and-setup-errors)
2. [Type Errors](#2-type-errors)
3. [Proof Construction Errors](#3-proof-construction-errors)
4. [Tactic Errors](#4-tactic-errors)
5. [Build and Performance Issues](#5-build-and-performance-issues)

---

## 1. Import and Setup Errors

### 1.1 "unknown identifier 'Formula'" or "unknown identifier 'DerivationTree'"

**Error**: Lean cannot find basic Bimodal types.

**Cause**: Missing import or namespace open statements.

**Solution**: Add the required imports and opens at the top of your file:

```lean
import Bimodal

open Bimodal.Syntax
open Bimodal.ProofSystem
```

### 1.2 "unknown identifier 'modal_search'" or "'apply_axiom'"

**Error**: Tactic names are not recognized.

**Cause**: Automation module not imported.

**Solution**: Add the automation import:

```lean
import Bimodal.Automation

open Bimodal.Automation
```

### 1.3 "file not found: Bimodal"

**Error**: The Bimodal library cannot be located.

**Cause**: Project not built or incorrect working directory.

**Solution**:
1. Ensure you're in the ProofChecker root directory
2. Build the project: `lake build`
3. Check that `lakefile.lean` includes Bimodal as a module

### 1.4 "import cycle detected"

**Error**: Circular dependencies between modules.

**Cause**: File imports create a cycle.

**Solution**: Check your import chain. Common fixes:
- Import `Bimodal` instead of individual submodules
- Move shared definitions to a lower-level module
- Use forward declarations where possible

---

## 2. Type Errors

### 2.1 "type mismatch: expected 'Formula', got 'Prop'"

**Error**: Trying to use Lean propositions where formulas are expected.

**Cause**: Confusing `Formula` (our object logic) with `Prop` (Lean's metalogic).

**Solution**: Declare variables as `Formula`, not `Prop`:

```lean
-- Wrong
variable (p q : Prop)

-- Correct
variable (p q : Formula)
```

### 2.2 "type mismatch: expected 'Prop', got 'Type'"

**Error**: Using `DerivationTree` where `Prop` is expected.

**Cause**: `DerivationTree Γ φ` (written `Γ ⊢ φ`) is a `Type`, not a `Prop`.

**Solution**: This is intentional - derivation trees are data structures that can be pattern matched. If you need a propositional statement about derivability, use the notation directly:

```lean
-- DerivationTree is Type - you can pattern match on it
example (d : ⊢ φ) : Nat := d.height

-- If you need Prop, use Nonempty or define your own
def Derivable (Γ : Context) (φ : Formula) : Prop := Nonempty (Γ ⊢ φ)
```

### 2.3 "failed to synthesize instance: Membership Formula (List Formula)"

**Error**: List membership not found.

**Cause**: Using wrong syntax for context membership.

**Solution**: Contexts are `List Formula`, so use standard list membership:

```lean
-- Correct: φ ∈ Γ where Γ : List Formula
example (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Γ ⊢ φ :=
  DerivationTree.assumption Γ φ h
```

### 2.4 "unknown identifier 'diamond'" or "invalid field notation"

**Error**: Derived operators not recognized.

**Cause**: Using wrong syntax for derived operators.

**Solution**: Use the correct method syntax:

```lean
-- Wrong
diamond φ
neg φ

-- Correct - use dot notation on Formula
φ.diamond    -- ◇φ (possibility)
φ.neg        -- ¬φ (negation)
φ.and ψ      -- φ ∧ ψ (conjunction)
φ.or ψ       -- φ ∨ ψ (disjunction)
φ.iff ψ      -- φ ↔ ψ (biconditional)
```

### 2.5 "type mismatch in atom: expected String, got Formula"

**Error**: Passing wrong type to `atom` constructor.

**Cause**: `Formula.atom` takes a `String`, not another `Formula`.

**Solution**:

```lean
-- Wrong
def p : Formula := Formula.atom q  -- q is Formula

-- Correct
def p : Formula := Formula.atom "p"  -- String literal
```

---

## 3. Proof Construction Errors

### 3.1 "cannot apply 'DerivationTree.necessitation': context is not empty"

**Error**: Trying to apply necessitation with non-empty context.

**Cause**: The necessitation rule `⊢ φ ⟹ ⊢ □φ` only works with empty context.

**Solution**: Necessitation only applies to theorems (empty context). For non-empty contexts, use generalized necessitation:

```lean
-- Wrong: Context is not empty
example (φ : Formula) : [ψ] ⊢ φ.box := by
  apply DerivationTree.necessitation  -- Error!

-- Correct: Use empty context
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box :=
  DerivationTree.necessitation φ h

-- For non-empty context, use weakening or generalized_modal_k
import Bimodal.Theorems.GeneralizedNecessitation

noncomputable example (φ : Formula) : [φ.box] ⊢ φ.box.box := by
  have h : [φ] ⊢ φ.box := ...
  exact Theorems.generalized_modal_k [φ] φ.box h
```

### 3.2 "cannot apply 'DerivationTree.temporal_duality': context is not empty"

**Error**: Temporal duality requires empty context.

**Cause**: Same as necessitation - this is a theorem-level rule.

**Solution**: Only apply to theorems with empty context `[]`.

### 3.3 "no matching axiom found" or "goal does not match axiom pattern"

**Error**: Trying to apply wrong axiom.

**Cause**: The formula doesn't match the axiom's pattern.

**Solution**: Check the axiom reference. Common axiom patterns:

| Axiom | Pattern | Use For |
|-------|---------|---------|
| `modal_t` | `□φ → φ` | Eliminating necessity |
| `modal_4` | `□φ → □□φ` | Iterating necessity |
| `modal_b` | `φ → □◇φ` | Introducing necessity of possibility |
| `modal_k_dist` | `□(φ → ψ) → (□φ → □ψ)` | Modal distribution |
| `prop_k` | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` | Combining implications |
| `prop_s` | `φ → (ψ → φ)` | Weakening |

### 3.4 "cannot find assumption in context"

**Error**: `DerivationTree.assumption` fails.

**Cause**: Formula is not literally in the context list, or list ordering issue.

**Solution**: Check exact membership. Context is a list, so order matters for `simp`:

```lean
-- Context [φ, ψ] contains φ at position 0
example (φ ψ : Formula) : [φ, ψ] ⊢ φ := by
  apply DerivationTree.assumption
  simp  -- Proves φ ∈ [φ, ψ]

-- If simp fails, try explicit proof
example (φ ψ : Formula) : [φ, ψ] ⊢ φ :=
  DerivationTree.assumption [φ, ψ] φ (List.mem_cons_self φ [ψ])
```

### 3.5 "unsolved goals after modus_ponens"

**Error**: Modus ponens leaves unprovable subgoals.

**Cause**: Wrong formula split for the implication.

**Solution**: `modus_ponens` requires two subproofs:
1. `Γ ⊢ φ → ψ` (the implication)
2. `Γ ⊢ φ` (the antecedent)

```lean
-- Proving Γ ⊢ ψ via modus ponens
example (φ ψ : Formula) : [φ, φ.imp ψ] ⊢ ψ := by
  apply DerivationTree.modus_ponens (φ := φ)  -- Specify which φ
  · -- Subgoal 1: prove [φ, φ.imp ψ] ⊢ φ.imp ψ
    apply DerivationTree.assumption; simp
  · -- Subgoal 2: prove [φ, φ.imp ψ] ⊢ φ
    apply DerivationTree.assumption; simp
```

---

## 4. Tactic Errors

### 4.1 "modal_search: no proof found within depth N"

**Error**: Proof search exhausted without finding proof.

**Cause**: Proof requires more depth, or is not automatically provable.

**Solution**: Increase depth or use manual tactics:

```lean
-- Increase depth (default is 10)
example (φ : Formula) : ⊢ complex_formula := by
  modal_search 20  -- Try depth 20

-- Or use named parameter
example (φ : Formula) : ⊢ complex_formula := by
  modal_search (depth := 25)
```

### 4.2 "aesop: internal error during proof reconstruction"

**Error**: `tm_auto` fails with aesop internal error.

**Cause**: Known issue with aesop on `DerivationTree` goals. See [KNOWN_LIMITATIONS.md](../project-info/KNOWN_LIMITATIONS.md).

**Solution**: Use `modal_search` instead of `tm_auto`:

```lean
-- May fail with aesop error
example (φ : Formula) : ⊢ φ.box.imp φ := by
  tm_auto  -- Error!

-- Use modal_search instead
example (φ : Formula) : ⊢ φ.box.imp φ := by
  modal_search
```

### 4.3 "tactic 'modal_t' failed: goal must be derivability relation"

**Error**: Tactic applied to wrong goal type.

**Cause**: Goal is not of form `Γ ⊢ φ`.

**Solution**: Ensure goal is a `DerivationTree`:

```lean
-- Wrong: goal is Prop
example : True := by
  modal_t  -- Error: not a derivability goal

-- Correct: goal is DerivationTree
example (φ : Formula) : ⊢ φ.box.imp φ := by
  apply_axiom  -- Applies matching axiom
```

### 4.4 Confusion between `modal_t` tactic and `Axiom.modal_t`

**Error**: Using constructor where tactic is expected or vice versa.

**Cause**: Name collision between tactic and axiom constructor.

**Solution**:
- `modal_t` (no prefix) is a tactic - use in `by` blocks
- `Axiom.modal_t` is a constructor - use in term mode

```lean
-- Tactic mode
example (φ : Formula) : ⊢ φ.box.imp φ := by
  apply_axiom  -- Finds and applies modal_t pattern

-- Term mode
example (φ : Formula) : ⊢ φ.box.imp φ :=
  DerivationTree.axiom [] _ (Axiom.modal_t φ)
```

---

## 5. Build and Performance Issues

### 5.1 Slow compilation for complex proofs

**Symptom**: Building files with many proofs takes a long time.

**Cause**: Type class inference and proof search are computationally expensive.

**Solutions**:
1. Use `noncomputable` for proofs that don't need to compute
2. Mark intermediate lemmas with `@[simp]` to help simplification
3. Split large proofs into smaller lemmas
4. Use explicit type annotations to help inference

```lean
-- Add noncomputable if proof doesn't need to compute
noncomputable def my_proof : ⊢ complex_formula := by
  ...

-- Explicit type annotations help inference
example (φ : Formula) : DerivationTree ([] : Context) φ.box.imp φ := by
  ...
```

### 5.2 "deterministic timeout" or memory issues

**Symptom**: Lean times out or runs out of memory.

**Cause**: Proof search exploring too many branches, or large term elaboration.

**Solutions**:
1. Break proof into smaller steps with `have`
2. Use lower proof search depth
3. Provide explicit arguments to avoid inference

```lean
-- Break into steps
example : ⊢ very_complex := by
  have h1 : ⊢ intermediate1 := ...
  have h2 : ⊢ intermediate2 := ...
  exact combine h1 h2
```

### 5.3 ProofSearch module build failures

**Symptom**: `Bimodal.Automation.ProofSearch` fails to build.

**Cause**: Known issue - ProofSearch is blocked pending architecture changes. See [Task 260](/specs/260_proof_search/).

**Solution**: Use `Bimodal.Automation.Tactics` instead, which provides `modal_search` and other working tactics.

### 5.4 "failed to synthesize: DecidableEq Formula"

**Error**: Decidability instance not found.

**Cause**: Some operations require decidable equality on formulas.

**Solution**: Formula has a `DecidableEq` instance; ensure it's available:

```lean
import Bimodal.Syntax.Formula

-- DecidableEq is derived, should work automatically
#check (inferInstance : DecidableEq Formula)
```

---

## Getting More Help

- **Quick Start Guide**: [QUICKSTART.md](QUICKSTART.md)
- **Proof Patterns**: [PROOF_PATTERNS.md](PROOF_PATTERNS.md)
- **Examples with Solutions**: [EXAMPLES.md](EXAMPLES.md#7-exercises)
- **Axiom Reference**: [AXIOM_REFERENCE.md](../reference/AXIOM_REFERENCE.md)
- **Tactic Reference**: [TACTIC_REFERENCE.md](../reference/TACTIC_REFERENCE.md)
- **Known Limitations**: [KNOWN_LIMITATIONS.md](../project-info/KNOWN_LIMITATIONS.md)

## Navigation

- [Quick Start](QUICKSTART.md)
- [User Guide](README.md)
- [Back to Bimodal](../../README.md)

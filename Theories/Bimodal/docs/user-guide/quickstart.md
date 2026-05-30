# Bimodal Quick Start

Get started with Bimodal proofs in under 10 minutes.

## Prerequisites

- Lean 4 installed and configured
- ProofChecker project cloned and built (`lake build`)
- VS Code with lean4 extension (recommended)

## Your First Bimodal Proof

### 1. Import the Library

```lean
import Bimodal

open Bimodal.Syntax
open Bimodal.ProofSystem
```

### 2. Define Formulas

Bimodal formulas are built from:

| Constructor | Meaning | Example |
|-------------|---------|---------|
| `atom s` | Propositional variable | `atom "p"` |
| `bot` | False (`⊥`) | `bot` |
| `φ.imp ψ` | Implication (`φ → ψ`) | `p.imp q` |
| `φ.box` | Necessity (`□φ`) | `p.box` |
| `φ.past` | Historical (`▽φ`) | `p.past` |
| `φ.future` | Future (`△φ`) | `p.future` |

Derived operators:
- `φ.neg` = `φ.imp bot` (negation)
- `φ.diamond` = `φ.box.neg.neg` (possibility)
- `φ.and ψ` = conjunction
- `φ.or ψ` = disjunction

### 3. Write a Simple Proof

```lean
-- Prove: □(p → q) → (□p → □q) (modal distribution)
example (p q : Formula) : ⊢ ((p.imp q).box).imp (p.box.imp q.box) := by
  exact modal_k p q
```

### 4. Use Derivation Trees

Proofs in Bimodal use `DerivationTree` for explicit proof construction:

```lean
-- Modus ponens example
example (φ ψ : Formula) (h1 : ⊢ φ.imp ψ) (h2 : ⊢ φ) : ⊢ ψ := by
  exact DerivationTree.modusPonens h1 h2
```

## Key Operators

| Symbol | Lean | Name | Reads as |
|--------|------|------|----------|
| `□` | `.box` | Necessity | "necessarily" |
| `◇` | `.diamond` | Possibility | "possibly" |
| `△` | `.future` | Always Future | "always will be" |
| `▽` | `.past` | Always Past | "always was" |
| `→` | `.imp` | Implication | "implies" |
| `¬` | `.neg` | Negation | "not" |

## Common Proof Techniques

### Apply Axioms

```lean
-- Modal T axiom: □p → p
example (p : Formula) : ⊢ p.box.imp p := modal_t p

-- Modal 4 axiom: □p → □□p
example (p : Formula) : ⊢ p.box.imp p.box.box := modal_4 p
```

### Use Necessitation

```lean
-- From ⊢ φ derive ⊢ □φ
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box := by
  exact DerivationTree.necessitation h
```

### Combine Theorems

```lean
-- Transitivity of implication
example (A B C : Formula) : ⊢ (A.imp B).imp ((B.imp C).imp (A.imp C)) :=
  transitivity A B C
```

## Next Steps

1. **Learn proof patterns**: [PROOF_PATTERNS.md](PROOF_PATTERNS.md)
2. **Reference axioms**: [AXIOM_REFERENCE.md](../reference/AXIOM_REFERENCE.md)
3. **See examples**: [Bimodal/Examples/](../../Examples/)
4. **General tutorial**: [TUTORIAL.md](../../../docs/user-guide/TUTORIAL.md)

## Troubleshooting

### "unknown identifier"

Check imports:
```lean
import Bimodal
open Bimodal.Syntax
open Bimodal.ProofSystem
```

### "type mismatch"

Ensure you're working with `Formula` type:
```lean
variable (p q : Formula)  -- Correct
-- Not: variable (p q : Prop)
```

### "unsolved goals"

Use `lean_goal` or VS Code goal view to see proof state. Apply appropriate
lemma or tactic.

### More Help

For detailed troubleshooting with 20+ error patterns, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

For practice problems with hints and solutions, see [EXAMPLES.md](EXAMPLES.md#7-exercises).

## Navigation

- [Proof Patterns](PROOF_PATTERNS.md) - Common patterns
- [Examples and Exercises](EXAMPLES.md) - Worked examples with solutions
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Detailed error solutions
- [Axiom Reference](../reference/AXIOM_REFERENCE.md) - Complete axiom list
- [Back to User Guide](README.md)

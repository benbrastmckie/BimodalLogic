# Propositional — Propositional Theorems

Propositional tautologies and derived rules for TM bimodal logic.

This directory contains derived propositional theorems used across the library,
including double-negation elimination, contraposition, de Morgan laws, and
propositional combinator lemmas. These are the propositional building blocks
that higher-level proofs rely on.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Connectives.lean` | 745 | Derived connective theorems: conjunction, disjunction, negation laws |
| `Core.lean` | 730 | Core propositional theorems: double negation, contraposition, ex falso |
| `Reasoning.lean` | 247 | Propositional reasoning rules: hypothetical syllogism, modus tollens |

## Key Results

- Double negation elimination: `⊢ ¬¬φ → φ`
- Contraposition: `⊢ (φ → ψ) → (¬ψ → ¬φ)`
- De Morgan laws for conjunction and disjunction
- Disjunctive syllogism, hypothetical syllogism

## Dependencies

- **Imports from**: `Bimodal.ProofSystem`
- **Imported by**: `Bimodal.Metalogic.Core`, `Bimodal.Theorems.Combinators`

## Related Documentation

- [Theorems README](../README.md)
- [ProofSystem README](../../ProofSystem/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

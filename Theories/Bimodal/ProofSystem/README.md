# ProofSystem

Hilbert-style proof system for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| Axioms.lean | 15 TM axiom schemas |
| Derivation.lean | Derivation tree inductive type and inference rules |
| LinearityDerivedFacts.lean | Derived facts about temporal linearity |

## Key Definitions

- `Axiom`: Inductive type for 15 TM axiom schemas
- `DerivationTree`: Proof trees with axiom, assumption, modus ponens, necessitation rules
- `Derives`: Derivability relation `Gamma |- phi`

## Axiom Categories

- **Propositional** (2): K, S combinators
- **Modal** (6): T, 4, B, 5-collapse, K-distribution, modal-future
- **Temporal** (5): TK, T4, TA, TL, temporal-future
- **Classical** (2): Ex falso, Peirce's law

## Related Documentation

- [Parent README](../README.md)
- [Metalogic](../Metalogic/README.md) - Soundness and completeness of proof system

---

*Last Updated: 2026-03-16*

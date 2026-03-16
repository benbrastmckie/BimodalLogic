# Syntax

Core syntactic definitions for TM bimodal logic formulas.

## Contents

| File | Description |
|------|-------------|
| Formula.lean | Formula inductive type with modal and temporal operators |
| Atom.lean | Propositional atom type |
| Context.lean | Proof context (list of formulas) |
| Subformulas.lean | Subformula relation and listing |
| SubformulaClosure.lean | Subformula closure as Finset for BFMCS construction |

## Key Definitions

- `Formula`: The inductive type for TM bimodal logic formulas
- `Atom`: Propositional atoms (sentence letters)
- `Context`: Type alias for `List Formula`
- `subformulas`: List all subformulas of a formula

## Related Documentation

- [Parent README](../README.md)
- [ProofSystem](../ProofSystem/README.md) - Uses formulas for derivations

---

*Last Updated: 2026-03-16*

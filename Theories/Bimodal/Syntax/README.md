# Syntax

Core syntactic definitions for TM bimodal logic formulas.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Atom.lean` | 208 | `Atom`: Propositional atom type with decidable equality |
| `BigConj.lean` | 49 | `bigConj`: Big conjunction over a list of formulas |
| `Context.lean` | 204 | `Context`: Type alias for `List Formula` (proof contexts) |
| `Formula.lean` | 566 | `Formula`: Inductive formula type with modal and temporal operators |
| `Subformulas.lean` | 229 | `subformulas`: Subformula relation and listing function |
| `SubformulaClosure/` | — | Subformula closure as `Finset` for BFMCS construction (3 files) |

## Key Definitions

- `Formula`: The inductive type for TM bimodal logic formulas:
  - Primitives: `atom`, `bot`, `imp`, `box`, `all_past`, `all_future`
  - Derived (notation): `neg`, `top`, `or`, `and`, `diamond`, `some_past`, `some_future`, `always`, `sometimes`
- `Atom`: Propositional atoms (string-indexed sentence letters)
- `Context`: Type alias for `List Formula`
- `subformulas`: List all subformulas of a formula (recursive descent)
- `bigConj`: Fold over a list using conjunction

## Related Documentation

- [Parent README](../README.md)
- [SubformulaClosure README](SubformulaClosure/README.md)
- [ProofSystem README](../ProofSystem/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

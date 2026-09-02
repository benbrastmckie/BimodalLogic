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
  - Constructors (six, `Formula.lean:76-105`): `atom`, `bot`, `imp`, `box`, `untl`, `snce`.
    `untl`/`snce` are guard-first — `untl guard event` — so `untl` is Until and `snce` is Since.
  - Derived (definitions, not constructors): `neg`, `top`, `or`, `and`, `diamond`, `someFuture`,
    `somePast`, `allFuture`, `allPast`, `always`, `sometimes`. The temporal four are camelCase;
    `H`/`G`/`P`/`F` are derived from `untl`/`snce`, not primitive.
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

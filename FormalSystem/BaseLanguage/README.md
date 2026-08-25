# BaseLanguage — the tense-primitive object language BL

This directory defines a **second object language** for TM, and its proof system.

Where the primary language (`FormalSystem/Syntax/Formula.lean`) takes `untl` and `snce` as
primitive and derives `H`/`G`, the base language `BL` takes `H` (`allPast`) and `G`
(`allFuture`) as *primitive*:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ
```

The two languages are related by the translation `tr` (`Translation.lean`), which is what the
conservativity result in `FormalSystem/Metalogic/Conservativity.lean` transports along. `BL` is
the language in which the source paper states TM; the primary language is the one this
repository's metalogic is proved in.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `AxiomDischarge.lean` | 381 | `dischargeAxiom` — for each `BaseLanguage.Axiom` constructor, a primary-language derivation of that axiom's translation. Seven rows are exact; the rest go through the `F`/`P` bridge. |
| `Axioms.lean` | 171 | `BaseLanguage.Axiom` — TM's axiom schemata over BL (MK, MT, M5, MF, TK, T4, TB, TA, TL), plus the three extension axioms routed to their frame classes by `Axiom.minFrameClass`. This is a second `inductive Axiom`, distinct from the primary language's. |
| `Derivation.lean` | 189 | `BaseLanguage.DerivationTree` — a constructor-for-constructor mirror of the primary `DerivationTree`, with the same 7 inference rules, over `BLFormula`. |
| `Formula.lean` | 203 | `BLFormula`, the tense-primitive base language, with `allPast`/`allFuture` as constructors rather than abbreviations. |
| `Translation.lean` | 266 | `tr : BLFormula → Formula` and `trCtx` — the translation into the primary language, sending each BL primitive to the primary operator of the same name. |

## Key Results

- `tr` (`Translation.lean`) — the translation of BL into the primary language.
- `dischargeAxiom` (`AxiomDischarge.lean`) — the axiom-discharge table that makes the `axiom`
  case of `Conservativity.translate` a one-line match.
- `BaseLanguage.DerivationTree` (`Derivation.lean`) — the mirror proof system, which is what
  makes `Conservativity.translate` a seven-case structural recursion with one case per rule.

## Dependencies

- **Imports from**: `FormalSystem.Syntax`, `FormalSystem.ProofSystem`, `FormalSystem.Theorems`
- **Imported by**: `FormalSystem.Metalogic.Conservativity`

## Related Documentation

- [FormalSystem README](../README.md)
- [Syntax README](../Syntax/README.md) — the primary, until/since-primitive language
- [ProofSystem README](../ProofSystem/README.md)

---

**Last verified**: 2026-08-25

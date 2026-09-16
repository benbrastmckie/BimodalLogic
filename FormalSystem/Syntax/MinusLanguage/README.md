# MinusLanguage — the tense-primitive object language L⁻

This directory defines a **second object language**, L⁻, and its proof system TM⁻.

Where the primary language (`FormalSystem/Syntax/Formula.lean`) takes `untl` and `snce` as
primitive and derives `H`/`G`, the base language `L⁻` takes `H` (`allPast`) and `G`
(`allFuture`) as *primitive*:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ
```

The two languages are related by the translation `tr` (`Translation.lean`), which is what the
conservativity result in `FormalSystem/Metalogic/Conservativity/Backward.lean` transports along.
`L⁻` and `TM⁻` are this repository's own: the manuscript withdrew its H/G fragment, so neither
answers to a paper name. The primary language `L` — the paper's own 𝓛 — is the one this
repository's metalogic is proved in.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `AxiomDischarge.lean` | 381 | `dischargeAxiom` — for each `MinusLanguage.Axiom` constructor, a primary-language derivation of that axiom's translation. Seven rows are exact; the rest go through the `F`/`P` bridge. |
| `Axioms.lean` | 171 | `MinusLanguage.Axiom` — TM⁻'s axiom schemata over L⁻ (MK, MT, M5, MF, TK, T4, TB, TA, TL), plus the three extension axioms routed to their frame classes by `Axiom.minFrameClass`. This is a second `inductive Axiom`, distinct from the primary language's. |
| `Derivation.lean` | 189 | `MinusLanguage.DerivationTree` — a constructor-for-constructor mirror of the primary `DerivationTree`, with the same 7 inference rules, over `MinusFormula`. |
| `Formula.lean` | 210 | `MinusFormula`, the tense-primitive base language, with `allPast`/`allFuture` as constructors rather than abbreviations. |
| `Translation.lean` | 266 | `tr : MinusFormula → Formula` and `trCtx` — the translation into the primary language, sending each L⁻ primitive to the primary operator of the same name. |

## Where the L⁻ semantics lives

Nothing in this directory defines truth, validity, or a frame — that is the standing module
invariant recorded in `FormalSystem/Syntax/MinusLanguage.lean`, and it is **directional**: it forbids the
edge `MinusLanguage/ → Semantics/` and says nothing about the converse, which is permitted and
used. The base language's semantics is sited outside this directory, on the far side of that
permitted edge:

| File | What it carries |
|------|-----------------|
| `FormalSystem/Semantics/MinusTruth.lean` | `MinusTruthAt`, a native six-clause recursion on `MinusFormula` per `def:BL-semantics` — **not** `TruthAt ∘ tr` |
| `FormalSystem/Semantics/MinusValidity.lean` | `MinusValid`, `MinusSemanticConsequence`, and the Dense / Discrete / Dedekind-dense validity predicates |
| `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` | the truth-transfer bridge `truthAt_tr`, and L⁻ soundness at `FrameClass.Base` and its three extensions, by composition through `Conservativity.translate` |

`Semantics/MinusTruth.lean` imports `Formula.lean` only — a leaf whose own sole import is
`FormalSystem.Syntax.Atom` — so the edge introduces no cycle.

## Key Results

- `tr` (`Translation.lean`) — the translation of L⁻ into the primary language.
- `dischargeAxiom` (`AxiomDischarge.lean`) — the axiom-discharge table that makes the `axiom`
  case of `Conservativity.translate` a one-line match.
- `MinusLanguage.DerivationTree` (`Derivation.lean`) — the mirror proof system, which is what
  makes `Conservativity.translate` a seven-case structural recursion with one case per rule.

## Dependencies

- **Imports from**: `FormalSystem.Syntax`, `FormalSystem.ProofSystem`, `FormalSystem.Theorems`
- **Imported by**: `FormalSystem.Metalogic.Conservativity` (whole directory);
  `FormalSystem.Semantics.MinusTruth` (`Formula.lean` only, for `MinusFormula`)

## Related Documentation

- [FormalSystem README](../../README.md)
- [Syntax README](../README.md) — the primary, until/since-primitive language
- [ProofSystem README](../../ProofSystem/README.md)
- [Semantics README](../../Semantics/README.md) — where `MinusTruth.lean` and `MinusValidity.lean` live
- [Metalogic README](../../Metalogic/README.md) — where `MinusLanguageSoundness.lean` lives

---

**Last verified**: 2026-09-08

---

*Last verified: 2026-09-08*

# Syntax

Core syntactic definitions for TM bimodal logic formulas.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Syntax -->
| File | Lines | Description |
|------|-------|-------------|
| `Atom.lean` | 215 | `Atom`: Propositional atom type with decidable equality |
| `BigConj.lean` | 55 | `bigConj`: Big conjunction over a list of formulas |
| `Context.lean` | 210 | `Context`: Type alias for `List Formula` (proof contexts) |
| `Formula.lean` | 855 | `Formula`: Inductive formula type with modal and temporal operators |
| `MinusLanguage.lean` | 45 | Sibling aggregator for `MinusLanguage/` (the language L⁻) |
| `PlusLanguage.lean` | 54 | Sibling aggregator for `PlusLanguage/` (the language L⁺) |
| `StarLanguage.lean` | 60 | Sibling aggregator for `StarLanguage/` (the language L⋆) |
| `SubformulaClosure.lean` | 38 | Sibling aggregator for `SubformulaClosure/` |
| `Subformulas.lean` | 235 | `subformulas`: Subformula relation and listing function |
| `MinusLanguage/` | — | L⁻: `MinusFormula` with `allPast`/`allFuture` primitive in place of `untl`/`snce`, its axioms, proof system and the translation `tr` to L (6 files) |
| `PlusLanguage/` | — | L⁺: `PlusFormula` = L plus the stability modal `⊡` (`stab`, "boxdot"), its axioms, proof system, embedding and substitution (5 files) |
| `StarLanguage/` | — | L⋆: `StarFormula` = L⁺ plus the time registers `↑ⁱ`/`↓ⁱ` (`timeStore`/`timeRecall`), its axioms, proof system and embedding (4 files) |
| `SubformulaClosure/` | — | Subformula closure as `Finset` for BFMCS construction (4 files) |
<!-- END GENERATED -->

## Language family

`Syntax/` holds four object languages, not one. Each subdirectory below is a *separate
inductive type* with its own axioms, derivation system and (elsewhere) semantics — they are not
notations over a shared `Formula`.

| Directory | Language | Type | Constructors |
|-----------|----------|------|--------------|
| `Syntax/` (here) | L | `Formula` | `atom`, `bot`, `imp`, `box`, `untl`, `snce` (6) |
| [`Syntax/MinusLanguage/`](MinusLanguage/README.md) | L⁻ | `MinusFormula` | `atom`, `bot`, `imp`, `box`, `allPast`, `allFuture` (6) |
| [`Syntax/PlusLanguage/`](PlusLanguage/README.md) | L⁺ | `PlusFormula` | L's six **+ `stab`** (7) |
| [`Syntax/StarLanguage/`](StarLanguage/README.md) | L⋆ | `StarFormula` | L⁺'s seven **+ `timeStore`, `timeRecall`** (9) |

### The chain, and the one that is not in it

**L ⊂ L⁺ ⊂ L⋆ is the extension chain.** Each adds constructors to the one before, and each
comes with a constructor-to-constructor embedding (`PlusFormula.ofFormula`,
`StarFormula.ofPlus`).

**L⁻ is *not* an extension of L.** It is a **sibling variant**: it takes `H`/`G`
(`allPast`/`allFuture`) as *primitive constructors* in place of L's `untl`/`snce`, so neither
language's constructor set contains the other's. The two are related by a translation,
`tr : MinusFormula → Formula`, in
[`MinusLanguage/Translation.lean`](MinusLanguage/Translation.lean) — not by an embedding. L⁻ is
the language in which the source paper states TM.

Do not describe these four as "one extension hierarchy": three of them form a chain and the
fourth does not belong to it.

### Looking for boxdot (`⊡`)?

**It already exists.** The **stability modal** `⊡` — the constructor `stab`, read "settled at
the present world state" — is implemented in
[`Syntax/PlusLanguage/`](PlusLanguage/README.md), and it is complete rather than partial:
`PlusFormula` with `stab`, the eight `⊡` axiom schemata in `PlusLanguage/Axioms.lean`, the
`PlusDerivationTree` proof system, the embedding `ofFormula`, backward conservativity, and the
`PlusTruthAt` semantics in `FormalSystem/Semantics/PlusTruth.lean`. It carries no `sorry`.

`⊡` is also the sole operator L⁺ adds to L, so "L plus boxdot" and "L⁺" name the same language.
It is carried forward unchanged into L⋆, whose own additions are the two hybrid time registers
`↑ⁱ` (`timeStore`) and `↓ⁱ` (`timeRecall`).

This section exists because `⊡` was previously built, sorry-free, in a directory that sat as a
flat sibling of `Syntax/` with nothing pointing here — so a reader starting from the base
language had no way to discover it and was at real risk of rebuilding it.

### Namespaces stay flat

Nesting these directories under `Syntax/` did **not** change their namespaces: the declarations
in `Syntax/MinusLanguage/` are still in `FormalSystem.MinusLanguage`, not
`FormalSystem.Syntax.MinusLanguage`. Prose naming those namespaces is therefore correct as
written even though the *module* paths are now `FormalSystem.Syntax.MinusLanguage.*`.

`FormalSystem/Syntax.lean` also deliberately does not import the three nested aggregators, so a
bare `import FormalSystem.Syntax` stays as cheap as it was before the move.

## Key Definitions

- `Formula`: The inductive type for TM bimodal logic formulas:
  - Constructors (six, `Formula.lean`): `atom`, `bot`, `imp`, `box`, `untl`, `snce`.
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

*Last verified: 2026-09-07*

# Expressiveness — Kamp/Stavi Expressive Completeness

Expressive-completeness results for TM: which first-order properties of a temporal flow are
definable by a temporal formula.

This directory holds the monadic first-order framework, the Ehrenfeucht-Fraisse game engine,
the normal-form theory, the Gabbay separation route, and the Kamp and Stavi expressive
completeness theorems built on top of them.

The development answers a question about **expressive power**, not about canonical models. It
previously lived inside [`Metalogic/WeakCanonical/`](../WeakCanonical/README.md), where the
directory name misdescribed it and put `WeakCanonical` into the fully-qualified name of every
result — including the two headline theorems an external reader would cite. No module in this
directory imports anything from `WeakCanonical/` or `BXCanonical/`, so the two developments are
a genuine partition; `scripts/measure-refactor-partitions.py --check` asserts that standing.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `EFGameTactics.lean` | 333 | EF game automation tactics for expressive completeness proofs |
| `MonadicFO.lean` | 823 | Monadic first-order logic translation for expressiveness results |
| `NormalForm.lean` | 882 | Normal form for TM formulas used in the expressiveness proofs |
| `PriorDefs.lean` | 47 | Shared definitions for the Prior expressiveness development |
| `PriorDefsDense.lean` | 409 | Prior definitions specialized to the dense setting |
| `PriorExpressiveness.lean` | 378 | Prior's theorem on temporal expressiveness |
| `PriorExpressivenessDense.lean` | 389 | Prior expressiveness in the dense setting |
| `StaviConnectives.lean` | 583 | Stavi connectives (Until, Since extensions) and their properties |
| `Table.lean` | 296 | Tabular representation for N-equivalence classes |
| `EFGames/` | 11,800 | Ehrenfeucht-Fraisse bisimulation game engine (8 files) |
| `GameTransfer/` | 9,507 | Transfer of game equivalences across structures (5 files) |
| `Kamp/` | 77,714 | Kamp/Rabinovich separation machinery (116 files) -- by far the largest subtree in the repository |
| `Separation/` | 926 | Separation theorem and supporting lemmas (3 files) |

Measured live contents: **9 loose modules and 4 subdirectories**, 141 modules in total.
The aggregator for this directory is the sibling `Metalogic/Expressiveness.lean`, not a
self-named file inside it. Counts above are measured and exclude the archive. Run
`scripts/check-module-invariants.sh` rather than an ad-hoc `find` to re-derive live counts.

## Key Results

- `Kamp.kampPriorExpressiveCompleteness`: Kamp's expressive-completeness theorem for the Prior
  connectives over Dedekind-complete flows.
- `uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean`): the load-bearing corollary
  consumed by the live completeness chain.

Both are on the main-results page (`FormalSystem/MainResults.lean`) and both are pinned by
check C14's axiom baseline in `scripts/check-module-invariants.sh`, recorded as depending on
exactly `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.

## Architecture

```
MonadicFO.lean            (monadic signature, MonadicFormula, evaluation)
       |
       +-- NormalForm.lean
       |        |
       +-- EFGames/             (bisimulation games, StaviCompleteness)
       |        |
       +-- GameTransfer/        (game equivalence transfer)
       +-- Separation/          (Gabbay separation route)
       +-- Table.lean           (temporal-to-monadic table translation)
       |
       +-- Kamp/                (the Kamp theorem chain)
       +-- PriorDefs{,Dense}.lean / PriorExpressiveness{,Dense}.lean
       +-- StaviConnectives.lean
```

## Dependencies

- **Imports from**: `FormalSystem.Syntax`, `FormalSystem.Semantics`, `FormalSystem.Metalogic.Core`
- **Imported by**: `FormalSystem.Metalogic.Expressiveness` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [WeakCanonical README](../WeakCanonical/README.md)
- [EFGames README](EFGames/README.md)
- [Separation README](Separation/README.md)

---

*Last verified: 2026-09-21*

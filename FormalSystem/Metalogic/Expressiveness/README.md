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
| `OpenFutureElimination.lean` | 743 | Elimination of a disjunction under the open-future and open-past modals, its conjunctive-normal-form version, a translation into L⁺ conditional on a named separation hypothesis, the transfer corollaries reducing open-language decidability and completeness to their L⁺ counterparts, and the stability-cluster type product: the (past-type, future-type) pairs realized across a stability cluster are exactly the product of the realized past-types with the realized future-types |
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
| `SeparationZ/` | 6,875 | Gabbay separation over the integer flow, on an auxiliary until/since syntax with abstract leaves: GHR Lemmas 10.2.1-10.2.8 and Theorem 10.2.9 in full, the CNF packaging of the separated form, the discharge `separationOver_ztime : SeparationOver TaskFrame.IsZTime` with the computable `sepZ`, and the computable translation `trZ` (13 files) |

Measured live contents: **10 loose modules and 5 subdirectories**, 157 modules in total
(10 loose + EFGames 11 + GameTransfer 5 + Kamp 115 + Separation 3 + SeparationZ 13), re-derived
rather than incremented. The per-subdirectory file and line figures in the table above are hand-written and
lag that measurement; the live figures and the generated `Expressiveness/` row in
[`Metalogic/README.md`](../README.md) are the authority, not the table cells. The aggregator for
this directory is the sibling `Metalogic/Expressiveness.lean`, not a self-named file inside it.
Counts above exclude the archive. Run `scripts/check-module-invariants.sh` rather than an ad-hoc
`find` to re-derive live counts.

## Key Results

- `Kamp.kampPriorExpressiveCompleteness`: Kamp's expressive-completeness theorem for the Prior
  connectives over Dedekind-complete flows.
- `uSExpressivelyCompleteOverPrior` (`PriorExpressiveness.lean`): the load-bearing corollary
  consumed by the live completeness chain.

- `ofutP_or_iff` / `opastP_or_iff` and `ofutP_sepForm_iff` / `opastP_sepForm_iff`
  (`OpenFutureElimination.lean`): the open-future and open-past modals eliminated against a
  separated disjunction and against a separated conjunctive normal form, on every regular task
  frame. On top of them, `openValidIn_ztime_iff_tr` and `openValidIn_rtime_iff_tr` transfer
  validity along the translation `tr` at `.ZTime` and `.RTime` — **conditional on
  `SeparationOver`**, an explicit named hypothesis standing for separation over the class.
  `SeparationZ/` discharges it at `.ZTime`: `separationOver_ztime` (`SeparationZ/Discharge.lean`)
  proves `SeparationOver TaskFrame.IsZTime` from GHR Lemmas 10.2.1-10.2.8 and Theorem 10.2.9 over
  the integer flow, so `openValidIn_ztime_iff_tr` is instantiable there, and `trZ` with
  `openValidIn_ztime_iff_trZ` (`SeparationZ/Computable.lean`) is the unconditional computable
  form. At `.RTime` the hypothesis (GHR Theorem 10.3.20) remains undischarged. It fails over the
  non-Dedekind-complete flows, so nothing in that module reaches the dense or unconstrained
  classes.
  On top of those transfers sit the **transfer corollaries**
  `decidableOpenValidInOfTranslation`, `openDecider_correct`, `exists_translation_ztime` /
  `exists_translation_rtime`, `decidableOpenValidZTimeOfTr` / `decidableOpenValidRTimeOfTr`,
  `openComplete_of_plusComplete_in` and `openValid_of_plusSound`. Each states a **reduction**:
  given decidability resp. completeness of L⁺ validity at a frame class, the corresponding
  open-language fact follows. Every antecedent is undischarged — `Decidable (PlusValidIn
  FrameClass.ZTime _)` is stated nowhere in this tree, completeness of any recursive extension of
  TM⁺ is open at every frame class, and `tr` is noncomputable, so no decision procedure and no
  recursive axiomatization follows either. **No completeness or decidability result for the
  open-future language is established, at any class.**
  That module also **owns the shared vocabulary** `PastDet`, `FutDet`, `OfutP` and `OpastP`, all
  public and documented, together with the syntactic bridges `pastDet_of_isPurePast` and
  `futDet_of_isPureFuture` and the two split-free ends `ofutP_of_pastDet` and `ofutP_of_futDet`;
  a consumer elsewhere in the tree imports them from here rather than redefining them.

The first two are on the main-results page (`FormalSystem/MainResults.lean`) and both are pinned
by check C14's axiom baseline in `scripts/check-module-invariants.sh`, recorded as depending on
exactly `[propext, Classical.choice, Quot.sound]` with no `sorryAx`. The elimination layer is
pinned by the same baseline but is deliberately absent from the main-results page, because its
headline statement is conditional on unformalized literature.

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
       +-- OpenFutureElimination.lean  (open-future/open-past elimination; conditional
                                        translation into L-plus)
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

*Last verified: 2026-11-11*

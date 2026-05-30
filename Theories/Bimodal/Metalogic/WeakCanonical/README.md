# WeakCanonical — Weak Canonical Model Construction

Weak canonical model construction for Base TM completeness (Henkin-style approach).

This directory implements completeness for the Base TM logic variant via a reflexive
canonical model. The approach generalizes the classical Henkin construction to the
bimodal setting with temporal operators, using bisimulation equivalence games to
characterize expressive power and establishing completeness via normal-form reduction.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ChronicleExtraction.lean` | 255 | Extracting chronicles from the weak canonical model |
| `FrameProperties.lean` | 55 | Frame property verification for the weak canonical model |
| `MonadicFO.lean` | 406 | Monadic first-order logic translation for expressiveness results |
| `NEquivalence.lean` | 1227 | N-equivalence relation and its properties for bisimulation games |
| `NormalForm.lean` | 615 | Normal form for TM formulas used in the completeness proof |
| `OrderedSum.lean` | 62 | Ordered sum construction for building new models |
| `PriorExpressiveness.lean` | 395 | Prior's theorem on temporal expressiveness |
| `ReflexiveCanonical.lean` | 760 | Main reflexive canonical model construction |
| `Separation.lean` | 38 | Re-export module for the Separation subdirectory |
| `StaviConnectives.lean` | 578 | Stavi connectives (Until, Since extensions) and their properties |
| `Table.lean` | 280 | Tabular representation for N-equivalence classes |
| `Transfer.lean` | 1110 | Transfer lemma: truth transferred via N-equivalence |
| `TruthLemma.lean` | 565 | Truth lemma for the weak canonical model |
| `WeakCanonical.lean` | 62 | Re-export module for the WeakCanonical package |
| `EFGames/` | — | Ehrenfeucht-Fraisse bisimulation game engine (9 files) |
| `ExpressiveCompleteness/` | — | Expressive completeness results (2 files) |
| `Expressiveness/` | — | Expressiveness separation results (5 files) |
| `IntegerModel/` | — | Integer model construction (3 files) |
| `Separation/` | — | Separation theorem and supporting lemmas (11+ files) |

## Key Results

- `weak_completeness`: Every Base-TM-valid formula is derivable
- `truth_lemma`: Formula membership in an MCS iff true in the canonical model
- `transfer_theorem`: N-equivalent structures satisfy the same TM formulas
- `normal_form_reduction`: Every TM formula reduces to a normal form

## Architecture

```
ReflexiveCanonical.lean
       |
       +-- TruthLemma.lean
       |        |
       +-- NEquivalence.lean
       |        |
       +-- EFGames/             (bisimulation games)
       +-- ExpressiveCompleteness/
       +-- Expressiveness/
       +-- Separation/          (separation theorem)
       +-- IntegerModel/        (integer witness model)
```

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core`, `Bimodal.Syntax`
- **Imported by**: `Bimodal.Metalogic.Completeness` (indirectly)

## Related Documentation

- [Metalogic README](../README.md)
- [EFGames README](EFGames/README.md)
- [Separation README](Separation/README.md)
- [BXCanonical README](../BXCanonical/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

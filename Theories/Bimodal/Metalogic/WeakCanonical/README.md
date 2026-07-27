# WeakCanonical — Weak Canonical Model Construction

Weak canonical model construction for Base TM completeness (Henkin-style approach).

This directory implements completeness for the Base TM logic variant via a reflexive
canonical model. The approach generalizes the classical Henkin construction to the
bimodal setting with temporal operators, using bisimulation equivalence games to
characterize expressive power and establishing completeness via normal-form reduction.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ChronicleExtraction.lean` | 215 | Extracting chronicles from the weak canonical model |
| `EFGameTactics.lean` | 331 | EF game automation tactics for expressive completeness proofs |
| `FrameProperties.lean` | 67 | Frame property verification for the weak canonical model |
| `MonadicFO.lean` | 822 | Monadic first-order logic translation for expressiveness results |
| `NEquivalence.lean` | 1315 | N-equivalence relation and its properties for bisimulation games |
| `NormalForm.lean` | 873 | Normal form for TM formulas used in the completeness proof |
| `OrderedSum.lean` | 52 | Ordered sum construction for building new models |
| `PriorDefs.lean` | 47 | Shared definitions for the Prior expressiveness development |
| `PriorExpressiveness.lean` | 372 | Prior's theorem on temporal expressiveness |
| `ReflexiveCanonical.lean` | 780 | Main reflexive canonical model construction |
| `StaviConnectives.lean` | 583 | Stavi connectives (Until, Since extensions) and their properties |
| `Table.lean` | 296 | Tabular representation for N-equivalence classes |
| `Transfer.lean` | 1244 | Transfer lemma; carries `countermodel_discrete`, the sole live `sorry` |
| `TruthLemma.lean` | 206 | Truth lemma for the weak canonical model |
| `EFGames/` | 11,872 | Ehrenfeucht-Fraisse bisimulation game engine (8 files) |
| `Expressiveness/` | 9,503 | Expressiveness separation results (5 files) |
| `IntegerModel/` | 5,503 | Integer model construction (6 files) |
| `Kamp/` | 71,246 | Kamp/Reynolds separation machinery (99 files) -- by far the largest subtree in the repository, and the reason `WeakCanonical` is the riskiest thing in the tree to relocate. Carries its own local `Boneyard/`. |
| `Separation/` | 926 | Separation theorem and supporting lemmas (3 files) |

The aggregator for this directory is the sibling `Metalogic/WeakCanonical.lean`,
not a self-named file inside it. Counts above are measured, and both this
directory's `Boneyard/` and the one under `Kamp/` are excluded from them; run
`scripts/check-module-invariants.sh` rather than an ad-hoc `find` to re-derive
live counts, since a filter naming only the top-level `Boneyard` silently counts
the Kamp-local archive as live.

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
- **Imported by**: `Bimodal.Metalogic.WeakCanonical` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [EFGames README](EFGames/README.md)
- [Separation README](Separation/README.md)
- [BXCanonical README](../BXCanonical/README.md)

---

*Last verified: 2026-05-29*

# BXCanonical — Burgess-Xu Canonical Model

Canonical model construction for Dense and Discrete TM completeness (Burgess 1982 chronicle approach).

This directory implements completeness for the Dense and Discrete TM logic variants using
a chronicle-based canonical model. A chronicle is a sequence of maximal consistent sets
satisfying coherence conditions that correspond to the temporal and modal structure of TM frames.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `BXCanonical.lean` | 28 | Re-export module for the BXCanonical package |
| `CanonicalChain.lean` | 110 | Chronicle chain construction and its linear order |
| `CanonicalModel.lean` | 794 | Canonical model assembly from chronicles; frame/model structure |
| `Completeness.lean` | 439 | Main completeness theorem wiring for Dense and Discrete variants |
| `Frame.lean` | 710 | Canonical frame properties: task relation, temporal accessibility |
| `OrderedSeedConsistency.lean` | 254 | Seed consistency for the ordered chronicle construction |
| `TruthLemma.lean` | 302 | Truth lemma: MCS membership iff formula true in canonical model |
| `Chronicle/` | — | Dense chronicle construction (7 files) |
| `Filtration/` | — | Filtration-based model construction (1 file) |
| `Quasimodel/` | — | Quasimodel intermediate construction (6 files) |

## Key Results

- `completeness_dense`: Every validly dense formula is derivable in TM Dense
- `completeness_discrete`: Every validly discrete formula is derivable in TM Discrete
- `truth_lemma`: MCS membership characterizes truth in the canonical model

## Architecture

```
Completeness.lean
       |
       +-- TruthLemma.lean
       |        |
       +-- CanonicalModel.lean
       |        |
       +-- Frame.lean
       |        |
       +-- CanonicalChain.lean
       |        |
       +-- Chronicle/          (chronicle construction)
       +-- Quasimodel/         (quasimodel intermediate)
       +-- Filtration/         (filtration for FMP)
```

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core`, `Bimodal.Syntax.SubformulaClosure`
- **Imported by**: `Bimodal.Metalogic.Completeness`

## Related Documentation

- [Metalogic README](../README.md)
- [Chronicle README](Chronicle/README.md)
- [Quasimodel README](Quasimodel/README.md)
- [Filtration README](Filtration/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

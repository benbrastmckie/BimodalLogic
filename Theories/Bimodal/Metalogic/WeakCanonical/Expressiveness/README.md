# Expressiveness

Expressiveness separation results for TM bimodal logic variants.

This directory proves separation results showing that certain formulas are expressible
in one variant of TM logic but not in others, establishing the strict hierarchy
between Base, Dense, and Discrete TM.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CaseAnalysis.lean` | 3749 | Case analysis for expressiveness separation arguments |
| `Claim1.lean` | 1629 | First main separation claim: Base TM does not express dense-only properties |
| `DConsistencyTransport.lean` | 742 | D-consistency transport lemma for separation arguments |
| `SplitPoint.lean` | 4693 | Split point construction for building separating models |
| `Theorem6.lean` | 422 | Theorem 6 (from the source paper): expressiveness separation result |

## Key Results

- `theorem6`: Expressiveness separation: Dense and Discrete TM are incomparable
- `split_point_construction`: Building separating models at partition boundaries
- `d_consistency_transport`: Consistency properties preserved under model transformations

## Dependencies

- **Imports from**: `Bimodal.Metalogic.WeakCanonical.EFGames`, `Bimodal.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `Bimodal.Metalogic.WeakCanonical` (top level)

## Related Documentation

- [WeakCanonical README](../README.md)
- [EFGames README](../EFGames/README.md)
- [ExpressiveCompleteness README](../ExpressiveCompleteness/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

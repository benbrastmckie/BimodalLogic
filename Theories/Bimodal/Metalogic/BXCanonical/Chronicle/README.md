# Chronicle — Dense Chronicle Construction

Dense chronicle construction for the BXCanonical completeness proof.

A chronicle is a dense sequence of maximally consistent sets indexed by rational-like
time points, constructed to witness completeness of Dense TM logic. This directory
implements the construction of such chronicles from a consistent seed MCS, following
the Burgess (1982) approach.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ChronicleConstruction.lean` | 1510 | Main chronicle construction algorithm: building the dense MCS sequence |
| `ChronicleToCountermodel.lean` | 3374 | Extracting a countermodel from an open chronicle (refutation extraction) |
| `ChronicleTypes.lean` | 865 | Type definitions for chronicles, chronicle elements, and indexed families |
| `CounterexampleElimination.lean` | 3487 | Counterexample elimination: showing chronicles avoid false formulas |
| `HenkinDiscreteChain.lean` | 121 | Discrete variant: Henkin witness chain for discrete completeness |
| `PointInsertion.lean` | 3527 | Point insertion lemma: inserting intermediate chronicle points for density |
| `RRelation.lean` | 1686 | Task relation construction for chronicles: R(τ,t,σ) derived from MCS membership |

## Key Results

- `chronicle_construction`: Main construction producing a dense MCS sequence from a seed
- `point_insertion`: Between any two chronicle points, an intermediate point can be inserted
- `counterexample_elimination`: Chronicles do not falsify consistent formulas
- `chronicle_to_countermodel`: Open chronicles yield countermodels

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core`, `Bimodal.Metalogic.BXCanonical.Quasimodel`
- **Imported by**: `Bimodal.Metalogic.BXCanonical.CanonicalModel`

## Related Documentation

- [BXCanonical README](../README.md)
- [Quasimodel README](../Quasimodel/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

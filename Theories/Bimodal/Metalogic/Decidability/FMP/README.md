# FMP — Finite Model Property

Finite model property (FMP) proofs for TM bimodal logic variants.

The FMP states that if a formula is satisfiable, it is satisfiable in a finite model.
This directory proves FMP for the Dense and Discrete variants via filtration and
closure-based model construction, and is used by the tableau decision procedure.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ClosureMCS.lean` | 279 | MCS theory restricted to subformula closure (foundation for filtration) |
| `DenseFMP.lean` | 112 | Finite model property for the Dense TM variant |
| `DiscreteFMP.lean` | 117 | Finite model property for the Discrete TM variant |
| `Filtration.lean` | 323 | Filtration construction: quotienting a model by subformula closure equivalence |
| `FiniteModel.lean` | 177 | Finite model extraction and cardinality bounds |
| `FMP.lean` | 248 | Main FMP re-export and unified interface |
| `TruthPreservation.lean` | 400 | Truth preservation across the filtration quotient |

## Key Results

- `filtration_is_finite`: The filtrated model has bounded cardinality
- `fmp_dense`: Dense TM satisfiability implies finite-model satisfiability
- `fmp_discrete`: Discrete TM satisfiability implies finite-model satisfiability
- `truth_preserved_under_filtration`: Filtration preserves truth of closure formulas

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core.RestrictedMCS`, `Bimodal.Syntax.SubformulaClosure`
- **Imported by**: `Bimodal.Metalogic.Decidability`

## Related Documentation

- [Decidability README](../README.md)
- [Core RestrictedMCS README](../../Core/RestrictedMCS/README.md)
- [SubformulaClosure README](../../../Syntax/SubformulaClosure/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

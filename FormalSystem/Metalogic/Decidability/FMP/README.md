# FMP — Finite Model Property

Finite model property (FMP) proofs for TM bimodal logic variants.

The FMP states that if a formula is satisfiable, it is satisfiable in a finite model.
This directory proves FMP via filtration and closure-based model construction,
and is used by the tableau decision procedure.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ClosureMCS.lean` | 279 | MCS theory restricted to subformula closure (foundation for filtration) |
| `Filtration.lean` | 323 | Filtration construction: quotienting a model by subformula closure equivalence |
| `FiniteModel.lean` | 177 | Finite model extraction and cardinality bounds |
| `FMP.lean` | 248 | Main FMP re-export and unified interface |
| `TruthPreservation.lean` | 400 | Truth preservation across the filtration quotient |

## Key Results

- `filtration_is_finite`: The filtrated model has bounded cardinality
- `truth_preserved_under_filtration`: Filtration preserves truth of closure formulas

Archived: the former `DenseFMP.lean`/`DiscreteFMP.lean` variant modules
(`fmp_dense`, `fmp_discrete`) had no live importers and were moved to
`FormalSystem/Boneyard/FMPVariants/`.

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core.RestrictedMCS`, `Bimodal.Syntax.SubformulaClosure`
- **Imported by**: `Bimodal.Metalogic.Decidability`

## Related Documentation

- [Decidability README](../README.md)
- [Core RestrictedMCS README](../../Core/RestrictedMCS/README.md)
- [SubformulaClosure README](../../../Syntax/SubformulaClosure/README.md)

---

*Last verified: 2026-05-29*

# SubformulaClosure

Subformula closure as a finite set, used in canonical model constructions.

This directory computes and characterizes the subformula closure of a formula -- the
finite set of all subformulas -- as a `Finset`. This closure is used throughout the
metalogic as the domain for restricted maximal consistent sets, filtration, and the
finite model property.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Closure.lean` | 367 | `subformulaClosure`: Finset of all subformulas of a formula |
| `NestingDepth.lean` | 232 | Nesting depth measure for formulas; used in bounded search |
| `TemporalFormulas.lean` | 1296 | Temporal formula classification within subformula closures |

## Key Definitions

- `subformulaClosure φ`: The `Finset Formula` containing all subformulas of `φ`
- `nestingDepth φ`: Measure of modal/temporal nesting depth
- `temporalFormulas`: Subset of closure containing only temporal subformulas

## Dependencies

- **Imports from**: `Bimodal.Syntax.Formula`, `Bimodal.Syntax.Subformulas`
- **Imported by**: `Bimodal.Metalogic.Core.RestrictedMCS`, `Bimodal.Metalogic.Decidability.FMP`

## Related Documentation

- [Syntax README](../README.md)
- [Core RestrictedMCS README](../../Metalogic/Core/RestrictedMCS/README.md)
- [FMP README](../../Metalogic/Decidability/FMP/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

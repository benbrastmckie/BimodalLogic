# Filtration — BXCanonical Filtration

Filtration construction for the BXCanonical finite model property.

This directory contains the filtration technique applied in the BXCanonical context,
where a potentially infinite canonical model is quotiented by subformula closure
equivalence to produce a finite model that preserves truth of relevant formulas.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `DefectChain.lean` | 112 | Defect chain construction: handling formulas not realized in the filtrated model |

## Key Results

- `defect_chain`: Construction of witness sequences for unrealized temporal formulas
- Foundation for decidability proofs that rely on finite model property

## Dependencies

- **Imports from**: `Bimodal.Metalogic.BXCanonical.Chronicle`, `Bimodal.Syntax.SubformulaClosure`
- **Imported by**: `Bimodal.Metalogic.BXCanonical.Completeness`

## Related Documentation

- [BXCanonical README](../README.md)
- [FMP README](../../Decidability/FMP/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

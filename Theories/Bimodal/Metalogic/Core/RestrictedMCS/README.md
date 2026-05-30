# RestrictedMCS

Maximal consistent sets (MCS) restricted to a subformula closure.

This subdirectory defines restricted MCS theory used in the finite model property (FMP)
proofs and the tableau-based decision procedure. A restricted MCS is a maximal consistent
set constrained to contain only formulas from a fixed finite subformula closure.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Basic.lean` | 653 | Restricted MCS definitions, restricted Lindenbaum's lemma, basic properties |
| `Deferral.lean` | 764 | Deferral lemmas: extending restricted MCS and managing formula membership under closure |

## Key Definitions

- `RestrictedMCS`: Maximal consistent set bounded by a subformula closure `Cl`
- `restricted_lindenbaum`: Extension of consistent sets to restricted MCS via finite enumeration
- Membership and closure lemmas adapted to the finite-subformula setting

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core.MaximalConsistent`, `Bimodal.Syntax.SubformulaClosure`
- **Imported by**: `Bimodal.Metalogic.Decidability.FMP`, `Bimodal.Metalogic.BXCanonical`

## Related Documentation

- [Core Metalogic README](../README.md)
- [SubformulaClosure README](../../../Syntax/SubformulaClosure/README.md)
- [Decidability FMP README](../../Decidability/FMP/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

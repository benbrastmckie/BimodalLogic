# RestrictedMCS

Maximal consistent sets (MCS) restricted to a subformula closure.

This subdirectory defines restricted MCS theory used in the finite model property (FMP)
proofs and the tableau-based decision procedure. A restricted MCS is a maximal consistent
set constrained to contain only formulas from a fixed finite subformula closure.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Core/RestrictedMCS rows=loose cols=lines -->
| File | Lines | Description |
|------|-------|-------------|
| `Basic.lean` | 368 | Restricted MCS definitions, restricted Lindenbaum's lemma, basic properties |
<!-- END GENERATED -->

## Key Definitions

- `RestrictedMCS`: Maximal consistent set bounded by a subformula closure `Cl`
- `restricted_lindenbaum`: Extension of consistent sets to restricted MCS via finite enumeration
- Membership and closure lemmas adapted to the finite-subformula setting

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Core.MaximalConsistent`, `FormalSystem.Syntax.SubformulaClosure`
- **Imported by**: `FormalSystem.Metalogic.Decidability.FMP`, `FormalSystem.Metalogic.BXCanonical`

## Related Documentation

- [Core Metalogic README](../README.md)
- [SubformulaClosure README](../../../Syntax/SubformulaClosure/README.md)
- [Decidability FMP README](../../Decidability/FMP/README.md)

---

*Last verified: 2026-09-21*

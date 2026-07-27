# ExpressiveCompleteness

Expressive completeness results for TM bimodal logic.

This directory proves that TM logic (with Until and Since operators) is expressively
complete for the bisimulation-invariant fragment of first-order logic over linear orders.
This is the bimodal analogue of Kamp's theorem for temporal logic.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `QuantifierElimination.lean` | 1787 | Quantifier elimination for the monadic fragment over linear orders |
| `Theorem.lean` | 365 | Main expressive completeness theorem assembly |

## Key Results

- `expressive_completeness`: TM logic is expressively complete for bisimulation-invariant FO
- `quantifier_elimination`: The relevant FO fragment admits effective quantifier elimination

## Dependencies

- **Imports from**: `Bimodal.Metalogic.WeakCanonical.EFGames`, `Bimodal.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `Bimodal.Metalogic.WeakCanonical` (top level)

## Related Documentation

- [WeakCanonical README](../README.md)
- [EFGames README](../EFGames/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

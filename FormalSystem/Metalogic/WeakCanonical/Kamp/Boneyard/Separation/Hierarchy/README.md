# Hierarchy — Expressive Hierarchy Completion

Completion of the expressiveness hierarchy for TM bimodal logic variants.

This directory proves the final steps of the expressiveness hierarchy, establishing
that the Base, Dense, and Discrete variants form a strict hierarchy under expressiveness,
and completing the proof that no variant can simulate the others.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `HierarchyCompletion.lean` | 1621 | Main hierarchy completion: assembling all separation results |
| `HierarchyDefs.lean` | 808 | Hierarchy definitions: expressiveness ordering, variant comparison |
| `HierarchyInduction.lean` | 1436 | Inductive argument for hierarchy strictness |

## Key Results

- `hierarchy_strict`: The expressiveness ordering Base < Dense and Base < Discrete is strict
- `hierarchy_incomparable`: Dense and Discrete TM are expressiveness-incomparable
- `hierarchy_defs`: Formal definition of the expressiveness comparison relation

## Dependencies

- **Imports from**: `Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ`, `Bimodal.Metalogic.WeakCanonical.Expressiveness`
- **Imported by**: `Bimodal.Metalogic.WeakCanonical` (top level)

## Related Documentation

- [Separation README](../README.md)
- [DedekindZ README](../DedekindZ/README.md)
- [Expressiveness README](../../Expressiveness/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

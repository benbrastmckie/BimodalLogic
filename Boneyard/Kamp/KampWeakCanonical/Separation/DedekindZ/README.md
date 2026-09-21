# DedekindZ — Dedekind-Complete Integer Order

Dedekind-completeness properties for the integer order in the separation context.

This directory establishes that the integer linear order satisfies the necessary
Dedekind-like completeness properties used in the temporal separation arguments,
providing the arithmetic foundation for the separation theorem.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Cases.lean` | 1768 | Case analysis for Dedekind-Z properties in the separation proof |
| `QLemma.lean` | 459 | Q-lemma: key quantitative lemma for integer order separation |

## Key Results

- `QLemma`: Quantitative lemma about integer time-point separation
- Case analysis establishing completeness of the integer order for TM separation

## Dependencies

- **Imports from**: `Bimodal.Metalogic.WeakCanonical.Separation` (parent definitions)
- **Imported by**: `Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

## Related Documentation

- [Separation README](../README.md)
- [Hierarchy README](../Hierarchy/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

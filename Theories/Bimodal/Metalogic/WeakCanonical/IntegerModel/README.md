# IntegerModel — Integer Witness Model

Integer model construction for TM bimodal logic completeness arguments.

This directory constructs the integer number line (Z, <) as a concrete witness model
for Base TM logic. The integer model demonstrates that certain formulas are satisfiable
and provides the basis for "shift-and-glue" constructions used in completeness proofs.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `GoodStructures.lean` | 909 | Good structure definitions: models satisfying the necessary frame conditions |
| `ReynoldsNoGaps.lean` | 114 | Reynolds no-gaps theorem: Z satisfies the Base TM frame conditions |
| `ShiftAndGlue.lean` | 956 | Shift-and-glue construction: combining integer models with shifted copies |

## Key Results

- `reynolds_no_gaps`: The integer order satisfies Base TM frame conditions
- `shift_and_glue`: Integer models can be combined by shifting temporal indices
- `good_structure_def`: Characterizes well-behaved TM models for completeness

## Dependencies

- **Imports from**: `Bimodal.Semantics`, `Bimodal.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `Bimodal.Metalogic.WeakCanonical.Separation`

## Related Documentation

- [WeakCanonical README](../README.md)
- [Separation README](../Separation/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

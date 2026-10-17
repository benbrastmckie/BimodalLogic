# IntegerModel — Integer Witness Model

Integer model construction for TM bimodal logic completeness arguments.

This directory constructs the integer number line (Z, <) as a concrete witness model
for Base TM logic. The integer model demonstrates that certain formulas are satisfiable
and provides the basis for "shift-and-glue" constructions used in completeness proofs.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical/IntegerModel -->
| File | Lines | Description |
|------|-------|-------------|
| `GoodStructures.lean` | 883 | Good structure definitions: models satisfying the necessary frame conditions |
| `GoodStructuresModelSurgery.lean` | 2,190 | Model surgery for `no_gaps_discrete` (Reynolds 1994, Theorem 14 at the `OrderedMonadicStructure` level): in a discrete linear order satisfying semantic Prior-UZ/SZ, contemporaneous-class boundaries cannot sit at Dedekind gaps |
| `NoGapsDiscreteProof.lean` | 124 | Sorry-free `no_gaps_discrete` and `one_class`, delegating to `no_gaps_discrete_model_surgery`; sits downstream of both `GoodStructures.lean` and `GoodStructuresModelSurgery.lean` to break their import cycle |
| `ReynoldsBridge.lean` | 1,296 | Strategy B discrete countermodel: builds `LimitDomSubtype` directly as an `OrderedMonadicStructure` with semantic Prior-UZ/SZ, bypassing `succ_embed_surjective` and the `IsSuccArchimedean` requirement |
| `ReynoldsNoGaps.lean` | 208 | Reynolds no-gaps theorem: Z satisfies the Base TM frame conditions |
| `ShiftAndGlue.lean` | 924 | Shift-and-glue construction: combining integer models with shifted copies |
<!-- END GENERATED -->

## Key Results

- `reynolds_no_gaps`: The integer order satisfies Base TM frame conditions
- `shift_and_glue`: Integer models can be combined by shifting temporal indices
- `good_structure_def`: Characterizes well-behaved TM models for completeness

## Dependencies

- **Imports from**: `FormalSystem.Semantics`, `FormalSystem.Metalogic.WeakCanonical.NEquivalence`
- **Imported by**: `FormalSystem.Metalogic.Expressiveness.Separation`

## Related Documentation

- [WeakCanonical README](../README.md)
- [Separation README](../../Expressiveness/Separation/README.md)

---

*Last verified: 2026-09-21*

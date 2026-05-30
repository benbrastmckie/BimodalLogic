# SoundnessLemmas

Supporting lemmas for the TM soundness theorem.

This directory contains the auxiliary results needed for the main soundness proof,
organized by frame class: core lemmas valid on all linear orders, and specialized
lemmas for the Dense and Discrete frame classes.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Core.lean` | 106 | Core soundness lemmas valid on all linear temporal orders |
| `DenseValidity.lean` | 1338 | Soundness lemmas for densely-ordered frames (Dense TM variant) |
| `FrameClassVariants.lean` | 971 | Soundness lemmas for frame-class-specific axioms; axiom-to-class mapping |

## Key Results

- Validity of each individual axiom schema on its required frame class
- Monotonicity lemmas for temporal operators
- Structural preservation lemmas (used in the main soundness induction)

## Dependencies

- **Imports from**: `Bimodal.Semantics`, `Bimodal.ProofSystem`, `Bimodal.FrameConditions`
- **Imported by**: `Bimodal.Metalogic.Soundness`

## Related Documentation

- [Metalogic README](../README.md)
- [FrameConditions README](../../FrameConditions/README.md)
- [Soundness.lean](../Soundness.lean)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

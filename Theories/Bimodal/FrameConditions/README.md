# FrameConditions

Frame condition definitions and soundness proofs for TM bimodal logic variants.

This directory contains the semantic frame conditions that distinguish the Base, Dense,
and Discrete variants of TM logic, along with soundness certificates and compatibility
lemmas for each frame class.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Compatibility.lean` | 176 | Compatibility lemmas between frame conditions and axiom schemas |
| `FrameClass.lean` | 220 | Frame class definitions: `FrameClass.Base`, `Dense`, `Discrete` type aliases |
| `Soundness.lean` | 190 | Soundness proofs: each axiom is valid on its corresponding frame class |
| `Validity.lean` | 204 | Semantic validity definitions relative to frame classes |

## Key Definitions

- `FrameClass`: Enumeration of Base, Dense, and Discrete frame classes
- `frameClass_of_axiom`: Maps each axiom to its required frame class
- `axiom_valid`: Main soundness certificate for all base axioms
- `axiom_dense_valid`: Soundness certificate for dense-only axioms
- `axiom_discrete_valid`: Soundness certificate for discrete-only axioms

## Dependencies

- **Imports from**: `Bimodal.Syntax`, `Bimodal.Semantics`, `Bimodal.ProofSystem`
- **Imported by**: `Bimodal.Metalogic.SoundnessLemmas`, `Bimodal.Metalogic.Soundness`

## Related Documentation

- [Parent README](../README.md)
- [Semantics README](../Semantics/README.md)
- [ProofSystem README](../ProofSystem/README.md)
- [Metalogic README](../Metalogic/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

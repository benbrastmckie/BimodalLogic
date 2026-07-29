# SoundnessLemmas

Supporting lemmas for the TM soundness theorem.

This directory contains the auxiliary results needed for the main soundness proof,
organized by frame class: core lemmas valid on all linear orders, and specialized
lemmas for the Dense and Discrete frame classes.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CoValidity.lean` | 143 | `co_valid`: semantic validity of the paper's CO principle `△(Hφ → F Hφ) → (Hφ → Gφ)` on dense Dedekind-complete flows. Not a soundness case — CO is a derived theorem here, not an `Axiom` constructor |
| `Core.lean` | 106 | Core soundness lemmas valid on all linear temporal orders |
| `DenseValidity.lean` | 1338 | Soundness lemmas for densely-ordered frames (Dense TM variant) |
| `FrameClassVariants.lean` | 971 | Soundness lemmas for frame-class-specific axioms; axiom-to-class mapping |
| `Separability.lean` | 346 | Separability of dense Dedekind-complete duration groups and the order-theoretic core of the Sep axiom (Reynolds 1992, §7 lemma 10) |

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

*Last verified: 2026-07-27*

# SoundnessLemmas

Supporting lemmas for the TM soundness theorem.

This directory contains the auxiliary results needed for the main soundness proof:
the per-axiom validity and swap-validity lemmas, and the order-theoretic input to the
Dedekind-class separability axiom.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CoValidity.lean` | 140 | `co_valid`: semantic validity of the paper's CO principle `△(Hφ → F Hφ) → (Hφ → Gφ)` on dense Dedekind-complete flows. Not a soundness case — CO is a derived theorem here, not an `Axiom` constructor |
| `FrameClassVariants.lean` | 963 | The per-axiom swap-validity and validity lemmas at `FrameClass.Base`, the 45-arm dispatcher `axiom_swap_valid_general` that delegates to them one line per arm, and the four discrete Prior/z1 lemmas at `ValidDiscrete`; consumed by `Metalogic/Soundness.lean`'s `axiom_swap_validIn_min` |
| `Separability.lean` | 354 | Separability of dense Dedekind-complete duration groups and the order-theoretic core of the Sep axiom (Reynolds 1992, §7 lemma 10) |

## Key Results

- Validity of each individual axiom schema on its required frame class
- Swap-validity of each axiom schema, the input to the `temporal_duality` soundness case
- Monotonicity lemmas for temporal operators

## Dependencies

- **Imports from**: `FormalSystem.Semantics.Validity`, `FormalSystem.ProofSystem.Derivation`,
  and Mathlib's order/Archimedean modules
- **Imported by**: `FormalSystem.Metalogic.Soundness`,
  `FormalSystem.Metalogic.Decidability.Verified.Decidable`

## Related Documentation

- [Metalogic README](../README.md)
- [Soundness.lean](../Soundness.lean)

---

*Last verified: 2026-09-02*

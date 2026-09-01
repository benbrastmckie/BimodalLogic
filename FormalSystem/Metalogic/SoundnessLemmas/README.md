# SoundnessLemmas

Supporting lemmas for the TM soundness theorem.

This directory contains the auxiliary results needed for the main soundness proof,
organized by frame class: core lemmas valid on all linear orders, and specialized
lemmas for the Dense and Discrete frame classes.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `CoValidity.lean` | 141 | `co_valid`: semantic validity of the paper's CO principle `△(Hφ → F Hφ) → (Hφ → Gφ)` on dense Dedekind-complete flows. Not a soundness case — CO is a derived theorem here, not an `Axiom` constructor |
| `Core.lean` | 107 | Core soundness lemmas valid on all linear temporal orders |
| `DenseValidity.lean` | 1296 | Soundness lemmas for densely-ordered frames (Dense TM variant), including `axiom_swap_valid` and the rule-preservation lemmas |
| `FrameClassVariants.lean` | 591 | Base-axiom swap-validity (`axiom_swap_valid_general`) and the four discrete Prior/z1 validity lemmas, consumed by `Metalogic/Soundness.lean`'s `axiom_swap_validIn_min` |
| `Separability.lean` | 352 | Separability of dense Dedekind-complete duration groups and the order-theoretic core of the Sep axiom (Reynolds 1992, §7 lemma 10) |

## Key Results

- Validity of each individual axiom schema on its required frame class
- Monotonicity lemmas for temporal operators
- Structural preservation lemmas (used in the main soundness induction)

## Dependencies

- **Imports from**: `FormalSystem.Semantics.Truth`, `FormalSystem.Semantics.Validity`,
  `FormalSystem.ProofSystem.Derivation`, `FormalSystem.ProofSystem.Axioms`, and Mathlib's
  order/Archimedean modules
- **Imported by**: `FormalSystem.Metalogic.Soundness`

## Related Documentation

- [Metalogic README](../README.md)
- [Soundness.lean](../Soundness.lean)

---

*Last verified: 2026-09-01*

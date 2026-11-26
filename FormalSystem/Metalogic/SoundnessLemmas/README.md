# SoundnessLemmas

Supporting lemmas for the TM soundness theorem.

This directory contains the auxiliary results needed for the main soundness proof:
the per-axiom validity and reflection-validity lemmas, and the order-theoretic input to the
Dedekind-class separability axiom.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/SoundnessLemmas -->
| File | Lines | Description |
|------|-------|-------------|
| `CoValidity.lean` | 112 | `co_valid`: semantic validity of the paper's CO principle `△(Hφ → F Hφ) → (Hφ → Gφ)` on dense Dedekind-complete flows. Not a soundness case — CO is a derived theorem here, not an `Axiom` constructor |
| `DiscreteOrder.lean` | 175 | The order cores of the four discrete-frame validity proofs — `exists_nearest_gt`, `exists_nearest_lt` and their duals — stated over an abstract predicate `P : D → Prop`, mentioning neither `Formula` nor `TruthAt` |
| `EventOperators.lean` | 91 | `after_negation_valid`: semantic validity of `lem:after-negation`, `After(φ,⊤) → (¬After(φ,ψ) ↔ After(φ,¬ψ))`, over every task frame. Not a soundness case — `Formula.after` is a derived operator, not an `Axiom` constructor; the mathematics is the generic `After` tier of `Semantics/TruthClauses.lean` |
| `FrameClassVariants.lean` | 802 | The per-axiom reflection-validity and validity lemmas at `FrameClass.Base`, the 29-arm dispatcher `axiom_reflect_time_valid_general` that delegates to them one line per arm, and the four discrete Prior/z1 lemmas at `ValidZTime`; consumed by `Metalogic/Soundness.lean`'s `axiom_reflect_time_validIn_min` |
| `GenericSchemata.lean` | 1,455 | The TM⁺ mirror schemata stated **once**, pointwise, over `Semantics/TruthClauses.lean`'s `TruthEnv`/operator-clause interface — the propositional, S5-modal and `⊡` tiers, seriality, monotonicity, connection, enrichment/accumulation/absorption, both nestings of `U`/`S` linearity and both disjunct orderings of temporal linearity, the `F`/`P` equivalences, the discrete-uniformity group with its gap-translation core, density, Prior-Z, Z1, the Reynolds Dedekind tier, and `modal_future` under an explicit homogeneity hypothesis. L⁺, L⋆ and L^▷ each delegate their own validity theorems to these instead of transcribing the schemata a third time; no lemma here carries an attribute |
| `Separability.lean` | 335 | Separability of dense Dedekind-complete duration groups and the order-theoretic core of the Sep axiom (Reynolds 1992, §7 lemma 10) |
<!-- END GENERATED -->

## Key Results

- Validity of each individual axiom schema on its required frame class
- Reflection-validity of each axiom schema, the input to the `time_reflection` soundness case
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

*Last verified: 2026-11-06*

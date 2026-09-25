# Theorems

Derived theorems and proof infrastructure for TM bimodal logic.

This directory contains theorems that are provable within TM logic itself (as
derivations), organized by topic. These are distinguished from metalogical results
(in `Metalogic/`) which are proved about TM logic.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Theorems -->
| File | Lines | Description |
|------|-------|-------------|
| `Combinators.lean` | 969 | Propositional combinator lemmas: I, K, S, B, C, composition |
| `ContextualProofs.lean` | 490 | Derivations carried out under a nonempty context |
| `DedekindDerived.lean` | 416 | Dedekind-class derived theorems: `△`-eliminators, the `F(Hψ) → ψ` / `F(Hψ) → U(⊤,ψ)` / `S(Hψ∧ψ,ψ) → Hψ` point-shifting lemmas, and `coDerived` (the paper's CO principle derived from the Reynolds gap basis) |
| `DeductionTheorem.lean` | 487 | The deduction theorem (`A :: Γ ⊢ B` gives `Γ ⊢ A → B`) and its converse. Keeps `namespace FormalSystem.Metalogic.Core`, a recorded exception its module docstring explains |
| `DiscreteUnfolding.lean` | 498 | The ℤ-exact one-step unfolding of `untl` at `FrameClass.ZTime` |
| `GeneralizedNecessitation.lean` | 242 | Generalized necessitation rules for modal and temporal operators |
| `ModalDerived.lean` | 219 | Closed object-logic derivation helpers (`dneTheorem`, `boxDneTheorem`, the `G`/`H` analogues) collected out of `Metalogic/Bundle/` so canonical-model modules can reach them without the bundle machinery |
| `ModalS4.lean` | 422 | S4 modal theorems: consequences of T, 4, K axioms |
| `ModalS5.lean` | 788 | S5 modal theorems: consequences of T, 4, B, 5 axioms |
| `Perpetuity.lean` | 94 | Re-export for the Perpetuity subdirectory |
| `TemporalDerived.lean` | 832 | Derived temporal theorems: temp_k_dist, temp_4 (derived from BX axioms) |
| `Perpetuity/` | — | Perpetuity principles P1-P6: `Helpers.lean`, `MonotonicityDuality.lean`, `Principles.lean` (3 files) |
| `Propositional/` | — | Propositional tautologies and rules: Connectives, Core, Reasoning (3 files) |
<!-- END GENERATED -->

## Key Categories

- **Combinators**: Identity, composition, permutation, substitution lemmas
- **Propositional**: Classical tautologies (double negation, contraposition, de Morgan)
- **Modal S4/S5**: Axiom consequences for S4 and S5 fragments
- **Perpetuity**: P1-P6 perpetuity principles (G-H equivalences, eternal truths)
- **Temporal Derived**: Linearity-derived theorems (temp_k_dist, temp_4 are now derived)

## Related Documentation

- [Parent README](../README.md)
- [Perpetuity README](Perpetuity/README.md)
- [Propositional README](Propositional/README.md)

---

*Last verified: 2026-09-21*

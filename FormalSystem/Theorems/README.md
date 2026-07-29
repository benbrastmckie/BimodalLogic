# Theorems

Derived theorems and proof infrastructure for TM bimodal logic.

This directory contains theorems that are provable within TM logic itself (as
derivations), organized by topic. These are distinguished from metalogical results
(in `Metalogic/`) which are proved about TM logic.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Combinators.lean` | 675 | Propositional combinator lemmas: I, K, S, B, C, composition |
| `DedekindDerived.lean` | 400 | Dedekind-class derived theorems: `△`-eliminators, the `F(Hψ) → ψ` / `F(Hψ) → U(⊤,ψ)` / `S(Hψ∧ψ,ψ) → Hψ` point-shifting lemmas, and `co_derived` (the paper's CO principle derived from the Reynolds gap basis) |
| `GeneralizedNecessitation.lean` | 240 | Generalized necessitation rules for modal and temporal operators |
| `ModalS4.lean` | 468 | S4 modal theorems: consequences of T, 4, K axioms |
| `ModalS5.lean` | 859 | S5 modal theorems: consequences of T, 4, B, 5 axioms |
| `Perpetuity.lean` | 88 | Re-export for the Perpetuity subdirectory |
| `TemporalDerived.lean` | 366 | Derived temporal theorems: temp_k_dist, temp_4 (derived from BX axioms) |
| `Perpetuity/` | — | Perpetuity principles P1-P6 (subdirectory) |
| `Propositional/` | — | Propositional tautologies and rules: Connectives, Core, Reasoning (3 files) |

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

*Last verified: 2026-05-29*

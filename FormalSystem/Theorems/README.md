# Theorems

Derived theorems and proof infrastructure for TM bimodal logic.

This directory contains theorems that are provable within TM logic itself (as
derivations), organized by topic. These are distinguished from metalogical results
(in `Metalogic/`) which are proved about TM logic.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Theorems -->
| File | Lines | Description |
|------|-------|-------------|
| `Combinators.lean` | 926 | Propositional combinator lemmas: I, K, S, B, C, composition |
| `ConnectDerived.lean` | 194 | TC (`connectFuture`), `F H ψ → ψ`, NP (`discreteSymmFwd`) and NA (`discretePropagateBwd`) derived computably from US, UG, UC, NB, MF, MT, TN and TR, with the TR mirrors `connectPast`/`discreteSymmBwd` and the computable propositional stock (`compLeft`, `compRight`, `curryThm`, `lceImpThm`, `rceImpThm`, `untlBotFalseThm`, `gMonoThm`) |
| `ContextualProofs.lean` | 491 | Derivations carried out under a nonempty context |
| `DedekindDerived.lean` | 411 | Dedekind-class derived theorems: `△`-eliminators, the `F(Hψ) → ψ` / `F(Hψ) → U(⊤,ψ)` / `S(Hψ∧ψ,ψ) → Hψ` point-shifting lemmas, and `coDerived` (the paper's CO principle derived from the Reynolds gap basis) |
| `DeductionTheorem.lean` | 487 | The deduction theorem (`A :: Γ ⊢ B` gives `Γ ⊢ A → B`) and its converse. Keeps `namespace FormalSystem.Metalogic.Core`, a recorded exception its module docstring explains |
| `DiscreteUnfolding.lean` | 499 | The ℤ-exact one-step unfolding of `untl` at `FrameClass.ZTime` |
| `GeneralizedNecessitation.lean` | 242 | Generalized necessitation rules for modal and temporal operators |
| `LinearityDerived.lean` | 200 | TL (`tempLinearity`) derived from CN with UF and UE, DN (`density`) derived from NN with the Base schemata, the legacy order `tempLinearityLegacy`, the past mirror `tempLinearityPast`, and the computable disjunction stock (`orInlThm`, `orInrThm`, `claviusThm`, `orElimThm`) |
| `ModalDerived.lean` | 220 | Closed object-logic derivation helpers (`dneTheorem`, `boxDneTheorem`, the `G`/`H` analogues) collected out of `Metalogic/Bundle/` so canonical-model modules can reach them without the bundle machinery |
| `ModalS4.lean` | 422 | S4 modal theorems: consequences of T, 4, K axioms |
| `ModalS5.lean` | 788 | S5 modal theorems: consequences of T, 4, B, 5 axioms |
| `Perpetuity.lean` | 94 | Re-export for the Perpetuity subdirectory |
| `TemporalDerived.lean` | 835 | Derived temporal theorems: temp_k_dist, temp_4 (derived from BX axioms) |
| `Perpetuity/` | — | Perpetuity principles P1-P6: `Helpers.lean`, `MonotonicityDuality.lean`, `Principles.lean` (3 files) |
| `Propositional/` | — | Propositional tautologies and rules: Connectives, Core, Reasoning (3 files) |
<!-- END GENERATED -->

## Key Categories

- **Combinators**: Identity, composition, permutation, substitution lemmas
- **Propositional**: Classical tautologies (double negation, contraposition, de Morgan)
- **Modal S4/S5**: Axiom consequences for S4 and S5 fragments
- **Perpetuity**: P1-P6 perpetuity principles (G-H equivalences, eternal truths)
- **Temporal Derived**: Linearity-derived theorems (temp_k_dist, temp_4 are now derived)

## Where a derived schema lives

`ProofSystem/` imports only `Syntax`, so a derived schema is placed at the lowest module whose
imports already supply its proof, and the chain is

`Combinators → DeductionTheorem → Propositional.Core → Connectives → GeneralizedNecessitation →
ConnectDerived → TemporalDerived → LinearityDerived → DedekindDerived`.

- `ProofSystem/DerivedAxioms.lean` (below `Combinators`): the TR mirrors and the schemata that
  need only raw constructors — UE (`untilF`), UT (`fUntilEquiv`), NF (`discretePropagateFwd`).
- `ConnectDerived.lean`: TC (`connectFuture`), NP (`discreteSymmFwd`), NA
  (`discretePropagateBwd`) with their mirrors; sits below `TemporalDerived`, which consumes TC.
- `LinearityDerived.lean`: TL (`tempLinearity`, from CN) and DN (`density`, from NN) with the
  legacy order and past mirror; sits above `TemporalDerived` for `someFutureMono`.
- `Metalogic/CompletenessDerived.lean`: Z1 (`z1Thm`), recovered through the ZTime completeness
  engine and therefore above `Metalogic/BXCanonical`.

Every derivation in `ConnectDerived` and `LinearityDerived` is computable, because the runtime
proof search and the dataset tooling build and traverse the trees.

## Related Documentation

- [Parent README](../README.md)
- [Perpetuity README](Perpetuity/README.md)
- [Propositional README](Propositional/README.md)

---

*Last verified: 2026-09-21*

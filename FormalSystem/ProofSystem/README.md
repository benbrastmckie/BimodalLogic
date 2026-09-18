# ProofSystem

Hilbert-style proof system for TM bimodal logic (Burgess-Xu axiomatization).

This directory defines the complete axiom system and derivation rules for all four
TM logic variants (Base, Dense, Discrete, Dedekind), along with derived facts and utilities.

## Modules

| File | Lines | Description |
|------|------:|-------------|
| `Axioms.lean` | 621 | `Axiom` inductive type: 29 constructors (the paper's primitive schemata) in nine layers |
| `DerivedAxioms.lean` | 244 | The time-reflection mirrors, derived by the TR rule (`DerivedAxioms` namespace) |
| `Derivation.lean` | 418 | `DerivationTree` inductive type: 7 inference rules as constructors |
| `Derivable.lean` | 196 | `Derivable`: Prop-valued derivability wrapper for classical reasoning |
| `LinearityDerivedFacts.lean` | 74 | Derived consequences of `temp_linearity`; non-derivability analysis |

## Axiom System

### Primitive Axioms and Derived Schemata

The `Axiom` inductive type has **29 constructors** organized into **nine layers**: exactly the
paper's primitive axiom schemata (`def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`), with
TL, CN and TS stated verbatim.

| Layer | Constructors | Description |
|-------|------------:|-------------|
| 1. Propositional | 4 | Classical: K, S, EFQ, Peirce |
| 2. S5 Modal | 3 | MT, M5 (5-collapse), MK (K-distribution) |
| 3. BX Temporal | 9 | Burgess-Xu Until/Since axioms, future direction |
| 3b. Additional BX Temporal | 2 | `temp_linearity` (TL), `F_until_equiv` (UT) |
| 4. Interaction | 1 | MF: `□φ → □Gφ` (TF is derived) |
| 5. Uniformity | 4 | NP, NF, NA, NB (valid on all ordered abelian groups) |
| 6. Prior | 1 | Prior-UZ (discrete well-ordering) |
| 7. Z1 | 1 | IsSuccArchimedean characteristic axiom |
| 8. Density | 2 | `density` (`GGφ → Gφ`) and `dense_indicator` (`¬U(⊤,⊥)`) (dense-only) |
| 9. Reynolds Dedekind | 2 | `prior_U_gap`, `sep` (Dedekind-only) |
| **Total** | **29** | |

**Frame classification**: 23 Base constructors, 2 Dense-only (`density`, `dense_indicator`),
2 Discrete-only (`prior_UZ`, `z1`), 2 Dedekind-only (`prior_U_gap`, `sep`) — see
`Axiom.minFrameClass` in `Axioms.lean`. Cumulatively (`Dense ≤ Dedekind`): Base 23,
Dense 25, Discrete 25, Dedekind 27.

**Derived schemata**: every past mirror (`serialPast`, `leftMonoSinceH`, …, `sinceP`,
`pSinceEquiv`, `discreteSymmBwd`, `priorSZ`, `priorSGap`) is proved by one application of
`time_reflection` in `DerivedAxioms.lean`, which also holds `serialFutureImp` (the pre-paper
`⊤ → F⊤`); `modal4`, `modalB`, the linearity mirrors `tempLinearityPast`/`linearSince` and the
pre-paper forms `tempLinearityLegacy`, `linearUntilLegacy` are in `../Theorems/Combinators.lean`.
Each is the lowerCamelCase form of the former constructor name, in the `DerivedAxioms`
namespace, with a context-lifted `…At Γ` form.

### Frame Class Coverage

All four `FrameClass` values are axiomatized here. `FrameClass.Dedekind` — Reynolds'
definable-gap axioms on top of the two density axioms — carries `soundness_dedekind`
(`../Metalogic/Soundness.lean`) and `completeness_dedekind`
(`../Metalogic/StrongCompleteness.lean`), both stated against `ValidDedekind` rather than
the density-free `ValidComplete`, because `density` and `dense_indicator` are admissible at
`.Dedekind` and both are false on ℤ.

### Inference Rules (`DerivationTree`)

| Rule | Description |
|------|-------------|
| `assumption` | `φ ∈ Γ → Γ ⊢ φ` |
| `weakening` | `Γ ⊢ φ → (ψ :: Γ) ⊢ φ` |
| `axiom` | Any axiom instance is derivable |
| `modus_ponens` | From `⊢ φ → ψ` and `⊢ φ`, derive `⊢ ψ` |
| `necessitation` | From `⊢ φ`, derive `⊢ □φ` |
| `temporal_necessitation` | From `⊢ φ`, derive `⊢ Gφ` |
| `time_reflection` | From `⊢ φ`, derive `⊢ φ.reflectTime` |

**Note**: `DerivationTree` is `Type` (not `Prop`) for computability reasons.
Use `Derivable` from `Derivable.lean` for Prop-valued derivability.

## Key Definitions

- `Axiom φ`: Inductive type inhabited when `φ` is a TM axiom instance
- `DerivationTree Γ φ`: Type of derivation trees (proofs) of `φ` from context `Γ`
- `Derives Γ φ`: Notation `Γ ⊢ φ` for nonemptiness of `DerivationTree Γ φ`
- `Derivable fc Γ φ`: Prop-valued derivability parameterized by frame class

## Related Documentation

- [Parent README](../README.md)
- [Metalogic README](../Metalogic/README.md)
- [Axiom Reference](../../docs/reference/axiom-reference.md)

---

*Last verified: 2026-09-07*

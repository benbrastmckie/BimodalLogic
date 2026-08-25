# ProofSystem

Hilbert-style proof system for TM bimodal logic (Burgess-Xu axiomatization).

This directory defines the complete axiom system and derivation rules for all four
TM logic variants (Base, Dense, Discrete, Dedekind), along with derived facts and utilities.

## Modules

| File | Lines | Description |
|------|------:|-------------|
| `Axioms.lean` | 625 | `Axiom` inductive type: 45 constructors organized into nine layers |
| `Derivation.lean` | 386 | `DerivationTree` inductive type: 7 inference rules as constructors |
| `Derivable.lean` | 228 | `Derivable`: Prop-valued derivability wrapper for classical reasoning |
| `LinearityDerivedFacts.lean` | 88 | Derived consequences of `temp_linearity`; non-derivability analysis |

## Axiom System

### Schema Count vs. Constructor Count

The `Axiom` inductive type has **45 constructors** organized into **nine layers**.
The 45 constructors correspond to **specific formula instances** within a smaller
set of schema families:

| Layer | Schemas | Constructors | Description |
|-------|--------:|------------:|-------------|
| 1. Propositional | 4 | 4 | Classical: K, S, EFQ, Peirce |
| 2. S5 Modal | 5 | 5 | T, 4, B, 5-collapse, K-distribution |
| 3. BX Temporal | ~9 | 18 | Burgess-Xu Until/Since axioms (paired G/H) |
| 3b. Additional BX Temporal | 2 | 4 | `temp_linearity`, `temp_linearity_past`, `F_until_equiv`, `P_since_equiv` |
| 4. Interaction | 1 | 1 | MF: `□φ → □Gφ` (TF is now derived) |
| 5. Uniformity | 5 | 5 | Discrete uniformity (valid on all ordered abelian groups) |
| 6. Prior | 2 | 2 | Prior-UZ/SZ (discrete well-ordering) |
| 7. Z1 | 1 | 1 | IsSuccArchimedean characteristic axiom |
| 8. Density | 2 | 2 | `density` (`GGφ → Gφ`) and `dense_indicator` (`¬U(⊤,⊥)`) (dense-only) |
| 9. Reynolds Dedekind | 3 | 3 | `prior_U_gap`, `prior_S_gap`, `sep` (Dedekind-only) |
| **Total** | | **45** | |

**Frame classification**: 37 Base constructors, 2 Dense-only (`density`, `dense_indicator`),
3 Discrete-only (`prior_UZ`, `prior_SZ`, `z1`), 3 Dedekind-only (`prior_U_gap`, `prior_S_gap`,
`sep`) — see `Axiom.minFrameClass` in `Axioms.lean`. Cumulatively (`Dense ≤ Dedekind`): Base 37,
Dense 39, Discrete 40, Dedekind 42.

**Note**: the `Axiom` inductive type has 45 constructors rather than one per logical schema
because paired temporal operators (G/H, F/P, Until/Since) each generate separate constructors.

### Frame Class Coverage

All four `FrameClass` values are axiomatized here. `FrameClass.Dedekind` — Reynolds'
definable-gap axioms on top of the two density axioms — carries `soundness_dedekind`
(`../Metalogic/Soundness.lean`) and `completeness_dedekind`
(`../Metalogic/StrongCompleteness.lean`), both stated against `ValidDedekindDense` rather than
the density-free `ValidDedekind`, because `density` and `dense_indicator` are admissible at
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
| `temporal_duality` | From `⊢ φ`, derive `⊢ swap(φ)` |

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

*Last verified: 2026-05-29*

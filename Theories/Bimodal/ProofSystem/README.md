# ProofSystem

Hilbert-style proof system for TM bimodal logic (Burgess-Xu axiomatization).

This directory defines the complete axiom system and derivation rules for all three
TM logic variants (Base, Dense, Discrete), along with derived facts and utilities.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Axioms.lean` | 468 | `Axiom` inductive type: 42 constructors organized into 8 layers |
| `Derivation.lean` | 385 | `DerivationTree` inductive type: 7 inference rules as constructors |
| `Derivable.lean` | 221 | `Derivable`: Prop-valued derivability wrapper for classical reasoning |
| `Substitution.lean` | 459 | Atom substitution for formulas and derivation preservation under substitution |
| `LinearityDerivedFacts.lean` | 82 | Derived consequences of `temp_linearity`; non-derivability analysis |

## Axiom System

### Schema Count vs. Constructor Count

The `Axiom` inductive type has **42 constructors** organized into **8 layers**.
The 42 constructors correspond to **specific formula instances** within a smaller
set of schema families:

| Layer | Schemas | Constructors | Description |
|-------|---------|-------------|-------------|
| Propositional | 4 | 4 | Classical: K, S, EFQ, Peirce |
| S5 Modal | 5 | 5 | T, 4, B, 5-collapse, K-distribution |
| BX Temporal | ~11 | 22 | Burgess-Xu Until/Since axioms (paired G/H) |
| Interaction | 1 | 1 | MF: `□φ → □Gφ` (TF is now derived) |
| Uniformity | 5 | 5 | Discrete uniformity (valid on all ordered abelian groups) |
| Prior | 2 | 2 | Prior-UZ/SZ (discrete well-ordering) |
| Z1 | 1 | 1 | IsSuccArchimedean characteristic axiom |
| Density | 2 | 2 | `Gφ → GGφ` and `¬U(⊤,⊥)` (dense-only) |

**Frame classification**: 37 Base constructors, 2 Discrete-only, 3 Dense-only.

**Note**: The root README references "21 axiom schemata" as the count of distinct
logical schemas. The `Axiom` inductive type has 42 constructors because paired temporal
operators (G/H, F/P, Until/Since) each generate separate constructors.

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
- `Formula.subst`: Atom substitution preserving derivability

## Related Documentation

- [Parent README](../README.md)
- [Metalogic README](../Metalogic/README.md)
- [Axiom Reference](../docs/reference/AXIOM_REFERENCE.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

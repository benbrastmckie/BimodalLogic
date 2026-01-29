# Completeness Theorem Hierarchy

**Status**: Self-Contained (No Boneyard Dependencies)

This directory contains the completeness hierarchy for TM bimodal logic, progressing from weak completeness through finite-premise strong completeness to infinitary strong completeness.

## Overview

The completeness theorem establishes that TM bimodal logic is complete with respect to task frame semantics: every valid formula is provable, and every semantic consequence has a derivation witness.

The proof proceeds via contraposition using the representation theorem from the `Representation/` directory.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Completeness.lean` | Module root, re-exports hierarchy | Complete |
| `WeakCompleteness.lean` | Weak completeness: valid implies provable | **Sorry-free** |
| `FiniteStrongCompleteness.lean` | Strong completeness for List-based contexts | **Sorry-free** |
| `InfinitaryStrongCompleteness.lean` | Strong completeness for Set-based contexts | **Sorry-free** |

## Dependency Flowchart

```
           Representation/
           representation_theorem
                   │
                   v
        WeakCompleteness.lean
                   │
                   v
    FiniteStrongCompleteness.lean
                   │
                   v
  InfinitaryStrongCompleteness.lean
```

## Key Theorems

### Weak Completeness (`WeakCompleteness.lean`)

```lean
theorem weak_completeness (φ : Formula) :
    valid φ → ContextDerivable [] φ

theorem provable_iff_valid (φ : Formula) :
    ContextDerivable [] φ ↔ valid φ
```

Every valid formula is provable (from the empty context).

**Proof Strategy**: Contrapositive using the representation theorem:
1. Assume φ is not provable
2. Then {¬φ} is consistent
3. By representation theorem, {¬φ} is satisfiable
4. Therefore ¬φ is true somewhere, so φ is not valid

### Finite-Premise Strong Completeness (`FiniteStrongCompleteness.lean`)

```lean
theorem finite_strong_completeness (Gamma : Context) (φ : Formula) :
    semantic_consequence Gamma φ → ContextDerivable Gamma φ

theorem context_provable_iff_entails (Gamma : Context) (φ : Formula) :
    ContextDerivable Gamma φ ↔ semantic_consequence Gamma φ
```

Extends weak completeness to List-based contexts via the deduction theorem.

**Key Construction**:
- `impChain`: Builds implication chain from context to formula
- `impChain Gamma φ = ψ₁ → (ψ₂ → ... → (ψₙ → φ)...)`

### Infinitary Strong Completeness (`InfinitaryStrongCompleteness.lean`)

```lean
theorem infinitary_strong_completeness (Gamma : Set Formula) (φ : Formula) :
    set_semantic_consequence Gamma φ →
    ∃ (Delta : Finset Formula), Delta.toSet ⊆ Gamma ∧ ContextDerivable Delta.toList φ
```

Every Set-based semantic consequence has a finite derivation witness.

**Supporting Definitions**:
- `set_semantic_consequence`: Semantic consequence for potentially infinite sets
- `set_satisfiable`: Satisfiability for potentially infinite sets

## Proof Architecture

```
                      COMPLETENESS THEOREM
                              │
                              v
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           v                  v                  v
    weak_completeness   finite_strong    infinitary_strong
           │              completeness      completeness
           │                  │                  │
           v                  v                  v
    representation      deduction_theorem   Lindenbaum +
       theorem                              MCS extension
```

## Design Notes

### Why Three Levels?

1. **Weak completeness** establishes the fundamental result for formulas alone
2. **Finite-premise strong** handles proofs from finite assumption sets (practical reasoning)
3. **Infinitary strong** enables the compactness theorem via finite witness extraction

### Soundness Integration

The bidirectional equivalences (e.g., `provable_iff_valid`) use the soundness theorem from `../Soundness/`. The soundness theorem is now self-contained (migrated from Boneyard).

## Dependencies

- **Representation**: `representation_theorem` (canonical model satisfiability)
- **Soundness**: `soundness` (derivability implies validity)
- **Core**: `deduction_theorem`, MCS properties

## Related Files

- `../Soundness/README.md` - Soundness theorem (used for iff statements)
- `../Representation/README.md` - Representation theorem implementation
- `../Compactness/README.md` - Compactness theorem (uses infinitary completeness)
- `../Core/README.md` - MCS and deduction theorem foundations

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)

---

*Last updated: 2026-01-29*

# Completeness Theorem

This directory contains the completeness theorems for TM bimodal logic, establishing that every valid formula is provable.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Completeness.lean` | Module root, re-exports hierarchy | Complete |
| `WeakCompleteness.lean` | Weak completeness: valid implies provable | Complete |
| `FiniteStrongCompleteness.lean` | Strong completeness for List-based contexts | Complete |

## Key Theorems

### Weak Completeness (`WeakCompleteness.lean`)

```lean
theorem weak_completeness (φ : Formula) :
    valid φ → ContextDerivable [] φ

theorem provable_iff_valid (φ : Formula) :
    ContextDerivable [] φ ↔ valid φ
```

Every valid formula is provable (from the empty context).

**Proof Strategy**: Contrapositive using `semantic_weak_completeness` from `FMP/`.

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

## Dependency Flowchart

```
    FMP/SemanticCanonicalModel.lean
    semantic_weak_completeness
              │
              v
    WeakCompleteness.lean
              │
              v
  FiniteStrongCompleteness.lean
```

## Design Notes

### Why Two Levels?

1. **Weak completeness** establishes the fundamental result for formulas alone
2. **Finite-premise strong** handles proofs from finite assumption sets (practical reasoning)

For infinitary strong completeness (Set-based contexts), see `UnderDevelopment/RepresentationTheorem/InfinitaryStrongCompleteness.lean`.

### Soundness Integration

The bidirectional equivalences (e.g., `provable_iff_valid`) use the soundness theorem from `../Soundness/`.

## Dependencies

- **FMP**: `semantic_weak_completeness` (the canonical completeness result)
- **Soundness**: `soundness` (derivability implies validity)
- **Core**: `deduction_theorem`, MCS properties

## Related Files

- `../Soundness/README.md` - Soundness theorem (used for iff statements)
- `../FMP/README.md` - Contains `semantic_weak_completeness`
- `../Core/README.md` - Deduction theorem and MCS foundations

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)

---

*Last updated: 2026-01-30*

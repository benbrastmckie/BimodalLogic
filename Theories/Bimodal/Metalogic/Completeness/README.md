# Completeness Theorem

This directory contains the completeness theorems for TM bimodal logic, establishing that every valid formula is provable.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Completeness.lean` | Module root, re-exports hierarchy | Complete |
| `FiniteStrongCompleteness.lean` | Strong completeness for List-based contexts | Complete |

## Archived Modules (Task 809)

The following modules were archived to `Boneyard/Metalogic_v5/Completeness/` because they depended on the Representation approach which contained sorries:

| Module | Why Archived |
|--------|--------------|
| `WeakCompleteness.lean` | Depended on UniversalCanonicalModel with 30+ sorries |
| `InfinitaryStrongCompleteness.lean` | Depended on UniversalCanonicalModel with 30+ sorries |

For sorry-free completeness, use:
- `Bimodal.Metalogic.FMP.semantic_weak_completeness` (weak completeness)
- `finite_strong_completeness` in this directory (finite-premise strong)

## Key Theorems

### Finite-Premise Strong Completeness (`FiniteStrongCompleteness.lean`)

```lean
theorem finite_strong_completeness (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> ContextDerivable Gamma phi

theorem context_provable_iff_entails (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi <-> semantic_consequence Gamma phi
```

Extends weak completeness to List-based contexts via the deduction theorem.

**Key Construction**:
- `impChain`: Builds implication chain from context to formula
- `impChain Gamma phi = psi1 -> (psi2 -> ... -> (psin -> phi)...)`

## Dependency Flowchart

```
    FMP/SemanticCanonicalModel.lean
    semantic_weak_completeness
              |
              v
  FiniteStrongCompleteness.lean
```

## Design Notes

### Why Two Levels?

1. **Weak completeness** establishes the fundamental result for formulas alone
2. **Finite-premise strong** handles proofs from finite assumption sets (practical reasoning)

For infinitary strong completeness (Set-based contexts), the Representation approach
in Boneyard/Metalogic_v5/ provides this, but with trusted axioms (30 sorries).

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

*Last updated: 2026-02-02 (Task 809 archival)*

# Completeness Theorem Hierarchy

This directory contains the completeness hierarchy for TM bimodal logic, progressing from weak completeness through finite-premise strong completeness to infinitary strong completeness.

## Overview

The completeness theorem establishes that TM bimodal logic is complete with respect to task frame semantics: every valid formula is provable, and every semantic consequence has a derivation witness.

The proof proceeds via contraposition using the representation theorem from the `Representation/` directory.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Completeness.lean` | Module root, re-exports hierarchy | Complete |
| `WeakCompleteness.lean` | Weak completeness: valid implies provable | Proven |
| `FiniteStrongCompleteness.lean` | Strong completeness for List-based contexts | Proven |
| `InfinitaryStrongCompleteness.lean` | Strong completeness for Set-based contexts | Proven |

## Key Theorems

### Weak Completeness (`WeakCompleteness.lean`)

```lean
theorem weak_completeness (phi : Formula) :
    valid phi -> ContextDerivable [] phi

theorem provable_iff_valid (phi : Formula) :
    ContextDerivable [] phi <-> valid phi
```

Every valid formula is provable (from the empty context).

**Proof Strategy**: Contrapositive using the representation theorem:
1. Assume phi is not provable
2. Then {neg phi} is consistent
3. By representation theorem, {neg phi} is satisfiable
4. Therefore neg phi is true somewhere, so phi is not valid

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
- `impChain Gamma phi = psi_1 -> (psi_2 -> ... -> (psi_n -> phi)...)`

### Infinitary Strong Completeness (`InfinitaryStrongCompleteness.lean`)

```lean
theorem infinitary_strong_completeness (Gamma : Set Formula) (phi : Formula) :
    set_semantic_consequence Gamma phi ->
    exists (Delta : Finset Formula), Delta.toSet ⊆ Gamma /\ ContextDerivable Delta.toList phi
```

Every Set-based semantic consequence has a finite derivation witness.

**Supporting Definitions**:
- `set_semantic_consequence`: Semantic consequence for potentially infinite sets
- `set_satisfiable`: Satisfiability for potentially infinite sets

## Proof Architecture

```
                      COMPLETENESS THEOREM
                              |
                              v
           +------------------+------------------+
           |                  |                  |
           v                  v                  v
    weak_completeness   finite_strong    infinitary_strong
           |              completeness      completeness
           |                  |                  |
           v                  v                  v
    representation      deduction_theorem   Lindenbaum +
       theorem                              MCS extension
```

## Dependencies

- **Representation Theorem**: `Bimodal.Metalogic.Representation.representation_theorem`
- **Deduction Theorem**: `Bimodal.Metalogic.Core.DeductionTheorem`
- **MCS Theory**: `Bimodal.Metalogic.Core.MCSProperties`
- **Soundness**: Axiomatized pending Boneyard migration

## Design Notes

### Why Three Levels?

1. **Weak completeness** establishes the fundamental result for formulas alone
2. **Finite-premise strong** handles proofs from finite assumption sets (practical reasoning)
3. **Infinitary strong** enables the compactness theorem via finite witness extraction

### Soundness Dependency

The bidirectional equivalences (e.g., `provable_iff_valid`) require soundness. Soundness is axiomatized with sorry pending Boneyard migration; the one-directional completeness theorems do not require it.

## Related Files

- `../Representation/README.md` - Representation theorem implementation
- `../Compactness/README.md` - Compactness theorem (uses infinitary completeness)
- `../Core/README.md` - MCS and deduction theorem foundations

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
- Research report: specs/654_.../reports/research-004.md (indexed family approach)

---

*Last updated: 2026-01-29*

# Compactness Theorem

**Status**: Self-Contained (No Boneyard Dependencies)

This directory contains the compactness theorem for TM bimodal logic.

## Overview

The compactness theorem establishes that a (possibly infinite) set of formulas is satisfiable if and only if every finite subset is satisfiable. This fundamental result bridges finite and infinite semantics and has important applications for decidability and model theory.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Compactness.lean` | Compactness theorem and variants | **Sorry-free** |

## Key Theorems

### Main Compactness Theorem

```lean
theorem compactness (Gamma : Set Formula) :
    (∀ (Delta : Finset Formula), Delta.toSet ⊆ Gamma → set_satisfiable Delta.toSet) →
    set_satisfiable Gamma
```

If every finite subset of Gamma is satisfiable, then Gamma is satisfiable.

### Bidirectional Form

```lean
theorem compactness_iff (Gamma : Set Formula) :
    set_satisfiable Gamma ↔
    ∀ (Delta : Finset Formula), Delta.toSet ⊆ Gamma → set_satisfiable Delta.toSet
```

### Compactness for Entailment

```lean
theorem compactness_entailment (Gamma : Set Formula) (φ : Formula) :
    set_semantic_consequence Gamma φ →
    ∃ (Delta : Finset Formula), Delta.toSet ⊆ Gamma ∧ set_semantic_consequence Delta.toSet φ
```

Semantic consequence from infinite sets always has a finite witness.

### Compactness for Unsatisfiability

```lean
theorem compactness_unsatisfiability (Gamma : Set Formula) :
    ¬set_satisfiable Gamma →
    ∃ (Delta : Finset Formula), Delta.toSet ⊆ Gamma ∧ ¬set_satisfiable Delta.toSet
```

Unsatisfiability of infinite sets always has a finite witness.

## Proof Strategy

The proof uses contraposition via infinitary strong completeness:

1. Assume every finite subset of Gamma is satisfiable
2. Suppose (for contradiction) Gamma is not satisfiable
3. Then Gamma ⊨ ⊥ (false is a semantic consequence of Gamma)
4. By infinitary strong completeness: some finite Delta ⊆ Gamma derives ⊥
5. By soundness: Delta is unsatisfiable
6. Contradiction with assumption

```
             Compactness
                  │
                  v
    Infinitary Strong Completeness
                  │
         ┌───────┴───────┐
         │               │
         v               v
    Lindenbaum       Soundness
       Lemma
```

## Dependencies

- **Infinitary Strong Completeness**: `Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness`
- **Soundness**: `Bimodal.Metalogic.Soundness.soundness` (now self-contained)

## Design Notes

### Why Separate from Completeness?

While compactness follows from infinitary strong completeness, it is conceptually distinct:
- Completeness connects syntax (provability) to semantics (validity)
- Compactness is a purely semantic property about satisfiability

Separating them makes the dependency structure clear and allows each result to be used independently.

### Applications

Compactness enables:
- Decidability arguments via finite model checking
- Non-existence proofs via infinite models
- Transfer of properties from finite to infinite sets

## Related Files

- `../Completeness/README.md` - Infinitary strong completeness (prerequisite)
- `../Soundness/README.md` - Soundness theorem (prerequisite)
- `../Representation/README.md` - Representation theorem (foundation for completeness)
- `../README.md` - Overall metalogic architecture

## References

- Modal Logic, Blackburn et al., Chapter 4 (Compactness)

---

*Last updated: 2026-01-29*

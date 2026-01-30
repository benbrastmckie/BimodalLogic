# Representation Theorem: Universal Canonical Model Approach

This directory contains the universal canonical model construction for proving completeness via the representation theorem.

## Status: UNDER DEVELOPMENT

**Total Sorries**: 17

These files are preserved as an alternative approach to completeness. The sorry-free completeness is provided by `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`.

## Files

| File | Sorries | Description |
|------|---------|-------------|
| TaskRelation.lean | 5 | Canonical task relation with compositionality |
| CoherentConstruction.lean | 8 | Coherent MCS family construction |
| CanonicalHistory.lean | 0 | Canonical history construction (depends on sorried TaskRelation) |
| TruthLemma.lean | 4 | Truth lemma for canonical models |
| UniversalCanonicalModel.lean | 0 | Universal canonical model assembly (depends on above) |
| InfinitaryStrongCompleteness.lean | 0 | Strong completeness for infinite premises |
| Compactness.lean | 0 | Compactness theorem |

## Sorry Analysis

### TaskRelation.lean (5 sorries)

Cross-sign duration composition cases:

| Case | Description |
|------|-------------|
| d1+d2=0 | Cross-sign cancellation requires MCS equality |
| d1+d2>0 forward G | Cross-direction G propagation |
| d1+d2>0 backward H | Cross-direction H propagation |
| d1+d2<0 forward H | Negative cross-direction H |
| d1+d2<0 backward G | Negative cross-direction G |

**Why unprovable**: Requires omega-rule reasoning or cross-origin axioms not present in TM logic.

### CoherentConstruction.lean (8 sorries)

Cross-origin coherence cases:

| Condition | Cases |
|-----------|-------|
| forward_G | 2 (cross-origin, backward chain toward origin) |
| backward_H | 2 (forward chain, cross-origin) |
| forward_H | 2 (forward chain, cross-origin) |
| backward_G | 2 (cross-origin, backward chain) |

**Why unprovable**: Forward and backward Lindenbaum seeds are independent; no axiom connects G-formulas in backward chain to H-formulas in forward chain.

### TruthLemma.lean (4 sorries)

| Case | Description |
|------|-------------|
| Box forward | Box quantifies over ALL histories |
| Box backward | Box requires ALL histories |
| H backward | Requires omega-rule |
| G backward | Requires omega-rule |

**Why unprovable**: Box uses S5-style universal quantification; temporal backward requires infinitary derivation.

## Architecture

```
TaskRelation.lean  CoherentConstruction.lean
       \                    /
        \                  /
         v                v
      CanonicalHistory.lean
               |
               v
         TruthLemma.lean
               |
               v
    UniversalCanonicalModel.lean
               |
               v
   InfinitaryStrongCompleteness.lean
               |
               v
        Compactness.lean
```

## Development Notes

### To work on these files:

1. Uncomment the relevant import in `RepresentationTheorem.lean`
2. Build: `lake build Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.TaskRelation`
3. Re-comment import before committing

### Potential future work:

1. **Alternate Box semantics**: Use Kripke-style accessibility relations instead of universal quantification
2. **Restricted completeness**: Prove completeness for box-free formulas only
3. **Constructive MCS**: Use constructive extension that maintains cross-origin coherence

## References

- Modal Logic, Blackburn et al., Chapters 4-5

---

*Last updated: 2026-01-30*

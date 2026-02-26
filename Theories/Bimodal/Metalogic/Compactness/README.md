# Compactness (ARCHIVED)

**Status**: ARCHIVED to Boneyard/Metalogic_v5/Compactness/ (Task 809, 2026-02-02)

## Why Archived

The Compactness theorem was archived because it depended on:
- `InfinitaryStrongCompleteness` which used the Representation approach
- The Representation approach contained 30+ sorries

## Archive Location

```
Theories/Bimodal/Boneyard/Metalogic_v5/Compactness/Compactness.lean
```

## What Was Available

The archived compactness theorem provides:
- `compactness`: Main compactness theorem
- `compactness_iff`: Bidirectional equivalence
- `compactness_entailment`: Semantic consequence has finite witness
- `compactness_unsatisfiability`: Unsatisfiability has finite witness

## Alternative

For sorry-free completeness proofs, use:
- `Bimodal.Metalogic.FMP.semantic_weak_completeness` (weak completeness)
- `Bimodal.Metalogic.Completeness.finite_strong_completeness` (finite-premise)

The FMP approach does not provide infinitary completeness or compactness
because it operates on single formulas, not infinite formula sets.

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Bundle README](../Bundle/README.md) - BFMCS completeness approach
- [FMP README](../FMP/README.md) - FMP completeness approach

---

*Archived: 2026-02-02 (Task 809)*

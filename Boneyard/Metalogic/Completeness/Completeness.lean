import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness

/-!
# Completeness Module for TM Bimodal Logic

This module serves as the root of the completeness hierarchy for TM logic.

## Structure

```
Completeness/
├── Completeness.lean                   # This file - module root
└── FiniteStrongCompleteness.lean       # finite_strong_completeness (List contexts)

FMP/
└── SemanticCanonicalModel.lean         # semantic_weak_completeness (sorry-free)
```

## Archived to Boneyard/Metalogic_v5/ (Task 809)

The following were archived because they depended on Representation approach with 30+ sorries:
- WeakCompleteness.lean (used Representation-based representation_theorem)
- InfinitaryStrongCompleteness.lean (used Representation-based truth_lemma)
- Compactness/Compactness.lean (used InfinitaryStrongCompleteness)

## Main Results (Active)

### Finite-Premise Strong Completeness
- `finite_strong_completeness`: `Gamma |= phi -> ContextDerivable Gamma phi` (for List Gamma)
- `context_provable_iff_entails`: `ContextDerivable Gamma phi <-> Gamma |= phi`
- `impChain`: Helper for building implication chains

### Sorry-Free Weak Completeness (in FMP/)
- `semantic_weak_completeness`: `valid phi -> ContextDerivable [] phi`

## Archived Results (in Boneyard/Metalogic_v5/)

These results exist but depend on trusted axioms (30 sorries in Representation approach):
- `weak_completeness`: Weak completeness via Representation
- `infinitary_strong_completeness`: Set-based contexts
- `compactness`: True compactness theorem

## Design Notes

For a sorry-free completeness proof suitable for publication, use:
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
-- Use: semantic_weak_completeness
```

The FMP approach is now the canonical sorry-free completeness path.

## References

- Representation theorem (archived): `Boneyard/Metalogic_v5/Representation/`
- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)

---

*Updated: 2026-02-02 (Task 809 archival)*
-/

-- All exports are via the imports above
-- Users can open the namespace to access definitions

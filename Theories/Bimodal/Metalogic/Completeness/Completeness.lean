import Bimodal.Metalogic.Completeness.WeakCompleteness
import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness
import Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness
import Bimodal.Metalogic.Compactness.Compactness

/-!
# Completeness Module for TM Bimodal Logic

This module serves as the root of the completeness hierarchy for TM logic.

## Structure

```
Completeness/
├── Completeness.lean                   # This file - module root
├── WeakCompleteness.lean               # weak_completeness, provable_iff_valid
├── FiniteStrongCompleteness.lean       # finite_strong_completeness (List contexts)
└── InfinitaryStrongCompleteness.lean   # Set-based contexts, set_semantic_consequence

Compactness/
└── Compactness.lean                    # compactness theorem
```

## Main Results

### Weak Completeness (Phase 1)
- `weak_completeness`: `⊨ φ → ContextDerivable [] φ`
- `provable_iff_valid`: `ContextDerivable [] φ ↔ ⊨ φ`

### Finite-Premise Strong Completeness (Phase 2)
- `finite_strong_completeness`: `Γ ⊨ φ → ContextDerivable Γ φ` (for List Γ)
- `context_provable_iff_entails`: `ContextDerivable Γ φ ↔ Γ ⊨ φ`
- `impChain`: Helper for building implication chains

### Infinitary Strong Completeness (Phase 4)
- `set_semantic_consequence`: Semantic consequence for Set-based contexts
- `set_satisfiable`: Satisfiability for Set-based contexts
- `infinitary_strong_completeness`: Set-based consequence has finite witness (axiomatized)
- `infinitary_strong_completeness_finset`: Fully proven for finite sets

### True Compactness (Phase 5)
- `compactness`: Satisfiable iff every finite subset is satisfiable
- `compactness_iff`: Bidirectional equivalence form
- `compactness_entailment`: Semantic consequence has finite witness
- `compactness_unsatisfiability`: Unsatisfiability has finite witness

## References

- Representation theorem: `Bimodal.Metalogic.Representation.representation_theorem`
- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
-/

-- All exports are via the imports above
-- Users can open the namespace to access definitions

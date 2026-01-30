import Bimodal.Metalogic.Completeness.WeakCompleteness
import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness
-- InfinitaryStrongCompleteness archived to Boneyard/Metalogic_v4/ (Task 772)
-- It depended on sorried representation theorem infrastructure
-- Compactness archived to Boneyard/Metalogic_v4/ (Task 772)
-- It depended on infinitary strong completeness

/-!
# Completeness Module for TM Bimodal Logic

This module serves as the root of the completeness hierarchy for TM logic.

## Structure

```
Completeness/
├── Completeness.lean                   # This file - module root
├── WeakCompleteness.lean               # weak_completeness, provable_iff_valid
└── FiniteStrongCompleteness.lean       # finite_strong_completeness (List contexts)

Compactness/
└── Compactness.lean                    # compactness theorem

Archived (Boneyard/Metalogic_v4/):
├── InfinitaryStrongCompleteness.lean   # Depended on sorried representation theorem
└── Compactness.lean                    # Depended on infinitary strong completeness
```

## Main Results

### Weak Completeness (Phase 1)
- `weak_completeness`: `⊨ φ → ContextDerivable [] φ`
- `provable_iff_valid`: `ContextDerivable [] φ ↔ ⊨ φ`

### Finite-Premise Strong Completeness (Phase 2)
- `finite_strong_completeness`: `Γ ⊨ φ → ContextDerivable Γ φ` (for List Γ)
- `context_provable_iff_entails`: `ContextDerivable Γ φ ↔ Γ ⊨ φ`
- `impChain`: Helper for building implication chains

### Infinitary Strong Completeness (ARCHIVED - Task 772)
**Archived to Boneyard/Metalogic_v4/**: Depended on sorried representation theorem.
- `set_semantic_consequence`: Semantic consequence for Set-based contexts
- `infinitary_strong_completeness`: Set-based consequence has finite witness
The finite set specialization remains accessible via compactness.

### True Compactness (ARCHIVED - Task 772)
**Archived to Boneyard/Metalogic_v4/**: Depended on infinitary strong completeness.
- `compactness`: Satisfiable iff every finite subset is satisfiable
- Finite compactness (`compactness_finset`) remains trivially true

## References

- Semantic weak completeness: `Bimodal.Metalogic.FMP.semantic_weak_completeness` (sorry-free)
- Task 772: Refactoring to archive sorried representation theorem infrastructure
- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
-/

-- All exports are via the imports above
-- Users can open the namespace to access definitions

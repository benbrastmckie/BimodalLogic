import Bimodal.Metalogic.Completeness.WeakCompleteness

/-!
# Completeness Module for TM Bimodal Logic

This module serves as the root of the completeness hierarchy for TM logic.

## Structure

```
Completeness/
├── Completeness.lean            # This file - module root
├── WeakCompleteness.lean        # weak_completeness, provable_iff_valid
├── FiniteStrongCompleteness.lean # (Phase 2) strong_completeness for List contexts
└── InfinitaryStrongCompleteness.lean # (Phase 4) strong_completeness for Set contexts
```

## Main Results

### Weak Completeness (Phase 1)
- `weak_completeness`: `⊨ φ → ContextDerivable [] φ`
- `provable_iff_valid`: `ContextDerivable [] φ ↔ ⊨ φ`

### Strong Completeness (Phases 2, 4)
- `finite_strong_completeness`: `Γ ⊨ φ → ContextDerivable Γ φ` (finite Γ)
- `infinitary_strong_completeness`: Set-based contexts

## References

- Representation theorem: `Bimodal.Metalogic.Representation.representation_theorem`
- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
-/

-- All exports are via the import above
-- Users can open the namespace to access definitions

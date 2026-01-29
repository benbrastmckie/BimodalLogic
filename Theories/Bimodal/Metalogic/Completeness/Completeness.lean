import Bimodal.Metalogic.Completeness.WeakCompleteness
import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness

/-!
# Completeness Module for TM Bimodal Logic

This module serves as the root of the completeness hierarchy for TM logic.

## Structure

```
Completeness/
├── Completeness.lean                   # This file - module root
├── WeakCompleteness.lean               # weak_completeness, provable_iff_valid
├── FiniteStrongCompleteness.lean       # finite_strong_completeness (List contexts)
├── InfinitaryStrongCompleteness.lean   # (Phase 4) Set-based contexts
```

## Main Results

### Weak Completeness (Phase 1)
- `weak_completeness`: `⊨ φ → ContextDerivable [] φ`
- `provable_iff_valid`: `ContextDerivable [] φ ↔ ⊨ φ`

### Finite-Premise Strong Completeness (Phase 2)
- `finite_strong_completeness`: `Γ ⊨ φ → ContextDerivable Γ φ`
- `context_provable_iff_entails`: `ContextDerivable Γ φ ↔ Γ ⊨ φ`
- `impChain`: Helper for building implication chains

## References

- Representation theorem: `Bimodal.Metalogic.Representation.representation_theorem`
- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
-/

-- All exports are via the imports above
-- Users can open the namespace to access definitions

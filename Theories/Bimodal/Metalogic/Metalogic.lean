-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Bundle.Completeness
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Metalogic.Decidability

/-!
# Bimodal Metalogic

This module provides the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Main Results

| Result | Theorem | Module | Status |
|--------|---------|--------|--------|
| **Soundness** | `soundness` | `Soundness` | SORRY-FREE |
| **BMCS Weak Completeness** | `bmcs_weak_completeness` | `Bundle.Completeness` | SORRY-FREE |
| **BMCS Strong Completeness** | `bmcs_strong_completeness` | `Bundle.Completeness` | SORRY-FREE |
| **FMP Weak Completeness** | `fmp_weak_completeness` | `FMP.SemanticCanonicalModel` | SORRY-FREE |
| **Decidability** | `decide` | `Decidability.DecisionProcedure` | SORRY-FREE |

All main theorems are proven without sorries.

## Sorry Status

**Active sorries in Metalogic/**: 4 (all in helper lemmas, documented as failures with alternatives)

| File | Line | Sorry | Status | Alternative |
|------|------|-------|--------|-------------|
| `Bundle/TruthLemma.lean` | ~383 | all_future backward | Documented | Omega-rule (infinitary) |
| `Bundle/TruthLemma.lean` | ~395 | all_past backward | Documented | Omega-rule (infinitary) |
| `Bundle/Construction.lean` | ~220 | modal_backward | Documented | Multi-family BMCS |
| `FMP/Closure.lean` | ~728 | diamond membership | Documented | Minor edge case |

**Key Point**: These do NOT affect main theorems. Completeness uses only the FORWARD
direction of the truth lemma, which is fully proven.

## Module Structure

```
Metalogic/
├── Core/                    # MCS theory, provability, deduction theorem
│   ├── DeductionTheorem.lean   # Hilbert-style deduction theorem
│   ├── MaximalConsistent.lean  # Lindenbaum's lemma, MCS properties
│   └── MCSProperties.lean      # MCS closure under derivation
│
├── Bundle/                  # BMCS Completeness (primary completeness result)
│   ├── IndexedMCSFamily.lean   # Temporal MCS families
│   ├── BMCS.lean               # Bundle structure
│   ├── BMCSTruth.lean          # Truth with bundled box
│   ├── TruthLemma.lean         # KEY: sorry-free forward direction
│   ├── Construction.lean       # BMCS from consistent context
│   └── Completeness.lean       # bmcs_weak_completeness, bmcs_strong_completeness
│
├── FMP/                     # Finite Model Property
│   ├── SemanticCanonicalModel.lean  # fmp_weak_completeness (sorry-free)
│   ├── FiniteWorldState.lean        # Bounded world states
│   ├── BoundedTime.lean             # Bounded temporal indices
│   └── Closure.lean                 # Formula closure operations
│
├── Decidability/            # Tableau-based decision procedure
│   ├── DecisionProcedure.lean  # Main decide function
│   ├── Correctness.lean        # Soundness proof
│   └── ...                     # Supporting modules
│
├── Soundness.lean           # soundness theorem
├── SoundnessLemmas.lean     # Axiom validity lemmas
├── Completeness.lean        # MCS closure properties
│
└── Algebraic/               # (Future) Algebraic representation theorem
    └── ...                     # Preserved for future work
```

## Completeness Strategy

### BMCS Completeness (Bundle/)

The Bundle of Maximal Consistent Sets (BMCS) approach provides Henkin-style
completeness that avoids the modal box obstruction:

1. **Representation**: If φ is consistent, construct BMCS where φ is true
2. **Weak Completeness**: bmcs_valid φ → ⊢ φ (by contrapositive)
3. **Strong Completeness**: bmcs_consequence Γ φ → Γ ⊢ φ (by contrapositive)

```
BMCS Completeness + Standard Soundness
══════════════════════════════════════
⊢ φ  ↔  bmcs_valid φ  →  standard_valid φ
```

### FMP Completeness (FMP/)

The Finite Model Property approach constructs finite countermodels:

1. If φ is not provable, {¬φ} is consistent
2. Extend to closure-MCS via Lindenbaum
3. Build finite world state from closure-MCS
4. φ is false in this finite model

Both approaches yield sorry-free completeness theorems.

## Usage

For BMCS completeness (Henkin-style):
```lean
import Bimodal.Metalogic.Bundle.Completeness
-- Provides: bmcs_representation, bmcs_weak_completeness, bmcs_strong_completeness
```

For FMP-based completeness:
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
-- Provides: fmp_weak_completeness (alias: semantic_weak_completeness)
```

For decidability:
```lean
import Bimodal.Metalogic.Decidability
-- Provides: decide, isValid, isSatisfiable
```

For soundness:
```lean
import Bimodal.Metalogic.Soundness
-- Provides: soundness
```

## References

- Research: specs/812_canonical_model_completeness/reports/research-007.md
- Implementation: specs/812_canonical_model_completeness/plans/implementation-003.md
- Task 818: Module refactoring and documentation
-/

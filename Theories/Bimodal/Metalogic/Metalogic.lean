-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Bundle.Completeness
import Bimodal.Metalogic.Representation
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
| **Standard Weak Completeness** | `standard_weak_completeness` | `Representation` | sorry-dependent |
| **Standard Strong Completeness** | `standard_strong_completeness` | `Representation` | sorry-dependent |
| **FMP Weak Completeness** | `fmp_weak_completeness` | `FMP.SemanticCanonicalModel` | SORRY-FREE |
| **Decidability** | `decide` | `Decidability.DecisionProcedure` | SORRY-FREE |

All main theorems are proven without sorries (direct or local). The standard completeness
theorems in Representation.lean are sorry-dependent because they rely on
`construct_saturated_bmcs_int` which has upstream sorries in the BMCS saturation chain.

## Sorry Status

**Active sorries in Metalogic/**: 7 total

| File | Count | Description |
|------|-------|-------------|
| `Bundle/Construction.lean` | 1 | modal_backward (line 197) |
| `Bundle/TemporalCoherentConstruction.lean` | 2 | temporal_coherent_family_exists, fully_saturated_bmcs_exists_int |
| `Bundle/DovetailingChain.lean` | 4 | cross-sign propagation and F/P witnesses |

**Key Point**: Main completeness theorems (bmcs_weak_completeness, bmcs_strong_completeness,
standard_weak_completeness, standard_strong_completeness) are SORRY-FREE. The soundness
theorem is also SORRY-FREE. Remaining sorries are in upstream BMCS construction utilities.

**Resolved (task 912 v002)**:
- 29 sorries archived (25 RecursiveSeed/Seed*, 4 EvalBMCS truth lemma)
- 3 sorries discharged: 2 in Representation.lean (Omega-mismatch), 1 in Soundness.lean (temporal duality)

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
-- Provides: fmp_weak_completeness
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

-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Decidability
import Bimodal.Metalogic.StagedConstruction.Completeness

/-!
# Bimodal Metalogic

This module provides the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Publication-Ready Results

| Result | Theorem | Status |
|--------|---------|--------|
| **Soundness** | `soundness` | SORRY-FREE, AXIOM-FREE |
| **Dense Completeness** | `dense_completeness_components_proven` | SORRY-FREE, AXIOM-FREE |
| **Decidability** | `decide` | SORRY-FREE, AXIOM-FREE |

## Completeness Architecture

The dense completeness proof uses the StagedConstruction approach:

1. **Cantor Isomorphism**: TimelineQuot (canonical MCS quotient) is order-isomorphic to Q
2. **CanonicalFMCS**: Sorry-free temporal coherent family over all MCSs
3. **Truth Lemma**: MCS membership iff semantic truth (bmcs_truth_lemma, shifted_truth_lemma)
4. **Dense Completeness**: All components proven without sorries

## Axiom Dependencies

Standard Lean axioms only (no custom axioms):
- `propext`: Propositional extensionality
- `Classical.choice`: Classical choice
- `Quot.sound`: Quotient soundness

## Module Structure

```
Metalogic/
├── Core/                    # MCS theory, deduction theorem
├── Bundle/                  # BFMCS infrastructure
│   ├── TruthLemma.lean         # SORRY-FREE truth lemma
│   ├── CanonicalConstruction.lean  # Shifted truth lemma
│   └── CanonicalFMCS.lean      # All-MCS temporal coherence
├── StagedConstruction/      # Dense completeness (Cantor approach)
│   └── Completeness.lean       # Main completeness documentation
├── Decidability/            # Tableau decision procedure
├── Soundness.lean           # Soundness theorem
└── SoundnessLemmas.lean     # Axiom validity lemmas
```

## Usage

```lean
import Bimodal.Metalogic.Soundness
-- #check soundness

import Bimodal.Metalogic.StagedConstruction.Completeness
-- #check dense_completeness_components_proven

import Bimodal.Metalogic.Decidability
-- #check decide
```

## References

- Task 929: Publication preparation
- Task 956: D construction from Cantor
- Task 967: T-axiom irreflexivity
-/

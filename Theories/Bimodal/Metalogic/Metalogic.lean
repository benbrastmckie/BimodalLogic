-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Decidability

/-!
# Bimodal Metalogic

This module provides the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Reflexive G/H Semantics (Task 29)

Under reflexive semantics, G and H quantify over `s ≥ t` and `s ≤ t` respectively
(including the current time). This makes the canonical accessibility relation
REFLEXIVE: `canonicalR_reflexive` is proven via T-axiom.

## Publication-Ready Results

| Result | Theorem | Status |
|--------|---------|--------|
| **Soundness** | `soundness` | SORRY-FREE, AXIOM-FREE |
| **Base Completeness** | `base_truth_lemma` | SORRY-FREE, AXIOM-FREE |
| **Decidability** | `decide` | SORRY-FREE, AXIOM-FREE |

## Completeness Architecture

The completeness proof uses the SuccChain architecture:

1. **SuccChain/**: Successor chain construction for dense completeness
2. **Bundle/**: BFMCS infrastructure with truth lemma
3. **FrameConditions/**: Frame condition proofs

## Axiom Dependencies

Standard Lean axioms only on publication path:
- `propext`, `Classical.choice`, `Quot.sound`

## Module Structure

```
Metalogic/
├── Core/                    # MCS theory, deduction theorem
├── Bundle/                  # BFMCS infrastructure
│   ├── TruthLemma.lean         # Truth lemma
│   ├── CanonicalConstruction.lean  # Shifted truth lemma
│   ├── CanonicalFMCS.lean      # Temporal coherent families
│   └── CanonicalIrreflexivity.lean  # Reflexive/irreflexive theorems
├── SuccChain/               # Successor chain completeness (active)
├── FrameConditions/         # Frame condition proofs
├── Decidability/            # Tableau decision procedure
├── Soundness.lean           # Soundness theorem
└── BaseCompleteness.lean    # Base completeness interface
```

## References

- Task 29: Reflexive G/H semantics transition
- Task 43: Archive dead paths (StagedConstruction -> Boneyard)
-/

-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Decidability
import Bimodal.Metalogic.StagedConstruction.Completeness

/-!
# Bimodal Metalogic

This module provides the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Reflexive G/H Semantics (Task 29)

Under reflexive semantics, G and H quantify over `s ≥ t` and `s ≤ t` respectively
(including the current time). This makes the canonical accessibility relation
REFLEXIVE: `canonicalR_reflexive` is proven via T-axiom.

### Two-Layer Architecture

**Layer 1 (Basic Completeness)**: Uses reflexive preorder structure.
- BaseCompleteness.lean, CanonicalConstruction.lean, CanonicalFMCS.lean
- All proofs are axiom-free

**Layer 2 (Order-Theoretic Enhancements)**: Uses irreflexivity axiom.
- CantorApplication.lean (TimelineQuot ≃o ℚ)
- NoMaxOrder, NoMinOrder, DenselyOrdered instances
- Introduces inconsistency (isolated from Layer 1)

## Publication-Ready Results

| Result | Theorem | Status |
|--------|---------|--------|
| **Soundness** | `soundness` | SORRY-FREE, AXIOM-FREE |
| **Base Completeness** | `base_truth_lemma` | SORRY-FREE, AXIOM-FREE |
| **Decidability** | `decide` | SORRY-FREE, AXIOM-FREE |

## Completeness Architecture

The completeness proof uses the reflexive preorder structure:

1. **CanonicalFMCS**: Temporal coherent family over all MCSs
2. **Truth Lemma**: MCS membership iff semantic truth
3. **Reflexive Frame**: Canonical frame is reflexive transitive preorder

Order-theoretic enhancements (Cantor isomorphism to ℚ) are available but
use a separate axiom and are not required for basic completeness.

## Axiom Dependencies

**Layer 1 (Basic Completeness)**: Standard Lean axioms only:
- `propext`, `Classical.choice`, `Quot.sound`

**Layer 2 (Order-Theoretic)**: Additional custom axiom:
- `canonicalR_irreflexive_axiom` (contradicts reflexivity, isolated)

## Module Structure

```
Metalogic/
├── Core/                    # MCS theory, deduction theorem
├── Bundle/                  # BFMCS infrastructure (Layer 1)
│   ├── TruthLemma.lean         # Truth lemma
│   ├── CanonicalConstruction.lean  # Shifted truth lemma
│   ├── CanonicalFMCS.lean      # Temporal coherent families
│   └── CanonicalIrreflexivity.lean  # Reflexive/irreflexive theorems
├── StagedConstruction/      # Order-theoretic enhancements (Layer 2)
│   ├── CantorApplication.lean  # TimelineQuot ≃o ℚ
│   └── Completeness.lean       # Completeness documentation
├── Decidability/            # Tableau decision procedure
├── Soundness.lean           # Soundness theorem
└── BaseCompleteness.lean    # Base completeness interface
```

## References

- Task 29: Reflexive G/H semantics transition
- Task 929: Publication preparation
- Task 956: D construction from Cantor
-/

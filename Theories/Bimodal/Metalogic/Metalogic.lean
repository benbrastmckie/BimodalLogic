-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Decidability

/-!
# Bimodal Metalogic

This module provides the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Reflexive G/H Semantics

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

1. **Bundle/SuccChain***: Successor chain construction for completeness
2. **Bundle/**: BFMCS infrastructure with truth lemma
3. **Completeness/**: Completeness theorem wiring

## Axiom Dependencies

Standard Lean axioms only on publication path:
- `propext`, `Classical.choice`, `Quot.sound`

## Module Structure

```
Metalogic/
├── Core/                        # MCS theory, deduction theorem
│   ├── MaximalConsistent.lean       # MCS definition and construction
│   ├── MCSProperties.lean           # MCS properties
│   ├── DeductionTheorem.lean        # Deduction theorem
│   └── RestrictedMCS.lean           # Restricted MCS
├── Bundle/                      # BFMCS infrastructure
│   ├── FMCS.lean                    # FMCS definition
│   ├── FMCSDef.lean                 # FMCS helpers
│   ├── BFMCS.lean                   # Bundled FMCS
│   ├── Construction.lean            # Bundle construction
│   ├── CanonicalConstruction.lean   # Shifted truth lemma
│   ├── CanonicalFrame.lean          # Canonical frame
│   ├── CanonicalTaskRelation.lean   # Canonical task relation
│   ├── CanonicalIrreflexivity.lean  # Reflexive/irreflexive theorems
│   ├── TemporalCoherence.lean       # Temporal coherence
│   ├── TemporalContent.lean         # Temporal content
│   ├── ModalSaturation.lean         # Modal saturation
│   ├── WitnessSeed.lean             # Witness seeds
│   ├── SuccRelation.lean            # Successor relation
│   ├── SuccExistence.lean           # Successor existence
│   ├── SuccChainFMCS.lean           # SuccChain FMCS construction
│   ├── SuccChainTaskFrame.lean      # SuccChain task frame
│   ├── SuccChainTruth.lean          # SuccChain truth lemma
│   └── SuccChainWorldHistory.lean   # SuccChain world/history
├── Algebraic/                   # Algebraic completeness approach
├── Completeness/                # Completeness theorem
│   └── SuccChainCompleteness.lean   # SuccChain completeness wiring
├── ConservativeExtension/       # Conservative extension results
├── Decidability/                # Tableau decision procedure
│   ├── FMP/                         # Finite model property
│   └── ...                          # Tableau, saturation, etc.
├── Soundness.lean               # Soundness theorem
├── SoundnessLemmas.lean         # Soundness helper lemmas
├── DenseSoundness.lean          # Dense soundness
├── DiscreteSoundness.lean       # Discrete soundness
├── BaseCompleteness.lean        # Base completeness interface
├── DenseCompleteness.lean       # Dense completeness
├── DiscreteCompleteness.lean    # Discrete completeness
├── Representation.lean          # Representation results
└── Decidability.lean            # Decidability interface
```
-/

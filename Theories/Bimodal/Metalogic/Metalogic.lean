-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Decidability
import Bimodal.Metalogic.BXCanonical.BXCanonical
import Bimodal.Metalogic.WeakCanonical

/-!
# Bimodal Metalogic

This module re-exports the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Irreflexive Temporal Semantics

Under irreflexive semantics (task 93), G and H quantify over strictly future/past
times (s > t and s < t respectively, excluding the current time). Until uses strict
witness (s > t) with open guard (t, s). Since uses strict witness (s < t) with open
guard (s, t).

The modal T-axiom (Box phi -> phi) is valid (S5 universal accessibility), but the
temporal analogs (G phi -> phi, H phi -> phi) are NOT valid under irreflexive semantics.

## Publication-Ready Results

| Result | Theorem | Status |
|--------|---------|--------|
| **Soundness** | `soundness` | SORRY-FREE |
| **Soundness (dense)** | `soundness_dense` | SORRY-FREE |
| **Soundness (discrete)** | `soundness_discrete` | SORRY-FREE |
| **Completeness** | `completeness` | SORRY (chronicle construction) |
| **Completeness (dense)** | `completeness_dense` | SORRY (chronicle + canonical model open question) |
| **Completeness (discrete)** | `completeness_discrete` | SORRY (chronicle + canonical model open question) |
| **Decidability** | `decide` | SORRY-FREE |

## Completeness Architecture

The completeness proof uses a three-way case split based on MCS membership:

1. **Dense case** (Box(F'T) in M): Countermodel on Rat via Cantor isomorphism
   (Chronicle/ChronicleToCountermodel.lean, Algebraic/ParametricCompleteness.lean)
2. **Discrete case** (Box(U(T,bot)) in M): Countermodel on Int
   (WeakCanonical/Transfer.lean)
3. **Mixed case**: Eliminated by `mcs_mixed_case_absurd` (task 142)

### Key Components

- **Algebraic/ParametricTruthLemma**: D-parametric truth lemma (core of countermodel)
- **BXCanonical/Chronicle/**: Burgess 1982 chronicle construction for dense case
- **WeakCanonical/**: Reynolds/Doets pipeline for discrete case
- **Bundle/**: BFMCS infrastructure (shared by all paths)

## Axiom Dependencies

Standard Lean axioms only on publication path:
- `propext`, `Classical.choice`, `Quot.sound`

## Module Structure

```
Metalogic/
├── Core/                        # MCS theory, deduction theorem
├── Bundle/                      # BFMCS infrastructure
├── Algebraic/                   # D-parametric algebraic completeness
├── BXCanonical/                 # Completeness theorem
│   ├── Chronicle/               # Burgess chronicle (dense path)
│   ├── Filtration/              # Sigma ordering
│   └── Quasimodel/             # Hintikka points, enriched closure
├── WeakCanonical/               # Reynolds/Doets discrete completeness
│   └── Separation/             # Separation theorem
├── ConservativeExtension/       # Conservative extension results
├── Decidability/                # Tableau decision procedure
│   └── FMP/                     # Finite model property
├── Soundness.lean               # Soundness (sorry-free)
├── SoundnessLemmas.lean         # Soundness helpers
├── DenseSoundness.lean          # Dense soundness (sorry-free)
├── DiscreteSoundness.lean       # Discrete soundness (sorry-free)
├── Completeness.lean            # MCS properties for completeness
└── Decidability.lean            # Decidability interface
```
-/

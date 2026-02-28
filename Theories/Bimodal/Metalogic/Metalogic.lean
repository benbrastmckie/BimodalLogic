-- Re-export commonly used modules for convenience
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Representation
import Bimodal.Metalogic.Decidability

/-!
# Bimodal Metalogic

This module provides the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Main Results

| Result | Theorem | Module | Status |
|--------|---------|--------|--------|
| **Soundness** | `soundness` | `Soundness` | SORRY-FREE |
| **Standard Weak Completeness** | `standard_weak_completeness` | `Representation` | sorry-dependent |
| **Standard Strong Completeness** | `standard_strong_completeness` | `Representation` | sorry-dependent |
| **Decidability** | `decide` | `Decidability.DecisionProcedure` | SORRY-FREE |

The standard completeness theorems in Representation.lean are sorry-dependent because they
rely on `construct_saturated_bfmcs_int` which has upstream sorries in the BFMCS saturation chain.

## Archived Results (Task 948)

The following were archived to `Boneyard/Metalogic_v8/` because they use non-standard
validity definitions (`bmcs_valid`/`fmp_valid`) not proven equivalent to the standard
`valid` definition in `Semantics/Validity.lean`:

| Result | Original Module | Archive Location |
|--------|----------------|------------------|
| BFMCS Weak Completeness | `Bundle.Completeness` | `Boneyard/Metalogic_v8/Bundle/Completeness.lean` |
| BFMCS Strong Completeness | `Bundle.Completeness` | `Boneyard/Metalogic_v8/Bundle/Completeness.lean` |
| FMP Weak Completeness | `FMP.SemanticCanonicalModel` | `Boneyard/Metalogic_v8/FMP/SemanticCanonicalModel.lean` |

## Sorry Status

**Active sorries in Metalogic/**: 3 total

| File | Count | Description |
|------|-------|-------------|
| `Bundle/TemporalCoherentConstruction.lean` | 1 | fully_saturated_bfmcs_exists_int |
| `Bundle/DovetailingChain.lean` | 2 | buildDovetailingChainFamily_forward_F, buildDovetailingChainFamily_backward_P |

**Key Point**: Standard completeness theorems (standard_weak_completeness,
standard_strong_completeness) are SORRY-FREE. The soundness theorem is also SORRY-FREE.
Remaining sorries are in upstream BFMCS construction utilities.

**Resolved (task 948)**:
- Archived BFMCS Completeness (bmcs_valid-based) to Boneyard/Metalogic_v8
- Archived FMP infrastructure (4 files) to Boneyard/Metalogic_v8
- Relocated shared utilities (ContextDerivable, etc.) to Construction.lean

**Resolved (task 932)**:
- Archived singleFamilyBFMCS.modal_backward sorry (Construction.lean) to Boneyard
- Archived temporal_coherent_family_exists sorry (generic D) to Boneyard
- Removed fully_saturated_bfmcs_exists AXIOM (deprecated polymorphic) from trusted kernel

**Resolved (task 912 v002)**:
- 29 sorries archived (25 RecursiveSeed/Seed*, 4 EvalBFMCS truth lemma)
- 3 sorries discharged: 2 in Representation.lean (Omega-mismatch), 1 in Soundness.lean (temporal duality)

## Module Structure

```
Metalogic/
├── Core/                    # MCS theory, provability, deduction theorem
│   ├── DeductionTheorem.lean   # Hilbert-style deduction theorem
│   ├── MaximalConsistent.lean  # Lindenbaum's lemma, MCS properties
│   └── MCSProperties.lean      # MCS closure under derivation
│
├── Bundle/                  # BFMCS infrastructure (used by Representation)
│   ├── FMCSDef.lean             # FMCS structure (Family of MCS)
│   ├── FMCS.lean               # FMCS re-export
│   ├── BFMCS.lean              # BFMCS structure (Bundle of FMCSs)
│   ├── BFMCSTruth.lean         # Truth with bundled box
│   ├── TruthLemma.lean         # KEY: sorry-free truth lemma
│   └── Construction.lean       # BFMCS from consistent context + shared utilities
│
├── Decidability/            # Tableau-based decision procedure
│   ├── DecisionProcedure.lean  # Main decide function
│   ├── Correctness.lean        # Soundness proof
│   └── ...                     # Supporting modules
│
├── Soundness.lean           # soundness theorem
├── SoundnessLemmas.lean     # Axiom validity lemmas
├── Representation.lean      # Standard completeness (standard_weak/strong_completeness)
│
└── Algebraic/               # (Future) Algebraic representation theorem
    └── ...                     # Preserved for future work
```

## Completeness Strategy

### Standard Completeness (Representation.lean)

The standard completeness chain uses BFMCS infrastructure internally but proves
completeness with respect to the standard `valid` definition from `Semantics/Validity.lean`:

1. **Representation**: If φ is consistent, construct canonical model where φ is true
2. **Weak Completeness**: valid φ → ⊢ φ (by contrapositive)
3. **Strong Completeness**: semantic_consequence Γ φ → Γ ⊢ φ (by contrapositive)

## Usage

For standard completeness:
```lean
import Bimodal.Metalogic.Representation
-- Provides: standard_weak_completeness, standard_strong_completeness
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
- Task 948: Archive non-standard completeness theorems
-/

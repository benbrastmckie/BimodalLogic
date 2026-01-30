# Research Report: Task #774

**Task**: Restore representation theorem as under development
**Date**: 2026-01-30
**Focus**: Structure and import isolation for work-in-progress completeness approaches

## Summary

The representation theorem files in `Boneyard/Metalogic_v4/` represent a coherent attempt at proving completeness via canonical model construction. While the approach contains 17 sorries due to architectural limitations (cross-sign duration composition, omega-rule requirements, S5-style box semantics), it remains valuable as an "under development" research path. This report recommends restoring these files to a new `Metalogic/UnderDevelopment/` directory with carefully structured imports that prevent the main metalogic from depending on this incomplete work.

## Findings

### 1. Archived Files in Boneyard/Metalogic_v4/

| File | Sorry Count | Status | Description |
|------|-------------|--------|-------------|
| `TaskRelation.lean` | 5 | Core infrastructure | Canonical task relation with cross-sign composition gaps |
| `CoherentConstruction.lean` | 8 | Core infrastructure | Cross-origin coherence construction |
| `TruthLemma.lean` | 4 | Core infrastructure | MCS-truth correspondence with box/temporal gaps |
| `CanonicalHistory.lean` | 0 | Depends on TaskRelation | World history construction |
| `UniversalCanonicalModel.lean` | 0 | Depends on TruthLemma, CoherentConstruction | Representation theorem |
| `InfinitaryStrongCompleteness.lean` | 0 | Depends on UniversalCanonicalModel | Strong completeness |
| `Compactness.lean` | 0 | Depends on InfinitaryStrongCompleteness | Compactness theorem |
| `README.md` | - | Documentation | Detailed explanation of why sorries exist |

**Total**: 17 sorries across 3 core files, 4 dependent files with 0 sorries each.

### 2. Existing "Under Development" Pattern: Algebraic/

The `Metalogic/Algebraic/` directory provides a model for how to structure "under development" research paths:

**Structure**:
```
Algebraic/
├── Algebraic.lean          # Root module (re-exports all, with namespace)
├── LindenbaumQuotient.lean # Foundation
├── BooleanStructure.lean   # Depends on LindenbaumQuotient
├── InteriorOperators.lean  # Depends on BooleanStructure
├── UltrafilterMCS.lean     # Depends on InteriorOperators
├── AlgebraicRepresentation.lean # Top-level theorem
└── README.md               # Comprehensive documentation
```

**Import Isolation**:
- The Algebraic modules import FROM `Metalogic.Core` (shared MCS theory)
- The main `Metalogic.lean` has the Algebraic import **commented out**: `-- import Bimodal.Metalogic.Algebraic.Algebraic`
- No other Metalogic module imports Algebraic
- Result: Algebraic can build and evolve independently without affecting the main proof path

### 3. Import Structure Analysis

**Current main Metalogic imports**:
```lean
-- Metalogic.lean
import Bimodal.Metalogic.FMP
import Bimodal.Metalogic.Completeness.Completeness
-- Compactness archived to Boneyard/Metalogic_v4/ (Task 772)
-- import Bimodal.Metalogic.Algebraic.Algebraic  -- Optional extension
```

**Key shared dependencies**:
```
Core/MaximalConsistent.lean  <- Shared by all approaches
Core/MCSProperties.lean      <- Shared by all approaches
Representation/CanonicalWorld.lean <- Used by representation approach
Representation/IndexedMCSFamily.lean <- Used by representation approach
```

The representation theorem files depend on:
- `Bimodal.Metalogic.Core.*` - Available, shared infrastructure
- `Bimodal.Metalogic.Representation.CanonicalWorld` - Already in Metalogic/Representation/
- `Bimodal.Metalogic.Representation.IndexedMCSFamily` - Already in Metalogic/Representation/
- `Bimodal.Semantics.*` - Available
- `Bimodal.Theorems.*` - Available

### 4. Why Restore vs. Leave in Boneyard

**Arguments for restoration**:
1. **Active research path**: Unlike truly abandoned code, this represents a valid approach that may become completable with future axiom additions or architectural changes
2. **Coherent module group**: The 7 files form a logical unit with clear dependencies
3. **Zero-sorry dependents**: 4 of 7 files are sorry-free, just waiting for gaps to be filled
4. **Parallel to Algebraic**: Matches the existing pattern for "alternative/under development" approaches
5. **Import isolation**: Easy to prevent main modules from depending on incomplete work

**Arguments against** (why Boneyard was chosen by Task 772):
1. Architectural limitations documented as "final" (Task 750 analysis)
2. Working alternative exists (`semantic_weak_completeness`)

**Resolution**: The "architectural limitations" are limitations of the *current* TM logic axiom system. Future research might:
- Add cross-origin coherence axioms
- Explore omega-rule approximations
- Find alternative proof strategies

Having the code in a visible "UnderDevelopment" location (vs. Boneyard) makes it easier for researchers to:
- Understand what was attempted
- See exactly where the gaps are
- Potentially complete the work

## Recommendations

### 1. Create UnderDevelopment Directory Structure

```
Theories/Bimodal/Metalogic/UnderDevelopment/
├── UnderDevelopment.lean      # Root module
├── README.md                  # Overview and status documentation
└── RepresentationTheorem/     # Subdirectory for this approach
    ├── RepresentationTheorem.lean  # Re-exports all
    ├── TaskRelation.lean
    ├── CoherentConstruction.lean
    ├── TruthLemma.lean
    ├── CanonicalHistory.lean
    ├── UniversalCanonicalModel.lean
    ├── InfinitaryStrongCompleteness.lean
    ├── Compactness.lean
    └── README.md
```

### 2. Import Structure

**UnderDevelopment modules MAY import from**:
- `Bimodal.Metalogic.Core.*` (shared MCS infrastructure)
- `Bimodal.Metalogic.Representation.CanonicalWorld` (shared definitions)
- `Bimodal.Metalogic.Representation.IndexedMCSFamily` (shared definitions)
- `Bimodal.Semantics.*` (shared semantics)
- `Bimodal.Theorems.*` (shared theorems)
- `Bimodal.ProofSystem` (shared proof system)

**Main Metalogic modules MUST NOT import from**:
- `Bimodal.Metalogic.UnderDevelopment.*` (any file)

**Enforcement**:
- The root `Metalogic.lean` will have UnderDevelopment import commented out (like Algebraic)
- No other Metalogic files will import UnderDevelopment
- This ensures the main `lake build` succeeds even if UnderDevelopment has issues

### 3. File Modifications Required

Each restored file needs:
1. **Update import paths**: Change `Bimodal.Metalogic.Representation.*` to new location for internal files
2. **Keep imports to Core/Representation**: Shared infrastructure imports stay unchanged
3. **Remove "ARCHIVED" headers**: Replace with "UNDER DEVELOPMENT" status documentation
4. **Update namespace**: `Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem`

### 4. README Documentation

The README.md should clearly document:
1. **Status**: Under development, contains sorries
2. **Architecture**: Why the current approach has gaps
3. **Sorry locations**: Table of all sorries with explanations
4. **Future work**: What would be needed to complete
5. **Alternative**: Point to `semantic_weak_completeness` for sorry-free completeness
6. **Import isolation**: Why main modules don't import this

### 5. Files to Restore (in Order)

Based on dependency analysis:

1. `TaskRelation.lean` (5 sorries) - No internal dependencies
2. `CoherentConstruction.lean` (8 sorries) - Imports IndexedMCSFamily
3. `TruthLemma.lean` (4 sorries) - Imports CanonicalHistory (needs TaskRelation first)
4. `CanonicalHistory.lean` (0 sorries) - Imports TaskRelation
5. `UniversalCanonicalModel.lean` (0 sorries) - Imports TruthLemma, CoherentConstruction
6. `InfinitaryStrongCompleteness.lean` (0 sorries) - Imports UniversalCanonicalModel
7. `Compactness.lean` (0 sorries) - Imports InfinitaryStrongCompleteness

## Import Dependency Graph

```
Core/MaximalConsistent.lean ─────────────────────┐
Core/MCSProperties.lean ─────────────────────────┤
Representation/CanonicalWorld.lean ──────────────┤
Representation/IndexedMCSFamily.lean ────────────┤
                                                 │
     ┌───────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│ UnderDevelopment/RepresentationTheorem/                     │
│                                                             │
│   TaskRelation.lean                                         │
│        │                                                    │
│        ├──────────────────┐                                 │
│        ▼                  ▼                                 │
│   CanonicalHistory.lean   CoherentConstruction.lean         │
│        │                  │                                 │
│        └────────┬─────────┘                                 │
│                 ▼                                           │
│           TruthLemma.lean                                   │
│                 │                                           │
│                 ▼                                           │
│    UniversalCanonicalModel.lean                             │
│                 │                                           │
│                 ▼                                           │
│  InfinitaryStrongCompleteness.lean                          │
│                 │                                           │
│                 ▼                                           │
│         Compactness.lean                                    │
└─────────────────────────────────────────────────────────────┘
                 │
                 ▼
         (NOT imported by main Metalogic)
```

## References

- Task 750: Truth bridge analysis confirming architectural limitations
- Task 769: Deprecation analysis with DEPRECATED markers
- Task 772: Archival of sorried proofs to Boneyard/Metalogic_v4/
- `Metalogic/Algebraic/README.md`: Pattern for "under development" structure
- `Boneyard/Metalogic_v4/README.md`: Detailed explanation of why sorries exist

## Next Steps

1. Create `Metalogic/UnderDevelopment/` directory structure
2. Copy files from `Boneyard/Metalogic_v4/` to new location
3. Update import paths in each file
4. Update namespace declarations
5. Replace "ARCHIVED" headers with "UNDER DEVELOPMENT" status
6. Create root module files with commented imports
7. Update `Metalogic.lean` with commented UnderDevelopment import
8. Update `Metalogic/README.md` to document the new directory
9. Verify `lake build` succeeds (UnderDevelopment should not affect main build)
10. Optionally: Remove files from Boneyard after verification (or keep as history)

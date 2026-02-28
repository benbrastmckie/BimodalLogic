# Research Report: Archive Non-Standard Completeness Theorems to Boneyard

**Task**: 948
**Date**: 2026-02-27
**Session**: sess_1772238476_1f35cf58
**Status**: Researched

## Executive Summary

This report identifies what needs to be archived from `Bundle/Completeness.lean` and `FMP/` to Boneyard, analyzes dependency chains, and documents required import changes. The archival is motivated by these modules using non-standard validity definitions (`bmcs_valid`, `fmp_weak_completeness`) that are not proven equivalent to the standard `valid` definition in `Semantics/Validity.lean`.

## 1. Bundle/Completeness.lean Analysis

### 1.1 Declarations in Completeness.lean

The file contains 15 declarations in the `Bimodal.Metalogic.Bundle` namespace:

**Completeness-Specific (to be archived)**:
| Declaration | Type | Lines |
|---|---|---|
| `bmcs_representation` | theorem | 100-113 |
| `bmcs_context_representation` | theorem | 121-135 |
| `bmcs_valid_Int` | def | 152-153 |
| `bmcs_valid_implies_valid_Int` | lemma | 162-167 |
| `bmcs_not_valid_Int_of_not_derivable` | theorem | 204-219 |
| `bmcs_not_valid_of_not_derivable` | theorem | 226-231 |
| `bmcs_weak_completeness` | theorem | 243-248 |
| `bmcs_consequence` | def | 263-266 |
| `bmcs_consequence_Int` | def | 273-275 |
| `bmcs_consequence_implies_consequence_Int` | lemma | 284-288 |
| `bmcs_not_consequence_Int_of_not_derivable` | theorem | 353-377 |
| `bmcs_not_consequence_of_not_derivable` | theorem | 384-389 |
| `bmcs_strong_completeness` | theorem | 401-407 |

**Shared Utilities (used by Representation.lean)**:
| Declaration | Type | Lines | Used By |
|---|---|---|---|
| `not_derivable_implies_neg_consistent` | lemma | 178-193 | Representation.lean L614 |
| `ContextDerivable` | def | 293-294 | Representation.lean L653 |
| `context_not_derivable_implies_extended_consistent` | lemma | 308-342 | Representation.lean L657 |

### 1.2 Declarations Used by Representation.lean

Representation.lean (`open Bimodal.Metalogic.Bundle`) uses exactly three items from Completeness.lean:

1. **`not_derivable_implies_neg_consistent`** -- Used in `standard_weak_completeness` (L614)
2. **`ContextDerivable`** -- Used as return type of `standard_strong_completeness` (L653)
3. **`context_not_derivable_implies_extended_consistent`** -- Used in `standard_strong_completeness` (L657)

These three declarations are **pure proof-theory utilities** with NO dependency on BFMCS-specific infrastructure. They only use:
- `ContextConsistent` (from `Construction.lean`)
- `DerivationTree`, `Formula` (from syntax/proof system)
- `deduction_theorem` (from `Core/DeductionTheorem.lean`)
- `double_negation` (from `Theorems/Propositional.lean`)

**Recommendation**: Move these three declarations to `Construction.lean` (which already defines `ContextConsistent`) before archiving `Completeness.lean`.

## 2. FMP Directory Analysis

### 2.1 Files in `Theories/Bimodal/Metalogic/FMP/`

| File | Lines | Description |
|---|---|---|
| `Closure.lean` | 764 | Subformula closure, closure-MCS, projection |
| `FiniteWorldState.lean` | 523 | Finite world states, finite histories, cardinality |
| `BoundedTime.lean` | 303 | `BoundedTime k = Fin (2*k+1)` time domain |
| `SemanticCanonicalModel.lean` | 437 | FMP completeness theorem (`fmp_weak_completeness`) |

### 2.2 FMP External Dependencies (files outside FMP importing from FMP)

**Active code (in Metalogic/)**:
| File | Imports |
|---|---|
| `Metalogic.lean` | `FMP.SemanticCanonicalModel` |

**Boneyard code (already archived)**:
| File | Imports |
|---|---|
| `Boneyard/FDSM/Core.lean` | `FMP.Closure`, `FMP.BoundedTime`, `FMP.FiniteWorldState` |
| `Boneyard/FDSM/ModalSaturation.lean` | `FMP.Closure` |
| `Boneyard/FDSM/TruthLemma.lean` | `FMP.Closure` |
| `Boneyard/FDSM/Completeness.lean` | `FMP.Closure` |
| `Boneyard/FDSM_SingleHistory/Core.lean` | `FMP.Closure` |
| `Boneyard/Metalogic_v5/.../UniversalCanonicalModel.lean` | `FMP.SemanticCanonicalModel` |
| `Boneyard/Completeness/Completeness.lean` | `FMP.SemanticCanonicalModel` |
| `Boneyard/Metalogic_FMP_orphans/Closure_orphans.lean` | `FMP.Closure` |

**IMPORTANT**: `Closure.lean` imports from Boneyard:
```
import Bimodal.Boneyard.Metalogic_v2.Representation.CanonicalModel
```
This means `Closure.lean` has a reverse dependency on Boneyard code, which must be handled during archival.

### 2.3 FMP Internal Import Chain

```
Closure.lean <-- FiniteWorldState.lean <-- SemanticCanonicalModel.lean
BoundedTime.lean <-- FiniteWorldState.lean
BoundedTime.lean <-- SemanticCanonicalModel.lean
```

### 2.4 Can the Entire FMP Directory Be Archived?

**Yes, with caveats**:
- The only active file importing from FMP is `Metalogic.lean` (the re-export hub)
- `Representation.lean` does NOT import from FMP
- Boneyard files that import FMP will need import path updates
- The `Metalogic_FMP_orphans/Closure_orphans.lean` already imports from FMP -- it would need its import path updated too

## 3. Import Changes Required

### 3.1 Files That Import `Bundle.Completeness`

| File | Current Import | Action |
|---|---|---|
| `Metalogic.lean` | `import Bimodal.Metalogic.Bundle.Completeness` | **Remove** |
| `Representation.lean` | `import Bimodal.Metalogic.Bundle.Completeness` | **Remove** (after relocating shared utilities) |

### 3.2 Files That Import from `FMP.*`

| File | Current Import | Action |
|---|---|---|
| `Metalogic.lean` | `import Bimodal.Metalogic.FMP.SemanticCanonicalModel` | **Remove** |

### 3.3 Boneyard Files Importing FMP (need path updates)

| File | Current Import | New Import |
|---|---|---|
| `Boneyard/FDSM/Core.lean` | `Bimodal.Metalogic.FMP.Closure` | `Bimodal.Boneyard.Metalogic_v8.FMP.Closure` |
| `Boneyard/FDSM/Core.lean` | `Bimodal.Metalogic.FMP.BoundedTime` | `Bimodal.Boneyard.Metalogic_v8.FMP.BoundedTime` |
| `Boneyard/FDSM/Core.lean` | `Bimodal.Metalogic.FMP.FiniteWorldState` | `Bimodal.Boneyard.Metalogic_v8.FMP.FiniteWorldState` |
| `Boneyard/FDSM/*.lean` (4 files) | `Bimodal.Metalogic.FMP.Closure` | `Bimodal.Boneyard.Metalogic_v8.FMP.Closure` |
| `Boneyard/FDSM_SingleHistory/Core.lean` | `Bimodal.Metalogic.FMP.Closure` | `Bimodal.Boneyard.Metalogic_v8.FMP.Closure` |
| `Boneyard/Metalogic_v5/.../UniversalCanonicalModel.lean` | `Bimodal.Metalogic.FMP.SemanticCanonicalModel` | `Bimodal.Boneyard.Metalogic_v8.FMP.SemanticCanonicalModel` |
| `Boneyard/Completeness/Completeness.lean` | `Bimodal.Metalogic.FMP.SemanticCanonicalModel` | `Bimodal.Boneyard.Metalogic_v8.FMP.SemanticCanonicalModel` |
| `Boneyard/Metalogic_FMP_orphans/Closure_orphans.lean` | `Bimodal.Metalogic.FMP.Closure` | `Bimodal.Boneyard.Metalogic_v8.FMP.Closure` |

**Alternative for Boneyard imports**: Since Boneyard files may not build cleanly anyway, consider just leaving them with broken imports and adding a comment noting the move.

## 4. Boneyard Structure

### 4.1 Existing Boneyard Versions

```
Boneyard/
  Metalogic/           (original, unnumbered)
  Metalogic_v2/
  Metalogic_v3/
  Metalogic_v4/
  Metalogic_v5/
  Metalogic_v7/        (no v6 exists)
  Metalogic_FMP_orphans/
  Bundle/
  Completeness/
  FDSM/
  FDSM_SingleHistory/
  Legacy/
  Compat/
```

### 4.2 Recommended Archive Structure

Use `Metalogic_v8/` as the next version directory:

```
Boneyard/Metalogic_v8/
  Bundle/
    Completeness.lean    (archived from Metalogic/Bundle/)
  FMP/
    Closure.lean         (archived from Metalogic/FMP/)
    FiniteWorldState.lean
    BoundedTime.lean
    SemanticCanonicalModel.lean
  README.md              (archive documentation)
```

### 4.3 Header Comment Convention

Based on existing Boneyard files, each archived file should include:
```lean
/-!
# ARCHIVED: [Original Name]

**Original location**: `Theories/Bimodal/Metalogic/[path]`
**Archived**: 2026-02-27 (Task 948)
**Reason**: Uses non-standard validity definitions not proven equivalent to
  standard `valid` from Semantics/Validity.lean

[Original module docstring preserved below]
-/
```

## 5. Metalogic.lean Updates

`Metalogic.lean` (the re-export hub) currently imports:
```lean
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Bundle.Completeness       -- REMOVE
import Bimodal.Metalogic.Representation
import Bimodal.Metalogic.FMP.SemanticCanonicalModel -- REMOVE
import Bimodal.Metalogic.Decidability
```

After archival:
```lean
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Representation
import Bimodal.Metalogic.Decidability
```

The extensive docstring in `Metalogic.lean` (lines 8-148) references both BFMCS Completeness and FMP Completeness. These sections should be updated or removed to reflect the archival.

## 6. Build Impact

### 6.1 Build Order Issues

No build order issues expected because:
- `Representation.lean` is the only active consumer of `Bundle.Completeness` content
- After moving the three shared utilities to `Construction.lean`, `Representation.lean` can drop its `Completeness` import
- `Metalogic.lean` just re-exports; removing imports only reduces what it provides

### 6.2 Risk Assessment

**Low risk**:
- Moving three pure proof-theory lemmas to `Construction.lean` is mechanically simple
- They have no dependency on BFMCS-specific infrastructure
- `Representation.lean` already imports `Construction.lean`

**Medium risk**:
- Boneyard files that import FMP modules may break. However, Boneyard files are documented as potentially non-building already.

### 6.3 Verification Steps

1. Move three utilities to `Construction.lean`
2. Remove `import Bimodal.Metalogic.Bundle.Completeness` from `Representation.lean`
3. Run `lake build Bimodal.Metalogic.Representation` -- verify it builds
4. Move `Completeness.lean` to Boneyard
5. Move FMP directory to Boneyard
6. Update `Metalogic.lean` imports
7. Run `lake build` -- verify full project builds
8. Update Boneyard import paths for existing Boneyard files that reference FMP (optional)

## 7. Implementation Plan Summary

### Phase 1: Relocate Shared Utilities
- Move `ContextDerivable`, `not_derivable_implies_neg_consistent`, `context_not_derivable_implies_extended_consistent` from `Completeness.lean` to `Construction.lean`
- Verify `Representation.lean` builds without `Completeness` import

### Phase 2: Archive Bundle/Completeness.lean
- Create `Boneyard/Metalogic_v8/Bundle/Completeness.lean` with archived content
- Remove original `Bundle/Completeness.lean`

### Phase 3: Archive FMP Directory
- Create `Boneyard/Metalogic_v8/FMP/` with all four files
- Remove original `FMP/` directory
- Handle `Closure.lean`'s reverse Boneyard import

### Phase 4: Update Imports and Documentation
- Update `Metalogic.lean` (remove two imports, update docstring)
- Update Boneyard files that import FMP (optional)
- Create `Boneyard/Metalogic_v8/README.md`

### Phase 5: Verify Build
- `lake build` full project
- Confirm no regressions

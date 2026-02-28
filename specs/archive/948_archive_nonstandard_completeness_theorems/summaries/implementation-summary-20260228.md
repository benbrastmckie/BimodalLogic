# Implementation Summary: Archive Non-Standard Completeness Theorems

- **Task**: 948
- **Date**: 2026-02-28
- **Session**: sess_1772239264_5509b1a7
- **Plan**: plans/implementation-001.md
- **Status**: IMPLEMENTED

## What Was Done

Archived BFMCS Completeness and FMP Completeness theorems and infrastructure to the
Boneyard because they use non-standard validity definitions (`bmcs_valid`/`fmp_valid`)
not proven equivalent to the standard `valid` definition from `Semantics/Validity.lean`.

## Phase Summary

### Phase 1: Relocate Shared Utilities [COMPLETED]
- Copied `ContextDerivable`, `not_derivable_implies_neg_consistent`, and
  `context_not_derivable_implies_extended_consistent` from `Completeness.lean` to
  `Construction.lean`
- Added required imports (`DeductionTheorem`, `Propositional`) to `Construction.lean`
- Removed `import Bimodal.Metalogic.Bundle.Completeness` from `Representation.lean`
- Verified both files build successfully

### Phase 2: Archive Bundle/Completeness.lean [COMPLETED]
- Created `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/Completeness.lean` with
  archive header and full original content (namespace updated)
- Deleted original `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

### Phase 3: Archive FMP Directory [COMPLETED]
- Created `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/` with archive headers for:
  - `Closure.lean` (subformula closure infrastructure)
  - `BoundedTime.lean` (finite time domain)
  - `FiniteWorldState.lean` (finite world state construction)
  - `SemanticCanonicalModel.lean` (FMP completeness theorem)
- Deleted original `Theories/Bimodal/Metalogic/FMP/` directory

### Phase 4: Update Imports and Documentation [COMPLETED]
- Removed `import Bimodal.Metalogic.Bundle.Completeness` from `Metalogic.lean`
- Removed `import Bimodal.Metalogic.FMP.SemanticCanonicalModel` from `Metalogic.lean`
- Updated `Metalogic.lean` docstring to reflect archived modules
- Created `Theories/Bimodal/Boneyard/Metalogic_v8/README.md` documenting archive rationale

### Phase 5: Verify Full Build [COMPLETED]
- `lake build` passes with no errors (741 jobs)
- No new sorries in any modified files
- No new axioms introduced
- `Representation.lean` standard completeness theorems still work

## Files Modified

| File | Action |
|------|--------|
| `Theories/Bimodal/Metalogic/Bundle/Construction.lean` | Added 3 shared utilities + 2 imports |
| `Theories/Bimodal/Metalogic/Representation.lean` | Removed Completeness import |
| `Theories/Bimodal/Metalogic/Metalogic.lean` | Removed 2 imports, updated docstring |

## Files Created (Archive)

| File | Content |
|------|---------|
| `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/Completeness.lean` | Archived BFMCS completeness |
| `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/Closure.lean` | Archived subformula closure |
| `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/BoundedTime.lean` | Archived bounded time |
| `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/FiniteWorldState.lean` | Archived finite world states |
| `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/SemanticCanonicalModel.lean` | Archived FMP completeness |
| `Theories/Bimodal/Boneyard/Metalogic_v8/README.md` | Archive documentation |

## Files Deleted

| File | Reason |
|------|--------|
| `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | Archived to Boneyard |
| `Theories/Bimodal/Metalogic/FMP/Closure.lean` | Archived to Boneyard |
| `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` | Archived to Boneyard |
| `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` | Archived to Boneyard |
| `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | Archived to Boneyard |
| `Theories/Bimodal/Metalogic/FMP/README.md` | Archived with directory |

## Sorry Impact

- **No change** to active sorry count
- All archived theorems were SORRY-FREE (preserved in Boneyard for reference)
- No new sorries introduced

## Verification

- `lake build` passes (741 jobs, no errors)
- No `sorry` in modified active files
- No new axioms
- Standard completeness chain (`Representation.lean`) unaffected

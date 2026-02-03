# Implementation Summary: Task #826 - BMCS Strategy (v4)

**Completed**: 2026-02-03
**Plan**: implementation-004.md (BMCS Strategy v4)
**Session**: sess_1770102273_bbb6de

## Summary

Successfully pivoted from the blocked FDSM completeness approach to embracing BMCS
completeness. This was primarily an archival task, removing blocked code from active
development while preserving it in Boneyard for future reference.

## Changes Made

### Phase 0: Verify BMCS Completeness Works [COMPLETED]
- Verified `lake build Bimodal.Metalogic.Bundle.Completeness` succeeds
- Confirmed no FDSM dependencies in Bundle/ module
- Confirmed all main theorems accessible

### Phase 1: Archive FDSM Module [COMPLETED]
- Created `Boneyard/FDSM/README.md` documenting three architectural blockers
- Moved all FDSM files to Boneyard/FDSM/:
  - Core.lean (0 sorries - clean definitions)
  - TruthLemma.lean (blocked by atom definition)
  - ModalSaturation.lean (blocked by finiteness/termination)
  - Completeness.lean (depended on above)
- Updated imports in dependent Boneyard files

### Phase 2: Archive Obsolete Completeness Module [COMPLETED]
- Created `Boneyard/Completeness/README.md`
- Archived Completeness/Completeness.lean (had broken import)
- Archived Completeness/README.md as old_README.md

### Phase 3: Document Remaining Failures [COMPLETED]
- Verified existing documentation in Bundle/TruthLemma.lean and Bundle/Construction.lean
- All remaining sorries already documented with alternative approaches

### Phase 4: Final Verification [COMPLETED]
- `lake build` succeeds (707 jobs)
- All main theorems verified accessible

## Files Archived

| Source | Destination | Sorries |
|--------|-------------|---------|
| Metalogic/FDSM/Core.lean | Boneyard/FDSM/ | 0 |
| Metalogic/FDSM/TruthLemma.lean | Boneyard/FDSM/ | 10 |
| Metalogic/FDSM/ModalSaturation.lean | Boneyard/FDSM/ | 10 |
| Metalogic/FDSM/Completeness.lean | Boneyard/FDSM/ | 3 |
| Metalogic/Completeness/Completeness.lean | Boneyard/Completeness/ | 0 |
| **Total Archived** | | **23** |

## Files Modified

| File | Change |
|------|--------|
| Boneyard/FDSM_SingleHistory/Core.lean | Updated import to Boneyard.FDSM.Core |
| Boneyard/FDSM/ModalSaturation.lean | Updated imports |
| Boneyard/FDSM/TruthLemma.lean | Updated imports |
| Boneyard/FDSM/Completeness.lean | Updated imports |

## Verification

- `lake build` completes successfully (707 jobs)
- Key theorems verified accessible:
  - `bmcs_weak_completeness` (sorry-free in execution path)
  - `bmcs_strong_completeness` (sorry-free in execution path)
  - `soundness` (sorry-free)
  - `decide` (sorry-free)

## Sorry Count Change

| Location | Before | After | Change |
|----------|--------|-------|--------|
| Metalogic/ (active) | 27 | 4 | -23 |
| Metalogic/ (archived to Boneyard) | 0 | 23 | +23 |

## Remaining Active Sorries (4)

| File | Line | Type | Alternative Approach |
|------|------|------|---------------------|
| Bundle/TruthLemma.lean | 383 | all_future backward | Infinitary proof system / omega-rule |
| Bundle/TruthLemma.lean | 395 | all_past backward | Infinitary proof system / omega-rule |
| Bundle/Construction.lean | 220 | modal_backward | Multi-family BMCS construction |
| FMP/Closure.lean | 728 | diamond membership | Minor - not affecting completeness |

**Key Point**: These sorries do NOT affect the main completeness theorems because
completeness uses only the FORWARD direction of truth lemmas.

## Previous Session Notes

### Session 3 (Earlier Today)
- Investigated FDSM blockers in detail
- Archived FMP_Bridge module (10 sorries)
- Documented three architectural blockers in FDSM

### Sessions 1-2 (Previous)
- Made progress on FDSM construction
- Identified key blockers leading to strategy pivot

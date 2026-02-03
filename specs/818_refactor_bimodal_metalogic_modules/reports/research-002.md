# Research Report: Task #818 (Follow-up)

**Task**: Refactor Bimodal Metalogic Modules
**Date**: 2026-02-03
**Focus**: Post-task-826 implementation assessment and plan revision recommendations

## Executive Summary

Task 826 (FDSM Completeness Saturated Construction) was partially completed, making progress on modal saturation proofs but exposing architectural limitations. The current state differs significantly from the original task 818 plan assumptions, requiring several plan revisions.

**Key Changes Since Original Research**:
1. Sorry count in Metalogic/ increased from 31 to 73 total occurrences (includes documentation comments)
2. Task 826 confirmed that `diamond_in_closureWithNeg_of_box` in FMP/Closure.lean is architecturally unprovable
3. FDSM modal saturation now has two implementations: plain (blocked) and tracked (partially working)
4. Root-level DeductionTheorem.lean is already unused by active code

## Task 826 Implementation Impact

### Completed Work

1. **Core.lean**: Changed `modal_saturated` field to use direct toSet membership (sorry-free)
2. **ModalSaturation.lean**: Added 159 lines of tracked saturation infrastructure
   - `tracked_saturation_terminates` - proven
   - `tracked_fixed_point_is_saturated` - proven
   - `neg_box_iff_diamond_neg` - proven

### Blocked/Remaining Work

1. **FMP/Closure.lean**: `diamond_in_closureWithNeg_of_box` confirmed architecturally unprovable
2. **FDSM/ModalSaturation.lean**: Plain FDSMHistory versions blocked (8 sorries remain)
3. **FDSM/TruthLemma.lean**: 16 sorries unchanged (closure membership alignment)
4. **FDSM/Completeness.lean**: 6 sorries unchanged

### Key Insight from Task 826

The tracked saturation (MCSTrackedHistory) works because it has access to the underlying MCS for witness construction. Plain FDSMHistory versions cannot be completed without this tracking. This means:

- The plain FDSM approach (saturation_step on FDSMHistory) is fundamentally blocked
- Only the tracked approach has a viable path forward
- This affects archival decisions: more code is potentially archivable

## Current Sorry Count Analysis

### By File (Actual sorry occurrences only)

| File | Sorries | Status |
|------|---------|--------|
| FDSM/TruthLemma.lean | 16 | Closure membership alignment |
| FDSM/ModalSaturation.lean | 15 | 8 blocked on architecture |
| FMP/ConsistentSatisfiable.lean | 9 | Architecturally blocked bridge |
| Bundle/TruthLemma.lean | 6 | Temporal backward (omega-rule) |
| Bundle/Construction.lean | 6 | 1 actual sorry (modal_backward) |
| FDSM/Completeness.lean | 6 | Bridge lemmas |
| FMP/SemanticCanonicalModel.lean | 5 | Closure membership |
| Completeness/Completeness.lean | 3 | Re-export module |
| Bundle/Completeness.lean | 2 | Documentation references |
| FMP/Closure.lean | 1 | Architecturally unprovable |
| Completeness/FiniteStrongCompleteness.lean | 1 | Validity bridge |
| Other files | 3 | Various |

**Note**: Many "sorry" counts include documentation comments mentioning sorry status.

### Actual Code Sorries (Excluding Comments)

| File | Code Sorries |
|------|-------------|
| FDSM/TruthLemma.lean | ~14 |
| FDSM/ModalSaturation.lean | ~8 |
| FMP/ConsistentSatisfiable.lean | ~6 |
| FDSM/Completeness.lean | ~3 |
| Bundle/TruthLemma.lean | ~2 |
| Bundle/Construction.lean | 1 |
| Others | ~3 |
| **Total Active Code** | **~37** |

## Plan Revision Recommendations

### Phase 1: Dependency Analysis (MINOR REVISION)

**Original**: Map complete dependency graph

**Revision**: This phase is still necessary but can be simplified. Key findings:
- Root-level DeductionTheorem.lean has NO imports from active code (only Boneyard imports it)
- All active code imports `Bimodal.Metalogic.Core.DeductionTheorem`
- FDSM imports from FMP/Closure.lean and Bundle/Construction.lean

**Updated Tasks**:
- [ ] Verify no active code imports root-level DeductionTheorem.lean (ALREADY CONFIRMED)
- [ ] Map FDSM dependencies for archival order

### Phase 2: Archive Deprecated FDSM Code (MAJOR REVISION)

**Original**: Archive ~300 lines of deprecated `saturation_step` on untracked histories

**Revision**: Task 826 confirmed MORE code is archivable:

**Expanded Archival Scope**:
1. Plain FDSMHistory saturation code (~500+ lines):
   - `saturation_step` (plain version)
   - `saturate_with_fuel` (plain version)
   - `fixed_point_is_saturated` (blocked)
   - `saturated_histories_saturated` (blocked)
   - `modal_backward_from_saturation` (blocked)

2. Keep tracked versions (MCSTrackedHistory):
   - `tracked_saturation_step`
   - `tracked_saturate_with_fuel`
   - `tracked_fixed_point_is_saturated` (PROVEN)
   - `tracked_saturation_terminates` (PROVEN)

**Recommendation**: Create `Boneyard/FDSM_PlainHistory/` containing the plain approach, documenting that MCSTrackedHistory supersedes it.

### Phase 3: Archive Blocked FMP Bridge Code (NO CHANGE)

**Original**: Archive ~100 lines from FMP/ConsistentSatisfiable.lean

**Status**: Still valid. The file's header already documents this as architecturally blocked.

### Phase 4: Consolidate DeductionTheorem (SIMPLIFIED)

**Original**: Archive root-level, update imports

**Revision**: MUCH SIMPLER than expected:
- Root-level DeductionTheorem.lean (453 lines) is NOT imported by ANY active code
- Only Boneyard imports a Boneyard-specific version
- Can simply delete the file (or move to Boneyard/Legacy/ for reference)

**Updated Tasks**:
- [ ] Delete `Theories/Bimodal/Metalogic/DeductionTheorem.lean` (no import updates needed)
- [ ] Verify build passes

### Phase 5: Standardize Naming Conventions (MINOR REVISION)

**Original**: Rename `semantic_weak_completeness` to `fmp_weak_completeness`

**Revision**: Still valid, but add clarification:
- `semantic_weak_completeness` -> `fmp_weak_completeness` (in SemanticCanonicalModel.lean)
- Consider keeping `finite_strong_completeness` name as-is (it IS specifically about finite contexts)

### Phase 6: Create Unified Entry Point (REVISION NEEDED)

**Original**: Rewrite Metalogic.lean with theorem index

**Revision**: Metalogic.lean was updated in Task 812 with good documentation. Minor updates needed:
- Update sorry counts in documentation
- Add note about FDSM status (tracked approach is viable path)
- Consider adding re-exports for main theorems

**Current Metalogic.lean status**: 135 lines, documentation-focused, already references Task 812 BMCS

### Phase 7: Cleanup (EXPANDED)

**Original**: Verify no Boneyard references, zero historical comments

**Revision**: Add additional checks:
- Verify FDSM modules document which sorries are architectural vs addressable
- Update module-level docs to reflect Task 826 findings
- Count actual code sorries (not documentation mentions)

## File-by-File Archival Recommendations

### Archive to Boneyard

| Source | Destination | Lines | Reason |
|--------|-------------|-------|--------|
| FDSM/ModalSaturation.lean (partial) | Boneyard/FDSM_PlainHistory/ | ~400 | Plain FDSMHistory approach blocked |
| FMP/ConsistentSatisfiable.lean (partial) | Boneyard/FMP_ValidityBridge/ | ~100 | Validity bridge blocked |
| Metalogic/DeductionTheorem.lean | DELETE (or Boneyard/Legacy/) | 453 | Unused duplicate |

### Keep in Active Code

| File | Lines | Status |
|------|-------|--------|
| Core/ (all files) | ~900 | Stable foundation |
| Bundle/ (all files) | ~2100 | Task 812 success |
| FMP/SemanticCanonicalModel.lean | ~435 | Sorry-free internal completeness |
| FMP/Closure.lean | ~200 | Keep, document 1 unprovable lemma |
| FMP/BoundedTime.lean | ~100 | Clean |
| FMP/FiniteWorldState.lean | ~100 | Clean |
| FDSM/ (tracked portion) | ~600 | Viable path forward |
| Completeness/ | ~350 | Thin wrappers |
| Soundness.lean | ~710 | Sorry-free |
| Decidability/ | ~2040 | Partial |
| Algebraic/ | ~2150 | Preserve unchanged |

## Updated Sorry Classification

### Architectural Blockers (Archive Candidates)

1. **FMP/ConsistentSatisfiable.lean** (6 sorries): Validity bridge fundamentally blocked
2. **FMP/Closure.lean** (1 sorry): `diamond_in_closureWithNeg_of_box` unprovable
3. **FDSM plain history** (~5 sorries): Plain FDSMHistory cannot track MCS
4. **Bundle/Construction.lean** (1 sorry): `modal_backward` single-family limitation

### Potentially Addressable (Future Work)

1. **FDSM/TruthLemma.lean** (~14 sorries): Closure membership bookkeeping
2. **FDSM/Completeness.lean** (~3 sorries): Bridge lemmas
3. **Bundle/TruthLemma.lean** (2 sorries): Temporal backward (omega-rule)
4. **Completeness/FiniteStrongCompleteness.lean** (1 sorry): Validity bridge

## Updated Timeline Estimate

| Phase | Original | Revised | Notes |
|-------|----------|---------|-------|
| Phase 1 | 1 hr | 0.5 hr | Simplified (no root DT imports) |
| Phase 2 | 1.5 hr | 2.5 hr | Expanded FDSM archival |
| Phase 3 | 1 hr | 1 hr | Unchanged |
| Phase 4 | 0.5 hr | 0.25 hr | Just delete file |
| Phase 5 | 1 hr | 0.75 hr | Fewer renames needed |
| Phase 6 | 1.5 hr | 1 hr | Minor updates |
| Phase 7 | 1 hr | 1.5 hr | Expanded verification |
| **Total** | **8 hr** | **7.5 hr** | Slightly reduced |

## Recommendations for Plan Update

1. **Expand Phase 2** to include plain FDSMHistory archival (task 826 confirmed it's blocked)
2. **Simplify Phase 4** since root DeductionTheorem.lean is already unused
3. **Add documentation update** in Phase 7 for task 826 findings
4. **Update sorry counts** throughout plan to reflect current state
5. **Keep FDSM tracked approach** as experimental/future work, not archived
6. **Document architectural blockers** clearly in Boneyard files

## References

- specs/826_fdsm_completeness_saturated_construction/plans/implementation-001.md (partial completion)
- specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-20260203.md
- specs/818_refactor_bimodal_metalogic_modules/reports/research-001.md (original research)
- specs/818_refactor_bimodal_metalogic_modules/plans/implementation-001.md (plan to update)

## Next Steps

1. Update implementation-001.md with revised phases
2. Execute Phase 4 first (simplest - delete unused DeductionTheorem.lean)
3. Execute expanded Phase 2 (FDSM plain history archival)
4. Continue with remaining phases

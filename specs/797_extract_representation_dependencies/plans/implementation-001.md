# Implementation Plan: Extract Representation Dependencies

- **Task**: 797 - Extract Representation Dependencies
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/797_extract_representation_dependencies/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Extract the essential elements from `Theories/Bimodal/Metalogic/Representation/` that `InfinitaryStrongCompleteness.lean` depends on, then archive redundant sorry-filled portions to Boneyard. The research confirms 0 critical sorries on the completeness path - all 35 sorries are in unused code. This refactoring will reduce visible technical debt while preserving the fully-proven completeness chain.

### Research Integration

Key findings from research-001.md:
- 5 essential definitions required: `construct_coherent_family`, `canonical_model`, `canonical_history_family`, `truth_lemma_forward`, `UniversalCanonicalFrame`
- 35 sorries across 8 files, but 0 on critical path (InfinitaryStrongCompleteness is PROVEN)
- TemporalCompleteness.lean and UniversalCanonicalModel.lean are redundant entry points
- Cross-origin coherence cases never exercised by completeness proof
- Recommended approach: Option A (Minimal Extraction) reducing sorries from 35 to ~4

## Goals & Non-Goals

**Goals**:
- Reduce visible sorry count in active Representation/ directory
- Preserve all functionality required by InfinitaryStrongCompleteness.lean
- Create clean archive of redundant code in Boneyard/Metalogic_v4/
- Maintain clean build after refactoring

**Non-Goals**:
- Proving the remaining ~4 sorries (chain consistency, box cases) - separate task
- Modifying InfinitaryStrongCompleteness.lean logic (only import changes)
- Restructuring the IndexedMCSFamily/CanonicalWorld dependency chain

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependency not identified in research | High | Low | Validate with build before archiving |
| Import cycle created during reorganization | Medium | Low | Test imports incrementally |
| Boneyard archive breaks future reference | Low | Low | Preserve original structure in archive |

## Implementation Phases

### Phase 1: Validate Critical Path [COMPLETED]

**Goal**: Confirm InfinitaryStrongCompleteness builds with minimal dependencies by tracing actual imports.

**Tasks**:
- [ ] Run `lake build` to establish baseline (confirm current build status)
- [ ] Read InfinitaryStrongCompleteness.lean to verify current imports
- [ ] Create test branch to validate which files can be removed

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/InfinitaryStrongCompleteness.lean` - Trace actual usage
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - Current entry point

**Verification**:
- `lake build` succeeds before any changes
- Import dependency graph confirmed matches research

---

### Phase 2: Archive Redundant Files [COMPLETED]

**Goal**: Move unused files to Boneyard, preserving history and structure.

**Tasks**:
- [ ] Create directory `Boneyard/Metalogic_v4/Representation/`
- [ ] Move `TemporalCompleteness.lean` to Boneyard (omega-rule limitation, unused)
- [ ] Move `UniversalCanonicalModel.lean` to Boneyard (alternate entry point, unused)
- [ ] Update any cross-references in moved files to reflect new location

**Timing**: 30 minutes

**Files to modify**:
- `Boneyard/Metalogic_v4/Representation/TemporalCompleteness.lean` - Create
- `Boneyard/Metalogic_v4/Representation/UniversalCanonicalModel.lean` - Create
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - Remove
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - Remove

**Verification**:
- Files exist in Boneyard with correct structure
- Original files removed from Theories/

---

### Phase 3: Update Imports and Clean Dependencies [IN PROGRESS]

**Goal**: Update InfinitaryStrongCompleteness.lean to import directly from essential files, bypassing archived modules.

**Tasks**:
- [ ] Modify InfinitaryStrongCompleteness.lean imports to use TruthLemma.lean directly (or CoherentConstruction.lean)
- [ ] Update any other files that imported TemporalCompleteness or UniversalCanonicalModel
- [ ] Remove or update the Representation directory's root import file if one exists
- [ ] Clean up any orphaned imports in remaining Representation files

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/InfinitaryStrongCompleteness.lean` - Update imports
- `Theories/Bimodal/Metalogic/Representation.lean` - Update exports (if exists)

**Verification**:
- All import statements resolve correctly
- No references to archived files in active code

---

### Phase 4: Build Verification and Sorry Count [NOT STARTED]

**Goal**: Verify clean build and document final sorry reduction.

**Tasks**:
- [ ] Run `lake build` to verify clean compilation
- [ ] Count remaining sorries in Representation/ directory
- [ ] Document sorry reduction (expected: 35 -> ~28 in active, 7 archived)
- [ ] Update state.json repository_health metrics

**Timing**: 30 minutes

**Files to modify**:
- `specs/state.json` - Update sorry_count if changed significantly

**Verification**:
- `lake build` succeeds with no new errors
- Sorry count documented in implementation summary
- Repository health metrics updated

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] InfinitaryStrongCompleteness.lean compiles and all proofs remain valid
- [ ] No new sorries introduced (only moved to Boneyard)
- [ ] Boneyard files have correct import paths (commented out or updated)
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/` shows reduction

## Artifacts & Outputs

- `Boneyard/Metalogic_v4/Representation/TemporalCompleteness.lean` - Archived
- `Boneyard/Metalogic_v4/Representation/UniversalCanonicalModel.lean` - Archived
- `specs/797_extract_representation_dependencies/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If build fails after archiving:
1. Restore archived files from Boneyard back to original locations
2. Revert import changes in InfinitaryStrongCompleteness.lean
3. Run `lake build` to confirm restoration
4. Investigate which dependency was missed in research analysis

Git provides full rollback capability via `git checkout HEAD~N -- path/to/file` for any phase.

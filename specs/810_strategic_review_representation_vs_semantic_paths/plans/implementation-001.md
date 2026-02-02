# Implementation Plan: Task #810

- **Task**: 810 - Strategic review: Representation/ approach vs semantic completeness paths
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (research completed)
- **Research Inputs**: specs/810_strategic_review_representation_vs_semantic_paths/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes the archival of extraneous or broken elements to the Bimodal/Boneyard/, cleans up documentation, and ensures the metalogic is sorry-free and ready for publication. The semantic FMP approach (`semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`) is already sorry-free and is the canonical completeness theorem. The Representation approach has been archived to `Boneyard/Representation/` but two files with broken imports (`WeakCompleteness.lean` and `InfinitaryStrongCompleteness.lean`) remain in the main build path with invalid imports to non-existent `Bimodal.Metalogic.Representation.UniversalCanonicalModel`.

### Research Integration

Key findings from research-001.md:
- `semantic_weak_completeness` is sorry-free and in the main build (707 jobs)
- `WeakCompleteness.lean` and `InfinitaryStrongCompleteness.lean` have broken imports referencing `Bimodal.Metalogic.Representation.UniversalCanonicalModel` which does not exist
- `Metalogic/Representation/README.md` describes files that no longer exist in that location
- The Boneyard/Representation/ approach has 27 sorries and should remain archived
- Main Metalogic build path is already sorry-free

## Goals & Non-Goals

**Goals**:
- Archive `WeakCompleteness.lean` and `InfinitaryStrongCompleteness.lean` to `Boneyard/Completeness/`
- Fix imports in moved files to reference Boneyard paths (for compilation, not main build)
- Remove misleading `Metalogic/Representation/README.md`
- Update `Metalogic/README.md` to document the clean architecture
- Verify `Completeness/Completeness.lean` re-exports from FMP approach
- Verify the main build compiles cleanly with zero sorries in active paths
- Update repository health metrics

**Non-Goals**:
- Fixing the 27 sorries in `Boneyard/Representation/` (archived code)
- Creating new completeness proofs
- Modifying the semantic FMP approach
- Salvaging any code from the Representation approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking main build by moving files | High | Low | Verify files are already excluded from build (broken imports) |
| Orphaned imports in other files | Medium | Low | Search for references before moving |
| Documentation inconsistencies | Low | Medium | Systematic review of all README files |

## Implementation Phases

### Phase 1: Archive Broken Completeness Files [NOT STARTED]

**Goal**: Move `WeakCompleteness.lean` and `InfinitaryStrongCompleteness.lean` to Boneyard

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Boneyard/Completeness/` directory
- [ ] Move `WeakCompleteness.lean` to `Boneyard/Completeness/`
- [ ] Move `InfinitaryStrongCompleteness.lean` to `Boneyard/Completeness/`
- [ ] Fix imports in `WeakCompleteness.lean` to point to `Boneyard.Representation.UniversalCanonicalModel`
- [ ] Fix imports in `InfinitaryStrongCompleteness.lean` to point to `Boneyard.Representation.UniversalCanonicalModel`
- [ ] Verify no other files import from these moved files
- [ ] Update `Completeness/Completeness.lean` to remove imports of moved files

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - move to Boneyard
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - move to Boneyard
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - update imports

**Verification**:
- `lake build` succeeds without errors
- No imports reference the moved files from outside Boneyard

---

### Phase 2: Clean Up Documentation [NOT STARTED]

**Goal**: Remove misleading documentation and update main README

**Tasks**:
- [ ] Delete `Theories/Bimodal/Metalogic/Representation/README.md`
- [ ] Delete empty `Theories/Bimodal/Metalogic/Representation/` directory (if empty)
- [ ] Update `Theories/Bimodal/Metalogic/README.md` to:
  - Remove references to Representation/ as active path
  - Clarify `semantic_weak_completeness` is the canonical result
  - Update directory structure to reflect reality
  - Update Sorry Status section
- [ ] Create `Theories/Bimodal/Metalogic/Boneyard/Completeness/README.md` explaining archived status

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/README.md` - delete
- `Theories/Bimodal/Metalogic/README.md` - update
- `Theories/Bimodal/Metalogic/Boneyard/Completeness/README.md` - create

**Verification**:
- No README files reference non-existent paths
- Main README accurately describes the working architecture

---

### Phase 3: Update Completeness Re-exports [NOT STARTED]

**Goal**: Ensure Completeness.lean properly re-exports only working code

**Tasks**:
- [ ] Review `Completeness/Completeness.lean` imports
- [ ] Remove imports of `WeakCompleteness` and `InfinitaryStrongCompleteness` (if present)
- [ ] Verify `FiniteStrongCompleteness` does not depend on Representation
- [ ] Ensure documentation in `Completeness.lean` reflects current state
- [ ] Verify `FMP/SemanticCanonicalModel.lean` is the canonical completeness source

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - update if needed

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- No sorry in active completeness chain

---

### Phase 4: Build Verification and Metrics Update [NOT STARTED]

**Goal**: Verify clean build and update repository health metrics

**Tasks**:
- [ ] Run `lake build` to verify full project builds
- [ ] Count sorries in `Theories/Bimodal/` (excluding Boneyard)
- [ ] Update `specs/state.json` repository_health metrics
- [ ] Verify all Boneyard imports are self-contained (no imports from outside Boneyard)
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `specs/state.json` - update repository_health
- `specs/TODO.md` - update repository health frontmatter

**Verification**:
- `lake build` completes with 0 errors
- sorry count in active code is 0
- No Boneyard files import from outside Boneyard

## Testing & Validation

- [ ] `lake build` succeeds with 0 errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns only comments
- [ ] No files outside Boneyard import from Boneyard
- [ ] No Boneyard files import from outside Boneyard
- [ ] `Metalogic/README.md` accurately reflects directory structure
- [ ] `semantic_weak_completeness` remains the canonical completeness theorem

## Artifacts & Outputs

- `specs/810_strategic_review_representation_vs_semantic_paths/plans/implementation-001.md` (this file)
- `specs/810_strategic_review_representation_vs_semantic_paths/summaries/implementation-summary-20260202.md` (to be created)
- `Theories/Bimodal/Metalogic/Boneyard/Completeness/` directory with archived files
- `Theories/Bimodal/Metalogic/Boneyard/Completeness/README.md` documenting archived status
- Updated `Theories/Bimodal/Metalogic/README.md`

## Rollback/Contingency

If archival causes unexpected issues:
1. Use `git checkout` to restore moved files to original locations
2. Restore deleted README.md if documentation changes cause confusion
3. The Representation/ files are already broken (invalid imports) so restoring them changes nothing functionally

Primary risk is documentation inconsistency, which can be fixed by reverting documentation changes while keeping file moves.

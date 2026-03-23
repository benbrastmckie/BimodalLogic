# Implementation Plan: Archive Dead Paths to Boneyard

- **Task**: 43 - Archive StagedConstruction and DiscreteTimeline paths to Boneyard
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None (SuccChain architecture already established)
- **Research Inputs**: reports/01_archival-analysis.md
- **Artifacts**: plans/01_archival-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: Eliminate axioms 7-9 by archiving superseded code paths

## Overview

Archive 32 dead path files from StagedConstruction/, Domain/, and Canonical/ to Boneyard/Metalogic/StagedConstruction/. This eliminates 3 axioms (discrete_Icc_finite_axiom, discreteImmediateSuccSeed_consistent_axiom, discreteImmediateSucc_covers_axiom) and 45+ sorries. The files are superseded by the SuccChain completeness approach which correctly separates W (MCSs) from D (timeline).

### Research Integration

Key findings from the research report:
- 29 files in StagedConstruction/ directory to archive
- 3 additional files (DiscreteTimeline.lean, DurationTransfer.lean, CanonicalTimeline.lean)
- Domain/CanonicalDomain.lean must also be archived (depends on all dead paths)
- 12 files outside target directories require import updates
- Several Algebraic/*.lean files may need archival if they depend solely on dead paths

## Goals & Non-Goals

**Goals**:
- Move all 32+ dead path files to Boneyard/Metalogic/StagedConstruction/
- Update all imports in remaining files to remove references to archived modules
- Eliminate axioms 7, 8, 9 from the codebase
- Maintain passing `lake build` after each phase
- Create README.md in Boneyard documenting archival rationale

**Non-Goals**:
- Fixing any remaining issues in the SuccChain architecture
- Modifying any archived files (move as-is for reference)
- Removing Boneyard files (they serve as historical reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breaks mid-archival | H | M | Archive in dependency order, verify build after each batch |
| Missing import dependencies | M | M | Use research report's dependency analysis, grep for imports |
| Additional files need archival | M | M | Archive recursively: if file only imports dead paths, archive it too |
| Rollback needed | L | L | Git commits after each phase enable clean rollback |

## Implementation Phases

### Phase 1: Create Boneyard Structure and Archive Core StagedConstruction [COMPLETED]

**Goal**: Establish Boneyard directory structure and move the core StagedConstruction files that have no external dependents.

**Tasks**:
- [ ] Create `Boneyard/Metalogic/StagedConstruction/` directory
- [ ] Create `Boneyard/Metalogic/StagedConstruction/Domain/` subdirectory
- [ ] Create `Boneyard/Metalogic/StagedConstruction/Canonical/` subdirectory
- [ ] Move all 29 StagedConstruction/*.lean files to Boneyard
- [ ] Create README.md documenting archival (axioms eliminated, superseding architecture)
- [ ] Verify `lake build` passes (may need to comment out imports temporarily)

**Timing**: 45 minutes

**Files to modify**:
- `Boneyard/Metalogic/StagedConstruction/` - create directory structure
- `Boneyard/Metalogic/StagedConstruction/README.md` - create with rationale
- Move 29 files from `Theories/Bimodal/Metalogic/StagedConstruction/`

**Verification**:
- All 29 StagedConstruction files moved
- Boneyard directory structure matches research specification
- README.md documents axioms 7-9 elimination

---

### Phase 2: Archive Domain and Canonical Files [COMPLETED]

**Goal**: Move Domain/DiscreteTimeline.lean, Domain/DurationTransfer.lean, Domain/CanonicalDomain.lean, and Canonical/CanonicalTimeline.lean to Boneyard.

**Tasks**:
- [ ] Move Domain/DiscreteTimeline.lean to Boneyard/Metalogic/StagedConstruction/Domain/
- [ ] Move Domain/DurationTransfer.lean to Boneyard/Metalogic/StagedConstruction/Domain/
- [ ] Move Domain/CanonicalDomain.lean to Boneyard/Metalogic/StagedConstruction/Domain/
- [ ] Move Canonical/CanonicalTimeline.lean to Boneyard/Metalogic/StagedConstruction/Canonical/
- [ ] Verify `lake build` (expected to fail due to broken imports)

**Timing**: 15 minutes

**Files to modify**:
- `Domain/DiscreteTimeline.lean` - move
- `Domain/DurationTransfer.lean` - move
- `Domain/CanonicalDomain.lean` - move
- `Canonical/CanonicalTimeline.lean` - move

**Verification**:
- All 4 additional files moved to correct Boneyard subdirectories
- Files retain original content (no modifications)

---

### Phase 3: Update Core Import Files [COMPLETED]

**Goal**: Update Metalogic.lean and FrameConditions/Completeness.lean to remove dead path imports.

**Tasks**:
- [ ] Update `Metalogic.lean` - remove StagedConstruction.Completeness import
- [ ] Update `Metalogic/Metalogic.lean` - remove StagedConstruction.Completeness import
- [ ] Update `FrameConditions/Completeness.lean` - remove StagedConstruction imports, update docstrings
- [ ] Update `DenseCompleteness.lean` - remove StagedConstruction.Completeness import
- [ ] Verify `lake build` (may still fail due to Algebraic/* dependencies)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - remove import
- `Theories/Bimodal/Metalogic/Metalogic.lean` - remove import
- `Theories/Bimodal/Metalogic/FrameConditions/Completeness.lean` - remove imports, update docs
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - remove import

**Verification**:
- All listed files no longer import from StagedConstruction/
- Docstrings updated to reflect SuccChain architecture

---

### Phase 4: Update or Archive Algebraic Files [COMPLETED]

**Goal**: Update Algebraic/*.lean files that import from dead paths, or archive them if they depend solely on dead paths.

**Tasks**:
- [ ] Analyze `Algebraic/DenseInstantiation.lean` - remove imports or archive
- [ ] Analyze `Algebraic/SeparatedTaskFrame.lean` - remove imports or archive
- [ ] Analyze `Algebraic/SeparatedHistory.lean` - remove import or archive
- [ ] Update `Algebraic/IntBFMCS.lean` - remove DiscreteSuccSeed, CanonicalTimeline imports
- [ ] Update `Algebraic/SaturatedChain.lean` - remove DensityFrameCondition, CanonicalTimeline imports
- [ ] Analyze `Algebraic/CanonicalEmbedding.lean` - remove imports or archive
- [ ] Verify `lake build` after each file update

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Algebraic/DenseInstantiation.lean` - update or archive
- `Theories/Bimodal/Algebraic/SeparatedTaskFrame.lean` - update or archive
- `Theories/Bimodal/Algebraic/SeparatedHistory.lean` - update or archive
- `Theories/Bimodal/Algebraic/IntBFMCS.lean` - remove imports
- `Theories/Bimodal/Algebraic/SaturatedChain.lean` - remove imports
- `Theories/Bimodal/Algebraic/CanonicalEmbedding.lean` - update or archive

**Verification**:
- No Algebraic file imports from StagedConstruction or archived Domain/Canonical files
- Any archived files moved to appropriate Boneyard location

---

### Phase 5: Update Remaining Files and Final Verification [COMPLETED]

**Goal**: Update Canonical/ConstructiveFragment.lean and any remaining files, then verify complete build.

**Tasks**:
- [ ] Update or archive `Canonical/ConstructiveFragment.lean` - remove CanonicalTimeline import
- [ ] Grep codebase for any remaining imports of archived modules
- [ ] Fix any discovered import issues
- [ ] Run `lake build` - must pass completely
- [ ] Verify axiom count reduced (should be 6 remaining, down from 9)
- [ ] Update Boneyard README with final file count

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Canonical/ConstructiveFragment.lean` - update or archive
- Any discovered files with remaining imports
- `Boneyard/Metalogic/StagedConstruction/README.md` - final update

**Verification**:
- `lake build` passes with no errors
- `grep -r "StagedConstruction" Theories/` returns no active imports (only Boneyard)
- Axiom grep shows 6 remaining (axioms 7-9 in Boneyard only)

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No imports of StagedConstruction/ outside Boneyard
- [ ] Axiom count verification: `grep -r "^axiom" Theories/ | wc -l` equals 6
- [ ] SuccChain completeness proof still compiles
- [ ] Boneyard files are valid Lean (syntax correct, just orphaned)

## Artifacts & Outputs

- `Boneyard/Metalogic/StagedConstruction/` - archived files (32+)
- `Boneyard/Metalogic/StagedConstruction/README.md` - archival documentation
- `Boneyard/Metalogic/StagedConstruction/Domain/` - archived domain files
- `Boneyard/Metalogic/StagedConstruction/Canonical/` - archived canonical files
- `specs/043_archive_dead_paths_to_boneyard/summaries/01_archival-summary.md` - implementation summary

## Rollback/Contingency

If issues arise at any phase:
1. Git checkout the affected files: `git checkout HEAD~1 -- <file_path>`
2. Each phase is independently committable, enabling precise rollback
3. Boneyard structure can be removed if archival is incomplete: `rm -rf Boneyard/Metalogic/StagedConstruction/`
4. Original files can be restored from git history

If build fails after all phases:
1. Check for circular dependencies between remaining and archived files
2. May need to stub out types/functions that were exported from archived modules
3. Worst case: keep minimal shim file that re-exports needed definitions from Boneyard

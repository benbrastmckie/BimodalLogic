# Implementation Plan: Task #808

- **Task**: 808 - audit_coherentconstruction_taskrelation_sorries
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/808_audit_coherentconstruction_taskrelation_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Audit and archive 15 sorries across CoherentConstruction.lean and TaskRelation.lean. Research confirmed that none of these sorries block the completeness theorem - the representation theorem uses only proven coherence cases and doesn't depend on the cross-origin cases or task relation compositionality. This is a cleanup/documentation task to prepare the codebase for publication by clearly documenting why these sorries are acceptable.

### Research Integration

Research report analysis revealed:
- 10 sorries in CoherentConstruction.lean (2 consistency proofs, 8 cross-origin cases)
- 5 sorries in TaskRelation.lean (compositionality cases)
- None block the representation_theorem dependency path
- Cross-origin cases are documented in Boneyard/CrossOriginCases.lean
- Task relation is an alternative formulation not used by completeness proof

## Goals & Non-Goals

**Goals**:
- Document why each sorry is acceptable for publication
- Add clear header documentation explaining the sorry status
- Verify no other files depend on these constructions
- Move files to Boneyard/ with proper documentation
- Ensure build still passes after archival

**Non-Goals**:
- Complete any of the 15 sorries (not required for completeness)
- Modify the representation theorem or its dependencies
- Create new coherence proofs
- Complete modal completeness infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Files have dependencies we missed | H | L | Phase 1 scans for imports before archival |
| Build breaks after moving files | M | L | Phase 3 verifies build passes |
| Documentation incomplete | M | M | Phase 2 adds comprehensive headers explaining sorries |

## Implementation Phases

### Phase 1: Dependency Analysis [NOT STARTED]

**Goal**: Verify no other files depend on CoherentConstruction.lean or TaskRelation.lean

**Tasks**:
- [ ] Use Grep to find all imports of CoherentConstruction
- [ ] Use Grep to find all imports of TaskRelation
- [ ] Check UniversalCanonicalModel.lean dependencies (should only use proven cases)
- [ ] Document findings in implementation notes

**Timing**: 30 minutes

**Files to analyze**:
- `Theories/Bimodal/**/*.lean` - All modal logic files

**Verification**:
- No active files import CoherentConstruction or TaskRelation beyond expected paths
- UniversalCanonicalModel.lean dependency chain confirmed

---

### Phase 2: Add Documentation Headers [NOT STARTED]

**Goal**: Add clear explanatory comments to both files documenting why sorries are acceptable

**Tasks**:
- [ ] Add header to CoherentConstruction.lean explaining:
  - 2 consistency proof sorries (lines 405, 418) - runtime non-blocking
  - 8 cross-origin sorries - cases not exercised by representation theorem
  - Reference to Boneyard/CrossOriginCases.lean
- [ ] Add header to TaskRelation.lean explaining:
  - 5 compositionality sorries - alternative formulation not on completeness path
  - Would be needed for full modal completeness (future work)
- [ ] Add inline comments at each sorry with brief explanation

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Coherence/CoherentConstruction.lean` - Add header and inline comments
- `Theories/Bimodal/Metalogic/Coherence/TaskRelation.lean` - Add header and inline comments

**Verification**:
- Headers clearly explain the sorry status
- Each sorry has inline comment referencing research findings
- Documentation references research report

---

### Phase 3: Archive Files [NOT STARTED]

**Goal**: Move files to Boneyard/ and update imports

**Tasks**:
- [ ] Create Boneyard/Metalogic/Coherence/ directory
- [ ] Move CoherentConstruction.lean to Boneyard/Metalogic/Coherence/
- [ ] Move TaskRelation.lean to Boneyard/Metalogic/Coherence/
- [ ] Update any import statements (if Phase 1 found dependencies)
- [ ] Run lake build to verify compilation

**Timing**: 30 minutes

**Files to modify**:
- `Boneyard/Metalogic/Coherence/CoherentConstruction.lean` - Moved from Theories/
- `Boneyard/Metalogic/Coherence/TaskRelation.lean` - Moved from Theories/
- Any importing files (if found in Phase 1)

**Verification**:
- Files moved successfully
- Build passes without errors
- No import errors

---

### Phase 4: Create Summary and Verification [NOT STARTED]

**Goal**: Document the archival and verify repository state

**Tasks**:
- [ ] Create implementation summary documenting:
  - 15 sorries audited and archived
  - Files moved to Boneyard/
  - Build verified passing
  - No dependencies broken
- [ ] Verify representation_theorem still compiles
- [ ] Update task completion metadata

**Timing**: 15 minutes

**Files to create**:
- `specs/808_audit_coherentconstruction_taskrelation_sorries/summaries/implementation-summary-{DATE}.md`

**Verification**:
- Summary accurately reflects work completed
- Build passes
- representation_theorem compiles

## Testing & Validation

- [ ] lake build passes without errors
- [ ] UniversalCanonicalModel.lean compiles successfully
- [ ] representation_theorem definition accessible
- [ ] No import errors in Bimodal/Metalogic/
- [ ] Boneyard files contain comprehensive documentation

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-{DATE}.md
- Modified files with documentation headers (archived to Boneyard/)

## Rollback/Contingency

If archival causes unexpected issues:
1. Move files back from Boneyard/ to original locations
2. Remove documentation headers (via git restore)
3. Restore any modified imports
4. Verify build passes
5. Document issue in task notes for future investigation

The research confirms these files are safe to archive, so rollback is unlikely to be needed.

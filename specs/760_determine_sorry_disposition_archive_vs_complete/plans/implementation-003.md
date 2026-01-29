# Implementation Plan: Task #760

- **Task**: 760 - Archive sorried code to Boneyard (non-overlapping with Task 750)
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Priority**: Medium
- **Dependencies**: None (can run in parallel with Task 750)
- **Research Inputs**: specs/760_determine_sorry_disposition_archive_vs_complete/reports/research-001.md
- **Artifacts**: plans/implementation-003.md (this file - revision avoiding Task 750 overlap)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Archive sorried code from the main Bimodal/ theory to Boneyard/, **excluding items already handled by Task 750 (implementation-006.md)**.

### Task 750 Overlap Analysis

Task 750 v006 handles:
- AlgebraicSemanticBridge.lean (archive to Boneyard)
- HybridCompleteness.lean (archive to Boneyard)
- MCSDerivedWorldState.lean (archive to Boneyard)
- SemanticCanonicalModel.lean (documentation cleanup)
- FiniteModelProperty.lean (documentation cleanup)
- TruthLemma.lean (documentation cleanup)
- Boneyard/Metalogic_v3/ directory and README setup

**This plan (Task 760) handles**:
- Examples/ files: TemporalProofs, ModalProofStrategies, ModalProofs (12 sorries)
- IndexedMCSFamily.lean dead code (4 sorries)
- CoherentConstruction.lean cross-origin cases (8 sorries)
- TaskRelation.lean compositionality (5 sorries)

**Total**: 29 sorries in scope for this task

### Coordination with Task 750

Both tasks can execute in parallel since they target different files. If Task 750 creates Boneyard/Metalogic_v3/, this task will use it; otherwise this task creates it.

## Goals & Non-Goals

**Goals**:
- Move Examples/ exercise files to Boneyard/Examples/
- Extract dead code from IndexedMCSFamily.lean to Boneyard
- Extract cross-origin cases from CoherentConstruction.lean to Boneyard
- Extract compositionality proofs from TaskRelation.lean to Boneyard
- Ensure no imports from Boneyard/ in main theory
- Clean compilation with `lake build`
- Document archived code

**Non-Goals**:
- Touch files handled by Task 750 (AlgebraicSemanticBridge, HybridCompleteness, MCSDerivedWorldState, TruthLemma documentation, SemanticCanonicalModel, FiniteModelProperty)
- Complete any proofs
- Touch Logos/ or non-Bimodal code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports | High | Medium | Check all imports before moving |
| Dependency on Task 750 for Boneyard structure | Low | Low | Create structure if not present |
| Critical path depends on sorried code | High | Low | Verify with `lake build` |

## Implementation Phases

### Phase 1: Dependency Analysis [NOT STARTED]

**Goal**: Verify import dependencies for files to be archived.

**Tasks**:
- [ ] Check imports of Examples/*.lean files (expect none - examples are leaf files)
- [ ] Check usages of `construct_indexed_family` in IndexedMCSFamily.lean
- [ ] Check usages of cross-origin sorried lemmas in CoherentConstruction.lean
- [ ] Check usages of `canonical_task_rel_compositionality` in TaskRelation.lean

**Commands**:
```bash
# Examples
grep -r "Bimodal.Examples.TemporalProofs" Theories/ --include="*.lean" | grep -v Examples/
grep -r "Bimodal.Examples.ModalProofStrategies" Theories/ --include="*.lean" | grep -v Examples/
grep -r "Bimodal.Examples.ModalProofs" Theories/ --include="*.lean" | grep -v Examples/

# IndexedMCSFamily
grep -r "construct_indexed_family" Theories/ --include="*.lean"

# CoherentConstruction sorried lemmas
grep -r "cross_origin" Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean

# TaskRelation
grep -r "canonical_task_rel_compositionality" Theories/ --include="*.lean"
```

**Timing**: 30 minutes

**Verification**:
- Dependency analysis complete
- Safe files identified
- Extraction strategy determined

---

### Phase 2: Archive Examples/ Files (12 sorries) [NOT STARTED]

**Goal**: Move exercise files to Boneyard/Examples/. These are leaf files with no dependents.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Examples/` directory
- [ ] Move `TemporalProofs.lean` to Boneyard/Examples/
- [ ] Move `ModalProofStrategies.lean` to Boneyard/Examples/
- [ ] Move `ModalProofs.lean` to Boneyard/Examples/
- [ ] Add archive header to each file explaining:
  - These are exercise files with incomplete proofs
  - Moved to Boneyard to reduce sorry count in main codebase
  - Proofs are straightforward to complete if needed
- [ ] Update `Theories/Bimodal/Examples/Examples.lean` to remove imports
- [ ] Run `lake build` to verify

**Files**:
- CREATE: `Theories/Bimodal/Boneyard/Examples/`
- MOVE: `Examples/TemporalProofs.lean` → `Boneyard/Examples/`
- MOVE: `Examples/ModalProofStrategies.lean` → `Boneyard/Examples/`
- MOVE: `Examples/ModalProofs.lean` → `Boneyard/Examples/`
- MODIFY: `Theories/Bimodal/Examples/Examples.lean` (remove imports)

**Timing**: 45 minutes

**Verification**:
- `lake build` succeeds
- No imports of moved files in main codebase

---

### Phase 3: Archive IndexedMCSFamily Dead Code (4 sorries) [NOT STARTED]

**Goal**: Remove unused `construct_indexed_family` and related code from IndexedMCSFamily.lean.

**Tasks**:
- [ ] Confirm `construct_indexed_family` is unused (Phase 1 analysis)
- [ ] Identify all definitions/lemmas related to `construct_indexed_family`
- [ ] Extract to `Theories/Bimodal/Boneyard/Metalogic_v3/IndexedMCSFamily/ConstructIndexedFamily.lean`
- [ ] Add archive header explaining:
  - This was an alternative approach to family construction
  - Not integrated with main completeness path
  - Main proofs use `construct_coherent_family` instead
- [ ] Run `lake build` to verify

**Files**:
- CREATE: `Boneyard/Metalogic_v3/IndexedMCSFamily/ConstructIndexedFamily.lean`
- MODIFY: `Metalogic/Representation/IndexedMCSFamily.lean` (remove dead code)

**Timing**: 45 minutes

**Verification**:
- `lake build` succeeds
- `construct_indexed_family` not in main codebase
- Core IndexedMCSFamily functionality preserved

---

### Phase 4: Archive CoherentConstruction Cross-Origin Cases (8 sorries) [NOT STARTED]

**Goal**: Extract cross-origin coherence cases to Boneyard.

**Research note**: These sorries are marked "NOT REQUIRED FOR COMPLETENESS" and reference existing `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`.

**Tasks**:
- [ ] Review existing `CrossOriginCases.lean` in Boneyard
- [ ] Identify which sorried lemmas in CoherentConstruction can be removed
- [ ] If lemmas are used: replace with `sorry` placeholder referencing Boneyard
- [ ] If lemmas are unused: delete entirely
- [ ] Consolidate cross-origin documentation in Boneyard
- [ ] Run `lake build` to verify

**Files**:
- MODIFY: `Metalogic/Representation/CoherentConstruction.lean` (remove/simplify)
- MODIFY: `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean` (consolidate if needed)

**Timing**: 1 hour

**Verification**:
- `lake build` succeeds
- Cross-origin sorries reduced or eliminated from main code
- Documentation in Boneyard explains limitation

---

### Phase 5: Archive TaskRelation Compositionality (5 sorries) [NOT STARTED]

**Goal**: Extract task relation compositionality proofs to Boneyard.

**Tasks**:
- [ ] Identify `canonical_task_rel_compositionality` and dependent lemmas
- [ ] Check if used by completeness proof (research says no)
- [ ] Extract to `Theories/Bimodal/Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`
- [ ] Add archive header explaining:
  - Compositionality of canonical task relation
  - Complex case analysis for mixed-sign durations
  - Not on critical path for `semantic_weak_completeness`
- [ ] Run `lake build` to verify

**Files**:
- CREATE: `Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`
- MODIFY: `Metalogic/Representation/TaskRelation.lean` (remove sorried code)

**Timing**: 1 hour

**Verification**:
- `lake build` succeeds
- Compositionality code documented in Boneyard
- Main TaskRelation functionality preserved

---

### Phase 6: Update Boneyard Documentation [NOT STARTED]

**Goal**: Ensure all archived code is documented in Boneyard README.

**Tasks**:
- [ ] Update `Theories/Bimodal/Boneyard/README.md` with new entries:
  - Examples/ section: Exercise files with incomplete proofs
  - Metalogic_v3/IndexedMCSFamily/ section: Alternative family construction
  - Metalogic_v3/TaskRelation/ section: Compositionality attempts
  - Note that Coherence/CrossOriginCases already exists
- [ ] If Task 750 has not created Metalogic_v3/README.md, create it
- [ ] Verify no Boneyard imports in main code

**Commands**:
```bash
grep -r "import.*Boneyard" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard/
```

**Timing**: 30 minutes

**Verification**:
- Boneyard README documents all archived code
- No Boneyard imports in main theory

---

### Phase 7: Final Verification [NOT STARTED]

**Goal**: Verify clean build and document completion.

**Tasks**:
- [ ] Run full `lake build`
- [ ] Count remaining sorries in main Bimodal/ (excluding Boneyard)
- [ ] Compare to initial count (should be reduced by ~29)
- [ ] Create implementation summary

**Timing**: 30 minutes

**Verification**:
- `lake build` succeeds
- Sorry count reduced
- No functionality regression

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No imports from Boneyard/ in main Theories/Bimodal/
- [ ] Main theorems (`semantic_weak_completeness`) still compile
- [ ] Boneyard README documents all archived code

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Examples/` (3 archived files)
- `Theories/Bimodal/Boneyard/Metalogic_v3/IndexedMCSFamily/ConstructIndexedFamily.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`
- Updated `Theories/Bimodal/Boneyard/README.md`
- `specs/760_determine_sorry_disposition_archive_vs_complete/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If archiving causes critical breakage:
1. Git revert the problematic phase
2. Document why that code cannot be archived
3. Partial archiving is acceptable - each phase is independent

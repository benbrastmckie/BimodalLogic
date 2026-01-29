# Implementation Plan: Task #760

- **Task**: 760 - Archive sorried code to Boneyard (complementing completed Task 750)
- **Status**: [IMPLEMENTING]
- **Effort**: 4-5 hours
- **Priority**: Medium
- **Dependencies**: Task 750 (COMPLETED - Boneyard/Metalogic_v3/ structure exists)
- **Research Inputs**: specs/760_determine_sorry_disposition_archive_vs_complete/reports/research-001.md
- **Artifacts**: plans/implementation-004.md (this file - updated after Task 750 completion)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Archive sorried code from the main Bimodal/ theory to Boneyard/, **complementing the completed Task 750**.

### Task 750 Completion Summary

Task 750 (completed 2026-01-29) archived:
- `MCSDerivedWorldState.lean` → `Boneyard/Metalogic_v3/FailedTruthLemma/`
- `AlgebraicSemanticBridge.lean` → `Boneyard/Metalogic_v3/FailedTruthLemma/`
- `HybridCompleteness.lean` → `Boneyard/Metalogic_v3/FailedTruthLemma/`

Task 750 also:
- Created `Boneyard/Metalogic_v3/` directory structure with README
- Updated documentation in SemanticCanonicalModel, FiniteModelProperty, TruthLemma
- Documented `semantic_weak_completeness` as THE canonical completeness theorem

**This plan (Task 760) handles remaining sorries**:
- Examples/ files: TemporalProofs, ModalProofStrategies, ModalProofs (12 sorries)
- IndexedMCSFamily.lean dead code (4 sorries)
- CoherentConstruction.lean cross-origin cases (8 sorries)
- TaskRelation.lean compositionality (5 sorries)

**Total**: 29 sorries in scope for this task

### Key Insight from Task 750

From the Task 750 summary:
> "Sorries are architectural, not incomplete": The remaining sorries in `truth_at_implies_semantic_truth` and compositionality are fundamental limitations, not work to be done

This informs our approach - we're archiving these sorries not because they're "fixable later" but because they represent exploration paths that didn't work out or optional functionality not required for completeness.

## Goals & Non-Goals

**Goals**:
- Move Examples/ exercise files to Boneyard/Examples/
- Extract dead code from IndexedMCSFamily.lean to Boneyard
- Extract cross-origin cases from CoherentConstruction.lean (or remove if unused)
- Extract compositionality proofs from TaskRelation.lean to Boneyard
- Ensure no imports from Boneyard/ in main theory
- Clean compilation with `lake build`
- Update Boneyard documentation

**Non-Goals**:
- Touch files already handled by Task 750
- Complete any proofs (these are architectural limitations or exercise code)
- Touch Logos/ or non-Bimodal code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports | High | Medium | Check all imports before moving |
| Critical path depends on sorried code | High | Low | Verify with `lake build` |
| Conflict with Task 750 changes | Low | Low | Task 750 complete, no conflict |

## Implementation Phases

### Phase 1: Dependency Analysis [COMPLETED]

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

# CoherentConstruction sorried lemmas (check line numbers from research)
# Lines: 712, 715, 723, 726, 744, 751, 799, 802

# TaskRelation
grep -r "canonical_task_rel_compositionality" Theories/ --include="*.lean"
```

**Timing**: 30 minutes

**Verification**:
- Dependency analysis complete
- Safe files identified
- Extraction strategy determined

---

### Phase 2: Archive Examples/ Files (12 sorries) [IN PROGRESS]

**Goal**: Move exercise files to Boneyard/Examples/. These are leaf files with no dependents.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Examples/` directory
- [ ] Move `TemporalProofs.lean` to Boneyard/Examples/
- [ ] Move `ModalProofStrategies.lean` to Boneyard/Examples/
- [ ] Move `ModalProofs.lean` to Boneyard/Examples/
- [ ] Add archive header to each file:
  ```lean
  /-!
  # ARCHIVED: Exercise File with Incomplete Proofs

  **Archived from**: `Theories/Bimodal/Examples/`
  **Reason**: Contains `sorry` placeholders for exercises
  **Status**: Proofs are straightforward to complete if needed

  These exercises demonstrate proof techniques but were moved to Boneyard
  to reduce the sorry count in the main codebase.
  -/
  ```
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

**Goal**: Remove unused `construct_indexed_family` and related code.

Research identified this as DEAD CODE - not used anywhere in the codebase.

**Tasks**:
- [ ] Confirm `construct_indexed_family` is unused (Phase 1 analysis)
- [ ] Identify all definitions/lemmas related to `construct_indexed_family`
- [ ] Extract to `Theories/Bimodal/Boneyard/Metalogic_v3/IndexedMCSFamily/ConstructIndexedFamily.lean`
- [ ] Add archive header:
  ```lean
  /-!
  # ARCHIVED: Alternative Family Construction

  **Archived from**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
  **Reason**: Dead code - not used in completeness proof
  **Alternative**: Main proofs use `construct_coherent_family` instead

  This was an exploratory approach to family construction that was
  superseded by the coherent construction approach.
  -/
  ```
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

**Goal**: Handle cross-origin coherence sorries.

Research note: These sorries are marked "NOT REQUIRED FOR COMPLETENESS" and reference existing `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`.

**Decision tree**:
1. If cross-origin lemmas are **unused** → Delete from main file entirely
2. If cross-origin lemmas are **used but not critical** → Keep minimal sorry with Boneyard reference
3. If cross-origin lemmas are **critical** → Document as architectural limitation (like Task 750)

**Tasks**:
- [ ] Review existing `CrossOriginCases.lean` in Boneyard
- [ ] Identify which sorried lemmas in CoherentConstruction are actually used
- [ ] Apply decision tree above
- [ ] If extracting code, add archive header referencing CrossOriginCases.lean
- [ ] Run `lake build` to verify

**Files**:
- MODIFY: `Metalogic/Representation/CoherentConstruction.lean`
- POSSIBLY MODIFY: `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`

**Timing**: 1 hour

**Verification**:
- `lake build` succeeds
- Cross-origin sorries reduced or clearly documented
- No functionality regression

---

### Phase 5: Archive TaskRelation Compositionality (5 sorries) [NOT STARTED]

**Goal**: Extract task relation compositionality proofs to Boneyard.

From Task 750 insight: "compositionality [sorries] are fundamental limitations"

**Tasks**:
- [ ] Identify `canonical_task_rel_compositionality` and dependent lemmas
- [ ] Verify not used by completeness proof
- [ ] Extract to `Theories/Bimodal/Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`
- [ ] Add archive header:
  ```lean
  /-!
  # ARCHIVED: Task Relation Compositionality

  **Archived from**: `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
  **Reason**: Complex case analysis not required for completeness
  **Status**: Architectural limitation - mixed-sign duration cases

  The canonical task relation's compositionality property requires
  proving complex case analyses for mixed-sign durations. These are
  not on the critical path for `semantic_weak_completeness`.
  -/
  ```
- [ ] Run `lake build` to verify

**Files**:
- CREATE: `Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`
- MODIFY: `Metalogic/Representation/TaskRelation.lean`

**Timing**: 1 hour

**Verification**:
- `lake build` succeeds
- Compositionality code documented in Boneyard
- Main TaskRelation functionality preserved

---

### Phase 6: Update Boneyard Documentation [NOT STARTED]

**Goal**: Add Task 760 entries to existing Boneyard README (created by Task 750).

**Tasks**:
- [ ] Update `Theories/Bimodal/Boneyard/README.md`:
  - Add Examples/ section
  - Add Metalogic_v3/IndexedMCSFamily/ section
  - Add Metalogic_v3/TaskRelation/ section
  - Note that Coherence/CrossOriginCases was pre-existing
- [ ] Update `Boneyard/Metalogic_v3/README.md` (if exists from Task 750)
- [ ] Verify no Boneyard imports in main code:
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
- [ ] Count remaining sorries in main Bimodal/ (excluding Boneyard):
  ```bash
  grep -r "sorry" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard | wc -l
  ```
- [ ] Compare to pre-implementation count
- [ ] Create implementation summary

**Timing**: 30 minutes

**Verification**:
- `lake build` succeeds
- Sorry count reduced by ~29
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

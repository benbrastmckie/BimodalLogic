# Implementation Plan: Task #760

- **Task**: 760 - Archive sorried code to Boneyard for clean main codebase
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/760_determine_sorry_disposition_archive_vs_complete/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file - revision of v001)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Archive all sorried code from the main Bimodal/ theory to Boneyard/. The goal is a cleaner codebase where:
1. The main Theories/Bimodal/ (excluding Boneyard/) has minimal or no sorries
2. Documentation of incomplete approaches lives in Boneyard/ where it can be preserved
3. No imports from Boneyard/ in the main theory files

### Revision Notes

This plan supersedes v001 which focused on completing exercise sorries. User clarified:
- Do NOT complete exercises - archive them instead
- Archive ALL sorried code (ARCHIVE + COMPLETE categories from research)
- Also archive KEEP sorries that are just documentation (Boneyard is for documentation)
- Only sorries that may remain are truly unavoidable architectural ones in critical path code

### Research Integration

From research-001.md, the sorries to archive:

**ARCHIVE (25 sorries):**
- CoherentConstruction.lean: 8 (cross-origin cases)
- TaskRelation.lean: 5 (compositionality)
- IndexedMCSFamily.lean: 4 (dead code - construct_indexed_family)
- AlgebraicSemanticBridge.lean: 8 (alternative approach)

**COMPLETE → ARCHIVE (12 sorries):**
- TemporalProofs.lean: 2 (exercises)
- ModalProofStrategies.lean: 5 (exercises)
- ModalProofs.lean: 5 (exercises)

**KEEP → ARCHIVE (some, 11 total in category):**
- TruthLemma.lean: 4 (architectural - evaluate if backward directions can be removed)
- SemanticCanonicalModel.lean: 2 (alternative path)
- FiniteModelProperty.lean: 1 (alternative path)

**Total to address**: ~48 sorries across multiple files

## Goals & Non-Goals

**Goals**:
- Move sorried code to Boneyard/ with proper organization
- Ensure no imports from Boneyard/ in main theory
- Clean compilation with `lake build`
- Document archived code in Boneyard README
- Reduce visible sorry count in main codebase

**Non-Goals**:
- Complete any proofs
- Fix architectural sorries
- Touch Logos/ or non-Bimodal code
- Modify Boneyard/ imports (they can import main code, just not vice versa)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports | High | Medium | Check all imports before moving, use Grep |
| Critical path code depends on sorried code | High | Low | Verify with `lake build` after each phase |
| Losing important documentation | Medium | Low | Preserve comments in archived files |
| Circular dependencies | Medium | Low | Move entire modules, not partial code |

## Implementation Phases

### Phase 1: Audit and Dependency Analysis [NOT STARTED]

**Goal**: Map all dependencies before moving code.

**Tasks**:
- [ ] List all files to be archived
- [ ] For each file, check who imports it using Grep
- [ ] Identify safe files (no dependents outside Boneyard)
- [ ] Identify coupled files (need careful extraction)
- [ ] Create dependency graph

**Files to analyze**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`
- `Theories/Bimodal/Examples/TemporalProofs.lean`
- `Theories/Bimodal/Examples/ModalProofStrategies.lean`
- `Theories/Bimodal/Examples/ModalProofs.lean`
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Timing**: 1 hour

**Verification**:
- Dependency map complete
- Safe vs coupled files identified
- Clear plan for each file

---

### Phase 2: Archive Examples/ Files (12 sorries) [NOT STARTED]

**Goal**: Move exercise files to Boneyard. These should be safe (examples rarely have dependents).

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Examples/` directory
- [ ] Move `TemporalProofs.lean` to Boneyard/Examples/
- [ ] Move `ModalProofStrategies.lean` to Boneyard/Examples/
- [ ] Move `ModalProofs.lean` to Boneyard/Examples/
- [ ] Update lakefile.lean if needed (remove from build)
- [ ] Run `lake build` to verify no breakage
- [ ] Update Boneyard/README.md with documentation

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/Examples/` (new directory)
- Moved files with headers documenting archive reason
- `Theories/Bimodal/Boneyard/README.md`

**Verification**:
- `lake build` succeeds
- No imports of moved files in main codebase

---

### Phase 3: Archive AlgebraicSemanticBridge.lean (8 sorries) [NOT STARTED]

**Goal**: Move the entire algebraic approach to Boneyard.

**Tasks**:
- [ ] Check imports of `AlgebraicSemanticBridge.lean`
- [ ] If imported: extract alternative path code or remove imports
- [ ] Move to `Theories/Bimodal/Boneyard/Metalogic_v3/Algebraic/`
- [ ] Run `lake build` to verify
- [ ] Document in Boneyard README

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean` → archived
- Any files that imported it

**Verification**:
- `lake build` succeeds
- No Boneyard imports in main code

---

### Phase 4: Archive IndexedMCSFamily dead code (4 sorries) [NOT STARTED]

**Goal**: Move `construct_indexed_family` to Boneyard (research confirmed it's unused).

**Tasks**:
- [ ] Verify `construct_indexed_family` is truly unused (Grep)
- [ ] Option A: Move entire file if nothing else is used
- [ ] Option B: Extract only the unused definitions to Boneyard
- [ ] Run `lake build` to verify
- [ ] Document in Boneyard README

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (extract or move)
- `Theories/Bimodal/Boneyard/Metalogic_v3/` (destination)

**Verification**:
- `lake build` succeeds
- Unused code removed from main codebase

---

### Phase 5: Archive CoherentConstruction cross-origin cases (8 sorries) [NOT STARTED]

**Goal**: Extract cross-origin coherence cases to Boneyard.

**Tasks**:
- [ ] Identify which definitions/lemmas in CoherentConstruction have sorries
- [ ] Check if those lemmas are used elsewhere
- [ ] If used: leave sorry with reference to Boneyard (last resort)
- [ ] If not used: move to `Boneyard/Metalogic_v3/Coherence/` alongside existing CrossOriginCases.lean
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/`

**Verification**:
- `lake build` succeeds
- Cross-origin cases documented in Boneyard

---

### Phase 6: Archive TaskRelation compositionality (5 sorries) [NOT STARTED]

**Goal**: Extract task relation compositionality proofs to Boneyard.

**Tasks**:
- [ ] Identify `canonical_task_rel_compositionality` and related lemmas
- [ ] Check dependents
- [ ] If on critical path: evaluate if proof can be simplified
- [ ] If not critical: move to Boneyard
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v3/`

**Verification**:
- `lake build` succeeds
- Compositionality attempt documented in Boneyard

---

### Phase 7: Evaluate FMP/SemanticCanonicalModel (3 sorries) [NOT STARTED]

**Goal**: Evaluate whether SemanticCanonicalModel.lean and FiniteModelProperty.lean can be archived.

**Tasks**:
- [ ] Check if these provide unique functionality not in main completeness
- [ ] If redundant with `semantic_weak_completeness`: archive entirely
- [ ] If partially useful: extract useful parts, archive rest
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v3/FMP/`

**Verification**:
- `lake build` succeeds
- Alternative completeness paths documented in Boneyard

---

### Phase 8: Evaluate TruthLemma backward directions (4 sorries) [NOT STARTED]

**Goal**: Determine disposition of TruthLemma.lean backward direction sorries.

**Tasks**:
- [ ] Check if backward directions are used anywhere
- [ ] If unused: remove from TruthLemma.lean entirely (not needed for completeness)
- [ ] Archive removed code to Boneyard with documentation
- [ ] If used: document as architectural limitation (cannot archive)
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/`

**Verification**:
- `lake build` succeeds
- Documentation explains disposition

---

### Phase 9: Final Verification and Documentation [NOT STARTED]

**Goal**: Verify clean build and document all changes.

**Tasks**:
- [ ] Run full `lake build`
- [ ] Count remaining sorries in main Bimodal/ (excluding Boneyard)
- [ ] Update Boneyard/README.md with complete archive inventory
- [ ] Verify no Boneyard imports in main code: `grep -r "import.*Boneyard" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard`
- [ ] Update state.json with completion summary

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/README.md` (comprehensive update)
- `specs/760_determine_sorry_disposition_archive_vs_complete/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- `lake build` succeeds
- Sorry count documented
- No Boneyard imports in main code
- All archived code documented

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No imports from Boneyard/ in main Theories/Bimodal/
- [ ] Sorry count in main codebase reduced significantly
- [ ] Boneyard/README.md documents all archived code
- [ ] No functionality regression (main theorems still work)

## Artifacts & Outputs

- Archived files in `Theories/Bimodal/Boneyard/`
- Updated `Theories/Bimodal/Boneyard/README.md`
- `specs/760_determine_sorry_disposition_archive_vs_complete/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If archiving causes critical breakage:
1. Git revert the problematic phase
2. Document why that code cannot be archived
3. Mark as architectural limitation in research report
4. Partial archiving is acceptable - each phase is independent

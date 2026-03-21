# Implementation Plan: Task #750

- **Task**: 750 - refactor_forward_truth_lemma_remove_sorries
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Refactor the metalogic to use a clean Two-Pillar Architecture (Algebraic + FMP/Semantic), documenting the existing sorry-free paths and archiving superseded code. The research confirms that both pillars already exist and are proven: the Algebraic path proves satisfiability iff consistency via ultrafilters, while the FMP path provides semantic_weak_completeness without sorries. This plan focuses on: (1) removing backward Truth Lemma direction and box cases (not needed), (2) documenting the Two-Pillar Architecture in Metalogic/README.md, (3) archiving files in Representation/ that are superseded by the two pillars, and (4) cross-referencing between paths.

### Research Integration

**Integrated from research-003.md**:
- Two-pillar architecture already exists: Algebraic path (sorry-free) and FMP path (one non-critical sorry)
- `algebraic_representation_theorem` in Algebraic/AlgebraicRepresentation.lean is the core representation theorem
- `semantic_weak_completeness` in FMP/SemanticCanonicalModel.lean provides sorry-free completeness
- Representation/ contains legacy infrastructure that duplicates effort across both pillars
- Backward Truth Lemma direction and box cases have architectural limitations that cannot be fixed

## Goals & Non-Goals

**Goals**:
- Remove sorries from TruthLemma.lean by removing backward direction and box cases entirely
- Update Metalogic/README.md with explicit Two-Pillar Architecture documentation
- Archive superseded files from Representation/ to Boneyard/
- Add cross-references between Algebraic and FMP paths
- Ensure `lake build` passes with no regressions

**Non-Goals**:
- Proving the compositionality sorry in FMP (mathematically false for unbounded durations)
- Refactoring the Algebraic path (already sorry-free)
- Creating new completeness theorems (both pillars already have them)
- Changing the FMP finite model construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing imports | High | Medium | Check all imports before archiving; update import paths |
| Losing useful lemmas | Medium | Low | Review each file carefully; keep useful helper lemmas |
| Build failures after refactor | High | Medium | Run `lake build` after each phase; commit incrementally |
| Incomplete archival | Low | Low | Use grep to find all references to archived files |

## Implementation Phases

### Phase 1: Audit and Document Current State [NOT STARTED]

**Goal**: Understand exactly what uses what, identify safe archival targets

**Tasks**:
- [ ] Run grep to find all imports of Representation/ files
- [ ] Document which files import TruthLemma.lean
- [ ] Document which files import the backward truth lemma theorems
- [ ] Verify Algebraic/ is truly sorry-free with `lake build Bimodal.Metalogic.Algebraic.Algebraic`
- [ ] Verify FMP path works independently of Representation/TruthLemma.lean

**Timing**: 1 hour

**Files to examine**:
- `Theories/Bimodal/Metalogic/` (all .lean files)
- `Theories/Bimodal/Metalogic.lean` (main import file)

**Verification**:
- Clear list of import dependencies
- Confirmed which theorems are actually used by completeness proofs

---

### Phase 2: Refactor TruthLemma.lean to Forward-Only [NOT STARTED]

**Goal**: Remove all sorries from TruthLemma.lean by eliminating backward direction and box cases

**Tasks**:
- [ ] Remove `truth_lemma_mutual` (the biconditional with sorries)
- [ ] Keep only `truth_lemma_forward` as the main theorem
- [ ] Remove backward direction cases from all formula constructors
- [ ] Remove box forward/backward cases entirely (architectural limitation)
- [ ] Update the module docstring to explain the forward-only approach
- [ ] Run `lake build` to verify no regressions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - major refactor

**Verification**:
- `lake build Bimodal.Metalogic.Representation.TruthLemma` succeeds
- No sorries remain in TruthLemma.lean
- Forward direction still works for all formula types (atom, bot, imp, all_past, all_future)

---

### Phase 3: Archive Superseded Representation Files [NOT STARTED]

**Goal**: Move files that are superseded by the Two-Pillar Architecture to Boneyard

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v4/` for this archival
- [ ] Archive `CoherentConstruction.lean` (has many sorries, not needed for either pillar)
- [ ] Archive `CanonicalHistory.lean` (has sorries, superseded by both pillars)
- [ ] Archive `TaskRelation.lean` (has sorries, superseded)
- [ ] Archive `UniversalCanonicalModel.lean` (has sorries, superseded)
- [ ] Keep `IndexedMCSFamily.lean` (provides useful MCS family infrastructure)
- [ ] Keep `CanonicalWorld.lean` (provides world construction used elsewhere)
- [ ] Update imports in remaining files
- [ ] Run `lake build` after each archival

**Timing**: 1.5 hours

**Files to move**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` -> Boneyard
- `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean` -> Boneyard
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` -> Boneyard
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` -> Boneyard

**Verification**:
- `lake build` succeeds with reduced Representation/ directory
- No broken imports in remaining Metalogic/ files

---

### Phase 4: Update Metalogic/README.md with Two-Pillar Documentation [NOT STARTED]

**Goal**: Document the Two-Pillar Architecture clearly for future developers

**Tasks**:
- [ ] Add "Two-Pillar Architecture" section near the top
- [ ] Document Pillar A: Algebraic Path (`algebraic_representation_theorem`)
- [ ] Document Pillar B: Semantic/FMP Path (`semantic_weak_completeness`)
- [ ] Explain that both paths prove completeness independently
- [ ] Document the compositionality sorry as intentional and non-blocking
- [ ] Update the "Current Status" section to reflect the refactored state
- [ ] Remove references to archived files
- [ ] Add cross-references between paths

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - major update

**Verification**:
- README clearly explains the two pillars
- All mentioned files exist and are accurate
- No references to archived files

---

### Phase 5: Add Cross-References and Final Cleanup [NOT STARTED]

**Goal**: Add cross-references between the two paths and verify the complete architecture

**Tasks**:
- [ ] Add cross-reference comment in `Algebraic/AlgebraicRepresentation.lean` pointing to FMP path
- [ ] Add cross-reference comment in `FMP/SemanticCanonicalModel.lean` pointing to Algebraic path
- [ ] Update `FMP/README.md` to mention the Algebraic alternative
- [ ] Update `Metalogic/Metalogic.lean` to reflect the Two-Pillar imports
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify no sorries in critical paths

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - add comment
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add comment
- `Theories/Bimodal/Metalogic/FMP/README.md` - add section
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update imports

**Verification**:
- Full `lake build` succeeds
- Cross-references are accurate
- Both pillars are clearly documented

## Testing & Validation

- [ ] `lake build` passes with no new errors
- [ ] No sorries in TruthLemma.lean after Phase 2
- [ ] `algebraic_representation_theorem` still compiles (Algebraic path intact)
- [ ] `semantic_weak_completeness` still compiles (FMP path intact)
- [ ] All imports resolve correctly after archival
- [ ] README.md accurately reflects the codebase state

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - refactored to forward-only
- `Theories/Bimodal/Metalogic/README.md` - updated with Two-Pillar documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/` - archived superseded files
- `specs/750_refactor_forward_truth_lemma_remove_sorries/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If refactoring breaks critical functionality:
1. Git revert to pre-Phase-2 state
2. Keep TruthLemma.lean as-is with documented sorries
3. Focus only on documentation updates (Phase 4) without code changes
4. Document the sorries as "intentional architectural limitations" rather than removing them

Alternative minimal approach:
- Skip archival (Phase 3) and only do documentation (Phase 4)
- This preserves all code but clarifies which paths are recommended

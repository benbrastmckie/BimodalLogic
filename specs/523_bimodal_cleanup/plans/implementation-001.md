# Implementation Plan: Task #523

- **Task**: 523 - Clean Up Bimodal Lean Source Files After Task 505
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Priority**: Medium
- **Dependencies**: None (Task 505 already completed)
- **Research Inputs**: specs/523_bimodal_cleanup/reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Restructure the Bimodal/Metalogic/ directory to establish the Finite Model Property (FMP) as the central bridge between the Representation Theorem and all downstream metalogical results (Completeness, Decidability, Compactness). This cleanup removes historical commentary from code, moves deprecated approaches to Boneyard/, and creates clean import hierarchies with no circular dependencies.

### Research Integration

Research-003.md identified the ideal proof dependency tree with FMP as pivot point:
- Core/ (foundation) -> Representation/ (canonical model + truth lemma) -> FMP (bridge) -> {Completeness, Decidability, Compactness}
- Currently missing: Decidability connection to FMP, explicit Compactness module
- FiniteCanonicalModel.lean contains proven semantic completeness that should be extracted

## Goals & Non-Goals

**Goals**:
- Establish FMP as the explicit central bridge in import hierarchy
- Connect Decidability/Correctness.lean to FMP for bounded search termination
- Extract proven semantic results from FiniteCanonicalModel.lean to proper locations
- Move deprecated syntactic approach (~1000 lines) to Boneyard/
- Remove historical commentary from code (past comparisons, old approaches)
- Create comprehensive README.md files documenting architecture
- Ensure no circular imports between Completeness/Decidability/Compactness

**Non-Goals**:
- Proving new theorems (only moving/reorganizing existing proofs)
- Changing proof strategies (just restructuring)
- Adding new features or capabilities
- Modifying Core/ or Soundness/ directories (already clean)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle introduction | High | Low | Strict layer discipline: downstream never imports upstream |
| Build failures during refactor | Medium | Medium | Incremental commits, run `lake build` after each phase |
| Lost proofs during migration | High | Low | Git tracking, never delete without move-target verification |
| FMP proof has sorries | Medium | Medium | Verify FMP status first; if scaffolding, note in README |

## Implementation Phases

### Phase 1: Verify FMP Status and Establish Bridge [NOT STARTED]

**Goal**: Confirm FMP proof status and elevate it as the central bridge theorem

**Tasks**:
- [ ] Inspect Representation/FiniteModelProperty.lean for sorry placeholders
- [ ] Verify finite_model_property theorem signature and proof status
- [ ] Add explicit export declarations if FMP is proven
- [ ] Document FMP status (proven vs scaffolding) in preparation for downstream

**Timing**: 1 hour

**Files to modify**:
- `Bimodal/Metalogic/Representation/FiniteModelProperty.lean` - verify and document status

**Verification**:
- `lake build Bimodal.Metalogic.Representation.FiniteModelProperty` succeeds
- FMP proof status documented

---

### Phase 2: Connect Decidability to FMP [NOT STARTED]

**Goal**: Establish import dependency from Decidability/Correctness.lean to FMP

**Tasks**:
- [ ] Add import for Bimodal.Metalogic.Representation.FiniteModelProperty
- [ ] Update tableau_complete and decide_complete theorems to reference FMP bounds
- [ ] Remove or update Line 77 comment ("Requires FMP and tableau completeness proof")
- [ ] Verify no new sorries introduced

**Timing**: 1.5 hours

**Files to modify**:
- `Bimodal/Metalogic/Decidability/Correctness.lean` - add FMP import and theorem updates

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` succeeds
- Correctness.lean imports FiniteModelProperty.lean

---

### Phase 3: Create Explicit Compactness Module [NOT STARTED]

**Goal**: Rename Applications/ to Compactness/ and create proper module structure

**Tasks**:
- [ ] Rename Metalogic/Applications/ to Metalogic/Compactness/
- [ ] Update Compactness.lean to import FMP
- [ ] Create Compactness/Applications.lean for corollaries if needed
- [ ] Update Metalogic.lean hub to reflect new module path
- [ ] Update any imports referencing old Applications path

**Timing**: 1 hour

**Files to modify**:
- `Bimodal/Metalogic/Applications/` -> `Bimodal/Metalogic/Compactness/` (rename)
- `Bimodal/Metalogic/Compactness/Compactness.lean` - add FMP import
- `Bimodal/Metalogic.lean` - update module hub

**Verification**:
- `lake build Bimodal.Metalogic.Compactness.Compactness` succeeds
- No references to old Applications/ path remain

---

### Phase 4: Extract Semantic Results from FiniteCanonicalModel.lean [NOT STARTED]

**Goal**: Move proven semantic_truth_lemma_v2 and semantic_weak_completeness to proper locations

**Tasks**:
- [ ] Identify exact line ranges for semantic_truth_lemma_v2 (proven)
- [ ] Move semantic_truth_lemma_v2 to Representation/TruthLemma.lean
- [ ] Identify exact line ranges for semantic_weak_completeness (proven)
- [ ] Move semantic_weak_completeness to Completeness/WeakCompleteness.lean (create if needed)
- [ ] Update FiniteCanonicalModel.lean to import from new locations
- [ ] Verify all imports resolve correctly

**Timing**: 1.5 hours

**Files to modify**:
- `Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - extract theorems
- `Bimodal/Metalogic/Representation/TruthLemma.lean` - receive semantic truth lemma
- `Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - create with semantic completeness

**Verification**:
- `lake build Bimodal.Metalogic` succeeds
- semantic_weak_completeness accessible from Completeness/WeakCompleteness.lean

---

### Phase 5: Deprecate Syntactic Approach to Boneyard [NOT STARTED]

**Goal**: Move deprecated syntactic finite model code (~1000 lines) to Boneyard/

**Tasks**:
- [ ] Create Bimodal/Metalogic/Boneyard/ directory
- [ ] Identify syntactic approach code (FiniteWorldState, finite_task_rel, lines ~800-1900)
- [ ] Move syntactic code to Boneyard/SyntacticFiniteModel.lean
- [ ] Create Boneyard/README.md explaining deprecation reasons
- [ ] Update FiniteCanonicalModel.lean with reference to Boneyard
- [ ] Remove historical commentary comparing old/new approaches

**Timing**: 1 hour

**Files to modify**:
- `Bimodal/Metalogic/Boneyard/SyntacticFiniteModel.lean` - new file with deprecated code
- `Bimodal/Metalogic/Boneyard/README.md` - deprecation documentation
- `Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - remove deprecated code

**Verification**:
- FiniteCanonicalModel.lean reduced significantly in size
- Boneyard/ contains deprecated code with documentation
- Main build still succeeds

---

### Phase 6: Documentation and Final Cleanup [NOT STARTED]

**Goal**: Create architecture documentation and remove historical commentary from all files

**Tasks**:
- [ ] Create Metalogic/README.md with FMP-centric architecture diagram
- [ ] Create/update README.md in each subdirectory (Core, Soundness, Representation, Completeness, Decidability, Compactness)
- [ ] Remove historical commentary from code files (past comparisons, "old approach" comments)
- [ ] Update module-level docstrings to reflect current state without history
- [ ] Create theorem inventory table in master README

**Timing**: 1 hour

**Files to modify**:
- `Bimodal/Metalogic/README.md` - create master architecture doc
- `Bimodal/Metalogic/*/README.md` - create subdirectory docs
- Various `.lean` files - remove historical commentary

**Verification**:
- All README.md files exist and are consistent
- No "old approach" or "previously" commentary in code
- `lake build Bimodal.Metalogic` succeeds with all changes

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic` succeeds after each phase
- [ ] No circular import errors
- [ ] All theorems accessible from expected module paths
- [ ] Import graph follows strict layer discipline (downstream never imports upstream)
- [ ] Boneyard/ code not imported by main codebase
- [ ] README files accurately describe module structure

## Artifacts & Outputs

- `specs/523_bimodal_cleanup/plans/implementation-001.md` (this file)
- `Bimodal/Metalogic/README.md` - master architecture documentation
- `Bimodal/Metalogic/Boneyard/` - deprecated code preservation
- `Bimodal/Metalogic/Compactness/` - renamed from Applications/
- `Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - extracted proven theorem
- `specs/523_bimodal_cleanup/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If restructuring causes persistent build failures:
1. Use git to restore previous state: `git checkout HEAD -- Bimodal/Metalogic/`
2. Identify failing import paths
3. Attempt more incremental approach (one file at a time)
4. If FMP is unproven scaffolding, document this and defer Decidability connection to future task

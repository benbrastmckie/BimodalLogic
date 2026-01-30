# Implementation Plan: Task #783 (Revised)

- **Task**: 783 - compare_branches_identify_restorable_elements
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: Task 782 (revert completed)
- **Research Inputs**: specs/783_compare_branches_identify_restorable_elements/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true (Phase 4 restores Lean code)
- **Version**: 002 (revised from 001)

## Overview

This plan restores documentation improvements from the backup/pre-revert-782 branch, establishes the UnderDevelopment/ directory pattern, and restores the sorry-free completeness theorem from FMP/SemanticCanonicalModel.lean.

### Changes from v001

- **Added Phase 4**: Restore FMP/SemanticCanonicalModel.lean with updated import to use monolithic Soundness.lean
- **Updated Non-Goals**: Removed FMP/SemanticCanonicalModel.lean from exclusion list
- **Lean Intent**: Now true (code changes in Phase 4)

### Research Integration

From research-001.md:
- 8 new README files identified in backup branch
- Typst chapter 04-metalogic.typ has extensive updates (~250 lines)
- UnderDevelopment/ pattern documented with import isolation rules
- FMP/SemanticCanonicalModel.lean: 433 lines, contains `semantic_weak_completeness` (sorry-free)

## Goals & Non-Goals

**Goals**:
- Cherry-pick documentation README files from backup branch
- Create Theories/Bimodal/Metalogic/UnderDevelopment/ directory with README.md explaining the pattern
- Cherry-pick typst chapter 04-metalogic.typ updates
- **NEW**: Restore FMP/SemanticCanonicalModel.lean with updated Soundness import

**Non-Goals**:
- Restore Soundness/ modularization (will use monolithic Soundness.lean)
- Restore Examples archived to Boneyard
- Restore Representation/ code to UnderDevelopment/
- Any other code changes beyond SemanticCanonicalModel.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cherry-pick conflicts | Medium | Low | Use `git checkout` to extract specific files rather than cherry-pick commits |
| Path mismatches | Low | Medium | Verify file paths exist on main before cherry-picking |
| Import path mismatch | Medium | High | Update import from `Soundness.Soundness` to `Soundness` |
| SemanticCanonicalModel.lean doesn't compile | High | Medium | Verify dependencies exist, fix imports |

## Implementation Phases

### Phase 1: Cherry-pick README files from backup [NOT STARTED]

**Goal**: Restore the documentation README files from backup branch

**Tasks**:
- [ ] Extract Metalogic/Algebraic/README.md from backup
- [ ] Extract Metalogic/Completeness/README.md from backup
- [ ] Extract Metalogic/Core/README.md from backup
- [ ] Extract Metalogic/FMP/README.md from backup
- [ ] Extract Metalogic/Soundness/README.md from backup
- [ ] Update main Metalogic/README.md with improved version from backup

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - create (147 lines)
- `Theories/Bimodal/Metalogic/Completeness/README.md` - create (89 lines)
- `Theories/Bimodal/Metalogic/Core/README.md` - create (156 lines)
- `Theories/Bimodal/Metalogic/FMP/README.md` - create (97 lines)
- `Theories/Bimodal/Metalogic/Soundness/README.md` - create (141 lines)
- `Theories/Bimodal/Metalogic/README.md` - update with improved version

**Verification**:
- All 6 README files exist in Metalogic/ subdirectories
- Main Metalogic/README.md has updated content

---

### Phase 2: Create UnderDevelopment/ directory with README [NOT STARTED]

**Goal**: Establish the UnderDevelopment/ directory pattern with clear documentation

**Tasks**:
- [ ] Create Theories/Bimodal/Metalogic/UnderDevelopment/ directory
- [ ] Create UnderDevelopment/README.md explaining the isolation pattern
- [ ] Document import isolation rules (can import from elsewhere, cannot be imported)
- [ ] Document root module commenting pattern for lake build isolation
- [ ] Note that this directory is for future use (content restoration deferred)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/README.md` - create (~100 lines)

**Verification**:
- UnderDevelopment/ directory exists
- README.md clearly explains the isolation pattern
- No code files were created (just documentation)

---

### Phase 3: Cherry-pick typst chapter 04 updates [NOT STARTED]

**Goal**: Restore typst documentation updates for chapter 04-metalogic.typ

**Tasks**:
- [ ] Compare current docs/formal-methods/04-metalogic.typ with backup version
- [ ] Extract updated content from backup/pre-revert-782
- [ ] Verify typst compilation succeeds after update (if typst is available)

**Timing**: 30 minutes

**Files to modify**:
- `docs/formal-methods/04-metalogic.typ` - update (~250 lines changed)

**Verification**:
- Chapter 04 reflects documentation of contrapositive completeness path
- Updated theorem dependency diagrams included
- Sorry status table included if present in backup

---

### Phase 4: Restore FMP/SemanticCanonicalModel.lean [NOT STARTED]

**Goal**: Restore the sorry-free completeness theorem

**Tasks**:
- [ ] Extract FMP/SemanticCanonicalModel.lean from backup/pre-revert-782
- [ ] Update import from `Bimodal.Metalogic.Soundness.Soundness` to `Bimodal.Metalogic.Soundness`
- [ ] Verify all other imports resolve correctly
- [ ] Run `lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel` to verify compilation
- [ ] Fix any additional import issues if needed

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - create (433 lines)

**Key Content Being Restored**:
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This theorem is completely sorry-free and provides completeness via contrapositive.

**Verification**:
- File exists and compiles without errors
- `semantic_weak_completeness` theorem is present
- No new sorries introduced
- `lake build` succeeds for the file

---

## Testing & Validation

- [ ] Verify all README files exist and are non-empty
- [ ] Verify UnderDevelopment/README.md explains isolation pattern
- [ ] Verify FMP/SemanticCanonicalModel.lean compiles
- [ ] Verify `semantic_weak_completeness` has no sorry
- [ ] Verify `lake build` succeeds overall

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)
- 6 README files in Metalogic/ subdirectories
- 1 README file in UnderDevelopment/
- Updated docs/formal-methods/04-metalogic.typ
- FMP/SemanticCanonicalModel.lean (433 lines, sorry-free completeness)

## Rollback/Contingency

If restoration causes issues:
1. Use `git checkout HEAD -- <file>` to restore individual files
2. Use `git reset --hard HEAD~1` to revert last commit (if needed)
3. If SemanticCanonicalModel.lean doesn't compile, can defer to separate task

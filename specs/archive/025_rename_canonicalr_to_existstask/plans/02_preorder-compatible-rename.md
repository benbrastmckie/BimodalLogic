# Implementation Plan: Task #25 v2 - Preorder-Compatible Rename

- **Task**: 25 - rename_canonicalr_to_existstask
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours (reduced from 14 hours)
- **Dependencies**: None (self-contained refactor)
- **Research Inputs**:
  - specs/025_rename_canonicalr_to_existstask/reports/01_team-research.md
  - specs/025_rename_canonicalr_to_existstask/reports/05_team-research.md (blocker analysis)
- **Supersedes**: plans/01_implementation-plan.md (v1 - blocked on fresh G-atom proofs)
- **Artifacts**: plans/02_preorder-compatible-rename.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

This revised plan accepts Task 29's preorder architecture and focuses on pure refactoring work. **Phases 1-2 from v1 are dropped** because they require proving per-witness strictness via fresh G-atoms, which is mathematically impossible for pathological MCS (same blocker that consumed weeks of Task 29 research).

### What Changed From v1

| v1 Phase | v2 Status | Reason |
|----------|-----------|--------|
| Phase 1: Fresh G-Atom Infrastructure | **DROPPED** | Fresh atom proofs fail for pathological MCS where G(¬q) ∈ M for all atoms |
| Phase 2: Update Call Sites | **DROPPED** | Per-witness strictness approach abandoned |
| Phase 3: Retire Gabbay Infrastructure | **→ Phase 1** | Simplified: keep two-layer architecture from Task 29 |
| Phase 4: Rename CanonicalR to ExistsTask | **→ Phase 2** | Core refactoring work |
| Phase 5: New Theorems | **DROPPED** | Optional enrichment not needed |

### Task 29 Context

Task 29 established a two-layer architecture:
- **Layer 1 (Basic Completeness)**: Uses reflexive preorder, `canonicalR_reflexive` proven via T-axiom
- **Layer 2 (Order-Theoretic)**: Preserves `canonicalR_irreflexive_axiom` for Cantor/NoMaxOrder/NoMinOrder

This plan preserves that architecture while renaming the relation. The axiom stays (it's Layer 2 infrastructure), but we mark it deprecated and document its purpose.

## Goals and Non-Goals

**Goals**:
- Rename CanonicalR to ExistsTask across all ~49 files (~800 usages)
- Clean up Gabbay naming set infrastructure (reduce CanonicalIrreflexivity.lean)
- Preserve Task 29's two-layer architecture
- Update docstrings to reflect preorder semantics
- Maintain build health throughout

**Non-Goals**:
- Proving per-witness strictness (mathematically blocked)
- Deleting `canonicalR_irreflexive_axiom` (Layer 2 still uses it)
- Changing the semantics of ExistsTask
- Resolving the axiom inconsistency (Task 26 scope)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking intermediate builds during rename | High | Medium | Atomic commits per file group; batch search-replace with verification |
| Edge cases in `rw [CanonicalR, ...]` sites | Low | Medium | Add `@[simp] lemma ExistsTask_def` for compatibility |
| Missing some usages | Low | Low | Grep verification after each batch |

## Implementation Phases

### Phase 1: Retire Gabbay Infrastructure [NOT STARTED]

**Goal**: Remove the naming set infrastructure that's no longer needed under reflexive semantics.

**Context**: CanonicalIrreflexivity.lean (~1500 lines) contains extensive Gabbay infrastructure from Task 967's reflexive semantics proof. Under Task 29's two-layer architecture, we keep:
- `canonicalR_reflexive` (Layer 1, proven via T-axiom)
- `canonicalR_past_reflexive` (Layer 1, symmetric)
- The deprecated axiom and wrappers (Layer 2, preserved)

Everything else (naming sets, iterated deduction, atom-free subsets) can be removed.

**Tasks**:
- [ ] **Task 1.1**: Identify removable vs preserved declarations
  - **To remove**: `atomFreeSubset`, `namingSet`, `naming_set_consistent`, `iterated_deduction`, `iterated_imp_in_mcs`, fresh G-atom attempts
  - **To keep**: reflexivity theorems, deprecated axiom wrappers
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 30 min
  - **Verification**: List all declarations to remove

- [ ] **Task 1.2**: Delete unused infrastructure
  - **Target**: Reduce file from ~1500 lines to ~200 lines
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 45 min
  - **Verification**: `lake build` succeeds

- [ ] **Task 1.3**: Update docstrings for two-layer architecture
  - **Add**: Documentation explaining Layer 1 vs Layer 2
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 15 min
  - **Verification**: Module docstring accurate

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` succeeds
- File reduced to <250 lines
- Reflexivity theorems preserved
- Layer 2 axiom infrastructure preserved

---

### Phase 2: Rename CanonicalR to ExistsTask [NOT STARTED]

**Goal**: Rename the definition and all ~800 usages across 49 files.

**Tasks**:
- [ ] **Task 2.1**: Rename definition in CanonicalFrame.lean
  - **Changes**:
    - `def CanonicalR` → `def ExistsTask`
    - `def CanonicalR_past` → `def ExistsTask_past`
    - Add `@[simp] lemma ExistsTask_def : ExistsTask M N = (g_content M ⊆ N) := rfl`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
  - **Estimate**: 30 min
  - **Verification**: `lake build` shows downstream errors (expected)

- [ ] **Task 2.2**: Batch rename in Bundle/ files (12 files)
  - **Approach**: Search-replace `CanonicalR` → `ExistsTask`, `canonicalR_` → `existsTask_`
  - **Files**: SuccRelation, CanonicalTaskRelation, CanonicalIrreflexivity, DirectIrreflexivity, CanonicalFMCS, ChainFMCS, FMCSTransfer, CanonicalConstruction, ClosedFlagIntBFMCS, etc.
  - **Estimate**: 1 hour
  - **Verification**: `lake build` for Bundle/ succeeds

- [ ] **Task 2.3**: Batch rename in Canonical/ files (5 files)
  - **Files**: CanonicalTimeline, CanonicalIrreflexivityAxiom, CanonicalSerialFrameInstance, ConstructiveFragment, etc.
  - **Estimate**: 45 min
  - **Verification**: `lake build` for Canonical/ succeeds

- [ ] **Task 2.4**: Batch rename in StagedConstruction/ files (10 files)
  - **Files**: CanonicalRecovery, CantorPrereqs, CantorApplication, ClosureSaturation, DenseTimeline, DensityFrameCondition, DiscreteSuccSeed, DovetailedTimelineQuot, etc.
  - **Estimate**: 1.5 hours
  - **Verification**: `lake build` for StagedConstruction/ succeeds

- [ ] **Task 2.5**: Batch rename in Domain/ files (3 files)
  - **Files**: CanonicalDomain, DiscreteTimeline, etc.
  - **Estimate**: 30 min
  - **Verification**: `lake build` for Domain/ succeeds

- [ ] **Task 2.6**: Manual review of edge cases
  - **Site 1**: `rw [CanonicalR, Set.not_subset]` → use ExistsTask_def
  - **Site 2**: `CanonicalR_chain` → `ExistsTask_chain`
  - **Site 3**: `CanonicalR_reachable` → `ExistsTask_reachable`
  - **Estimate**: 30 min
  - **Verification**: All rw tactics still work

- [ ] **Task 2.7**: Update Boneyard files (if any references)
  - **Estimate**: 15 min
  - **Verification**: `lake build` succeeds

**Timing**: 5 hours

**Files to modify**: 49 total across Theories/Bimodal/Metalogic/

**Verification**:
- `lake build` succeeds
- `grep -rw "CanonicalR" --include="*.lean" Theories/ | grep -v "CanonicalReachable\|CanonicalRelation" | wc -l` returns 0
- All theorem names updated (canonicalR_* → existsTask_*)

---

### Phase 3: Final Cleanup and Documentation [NOT STARTED]

**Goal**: Update documentation and verify consistency.

**Tasks**:
- [ ] **Task 3.1**: Update module docstrings
  - **Add**: ExistsTask documentation explaining it's the existential accessibility relation
  - **Add**: Note that ExistsTask is reflexive (via T-axiom)
  - **Files**: Key module files
  - **Estimate**: 30 min

- [ ] **Task 3.2**: Update README files
  - **Files**: Bundle/README.md, Canonical/README.md, StagedConstruction/README.md
  - **Estimate**: 30 min

- [ ] **Task 3.3**: Create implementation summary
  - **Output**: `specs/025_rename_canonicalr_to_existstask/summaries/01_rename-summary.md`
  - **Estimate**: 30 min

**Timing**: 1.5 hours

**Verification**:
- Documentation accurate
- README files updated
- Summary created

## Testing and Validation

- [ ] `lake build` succeeds after each phase
- [ ] No remaining references to `CanonicalR` (except reachability/relation concepts)
- [ ] All 49 files compile with renamed identifiers
- [ ] CanonicalIrreflexivity.lean reduced to <250 lines
- [ ] Edge cases (rw tactics) work with ExistsTask_def

## Artifacts and Outputs

- `specs/025_rename_canonicalr_to_existstask/plans/02_preorder-compatible-rename.md` (this file)
- `specs/025_rename_canonicalr_to_existstask/summaries/01_rename-summary.md` (after completion)
- Modified Lean files (49 files across Theories/Bimodal/Metalogic/)

## Relationship to Other Tasks

| Task | Relationship |
|------|--------------|
| Task 29 | Completed. This plan preserves Task 29's two-layer architecture |
| Task 26 | Separate. Axiom removal is Task 26's scope, not this task |
| Task 34 | Separate. Seed axiom proofs are Task 34's scope |
| Task 18 | Subsumed. ExistsTask alias is created here |

## Rollback/Contingency

- Each phase has atomic commits; rollback via `git revert` if needed
- If batch rename causes unexpected breakage, restore via `git checkout` and proceed incrementally

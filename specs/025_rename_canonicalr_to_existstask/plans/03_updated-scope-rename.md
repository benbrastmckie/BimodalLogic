# Implementation Plan: Task #25 v3 - Updated Scope Rename

- **Task**: 25 - rename_canonicalr_to_existstask
- **Status**: [NOT STARTED]
- **Effort**: 9.5-10.5 hours
- **Dependencies**: None (self-contained refactor)
- **Research Inputs**:
  - specs/025_rename_canonicalr_to_existstask/reports/01_team-research.md
  - specs/025_rename_canonicalr_to_existstask/reports/05_team-research.md (blocker analysis)
  - specs/025_rename_canonicalr_to_existstask/reports/06_task29-impact-analysis.md (scope update)
- **Supersedes**: plans/02_preorder-compatible-rename.md (v2 - estimates outdated)
- **Artifacts**: plans/03_updated-scope-rename.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

This plan updates v2 with accurate scope from research report 06. Task 29's two-layer architecture is complete (`canonicalR_reflexive` proven via T-axiom). The rename affects 1811 usages across 63 files (not ~800/49 as estimated). Phase 1 cleanup targets ~300 lines (not ~200) due to useful fresh atom infrastructure worth preserving.

### Research Integration

From report 06 (task29-impact-analysis.md):
- **Usage count**: 1811 usages across 63 files (2.3x higher than v2 estimate)
- **Phase 1 target**: ~300 lines after removing 1200+ lines of stale content
- **Task 29 complete**: Two-layer architecture established, no blockers
- **Task 35 independent**: Zero CanonicalR references in SuccChain files

### What Changed From v2

| v2 Estimate | v3 Actual | Change |
|-------------|-----------|--------|
| ~800 usages | 1811 usages | +126% |
| 49 files | 63 files | +29% |
| 6-8 hours total | 9.5-10.5 hours total | +50% |
| Phase 1: ~200 lines target | Phase 1: ~300 lines target | +50% |
| Phase 2: 5 hours | Phase 2: 6-7 hours | +30% |

## Goals and Non-Goals

**Goals**:
- Rename CanonicalR to ExistsTask across all 63 files (1811 usages)
- Clean up CanonicalIrreflexivity.lean (from ~1515 to ~300 lines)
- Preserve Task 29's two-layer architecture
- Update docstrings to reflect reflexive semantics (Layer 1) vs deprecated axiom (Layer 2)
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
| Boneyard files (700 usages) slow down verification | Medium | Medium | Process Boneyard last; can skip if time-constrained |

## Implementation Phases

### Phase 1: Retire Gabbay Infrastructure [COMPLETED]

**Goal**: Remove abandoned working notes and stale infrastructure while preserving useful components.

**Context**: CanonicalIrreflexivity.lean (1515 lines) contains:
- Lines 1-199: Useful infrastructure (imports, fresh atoms, reflexivity theorems)
- Lines 200-1467: ~1268 lines of abandoned working notes and sorried proofs
- Lines 1468-1515: Task 29's two-layer documentation and deprecated axiom

**Tasks**:
- [ ] **Task 1.1**: Audit file structure
  - **Purpose**: Map which sections to keep vs remove
  - **Keep**: Imports (1-65), fresh atom infrastructure (66-165), reflexivity theorems (166-199), two-layer docs (1468-1515)
  - **Remove**: Lines 200-1467 (abandoned proofs, MCS pathology analysis, sorried attempts)
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 30 min
  - **Verification**: Complete list of declarations to remove

- [ ] **Task 1.2**: Delete unused infrastructure
  - **Target**: Remove ~1200 lines, target file size ~300 lines
  - **Removals**:
    - Fresh G-Atom Per-Witness Strictness (lines 200-257)
    - `fresh_Gp_seed_consistent` and related (lines 258-457) - proven but unused
    - Extensive working notes (lines 508-1467) including sorried `Gp_seed_consistent`, `Gneg_seed_consistent`, MCS pathology analysis
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 45 min
  - **Verification**: `lake build` succeeds

- [ ] **Task 1.3**: Update docstrings for two-layer architecture
  - **Fix**: File header (lines 11-52) still references "strict temporal semantics" - update for reflexive semantics
  - **Add**: Clear documentation explaining Layer 1 (reflexive, proven) vs Layer 2 (deprecated axiom)
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 15 min
  - **Verification**: Module docstring accurately reflects Task 29 outcome

- [ ] **Task 1.4**: Preserve per-construction strictness infrastructure
  - **Keep**: `lt_of_canonicalR_and_not_reverse` (line 484 area) - helper for future per-construction proofs
  - **Note**: This ~50 lines of infrastructure is kept for future use even though not currently needed
  - **Estimate**: 15 min
  - **Verification**: Helper theorems preserved and documented

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` succeeds
- File reduced to ~300 lines (from 1515)
- Reflexivity theorems preserved (`canonicalR_reflexive`, `canonicalR_past_reflexive`)
- Layer 2 axiom infrastructure preserved (`canonicalR_irreflexive_axiom`)
- Per-construction helpers preserved (`lt_of_canonicalR_and_not_reverse`)

---

### Phase 2: Rename CanonicalR to ExistsTask [COMPLETED]

**Goal**: Rename the definition and all 1811 usages across 63 files.

**Tasks**:
- [ ] **Task 2.1**: Rename definition in CanonicalFrame.lean
  - **Changes**:
    - `def CanonicalR` -> `def ExistsTask`
    - `def CanonicalR_past` -> `def ExistsTask_past`
    - Add `@[simp] lemma ExistsTask_def : ExistsTask M N = (g_content M ⊆ N) := rfl`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
  - **Estimate**: 30 min
  - **Verification**: `lake build` shows downstream errors (expected)

- [ ] **Task 2.2**: Batch rename in Bundle/ files (12 files, ~300 usages)
  - **Approach**: Search-replace `CanonicalR` -> `ExistsTask`, `canonicalR_` -> `existsTask_`
  - **Files**: SuccRelation, CanonicalTaskRelation, CanonicalIrreflexivity, DirectIrreflexivity, CanonicalFMCS, ChainFMCS, FMCSTransfer, CanonicalConstruction, ClosedFlagIntBFMCS, etc.
  - **Estimate**: 1.5 hours
  - **Verification**: `lake build` for Bundle/ succeeds

- [ ] **Task 2.3**: Batch rename in StagedConstruction/ files (18 files, ~500 usages)
  - **Files**: CanonicalRecovery, CantorPrereqs, CantorApplication, ClosureSaturation, DenseTimeline, DensityFrameCondition, DiscreteSuccSeed, DovetailedTimelineQuot, etc.
  - **Estimate**: 2 hours
  - **Verification**: `lake build` for StagedConstruction/ succeeds

- [ ] **Task 2.4**: Batch rename in Algebraic/ files (12 files, ~200 usages)
  - **Files**: Various algebraic structure files
  - **Estimate**: 1 hour
  - **Verification**: `lake build` for Algebraic/ succeeds

- [ ] **Task 2.5**: Batch rename in Canonical/ files (5 files, ~50 usages)
  - **Files**: CanonicalTimeline, CanonicalIrreflexivityAxiom, ConstructiveFragment, etc.
  - **Estimate**: 45 min
  - **Verification**: `lake build` for Canonical/ succeeds

- [ ] **Task 2.6**: Batch rename in Domain/ files (3 files, ~20 usages)
  - **Files**: CanonicalDomain, DiscreteTimeline, etc.
  - **Estimate**: 30 min
  - **Verification**: `lake build` for Domain/ succeeds

- [ ] **Task 2.7**: Manual review of edge cases
  - **Site 1**: `rw [CanonicalR, Set.not_subset]` -> use ExistsTask_def
  - **Site 2**: `CanonicalR_chain` -> `ExistsTask_chain`
  - **Site 3**: `CanonicalR_reachable` -> `ExistsTask_reachable`
  - **Estimate**: 30 min
  - **Verification**: All rw tactics still work

- [ ] **Task 2.8**: Update Boneyard files (13 files, ~700 usages)
  - **Note**: These are abandoned experiments, lower priority
  - **Approach**: Mechanical rename, minimal verification
  - **Estimate**: 30 min
  - **Verification**: `lake build` succeeds (may have existing sorries)

**Timing**: 6-7 hours

**Files to modify**: 63 files across Theories/Bimodal/Metalogic/

**Verification**:
- `lake build` succeeds
- `grep -rw "CanonicalR" --include="*.lean" Theories/ | grep -v "CanonicalReachable\|CanonicalRelation" | wc -l` returns 0
- All theorem names updated (canonicalR_* -> existsTask_*)

---

### Phase 3: Final Cleanup and Documentation [IN PROGRESS]

**Goal**: Update documentation and verify consistency.

**Tasks**:
- [ ] **Task 3.1**: Update module docstrings
  - **Add**: ExistsTask documentation explaining it's the existential accessibility relation
  - **Add**: Note that ExistsTask is reflexive (via T-axiom, Layer 1)
  - **Add**: Note about deprecated axiom infrastructure (Layer 2)
  - **Files**: Key module files
  - **Estimate**: 30 min

- [ ] **Task 3.2**: Update README files
  - **Files**: Bundle/README.md, Canonical/README.md, StagedConstruction/README.md (if they exist)
  - **Estimate**: 30 min

- [ ] **Task 3.3**: Create implementation summary
  - **Output**: `specs/025_rename_canonicalr_to_existstask/summaries/01_rename-summary.md`
  - **Content**: Statistics (files, usages, lines removed), key decisions, verification results
  - **Estimate**: 30 min

**Timing**: 1.5 hours

**Verification**:
- Documentation accurate and reflects Task 29 outcome
- README files updated (where they exist)
- Summary created with statistics

## Testing and Validation

- [ ] `lake build` succeeds after each phase
- [ ] No remaining references to `CanonicalR` (except in compound names like CanonicalReachable, CanonicalRelation)
- [ ] All 63 files compile with renamed identifiers
- [ ] CanonicalIrreflexivity.lean reduced to ~300 lines
- [ ] Edge cases (rw tactics) work with ExistsTask_def
- [ ] Reflexivity theorems preserved and renamed to `existsTask_reflexive`

## Artifacts and Outputs

- `specs/025_rename_canonicalr_to_existstask/plans/03_updated-scope-rename.md` (this file)
- `specs/025_rename_canonicalr_to_existstask/summaries/01_rename-summary.md` (after completion)
- Modified Lean files (63 files across Theories/Bimodal/Metalogic/)

## Relationship to Other Tasks

| Task | Relationship |
|------|--------------|
| Task 29 | Completed. This plan preserves Task 29's two-layer architecture |
| Task 26 | Separate. Axiom removal is Task 26's scope, not this task |
| Task 34 | Separate. Seed axiom proofs are Task 34's scope |
| Task 35 | Independent. Zero CanonicalR references in SuccChain files |
| Task 18 | Subsumed. ExistsTask alias is created here |

## Rollback/Contingency

- Each phase has atomic commits; rollback via `git revert` if needed
- If batch rename causes unexpected breakage, restore via `git checkout` and proceed incrementally
- Boneyard files (Task 2.8) can be skipped if time-constrained (low priority)

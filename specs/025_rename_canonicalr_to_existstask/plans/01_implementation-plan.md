# Implementation Plan: Task #25 - Rename CanonicalR to ExistsTask

- **Task**: 25 - rename_canonicalr_to_existstask
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (self-contained refactor)
- **Research Inputs**: specs/025_rename_canonicalr_to_existstask/reports/01_team-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Shift the proof architecture from CanonicalR to ExistsTask as the primary abstraction for existential accessibility. The core insight from research: **the separation is already clean** - all 49 files using CanonicalR genuinely need existential accessibility semantics. The work is: (1) prove per-witness strictness via fresh G-atoms to resolve the Task 29 inconsistency, (2) retire the 1200-line Gabbay infrastructure, and (3) rename CanonicalR to ExistsTask across ~800 usages.

### Research Integration

Key findings from team research (3 teammates):
- **0 files misuse CanonicalR**: Every usage is genuinely existential accessibility
- **Two-level architecture is correct**: ExistsTask (binary relation) vs CanonicalTask/Succ (step-indexed)
- **12 `canonicalR_strict` call sites**: All share identical pattern replaceable with fresh G-atom
- **Gabbay infrastructure retirable**: 1200+ lines reduce to ~60 lines under reflexive semantics

## Goals and Non-Goals

**Goals**:
- Rename CanonicalR to ExistsTask across all 49 files (~800 usages)
- Prove per-witness strictness via fresh G-atoms (`existsTask_strict_fresh_atom`)
- Replace all 12 `canonicalR_strict` call sites with fresh G-atom approach
- Delete `canonicalR_irreflexive_axiom` and related deprecated infrastructure
- Retire Gabbay naming set infrastructure (reduce CanonicalIrreflexivity.lean to ~60 lines)
- Maintain build health throughout (incremental verification)

**Non-Goals**:
- Changing the semantics of ExistsTask (it remains g_content M ⊆ N)
- Modifying CanonicalTask or Succ relations (they are already separate and correct)
- Adding new theorems like `CanonicalTask_no_positive_cycle` (Phase 5 is optional enrichment)
- Fixing the `dovetailedTimeline_has_intermediate` sorry (independent gap)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fresh G-atom consistency proof is harder than expected | Medium | Low | The pattern is simpler than Gabbay's naming set proof; `Atom.exists_fresh` already exists |
| Breaking intermediate builds during rename | High | Medium | Phase 4 uses batch search-replace with immediate verification; atomic commits per file group |
| Edge cases in `rw [CanonicalR, ...]` sites | Low | Medium | Research identified 5 edge cases; add `@[simp] lemma ExistsTask_def` for compatibility |
| `inl h_eq` cases in CanonicalSerialFrameInstance | Medium | Low | Fresh G-atom in seed proves N != w.val via G(q) membership |

## Implementation Phases

### Phase 1: Fresh G-Atom Infrastructure [IN PROGRESS]

**Goal**: Establish the mathematical foundation for per-witness strictness that replaces universal irreflexivity.

**Tasks**:
- [ ] **Task 1.1**: Prove `fresh_atom_Gp_seed_consistent`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 1.5 hours
  - **Verification**: `lake build` succeeds; lemma type-checks

- [ ] **Task 1.2**: Prove `existsTask_strict_fresh_atom`
  - **Signature**: `(M : Set Formula) (hM : SetMaximalConsistent M) : ∃ W, SetMaximalConsistent W ∧ ExistsTask M W ∧ ¬ExistsTask W M`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 1.5 hours
  - **Dependencies**: Task 1.1
  - **Verification**: `lake build` succeeds; can be applied in proof

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Add fresh G-atom lemmas

**Verification**:
- `lake build` succeeds
- New lemmas can be used in subsequent phases
- No new axioms introduced

---

### Phase 2: Update Call Sites [NOT STARTED]

**Goal**: Replace all 12 `canonicalR_strict` call sites with fresh G-atom approach, delete the inconsistent axiom.

**Tasks**:
- [ ] **Task 2.1**: Update CantorApplication.lean (3 sites)
  - **Sites**: NoMaxOrder, NoMinOrder, DenselyOrdered (2 sub-sites)
  - **File**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
  - **Estimate**: 45 min
  - **Verification**: `lake build` succeeds

- [ ] **Task 2.2**: Update DovetailedTimelineQuot.lean (4 sites)
  - **Sites**: NoMaxOrder, NoMinOrder, DenselyOrdered (2 sites at lines 332-335)
  - **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
  - **Estimate**: 45 min
  - **Note**: The `dovetailedTimeline_has_intermediate` sorry (line 295) is independent
  - **Verification**: `lake build` succeeds

- [ ] **Task 2.3**: Update CanonicalSerialFrameInstance.lean (2 sites)
  - **Sites**: NoMaxOrder (lines 74-77), NoMinOrder (lines 121-123)
  - **File**: `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
  - **Estimate**: 1 hour
  - **Special handling**: `inl h_eq` cases need fresh G-atom to prove N != w.val
  - **Verification**: `lake build` succeeds

- [ ] **Task 2.4**: Update DiscreteTimeline.lean (2 sites)
  - **Sites**: NoMaxOrder (lines 144-145), NoMinOrder (lines 166-167)
  - **File**: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
  - **Estimate**: 30 min
  - **Verification**: `lake build` succeeds

- [ ] **Task 2.5**: Delete `canonicalR_irreflexive_axiom`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 15 min
  - **Also remove**: `canonicalR_irreflexive` (deprecated), `canonicalR_strict`, `canonicalR_antisymmetric_strict`
  - **Verification**: `lake build` succeeds; no remaining references

**Timing**: 3.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Verification**:
- `lake build` succeeds
- No references to `canonicalR_strict` remain
- No references to `canonicalR_irreflexive_axiom` remain
- `grep -r "canonicalR_strict\|canonicalR_irreflexive" --include="*.lean" | wc -l` returns 0

---

### Phase 3: Retire Gabbay Infrastructure [NOT STARTED]

**Goal**: Remove the 1200-line naming set infrastructure that served the old strict-semantics proof.

**Tasks**:
- [ ] **Task 3.1**: Identify removable infrastructure
  - **To remove**: `atomFreeSubset`, `namingSet`, `naming_set_consistent`, `iterated_deduction`, `iterated_imp_in_mcs`
  - **To keep**: `canonicalR_reflexive`, `canonicalR_past_reflexive`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 30 min
  - **Verification**: List all removed declarations

- [ ] **Task 3.2**: Delete Gabbay infrastructure
  - **Target**: Reduce file from ~1254 lines to ~60 lines
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  - **Estimate**: 30 min
  - **Verification**: `lake build` succeeds; file contains only reflexivity theorems + fresh G-atom

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Reduce from 1254 to ~60 lines

**Verification**:
- `lake build` succeeds
- File line count reduced to <100 lines
- Contains: `canonicalR_reflexive`, `canonicalR_past_reflexive`, fresh G-atom lemmas

---

### Phase 4: Rename CanonicalR to ExistsTask [NOT STARTED]

**Goal**: Rename the definition and all ~800 usages across 49 files.

**Tasks**:
- [ ] **Task 4.1**: Rename definition in CanonicalFrame.lean
  - **Change**: `def CanonicalR` -> `def ExistsTask`
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
  - **Estimate**: 30 min
  - **Also**: Add `@[simp] lemma ExistsTask_def : ExistsTask M N = (g_content M ⊆ N) := rfl`
  - **Also**: Rename `CanonicalR_past` -> `ExistsTask_past`
  - **Verification**: `lake build` shows downstream errors (expected)

- [ ] **Task 4.2**: Batch rename in Bundle/ files (12 files, ~200 usages)
  - **Files**: SuccRelation, CanonicalTaskRelation, CanonicalIrreflexivity, DirectIrreflexivity, CanonicalFMCS, ChainFMCS, FMCSTransfer, CanonicalConstruction, ClosedFlagIntBFMCS, etc.
  - **Estimate**: 1 hour
  - **Verification**: `lake build` for Bimodal.Metalogic.Bundle succeeds

- [ ] **Task 4.3**: Batch rename in Canonical/ files (5 files, ~70 usages)
  - **Files**: CanonicalTimeline, CanonicalIrreflexivityAxiom, CanonicalSerialFrameInstance, ConstructiveFragment, etc.
  - **Estimate**: 45 min
  - **Verification**: `lake build` for Bimodal.Metalogic.Canonical succeeds

- [ ] **Task 4.4**: Batch rename in StagedConstruction/ files (10 files, ~350 usages)
  - **Files**: CanonicalRecovery, CantorPrereqs, CantorApplication, ClosureSaturation, DenseTimeline, DensityFrameCondition, DiscreteSuccSeed, DovetailedTimelineQuot, etc.
  - **Estimate**: 1.5 hours
  - **Verification**: `lake build` for Bimodal.Metalogic.StagedConstruction succeeds

- [ ] **Task 4.5**: Batch rename in Domain/ files (3 files, ~25 usages)
  - **Files**: CanonicalDomain, DiscreteTimeline, etc.
  - **Estimate**: 30 min
  - **Verification**: `lake build` for Bimodal.Metalogic.Domain succeeds

- [ ] **Task 4.6**: Manual review of 5 edge cases
  - **Site 1**: `rw [CanonicalR, Set.not_subset]` in SeparationLemma.lean -> use ExistsTask_def
  - **Site 2**: `rw [CanonicalR, ...]` in ConstructiveFragment.lean -> use ExistsTask_def
  - **Site 3**: `CanonicalR_chain` -> `ExistsTask_chain` (distinct from CanonicalTask)
  - **Site 4**: `CanonicalR_past` -> `ExistsTask_past`
  - **Site 5**: `CanonicalR_reachable` -> `ExistsTask_reachable`
  - **Estimate**: 30 min
  - **Verification**: All rw tactics still work

- [ ] **Task 4.7**: Update Boneyard files (6 files)
  - **Files**: Boneyard/*.lean files containing CanonicalR references
  - **Estimate**: 15 min
  - **Verification**: `lake build` succeeds

**Timing**: 5 hours

**Files to modify** (49 total):
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Definition rename
- `Theories/Bimodal/Metalogic/Bundle/*.lean` - 12 files
- `Theories/Bimodal/Metalogic/Canonical/*.lean` - 5 files
- `Theories/Bimodal/Metalogic/StagedConstruction/*.lean` - 10 files
- `Theories/Bimodal/Metalogic/Domain/*.lean` - 3 files
- `Theories/Bimodal/Boneyard/*.lean` - 6 files

**Verification**:
- `lake build` succeeds
- `grep -r "CanonicalR\b" --include="*.lean" | grep -v "ExistsTask\|CanonicalReachable\|CanonicalRelation" | wc -l` returns 0
- All theorem names updated (canonicalR_* -> existsTask_*)

---

### Phase 5: New CanonicalTask Theorems (Optional) [NOT STARTED]

**Goal**: Strengthen the theoretical foundation with explicit step-level progress theorems.

**Tasks**:
- [ ] **Task 5.1**: Prove `CanonicalTask_no_positive_cycle`
  - **Statement**: No positive-length Succ-chain loops back to the starting MCS
  - **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
  - **Estimate**: 1.5 hours
  - **Verification**: `lake build` succeeds

- [ ] **Task 5.2**: Prove `Succ_step_changes_content`
  - **Statement**: Every Succ step results in distinct MCS content
  - **File**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
  - **Estimate**: 1 hour
  - **Verification**: `lake build` succeeds

**Timing**: 2.5 hours (optional enrichment)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

**Verification**:
- `lake build` succeeds
- New theorems can be applied in proofs

## Testing and Validation

- [ ] `lake build` succeeds after each phase
- [ ] No remaining references to deprecated `canonicalR_strict` or `canonicalR_irreflexive_axiom`
- [ ] All 49 files compile with renamed identifiers
- [ ] No new axioms introduced (verify with `#print axioms` on key theorems)
- [ ] Fresh G-atom lemma applies correctly at all 12 call sites
- [ ] CanonicalIrreflexivity.lean reduced to <100 lines
- [ ] Edge cases (rw tactics) work with ExistsTask_def

## Artifacts and Outputs

- `specs/025_rename_canonicalr_to_existstask/plans/01_implementation-plan.md` (this file)
- `specs/025_rename_canonicalr_to_existstask/summaries/01_implementation-summary.md` (after completion)
- Modified Lean files (49 files across Theories/Bimodal/Metalogic/)

## Rollback/Contingency

- Each phase has atomic commits; rollback via `git revert` if needed
- If fresh G-atom proof is blocked, preserve current state and document the gap
- If batch rename causes unexpected breakage, restore via `git checkout` and proceed incrementally
- Phase 5 is optional and can be deferred without blocking task completion
